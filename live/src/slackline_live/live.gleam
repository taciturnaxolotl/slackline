//// Checks slackline's decoders against a real workspace. It only calls
//// read-only methods.
////
//// ```sh
//// SLACK_TOKEN=xoxb-... gleam run -m slackline_live/live
//// ```
////
//// It sends with `slackline/httpc`, so run it on the Erlang target.
////
//// Each response is saved to `build/live/<method>.json`, then decoded with
//// the typed decoder. A decode failure is a bug in a spec. An API error such
//// as `missing_scope` only means the token cannot call that method.

import gleam/http/response
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import slackline.{type Call, type Client}
import slackline/api/auth
import slackline/api/bookmarks
import slackline/api/bookmarks/list as bookmarks_list
import slackline/api/bots
import slackline/api/chat
import slackline/api/conversations
import slackline/api/conversations/history
import slackline/api/conversations/list as conversations_list
import slackline/api/dnd
import slackline/api/emoji
import slackline/api/files
import slackline/api/pins
import slackline/api/reactions
import slackline/api/reminders
import slackline/api/search
import slackline/api/stars
import slackline/api/team
import slackline/api/usergroups
import slackline/api/users
import slackline/api/users/get_presence
import slackline/api/users/info as users_info
import slackline/api/users/list as users_list
import slackline/api/users/profile_get
import slackline/file
import slackline/httpc
import slackline/message
import slackline/user
import slackline/value

pub type Outcome {
  Decoded
  /// Decoded, but some values fell into catch-all variants.
  Unknowns(found: List(String))
  Refused(error: String)
  Broken(reason: String)
}

pub fn main() -> Nil {
  case getenv("SLACK_TOKEN") {
    Error(Nil) -> {
      io.println_error("Set SLACK_TOKEN to a bot or user token.")
      halt(2)
    }
    Ok(token) -> {
      let client = slackline.new(token)
      let outcomes = run(client)
      report(outcomes)
    }
  }
}

fn run(client: Client) -> List(#(String, Outcome)) {
  let #(_, auth_outcome) = check(client, auth.test_())

  let #(channels, channels_outcome) =
    check(
      client,
      conversations.list()
        |> conversations_list.types([
          "public_channel",
          "private_channel",
          "mpim",
          "im",
        ])
        |> conversations_list.limit(200),
    )
  let channels =
    channels
    |> option.map(fn(page) { option.unwrap(page.channels, []) })
    |> option.unwrap([])
  let channel_outcomes =
    channels
    |> list.filter(fn(c) { c.is_member == Some(True) || c.is_im == Some(True) })
    |> list.take(8)
    |> list.flat_map(fn(c) { channel_checks(client, c.id) })

  let #(members, users_outcome) =
    check(client, users.list() |> users_list.limit(200))
  let members =
    members
    |> option.map(fn(page) { option.unwrap(page.members, []) })
    |> option.unwrap([])
  let person =
    list.find(members, fn(u: user.User) {
      u.is_bot != Some(True) && u.deleted != Some(True)
    })
  let user_outcomes = case person {
    Ok(user.User(id: user_id, ..)) -> [
      outcome(client, users.info() |> users_info.user(user_id)),
      outcome(client, users.profile_get() |> profile_get.user(user_id)),
      outcome(client, users.get_presence() |> get_presence.user(user_id)),
    ]
    Error(Nil) -> []
  }

  let #(file_page, files_outcome) = check(client, files.list())
  let file_outcomes = case
    file_page
    |> option.map(fn(page) { option.unwrap(page.files, []) })
    |> option.unwrap([])
  {
    [file.File(id: Some(file_id), ..), ..] -> [
      outcome(client, files.info(file: file_id)),
    ]
    _ -> []
  }

  list.flatten([
    [auth_outcome, channels_outcome],
    channel_outcomes,
    [users_outcome],
    user_outcomes,
    [files_outcome],
    file_outcomes,
    [
      outcome(client, users.conversations()),
      outcome(client, team.info()),
      outcome(client, team.profile_get()),
      outcome(client, emoji.list()),
      outcome(client, reactions.list()),
      outcome(client, reminders.list()),
      outcome(client, dnd.info()),
      outcome(client, auth.teams_list()),
      outcome(client, stars.list()),
      outcome(client, search.messages(query: "the")),
      outcome(client, search.files(query: "a")),
      outcome(client, search.all(query: "slack")),
    ],
    group_outcomes(client),
  ])
}

fn channel_checks(
  client: Client,
  channel_id: String,
) -> List(#(String, Outcome)) {
  let #(history, history_outcome) =
    check(
      client,
      conversations.history(channel: channel_id) |> history.limit(200),
    )
  let messages =
    history
    |> option.map(fn(page) { option.unwrap(page.messages, []) })
    |> option.unwrap([])
  let thread =
    list.find_map(messages, fn(m: message.Message) {
      case m.reply_count, m.ts {
        Some(count), Some(ts) if count > 0 -> Ok(ts)
        _, _ -> Error(Nil)
      }
    })
  let replies = case thread {
    Ok(ts) -> [outcome(client, conversations.replies(channel: channel_id, ts:))]
    Error(Nil) -> []
  }
  let permalink = case list.first(messages) {
    Ok(message.Message(ts: Some(ts), ..)) -> [
      outcome(client, chat.get_permalink(channel: channel_id, message_ts: ts)),
    ]
    _ -> []
  }
  let bots =
    messages
    |> list.filter_map(fn(m: message.Message) {
      option.to_result(m.bot_id, Nil)
    })
    |> list.unique
    |> list.take(3)
    |> list.map(fn(bot) { outcome(client, bots.info(bot:)) })
  list.flatten([
    [
      history_outcome,
      outcome(client, conversations.info(channel: channel_id)),
      outcome(client, conversations.members(channel: channel_id)),
      outcome(client, pins.list(channel: channel_id)),
      outcome(client, bookmarks.list() |> bookmarks_list.channel_id(channel_id)),
    ],
    replies,
    permalink,
    bots,
  ])
}

fn group_outcomes(client: Client) -> List(#(String, Outcome)) {
  let #(groups, groups_outcome) = check(client, usergroups.list())
  let members = case groups {
    Some(response) ->
      case option.unwrap(response.usergroups, []) {
        [group, ..] -> [
          outcome(client, usergroups.users_list(usergroup: group.id)),
        ]
        [] -> []
      }
    None -> []
  }
  [groups_outcome, ..members]
}

/// Sends a call once as raw json, saves the body, then decodes the same body
/// with the call's typed decoder.
fn check(client: Client, call: Call(m, a)) -> #(Option(a), #(String, Outcome)) {
  let method = slackline.method(call)
  let raw = slackline.raw(method, slackline.params(call))
  case httpc.send(raw, client) {
    Error(slackline.ApiError(error:, ..)) -> #(None, #(method, Refused(error)))
    Error(error) -> #(None, #(method, Broken(slackline.describe_error(error))))
    Ok(body) -> {
      let text = value.to_string(body)
      let _ = write_file("build/live/" <> method <> ".json", text)
      let reply = response.new(200) |> response.set_body(text)
      case slackline.response(call, reply) {
        Ok(decoded) ->
          case unknowns(string.inspect(decoded)) {
            [] -> #(Some(decoded), #(method, Decoded))
            found -> #(Some(decoded), #(method, Unknowns(found)))
          }
        Error(slackline.DecodeError(errors:, ..)) -> #(
          None,
          #(method, Broken(string.inspect(errors))),
        )
        Error(error) -> #(
          None,
          #(method, Broken(slackline.describe_error(error))),
        )
      }
    }
  }
}

/// The catch-all constructors in an inspected value, with their tags, such
/// as `UnknownBlock("future_block")`.
pub fn unknowns(inspected: String) -> List(String) {
  case string.split(inspected, "Unknown") {
    [] | [_] -> []
    [_, ..rest] ->
      rest
      |> list.filter_map(fn(piece) {
        case string.split_once(piece, "(") {
          Ok(#(name, after)) ->
            case string.split_once(after, "\"") {
              Ok(#("", tagged)) ->
                case string.split_once(tagged, "\"") {
                  Ok(#(tag, _)) -> Ok("Unknown" <> name <> "(" <> tag <> ")")
                  Error(Nil) -> Ok("Unknown" <> name)
                }
              _ -> Ok("Unknown" <> name)
            }
          Error(Nil) -> Error(Nil)
        }
      })
      |> list.unique
  }
}

fn outcome(client: Client, call: Call(m, a)) -> #(String, Outcome) {
  check(client, call).1
}

fn report(outcomes: List(#(String, Outcome))) -> Nil {
  list.each(outcomes, fn(entry) {
    let #(method, outcome) = entry
    case outcome {
      Decoded -> io.println("ok       " <> method)
      Unknowns(found) ->
        io.println("unknown  " <> method <> " " <> string.join(found, ", "))
      Refused(error) ->
        io.println("refused  " <> method <> " (" <> error <> ")")
      Broken(reason) ->
        io.println("BROKEN   " <> method <> "\n         " <> reason)
    }
  })
  let broken =
    list.count(outcomes, fn(entry) {
      case entry.1 {
        Broken(_) -> True
        _ -> False
      }
    })
  io.println(
    "\n"
    <> int.to_string(list.length(outcomes))
    <> " calls, "
    <> int.to_string(broken)
    <> " broken. Raw responses are in build/live/.",
  )
  case broken {
    0 -> Nil
    _ -> halt(1)
  }
}

@external(erlang, "slackline_live_ffi", "getenv")
fn getenv(name: String) -> Result(String, Nil)

@external(erlang, "slackline_live_ffi", "write_file")
fn write_file(path: String, contents: String) -> Result(Nil, Nil)

@external(erlang, "slackline_live_ffi", "halt")
fn halt(code: Int) -> Nil
