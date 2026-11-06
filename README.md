<p align="center">
    <img src="https://l4.dunkirk.sh/i/Wdwiu5DGBIuc.svg" alt="slackline title graphic" />
</p>

Slackline is a slack api client for gleam that attempts to port most of [slack's api surface](https://docs.slack.dev) similar to projects like [slack-edge](https://github.com/slack-edge/slack-edge). This is still very beta so please do open an issue or send me an email if something isn't working properly! Also if you have opinions about how to make this more idiomatic I would love to hear!

```sh
gleam add slackline
```

## Usage

Every Web API method is a function in `slackline/api/<family>`. It takes the required arguments and gives you a `Call`, which you send with `slackline/httpc` on Erlang or `slackline/fetch` on JavaScript:

```gleam
import slackline
import slackline/api/chat
import slackline/httpc

let client = slackline.new("xoxb-your-token")

chat.post_message(channel: "C123", text: "hello from gleam!")
|> httpc.send(client)
```

Optional arguments live in a module named after the method:

```gleam
import slackline/api/chat/post_message

chat.post_message(channel: "C123", text: "deploy finished")
|> post_message.thread_ts(ts)
|> post_message.unfurl_links(False)
|> httpc.send(client)
```

### Block Kit

Blocks and elements take their required fields and a list of attributes, like Lustre does for HTML. An attribute that does not belong to the block will not compile.

```gleam
import slackline/block
import slackline/block/section
import slackline/element
import slackline/element/button

chat.post_message(channel: "C123", text: "deploy finished")
|> post_message.blocks([
  block.section(block.mrkdwn("*deploy finished* :rocket:"), [
    section.accessory(element.button("Logs", "logs", [button.url(logs_url)])),
  ]),
])
|> httpc.send(client)
```

Modals work the same way:

```gleam
import slackline/block/input
import slackline/view

view.modal(
  "Feedback",
  [
    block.input("Thoughts", element.plain_text_input("thoughts", []), [
      input.block_id("thoughts"),
    ]),
  ],
  [view.callback_id("feedback"), view.submit("Send")],
)
```

### Apps

`slackline/app` routes slash commands, actions, modal submissions and events to your handlers. Slack requires an `ack` within a three second timelimit, so put anything slow goes after `use <- app.ack_then`:

```gleam
import slackline/api/views
import slackline/api/views/open
import slackline/app
import slackline/event

app.new(signing_secret)
|> app.command("/feedback", fn(command) {
  use <- app.ack_then
  views.open(view: feedback_modal())
  |> open.trigger_id(command.trigger_id)
  |> httpc.send(client)
})
|> app.view_submission("feedback", fn(submission) {
  case view.input_text(submission.view, block_id: "thoughts", action_id: "thoughts") {
    Some("") | None -> app.errors([#("thoughts", "say something!")])
    Some(_) -> app.ack()
  }
})
|> app.on_event(fn(event, _delivery) {
  case event {
    event.AppMention(channel:, ..) -> {
      let _ = chat.post_message(channel:, text: "hi!") |> httpc.send(client)
      Nil
    }
    _ -> Nil
  }
})
```

Give `app.handle` the request from your HTTP server with its raw body. Send back `response`, then call `after()`. On Erlang, run it in a new process:

```gleam
let app.Handled(response:, after:) = app.handle(bot, request)
```

### Socket Mode

Call `apps.connections_open()` with an app-level (`xapp-`) token. Connect any WebSocket client to the `url` it returns and then pass text frames back to the app:

```gleam
case app.handle_socket(bot, frame) {
  app.Send(frame: reply, after:) -> {
    send(reply)
    after()
  }
  app.Reconnect(_) -> reconnect()
  app.Ignore -> Nil
}
```

### Pagination

`httpc.fold_pages` returns `next_cursor` for folding:

```gleam
import slackline/api/conversations
import slackline/api/conversations/list as conversations_list

conversations.list()
|> conversations_list.limit(200)
|> httpc.fold_pages(
  client,
  from: [],
  with: fn(channels, page) { list.append(channels, option.unwrap(page.channels, [])) },
  metadata: fn(page) { page.response_metadata },
)
```

### File arguments

A few methods take file contents, such as `users.setPhoto` and the preview of `files.remote.add`. Their setters take a `slackline.FileUpload`, and the call is sent as `multipart/form-data`:

```gleam
import slackline/api/users
import slackline/api/users/set_photo

users.set_photo()
|> set_photo.image(slackline.FileUpload(
  filename: "avatar.png",
  content_type: "image/png",
  contents: png,
))
|> httpc.send(user_client)
```

To share files in a conversation, use `httpc.upload_files` (or `fetch.upload_files`). It runs Slack's three upload steps, `files.getUploadURLExternal`, the byte upload and `files.completeUploadExternal`, and shares every file in one message:

```gleam
import slackline/api/files/complete_upload_external

httpc.upload_files(client, [report], share: fn(call) {
  call
  |> complete_upload_external.channel_id(channel)
  |> complete_upload_external.initial_comment("this week's report")
})
```

Run the three steps yourself to set `alt_txt` or `snippet_type`, to upload now and share later, or to retry only the byte upload.

---

The canonical repo for this is hosted on tangled over at [`https://tangled.org/dunkirk.sh/slackline`](https://tangled.org/dunkirk.sh/slackline)

## Development

Most of `src/` is generated from the Slack docs and annotated with schema specs in `spec/` which describe the types and methods generated by `codegen/`:

```sh
cd codegen
gleam run -m slackline_codegen/docs fetch     # download the docs
gleam run -m slackline_codegen/docs extract   # rebuild spec/methods.json
gleam run -m slackline_codegen/generate       # regenerate src/ from spec/
```

Then run `gleam test` and `gleam test --target javascript` from the root. `spec/README.md` contains the spec language and the modelling rules.

`live/` can run slackline with a slack app to test that the calls havent changed without docs updates: read and write calls, the Events API, interactivity and Socket Mode. See `live/README.md`.

<p align="center">
    <img src="https://raw.githubusercontent.com/taciturnaxolotl/carriage/main/.github/images/line-break.svg" />
</p>

<p align="center">
    <i><code>&copy; 2026-present <a href="https://dunkirk.sh">Kieran Klukas</a></code></i>
</p>

<p align="center">
    <a href="https://tangled.org/dunkirk.sh/slackline/blob/main/LICENSE.md"><img src="https://img.shields.io/static/v1.svg?style=for-the-badge&label=License&message=MIT&logoColor=d9e0ee&colorA=363a4f&colorB=b7bdf8"/></a>
</p>
