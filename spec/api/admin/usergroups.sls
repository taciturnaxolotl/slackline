//// Admin API methods for managing user groups and IDP groups across an org.
module slackline/api/admin/usergroups

/// A user that could not be added to a user group.
record InvalidUsergroupUser {
  user_id: String
  /// Why the user was rejected, such as `guest_user`.
  reason: String?
}

/// A default channel of an IDP group.
record UsergroupChannel {
  id: String
  name: String?
  team_id: String?
  /// Member count, when `include_num_members` was set.
  num_members: Int?
  /// Whether the channel details are redacted for the caller.
  is_redacted: Bool?
}

method admin.usergroups.addChannels {
  response Nil
}

method admin.usergroups.addTeams {
  response Nil
}

method admin.usergroups.addUsers {
  response {
    /// Users that could not be added. Omitted when every user was added.
    invalid_users: List(InvalidUsergroupUser)?
  }
}

method admin.usergroups.create {
  response {
    /// The new user group.
    subteam: Usergroup
  }
}

method admin.usergroups.fetch {
  response {
    subteam: Usergroup
  }
}

method admin.usergroups.update {
  response {
    /// The updated user group.
    subteam: Usergroup
  }
}

method admin.usergroups.listChannels {
  response {
    channels: List(UsergroupChannel)?
  }
}

method admin.usergroups.removeChannels {
  response Nil
}

method admin.usergroups.removeTeams {
  response Nil
}

method admin.usergroups.removeUsers {
  response Nil
}

method admin.usergroups.uploadUsers {
  response {
    /// How many users were added.
    successful_user_count: Int?
    /// Users that could not be added.
    invalid_users: List(InvalidUsergroupUser)?
  }
}
