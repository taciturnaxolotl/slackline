//// Write tests that change workspace state: channel lifecycle, user
//// groups, profiles, canvas access, public file links and assorted one-off
//// methods. It creates a channel, a user group and a file, and cleans up
//// what Slack lets it. Run it only in a workspace you own.
////
//// ```sh
//// gleam run -m slackline_live/lifecycle C0123456789  # a channel for posts
//// ```

import argv
import gleam/bit_array
import gleam/int
import gleam/io
import gleam/json
import gleam/option.{None, Some}
import gleam/string
import slackline.{type Client}
import slackline/api/api
import slackline/api/auth
import slackline/api/blocks as blocks_api
import slackline/api/blocks/validate
import slackline/api/canvases
import slackline/api/canvases/access_delete
import slackline/api/canvases/access_set
import slackline/api/chat
import slackline/api/conversations
import slackline/api/conversations/canvases_create
import slackline/api/conversations/kick
import slackline/api/dnd
import slackline/api/files
import slackline/api/files/complete_upload_external
import slackline/api/files/remote_info
import slackline/api/files/remote_remove
import slackline/api/files/remote_update
import slackline/api/team
import slackline/api/usergroups
import slackline/api/usergroups/create as usergroups_create
import slackline/api/usergroups/update as usergroups_update
import slackline/api/users
import slackline/api/users/info
import slackline/api/users/profile_set
import slackline/block
import slackline/common
import slackline/httpc
import slackline/interaction
import slackline/value
import slackline_live/env

pub fn main() -> Nil {
  let assert Ok(tokens) = env.load_tokens()
  let bot = slackline.new(tokens.bot)
  let user = slackline.new(tokens.user)
  let assert [posts, ..] = argv.load().arguments
  let n = int.to_string(env.unique() + now() % 100_000)

  misc(bot, user, tokens)
  webhook()
  channel_lifecycle(bot, user, tokens, n)
  usergroup(user, tokens, n)
  profile(user, tokens)
  public_file(bot, user, posts)
  remote_file(bot, n)
  Nil
}

fn misc(bot: Client, user: Client, tokens: env.Tokens) -> Nil {
  let _ = api.test_() |> httpc.send(bot) |> show("api.test")
  let _ =
    blocks_api.validate()
    |> validate.blocks([block.section(block.text("valid"), [])])
    |> httpc.send(bot)
    |> show("blocks.validate")
  let _ = users.identity() |> httpc.send(user) |> show("users.identity")
  let _ = users.set_active() |> httpc.send(bot) |> show("users.setActive")
  let _ =
    dnd.team_info(users: [tokens.user_id])
    |> httpc.send(bot)
    |> show("dnd.teamInfo")
  let _ = dnd.end_dnd() |> httpc.send(user) |> show("dnd.endDnd")
  let _ =
    team.preferences_list()
    |> httpc.send(bot)
    |> show("team.preferences.list")
  let _ = team.billable_info() |> httpc.send(user) |> show("team.billableInfo")
  let _ = team.access_logs() |> httpc.send(user) |> show("team.accessLogs")
  let _ =
    team.integration_logs()
    |> httpc.send(user)
    |> show("team.integrationLogs")
  let _ =
    team.external_teams_list()
    |> httpc.send(bot)
    |> show("team.externalTeams.list")
  Nil
}

fn webhook() -> Nil {
  case env.read_file(env.state_dir() <> "/webhook") {
    Ok(url) -> {
      let message =
        interaction.ResponseMessage(
          ..interaction.response_message(),
          text: Some("from an incoming webhook"),
          blocks: Some([
            block.section(block.mrkdwn("*incoming webhook* via slackline"), []),
          ]),
        )
      let _ =
        httpc.webhook(url, interaction.response_message_to_json(message))
        |> show("incoming webhook")
      let _ =
        httpc.webhook(url <> "x", json.object([#("text", json.string("bad"))]))
        |> show("incoming webhook (bad url)")
      Nil
    }
    Error(Nil) -> io.println("no webhook saved")
  }
}

fn channel_lifecycle(
  bot: Client,
  user: Client,
  tokens: env.Tokens,
  n: String,
) -> Nil {
  let assert Ok(created) =
    conversations.create(name: "slackline-life-" <> n)
    |> httpc.send(bot)
    |> show("conversations.create")
  let channel = created.channel.id
  let _ =
    conversations.invite(channel:, users: [tokens.user_id])
    |> httpc.send(bot)
    |> show("conversations.invite")
  let _ =
    conversations.rename(channel:, name: "slackline-renamed-" <> n)
    |> httpc.send(bot)
    |> show("conversations.rename")
  let _ =
    conversations.set_purpose(channel:, purpose: "slackline lifecycle test")
    |> httpc.send(bot)
    |> show("conversations.setPurpose")
  let _ =
    conversations.set_topic(channel:, topic: "lifecycle")
    |> httpc.send(user)
    |> show("conversations.setTopic (user)")
  let assert Ok(posted) =
    chat.post_message(channel:, text: "mark me read")
    |> httpc.send(bot)
    |> show("chat.postMessage")
  let _ =
    conversations.mark(channel:, ts: posted.ts)
    |> httpc.send(user)
    |> show("conversations.mark")
  case
    conversations.canvases_create(channel_id: channel)
    |> canvases_create.title("channel canvas")
    |> canvases_create.document_content(common.CanvasDocumentContent(
      "# channel canvas",
    ))
    |> httpc.send(bot)
    |> show("conversations.canvases.create")
  {
    Ok(made) -> canvas_access(bot, made.canvas_id, channel, tokens.user_id)
    Error(_) -> Nil
  }
  let _ =
    conversations.kick(channel:)
    |> kick.user(tokens.user_id)
    |> httpc.send(bot)
    |> show("conversations.kick")
  let _ =
    conversations.archive(channel:)
    |> httpc.send(bot)
    |> show("conversations.archive")
  let _ =
    conversations.unarchive(channel:)
    |> httpc.send(user)
    |> show("conversations.unarchive (user)")
  let _ =
    conversations.leave(channel:)
    |> httpc.send(bot)
    |> show("conversations.leave")
  let _ =
    conversations.archive(channel:)
    |> httpc.send(user)
    |> show("conversations.archive (user)")
  let assert Ok(dm) =
    conversations.open()
    |> open_users([tokens.user_id])
    |> httpc.send(bot)
    |> show("conversations.open")
  let _ =
    conversations.close(channel: dm.channel.id)
    |> httpc.send(bot)
    |> show("conversations.close")
  Nil
}

fn open_users(call, users: List(String)) {
  slackline.with_param(call, "users", string.join(users, ","))
}

fn canvas_access(
  bot: Client,
  canvas_id: String,
  channel: String,
  user: String,
) -> Nil {
  let _ =
    canvases.access_set(canvas_id:, access_level: canvases.WriteAccess)
    |> access_set.user_ids([user])
    |> httpc.send(bot)
    |> show("canvases.access.set")
  let _ =
    canvases.access_delete(canvas_id:)
    |> access_delete.user_ids([user])
    |> httpc.send(bot)
    |> show("canvases.access.delete")
  let _ = channel
  Nil
}

fn usergroup(user: Client, tokens: env.Tokens, n: String) -> Nil {
  case
    usergroups.create(name: "slackline " <> n)
    |> usergroups_create.handle("slackline-" <> n)
    |> usergroups_create.description("made by slackline")
    |> httpc.send(user)
    |> show("usergroups.create")
  {
    Ok(usergroups.CreateResponse(usergroup: Some(group))) -> {
      let usergroup = group.id
      let _ =
        usergroups.update(usergroup:)
        |> usergroups_update.description("updated by slackline")
        |> httpc.send(user)
        |> show("usergroups.update")
      let _ =
        usergroups.users_update(usergroup:, users: [tokens.user_id])
        |> httpc.send(user)
        |> show("usergroups.users.update")
      let _ =
        usergroups.users_list(usergroup:)
        |> httpc.send(user)
        |> show("usergroups.users.list")
      let _ =
        usergroups.disable(usergroup:)
        |> httpc.send(user)
        |> show("usergroups.disable")
      let _ =
        usergroups.enable(usergroup:)
        |> httpc.send(user)
        |> show("usergroups.enable")
      let _ =
        usergroups.disable(usergroup:)
        |> httpc.send(user)
        |> show("usergroups.disable (cleanup)")
      Nil
    }
    Ok(_) -> io.println("usergroups.create returned no group")
    Error(_) -> Nil
  }
}

fn profile(user: Client, tokens: env.Tokens) -> Nil {
  let assert Ok(before) =
    users.profile_get() |> httpc.send(user) |> show("users.profile.get")
  let title = case before.profile {
    Some(profile) -> option.unwrap(profile.title, "")
    None -> ""
  }
  let clear_status =
    users.ProfileUpdate(
      display_name: None,
      email: None,
      first_name: None,
      last_name: None,
      phone: None,
      pronouns: None,
      real_name: None,
      start_date: None,
      title: None,
      status_emoji: Some(""),
      status_expiration: Some(0),
      status_text: Some(""),
      fields: None,
    )
  let _ =
    users.profile_set()
    |> profile_set.profile(users.ProfileUpdate(
      display_name: None,
      email: None,
      first_name: None,
      last_name: None,
      phone: None,
      pronouns: None,
      real_name: None,
      start_date: None,
      title: None,
      status_emoji: Some(":rocket:"),
      status_expiration: Some(now() + 120),
      status_text: Some("testing slackline"),
      fields: None,
    ))
    |> httpc.send(user)
    |> show("users.profile.set")
  let _ =
    users.profile_set()
    |> profile_set.name("title")
    |> profile_set.value(title)
    |> httpc.send(user)
    |> show("users.profile.set (name/value)")
  let _ =
    users.profile_set()
    |> profile_set.profile(clear_status)
    |> httpc.send(user)
    |> show("users.profile.set (clear status)")
  case users.info() |> info.user(tokens.user_id) |> httpc.send(user) {
    Ok(users.InfoResponse(user: Some(found))) ->
      case found.profile {
        Some(profile) ->
          case profile.email {
            Some(email) -> {
              let _ =
                users.lookup_by_email(email:)
                |> httpc.send(user)
                |> show("users.lookupByEmail")
              Nil
            }
            None -> io.println("no email to look up")
          }
        None -> Nil
      }
    _ -> Nil
  }
}

fn public_file(bot: Client, user: Client, channel: String) -> Nil {
  let contents = bit_array.from_string("public slackline file\n")
  let assert Ok(target) =
    files.get_upload_url_external(
      length: bit_array.byte_size(contents),
      filename: "public.txt",
    )
    |> httpc.send(user)
    |> show("files.getUploadURLExternal (user)")
  let _ = httpc.upload(target.upload_url, contents) |> show("upload")
  let _ =
    files.complete_upload_external(files: [
      files.UploadedFile(id: target.file_id, title: Some("public.txt")),
    ])
    |> complete_upload_external.channel_id(channel)
    |> httpc.send(user)
    |> show("files.completeUploadExternal (user)")
  let file = target.file_id
  let _ =
    files.shared_public_url(file:)
    |> httpc.send(user)
    |> show("files.sharedPublicURL")
  let _ =
    files.revoke_public_url(file:)
    |> httpc.send(user)
    |> show("files.revokePublicURL")
  let _ = files.delete(file:) |> httpc.send(user) |> show("files.delete")
  let _ = bot
  Nil
}

fn remote_file(bot: Client, n: String) -> Nil {
  let id = "slackline-life-" <> n
  let _ =
    files.remote_add(
      external_id: id,
      external_url: "https://gleam.run",
      title: "before",
    )
    |> httpc.send(bot)
    |> show("files.remote.add")
  let _ =
    files.remote_update()
    |> remote_update.external_id(id)
    |> remote_update.title("after")
    |> httpc.send(bot)
    |> show("files.remote.update")
  let _ =
    files.remote_info()
    |> remote_info.external_id(id)
    |> httpc.send(bot)
    |> show("files.remote.info")
  let _ =
    files.remote_remove()
    |> remote_remove.external_id(id)
    |> httpc.send(bot)
    |> show("files.remote.remove")
  let _ = auth.test_
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

@external(erlang, "os", "system_time")
fn system_time(unit: Int) -> Int

fn now() -> Int {
  system_time(1)
}
