//// Socket Mode: receive events, interactions and slash commands over a
//// WebSocket instead of a public request url.
////
//// Open a connection url with `slackline/api/apps.connections_open` and an
//// app-level (`xapp-`) token. Connect a WebSocket client to it. Decode each
//// text frame with `socket_mode.parse`. Answer every message that has an
//// `envelope_id` within three seconds with `socket_mode.ack(envelope_id)`.
//// `slackline/app.handle_socket` does all of that for an app. See
//// <https://docs.slack.dev/apis/events-api/using-socket-mode>.
module slackline/socket_mode

/// Diagnostic details Slack attaches to `hello` and `disconnect` messages.
record DebugInfo {
  host: String?
  started: String?
  build_number: Int?
  /// Roughly how long, in seconds, until Slack refreshes this connection.
  approximate_connection_time: Int?
}

record ConnectionInfo {
  app_id: String?
}

/// Why Slack is closing a connection.
enum DisconnectReason {
  /// The connection will be closed in about ten seconds. Open a new one.
  warning
  /// Slack is about to refresh the connection. Open a new one.
  refresh_requested
  /// Socket Mode was turned off for the app.
  link_disabled
  .. UnknownDisconnectReason
}

/// One message received over a Socket Mode WebSocket.
union SocketMessage tag "type" {
  /// Sent when a connection is ready.
  hello Hello {
    num_connections: Int?
    connection_info: ConnectionInfo?
    debug_info: DebugInfo?
  }
  /// Slack is about to close this connection.
  disconnect Disconnect {
    reason: DisconnectReason
    debug_info: DebugInfo?
  }
  /// An Events API delivery. Acknowledge it with `ack`.
  events_api EventsApi {
    envelope_id: String
    payload: Envelope
    accepts_response_payload: Bool?
    retry_attempt: Int?
    retry_reason: String?
  }
  /// An interactivity payload (block actions, view submissions, shortcuts,
  /// ...). Acknowledge it with `ack` or `ack_with`.
  interactive Interactive {
    envelope_id: String
    payload: Interaction
    accepts_response_payload: Bool?
  }
  /// A slash command. Acknowledge it with `ack` or `ack_with`.
  slash_commands SlashCommands {
    envelope_id: String
    payload: SlashCommand
    accepts_response_payload: Bool?
  }
  .. UnknownSocketMessage
}
