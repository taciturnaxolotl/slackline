//// Slash commands: the payload Slack sends to a command's Request URL.
////
//// Slack sends it as `application/x-www-form-urlencoded`. Parse the body
//// with `uri.parse_query` and pass the pairs to `parse`.
////
//// Respond with an empty 200, plain text, or a `slackline/interaction.ResponseMessage`.
//// See <https://docs.slack.dev/interactivity/implementing-slash-commands>.
module slackline/command

/// A slash command invocation.
/// <https://docs.slack.dev/interactivity/implementing-slash-commands#command_payload_descriptions>
record SlashCommand {
  /// (Deprecated) A verification token. Verify requests with the signing secret instead.
  token: String?
  /// The command that was entered, for example `/weather`.
  command: String
  /// The part of the slash command after the command itself. Empty when nothing was typed.
  text: String?
  /// A temporary webhook URL for message responses.
  response_url: String
  /// A short-lived ID that allows the app to open a modal.
  trigger_id: String
  /// The ID of the user who triggered the command.
  user_id: String
  /// (Deprecated) The plain text name of the user. Use `user_id` instead.
  user_name: String?
  /// The workspace the command was invoked in.
  team_id: String?
  /// The slack.com subdomain of the workspace.
  team_domain: String?
  /// Present when the workspace is part of an Enterprise organization.
  enterprise_id: String?
  /// Present when the workspace is part of an Enterprise organization.
  enterprise_name: String?
  /// The conversation the command was invoked in.
  channel_id: String
  /// The name of that conversation.
  channel_name: String?
  /// Your app's unique identifier.
  api_app_id: String?
  /// `"true"` or `"false"`: whether the app is installed at the org level.
  is_enterprise_install: String?
  /// `"1"` on SSL certificate check requests. Acknowledge and ignore those requests.
  ssl_check: String?
}
