//// Verify that an HTTP request really came from Slack.
////
//// Slack signs every request it sends to your app with your app's signing
//// secret (found under Basic Information in your app's settings). Check the
//// signature before trusting the body. See
//// <https://docs.slack.dev/authentication/verifying-requests-from-slack>.
////
//// ```gleam
//// case verify.request(request, signing_secret) {
////   Ok(Nil) -> handle(request)
////   Error(_) -> response.new(401)
//// }
//// ```

import gleam/bit_array
import gleam/crypto
import gleam/http/request.{type Request}
import gleam/int
import gleam/result
import gleam/string

/// How far a request timestamp may drift from the current time, in seconds,
/// before `check` rejects it as a replay. Slack recommends five minutes.
pub const max_age_seconds = 300

/// Why a request failed verification.
pub type VerifyError {
  /// The `x-slack-request-timestamp` header is missing or not a number.
  MissingTimestamp
  /// The `x-slack-signature` header is missing.
  MissingSignature
  /// The timestamp is more than `max_age_seconds` away from now.
  StaleTimestamp(timestamp: Int, now: Int)
  /// The signature does not match the body.
  InvalidSignature
}

/// Verifies a request against the current time.
pub fn request(
  request: Request(String),
  signing_secret: String,
) -> Result(Nil, VerifyError) {
  request_at(request, signing_secret, now_seconds())
}

/// Verifies a request against an explicit time (unix seconds). Useful for
/// tests and replayed traffic.
pub fn request_at(
  request: Request(String),
  signing_secret: String,
  now: Int,
) -> Result(Nil, VerifyError) {
  use timestamp <- result.try(
    request.get_header(request, "x-slack-request-timestamp")
    |> result.try(int.parse)
    |> result.replace_error(MissingTimestamp),
  )
  use signature <- result.try(
    request.get_header(request, "x-slack-signature")
    |> result.replace_error(MissingSignature),
  )
  check(signing_secret, timestamp, signature, request.body, now)
}

/// Verifies the raw pieces of a signed request.
pub fn check(
  signing_secret signing_secret: String,
  timestamp timestamp: Int,
  signature signature: String,
  body body: String,
  now now: Int,
) -> Result(Nil, VerifyError) {
  case int.absolute_value(now - timestamp) > max_age_seconds {
    True -> Error(StaleTimestamp(timestamp:, now:))
    False -> {
      let expected = sign(signing_secret, timestamp, body)
      case
        crypto.secure_compare(
          bit_array.from_string(expected),
          bit_array.from_string(signature),
        )
      {
        True -> Ok(Nil)
        False -> Error(InvalidSignature)
      }
    }
  }
}

/// The `x-slack-signature` value Slack would send for a body. Use it to sign
/// requests in tests.
pub fn sign(signing_secret: String, timestamp: Int, body: String) -> String {
  let base = "v0:" <> int.to_string(timestamp) <> ":" <> body
  let digest =
    crypto.hmac(
      bit_array.from_string(base),
      crypto.Sha256,
      bit_array.from_string(signing_secret),
    )
  "v0=" <> string.lowercase(bit_array.base16_encode(digest))
}

/// The current unix time in seconds.
@external(erlang, "slackline_ffi", "now_seconds")
@external(javascript, "../slackline_ffi.mjs", "now_seconds")
pub fn now_seconds() -> Int
