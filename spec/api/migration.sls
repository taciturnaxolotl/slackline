//// Slack Web API methods for migrating workspaces into an Enterprise organization.
module slackline/api/migration

method migration.exchange {
  args {
    /// User IDs to map, up to 400 per request.
    users: List(String) comma
  }
  response {
    /// The workspace ID.
    team_id: String?
    /// The Enterprise organization ID.
    enterprise_id: String?
    /// Maps each requested ID to its global ID, or back to the local ID when `to_old` is set.
    user_id_map: Dict(String)?
    /// Requested IDs that are invalid or do not belong to the workspace.
    invalid_user_ids: List(String)?
  }
}
