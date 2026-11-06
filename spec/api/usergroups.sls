//// Slack Web API methods for user groups.
module slackline/api/usergroups

method usergroups.create {
  args {
    /// Channel IDs the user group uses as defaults.
    channels: List(String)? comma
    /// Channel IDs the user group can custom add usergroup members to.
    additional_channels: List(String)? comma
  }
  response {
    /// The new user group, including its preferences.
    usergroup: Usergroup?
  }
}

method usergroups.disable {
  args {
    usergroup: String
    team_id: String?
  }
  response {
    /// The disabled user group. Its `date_delete` is non-zero.
    usergroup: Usergroup?
  }
}

method usergroups.enable {
  response {
    /// The enabled user group.
    usergroup: Usergroup?
  }
}

method usergroups.list {
  response {
    /// The user groups, in no particular order.
    usergroups: List(Usergroup)?
  }
}

method usergroups.update {
  args {
    usergroup: String
    team_id: String?
    /// Channel IDs the user group uses as defaults.
    channels: List(String)? comma
    /// Channel IDs the user group can custom add usergroup members to.
    additional_channels: List(String)? comma
  }
  response {
    /// The updated user group.
    usergroup: Usergroup?
  }
}

method usergroups.users.list {
  response {
    /// The IDs of the users in the user group.
    users: List(String)?
  }
}

method usergroups.users.update {
  args {
    /// User IDs that make up the entire new list of users for the user group.
    users: List(String) comma
    /// Channel IDs the user group can custom add usergroup members to.
    additional_channels: List(String)? comma
  }
  response {
    /// The updated user group.
    usergroup: Usergroup?
  }
}
