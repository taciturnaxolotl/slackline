//// Workflows: featured workflows in channels and trigger run permissions.
module slackline/api/workflows

/// Who can run a workflow trigger.
enum TriggerPermissionType {
  everyone
  app_collaborators
  named_entities
  .. UnknownTriggerPermissionType
}

/// A featured workflow trigger.
record FeaturedTrigger {
  /// ID of the trigger.
  id: String
  /// Title of the workflow.
  title: String?
}

/// The featured workflows of one channel.
record ChannelFeaturedWorkflows {
  channel_id: String
  /// The channel's featured triggers.
  triggers: List(FeaturedTrigger)?
}

/// A trigger's permission type and, if applicable, the entities with access.
record TriggerPermissions {
  /// Who can run the trigger.
  permission_type: TriggerPermissionType?
  /// Users with access.
  user_ids: List(String)?
  /// Channels whose members have access.
  channel_ids: List(String)?
  /// Workspaces whose members have access.
  team_ids: List(String)?
  /// Organizations whose members have access.
  org_ids: List(String)?
}

method workflows.featured.add {
  response Nil
}

method workflows.featured.list {
  response {
    /// Featured workflows for each requested channel.
    featured_workflows: List(ChannelFeaturedWorkflows)?
  }
}

method workflows.featured.remove {
  response Nil
}

method workflows.featured.set {
  response Nil
}

method workflows.triggers.permissions.add {
  response TriggerPermissions
}

method workflows.triggers.permissions.list {
  response TriggerPermissions
}

method workflows.triggers.permissions.remove {
  response TriggerPermissions
}

method workflows.triggers.permissions.set {
  args {
    permission_type: TriggerPermissionType
  }
  response TriggerPermissions
}
