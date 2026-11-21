import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/http
import gleam/int
import gleam/option.{None}
import gleam/string
import slackline
import slackline/value

/// Identifies `logs` in the `slackline.Call` it returns.
pub type Logs

/// The type of the unauthenticated calls, `schemas` and `actions`.
pub type Reference

const base = "https://api.slack.com/audit/v1/"

/// Audit events, newest first. Narrow them with the setters below, and page
/// with `httpc.fold_pages` and `response_metadata`.
pub fn logs() -> slackline.Call(Logs, AuditLogs) {
  slackline.rest(http.Get, base <> "logs", None, audit_logs_decoder())
}

/// Only events at or before this Unix time.
pub fn latest(call: slackline.Call(Logs, r), latest: Int) -> slackline.Call(Logs, r) {
  slackline.with_param(call, "latest", int.to_string(latest))
}

/// Only events at or after this Unix time. There is no data before March 2018.
pub fn oldest(call: slackline.Call(Logs, r), oldest: Int) -> slackline.Call(Logs, r) {
  slackline.with_param(call, "oldest", int.to_string(oldest))
}

/// How many events to return, at most 9999. Slack may return more when
/// several share a timestamp.
pub fn limit(call: slackline.Call(Logs, r), limit: Int) -> slackline.Call(Logs, r) {
  slackline.with_param(call, "limit", int.to_string(limit))
}

/// Only these actions (at most 30), such as `user_login`.
pub fn action(
  call: slackline.Call(Logs, r),
  actions: List(String),
) -> slackline.Call(Logs, r) {
  slackline.with_param(call, "action", string.join(actions, ","))
}

/// Only events by this user.
pub fn actor(call: slackline.Call(Logs, r), user: String) -> slackline.Call(Logs, r) {
  slackline.with_param(call, "actor", user)
}

/// Only events on this channel, workspace, organization, file or other ID.
pub fn entity(call: slackline.Call(Logs, r), id: String) -> slackline.Call(Logs, r) {
  slackline.with_param(call, "entity", id)
}

/// The shape of each kind of entity, as json.
pub fn schemas() -> slackline.Call(Reference, List(value.Value)) {
  slackline.rest(
    http.Get,
    base <> "schemas",
    None,
    decode.at(["schemas"], decode.list(value.decoder())),
  )
  |> slackline.without_token
}

/// Every action name, keyed by the kind of entity it applies to.
pub fn actions() -> slackline.Call(Reference, Dict(String, List(String))) {
  slackline.rest(
    http.Get,
    base <> "actions",
    None,
    decode.at(["actions"], decode.dict(decode.string, decode.list(decode.string))),
  )
  |> slackline.without_token
}
