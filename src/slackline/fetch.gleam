//// Send Web API calls with [`gleam_fetch`](https://hexdocs.pm/gleam_fetch)
//// on the JavaScript target.
////
//// ```gleam
//// let client = slackline.new(token)
//// auth.test_()
//// |> fetch.send(client)
//// |> promise.map(fn(result) { ... })
//// ```

import gleam/fetch
import gleam/javascript/promise.{type Promise}
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/result
import slackline.{type Call, type Client, type Error, type ResponseMetadata}

/// Sends a call and decodes its response.
@external(erlang, "slackline_ffi", "javascript_only")
pub fn send(call: Call(m, a), client: Client) -> Promise(Result(a, Error)) {
  slackline.request(call, client)
  |> fetch.send
  |> promise.try_await(fetch.read_text_body)
  |> promise.map(fn(result) {
    result
    |> result.map_error(slackline.transport_error)
    |> result.try(slackline.response(call, _))
  })
}

/// Sends a call and every following page, folding each response into an
/// accumulator. `metadata` finds a response's `response_metadata`, which
/// holds the cursor of the next page. Stops at the first error.
@external(erlang, "slackline_ffi", "javascript_only")
pub fn fold_pages(
  call: Call(m, a),
  client: Client,
  from initial: b,
  with fold: fn(b, a) -> b,
  metadata metadata: fn(a) -> Option(ResponseMetadata),
) -> Promise(Result(b, Error)) {
  use result <- promise.await(send(call, client))
  case result {
    Error(error) -> promise.resolve(Error(error))
    Ok(page) -> {
      let acc = fold(initial, page)
      case slackline.next_page(call, metadata(page)) {
        Some(next) -> fold_pages(next, client, acc, fold, metadata)
        None -> promise.resolve(Ok(acc))
      }
    }
  }
}

/// Uploads file contents to an `upload_url` from
/// `files.getUploadURLExternal`.
@external(erlang, "slackline_ffi", "javascript_only")
pub fn upload(
  upload_url: String,
  contents: BitArray,
) -> Promise(Result(Nil, Error)) {
  case slackline.upload_request(upload_url, contents) {
    Error(Nil) ->
      promise.resolve(Error(slackline.TransportError("invalid upload url")))
    Ok(request) ->
      fetch.send_bits(request)
      |> promise.try_await(fetch.read_text_body)
      |> promise.map(fn(result) {
        result
        |> result.map_error(slackline.transport_error)
        |> result.try(slackline.upload_response)
      })
  }
}

/// Posts a message to an incoming webhook or `response_url`.
@external(erlang, "slackline_ffi", "javascript_only")
pub fn webhook(url: String, body: json.Json) -> Promise(Result(Nil, Error)) {
  case slackline.webhook_request(url, body) {
    Error(Nil) ->
      promise.resolve(Error(slackline.TransportError("invalid webhook url")))
    Ok(request) ->
      fetch.send(request)
      |> promise.try_await(fetch.read_text_body)
      |> promise.map(fn(result) {
        result
        |> result.map_error(slackline.transport_error)
        |> result.try(slackline.webhook_response)
      })
  }
}
