//// Creates, updates or deletes the live test app with slackline's own
//// `apps.manifest.*` calls.
////
//// ```sh
//// source ~/.local/state/slackline-live/env
//// gleam run -m slackline_live/setup -- create [socket]
//// gleam run -m slackline_live/setup -- update [socket]
//// gleam run -m slackline_live/setup -- delete
//// ```
////
//// `create` saves the app credentials and prints the install link. Start
//// `slackline_live/bot` and the bore tunnel first, because Slack checks the
//// event request url when the app is created.

import argv
import gleam/io
import gleam/json
import gleam/option.{Some}
import gleam/string
import slackline
import slackline/api/apps
import slackline/api/oauth as oauth_api
import slackline/api/oauth/v2_access
import slackline/httpc
import slackline/manifest
import slackline/oauth
import slackline/value
import slackline_live/env

pub fn main() -> Nil {
  case env.getenv("SLACK_CONFIG_TOKEN"), argv.load().arguments {
    _, ["url"] -> {
      let assert Ok(app) = env.load_app()
      io.println(install_url(app))
    }
    _, ["exchange", code] -> exchange(code)
    Error(Nil), _ ->
      fail("Set SLACK_CONFIG_TOKEN to an app configuration token.")
    Ok(token), ["create"] -> create(slackline.new(token), False)
    Ok(token), ["create", "socket"] -> create(slackline.new(token), True)
    Ok(token), ["update"] -> update(slackline.new(token), False)
    Ok(token), ["update", "socket"] -> update(slackline.new(token), True)
    Ok(token), ["delete"] -> delete(slackline.new(token))
    _, _ ->
      fail(
        "Usage: setup create [socket] | update [socket] | delete | url | exchange <code>",
      )
  }
}

fn create(client: slackline.Client, socket: Bool) -> Nil {
  let manifest = test_manifest(socket)
  let assert Ok(validated) =
    apps.manifest_validate(manifest: manifest) |> httpc.send(client)
  io.println("validate: " <> string.inspect(validated))
  case apps.manifest_create(manifest: manifest) |> httpc.send(client) {
    Error(error) -> fail("create: " <> describe(error))
    Ok(created) -> {
      let assert Some(credentials) = created.credentials
      let assert Some(client_id) = credentials.client_id
      let assert Some(client_secret) = credentials.client_secret
      let assert Some(signing_secret) = credentials.signing_secret
      let app =
        env.AppInfo(
          app_id: created.app_id,
          client_id:,
          client_secret:,
          signing_secret:,
        )
      let assert Ok(Nil) = env.save_app(app)
      io.println("created " <> created.app_id)
      io.println("install: " <> install_url(app))
    }
  }
}

fn update(client: slackline.Client, socket: Bool) -> Nil {
  let assert Ok(app) = env.load_app()
  case
    apps.manifest_update(manifest: test_manifest(socket), app_id: app.app_id)
    |> httpc.send(client)
  {
    Ok(updated) -> io.println("updated: " <> string.inspect(updated))
    Error(error) -> fail("update: " <> describe(error))
  }
  case apps.manifest_export(app_id: app.app_id) |> httpc.send(client) {
    Ok(exported) ->
      io.println("exported: " <> value.to_string(exported.manifest))
    Error(error) -> fail("export: " <> describe(error))
  }
}

fn delete(client: slackline.Client) -> Nil {
  let assert Ok(app) = env.load_app()
  case apps.manifest_delete(app_id: app.app_id) |> httpc.send(client) {
    Ok(Nil) -> io.println("deleted " <> app.app_id)
    Error(error) -> fail("delete: " <> describe(error))
  }
}

/// Finishes an install whose redirect could not reach the bot, from the
/// `code` in the redirect url.
fn exchange(code: String) -> Nil {
  let assert Ok(app) = env.load_app()
  let result =
    oauth_api.v2_access()
    |> v2_access.client_id(app.client_id)
    |> v2_access.client_secret(app.client_secret)
    |> v2_access.code(code)
    |> v2_access.redirect_uri(env.public_url <> "/oauth/callback")
    |> httpc.send(slackline.anonymous())
  case result {
    Error(error) -> fail("exchange: " <> describe(error))
    Ok(granted) -> {
      let assert Some(bot) = granted.access_token
      let assert Some(user) = granted.authed_user
      let tokens =
        env.Tokens(
          bot:,
          user: option.unwrap(user.access_token, ""),
          team_id: granted.team
            |> option.map(fn(team) { team.id })
            |> option.unwrap(""),
          user_id: user.id,
        )
      let assert Ok(Nil) = env.save_tokens(tokens)
      io.println("installed: bot scopes " <> option.unwrap(granted.scope, ""))
    }
  }
}

/// The install link, built with `slackline/oauth`.
pub fn install_url(app: env.AppInfo) -> String {
  oauth.authorize_url(
    oauth.Authorize(
      ..oauth.authorize(client_id: app.client_id),
      scopes: bot_scopes,
      user_scopes: user_scopes,
      redirect_uri: Some(env.public_url <> "/oauth/callback"),
      state: Some(oauth.sign_state(app.signing_secret)),
    ),
  )
}

const bot_scopes = [
  "app_mentions:read", "bookmarks:read", "bookmarks:write", "channels:manage",
  "channels:write.invites", "groups:write", "channels:history", "channels:join",
  "channels:read", "chat:write", "chat:write.public", "commands", "dnd:read",
  "emoji:read", "files:read", "files:write", "groups:history", "groups:read",
  "im:history", "im:read", "im:write", "links:read", "links:write",
  "mpim:history", "mpim:read", "pins:read", "pins:write", "reactions:read",
  "reactions:write", "team:read", "usergroups:read", "users.profile:read",
  "users:read", "users:read.email", "canvases:read", "canvases:write",
  "calls:read", "calls:write", "remote_files:read", "remote_files:write",
  "remote_files:share", "users:write",
]

const user_scopes = [
  "bookmarks:read", "channels:history", "channels:read", "dnd:read",
  "emoji:read", "files:read", "groups:history", "groups:read", "im:history",
  "im:read", "mpim:history", "mpim:read", "pins:read", "reactions:read",
  "reminders:read", "search:read", "stars:read", "team:read", "usergroups:read",
  "users.profile:read", "users:read", "reminders:write", "dnd:write",
  "stars:write",
]

/// Decodes the manifest with slackline's types, then encodes it again, so
/// both directions are tested before Slack sees it.
fn test_manifest(socket: Bool) -> value.Value {
  let assert Ok(decoded) =
    json.parse(manifest_json(socket), manifest.manifest_decoder())
  let assert Ok(encoded) =
    decoded |> manifest.manifest_to_json |> json.to_string |> value.parse
  encoded
}

fn manifest_json(socket: Bool) -> String {
  let url = env.public_url <> "/slack"
  // Socket Mode apps take events over the WebSocket, so they set no urls.
  let with_url = fn(entries, key) {
    case socket {
      True -> entries
      False -> [#(key, json.string(url)), ..entries]
    }
  }
  let scopes = fn(list) { json.array(list, json.string) }
  json.object([
    #(
      "_metadata",
      json.object([
        #("major_version", json.int(1)),
        #("minor_version", json.int(1)),
      ]),
    ),
    #(
      "display_information",
      json.object([
        #("name", json.string("slackline test")),
        #(
          "description",
          json.string("Live tests for the slackline Gleam library"),
        ),
        #("background_color", json.string("#2c2d72")),
      ]),
    ),
    #(
      "features",
      json.object([
        #(
          "app_home",
          json.object([
            #("home_tab_enabled", json.bool(True)),
            #("messages_tab_enabled", json.bool(True)),
            #("messages_tab_read_only_enabled", json.bool(False)),
          ]),
        ),
        #(
          "bot_user",
          json.object([
            #("display_name", json.string("slackline test")),
            #("always_online", json.bool(True)),
          ]),
        ),
        #(
          "shortcuts",
          json.preprocessed_array([
            json.object([
              #("name", json.string("slackline global")),
              #("type", json.string("global")),
              #("callback_id", json.string("slackline_global")),
              #("description", json.string("Opens the slackline test modal")),
            ]),
            json.object([
              #("name", json.string("slackline message")),
              #("type", json.string("message")),
              #("callback_id", json.string("slackline_message")),
              #("description", json.string("Inspects a message with slackline")),
            ]),
          ]),
        ),
        #(
          "slash_commands",
          json.preprocessed_array([
            json.object(with_url(
              [
                #("command", json.string("/slackline")),
                #("description", json.string("Run slackline live tests")),
                #("usage_hint", json.string("[modal|blocks|ping]")),
                #("should_escape", json.bool(False)),
              ],
              "url",
            )),
          ]),
        ),
        #("unfurl_domains", scopes(["slackline.bore.dunkirk.sh"])),
      ]),
    ),
    #(
      "oauth_config",
      json.object([
        #("redirect_urls", scopes([env.public_url <> "/oauth/callback"])),
        #(
          "scopes",
          json.object([
            #("bot", scopes(bot_scopes)),
            #("user", scopes(user_scopes)),
          ]),
        ),
      ]),
    ),
    #(
      "settings",
      json.object([
        #(
          "event_subscriptions",
          json.object(with_url(
            [
              #(
                "bot_events",
                scopes([
                  "app_home_opened", "app_mention", "channel_created",
                  "link_shared", "member_joined_channel", "message.channels",
                  "message.groups", "message.im", "pin_added", "reaction_added",
                  "reaction_removed",
                ]),
              ),
            ],
            "request_url",
          )),
        ),
        #(
          "interactivity",
          json.object(with_url(
            with_url([#("is_enabled", json.bool(True))], "request_url"),
            "message_menu_options_url",
          )),
        ),
        #("org_deploy_enabled", json.bool(False)),
        #("socket_mode_enabled", json.bool(socket)),
        #("token_rotation_enabled", json.bool(False)),
      ]),
    ),
  ])
  |> json.to_string
}

fn describe(error: slackline.Error) -> String {
  case error {
    slackline.ApiError(response:, ..) -> value.to_string(response)
    _ -> slackline.describe_error(error)
  }
}

fn fail(message: String) -> Nil {
  io.println_error(message)
  env.halt(1)
}
