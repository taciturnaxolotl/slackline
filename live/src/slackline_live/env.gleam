//// Small helpers the dev programs share: environment, files and state.

import gleam/dynamic/decode
import gleam/json
import gleam/result

/// Where the live test keeps credentials, outside the repository.
pub fn state_dir() -> String {
  result.unwrap(getenv("HOME"), ".") <> "/.local/state/slackline-live"
}

/// The public url bore forwards to the test bot.
pub const public_url = "https://slackline.bore.dunkirk.sh"

pub const port = 8000

/// Credentials of the test app, written by `setup` and read by `bot`.
pub type AppInfo {
  AppInfo(
    app_id: String,
    client_id: String,
    client_secret: String,
    signing_secret: String,
  )
}

pub fn save_app(app: AppInfo) -> Result(Nil, Nil) {
  json.object([
    #("app_id", json.string(app.app_id)),
    #("client_id", json.string(app.client_id)),
    #("client_secret", json.string(app.client_secret)),
    #("signing_secret", json.string(app.signing_secret)),
  ])
  |> json.to_string
  |> write_file(state_dir() <> "/app.json", _)
}

pub fn load_app() -> Result(AppInfo, Nil) {
  use text <- result.try(read_file(state_dir() <> "/app.json"))
  json.parse(text, {
    use app_id <- decode.field("app_id", decode.string)
    use client_id <- decode.field("client_id", decode.string)
    use client_secret <- decode.field("client_secret", decode.string)
    use signing_secret <- decode.field("signing_secret", decode.string)
    decode.success(AppInfo(app_id:, client_id:, client_secret:, signing_secret:))
  })
  |> result.replace_error(Nil)
}

/// Tokens from the OAuth install, written by `bot`.
pub type Tokens {
  Tokens(bot: String, user: String, team_id: String, user_id: String)
}

pub fn save_tokens(tokens: Tokens) -> Result(Nil, Nil) {
  json.object([
    #("bot", json.string(tokens.bot)),
    #("user", json.string(tokens.user)),
    #("team_id", json.string(tokens.team_id)),
    #("user_id", json.string(tokens.user_id)),
  ])
  |> json.to_string
  |> write_file(state_dir() <> "/tokens.json", _)
}

pub fn load_tokens() -> Result(Tokens, Nil) {
  use text <- result.try(read_file(state_dir() <> "/tokens.json"))
  json.parse(text, {
    use bot <- decode.field("bot", decode.string)
    use user <- decode.field("user", decode.string)
    use team_id <- decode.field("team_id", decode.string)
    use user_id <- decode.field("user_id", decode.string)
    decode.success(Tokens(bot:, user:, team_id:, user_id:))
  })
  |> result.replace_error(Nil)
}

@external(erlang, "slackline_live_ffi", "getenv")
pub fn getenv(name: String) -> Result(String, Nil)

@external(erlang, "slackline_live_ffi", "write_file")
pub fn write_file(path: String, contents: String) -> Result(Nil, Nil)

@external(erlang, "slackline_live_ffi", "read_file")
pub fn read_file(path: String) -> Result(String, Nil)

@external(erlang, "slackline_live_ffi", "halt")
pub fn halt(code: Int) -> Nil

@external(erlang, "slackline_live_ffi", "unique")
pub fn unique() -> Int
