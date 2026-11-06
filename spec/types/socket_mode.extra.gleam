import gleam/json
import gleam/option.{type Option}

/// The frame that acknowledges a message.
pub fn ack(envelope_id: String) -> String {
  json.object([#("envelope_id", json.string(envelope_id))]) |> json.to_string
}

/// The frame that acknowledges a message with a response payload, for
/// messages where `accepts_response_payload` is true (for example a slash
/// command reply or a view submission `response_action`).
pub fn ack_with(envelope_id: String, payload: json.Json) -> String {
  json.object([
    #("envelope_id", json.string(envelope_id)),
    #("payload", payload),
  ])
  |> json.to_string
}

/// Decodes one WebSocket text frame.
pub fn parse(frame: String) -> Result(SocketMessage, json.DecodeError) {
  json.parse(frame, socket_message_decoder())
}

/// The envelope id of a message that needs acknowledging, if any.
pub fn envelope_id(message: SocketMessage) -> Option(String) {
  case message {
    EventsApi(envelope_id:, ..)
    | Interactive(envelope_id:, ..)
    | SlashCommands(envelope_id:, ..) -> option.Some(envelope_id)
    _ -> option.None
  }
}
