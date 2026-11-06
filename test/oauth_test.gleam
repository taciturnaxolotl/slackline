import gleam/bit_array
import gleam/option.{Some}
import gleam/string
import slackline/oauth

pub fn pkce_matches_docs_test() {
  assert oauth.pkce_challenge("secretpassword")
    == "ldMBaaWcQYtSATMV_IG8mf3wp7A6EW80arYoSW80ntU"
}

pub fn authorize_url_test() {
  let url =
    oauth.authorize_url(
      oauth.Authorize(
        ..oauth.authorize(client_id: "33336676.569200954261"),
        scopes: ["incoming-webhook"],
        user_scopes: ["search:read"],
      ),
    )
  assert url
    == "https://slack.com/oauth/v2/authorize?client_id=33336676.569200954261&scope=incoming-webhook&user_scope=search%3Aread"
}

pub fn state_test() {
  let state = oauth.sign_state_at("secret", 1000)
  assert oauth.verify_state_at("secret", state, 1100) == Ok(Nil)
  assert oauth.verify_state_at("other", state, 1100)
    == Error(oauth.InvalidState)
  assert oauth.verify_state_at("secret", state, 5000)
    == Error(oauth.ExpiredState)
  assert string.length(state) > 10
}

pub fn state_from_the_future_test() {
  let state = oauth.sign_state_at("secret", 2000)
  assert oauth.verify_state_at("secret", state, 1950) == Ok(Nil)
  assert oauth.verify_state_at("secret", state, 1900)
    == Error(oauth.ExpiredState)
}

pub fn tampered_state_test() {
  // A state is `header.payload.signature`. Change the payload, keep the rest.
  let assert [header, _, signature] =
    string.split(oauth.sign_state_at("secret", 1000), ".")
  let payload = bit_array.base64_url_encode(<<"1090.forged":utf8>>, False)
  let forged = header <> "." <> payload <> "." <> signature
  assert oauth.verify_state_at("secret", forged, 1100)
    == Error(oauth.InvalidState)
  assert oauth.verify_state_at("secret", "not-a-state", 1100)
    == Error(oauth.InvalidState)
}

pub fn pkce_url_test() {
  let url =
    oauth.authorize_url(
      oauth.Authorize(
        ..oauth.authorize(client_id: "123.456"),
        user_scopes: ["chat:write"],
        code_challenge: Some(oauth.pkce_challenge("secretpassword")),
      ),
    )
  assert string.ends_with(
    url,
    "&code_challenge=ldMBaaWcQYtSATMV_IG8mf3wp7A6EW80arYoSW80ntU&code_challenge_method=S256",
  )
}

pub fn openid_url_test() {
  let url =
    oauth.openid_authorize_url(
      oauth.OpenIdAuthorize(
        ..oauth.openid_authorize(
          client_id: "s6BhdRkqt3",
          redirect_uri: "https://client.example.org/cb",
        ),
        state: Some("af0ifjsldkj"),
        nonce: Some("abcd"),
      ),
    )
  assert url
    == "https://slack.com/openid/connect/authorize?response_type=code&scope=openid%20profile%20email&client_id=s6BhdRkqt3&redirect_uri=https%3A%2F%2Fclient.example.org%2Fcb&state=af0ifjsldkj&nonce=abcd"
}
