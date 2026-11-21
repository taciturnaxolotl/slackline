import gleam/dict
import gleam/http/request
import gleam/http/response
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import gleam/uri
import log
import slackline/app
import slackline/block
import slackline/event
import slackline/interaction
import slackline/socket_mode
import slackline/verify

const secret = "8f742231b10e8888abcd99yyyzzz85a5"

fn signed(body: String, content_type: String) -> request.Request(String) {
  let now = verify.now_seconds()
  request.new()
  |> request.set_header("content-type", content_type)
  |> request.set_header("x-slack-request-timestamp", string.inspect(now))
  |> request.set_header("x-slack-signature", verify.sign(secret, now, body))
  |> request.set_body(body)
}

fn form(fields: List(#(String, String))) -> request.Request(String) {
  signed(uri.query_to_string(fields), "application/x-www-form-urlencoded")
}

fn command_fields(command: String, text: String) -> List(#(String, String)) {
  [
    #("command", command),
    #("text", text),
    #("user_id", "U1"),
    #("channel_id", "C1"),
    #("response_url", "https://hooks.slack.com/commands/T1/1/abc"),
    #("trigger_id", "1.2.abc"),
  ]
}

pub fn rejects_unsigned_test() {
  let req =
    request.new()
    |> request.set_header("content-type", "application/json")
    |> request.set_body("{}")
  assert { app.handle(app.new(secret), req).response }.status == 401
}

pub fn url_verification_test() {
  let body =
    "{\"token\":\"Jhj5dZrVaK7ZwHHjRyZWjbDl\",\"challenge\":\"3eZbrw1aBm2rZgRNFdxV2595E9CY3gmdALWMmHkvFXO7tYXAYM8P\",\"type\":\"url_verification\"}"
  let res =
    app.handle(app.new(secret), signed(body, "application/json")).response
  assert res.status == 200
  assert res.body
    == "{\"challenge\":\"3eZbrw1aBm2rZgRNFdxV2595E9CY3gmdALWMmHkvFXO7tYXAYM8P\"}"
}

pub fn command_test() {
  let my_app =
    app.new(secret)
    |> app.command("/hello", fn(command) {
      app.reply(interaction.ephemeral("hi " <> command.user_id))
    })
  let res =
    app.handle(
      my_app,
      form([
        #("command", "/hello"),
        #("user_id", "U123"),
        #("text", ""),
        #("team_id", "T1"),
        #("channel_id", "C1"),
        #("response_url", "https://hooks.slack.com/commands/T1/1/abc"),
        #("trigger_id", "1.2.abc"),
      ]),
    ).response
  assert res.status == 200
  assert response.get_header(res, "content-type") == Ok("application/json")
  assert res.body == "{\"text\":\"hi U123\",\"response_type\":\"ephemeral\"}"
}

pub fn ssl_check_test() {
  let res =
    app.handle(app.new(secret), form([#("ssl_check", "1"), #("token", "x")])).response
  assert res.status == 200
  assert res.body == ""
}

pub fn action_routing_test() {
  let payload =
    "{\"type\":\"block_actions\",\"user\":{\"id\":\"U1\"},\"actions\":[{\"type\":\"button\",\"action_id\":\"approve\",\"block_id\":\"b\",\"value\":\"42\",\"action_ts\":\"1.2\"}]}"
  let my_app =
    app.new(secret)
    |> app.action("other", fn(_, _) { app.ack_json(json.string("wrong")) })
    |> app.action("approve", fn(action, payload) {
      assert payload.user.id == "U1"
      case action {
        interaction.ButtonAction(value: Some(value), ..) ->
          app.ack_json(json.string(value))
        _ -> app.ack()
      }
    })
  let res = app.handle(my_app, form([#("payload", payload)])).response
  assert res.body == "\"42\""
}

pub fn view_submission_routing_test() {
  let payload =
    "{\"type\":\"view_submission\",\"user\":{\"id\":\"U1\"},\"view\":{\"id\":\"V1\",\"type\":\"modal\",\"callback_id\":\"signup\",\"blocks\":[]}}"
  let my_app =
    app.new(secret)
    |> app.view_closed("signup", fn(_) { app.ack_json(json.string("wrong")) })
    |> app.view_submission("signup", fn(submission) {
      assert submission.view.callback_id == Some("signup")
      app.errors([#("email", "nope")])
    })
  let res = app.handle(my_app, form([#("payload", payload)])).response
  assert res.body
    == "{\"response_action\":\"errors\",\"errors\":{\"email\":\"nope\"}}"
}

pub fn events_test() {
  let body =
    "{\"token\":\"x\",\"team_id\":\"T1\",\"api_app_id\":\"A1\",\"event\":{\"type\":\"app_mention\",\"user\":\"U1\",\"text\":\"<@U0> hi\",\"ts\":\"1.1\",\"channel\":\"C1\",\"event_ts\":\"1.1\"},\"type\":\"event_callback\",\"event_id\":\"Ev1\",\"event_time\":1}"
  let req =
    signed(body, "application/json")
    |> request.set_header("x-slack-retry-num", "2")
    |> request.set_header("x-slack-retry-reason", "http_timeout")
  // Handlers return Nil, so check what they saw through the delivery. They
  // run after the acknowledgement, in `after`.
  let my_app =
    app.unverified()
    |> app.on_event(fn(event, delivery) {
      let assert event.AppMention(..) = event
      assert delivery.team_id == Some("T1")
      assert delivery.retry == Some(app.Retry(num: 2, reason: "http_timeout"))
      Nil
    })
  let handled = app.handle(my_app, req)
  assert handled.response.status == 200
  assert handled.response.body == ""
  handled.after()
}

pub fn socket_mode_test() {
  let frame =
    "{\"payload\":{\"token\":\"bHKJ2n9AW6Ju3MjciOHfbA1b\",\"team_id\":\"T123ABC456\",\"team_domain\":\"maria\",\"channel_id\":\"C123ABC456\",\"channel_name\":\"general\",\"user_id\":\"U123ABC456\",\"user_name\":\"rainer\",\"command\":\"/randorilke\",\"text\":\"\",\"response_url\":\"https://rilke.slack.com/commands/T0SNL8S4S/37053613554/YMB2ZESDLNjNLqSFZ1quhNAh\",\"trigger_id\":\"37053613634.26768298162.440952c06ef4de2653466a48fe495f93\"},\"envelope_id\":\"dbdd0ef3-1543-4f94-bfb4-133d0e6c1545\",\"type\":\"slash_commands\",\"accepts_response_payload\":true}"
  let my_app =
    app.unverified()
    |> app.command("/randorilke", fn(_) {
      app.reply(interaction.ephemeral("Duino Elegies"))
    })
  let assert app.Send(frame: reply, ..) = app.handle_socket(my_app, frame)
  assert reply
    == "{\"envelope_id\":\"dbdd0ef3-1543-4f94-bfb4-133d0e6c1545\",\"payload\":{\"text\":\"Duino Elegies\",\"response_type\":\"ephemeral\"}}"
  assert app.handle_socket(
      my_app,
      "{\"type\":\"disconnect\",\"reason\":\"warning\",\"debug_info\":{\"host\":\"wss-111.slack.com\"}}",
    )
    == app.Reconnect(socket_mode.Warning)
}

pub fn ack_then_runs_after_test() {
  let my_app =
    app.unverified()
    |> app.command("/slow", fn(command) {
      use <- app.ack_then
      log.record("slow: " <> option.unwrap(command.text, ""))
    })
  let handled = app.handle(my_app, form(command_fields("/slow", "go")))
  assert handled.response.status == 200
  assert handled.response.body == ""
  assert !list.contains(log.recorded(), "slow: go")
  handled.after()
  assert list.contains(log.recorded(), "slow: go")
}

pub fn socket_continuation_test() {
  let frame =
    "{\"payload\":{\"command\":\"/slow\",\"text\":\"\",\"user_id\":\"U1\",\"channel_id\":\"C1\",\"response_url\":\"https://hooks.slack.com/commands/T1/1/abc\",\"trigger_id\":\"1.2.abc\"},\"envelope_id\":\"e1\",\"type\":\"slash_commands\",\"accepts_response_payload\":true}"
  let my_app =
    app.unverified()
    |> app.command("/slow", fn(_) {
      app.reply(interaction.in_channel("Working on it"))
      |> app.then(fn() { Nil })
    })
  let assert app.Send(frame: reply, after:) = app.handle_socket(my_app, frame)
  assert reply
    == "{\"envelope_id\":\"e1\",\"payload\":{\"text\":\"Working on it\",\"response_type\":\"in_channel\"}}"
  after()
}

pub fn shortcut_and_options_routing_test() {
  let shortcut =
    "{\"type\":\"shortcut\",\"callback_id\":\"new_thing\",\"trigger_id\":\"t1\",\"user\":{\"id\":\"U1\"},\"team\":{\"id\":\"T1\"}}"
  let suggestion =
    "{\"type\":\"block_suggestion\",\"user\":{\"id\":\"U1\"},\"block_id\":\"b\",\"action_id\":\"pick\",\"value\":\"ab\"}"
  let my_app =
    app.unverified()
    |> app.message_shortcut("new_thing", fn(_) {
      app.ack_json(json.string("wrong"))
    })
    |> app.global_shortcut("new_thing", fn(payload) {
      app.ack_json(
        json.string(case payload.trigger_id {
          Some(id) -> id
          None -> ""
        }),
      )
    })
    |> app.block_suggestion("pick", fn(payload) {
      app.options([block.option(payload.value, payload.value)])
    })
  let res = app.handle(my_app, form([#("payload", shortcut)])).response
  assert res.body == "\"t1\""
  let res = app.handle(my_app, form([#("payload", suggestion)])).response
  assert res.body
    == "{\"options\":[{\"text\":{\"type\":\"plain_text\",\"text\":\"ab\"},\"value\":\"ab\"}]}"
}

pub fn malformed_body_test() {
  let res =
    app.handle(app.new(secret), signed("{", "application/json")).response
  assert res.status == 400
}

pub fn unknown_command_acks_empty_test() {
  let res =
    app.handle(app.new(secret), form(command_fields("/nobody", ""))).response
  assert res.status == 200
  assert res.body == ""
}

pub fn second_action_routes_test() {
  let payload =
    "{\"type\":\"block_actions\",\"user\":{\"id\":\"U1\"},\"actions\":[{\"type\":\"button\",\"action_id\":\"ignored\",\"block_id\":\"b\",\"action_ts\":\"1\"},{\"type\":\"button\",\"action_id\":\"second\",\"block_id\":\"b\",\"value\":\"2\",\"action_ts\":\"2\"}]}"
  let my_app =
    app.new(secret)
    |> app.action("second", fn(_, _) { app.ack_json(json.string("second")) })
  let res = app.handle(my_app, form([#("payload", payload)])).response
  assert res.body == "\"second\""
}

pub fn on_interaction_fallback_test() {
  let payload =
    "{\"type\":\"dialog_cancellation\",\"callback_id\":\"old\",\"user\":{\"id\":\"U1\"},\"action_ts\":\"1\"}"
  let my_app =
    app.new(secret)
    |> app.on_interaction(fn(_) { app.ack() })
    |> app.on_interaction(fn(_) { app.ack_json(json.string("fallback")) })
  let res = app.handle(my_app, form([#("payload", payload)])).response
  assert res.body == "\"fallback\""
}

pub fn event_handlers_run_in_order_test() {
  let body =
    "{\"team_id\":\"T1\",\"event\":{\"type\":\"app_mention\",\"user\":\"U1\",\"text\":\"hi\",\"ts\":\"9.9\",\"channel\":\"C1\",\"event_ts\":\"9.9\"},\"type\":\"event_callback\",\"event_id\":\"EvOrder\"}"
  let my_app =
    app.unverified()
    |> app.on_event(fn(_, _) { log.record("order: first") })
    |> app.on_event(fn(_, _) { log.record("order: second") })
  let handled = app.handle(my_app, signed(body, "application/json"))
  handled.after()
  let order =
    list.filter(log.recorded(), fn(entry) {
      string.starts_with(entry, "order: ")
    })
  assert order == ["order: first", "order: second"]
}

pub fn socket_ignores_garbage_test() {
  assert app.handle_socket(app.unverified(), "not json") == app.Ignore
}

pub fn unknown_action_type_routes_test() {
  let payload =
    "{\"type\":\"block_actions\",\"user\":{\"id\":\"U1\"},\"actions\":[{\"type\":\"future_widget\",\"action_id\":\"future\",\"block_id\":\"b\",\"action_ts\":\"1\"}]}"
  let my_app =
    app.new(secret)
    |> app.action("future", fn(action, _) {
      case action {
        interaction.UnknownBlockAction(..) -> app.ack_json(json.string("raw"))
        _ -> app.ack()
      }
    })
  let res = app.handle(my_app, form([#("payload", payload)])).response
  assert res.body == "\"raw\""
}

pub fn later_fallback_replaces_earlier_test() {
  let payload =
    "{\"type\":\"dialog_cancellation\",\"callback_id\":\"old\",\"user\":{\"id\":\"U1\"},\"action_ts\":\"1\"}"
  let my_app =
    app.new(secret)
    |> app.on_interaction(fn(_) { app.ack_json(json.string("first")) })
    |> app.on_interaction(fn(_) { app.ack() })
  let res = app.handle(my_app, form([#("payload", payload)])).response
  assert res.body == ""
}

fn event_body(event: String, authorizations: String) -> String {
  "{\"team_id\":\"T1\",\"api_app_id\":\"A1\",\"event\":"
  <> event
  <> ",\"type\":\"event_callback\",\"event_id\":\"Ev1\",\"authorizations\":"
  <> authorizations
  <> "}"
}

const bot_authorization =
  "[{\"team_id\":\"T1\",\"user_id\":\"UBOT\",\"is_bot\":true}]"

fn ran(my_app: app.App, body: String, label: String) -> Bool {
  let handled = app.handle(my_app, signed(body, "application/json"))
  handled.after()
  list.contains(log.recorded(), label)
}

pub fn function_routes_by_callback_id_test() {
  let body =
    event_body(
      "{\"type\":\"function_executed\",\"function\":{\"id\":\"Fn1\",\"callback_id\":\"summarize\"},\"inputs\":{\"user_id\":\"U9\"},\"function_execution_id\":\"Fx1\",\"bot_access_token\":\"xwfp-1\",\"event_ts\":\"1.1\"}",
      "[]",
    )
  let my_app =
    app.unverified()
    |> app.function("other", fn(_) { log.record("fn: other") })
    |> app.function("summarize", fn(execution) {
      assert execution.function_execution_id == "Fx1"
      assert execution.token == Some("xwfp-1")
      assert dict.size(execution.inputs) == 1
      log.record("fn: summarize")
    })
  assert ran(my_app, body, "fn: summarize")
  assert !list.contains(log.recorded(), "fn: other")
}

pub fn assistant_message_matches_user_dm_threads_test() {
  let message = fn(extra) {
    event_body(
      "{\"type\":\"message\",\"channel\":\"D1\",\"channel_type\":\"im\",\"text\":\"hi\",\"ts\":\"2.2\""
        <> extra
        <> "}",
      "[]",
    )
  }
  let my_app = fn(label) {
    app.unverified()
    |> app.assistant_message(fn(_, _) { log.record(label) })
  }
  assert ran(
    my_app("assistant: thread"),
    message(",\"user\":\"U1\",\"thread_ts\":\"1.0\""),
    "assistant: thread",
  )
  assert !ran(
    my_app("assistant: top level"),
    message(",\"user\":\"U1\""),
    "assistant: top level",
  )
}

pub fn own_events_are_skipped_test() {
  let from_bot =
    event_body(
      "{\"type\":\"message\",\"channel\":\"C1\",\"user\":\"UBOT\",\"text\":\"hi\",\"ts\":\"3.3\"}",
      bot_authorization,
    )
  let from_app =
    event_body(
      "{\"type\":\"reaction_added\",\"user\":\"U2\",\"app_id\":\"A1\",\"reaction\":\"x\",\"item\":{\"type\":\"message\",\"channel\":\"C1\",\"ts\":\"1.1\"},\"event_ts\":\"3.4\"}",
      bot_authorization,
    )
  let joined =
    event_body(
      "{\"type\":\"member_joined_channel\",\"user\":\"UBOT\",\"channel\":\"C1\",\"event_ts\":\"3.5\"}",
      bot_authorization,
    )
  let from_person =
    event_body(
      "{\"type\":\"message\",\"channel\":\"C1\",\"user\":\"U2\",\"text\":\"hi\",\"ts\":\"3.6\"}",
      bot_authorization,
    )
  let recording = fn(label) {
    app.unverified() |> app.on_event(fn(_, _) { log.record(label) })
  }
  assert !ran(recording("own: bot user"), from_bot, "own: bot user")
  assert !ran(recording("own: app id"), from_app, "own: app id")
  assert ran(recording("own: joined"), joined, "own: joined")
  assert ran(recording("own: person"), from_person, "own: person")
  assert ran(
    recording("own: kept") |> app.include_own_events,
    from_bot,
    "own: kept",
  )
}

pub fn own_events_are_skipped_over_socket_mode_test() {
  let frame =
    "{\"envelope_id\":\"e1\",\"type\":\"events_api\",\"accepts_response_payload\":false,\"payload\":"
    <> event_body(
      "{\"type\":\"message\",\"channel\":\"C1\",\"user\":\"UBOT\",\"text\":\"hi\",\"ts\":\"4.4\"}",
      bot_authorization,
    )
    <> "}"
  let my_app =
    app.unverified() |> app.on_event(fn(_, _) { log.record("socket: own") })
  let assert app.Send(frame: "{\"envelope_id\":\"e1\"}", after:) =
    app.handle_socket(my_app, frame)
  after()
  assert !list.contains(log.recorded(), "socket: own")
}

pub fn dispatch_skips_own_events_too_test() {
  let assert Ok(incoming) =
    app.parse_request(signed(
      event_body(
        "{\"type\":\"message\",\"channel\":\"C1\",\"user\":\"UBOT\",\"text\":\"hi\",\"ts\":\"5.5\"}",
        bot_authorization,
      ),
      "application/json",
    ))
  let assert app.Events(own: True, ..) = incoming
  let my_app =
    app.unverified() |> app.on_event(fn(_, _) { log.record("dispatch: own") })
  let ack = app.dispatch(my_app, incoming, None)
  let assert app.Send(after:, ..) =
    app.handle_socket(
      app.unverified() |> app.command("/x", fn(_) { ack }),
      "{\"envelope_id\":\"e2\",\"type\":\"slash_commands\",\"accepts_response_payload\":false,\"payload\":{\"token\":\"t\",\"team_id\":\"T1\",\"team_domain\":\"d\",\"channel_id\":\"C1\",\"channel_name\":\"c\",\"user_id\":\"U1\",\"user_name\":\"u\",\"command\":\"/x\",\"text\":\"\",\"response_url\":\"https://x\",\"trigger_id\":\"t\"}}",
    )
  after()
  assert !list.contains(log.recorded(), "dispatch: own")
}
