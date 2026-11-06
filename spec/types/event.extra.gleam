import gleam/json

/// Parses a request URL body, or the `payload` of a Socket Mode `events_api`
/// message, into an `Envelope`.
pub fn parse(body: String) -> Result(Envelope, json.DecodeError) {
  json.parse(body, envelope_decoder())
}

/// Parses a bare inner event, for example the `event` field of an envelope
/// that you already took apart.
pub fn parse_inner(body: String) -> Result(Event, json.DecodeError) {
  json.parse(body, event_decoder())
}
