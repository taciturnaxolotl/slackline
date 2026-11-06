//// Admin apps: approve, restrict and configure apps across an Enterprise organization.
module slackline/api/admin/apps

/// Who last approved or restricted an app.
record AppResolver {
  actor_id: String?
  /// Such as `user`.
  actor_type: String?
}

/// An approved or restricted app, from `admin.apps.approved.list` or `admin.apps.restricted.list`.
record ResolvedApp {
  app: AppDetails?
  scopes: List(AppScope)?
  /// When the resolution was last updated (Unix time).
  date_updated: Int?
  last_resolved_by: AppResolver?
}

/// Whether a workflow builder can delegate their auth for end-user runs.
enum WorkflowAuthStrategy {
  builder_choice
  end_user_only
  .. UnknownWorkflowAuthStrategy
}

/// The app-level override for rich link previews.
enum RichLinkPreviewType {
  all_details
  limited_details
  no_preview
  default_to_global_setting
  .. UnknownRichLinkPreviewType
}

/// Allowed URLs and emails for connector authorization.
record DomainRestrictions {
  urls: List(String)?
  emails: List(String)?
}

/// An app's configuration, from `admin.apps.config.lookup`.
record AppConfig {
  app_id: String
  workflow_auth_strategy: WorkflowAuthStrategy?
  /// Null when not set.
  rich_link_preview_type: RichLinkPreviewType?
  /// Domain restrictions for the app, if set.
  domain_restrictions: DomainRestrictions?
}

/// Who can access an app or MCP server.
enum AppPermissionType {
  everyone
  named_entities
  named_entities_exclude
  no_one
  .. UnknownAppPermissionType
}

/// Where an app can be used in channels.
enum ChannelRestrictionMode {
  all_channels
  specific_channels
  all_channels_except
  "no_one" as ChannelRestrictionNoOne
  .. UnknownChannelRestrictionMode
}

/// An app's access permissions.
record AppPermissions {
  permission_type: AppPermissionType?
  /// Users granted (or excluded from) access with `named_entities` permissions.
  user_ids: List(String)?
  /// Usergroups granted (or excluded from) access with `named_entities` permissions.
  usergroup_ids: List(String)?
  /// `no_one` when `permission_type` is `no_one`.
  channel_restriction_mode: ChannelRestrictionMode?
  /// Channels the restriction mode applies to.
  channel_ids: List(String)?
}

method admin.apps.activities.list {
  args {
    min_log_level: ActivityLogLevel
    source: ActivitySource
    component_type: ActivityComponentType
    sort_direction: SortDirection
  }
  response {
    activities: List(AppActivity)?
    response_metadata: ResponseMetadata?
  }
}

method admin.apps.approve {
  args {
    user_scopes: List(String)? comma
    bot_scopes: List(String)? comma
  }
  response Nil
}

method admin.apps.approved.list {
  response {
    approved_apps: List(ResolvedApp)?
    response_metadata: ResponseMetadata?
  }
}

method admin.apps.clearResolution {
  response Nil
}

method admin.apps.config.lookup {
  response {
    configs: List(AppConfig)?
  }
}

method admin.apps.config.set {
  args {
    domain_restrictions: DomainRestrictions? json
    workflow_auth_strategy: WorkflowAuthStrategy
    rich_link_preview_type: RichLinkPreviewType
  }
  response Nil
}

method admin.apps.mcp.servers.permissions.set {
  args {
    permission_type: AppPermissionType
  }
  response Nil
}

method admin.apps.permissions.add {
  response AppPermissions
}

method admin.apps.permissions.list {
  response AppPermissions
}

method admin.apps.permissions.remove {
  response AppPermissions
}

method admin.apps.permissions.set {
  args {
    permission_type: AppPermissionType
    channel_restriction_mode: ChannelRestrictionMode
  }
  response AppPermissions
}

method admin.apps.requests.cancel {
  response Nil
}

method admin.apps.requests.list {
  response {
    app_requests: List(AppRequest)?
    response_metadata: ResponseMetadata?
  }
}

method admin.apps.restrict {
  response Nil
}

method admin.apps.restricted.list {
  response {
    restricted_apps: List(ResolvedApp)?
    response_metadata: ResponseMetadata?
  }
}

method admin.apps.uninstall {
  args {
    /// IDs of the teams to uninstall from (max 100). With an org-level token, this or `enterprise_id` is required.
    team_ids: List(String)? comma
  }
  response Nil
}

/// Who logged an app activity.
enum ActivitySource {
  slack
  developer
}

/// The kind of app component that logged an activity.
enum ActivityComponentType {
  events_api
  workflows
  functions
  tables
}
