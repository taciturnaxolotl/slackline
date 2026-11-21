//// Recognizes events the app caused itself, such as its own messages, from
//// the raw envelope json. Bolt filters these by default so a handler that
//// posts cannot trigger itself in a loop.

import gleam/dynamic/decode.{type Decoder}
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}

/// Events Slack sends about the app's own user that a handler still needs.
const kept = ["member_joined_channel", "member_left_channel"]

/// Whether the envelope at `path` in `text` holds an event from this app: one
/// whose `app_id` is the envelope's `api_app_id`, or whose `user` is the bot
/// user the envelope was authorized for.
pub fn check(text: String, path: List(String)) -> Bool {
  case json.parse(text, decode.at(path, envelope())) {
    Ok(Envelope(app_id:, bot_users:, event:)) -> {
      let by_app =
        app_id != None
        && list.contains([event.app_id, event.profile_app_id], app_id)
      let by_user = case event.user {
        Some(user) -> list.contains(bot_users, user)
        None -> False
      }
      !list.contains(kept, event.type_) && { by_app || by_user }
    }
    Error(_) -> False
  }
}

type Envelope {
  Envelope(app_id: Option(String), bot_users: List(String), event: Author)
}

type Author {
  Author(
    type_: String,
    user: Option(String),
    app_id: Option(String),
    profile_app_id: Option(String),
  )
}

fn envelope() -> Decoder(Envelope) {
  use app_id <- decode.optional_field("api_app_id", None, optional_string())
  use bot_users <- decode.optional_field(
    "authorizations",
    [],
    decode.list(bot_user()) |> decode.map(option.values),
  )
  use event <- decode.field("event", author())
  decode.success(Envelope(app_id:, bot_users:, event:))
}

fn bot_user() -> Decoder(Option(String)) {
  use user <- decode.optional_field("user_id", None, optional_string())
  use is_bot <- decode.optional_field("is_bot", False, decode.bool)
  decode.success(case is_bot {
    True -> user
    False -> None
  })
}

fn author() -> Decoder(Author) {
  use type_ <- decode.optional_field("type", "", decode.string)
  // `user` is an object on some events, such as `user_change`.
  use user <- decode.optional_field("user", None, optional_string())
  use app_id <- decode.optional_field("app_id", None, optional_string())
  use profile_app_id <- decode.optional_field(
    "bot_profile",
    None,
    decode.optional_field("app_id", None, optional_string(), decode.success)
      |> decode.optional
      |> decode.map(option.flatten),
  )
  decode.success(Author(type_:, user:, app_id:, profile_app_id:))
}

fn optional_string() -> Decoder(Option(String)) {
  decode.one_of(decode.string |> decode.map(Some), [decode.success(None)])
}
