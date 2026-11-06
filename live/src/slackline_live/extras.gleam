//// Write tests for the less common families: canvases, streaming, Calls,
//// remote files, reminders, Do Not Disturb, stars and presence. Everything
//// it creates, it removes again. It posts in the app's DM with you.
////
//// ```sh
//// gleam run -m slackline_live/extras
//// gleam run -m slackline_live/extras reminders  # also reminders.*
//// ```

import argv
import gleam/int
import gleam/io
import gleam/option.{None, Some}
import gleam/string
import slackline
import slackline/api/calls
import slackline/api/calls/add as calls_add
import slackline/api/calls/update as calls_update
import slackline/api/canvases
import slackline/api/canvases/create as canvases_create
import slackline/api/chat
import slackline/api/chat/append_stream
import slackline/api/chat/post_message
import slackline/api/chat/start_stream
import slackline/api/chat/stop_stream
import slackline/api/conversations
import slackline/api/conversations/open
import slackline/api/dnd
import slackline/api/files
import slackline/api/files/remote_info
import slackline/api/files/remote_remove
import slackline/api/files/remote_share
import slackline/api/reminders
import slackline/api/stars
import slackline/api/stars/add as stars_add
import slackline/api/stars/remove as stars_remove
import slackline/api/users
import slackline/block
import slackline/common
import slackline/httpc
import slackline/value
import slackline_live/env

pub fn main() -> Nil {
  let assert Ok(tokens) = env.load_tokens()
  let bot = slackline.new(tokens.bot)
  let user = slackline.new(tokens.user)
  let assert Ok(opened) =
    conversations.open()
    |> open.users([tokens.user_id])
    |> httpc.send(bot)
    |> show("conversations.open")
  let channel = opened.channel.id
  let id = "slackline-" <> int.to_string(env.unique())

  canvas(bot, channel)
  stream(bot, channel, tokens)
  call(bot, channel, tokens.user_id, id)
  remote_file(bot, channel, id)
  let _ =
    users.set_presence(presence: users.Auto)
    |> httpc.send(bot)
    |> show("users.setPresence")

  let assert Ok(posted) =
    chat.post_message(channel:, text: "a message to star")
    |> httpc.send(bot)
    |> show("chat.postMessage")
  star(user, channel, posted.ts)
  // Slack files new reminders under To-dos, where `reminders.info`, `list`,
  // `complete` and `delete` cannot find them, so each run leaves one behind.
  case argv.load().arguments {
    ["reminders"] -> reminder(user)
    _ -> Nil
  }
  snooze(user)
  let _ =
    chat.delete(channel:, ts: posted.ts)
    |> httpc.send(bot)
    |> show("chat.delete")
  Nil
}

fn canvas(bot: slackline.Client, channel: String) -> Nil {
  let doc = fn(markdown) { common.CanvasDocumentContent(markdown:) }
  case
    canvases.create()
    |> canvases_create.title("slackline canvas")
    |> canvases_create.document_content(doc("# slackline\n\nmade by Gleam"))
    |> httpc.send(bot)
    |> show("canvases.create")
  {
    Error(_) -> Nil
    Ok(created) -> {
      let canvas_id = created.canvas_id
      let _ =
        canvases.edit(canvas_id:, changes: [
          canvases.InsertAtEndChange(doc("## edited\n\nby `canvases.edit`")),
        ])
        |> httpc.send(bot)
        |> show("canvases.edit (insert)")
      let _ =
        canvases.edit(canvas_id:, changes: [
          canvases.RenameChange(doc("slackline canvas :sparkles:")),
        ])
        |> httpc.send(bot)
        |> show("canvases.edit (rename)")
      let _ =
        canvases.sections_lookup(
          canvas_id:,
          criteria: canvases.CanvasSectionCriteria(
            section_types: Some([canvases.AnyHeader]),
            contains_text: None,
          ),
        )
        |> httpc.send(bot)
        |> show("canvases.sections.lookup")
      let _ =
        canvases.get_content(canvas_id:)
        |> httpc.send(bot)
        |> show("canvases.getContent")
      let _ =
        chat.post_message(
          channel:,
          text: "canvas: https://slack.com/docs/" <> canvas_id,
        )
        |> httpc.send(bot)
        |> show("chat.postMessage (canvas link)")
      let _ =
        canvases.delete(canvas_id:)
        |> httpc.send(bot)
        |> show("canvases.delete")
      Nil
    }
  }
}

fn stream(bot: slackline.Client, channel: String, tokens: env.Tokens) -> Nil {
  let assert Ok(parent) =
    chat.post_message(channel:, text: "streaming below")
    |> httpc.send(bot)
    |> show("chat.postMessage (stream parent)")
  case
    chat.start_stream(channel:)
    |> start_stream.thread_ts(parent.ts)
    |> start_stream.recipient_user_id(tokens.user_id)
    |> start_stream.recipient_team_id(tokens.team_id)
    |> start_stream.chunks([
      chat.MarkdownTextChunk(text: "Thinking about *Gleam*"),
    ])
    |> httpc.send(bot)
    |> show("chat.startStream")
  {
    Error(_) -> Nil
    Ok(started) -> {
      let _ =
        chat.append_stream(channel:, ts: started.ts)
        |> append_stream.chunks([
          chat.MarkdownTextChunk(text: " and its type system."),
          chat.TaskUpdateChunk(
            id: "t1",
            title: "check the types",
            status: block.TaskComplete,
            hide_title: None,
            icon: None,
            details: Some("all green"),
            output: None,
            sources: None,
          ),
        ])
        |> httpc.send(bot)
        |> show("chat.appendStream")
      let _ =
        chat.stop_stream(channel:, ts: started.ts)
        |> stop_stream.chunks([chat.MarkdownTextChunk(text: " Done.")])
        |> stop_stream.blocks([
          block.context([block.context_mrkdwn("streamed by slackline")], []),
        ])
        |> httpc.send(bot)
        |> show("chat.stopStream")
      Nil
    }
  }
}

fn call(
  bot: slackline.Client,
  channel: String,
  user: String,
  id: String,
) -> Nil {
  case
    calls.add(external_unique_id: id, join_url: "https://example.com/call")
    |> calls_add.title("slackline call")
    |> calls_add.users([
      calls.CallUser(
        slack_id: Some(user),
        external_id: None,
        display_name: None,
        avatar_url: None,
      ),
    ])
    |> httpc.send(bot)
    |> show("calls.add")
  {
    Ok(calls.AddResponse(call: Some(call))) -> {
      let call_id = call.id
      let _ = calls.info(id: call_id) |> httpc.send(bot) |> show("calls.info")
      let _ =
        calls.update(id: call_id)
        |> calls_update.title("slackline call (renamed)")
        |> httpc.send(bot)
        |> show("calls.update")
      let guest =
        calls.CallUser(
          slack_id: None,
          external_id: "guest-1" |> Some,
          display_name: Some("Lucy"),
          avatar_url: None,
        )
      let _ =
        calls.participants_add(id: call_id, users: [guest])
        |> httpc.send(bot)
        |> show("calls.participants.add")
      let _ =
        chat.post_message(channel:, text: "a call")
        |> post_message.blocks([block.call(call_id, [])])
        |> httpc.send(bot)
        |> show("chat.postMessage (call block)")
      let _ =
        calls.participants_remove(id: call_id, users: [guest])
        |> httpc.send(bot)
        |> show("calls.participants.remove")
      let _ = calls.end(id: call_id) |> httpc.send(bot) |> show("calls.end")
      Nil
    }
    Ok(_) -> io.println("calls.add returned no call")
    Error(_) -> Nil
  }
}

fn remote_file(bot: slackline.Client, channel: String, id: String) -> Nil {
  case
    files.remote_add(
      external_id: id,
      external_url: "https://gleam.run",
      title: "slackline remote file",
    )
    |> httpc.send(bot)
    |> show("files.remote.add")
  {
    Error(_) -> Nil
    Ok(_) -> {
      let _ =
        files.remote_info()
        |> remote_info.external_id(id)
        |> httpc.send(bot)
        |> show("files.remote.info")
      let _ =
        files.remote_share(channels: [channel])
        |> remote_share.external_id(id)
        |> httpc.send(bot)
        |> show("files.remote.share")
      let _ =
        files.remote_list() |> httpc.send(bot) |> show("files.remote.list")
      let _ =
        files.remote_remove()
        |> remote_remove.external_id(id)
        |> httpc.send(bot)
        |> show("files.remote.remove")
      Nil
    }
  }
}

fn star(user: slackline.Client, channel: String, ts: String) -> Nil {
  let _ =
    stars.add()
    |> stars_add.channel(channel)
    |> stars_add.timestamp(ts)
    |> httpc.send(user)
    |> show("stars.add")
  let _ = stars.list() |> httpc.send(user) |> show("stars.list")
  let _ =
    stars.remove()
    |> stars_remove.channel(channel)
    |> stars_remove.timestamp(ts)
    |> httpc.send(user)
    |> show("stars.remove")
  Nil
}

fn reminder(user: slackline.Client) -> Nil {
  case
    reminders.add(text: "slackline test reminder", time: "in 2 hours")
    |> httpc.send(user)
    |> show("reminders.add")
  {
    Error(_) -> Nil
    Ok(added) -> {
      let reminder = added.reminder.id
      let _ =
        reminders.info(reminder:) |> httpc.send(user) |> show("reminders.info")
      let _ = reminders.list() |> httpc.send(user) |> show("reminders.list")
      let _ =
        reminders.complete(reminder:)
        |> httpc.send(user)
        |> show("reminders.complete")
      let _ =
        reminders.delete(reminder:)
        |> httpc.send(user)
        |> show("reminders.delete")
      Nil
    }
  }
}

fn snooze(user: slackline.Client) -> Nil {
  let _ =
    dnd.set_snooze(num_minutes: 1) |> httpc.send(user) |> show("dnd.setSnooze")
  let _ = dnd.info() |> httpc.send(user) |> show("dnd.info")
  let _ = dnd.end_snooze() |> httpc.send(user) |> show("dnd.endSnooze")
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
