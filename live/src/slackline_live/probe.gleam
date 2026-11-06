//// Calls the newer and rarer families once each, with both tokens, and
//// reports how Slack answers. A refusal still checks the request encoding
//// and the error path; an `ok` checks the response decoder. Anything it
//// creates, it deletes.
////
//// ```sh
//// gleam run -m slackline_live/probe C0123456789
//// ```

import argv
import gleam/bit_array
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import slackline.{type Client}
import slackline/api/apps
import slackline/api/apps/icon_set
import slackline/api/assistant
import slackline/api/files
import slackline/api/functions
import slackline/api/slack_lists
import slackline/api/slack_lists/access_delete
import slackline/api/slack_lists/access_set
import slackline/api/slack_lists/items_create
import slackline/api/slack_lists/update as list_update
import slackline/api/slackbot
import slackline/api/team
import slackline/api/users
import slackline/api/users/list as users_list
import slackline/api/workflows
import slackline/block
import slackline/httpc
import slackline/value
import slackline_live/env

pub fn main() -> Nil {
  let assert Ok(tokens) = env.load_tokens()
  let assert Ok(info) = env.load_app()
  let bot = slackline.new(tokens.bot)
  let user = slackline.new(tokens.user)
  let assert [channel, ..] = argv.load().arguments

  both(bot, user, "assistant.search.info", fn(c) {
    assistant.search_info() |> httpc.send(c) |> result_nil
  })
  both(bot, user, "assistant.search.context", fn(c) {
    assistant.search_context(query: "slackline") |> httpc.send(c) |> result_nil
  })
  both(bot, user, "workflows.featured.list", fn(c) {
    workflows.featured_list(channel_ids: [channel])
    |> httpc.send(c)
    |> result_nil
  })
  both(bot, user, "users.discoverableContacts.lookup", fn(c) {
    users.discoverable_contacts_lookup(email: "nobody@example.com")
    |> httpc.send(c)
    |> result_nil
  })
  both(bot, user, "team.billing.info", fn(c) {
    team.billing_info() |> httpc.send(c) |> result_nil
  })
  both(bot, user, "apps.activities.list", fn(c) {
    apps.activities_list(app_id: info.app_id) |> httpc.send(c) |> result_nil
  })
  both(bot, user, "functions.distributions.permissions.list", fn(c) {
    functions.distributions_permissions_list() |> httpc.send(c) |> result_nil
  })
  both(bot, user, "slackbot.skills.list", fn(c) {
    slackbot.skills_list() |> httpc.send(c) |> result_nil
  })
  lists(bot, user, channel)
  icon(bot, info.app_id)
  case argv.load().arguments {
    [_, "ratelimit", ..] -> rate_limit(bot)
    _ -> Nil
  }
}

/// Calls a Tier 2 method until Slack rate limits it, and lets
/// `httpc.retrying` wait it out.
fn rate_limit(bot: Client) -> Nil {
  let results =
    list.map(list.repeat(Nil, 150), fn(_) {
      use <- httpc.retrying(attempts: 4)
      let result = users.list() |> users_list.limit(1) |> httpc.send(bot)
      case result {
        Error(slackline.RateLimited(retry_after:)) ->
          io.println(
            "limited  users.list, waiting " <> int.to_string(retry_after) <> "s",
          )
        _ -> Nil
      }
      result
    })
  let ok = list.count(results, result.is_ok)
  io.println(
    "ok       retrying: "
    <> int.to_string(ok)
    <> "/150 users.list calls succeeded",
  )
}

fn lists(bot: Client, user: Client, channel: String) -> Nil {
  let attempt = fn(client, label) {
    slack_lists.create(name: "slackline probe")
    |> httpc.send(client)
    |> show(label)
  }
  case attempt(user, "slackLists.create (user)") {
    Ok(created) -> list_round_trip(user, created, channel)
    Error(_) ->
      case attempt(bot, "slackLists.create (bot)") {
        Ok(created) -> list_round_trip(bot, created, channel)
        Error(_) -> Nil
      }
  }
}

/// Runs every `slackLists.*` method against a fresh List, then deletes it
/// with `files.delete`, because a List is a file.
fn list_round_trip(
  client: Client,
  created: slack_lists.CreateResponse,
  channel: String,
) -> Nil {
  let list_id = created.list_id
  let column = case created.list_metadata {
    Some(slack_lists.ListMetadata(schema: Some([first, ..]), ..)) -> first.id
    _ -> ""
  }
  let new_item = fn(text) {
    slack_lists.items_create(list_id:)
    |> items_create.initial_fields([text_cell(column, None, text)])
    |> httpc.send(client)
    |> show("slackLists.items.create")
  }
  let first = new_item("first")
  let second = new_item("second")
  let third = new_item("third")
  case first {
    Ok(created) -> {
      let id = created.item.id
      let _ =
        slack_lists.items_info(list_id:, id:)
        |> httpc.send(client)
        |> show("slackLists.items.info")
      let _ =
        slack_lists.items_update(list_id:, cells: [
          text_cell(column, Some(id), "first, edited"),
        ])
        |> httpc.send(client)
        |> show("slackLists.items.update")
      let _ =
        slack_lists.items_delete(list_id:, id:)
        |> httpc.send(client)
        |> show("slackLists.items.delete")
      Nil
    }
    Error(_) -> Nil
  }
  let _ =
    slack_lists.items_list(list_id:)
    |> httpc.send(client)
    |> show("slackLists.items.list")
  case second, third {
    Ok(a), Ok(b) -> {
      let _ =
        slack_lists.items_delete_multiple(list_id:, ids: [a.item.id, b.item.id])
        |> httpc.send(client)
        |> show("slackLists.items.deleteMultiple")
      Nil
    }
    _, _ -> Nil
  }
  let _ =
    slack_lists.update(id: list_id)
    |> list_update.name("slackline probe (renamed)")
    |> httpc.send(client)
    |> show("slackLists.update")
  let _ =
    slack_lists.access_set(list_id:, access_level: "read")
    |> access_set.channel_ids([channel])
    |> httpc.send(client)
    |> show("slackLists.access.set")
  let _ =
    slack_lists.access_delete(list_id:)
    |> access_delete.channel_ids([channel])
    |> httpc.send(client)
    |> show("slackLists.access.delete")
  case
    slack_lists.download_start(list_id:)
    |> httpc.send(client)
    |> show("slackLists.download.start")
  {
    Ok(started) -> {
      let _ =
        slack_lists.download_get(list_id:, job_id: started.job_id)
        |> httpc.send(client)
        |> show("slackLists.download.get")
      Nil
    }
    Error(_) -> Nil
  }
  let _ =
    files.delete(file: list_id)
    |> httpc.send(client)
    |> show("files.delete (List)")
  Nil
}

fn text_cell(
  column: String,
  row: Option(String),
  text: String,
) -> slack_lists.ListCellInput {
  slack_lists.ListCellInput(
    column_id: column,
    row_id: row,
    row_id_to_create: None,
    rich_text: Some([
      block.rich_text(
        [block.rich_text_section([block.rich_text_run(text)])],
        [],
      ),
    ]),
    user: None,
    date: None,
    select: None,
    checkbox: None,
    number: None,
    email: None,
    phone: None,
    attachment: None,
    link: None,
    message: None,
    rating: None,
    timestamp: None,
    channel: None,
    reference: None,
  )
}

/// Sets the test app's icon, which exercises a multipart call that only
/// changes the app slackline owns.
fn icon(bot: Client, app_id: String) -> Nil {
  case env.read_file(env.state_dir() <> "/icon.png.b64") {
    Error(Nil) -> io.println("skip     apps.icon.set (no icon.png.b64)")
    Ok(text) -> {
      let assert Ok(png) = bit_array.base64_decode(string.trim(text))
      let _ =
        apps.icon_set(app_id:)
        |> icon_set.file(slackline.FileUpload(
          filename: "icon.png",
          content_type: "image/png",
          contents: png,
        ))
        |> httpc.send(bot)
        |> show("apps.icon.set (multipart)")
      Nil
    }
  }
}

fn both(
  bot: Client,
  user: Client,
  label: String,
  run: fn(Client) -> Result(Nil, slackline.Error),
) -> Nil {
  let _ = run(bot) |> show(label <> " (bot)")
  let _ = run(user) |> show(label <> " (user)")
  Nil
}

fn result_nil(
  result: Result(a, slackline.Error),
) -> Result(Nil, slackline.Error) {
  case result {
    Ok(_) -> Ok(Nil)
    Error(error) -> Error(error)
  }
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
        <> string.slice(value.to_string(response), 0, 160),
      )
    Error(error) ->
      io.println("BROKEN   " <> label <> " " <> string.inspect(error))
  }
  result
}
