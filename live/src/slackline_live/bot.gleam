//// A Slack app that exercises slackline against live traffic.
////
//// ```sh
//// gleam run -m slackline_live/bot      # serves on port 8000
//// bore slackline 8000                 # https://slackline.bore.dunkirk.sh
//// ```
////
//// Every request body is saved to `build/live/http/`, and every body the
//// router cannot decode is reported. Then `/slackline` in Slack opens a
//// modal with most input kinds, posts Block Kit messages and pings back
//// through a `response_url`. The Home tab, mentions, reactions and both
//// shortcuts also run through the router.

import gleam/bit_array
import gleam/bytes_tree
import gleam/dict
import gleam/erlang/process
import gleam/http.{Get, Post}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import gleam/uri
import mist
import slackline
import slackline/api/chat
import slackline/api/chat/post_message
import slackline/api/chat/unfurl
import slackline/api/oauth as oauth_api
import slackline/api/oauth/v2_access
import slackline/api/views
import slackline/api/views/open
import slackline/api/views/push
import slackline/api/views/update
import slackline/app
import slackline/block
import slackline/block/input
import slackline/block/section
import slackline/element
import slackline/element/button
import slackline/element/external_select
import slackline/element/multi_static_select
import slackline/element/plain_text_input
import slackline/element/static_select
import slackline/event
import slackline/httpc
import slackline/interaction
import slackline/mrkdwn
import slackline/oauth
import slackline/view
import slackline_live/env
import slackline_live/live
import slackline_live/setup

pub fn main() -> Nil {
  let assert Ok(_) =
    mist.new(serve)
    |> mist.bind("0.0.0.0")
    |> mist.port(env.port)
    |> mist.start
  io.println("listening on " <> int.to_string(env.port))
  process.sleep_forever()
}

fn serve(request: Request(mist.Connection)) -> Response(mist.ResponseData) {
  // Before `setup create` there are no credentials yet, but Slack already
  // checks the request url. An unverified router answers that challenge.
  let info =
    env.load_app()
    |> result.unwrap(env.AppInfo(
      app_id: "",
      client_id: "",
      client_secret: "",
      signing_secret: "",
    ))
  let body = case mist.read_body(request, 4_000_000) {
    Ok(request) -> bit_array.to_string(request.body) |> result.unwrap("")
    Error(_) -> ""
  }
  let request = request.set_body(request, body)
  let #(status, text) = case request.method, request.path {
    Post, "/slack" -> slack(info, request)
    Get, "/oauth/callback" -> callback(info, request)
    Get, "/install" -> #(302, "")
    _, _ -> #(404, "not found")
  }
  let response =
    response.new(status)
    |> response.set_body(mist.Bytes(bytes_tree.from_string(text)))
  case request.path, status {
    "/install", _ ->
      response.set_header(response, "location", install_link(info))
    "/slack", _ ->
      response.set_header(response, "content-type", "application/json")
    _, _ -> response
  }
}

fn install_link(info: env.AppInfo) -> String {
  setup.install_url(info)
}

// ---- OAuth -----------------------------------------------------------------

fn callback(info: env.AppInfo, request: Request(String)) -> #(Int, String) {
  let query =
    request.query |> option.unwrap("") |> uri.parse_query |> result.unwrap([])
  let state = list.key_find(query, "state") |> result.unwrap("")
  let code = list.key_find(query, "code") |> result.unwrap("")
  case oauth.verify_state(info.signing_secret, state) {
    Error(error) -> #(400, "bad state: " <> string.inspect(error))
    Ok(Nil) -> {
      let exchange =
        oauth_api.v2_access()
        |> v2_access.client_id(info.client_id)
        |> v2_access.client_secret(info.client_secret)
        |> v2_access.code(code)
        |> v2_access.redirect_uri(env.public_url <> "/oauth/callback")
        |> httpc.send(slackline.anonymous())
      case exchange {
        Error(error) -> #(500, slackline.describe_error(error))
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
          io.println("installed for " <> user.id)
          #(200, "slackline test is installed. You can close this tab.")
        }
      }
    }
  }
}

// ---- Slack requests --------------------------------------------------------

fn slack(info: env.AppInfo, request: Request(String)) -> #(Int, String) {
  let n = env.unique()
  let kind = case app.parse_request(request) {
    Ok(app.Events(event.EventCallback(event: inner, ..))) ->
      "event-" <> event_type(inner)
    Ok(app.Events(_)) -> "envelope"
    Ok(app.Interactive(_)) -> "interaction"
    Ok(app.Command(_)) -> "command"
    Ok(app.SslCheck) -> "ssl-check"
    Error(error) -> {
      io.println(
        "UNDECODED request "
        <> int.to_string(n)
        <> ": "
        <> string.inspect(error),
      )
      "undecoded"
    }
  }
  let _ =
    env.write_file(
      "build/live/http/" <> pad(n) <> "-" <> kind <> ".txt",
      string.join(
        [
          "content-type: "
            <> result.unwrap(request.get_header(request, "content-type"), ""),
          "",
          request.body,
        ],
        "\n",
      ),
    )
  io.println("request " <> int.to_string(n) <> ": " <> kind)
  let routes = case info.signing_secret {
    "" -> app.unverified()
    _ -> router(info)
  }
  let app.Handled(response:, after:) = app.handle(routes, request)
  process.spawn(after)
  #(response.status, response.body)
}

fn event_type(event: event.Event) -> String {
  case event {
    event.UnknownEvent(type_:, ..) -> "unknown-" <> type_
    _ ->
      string.inspect(event)
      |> string.split("(")
      |> list.first
      |> result.unwrap("event")
  }
}

fn pad(n: Int) -> String {
  string.pad_start(int.to_string(n), 4, "0")
}

fn client() -> slackline.Client {
  let assert Ok(tokens) = env.load_tokens()
  slackline.new(tokens.bot)
}

fn report(label: String, result: Result(a, slackline.Error)) -> Nil {
  case result {
    Ok(_) -> io.println("  " <> label <> ": ok")
    Error(error) ->
      io.println("  " <> label <> ": FAILED " <> string.inspect(error))
  }
}

pub fn router(info: env.AppInfo) -> app.App {
  app.new(info.signing_secret)
  |> app.command("/slackline", fn(command) {
    case string.trim(option.unwrap(command.text, "")) {
      "modal" -> {
        use <- app.ack_then
        views.open(view: test_modal(command.channel_id))
        |> open.trigger_id(command.trigger_id)
        |> httpc.send(client())
        |> report("views.open", _)
      }
      "blocks" -> {
        use <- app.ack_then
        chat.post_message(channel: command.channel_id, text: "slackline blocks")
        |> post_message.blocks(test_blocks(command.user_id))
        |> httpc.send(client())
        |> report("chat.postMessage", _)
      }
      "ping" ->
        app.reply(interaction.ephemeral(
          "pong from " <> mrkdwn.user(command.user_id),
        ))
      _ ->
        app.reply(interaction.ephemeral(
          "Try `/slackline modal`, `/slackline blocks` or `/slackline ping`.",
        ))
    }
  })
  |> app.action("ping", fn(action, payload) {
    io.println("  action: " <> string.inspect(action))
    use <- app.ack_then
    case payload.response_url {
      Some(url) ->
        interaction.ephemeral("button pressed")
        |> interaction.response_message_to_json
        |> httpc.webhook(url, _)
        |> report("response_url", _)
      None -> io.println("  no response_url")
    }
  })
  |> app.action("open_modal", fn(_, payload) {
    use <- app.ack_then
    case payload.trigger_id {
      Some(trigger) ->
        views.open(view: test_modal(""))
        |> open.trigger_id(trigger)
        |> httpc.send(client())
        |> report("views.open", _)
      None -> io.println("  no trigger_id")
    }
  })
  |> app.block_suggestion("language", fn(payload) {
    let query = string.lowercase(payload.value)
    ["gleam", "erlang", "javascript", "elixir", "lustre", "wisp"]
    |> list.filter(string.contains(_, query))
    |> list.map(fn(name) { block.option(name, name) })
    |> app.options
  })
  |> app.view_submission("slackline_modal", fn(submission) {
    let v = submission.view
    let read = fn(block) { view.input(v, block_id: block, action_id: block) }
    let fields = [
      "thoughts", "tone", "language", "people", "where", "colors", "flags",
      "size", "day", "time", "when", "count", "email", "site", "notes",
    ]
    list.each(fields, fn(name) {
      io.println(
        "  "
        <> name
        <> ": "
        <> case read(name) {
          Some(value) ->
            string.inspect(#(
              view.selected_value(value),
              view.selected_values(value),
              view.text_value(value),
            ))
          None -> "-"
        },
      )
    })
    case view.input_text(v, block_id: "thoughts", action_id: "thoughts") {
      Some("") | None -> app.errors([#("thoughts", "say something!")])
      Some(text) -> {
        use <- app.ack_then
        chat.post_message(
          channel: submission.user.id,
          text: "You said: " <> mrkdwn.escape(text),
        )
        |> httpc.send(client())
        |> report("chat.postMessage (submission)", _)
      }
    }
  })
  |> app.view_closed("slackline_modal", fn(_) {
    io.println("  modal closed")
    app.ack()
  })
  |> app.action("modal_push", fn(_, payload) {
    use <- app.ack_then
    case payload.trigger_id {
      Some(trigger) ->
        views.push(view: stack_view(1))
        |> push.trigger_id(trigger)
        |> httpc.send(client())
        |> report("views.push", _)
      None -> io.println("  no trigger_id")
    }
  })
  |> app.action("modal_update", fn(_, payload) {
    use <- app.ack_then
    case payload.view {
      Some(view.View(id: Some(view_id), hash: Some(hash), ..)) ->
        views.update(view: stack_view(1))
        |> update.view_id(view_id)
        |> update.hash(hash)
        |> httpc.send(client())
        |> report("views.update", _)
      _ -> io.println("  no view id")
    }
  })
  |> app.view_submission("slackline_stack", fn(submission) {
    let depth =
      submission.view.private_metadata
      |> option.unwrap("1")
      |> int.parse
      |> result.unwrap(1)
    io.println("  stack depth " <> int.to_string(depth))
    case depth {
      1 -> app.push(stack_view(2))
      2 -> app.update(stack_view(3))
      _ -> app.clear()
    }
  })
  |> app.global_shortcut("slackline_global", fn(payload) {
    use <- app.ack_then
    case payload.trigger_id {
      Some(trigger) ->
        views.open(view: test_modal(""))
        |> open.trigger_id(trigger)
        |> httpc.send(client())
        |> report("views.open (shortcut)", _)
      None -> io.println("  no trigger_id")
    }
  })
  |> app.message_shortcut("slackline_message", fn(payload) {
    use <- app.ack_then
    case payload.response_url {
      Some(url) ->
        interaction.ephemeral(
          "That message decoded as: "
          <> string.slice(string.inspect(payload.message), 0, 2500),
        )
        |> interaction.response_message_to_json
        |> httpc.webhook(url, _)
        |> report("response_url (shortcut)", _)
      None -> io.println("  no response_url")
    }
  })
  |> app.on_interaction(fn(payload) {
    io.println("  unrouted interaction: " <> string.inspect(payload))
    app.ack()
  })
  |> app.on_event(fn(event, delivery) {
    case live.unknowns(string.inspect(event)) {
      [] -> Nil
      found -> io.println("  UNKNOWN variants " <> string.join(found, ", "))
    }
    case delivery.retry {
      Some(retry) -> io.println("  retry " <> string.inspect(retry))
      None -> Nil
    }
    case event {
      event.AppHomeOpened(user: Some(user), tab: Some("home"), ..) ->
        views.publish(user_id: user, view: home(user))
        |> httpc.send(client())
        |> report("views.publish", _)
      event.AppMention(channel:, ts: Some(ts), user:, ..) ->
        chat.post_message(channel:, text: "hello!")
        |> post_message.thread_ts(ts)
        |> post_message.blocks(test_blocks(option.unwrap(user, "")))
        |> httpc.send(client())
        |> report("chat.postMessage (mention)", _)
      event.LinkShared(channel:, message_ts:, links:, unfurl_id:, source:, ..) -> {
        let unfurls =
          links
          |> list.map(fn(link) {
            #(
              link.url,
              chat.BlocksUnfurlContent(chat.BlocksUnfurl(
                blocks: [
                  block.section(
                    block.mrkdwn("*unfurled by slackline*\n" <> link.url),
                    [],
                  ),
                ],
                preview: None,
                hide_color: None,
              )),
            )
          })
          |> dict.from_list
        let call = case source, unfurl_id {
          Some(event.LinkSourceComposer), Some(id) ->
            chat.unfurl()
            |> unfurl.unfurl_id(id)
            |> unfurl.source(chat.Composer)
          _, _ ->
            chat.unfurl() |> unfurl.channel(channel) |> unfurl.ts(message_ts)
        }
        call
        |> unfurl.unfurls(unfurls)
        |> httpc.send(client())
        |> report("chat.unfurl", _)
      }
      event.UnknownEvent(type_:, ..) ->
        io.println("  UNKNOWN event type " <> type_)
      other ->
        io.println("  event: " <> string.slice(string.inspect(other), 0, 300))
    }
  })
}

// ---- views and blocks ------------------------------------------------------

fn test_blocks(user: String) -> List(block.Block) {
  [
    block.header("slackline", []),
    block.section(
      block.mrkdwn(
        "Hi " <> mrkdwn.user(user) <> ", this message came from Gleam.",
      ),
      [
        section.accessory(element.button("Ping", "ping", [button.value("1")])),
      ],
    ),
    block.divider([]),
    block.actions(
      [
        element.button("Open modal", "open_modal", [button.style(block.Primary)]),
        element.static_select("tone", [
          static_select.placeholder("Pick a tone"),
          static_select.options([
            block.option("Calm", "calm"),
            block.option("Loud", "loud"),
          ]),
        ]),
      ],
      [],
    ),
    block.context(
      [
        block.context_mrkdwn(
          "sent "
          <> mrkdwn.date(
            timestamp: 1_712_345_678,
            format: "{date_short} at {time}",
            link: None,
            fallback: "a while ago",
          ),
        ),
      ],
      [],
    ),
  ]
}

fn field(label: String, element: block.Element) -> block.Block {
  block.input(label, element, [])
}

fn test_modal(channel: String) -> view.View {
  let colors = [
    block.option("Red", "red"),
    block.option("Green", "green"),
    block.option("Blue", "blue"),
  ]
  view.modal(
    "slackline test",
    [
      block.actions(
        [
          element.button("Push a view", "modal_push", []),
          element.button("Replace this view", "modal_update", []),
        ],
        [],
      ),
      block.input(
        "Thoughts",
        element.plain_text_input("thoughts", [plain_text_input.multiline(True)]),
        [block_id("thoughts"), input.hint("Leave empty to see an error.")],
      ),
      block.input(
        "Tone",
        element.static_select("tone", [
          static_select.option_groups([
            block.option_group("Quiet", [block.option("Calm", "calm")]),
            block.option_group("Not quiet", [block.option("Loud", "loud")]),
          ]),
        ]),
        [block_id("tone"), input.optional(True)],
      ),
      block.input(
        "Language (search)",
        element.external_select("language", [
          external_select.min_query_length(1),
        ]),
        [block_id("language"), input.optional(True)],
      ),
      optional(
        field("People", element.multi_users_select("people", [])),
        "people",
      ),
      optional(
        field("Where", element.conversations_select("where", [])),
        "where",
      ),
      optional(
        field(
          "Colors",
          element.multi_static_select("colors", [
            multi_static_select.options(colors),
          ]),
        ),
        "colors",
      ),
      optional(field("Flags", element.checkboxes("flags", colors, [])), "flags"),
      optional(
        field(
          "Size",
          element.radio_buttons(
            "size",
            [block.option("S", "s"), block.option("L", "l")],
            [],
          ),
        ),
        "size",
      ),
      optional(field("Day", element.datepicker("day", [])), "day"),
      optional(field("Time", element.timepicker("time", [])), "time"),
      optional(field("When", element.datetimepicker("when", [])), "when"),
      optional(
        field("Count", element.number_input("count", False, [])),
        "count",
      ),
      optional(field("Email", element.email_text_input("email", [])), "email"),
      optional(field("Site", element.url_text_input("site", [])), "site"),
      optional(field("Notes", element.rich_text_input("notes", [])), "notes"),
    ],
    with: [
      view.callback_id("slackline_modal"),
      view.submit("Send"),
      view.close("Cancel"),
      view.notify_on_close(True),
      view.private_metadata(channel),
    ],
  )
}

fn stack_view(depth: Int) -> view.View {
  let label = int.to_string(depth)
  view.modal(
    "slackline stack " <> label,
    [
      block.section(
        block.text(case depth {
          1 -> "Submit pushes another view (response_action: push)."
          2 -> "Submit replaces this view (response_action: update)."
          _ -> "Submit closes every view (response_action: clear)."
        }),
        [],
      ),
    ],
    with: [
      view.callback_id("slackline_stack"),
      view.private_metadata(label),
      view.submit("Next"),
    ],
  )
}

fn block_id(id: String) -> block.Attr(block.InputBlock) {
  input.block_id(id)
}

fn optional(input_block: block.Block, id: String) -> block.Block {
  case input_block {
    block.Input(inner) ->
      block.Input(
        block.InputBlock(..inner, block_id: Some(id), optional: Some(True)),
      )
    other -> other
  }
}

fn home(user: String) -> view.View {
  view.home(
    [
      block.header("slackline test", []),
      block.section(
        block.mrkdwn(
          "Hello "
          <> mrkdwn.user(user)
          <> ". This Home tab came from `views.publish`.",
        ),
        [section.accessory(element.button("Open modal", "open_modal", []))],
      ),
    ],
    with: [view.callback_id("slackline_home")],
  )
}
