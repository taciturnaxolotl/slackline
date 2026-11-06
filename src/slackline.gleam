//// The Slack platform for Gleam: every Web API method, Block Kit, the
//// Events API, interactivity, OAuth and Socket Mode, typed from the official
//// reference at <https://docs.slack.dev>.
////
//// The Web API side does no IO. Each method in `slackline/api/*` takes its
//// required arguments and returns a `Call`: an HTTP request plus a decoder
//// for its response. Optional arguments are setters in a module named after
//// the method. Send the call with the HTTP client for your target:
////
//// ```gleam
//// import slackline
//// import slackline/api/chat
//// import slackline/api/chat/post_message
//// import slackline/httpc
////
//// pub fn main() {
////   let client = slackline.new("xoxb-your-token")
////   let assert Ok(posted) =
////     chat.post_message(channel: "C123", text: "hi")
////     |> post_message.unfurl_links(False)
////     |> httpc.send(client)
////   posted.ts
//// }
//// ```
////
//// A `Call(method, a)` carries its method as a type, such as
//// `chat.PostMessage`. A setter only accepts calls to its own method.
////
//// `slackline/httpc` sends on Erlang and `slackline/fetch` sends on
//// JavaScript. For any other client, build the request with `request` and
//// decode the response with `response`.
////
//// Methods that return pages take a `cursor` and return `response_metadata`.
//// `next_page` gives the call for the next page:
////
//// ```gleam
//// let call = conversations.list()
//// let assert Ok(page) = httpc.send(call, client)
//// case slackline.next_page(call, page.response_metadata) {
////   Some(next) -> todo as "send next"
////   None -> todo as "that was the last page"
//// }
//// ```
////
//// `httpc.fold_pages` and `fetch.fold_pages` do the whole loop.

import gleam/bit_array
import gleam/dynamic/decode.{type Decoder}
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/uri
import multipartkit
import multipartkit/form
import slackline/value.{type Value}

/// The default Web API base url.
pub const slack_api_url = "https://slack.com/api/"

/// The Web API base url for GovSlack workspaces.
pub const gov_slack_api_url = "https://slack-gov.com/api/"

/// The token to call the Web API with, and where to send calls.
pub opaque type Client {
  Client(token: Option(String), base: uri.Uri, headers: List(#(String, String)))
}

fn client(token: Option(String)) -> Client {
  let assert Ok(base) = uri.parse(slack_api_url)
  Client(token:, base:, headers: [])
}

/// A client that authenticates with a bot (`xoxb-`), user (`xoxp-`) or
/// app-level (`xapp-`) token.
pub fn new(token: String) -> Client {
  client(Some(token))
}

/// A client without a token, for methods such as `oauth.v2.access` that
/// authenticate with client credentials instead.
pub fn anonymous() -> Client {
  client(None)
}

/// Swaps the token a client sends.
pub fn with_token(client: Client, token: String) -> Client {
  Client(..client, token: Some(token))
}

/// Points a client at a different Web API base url, such as
/// `gov_slack_api_url` or a local mock server.
pub fn with_base_url(client: Client, url: String) -> Result(Client, Nil) {
  use base <- result.try(uri.parse(url))
  case base.scheme, base.host {
    Some("https"), Some(_) | Some("http"), Some(_) -> {
      let path = case string.ends_with(base.path, "/") {
        True -> base.path
        False -> base.path <> "/"
      }
      Ok(Client(..client, base: uri.Uri(..base, path:)))
    }
    _, _ -> Error(Nil)
  }
}

/// Adds a header to every request, such as a custom `user-agent`.
pub fn with_header(client: Client, name: String, value: String) -> Client {
  Client(..client, headers: [#(string.lowercase(name), value), ..client.headers])
}

/// One Web API method call: its name, its arguments and how to decode a
/// successful response. `method` names the method as a type, such as
/// `chat.PostMessage`, and `a` is the decoded response.
pub opaque type Call(method, a) {
  Call(
    method: String,
    params: List(#(String, String)),
    files: List(#(String, FileUpload)),
    decoder: Decoder(a),
    authenticated: Bool,
  )
}

/// File contents a call sends as a `multipart/form-data` part, such as the
/// `image` of `users.setPhoto`. For ordinary file sharing use
/// `files.getUploadURLExternal` instead, which takes plain bytes.
pub type FileUpload {
  FileUpload(
    /// The name Slack shows for the file, such as `"avatar.png"`.
    filename: String,
    /// The media type, such as `"image/png"`.
    content_type: String,
    contents: BitArray,
  )
}

/// Builds a call. The generated modules use this. Use `raw` for a method
/// slackline has no function for.
@internal
pub fn call(
  method: String,
  params: List(#(String, String)),
  decoder: Decoder(a),
) -> Call(method, a) {
  Call(method:, params:, files: [], decoder:, authenticated: True)
}

@internal
pub fn without_token(call: Call(m, a)) -> Call(m, a) {
  Call(..call, authenticated: False)
}

/// The method type of calls built with `raw`.
pub type Raw

/// Calls any Web API method, returning its whole response as json.
pub fn raw(
  method: String,
  params: List(#(String, String)),
) -> Call(Raw, Value) {
  call(method, params, value.decoder())
}

/// The Web API method a call will invoke, such as `"chat.postMessage"`.
pub fn method(call: Call(m, a)) -> String {
  call.method
}

/// The form-encoded arguments a call will send.
pub fn params(call: Call(m, a)) -> List(#(String, String)) {
  call.params
}

/// Adds or replaces an argument, such as one the docs do not list yet or
/// `team_id` on an org-wide app.
pub fn with_param(call: Call(m, a), key: String, value: String) -> Call(m, a) {
  Call(..call, params: list.key_set(call.params, key, value))
}

/// Adds or replaces a file argument. A call with files is sent as
/// `multipart/form-data` instead of a urlencoded form.
pub fn with_file(
  call: Call(m, a),
  key: String,
  file: FileUpload,
) -> Call(m, a) {
  Call(..call, files: list.key_set(call.files, key, file))
}

/// The file arguments a call will send.
pub fn files(call: Call(m, a)) -> List(#(String, FileUpload)) {
  call.files
}

/// Transforms the decoded response.
pub fn map(call: Call(m, a), with transform: fn(a) -> b) -> Call(m, b) {
  Call(..call, decoder: decode.map(call.decoder, transform))
}

/// Replaces the response decoder.
pub fn decode_with(call: Call(m, a), decoder: Decoder(b)) -> Call(m, b) {
  Call(
    method: call.method,
    params: call.params,
    files: call.files,
    decoder:,
    authenticated: call.authenticated,
  )
}

fn body(call: Call(m, a)) -> #(String, BitArray) {
  case call.files {
    [] -> #(
      "application/x-www-form-urlencoded",
      bit_array.from_string(uri.query_to_string(call.params)),
    )
    files -> {
      let form =
        list.fold(call.params, form.new(), fn(form, param) {
          form.add_field(form, name: param.0, value: param.1)
        })
      list.fold(files, form, fn(form, entry) {
        let #(name, FileUpload(filename:, content_type:, contents:)) = entry
        form.add_file(form, name:, filename:, content_type:, body: contents)
      })
      |> multipartkit.encode_form
    }
  }
}

/// Everything that can go wrong calling the Web API.
pub type Error {
  /// Slack answered with `"ok": false`. `error` is the error code, such as
  /// `"channel_not_found"`. `response` is the whole body, which can carry
  /// details such as the `needed` and `provided` scopes.
  ApiError(error: String, response: Value)
  /// Slack is rate limiting this method. Wait `retry_after` seconds.
  RateLimited(retry_after: Int)
  /// The response was not the json Slack normally sends.
  UnexpectedResponse(status: Int, body: String)
  /// The response was `ok` but did not match slackline's types. `raw` holds
  /// the data. Report the mismatch as a bug.
  DecodeError(errors: List(decode.DecodeError), raw: Value)
  /// The HTTP client failed before getting a response.
  TransportError(reason: String)
}

/// The HTTP request for a call. Calls without files are a urlencoded form;
/// calls with files are `multipart/form-data`.
pub fn request(call: Call(m, a), client: Client) -> Request(BitArray) {
  let assert Ok(base) =
    request.from_uri(
      uri.Uri(..client.base, path: client.base.path <> call.method),
    )
  let #(content_type, body) = body(call)
  let base =
    base
    |> request.set_method(http.Post)
    |> request.set_header("content-type", content_type)
    |> request.set_body(body)
  let base =
    list.fold(list.reverse(client.headers), base, fn(acc, header) {
      request.set_header(acc, header.0, header.1)
    })
  case client.token, call.authenticated {
    Some(token), True ->
      request.set_header(base, "authorization", "Bearer " <> token)
    _, _ -> base
  }
}

/// Decodes the HTTP response for a call.
pub fn response(
  call: Call(m, a),
  response: Response(String),
) -> Result(a, Error) {
  use <- rate_limited(response)
  case json.parse(response.body, value.decoder()) {
    Error(_) -> Error(UnexpectedResponse(response.status, response.body))
    Ok(body) -> decode_body(call, response, body)
  }
}

fn rate_limited(
  response: Response(String),
  otherwise: fn() -> Result(a, Error),
) -> Result(a, Error) {
  case response.status {
    429 -> {
      let retry_after =
        response.get_header(response, "retry-after")
        |> result.try(int.parse)
        |> result.unwrap(1)
      Error(RateLimited(retry_after))
    }
    _ -> otherwise()
  }
}

fn decode_body(
  call: Call(m, a),
  response: Response(String),
  body: Value,
) -> Result(a, Error) {
  case value.field(body, "ok") {
    Ok(value.Bool(True)) ->
      value.decode(body, call.decoder)
      |> result.map_error(DecodeError(_, body))
    Ok(value.Bool(False)) ->
      Error(ApiError(
        value.string_field(body, "error") |> result.unwrap("unknown_error"),
        body,
      ))
    _ -> Error(UnexpectedResponse(response.status, response.body))
  }
}

/// Pagination and warning details Slack attaches to many responses.
pub type ResponseMetadata {
  ResponseMetadata(
    /// Pass this as `cursor` to fetch the next page. Empty on the last page.
    next_cursor: Option(String),
    /// Warning codes, such as `missing_charset`.
    warnings: Option(List(String)),
    /// Human-readable details about warnings or errors.
    messages: Option(List(String)),
  )
}

/// Decodes `ResponseMetadata` from json.
pub fn response_metadata_decoder() -> Decoder(ResponseMetadata) {
  let strings = decode.optional(decode.list(decode.string))
  use next_cursor <- decode.optional_field(
    "next_cursor",
    None,
    decode.optional(decode.string),
  )
  use warnings <- decode.optional_field("warnings", None, strings)
  use messages <- decode.optional_field("messages", None, strings)
  decode.success(ResponseMetadata(next_cursor:, warnings:, messages:))
}

/// Encodes `ResponseMetadata` as json.
pub fn response_metadata_to_json(metadata: ResponseMetadata) -> json.Json {
  let strings = fn(key, value) {
    option.map(value, fn(value) { #(key, json.array(value, json.string)) })
  }
  [
    option.map(metadata.next_cursor, fn(cursor) {
      #("next_cursor", json.string(cursor))
    }),
    strings("warnings", metadata.warnings),
    strings("messages", metadata.messages),
  ]
  |> option.values
  |> json.object
}

/// The call for the next page, or `None` after the last page. Pass the
/// `response_metadata` from the response to `call`. The next call is the same
/// call with `cursor` set to `next_cursor`.
pub fn next_page(
  call: Call(m, a),
  metadata: Option(ResponseMetadata),
) -> Option(Call(m, a)) {
  case metadata {
    Some(ResponseMetadata(next_cursor: Some(cursor), ..)) if cursor != "" ->
      Some(with_param(call, "cursor", cursor))
    _ -> None
  }
}

/// Describes an error for logs.
pub fn describe_error(error: Error) -> String {
  case error {
    ApiError(error:, ..) -> "slack api error: " <> error
    RateLimited(retry_after) ->
      "rate limited, retry after " <> int.to_string(retry_after) <> "s"
    UnexpectedResponse(status, body) ->
      "unexpected response (" <> int.to_string(status) <> "): " <> body
    DecodeError(errors, ..) ->
      "could not decode response: " <> string.inspect(errors)
    TransportError(reason) -> "http error: " <> reason
  }
}

@internal
pub fn transport_error(error: e) -> Error {
  TransportError(string.inspect(error))
}

/// The request for step two of Slack's file upload flow. It posts the raw
/// bytes to the `upload_url` from `files.getUploadURLExternal`. Step three
/// is `files.completeUploadExternal`.
/// See <https://docs.slack.dev/messaging/working-with-files>.
pub fn upload_request(
  upload_url: String,
  contents: BitArray,
) -> Result(Request(BitArray), Nil) {
  use base <- result.map(request.to(upload_url))
  base
  |> request.set_method(http.Post)
  |> request.set_header("content-type", "application/octet-stream")
  |> request.set_body(contents)
}

/// Checks the response to an `upload_request`. Slack answers `200` and a
/// short text body such as `OK - 12`.
pub fn upload_response(response: Response(String)) -> Result(Nil, Error) {
  use <- rate_limited(response)
  case response.status {
    200 -> Ok(Nil)
    status -> Error(UnexpectedResponse(status, response.body))
  }
}

/// The request that posts a message to an incoming webhook or to a
/// `response_url` from a slash command or interaction. Build the body with
/// `interaction.response_message_to_json`, or send any json to an incoming
/// webhook. See <https://docs.slack.dev/messaging/sending-messages-using-incoming-webhooks>.
pub fn webhook_request(
  url: String,
  body: json.Json,
) -> Result(Request(String), Nil) {
  use base <- result.map(request.to(url))
  base
  |> request.set_method(http.Post)
  |> request.set_header("content-type", "application/json; charset=utf-8")
  |> request.set_body(json.to_string(body))
}

/// Checks the response to a `webhook_request`. On success, webhooks answer
/// `200` and the text `ok`. On failure, they answer with a status code and an
/// error code such as `invalid_payload` as plain text.
pub fn webhook_response(response: Response(String)) -> Result(Nil, Error) {
  use <- rate_limited(response)
  case response.status {
    200 -> Ok(Nil)
    _ ->
      case string.trim(response.body) {
        "" -> Error(UnexpectedResponse(response.status, response.body))
        code -> Error(ApiError(code, value.String(response.body)))
      }
  }
}
