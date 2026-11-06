//// Write tests against a real workspace. It creates a channel named
//// `slackline-live-<n>`, posts one message per Block Kit block, then edits,
//// reacts to, pins, schedules, uploads and deletes. Run it only in a
//// workspace you own.
////
//// ```sh
//// gleam run -m slackline_live/writes             # new channel
//// gleam run -m slackline_live/writes C0123456789 # existing channel
//// gleam run -m slackline_live/writes dm          # the app's DM with you
//// ```
////
//// It reads the tokens `setup exchange` saved. Slack rejects a block it
//// cannot parse with `invalid_blocks`, so each block post tests an encoder.

import argv
import gleam/bit_array
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import slackline.{type Client}
import slackline/api/bookmarks
import slackline/api/bookmarks/add as bookmarks_add
import slackline/api/bookmarks/edit as bookmarks_edit
import slackline/api/bookmarks/list as bookmarks_list
import slackline/api/bookmarks/remove as bookmarks_remove
import slackline/api/chat
import slackline/api/chat/post_message
import slackline/api/chat/update
import slackline/api/conversations
import slackline/api/conversations/open
import slackline/api/files
import slackline/api/files/complete_upload_external
import slackline/api/pins
import slackline/api/pins/add as pins_add
import slackline/api/pins/remove as pins_remove
import slackline/api/reactions
import slackline/api/reactions/remove as reactions_remove
import slackline/api/views
import slackline/block
import slackline/block/alert
import slackline/block/card
import slackline/block/container
import slackline/block/context_actions
import slackline/block/image
import slackline/block/section
import slackline/element
import slackline/element/button
import slackline/element/overflow
import slackline/httpc
import slackline/mrkdwn
import slackline/value
import slackline/view
import slackline_live/env

pub fn main() -> Nil {
  let assert Ok(tokens) = env.load_tokens()
  let bot = slackline.new(tokens.bot)
  let #(name, channel) = case argv.load().arguments {
    ["dm"] -> {
      let assert Ok(opened) =
        conversations.open()
        |> open.users([tokens.user_id])
        |> httpc.send(bot)
        |> show("conversations.open")
      #("the app DM", opened.channel.id)
    }
    [channel, ..] -> {
      let _ =
        conversations.join(channel:)
        |> httpc.send(bot)
        |> show("conversations.join")
      #(channel, channel)
    }
    [] -> {
      let name =
        "slackline-live-" <> int.to_string(env.unique() + now() % 100_000)
      let assert Ok(created) =
        conversations.create(name:)
        |> httpc.send(bot)
        |> show("conversations.create")
      let channel = created.channel.id
      let _ =
        conversations.invite(channel:, users: [tokens.user_id])
        |> httpc.send(bot)
        |> show("conversations.invite")
      let _ =
        conversations.set_topic(channel:, topic: "slackline live tests")
        |> httpc.send(bot)
        |> show("conversations.set_topic")
      #(name, channel)
    }
  }

  let results =
    list.map(blocks(), fn(entry) {
      let #(label, block) = entry
      let sent =
        chat.post_message(channel:, text: "block: " <> label)
        |> post_message.blocks([block])
        |> httpc.send(bot)
      case sent {
        Ok(_) -> #(label, "ok")
        Error(slackline.ApiError(error:, response:)) -> #(
          label,
          error <> " " <> value.to_string(response),
        )
        Error(error) -> #(label, slackline.describe_error(error))
      }
    })
  list.each(results, fn(entry) {
    io.println("block " <> string.pad_end(entry.0, 20, " ") <> entry.1)
  })

  let assert Ok(posted) =
    chat.post_message(channel:, text: "hello from slackline")
    |> httpc.send(bot)
    |> show("chat.postMessage")
  let ts = posted.ts
  let _ =
    chat.update(channel:, ts:)
    |> update.text("edited by slackline")
    |> httpc.send(bot)
    |> show("chat.update")
  let _ =
    chat.post_message(channel:, text: "a reply")
    |> post_message.thread_ts(ts)
    |> post_message.reply_broadcast(True)
    |> httpc.send(bot)
    |> show("chat.postMessage (thread)")
  let _ =
    conversations.replies(channel:, ts:)
    |> httpc.send(bot)
    |> show("conversations.replies")
  let _ =
    reactions.add(channel:, name: "tada", timestamp: ts)
    |> httpc.send(bot)
    |> show("reactions.add")
  let _ =
    reactions.get()
    |> with(channel, ts)
    |> httpc.send(bot)
    |> show("reactions.get")
  let _ =
    pins.add(channel:)
    |> pins_add.timestamp(ts)
    |> httpc.send(bot)
    |> show("pins.add")
  let _ = pins.list(channel:) |> httpc.send(bot) |> show("pins.list")
  let _ =
    pins.remove(channel:)
    |> pins_remove.timestamp(ts)
    |> httpc.send(bot)
    |> show("pins.remove")
  let _ =
    reactions.remove(name: "tada")
    |> reactions_remove.channel(channel)
    |> reactions_remove.timestamp(ts)
    |> httpc.send(bot)
    |> show("reactions.remove")
  bookmark(bot, channel)
  let _ =
    chat.post_ephemeral(
      channel:,
      user: tokens.user_id,
      text: "only you can see this",
    )
    |> httpc.send(bot)
    |> show("chat.postEphemeral")
  let _ =
    chat.me_message(channel:, text: "is testing slackline")
    |> httpc.send(bot)
    |> show("chat.meMessage")
  let _ =
    chat.get_permalink(channel:, message_ts: ts)
    |> httpc.send(bot)
    |> show("chat.getPermalink")

  let assert Ok(scheduled) =
    chat.schedule_message(channel:, post_at: now() + 3600, text: "later")
    |> httpc.send(bot)
    |> show("chat.scheduleMessage")
  let _ =
    chat.scheduled_messages_list()
    |> httpc.send(bot)
    |> show("chat.scheduledMessages.list")
  case scheduled.scheduled_message_id {
    "" -> io.println("no scheduled_message_id")
    id -> {
      let _ =
        chat.delete_scheduled_message(channel:, scheduled_message_id: id)
        |> httpc.send(bot)
        |> show("chat.deleteScheduledMessage")
      Nil
    }
  }

  upload(bot, channel)

  let _ =
    views.publish(user_id: tokens.user_id, view: home())
    |> httpc.send(bot)
    |> show("views.publish")
  let _ =
    conversations.history(channel:)
    |> httpc.send(bot)
    |> show("conversations.history")
  let _ = chat.delete(channel:, ts:) |> httpc.send(bot) |> show("chat.delete")
  io.println(
    "\nchannel " <> name <> " (" <> channel <> ") is left for inspection.",
  )
}

fn with(call, channel: String, ts: String) {
  call
  |> slackline.with_param("channel", channel)
  |> slackline.with_param("timestamp", ts)
}

fn bookmark(bot: Client, channel: String) -> Nil {
  let assert Ok(added) =
    bookmarks.add(title: "slackline", type_: "link")
    |> bookmarks_add.channel_id(channel)
    |> bookmarks_add.link("https://github.com/taciturnaxolotl/slackline")
    |> bookmarks_add.emoji(":star:")
    |> httpc.send(bot)
    |> show("bookmarks.add")
  let id = added.bookmark.id
  let _ =
    bookmarks.edit()
    |> bookmarks_edit.channel_id(channel)
    |> bookmarks_edit.bookmark_id(id)
    |> bookmarks_edit.title("slackline (edited)")
    |> httpc.send(bot)
    |> show("bookmarks.edit")
  let _ =
    bookmarks.list()
    |> bookmarks_list.channel_id(channel)
    |> httpc.send(bot)
    |> show("bookmarks.list")
  let _ =
    bookmarks.remove()
    |> bookmarks_remove.channel_id(channel)
    |> bookmarks_remove.bookmark_id(id)
    |> httpc.send(bot)
    |> show("bookmarks.remove")
  Nil
}

fn upload(bot: Client, channel: String) -> Nil {
  let contents = bit_array.from_string("hello from slackline\n")
  let assert Ok(target) =
    files.get_upload_url_external(
      length: bit_array.byte_size(contents),
      filename: "slackline.txt",
    )
    |> httpc.send(bot)
    |> show("files.getUploadURLExternal")
  let _ = httpc.upload(target.upload_url, contents) |> show("upload")
  let _ =
    files.complete_upload_external(files: [
      files.UploadedFile(id: target.file_id, title: Some("slackline.txt")),
    ])
    |> complete_upload_external.channel_id(channel)
    |> complete_upload_external.initial_comment("uploaded by slackline")
    |> httpc.send(bot)
    |> show("files.completeUploadExternal")
  let _ =
    files.info(file: target.file_id) |> httpc.send(bot) |> show("files.info")
  let _ =
    files.delete(file: target.file_id)
    |> httpc.send(bot)
    |> show("files.delete")
  Nil
}

fn show(
  result: Result(a, slackline.Error),
  label: String,
) -> Result(a, slackline.Error) {
  case result {
    Ok(_) -> io.println("ok       " <> label)
    Error(slackline.ApiError(error:, response:)) ->
      io.println(
        "refused  "
        <> label
        <> " ("
        <> error
        <> ") "
        <> value.to_string(response),
      )
    Error(error) ->
      io.println("BROKEN   " <> label <> " " <> string.inspect(error))
  }
  result
}

fn rich(text: String) -> block.RichText {
  block.rich_text_value([block.rich_text_section([block.rich_text_run(text)])])
}

fn blocks() -> List(#(String, block.Block)) {
  let logo =
    "https://raw.githubusercontent.com/gleam-lang/gleam/main/images/lucy.png"
  [
    #(
      "section",
      block.section(block.mrkdwn("*section* with " <> mrkdwn.code("mrkdwn")), [
        section.accessory(
          element.overflow(
            "o1",
            [block.option("One", "1"), block.option("Two", "2")],
            [
              overflow.confirm(block.confirmation_dialog(
                "Sure?",
                block.text("Really?"),
                "Yes",
                "No",
              )),
            ],
          ),
        ),
      ]),
    ),
    #("header", block.header("header", [])),
    #("divider", block.divider([])),
    #(
      "context",
      block.context(
        [
          block.context_mrkdwn("context"),
          block.context_image(image_url: logo, alt_text: "lucy"),
        ],
        [],
      ),
    ),
    #(
      "actions",
      block.actions(
        [
          element.button("Primary", "a1", [
            button.style(block.Primary),
            button.value("1"),
          ]),
          element.datepicker("a2", []),
          element.users_select("a3", []),
        ],
        [],
      ),
    ),
    #(
      "image",
      block.image("lucy", [image.image_url(logo), image.title("Lucy")]),
    ),
    #(
      "rich_text",
      block.rich_text(
        [block.rich_text_section([block.rich_text_run("rich text")])],
        [],
      ),
    ),
    #("markdown", block.markdown("**markdown** block", [])),
    #(
      "table",
      block.table(
        [
          [block.RawTextCell("a"), block.RawTextCell("b")],
          [block.RichTextCell(rich("c")), block.RawTextCell("d")],
        ],
        [],
      ),
    ),
    #(
      "card",
      block.card([card.title(block.text("card")), card.body(block.text("body"))]),
    ),
    #(
      "container",
      block.container([block.section(block.text("inside"), [])], [
        container.title("container"),
      ]),
    ),
    #(
      "context_actions",
      block.context_actions(
        [
          block.FeedbackButtons(block.FeedbackButtonsElement(
            positive_button: block.FeedbackButton(
              text: block.plain_text("good"),
              value: "up",
              accessibility_label: None,
            ),
            negative_button: block.FeedbackButton(
              text: block.plain_text("bad"),
              value: "down",
              accessibility_label: None,
            ),
            action_id: Some("feedback"),
          )),
        ],
        [context_actions.block_id("ca")],
      ),
    ),
    #("task_card", block.task_card("t1", "a task", block.TaskInProgress, [])),
    #(
      "plan",
      block.plan(
        "a plan",
        [
          block.PlanTask(
            task_id: "p1",
            title: "step",
            status: block.TaskComplete,
            details: None,
            output: None,
            sources: None,
            icon: None,
            hide_title: None,
          ),
        ],
        [],
      ),
    ),
    #(
      "carousel",
      block.carousel(
        [
          block.card([card.title(block.text("one"))]),
          block.card([card.title(block.text("two"))]),
        ],
        [],
      ),
    ),
    #(
      "video",
      block.video(
        alt_text: "video",
        title: "video",
        thumbnail_url: logo,
        video_url: "https://www.youtube.com/embed/dQw4w9WgXcQ",
        with: [],
      ),
    ),
  ]
}

fn home() -> view.View {
  view.home(
    [
      block.header("slackline home", []),
      block.section(block.text("published by the writes test"), []),
      block.alert(block.text("alert blocks only render outside messages"), [
        alert.level(block.AlertWarning),
      ]),
    ],
    with: [],
  )
}

@external(erlang, "os", "system_time")
fn system_time(unit: Int) -> Int

fn now() -> Int {
  system_time(1)
}
