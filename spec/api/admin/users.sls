//// Admin API methods for managing users, guests and sessions across an org.
module slackline/api/admin/users

/// A user, as listed by `admin.users.list`.
record AdminUser {
  id: String
  email: String?
  is_admin: Bool?
  is_owner: Bool?
  is_primary_owner: Bool?
  /// Whether the user is a multi-channel guest.
  is_restricted: Bool?
  /// Whether the user is a single-channel guest.
  is_ultra_restricted: Bool?
  is_bot: Bool?
  username: String?
  full_name: String?
  is_active: Bool?
  /// When the account was created, in Unix seconds.
  date_created: Int?
  /// When the account was deactivated, in Unix seconds.
  deactivated_ts: Int?
  /// When a guest account expires, in Unix seconds. `0` means never.
  expiration_ts: Int?
  /// IDs of the workspaces the user belongs to.
  workspaces: List(String)?
  has_2fa: Bool?
  has_sso: Bool?
}

/// The expiration details of a guest user.
record GuestExpiration {
  id: String
  email: String?
  is_restricted: Bool?
  is_ultra_restricted: Bool?
  /// When the guest account expires, in Unix seconds. `0` means never.
  expiration_ts: Int?
}

/// A user whose access could not be paused or resumed.
record InvalidAccessUser {
  user_id: String
  /// Why the user was rejected, such as `user_not_frontline_member`.
  reason: String?
}

/// Device details of a session, at creation or most recently.
record SessionDevice {
  /// The type of device for the session.
  device_hardware: String?
  /// The operating system for the device.
  os: String?
  /// The version of the OS.
  os_version: String?
  /// The version of the Slack client, if available.
  slack_client_version: String?
  /// The IP address for the session.
  ip: String?
}

/// An active user session.
record ActiveSession {
  user_id: String
  team_id: String?
  session_id: Int
  /// The most recent version of the session. Missing when the session has
  /// not changed since it was created.
  recent: SessionDevice?
  /// The original version of the session.
  created: SessionDevice?
}

/// The session settings of a user.
record UserSessionSettings {
  user_id: String
  /// Whether the session ends when the desktop app or browser is closed.
  desktop_app_browser_quit: Bool?
  /// The session duration, in seconds.
  duration: Int?
}

method admin.users.access.pause {
  response {
    /// Users that were rejected. Empty when every user was queued.
    invalid_users: List(InvalidAccessUser)?
  }
}

method admin.users.access.resume {
  response {
    /// Users that were rejected. Empty when every user was queued.
    invalid_users: List(InvalidAccessUser)?
  }
}

method admin.users.assign {
  args {
    /// Channel IDs to add the user to in the new workspace.
    channel_ids: List(String)? comma
  }
  response Nil
}

method admin.users.deactivate {
  response Nil
}

method admin.users.getExpiration {
  response {
    user: GuestExpiration
  }
}

method admin.users.invite {
  args {
    /// Channel IDs for this user to join. At least one channel is required.
    channel_ids: List(String) comma
  }
  response Nil
}

method admin.users.list {
  response {
    users: List(AdminUser)?
    response_metadata: ResponseMetadata?
  }
}

method admin.users.remove {
  response Nil
}

method admin.users.session.clearSettings {
  response Nil
}

method admin.users.session.getSettings {
  response {
    /// Settings of users that have active sessions.
    session_settings: List(UserSessionSettings)?
    /// IDs of users with no session settings applied.
    no_settings_applied: List(String)?
  }
}

method admin.users.session.invalidate {
  response Nil
}

method admin.users.session.list {
  response {
    active_sessions: List(ActiveSession)?
    response_metadata: ResponseMetadata?
  }
}

method admin.users.session.reset {
  response Nil
}

method admin.users.session.resetBulk {
  response Nil
}

method admin.users.session.setSettings {
  response Nil
}

method admin.users.setAdmin {
  response Nil
}

method admin.users.setExpiration {
  response Nil
}

method admin.users.setOwner {
  response Nil
}

method admin.users.setRegular {
  response Nil
}

method admin.users.unsupportedVersions.export {
  response Nil
}
