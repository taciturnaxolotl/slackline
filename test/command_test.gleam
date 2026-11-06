import gleam/dynamic
import gleam/dynamic/decode
import gleam/list
import gleam/option.{None, Some}
import gleam/uri
import slackline/command

/// The payload example from the slash command guide, as sent on the wire.
const body =
  "token=gIkuvaNzQIHg97ATvDxqgjtO&team_id=T0001&team_domain=example&enterprise_id=E0001&enterprise_name=Globular%20Construct%20Inc&channel_id=C2147483705&channel_name=test&user_id=U2147483697&user_name=Steve&command=/weather&text=94070&response_url=https://hooks.slack.com/commands/1234/5678&trigger_id=13345224609.738474920.8088930838d88f008e0&api_app_id=A123456"

pub fn docs_example_test() {
  let assert Ok(fields) = uri.parse_query(body)
  let input =
    fields
    |> list.map(fn(pair) { #(dynamic.string(pair.0), dynamic.string(pair.1)) })
    |> dynamic.properties
  let assert Ok(cmd) = decode.run(input, command.slash_command_decoder())
  let assert "/weather" = cmd.command
  let assert Some("94070") = cmd.text
  let assert "U2147483697" = cmd.user_id
  let assert Some("Globular Construct Inc") = cmd.enterprise_name
  let assert Some("A123456") = cmd.api_app_id
  let assert None = cmd.is_enterprise_install
  let assert None = cmd.ssl_check
}

pub fn from_form_test() {
  let assert Ok(fields) = uri.parse_query(body)
  let assert Ok(cmd) = command.parse(fields)
  let assert Some("T0001") = cmd.team_id
}

pub fn minimal_command_test() {
  let assert Ok(cmd) =
    command.parse([
      #("command", "/x"),
      #("user_id", "U1"),
      #("channel_id", "C1"),
      #("response_url", "https://hooks.slack.com/commands/T1/1/abc"),
      #("trigger_id", "1.2.abc"),
    ])
  let assert None = cmd.enterprise_id
}

pub fn ssl_check_test() {
  // SSL checks carry only `ssl_check` and `token`, so they do not decode as a
  // command; detect them on the raw form fields instead.
  let assert Error(_) = command.parse([#("ssl_check", "1"), #("token", "abc")])
}
