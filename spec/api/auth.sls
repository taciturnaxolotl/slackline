//// Slack Web API methods for checking and revoking tokens.
module slackline/api/auth

/// A workspace an org-wide app has been approved for, from `auth.teams.list`.
record AuthTeam {
  /// The workspace ID.
  id: String
  /// The workspace name.
  name: String?
  /// URIs for the images that represent the workspace, present when `include_icon` is set.
  icon: Dict(Value)?
}

method auth.revoke {
  response {
    /// Whether the token was actually revoked. `false` in testing mode.
    revoked: Bool?
  }
}

method auth.teams.list {
  response {
    /// The workspaces the app has been approved for.
    teams: List(AuthTeam)?
    response_metadata: ResponseMetadata?
  }
}

method auth.test {
  response {
    /// The URL of the workspace.
    url: String
    /// The workspace name.
    team: String
    /// The name of the user (or bot user) the token belongs to.
    user: String
    /// The workspace ID.
    team_id: String
    /// The ID of the user (or bot user) the token belongs to.
    user_id: String
    /// The bot ID, present for bot tokens.
    bot_id: String?
    /// The enterprise organization ID, present for org installations.
    enterprise_id: String?
    /// Whether the app is installed on an entire organization.
    is_enterprise_install: Bool?
  }
}
