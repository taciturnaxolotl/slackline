import gleam/dynamic/decode
import gleam/http/request
import gleam/http/response
import gleam/option
import gleam/string
import gleeunit
import multipartkit
import multipartkit/part
import slackline
import slackline/value

pub fn main() -> Nil {
  gleeunit.main()
}

// A typed call without depending on generated code.
fn auth_test() -> slackline.Call(slackline.Raw, String) {
  slackline.raw("auth.test", [])
  |> slackline.decode_with(decode.at(["url"], decode.string))
}

fn reply(status: Int, body: String) -> response.Response(String) {
  response.new(status) |> response.set_body(body)
}

pub fn rate_limited_test() {
  let res = reply(429, "") |> response.set_header("retry-after", "30")
  assert slackline.response(auth_test(), res)
    == Error(slackline.RateLimited(30))
  assert slackline.response(auth_test(), reply(429, ""))
    == Error(slackline.RateLimited(1))
}

pub fn api_error_test() {
  let assert Error(slackline.ApiError(error: "invalid_auth", ..)) =
    slackline.response(
      auth_test(),
      reply(200, "{\"ok\":false,\"error\":\"invalid_auth\"}"),
    )
  let assert Error(slackline.ApiError(error: "unknown_error", ..)) =
    slackline.response(auth_test(), reply(200, "{\"ok\":false}"))
}

pub fn unexpected_response_test() {
  assert slackline.response(auth_test(), reply(502, "<html>bad gateway</html>"))
    == Error(slackline.UnexpectedResponse(502, "<html>bad gateway</html>"))
  assert slackline.response(auth_test(), reply(200, "{\"no_ok\":1}"))
    == Error(slackline.UnexpectedResponse(200, "{\"no_ok\":1}"))
}

pub fn decode_error_keeps_raw_test() {
  let assert Error(slackline.DecodeError(raw:, ..)) =
    slackline.response(auth_test(), reply(200, "{\"ok\":true,\"url\":5}"))
  assert value.field(raw, "url") == Ok(value.Int(5))
}

pub fn base_url_test() {
  let assert Ok(client) =
    slackline.new("xoxb-1")
    |> slackline.with_base_url("http://localhost:8080/mock")
  let req = slackline.request(auth_test(), client)
  assert req.host == "localhost"
  assert req.port == option.Some(8080)
  assert req.path == "/mock/auth.test"
  assert slackline.with_base_url(client, "ftp://nope") == Error(Nil)
}

pub fn anonymous_sends_no_token_test() {
  let oauth_call = slackline.raw("oauth.v2.access", [#("code", "c")])
  let req = slackline.request(oauth_call, slackline.anonymous())
  assert request.get_header(req, "authorization") == Error(Nil)
  let req = slackline.request(oauth_call, slackline.new("xoxb-1"))
  assert request.get_header(req, "authorization") == Ok("Bearer xoxb-1")
}

pub fn with_header_test() {
  let client =
    slackline.new("xoxb-1") |> slackline.with_header("User-Agent", "bot/1")
  let req = slackline.request(auth_test(), client)
  assert request.get_header(req, "user-agent") == Ok("bot/1")
}

pub fn webhook_response_test() {
  assert slackline.webhook_response(reply(200, "ok")) == Ok(Nil)
  let assert Error(slackline.ApiError(error: "invalid_payload", ..)) =
    slackline.webhook_response(reply(400, "invalid_payload\n"))
  assert slackline.webhook_response(reply(500, ""))
    == Error(slackline.UnexpectedResponse(500, ""))
}

pub fn upload_response_test() {
  assert slackline.upload_response(reply(200, "OK - 12")) == Ok(Nil)
  assert slackline.upload_response(reply(413, "too big"))
    == Error(slackline.UnexpectedResponse(413, "too big"))
}

pub fn describe_error_test() {
  assert slackline.describe_error(slackline.RateLimited(30))
    == "rate limited, retry after 30s"
  assert slackline.describe_error(slackline.ApiError(
      "not_in_channel",
      value.Null,
    ))
    == "slack api error: not_in_channel"
}

pub fn urlencoded_body_test() {
  let call = slackline.raw("chat.postMessage", [#("text", "a b&c")])
  let req = slackline.request(call, slackline.new("xoxb-1"))
  assert request.get_header(req, "content-type")
    == Ok("application/x-www-form-urlencoded")
  assert req.body == <<"text=a%20b%26c":utf8>>
}

pub fn multipart_body_test() {
  let png = <<137, 80, 78, 71, 0, 255>>
  let call =
    slackline.raw("users.setPhoto", [#("crop_w", "100")])
    |> slackline.with_file(
      "image",
      slackline.FileUpload(
        filename: "avatar.png",
        content_type: "image/png",
        contents: png,
      ),
    )
  let req = slackline.request(call, slackline.new("xoxb-1"))
  let assert Ok(content_type) = request.get_header(req, "content-type")
  assert string.starts_with(content_type, "multipart/form-data; boundary=")
  let assert Ok([field, file]) = multipartkit.parse(req.body, content_type)
  assert part.name(field) == option.Some("crop_w")
  assert part.body(field) == <<"100":utf8>>
  assert part.name(file) == option.Some("image")
  assert part.filename(file) == option.Some("avatar.png")
  assert part.content_type(file) == option.Some("image/png")
  assert part.body(file) == png
}

pub fn with_file_replaces_test() {
  let file = fn(name) {
    slackline.FileUpload(filename: name, content_type: "text/plain", contents: <<
      name:utf8,
    >>)
  }
  let call =
    slackline.raw("files.upload", [])
    |> slackline.with_file("file", file("a.txt"))
    |> slackline.with_file("file", file("b.txt"))
  assert slackline.files(call) == [#("file", file("b.txt"))]
}
