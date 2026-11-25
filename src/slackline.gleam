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
import gleam/crypto
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
import slackline/internal/multipart
import slackline/value.{type Value}

/// The default Web API base url.
pub const slack_api_url = "https://slack.com/api/"

/// The Web API base url for GovSlack workspaces.
pub const gov_slack_api_url = "https://slack-gov.com/api/"

/// The token to call the Web API with, and where to send calls.
pub opaque type Client {
  Client(
    token: Option(String),
    base: uri.Uri,
    headers: List(#(String, String)),
    /// Where calls to Slack's other HTTP APIs go instead of their own hosts.
    other_apis: Option(uri.Uri),
  )
}

fn client(token: Option(String)) -> Client {
  let assert Ok(base) = uri.parse(slack_api_url)
  Client(token:, base:, headers: [], other_apis: None)
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

/// Sends calls to Slack's other HTTP APIs (SCIM, Audit Logs, Status) to this
/// scheme and host instead, keeping their paths, such as for a local mock
/// server.
pub fn with_other_apis_url(client: Client, url: String) -> Result(Client, Nil) {
  use base <- result.try(uri.parse(url))
  case base.scheme, base.host {
    Some("https"), Some(_) | Some("http"), Some(_) ->
      Ok(Client(..client, other_apis: Some(base)))
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
    endpoint: Endpoint,
  )
}

/// Where a call goes and how it answers.
type Endpoint {
  /// A Web API method, answering a json object with `"ok"`.
  WebApi
  /// A Web API method answering a gzip file with one json value per line,
  /// such as `admin.analytics.getFile`. The decoder sees a list of the lines.
  WebApiJsonLines
  /// Another Slack HTTP API, such as SCIM. Arguments go in the query string,
  /// `json` is the body, and the answer is plain json: no `"ok"`, errors as
  /// an HTTP status.
  Rest(verb: http.Method, url: uri.Uri, json: Option(String))
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
  Call(
    method:,
    params:,
    files: [],
    decoder:,
    authenticated: True,
    endpoint: WebApi,
  )
}

/// The same call, for code that sends different methods alike.
@internal
pub fn erase(call: Call(m, a)) -> Call(Nil, a) {
  Call(
    method: call.method,
    params: call.params,
    files: call.files,
    decoder: call.decoder,
    authenticated: call.authenticated,
    endpoint: call.endpoint,
  )
}

@internal
pub fn without_token(call: Call(m, a)) -> Call(m, a) {
  Call(..call, authenticated: False)
}

/// Marks a method that answers with a gzip file of json lines. The decoder
/// receives the list of lines.
@internal
pub fn json_lines(call: Call(m, a)) -> Call(m, a) {
  Call(..call, endpoint: WebApiJsonLines)
}

/// Builds a call to another Slack HTTP API, such as SCIM or Audit Logs. The
/// API modules use this.
@internal
pub fn rest(
  verb: http.Method,
  url: String,
  json_body: Option(json.Json),
  decoder: Decoder(a),
) -> Call(method, a) {
  let assert Ok(parsed) = uri.parse(url)
  Call(
    method: http.method_to_string(verb) |> string.uppercase
      <> " "
      <> parsed.path,
    params: [],
    files: [],
    decoder:,
    authenticated: True,
    endpoint: Rest(
      verb:,
      url: parsed,
      json: option.map(json_body, json.to_string),
    ),
  )
}

/// The gzip body a client has to decompress before `response_bits`, if this
/// call answers with a gzip file and the body is one.
@internal
pub fn gzip_body(
  call: Call(m, a),
  response: Response(BitArray),
) -> Result(BitArray, Nil) {
  case call.endpoint, response.body {
    WebApiJsonLines, <<0x1f, 0x8b, _:bits>> -> Ok(response.body)
    _, _ -> Error(Nil)
  }
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

/// Adds or replaces a file argument. A Web API call with files is sent as
/// `multipart/form-data` instead of a urlencoded form. Calls to Slack's other
/// APIs send json and ignore files.
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
    endpoint: call.endpoint,
  )
}

fn body(call: Call(m, a)) -> #(String, BitArray) {
  case call.files {
    [] -> #(
      "application/x-www-form-urlencoded",
      bit_array.from_string(uri.query_to_string(call.params)),
    )
    files -> {
      let boundary =
        "slackline-" <> bit_array.base16_encode(crypto.strong_random_bytes(16))
      let fields =
        list.map(call.params, fn(param) { multipart.Field(param.0, param.1) })
      let files =
        list.map(files, fn(entry) {
          let #(name, FileUpload(filename:, content_type:, contents:)) = entry
          multipart.File(name:, filename:, content_type:, body: contents)
        })
      #(
        "multipart/form-data; boundary=" <> boundary,
        multipart.encode(boundary, list.append(fields, files)),
      )
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

/// The HTTP request for a call. Web API calls without files are a
/// urlencoded form; calls with files are `multipart/form-data`.
pub fn request(call: Call(m, a), client: Client) -> Request(BitArray) {
  let base = case call.endpoint {
    Rest(verb:, url:, json:) ->
      rest_request(verb, rehost(url, client.other_apis), json, call.params)
    WebApi | WebApiJsonLines -> {
      let assert Ok(base) =
        request.from_uri(
          uri.Uri(..client.base, path: client.base.path <> call.method),
        )
      let #(content_type, body) = body(call)
      base
      |> request.set_method(http.Post)
      |> request.set_header("content-type", content_type)
      |> request.set_body(body)
    }
  }
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

fn rehost(url: uri.Uri, other_apis: Option(uri.Uri)) -> uri.Uri {
  case other_apis {
    Some(base) ->
      uri.Uri(..url, scheme: base.scheme, host: base.host, port: base.port)
    None -> url
  }
}

fn rest_request(
  verb: http.Method,
  url: uri.Uri,
  json: Option(String),
  params: List(#(String, String)),
) -> Request(BitArray) {
  let assert Ok(base) = request.from_uri(url)
  let base =
    base
    |> request.set_method(verb)
    |> request.set_query(params)
    |> request.set_body(<<>>)
  case json {
    None -> base
    Some(json) ->
      base
      |> request.set_header("content-type", "application/json")
      |> request.set_body(bit_array.from_string(json))
  }
}

/// Decodes the HTTP response for a call.
pub fn response(
  call: Call(m, a),
  response: Response(String),
) -> Result(a, Error) {
  use <- rate_limited(response)
  case call.endpoint {
    Rest(..) -> decode_rest(call, response)
    WebApi | WebApiJsonLines -> decode_web_api(call, response)
  }
}

/// Every Web API answer that carries `ok` is the json envelope, even for a
/// call that otherwise answers with json lines.
fn decode_web_api(
  call: Call(m, a),
  response: Response(String),
) -> Result(a, Error) {
  let envelope =
    json.parse(response.body, value.decoder())
    |> result.replace_error(Nil)
    |> result.try(fn(body) { value.field(body, "ok") |> result.replace(body) })
  case envelope, call.endpoint {
    Ok(body), _ -> decode_body(call, response, body)
    Error(Nil), WebApiJsonLines ->
      decode_lines(call, response.status, response.body)
    Error(Nil), _ -> Error(UnexpectedResponse(response.status, response.body))
  }
}

/// A plain json answer. Success is any 2xx status; an empty body, as for a
/// `204`, decodes as `null`. Errors carry a code as `error`, or as SCIM's
/// `Errors.description`.
fn decode_rest(
  call: Call(m, a),
  response: Response(String),
) -> Result(a, Error) {
  let body = case response.body {
    "" -> Ok(value.Null)
    text -> json.parse(text, value.decoder()) |> result.replace_error(Nil)
  }
  case response.status >= 200 && response.status < 300, body {
    True, Ok(body) ->
      value.decode(body, call.decoder) |> result.map_error(DecodeError(_, body))
    False, Ok(body) ->
      case rest_error_code(body) {
        Ok(code) -> Error(ApiError(code, body))
        Error(Nil) -> Error(UnexpectedResponse(response.status, response.body))
      }
    _, Error(Nil) -> Error(UnexpectedResponse(response.status, response.body))
  }
}

fn rest_error_code(body: Value) -> Result(String, Nil) {
  case value.string_field(body, "error") {
    Ok(code) -> Ok(code)
    Error(Nil) ->
      value.field(body, "Errors")
      |> result.try(value.string_field(_, "description"))
  }
}

/// Decodes an HTTP response with a binary body, already decompressed.
@internal
pub fn response_bits(
  call: Call(m, a),
  bits: Response(BitArray),
) -> Result(a, Error) {
  case bit_array.to_string(bits.body) {
    Ok(text) -> response(call, response.set_body(bits, text))
    Error(Nil) -> {
      use <- rate_limited(bits)
      Error(UnexpectedResponse(bits.status, "a body that is not UTF-8"))
    }
  }
}

fn decode_lines(
  call: Call(m, a),
  status: Int,
  text: String,
) -> Result(a, Error) {
  let lines =
    text
    |> string.split("\n")
    |> list.map(string.trim)
    |> list.filter(fn(line) { line != "" })
    |> list.try_map(json.parse(_, value.decoder()))
  case status, lines {
    200, Ok(lines) -> {
      let rows = value.Array(lines)
      value.decode(rows, call.decoder) |> result.map_error(DecodeError(_, rows))
    }
    _, _ -> Error(UnexpectedResponse(status, text))
  }
}

fn rate_limited(
  response: Response(b),
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

/// How long to wait, in milliseconds, before trying a failed call again:
/// Slack's `Retry-After` for rate limits, and a doubling backoff from one
/// second (at most thirty) for server errors and failed connections. `tries`
/// is how many attempts have failed so far. Other errors are not retried.
@internal
pub fn retry_delay(error: Error, tries: Int) -> Result(Int, Nil) {
  case error {
    RateLimited(retry_after:) -> Ok(retry_after * 1000)
    UnexpectedResponse(status:, ..) if status >= 500 -> Ok(backoff(tries))
    TransportError(_) -> Ok(backoff(tries))
    _ -> Error(Nil)
  }
}

fn backoff(tries: Int) -> Int {
  int.min(30_000, 1000 * int.bitwise_shift_left(1, int.max(tries - 1, 0)))
}

/// Describes an error for logs.
pub fn describe_error(error: Error) -> String {
  case error {
    ApiError(error:, response:) ->
      "slack api error: " <> error <> api_error_details(response)
    RateLimited(retry_after) ->
      "rate limited, retry after " <> int.to_string(retry_after) <> "s"
    UnexpectedResponse(status, body) ->
      "unexpected response (" <> int.to_string(status) <> "): " <> body
    DecodeError(errors, ..) ->
      "could not decode response: " <> string.inspect(errors)
    TransportError(reason) -> "http error: " <> reason
  }
}

/// Slack's explanation of a vague error code, such as ` (needed: chat:write)`.
fn api_error_details(response: Value) -> String {
  let messages =
    value.decode(
      response,
      decode.at(["response_metadata", "messages"], decode.list(decode.string)),
    )
    |> result.unwrap([])
  let needed = case value.string_field(response, "needed") {
    Ok(scope) -> ["needed: " <> scope]
    Error(Nil) -> []
  }
  case list.append(messages, needed) {
    [] -> ""
    details -> " (" <> string.join(details, "; ") <> ")"
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
