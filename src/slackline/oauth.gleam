//// Install an app with OAuth v2, or sign users in with Sign in with Slack.
////
//// 1. Send the user to `authorize_url(...)`.
//// 2. Slack redirects back to your `redirect_uri` with `code` and `state`.
//// 3. Check the state with `verify_state`, then exchange the code with
////    `slackline/api/oauth.v2_access` using an anonymous client.
////
//// ```gleam
//// let url =
////   oauth.authorize_url(
////     oauth.Authorize(
////       ..oauth.authorize(client_id: "123.456"),
////       scopes: ["chat:write", "commands"],
////       state: Some(oauth.sign_state(secret)),
////     ),
////   )
//// ```
////
//// See <https://docs.slack.dev/authentication/installing-with-oauth>,
//// <https://docs.slack.dev/authentication/using-pkce> and
//// <https://docs.slack.dev/authentication/sign-in-with-slack>.

import gleam/bit_array
import gleam/crypto
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/uri
import slackline/verify

/// Where to send users to install an app on the commercial Slack cloud.
pub const authorize_endpoint = "https://slack.com/oauth/v2/authorize"

/// Where to send users to install an app on GovSlack.
pub const gov_authorize_endpoint = "https://slack-gov.com/oauth/v2/authorize"

/// Where to send users for Sign in with Slack (OpenID Connect).
pub const openid_authorize_endpoint =
  "https://slack.com/openid/connect/authorize"

/// The parameters of an OAuth v2 install link.
pub type Authorize {
  Authorize(
    /// Defaults to `authorize_endpoint`.
    endpoint: String,
    /// Your app's client id.
    client_id: String,
    /// Scopes for the bot token.
    scopes: List(String),
    /// Scopes for a user token, if your app acts on behalf of users.
    user_scopes: List(String),
    /// Must match, or be below, a redirect url in your app settings.
    redirect_uri: Option(String),
    /// An opaque value echoed back to your redirect url. Use `sign_state`.
    state: Option(String),
    /// A workspace (`T…`) or organization (`E…`) id to suggest. Slack treats
    /// it as a hint. Trust the `oauth.v2.access` response.
    team: Option(String),
    /// A PKCE challenge from `pkce_challenge`. Sends
    /// `code_challenge_method=S256` alongside it.
    code_challenge: Option(String),
  )
}

/// An install link for `client_id` with nothing else set.
pub fn authorize(client_id client_id: String) -> Authorize {
  Authorize(
    endpoint: authorize_endpoint,
    client_id:,
    scopes: [],
    user_scopes: [],
    redirect_uri: None,
    state: None,
    team: None,
    code_challenge: None,
  )
}

/// Renders the install link.
pub fn authorize_url(authorize: Authorize) -> String {
  let query =
    [
      Some(#("client_id", authorize.client_id)),
      non_empty("scope", authorize.scopes),
      non_empty("user_scope", authorize.user_scopes),
      option.map(authorize.redirect_uri, pair("redirect_uri", _)),
      option.map(authorize.state, pair("state", _)),
      option.map(authorize.team, pair("team", _)),
      option.map(authorize.code_challenge, pair("code_challenge", _)),
      option.map(authorize.code_challenge, fn(_) {
        #("code_challenge_method", "S256")
      }),
    ]
    |> option.values
  authorize.endpoint <> "?" <> uri.query_to_string(query)
}

/// The parameters of a Sign in with Slack link.
pub type OpenIdAuthorize {
  OpenIdAuthorize(
    endpoint: String,
    client_id: String,
    /// Usually `["openid", "profile", "email"]`.
    scopes: List(String),
    redirect_uri: String,
    state: Option(String),
    /// Echoed in the id token, so you can detect replays.
    nonce: Option(String),
    team: Option(String),
  )
}

/// A Sign in with Slack link asking for `openid`, `profile` and `email`.
pub fn openid_authorize(
  client_id client_id: String,
  redirect_uri redirect_uri: String,
) -> OpenIdAuthorize {
  OpenIdAuthorize(
    endpoint: openid_authorize_endpoint,
    client_id:,
    scopes: ["openid", "profile", "email"],
    redirect_uri:,
    state: None,
    nonce: None,
    team: None,
  )
}

/// Renders the Sign in with Slack link.
pub fn openid_authorize_url(authorize: OpenIdAuthorize) -> String {
  let query =
    [
      Some(#("response_type", "code")),
      Some(#("scope", string.join(authorize.scopes, " "))),
      Some(#("client_id", authorize.client_id)),
      Some(#("redirect_uri", authorize.redirect_uri)),
      option.map(authorize.state, pair("state", _)),
      option.map(authorize.nonce, pair("nonce", _)),
      option.map(authorize.team, pair("team", _)),
    ]
    |> option.values
  authorize.endpoint <> "?" <> uri.query_to_string(query)
}

fn pair(key: String, value: String) -> #(String, String) {
  #(key, value)
}

fn non_empty(key: String, values: List(String)) -> Option(#(String, String)) {
  case values {
    [] -> None
    _ -> Some(#(key, string.join(values, ",")))
  }
}

// ---- PKCE ------------------------------------------------------------------

/// A fresh random PKCE code verifier. Keep it and send it as `code_verifier`
/// in the code exchange.
pub fn pkce_verifier() -> String {
  crypto.strong_random_bytes(32) |> bit_array.base64_url_encode(False)
}

/// The S256 code challenge for a verifier.
pub fn pkce_challenge(verifier: String) -> String {
  crypto.hash(crypto.Sha256, bit_array.from_string(verifier))
  |> bit_array.base64_url_encode(False)
}

// ---- state -----------------------------------------------------------------

/// How far ahead of now a state may be stamped, in seconds, to allow for
/// clocks that disagree.
const clock_skew_seconds = 60

/// How long a signed state stays valid, in seconds.
pub const state_max_age_seconds = 600

/// A tamper-proof `state` value signed with `secret` and stamped with the
/// current time. Use any long random string you keep private as the secret.
pub fn sign_state(secret: String) -> String {
  sign_state_at(secret, verify.now_seconds())
}

/// `sign_state` at an explicit unix time.
pub fn sign_state_at(secret: String, now: Int) -> String {
  let nonce =
    crypto.strong_random_bytes(16) |> bit_array.base64_url_encode(False)
  let payload = bit_array.from_string(int.to_string(now) <> "." <> nonce)
  crypto.sign_message(payload, bit_array.from_string(secret), crypto.Sha256)
}

/// Why a state value was rejected.
pub type StateError {
  /// The signature does not match, so the state was forged or mangled.
  InvalidState
  /// The state is older than `state_max_age_seconds`.
  ExpiredState
}

/// Checks a state value produced by `sign_state`.
pub fn verify_state(secret: String, state: String) -> Result(Nil, StateError) {
  verify_state_at(secret, state, verify.now_seconds())
}

/// `verify_state` at an explicit unix time.
pub fn verify_state_at(
  secret: String,
  state: String,
  now: Int,
) -> Result(Nil, StateError) {
  use payload <- result.try(
    crypto.verify_signed_message(state, bit_array.from_string(secret))
    |> result.try(bit_array.to_string)
    |> result.replace_error(InvalidState),
  )
  use issued <- result.try(
    string.split(payload, ".")
    |> list.first
    |> result.try(int.parse)
    |> result.replace_error(InvalidState),
  )
  case
    now - issued > state_max_age_seconds || issued - now > clock_skew_seconds
  {
    True -> Error(ExpiredState)
    False -> Ok(Nil)
  }
}
