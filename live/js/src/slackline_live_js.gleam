//// Runs slackline's `fetch` client on the JavaScript target against a real
//// workspace: one read, a paged fold, a post, a file upload and an
//// incoming webhook.
////
//// ```sh
//// cd live/js
//// gleam run -- C0123456789
//// ```
////
//// It reads the tokens and webhook url that `slackline_live` saved.

import gleam/bit_array
import gleam/dynamic/decode
import gleam/int
import gleam/io
import gleam/javascript/promise.{type Promise}
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import slackline
import slackline/api/auth
import slackline/api/chat
import slackline/api/conversations
import slackline/api/conversations/list as conversations_list
import slackline/api/files
import slackline/api/files/complete_upload_external
import slackline/api/users
import slackline/api/users/list as users_list
import slackline/fetch
import slackline/interaction

pub fn main() -> Promise(Nil) {
  let assert Ok(text) = read_state("tokens.json")
  let assert Ok(bot) =
    json.parse(text, {
      use bot <- decode.field("bot", decode.string)
      decode.success(bot)
    })
  let assert [channel, ..] = arguments()
  let client = slackline.new(bot)

  use _ <- promise.await(
    auth.test_() |> fetch.send(client) |> show("auth.test"),
  )
  use pages <- promise.await(
    users.list()
    |> users_list.limit(60)
    |> fetch.fold_pages(
      client,
      from: #(0, 0),
      with: fn(acc, page) {
        #(acc.0 + 1, acc.1 + list.length(option.unwrap(page.members, [])))
      },
      metadata: fn(page) { page.response_metadata },
    ),
  )
  case pages {
    Ok(#(pages, members)) ->
      io.println(
        "ok       users.list folded "
        <> int.to_string(members)
        <> " members over "
        <> int.to_string(pages)
        <> " pages",
      )
    Error(slackline.RateLimited(retry_after:)) ->
      io.println(
        "limited  users.list (retry after "
        <> int.to_string(retry_after)
        <> "s)",
      )
    Error(error) -> io.println("BROKEN   users.list " <> string.inspect(error))
  }
  use _ <- promise.await(
    conversations.list()
    |> conversations_list.limit(5)
    |> fetch.send(client)
    |> show("conversations.list"),
  )
  use posted <- promise.await(
    chat.post_message(channel:, text: "posted from the JavaScript target")
    |> fetch.send(client)
    |> show("chat.postMessage"),
  )
  use _ <- promise.await(case posted {
    Ok(posted) ->
      chat.delete(channel:, ts: posted.ts)
      |> fetch.send(client)
      |> show("chat.delete")
      |> promise.map(fn(_) { Nil })
    Error(_) -> promise.resolve(Nil)
  })
  use _ <- promise.await(upload(client, channel))
  case read_state("webhook") {
    Ok(url) ->
      fetch.webhook(
        string.trim(url),
        interaction.response_message_to_json(
          interaction.ResponseMessage(
            ..interaction.response_message(),
            text: Some("incoming webhook from the JavaScript target"),
          ),
        ),
      )
      |> show("incoming webhook")
      |> promise.map(fn(_) { Nil })
    Error(Nil) -> promise.resolve(io.println("no webhook saved"))
  }
}

fn upload(client: slackline.Client, channel: String) -> Promise(Nil) {
  let contents = bit_array.from_string("uploaded with fetch\n")
  use target <- promise.await(
    files.get_upload_url_external(
      length: bit_array.byte_size(contents),
      filename: "fetch.txt",
    )
    |> fetch.send(client)
    |> show("files.getUploadURLExternal"),
  )
  case target {
    Error(_) -> promise.resolve(Nil)
    Ok(target) -> {
      use _ <- promise.await(
        fetch.upload(target.upload_url, contents) |> show("upload"),
      )
      use _ <- promise.await(
        files.complete_upload_external(files: [
          files.UploadedFile(id: target.file_id, title: None),
        ])
        |> complete_upload_external.channel_id(channel)
        |> fetch.send(client)
        |> show("files.completeUploadExternal"),
      )
      files.delete(file: target.file_id)
      |> fetch.send(client)
      |> show("files.delete")
      |> promise.map(fn(_) { Nil })
    }
  }
}

fn show(
  result: Promise(Result(a, slackline.Error)),
  label: String,
) -> Promise(Result(a, slackline.Error)) {
  use result <- promise.map(result)
  case result {
    Ok(_) -> io.println("ok       " <> label)
    Error(slackline.ApiError(error:, ..)) ->
      io.println("refused  " <> label <> " (" <> error <> ")")
    Error(error) ->
      io.println("BROKEN   " <> label <> " " <> string.inspect(error))
  }
  result
}

@external(javascript, "./slackline_live_js_ffi.mjs", "read_state")
fn read_state(name: String) -> Result(String, Nil)

@external(javascript, "./slackline_live_js_ffi.mjs", "argv")
fn arguments() -> List(String)
