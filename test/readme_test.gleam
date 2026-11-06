//// The examples from README.md, so they keep compiling. Calls are built and
//// checked with `slackline.params`, not sent.

import gleam/http/request
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import gleam/uri
import slackline
import slackline/api/apps
import slackline/api/chat
import slackline/api/chat/post_message
import slackline/api/conversations
import slackline/api/conversations/list as conversations_list
import slackline/api/users
import slackline/api/users/set_photo
import slackline/api/views
import slackline/api/views/open
import slackline/app
import slackline/block
import slackline/block/input
import slackline/block/section
import slackline/conversation.{type Conversation}
import slackline/element
import slackline/element/button
import slackline/event
import slackline/httpc
import slackline/verify
import slackline/view

pub fn post_message_test() {
  let call = chat.post_message(channel: "C123", text: "hello from gleam!")
  assert slackline.method(call) == "chat.postMessage"
  assert slackline.params(call)
    == [#("channel", "C123"), #("text", "hello from gleam!")]
}

pub fn optionals_test() {
  let call =
    chat.post_message(channel: "C123", text: "deploy finished")
    |> post_message.thread_ts("1712345678.000100")
    |> post_message.unfurl_links(False)
  assert list.key_find(slackline.params(call), "thread_ts")
    == Ok("1712345678.000100")
  assert list.key_find(slackline.params(call), "unfurl_links") == Ok("false")
}

pub fn blocks_test() {
  let logs_url = "https://ci.example.com/42"
  let call =
    chat.post_message(channel: "C123", text: "deploy finished")
    |> post_message.blocks([
      block.section(block.mrkdwn("*deploy finished* :rocket:"), [
        section.accessory(
          element.button("Logs", "logs", [button.url(logs_url)]),
        ),
      ]),
    ])
  let assert Ok(blocks) = list.key_find(slackline.params(call), "blocks")
  assert string.contains(blocks, "\"url\":\"https://ci.example.com/42\"")
}

pub fn feedback_modal() -> view.View {
  view.modal(
    "Feedback",
    [
      block.input("Thoughts", element.plain_text_input("thoughts", []), [
        input.block_id("thoughts"),
      ]),
    ],
    [view.callback_id("feedback"), view.submit("Send")],
  )
}

pub fn modal_test() {
  let call = views.open(view: feedback_modal()) |> open.trigger_id("123.456")
  let assert Ok(modal) = list.key_find(slackline.params(call), "view")
  assert string.starts_with(modal, "{\"type\":\"modal\"")
}

pub fn bot(signing_secret: String, client: slackline.Client) -> app.App {
  app.new(signing_secret)
  |> app.command("/feedback", fn(command) {
    use <- app.ack_then
    views.open(view: feedback_modal())
    |> open.trigger_id(command.trigger_id)
    |> httpc.send(client)
  })
  |> app.view_submission("feedback", fn(submission) {
    case
      view.input_text(
        submission.view,
        block_id: "thoughts",
        action_id: "thoughts",
      )
    {
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
}

pub fn bot_test() {
  let secret = "8f742231b10e8888abcd99yyyzzz85a5"
  let bot = bot(secret, slackline.new("xoxb-unused"))
  let payload =
    "{\"type\":\"view_submission\",\"user\":{\"id\":\"U1\"},\"view\":{\"type\":\"modal\",\"callback_id\":\"feedback\",\"blocks\":[],\"state\":{\"values\":{\"thoughts\":{\"thoughts\":{\"type\":\"plain_text_input\",\"value\":\"\"}}}}}}"
  let body = uri.query_to_string([#("payload", payload)])
  let now = verify.now_seconds()
  let request =
    request.new()
    |> request.set_header("content-type", "application/x-www-form-urlencoded")
    |> request.set_header("x-slack-request-timestamp", int.to_string(now))
    |> request.set_header("x-slack-signature", verify.sign(secret, now, body))
    |> request.set_body(body)
  let app.Handled(response:, after:) = app.handle(bot, request)
  after()
  assert response.body
    == "{\"response_action\":\"errors\",\"errors\":{\"thoughts\":\"say something!\"}}"
}

pub fn on_frame(
  bot: app.App,
  frame: String,
  send: fn(String) -> Nil,
  reconnect: fn() -> Nil,
) -> Nil {
  case app.handle_socket(bot, frame) {
    app.Send(frame: reply, after:) -> {
      send(reply)
      after()
    }
    app.Reconnect(_) -> reconnect()
    app.Ignore -> Nil
  }
}

pub fn socket_mode_test() {
  assert slackline.method(apps.connections_open()) == "apps.connections.open"
  let bot = bot("unused", slackline.new("xoxb-unused"))
  on_frame(
    bot,
    "{\"type\":\"disconnect\",\"reason\":\"refresh_requested\"}",
    fn(_) { panic as "nothing to send" },
    fn() { Nil },
  )
}

pub fn all_channels(
  client: slackline.Client,
) -> Result(List(Conversation), slackline.Error) {
  conversations.list()
  |> conversations_list.limit(200)
  |> httpc.fold_pages(
    client,
    from: [],
    with: fn(channels, page) {
      list.append(channels, option.unwrap(page.channels, []))
    },
    metadata: fn(page) { page.response_metadata },
  )
}

pub fn pagination_test() {
  let first = conversations.list() |> conversations_list.limit(200)
  let metadata =
    slackline.ResponseMetadata(
      next_cursor: Some("dGVhbTpDMDYxRkE1UEI="),
      warnings: None,
      messages: None,
    )
  let assert Some(next) = slackline.next_page(first, Some(metadata))
  assert slackline.params(next)
    == [#("limit", "200"), #("cursor", "dGVhbTpDMDYxRkE1UEI=")]
}

pub fn set_photo(
  user_client: slackline.Client,
  png: BitArray,
) -> Result(Nil, slackline.Error) {
  users.set_photo()
  |> set_photo.image(slackline.FileUpload(
    filename: "avatar.png",
    content_type: "image/png",
    contents: png,
  ))
  |> httpc.send(user_client)
}

pub fn file_argument_test() {
  let call =
    users.set_photo()
    |> set_photo.image(
      slackline.FileUpload(
        filename: "avatar.png",
        content_type: "image/png",
        contents: <<1, 2, 3>>,
      ),
    )
  let assert [#("image", slackline.FileUpload(filename: "avatar.png", ..))] =
    slackline.files(call)
  let req = slackline.request(call, slackline.new("xoxp-1"))
  let assert Ok("multipart/form-data; boundary=" <> _) =
    request.get_header(req, "content-type")
}
