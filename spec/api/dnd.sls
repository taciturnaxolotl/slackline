//// Do Not Disturb settings (`dnd.*`).
module slackline/api/dnd

/// A user's Do Not Disturb status, as returned by `dnd.teamInfo`.
record DndStatus {
  /// Whether Do Not Disturb is enabled.
  dnd_enabled: Bool?
  /// Unix timestamp of when the next Do Not Disturb period starts.
  next_dnd_start_ts: Int?
  /// Unix timestamp of when the next Do Not Disturb period ends.
  next_dnd_end_ts: Int?
}

/// A user's Do Not Disturb and snooze status. The `snooze_*` fields are only
/// present when the queried user is the current user, and `snooze_endtime`
/// and `snooze_remaining` only when `snooze_enabled` is `true`.
record DndInfo {
  /// Whether Do Not Disturb is enabled.
  dnd_enabled: Bool?
  /// Unix timestamp of when the next Do Not Disturb period starts.
  next_dnd_start_ts: Int?
  /// Unix timestamp of when the next Do Not Disturb period ends.
  next_dnd_end_ts: Int?
  /// Whether snooze is active.
  snooze_enabled: Bool?
  /// Unix timestamp of when the snooze ends.
  snooze_endtime: Int?
  /// Seconds of snooze remaining.
  snooze_remaining: Int?
  /// Whether the snooze has no end. Cannot currently be set to `true`.
  snooze_is_indefinite: Bool?
}

method dnd.endDnd {
  response Nil
}

method dnd.endSnooze {
  response DndInfo
}

method dnd.info {
  response DndInfo
}

method dnd.setSnooze {
  args {
    /// Number of minutes, from now, to snooze until.
    num_minutes: Int
  }
  response DndInfo
}

method dnd.teamInfo {
  args {
    /// Users to fetch Do Not Disturb status for.
    users: List(String) comma
  }
  response {
    /// Do Not Disturb status keyed by user ID.
    users: Dict(DndStatus)?
  }
}
