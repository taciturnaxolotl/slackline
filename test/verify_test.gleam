import gleam/http/request
import gleam/list
import slackline/verify

// Example from https://docs.slack.dev/authentication/verifying-requests-from-slack
const secret = "8f742231b10e8888abcd99yyyzzz85a5"

const body =
  "token=xyzz0WbapA4vBCDEFasx0q6G&team_id=T1DC2JH3J&team_domain=testteamnow&channel_id=G8PSS9T3V&channel_name=foobar&user_id=U2CERLKJA&user_name=roadrunner&command=%2Fwebhook-collect&text=&response_url=https%3A%2F%2Fhooks.slack.com%2Fcommands%2FT1DC2JH3J%2F397700885554%2F96rGlfmibIGlgcZRskXaIFfN&trigger_id=398738663015.47445629121.803a0bc887a14d10d2c447fce8b6703c"

const signature =
  "v0=a2114d57b48eac39b9ad189dd8316235a7b4a8d21a10bd27519666489c69b503"

pub fn sign_matches_docs_test() {
  assert verify.sign(secret, 1_531_420_618, body) == signature
}

pub fn request_test() {
  let req =
    request.new()
    |> request.set_header("x-slack-request-timestamp", "1531420618")
    |> request.set_header("x-slack-signature", signature)
    |> request.set_body(body)
  assert verify.request_at(req, secret, 1_531_420_700) == Ok(Nil)
  assert verify.request_at(req, "wrong", 1_531_420_700)
    == Error(verify.InvalidSignature)
  assert verify.request_at(req, secret, 1_531_430_000)
    == Error(verify.StaleTimestamp(1_531_420_618, 1_531_430_000))
}

fn with_headers(headers: List(#(String, String))) -> request.Request(String) {
  list.fold(headers, request.new() |> request.set_body(body), fn(req, header) {
    request.set_header(req, header.0, header.1)
  })
}

pub fn missing_headers_test() {
  assert verify.request_at(
      with_headers([#("x-slack-signature", signature)]),
      secret,
      1_531_420_700,
    )
    == Error(verify.MissingTimestamp)
  assert verify.request_at(
      with_headers([
        #("x-slack-request-timestamp", "soon"),
        #("x-slack-signature", signature),
      ]),
      secret,
      1_531_420_700,
    )
    == Error(verify.MissingTimestamp)
  assert verify.request_at(
      with_headers([#("x-slack-request-timestamp", "1531420618")]),
      secret,
      1_531_420_700,
    )
    == Error(verify.MissingSignature)
}

pub fn future_timestamp_test() {
  let req =
    with_headers([
      #("x-slack-request-timestamp", "1531420618"),
      #("x-slack-signature", signature),
    ])
  assert verify.request_at(req, secret, 1_531_420_000)
    == Error(verify.StaleTimestamp(1_531_420_618, 1_531_420_000))
}

pub fn tampered_body_test() {
  let req =
    with_headers([
      #("x-slack-request-timestamp", "1531420618"),
      #("x-slack-signature", signature),
    ])
    |> request.set_body(body <> "&extra=1")
  assert verify.request_at(req, secret, 1_531_420_700)
    == Error(verify.InvalidSignature)
}
