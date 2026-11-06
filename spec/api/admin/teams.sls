//// Admin API methods for creating and configuring workspaces in an org.
module slackline/api/admin/teams

/// Who can find and join a workspace.
enum TeamDiscoverability {
  open
  closed
  invite_only
  unlisted
  hidden
  .. UnknownTeamDiscoverability
}

/// The primary owner of a workspace.
record TeamPrimaryOwner {
  user_id: String?
  email: String?
}

/// A workspace in the org, as listed by `admin.teams.list`.
record OrgTeam {
  id: String
  name: String?
  discoverability: TeamDiscoverability?
  primary_owner: TeamPrimaryOwner?
  team_url: String?
}

/// Settings of a workspace.
record TeamSettings {
  id: String
  name: String?
  domain: String?
  email_domain: String?
  # The docs only describe this field as an array.
  /// The workspace icon.
  icon: Value?
  enterprise_id: String?
  enterprise_name: String?
  # The docs only describe this field as an array.
  /// The default channels of the workspace.
  default_channels: Value?
}

method admin.teams.admins.list {
  response {
    /// IDs of the workspace admins.
    admin_ids: List(String)?
    response_metadata: ResponseMetadata?
  }
}

method admin.teams.owners.list {
  response {
    /// IDs of the workspace owners.
    owner_ids: List(String)?
    response_metadata: ResponseMetadata?
  }
}

method admin.teams.create {
  response {
    /// ID of the new workspace.
    team: String
  }
}

method admin.teams.list {
  response {
    teams: List(OrgTeam)?
    response_metadata: ResponseMetadata?
  }
}

method admin.teams.settings.info {
  response {
    team: TeamSettings
  }
}

method admin.teams.settings.setDefaultChannels {
  response Nil
}

method admin.teams.settings.setDescription {
  response Nil
}

method admin.teams.settings.setDiscoverability {
  args {
    discoverability: TeamDiscoverability
  }
  response Nil
}

method admin.teams.settings.setIcon {
  response Nil
}

method admin.teams.settings.setName {
  response Nil
}
