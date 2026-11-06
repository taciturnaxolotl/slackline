//// Send Web API calls with [`gleam_httpc`](https://hexdocs.pm/gleam_httpc)
//// on the Erlang target.
////
//// ```gleam
//// let client = slackline.new(token)
//// auth.test_() |> httpc.send(client)
//// ```

import gleam/bit_array
import gleam/http/response
import gleam/httpc
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/result
import slackline.{type Call, type Client, type Error, type ResponseMetadata}

/// Sends a call and decodes its response.
@external(javascript, "../slackline_ffi.mjs", "erlang_only")
pub fn send(call: Call(m, a), client: Client) -> Result(a, Error) {
  use response <- result.try(
    slackline.request(call, client)
    |> httpc.send
    |> result.map_error(slackline.transport_error),
  )
  slackline.response(call, response)
}

/// Sends a call with a custom `httpc` configuration, such as a longer
/// timeout.
@external(javascript, "../slackline_ffi.mjs", "erlang_only")
pub fn send_with(
  call: Call(m, a),
  client: Client,
  config: httpc.Configuration,
) -> Result(a, Error) {
  use response <- result.try(
    slackline.request(call, client)
    |> httpc.dispatch(config, _)
    |> result.map_error(slackline.transport_error),
  )
  slackline.response(call, response)
}

/// Sends a call and every following page, folding each response into an
/// accumulator. `metadata` finds a response's `response_metadata`, which
/// holds the cursor of the next page. Stops at the first error.
///
/// ```gleam
/// conversations.list()
/// |> httpc.fold_pages(
///   client,
///   from: [],
///   with: fn(channels, page) { list.append(channels, option.unwrap(page.channels, [])) },
///   metadata: fn(page) { page.response_metadata },
/// )
/// ```
@external(javascript, "../slackline_ffi.mjs", "erlang_only")
pub fn fold_pages(
  call: Call(m, a),
  client: Client,
  from initial: b,
  with fold: fn(b, a) -> b,
  metadata metadata: fn(a) -> Option(ResponseMetadata),
) -> Result(b, Error) {
  use page <- result.try(send(call, client))
  let acc = fold(initial, page)
  case slackline.next_page(call, metadata(page)) {
    Some(next) -> fold_pages(next, client, acc, fold, metadata)
    None -> Ok(acc)
  }
}

/// Uploads file contents to an `upload_url` from
/// `files.getUploadURLExternal`.
@external(javascript, "../slackline_ffi.mjs", "erlang_only")
pub fn upload(upload_url: String, contents: BitArray) -> Result(Nil, Error) {
  use request <- result.try(
    slackline.upload_request(upload_url, contents)
    |> result.replace_error(slackline.TransportError("invalid upload url")),
  )
  use response <- result.try(
    httpc.send_bits(request)
    |> result.map_error(slackline.transport_error),
  )
  let body = bit_array.to_string(response.body) |> result.unwrap("")
  slackline.upload_response(response.set_body(response, body))
}

/// Posts a message to an incoming webhook or `response_url`.
@external(javascript, "../slackline_ffi.mjs", "erlang_only")
pub fn webhook(url: String, body: json.Json) -> Result(Nil, Error) {
  use request <- result.try(
    slackline.webhook_request(url, body)
    |> result.replace_error(slackline.TransportError("invalid webhook url")),
  )
  use response <- result.try(
    httpc.send(request)
    |> result.map_error(slackline.transport_error),
  )
  slackline.webhook_response(response)
}
