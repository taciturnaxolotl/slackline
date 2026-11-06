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
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import slackline.{type Call, type Client, type Error, type ResponseMetadata}
import slackline/api/files

/// Sends a call and decodes its response.
@external(javascript, "../slackline_ffi.mjs", "erlang_only")
pub fn send(call: Call(m, a), client: Client) -> Result(a, Error) {
  use response <- result.try(
    slackline.request(call, client)
    |> httpc.send_bits
    |> result.map_error(slackline.transport_error),
  )
  use response <- result.try(text(response))
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
    |> httpc.dispatch_bits(config, _)
    |> result.map_error(slackline.transport_error),
  )
  use response <- result.try(text(response))
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

/// Uploads files and shares them in one message: the three steps of
/// `files.getUploadURLExternal`, `upload` and `files.completeUploadExternal`.
/// `share` adjusts the last call, for example to set the channel:
///
/// ```gleam
/// httpc.upload_files(client, [report], share: fn(call) {
///   call
///   |> complete_upload_external.channel_id(channel)
///   |> complete_upload_external.initial_comment("this week's report")
/// })
/// ```
///
/// Without a channel the files are uploaded but not shared. Each file's
/// `content_type` is not sent; Slack detects the type. Run the three steps
/// yourself for `alt_txt`, `snippet_type`, or to retry only the upload.
@external(javascript, "../slackline_ffi.mjs", "erlang_only")
pub fn upload_files(
  client: Client,
  uploads: List(slackline.FileUpload),
  share share: fn(
    Call(files.CompleteUploadExternal, files.CompleteUploadExternalResponse),
  ) -> Call(files.CompleteUploadExternal, files.CompleteUploadExternalResponse),
) -> Result(files.CompleteUploadExternalResponse, Error) {
  use uploaded <- result.try(
    list.try_map(uploads, fn(file) {
      let slackline.FileUpload(filename:, contents:, ..) = file
      use target <- result.try(
        files.get_upload_url_external(
          length: bit_array.byte_size(contents),
          filename:,
        )
        |> send(client),
      )
      use Nil <- result.map(upload(target.upload_url, contents))
      files.UploadedFile(id: target.file_id, title: Some(filename))
    }),
  )
  files.complete_upload_external(files: uploaded)
  |> share
  |> send(client)
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

/// Slack answers Web API calls with json, so a body that is not UTF-8 is
/// unexpected.
fn text(
  response: response.Response(BitArray),
) -> Result(response.Response(String), Error) {
  case bit_array.to_string(response.body) {
    Ok(body) -> Ok(response.set_body(response, body))
    Error(Nil) ->
      Error(slackline.UnexpectedResponse(
        status: response.status,
        body: "a body that is not UTF-8",
      ))
  }
}
