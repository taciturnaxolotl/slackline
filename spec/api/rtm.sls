//// Slack Web API methods for the legacy Real Time Messaging API.
module slackline/api/rtm

/// The connecting user, from `rtm.connect`.
record RtmSelf {
  /// The user ID.
  id: String
  /// The user name.
  name: String?
}

/// Brief information about the workspace, from `rtm.connect`.
record RtmTeam {
  /// The workspace ID.
  id: String
  /// The workspace name.
  name: String?
  /// The workspace domain.
  domain: String?
  /// The Enterprise organization ID, if the workspace is part of one.
  enterprise_id: String?
  /// The Enterprise organization name, if the workspace is part of one.
  enterprise_name: String?
}

/// The response from `rtm.connect`, also returned by `rtm.start` since September 27, 2022.
record RtmConnectResponse {
  /// The WebSocket Message Server URL. Valid for 30 seconds.
  url: String?
  /// The connecting user.
  self: RtmSelf?
  /// The workspace.
  team: RtmTeam?
}

method rtm.connect {
  response RtmConnectResponse
}

method rtm.start {
  response RtmConnectResponse
}
