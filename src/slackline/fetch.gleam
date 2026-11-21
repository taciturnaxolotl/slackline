//// Send Web API calls with [`gleam_fetch`](https://hexdocs.pm/gleam_fetch)
//// on the JavaScript target.
////
//// ```gleam
//// let client = slackline.new(token)
//// auth.test_()
//// |> fetch.send(client)
//// |> promise.map(fn(result) { ... })
//// ```

import gleam/bit_array
import gleam/fetch
import gleam/http/response.{type Response}
import gleam/javascript/promise.{type Promise}
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import slackline.{type Call, type Client, type Error, type ResponseMetadata}
import slackline/api/files

/// Sends a call and decodes its response.
@external(erlang, "slackline_ffi", "javascript_only")
pub fn send(call: Call(m, a), client: Client) -> Promise(Result(a, Error)) {
  use result <- promise.await(
    slackline.request(call, client)
    |> fetch.send_bits
    |> promise.try_await(fetch.read_bytes_body),
  )
  case result {
    Error(error) -> promise.resolve(Error(slackline.transport_error(error)))
    Ok(response) ->
      unpack(call, response)
      |> promise.map(result.try(_, slackline.response_bits(call, _)))
  }
}

/// Decompresses the body of calls that answer with a gzip file, with the
/// runtime's `DecompressionStream`.
@external(erlang, "slackline_ffi", "javascript_only")
fn unpack(
  call: Call(m, a),
  response: Response(BitArray),
) -> Promise(Result(Response(BitArray), Error)) {
  case slackline.gzip_body(call, response) {
    Error(Nil) -> promise.resolve(Ok(response))
    Ok(gz) ->
      gunzip(gz)
      |> promise.map(fn(result) {
        result
        |> result.map(response.set_body(response, _))
        |> result.replace_error(slackline.UnexpectedResponse(
          response.status,
          "a gzip body that could not be decompressed",
        ))
      })
  }
}

@external(erlang, "slackline_ffi", "javascript_only")
@external(javascript, "../slackline_ffi.mjs", "gunzip")
fn gunzip(data: BitArray) -> Promise(Result(BitArray, Nil))

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

/// Runs `run` again when it fails with a rate limit, a 5xx response or a
/// failed connection, and returns the last result after `attempts` tries in
/// total. Rate limits wait the `retry_after` Slack asks for; the others back
/// off from one second, doubling. Other errors return at once. A retried
/// write can happen twice if Slack applied it before failing, as with a
/// timeout after `chat.postMessage` was accepted.
///
/// ```gleam
/// use <- fetch.retrying(attempts: 3)
/// chat.post_message(channel:, text: "hi") |> fetch.send(client)
/// ```
@external(erlang, "slackline_ffi", "javascript_only")
pub fn retrying(
  attempts attempts: Int,
  run run: fn() -> Promise(Result(a, Error)),
) -> Promise(Result(a, Error)) {
  retry_loop(attempts, 1, run)
}

@external(erlang, "slackline_ffi", "javascript_only")
fn retry_loop(
  attempts: Int,
  tries: Int,
  run: fn() -> Promise(Result(a, Error)),
) -> Promise(Result(a, Error)) {
  use result <- promise.await(run())
  case result {
    Error(error) if tries < attempts ->
      case slackline.retry_delay(error, tries) {
        Ok(delay) -> {
          use Nil <- promise.await(promise.wait(delay))
          retry_loop(attempts, tries + 1, run)
        }
        Error(Nil) -> promise.resolve(result)
      }
    _ -> promise.resolve(result)
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

/// Uploads files and shares them in one message: the three steps of
/// `files.getUploadURLExternal`, `upload` and `files.completeUploadExternal`.
/// `share` adjusts the last call, for example to set the channel with
/// `complete_upload_external.channel_id`. Without a channel the files are
/// uploaded but not shared. Each file's `content_type` is not sent; Slack
/// detects the type. Run the three steps yourself for `alt_txt`,
/// `snippet_type`, or to retry only the upload.
@external(erlang, "slackline_ffi", "javascript_only")
pub fn upload_files(
  client: Client,
  uploads: List(slackline.FileUpload),
  share share: fn(
    Call(files.CompleteUploadExternal, files.CompleteUploadExternalResponse),
  ) -> Call(files.CompleteUploadExternal, files.CompleteUploadExternalResponse),
) -> Promise(Result(files.CompleteUploadExternalResponse, Error)) {
  use uploaded <- promise.try_await(upload_each(client, uploads, []))
  files.complete_upload_external(files: uploaded)
  |> share
  |> send(client)
}

@external(erlang, "slackline_ffi", "javascript_only")
fn upload_each(
  client: Client,
  uploads: List(slackline.FileUpload),
  done: List(files.UploadedFile),
) -> Promise(Result(List(files.UploadedFile), Error)) {
  case uploads {
    [] -> promise.resolve(Ok(list.reverse(done)))
    [slackline.FileUpload(filename:, contents:, ..), ..rest] -> {
      use target <- promise.try_await(
        files.get_upload_url_external(
          length: bit_array.byte_size(contents),
          filename:,
        )
        |> send(client),
      )
      use Nil <- promise.try_await(upload(target.upload_url, contents))
      upload_each(client, rest, [
        files.UploadedFile(id: target.file_id, title: Some(filename)),
        ..done
      ])
    }
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
