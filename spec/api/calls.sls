//// Slack Web API methods for registering and updating third-party Calls.
module slackline/api/calls

/// A Call participant. Slack requires either `slack_id` or `external_id`, or both.
record CallUser {
  /// The Slack user ID of the participant.
  slack_id: String?
  /// A unique ID created by your app for the participant, when you do not know their Slack ID.
  external_id: String?
  /// The name shown for a participant who is not identified by `slack_id`.
  display_name: String?
  /// The avatar URL shown for a participant who is not identified by `slack_id`.
  avatar_url: String?
}

/// A Call registered with `calls.add`.
record Call {
  /// The Call ID. Use it in a `call` block to post the Call to a channel.
  id: String
  /// Unix timestamp of the Call start time.
  date_start: Int?
  /// Unix timestamp of the Call end time, once it has ended.
  date_end: Int?
  /// The ID supplied by the third-party Call provider, unique across all its Calls.
  external_unique_id: String?
  /// The URL a client uses to join the Call.
  join_url: String?
  /// The URL Slack clients use to launch the third-party Call app directly.
  desktop_app_join_url: String?
  /// A human-readable ID supplied by the Call provider.
  external_display_id: String?
  /// The name of the Call.
  title: String?
  /// The Call participants.
  users: List(CallUser)?
}

method calls.add {
  args {
    /// The list of users to register as participants in the Call.
    users: List(CallUser) json
  }
  response {
    /// The registered Call.
    call: Call?
  }
}

method calls.end {
  response Nil
}

method calls.info {
  response {
    /// The Call.
    call: Call?
  }
}

method calls.participants.add {
  args {
    /// The list of users to add as participants in the Call.
    users: List(CallUser) json
  }
  response Nil
}

method calls.participants.remove {
  args {
    /// The list of users to remove as participants in the Call.
    users: List(CallUser) json
  }
  response Nil
}

method calls.update {
  response {
    /// The updated Call.
    call: Call?
  }
}
