import gleam/dynamic/decode
import gleam/http
import gleam/option.{None}
import slackline

/// The type of calls to the Status API.
pub type StatusApi

const base = "https://slack-status.com/api/v2.0.0/"

/// Slack's current status and every active incident.
pub fn current() -> slackline.Call(StatusApi, CurrentStatus) {
  slackline.rest(http.Get, base <> "current", None, current_status_decoder())
  |> slackline.without_token
}

/// Every past incident, newest first.
pub fn history() -> slackline.Call(StatusApi, List(Incident)) {
  slackline.rest(http.Get, base <> "history", None, decode.list(incident_decoder()))
  |> slackline.without_token
}
