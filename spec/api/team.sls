//// Slack Web API methods for workspace information, logs, billing and profile fields.
module slackline/api/team

/// Page-based paging details.
record TeamPaging {
  /// The number of items returned.
  count: Int?
  /// The total number of items.
  total: Int?
  /// The page of results returned.
  page: Int?
  /// The total number of pages.
  pages: Int?
}

/// Access by one user from one IP address and user agent combination.
record AccessLog {
  /// The ID of the user who accessed Slack.
  user_id: String
  /// The name of the user who accessed Slack.
  username: String?
  /// Unix timestamp of the first access for this combination.
  date_first: Int?
  /// Unix timestamp of the most recent access for this combination.
  date_last: Int?
  /// The total number of accesses for this combination.
  count: Int?
  /// The IP address of the device used.
  ip: String?
  /// The user agent of the browser or client application.
  user_agent: String?
  /// Best guess at the internet service provider owning the IP address.
  isp: String?
  /// Best guess at the country the access came from.
  country: String?
  /// Best guess at the region the access came from.
  region: String?
}

/// Billing information for one user.
record BillableInfo {
  /// Whether the user is billable under Slack's Fair Billing policy.
  billing_active: Bool?
}

/// A workspace's billing plan.
enum BillingPlan {
  /// Free plan.
  "free" as FreePlan
  /// Pro plan.
  "std" as StdPlan
  /// Business+ plan.
  "plus" as PlusPlan
  /// Enterprise plan.
  "enterprise" as EnterprisePlan
  /// Enterprise Compliance Select plan.
  "compliance" as CompliancePlan
  .. UnknownBillingPlan
}

/// A workspace connected to an external organization.
record ConnectedWorkspace {
  /// The workspace ID.
  workspace_id: String?
  /// The workspace name.
  workspace_name: String?
}

# The docs example shows a single object, so the decoder accepts both forms.
/// The connected workspaces of an external organization: one object or a list.
oneof ConnectedWorkspaces {
  ManyConnectedWorkspaces(List(ConnectedWorkspace))
  OneConnectedWorkspace(ConnectedWorkspace)
}

/// An entry in an ownership breakdown.
record OwnershipDetail {
  /// The owning team.
  team_id: String?
  /// The number of items it owns.
  count: Int?
}

/// Counts of shared items, such as canvases or lists, with an external organization.
record SharedItemCounts {
  /// The total number of items.
  total_count: Int?
  /// Who owns the items.
  ownership_details: List(OwnershipDetail)?
}

/// The Slack Connect status of an external organization.
enum ConnectionStatus {
  "CONNECTED" as Connected
  "DISCONNECTED" as Disconnected
  "BLOCKED" as Blocked
  "IN_REVIEW" as InReview
  .. UnknownConnectionStatus
}

/// An external organization connected through Slack Connect.
record ExternalOrganization {
  /// The organization's team ID.
  team_id: String
  /// The organization's name.
  team_name: String?
  /// The organization's domain.
  team_domain: String?
  /// The number of shared public channels.
  public_channel_count: Int?
  /// The number of shared private channels.
  private_channel_count: Int?
  /// The number of shared direct messages.
  im_channel_count: Int?
  /// The number of shared group direct messages.
  mpim_channel_count: Int?
  /// Your workspaces connected to this organization.
  connected_workspaces: ConnectedWorkspaces?
  /// Slack Connect preference overrides for this organization.
  slack_connect_prefs: Value?
  /// The connection status.
  connection_status: ConnectionStatus?
  /// Unix timestamp of the last activity.
  last_active_timestamp: Int?
  /// Whether the organization is sponsored.
  is_sponsored: Bool?
  /// Shared canvases.
  canvas: SharedItemCounts?
  /// Shared lists.
  lists: SharedItemCounts?
}

/// The ID of the service an integration log refers to, as a number or a string.
oneof IntegrationServiceId {
  IntegrationServiceIdString(String)
  IntegrationServiceIdInt(Int)
}

/// The kind of change an integration log records.
enum IntegrationChangeType {
  "added" as IntegrationAdded
  "removed" as IntegrationRemoved
  "enabled" as IntegrationEnabled
  "disabled" as IntegrationDisabled
  "expanded" as IntegrationExpanded
  "updated" as IntegrationUpdated
  .. UnknownIntegrationChangeType
}

/// Why an integration was disabled.
enum IntegrationDisableReason {
  /// Manually disabled by a user.
  "user" as DisabledByUser
  /// Rate limits exceeded.
  "rate_limits" as DisabledByRateLimits
  /// Disabled by Slack.
  "slack" as DisabledBySlack
  /// Too many errors.
  "errors" as DisabledByErrors
  /// A system change, such as a channel being archived.
  "system" as DisabledBySystem
  /// An admin, such as a user being deleted.
  "admin" as DisabledByAdmin
  /// The user declined the API terms of service.
  "api_decline" as DisabledByApiDecline
  /// The service was de-authorized.
  "deauth" as DisabledByDeauth
  .. UnknownIntegrationDisableReason
}

/// An integration activity log entry, for either a service or an app.
record IntegrationLog {
  /// The service ID, for services.
  service_id: IntegrationServiceId?
  /// The service type, for services.
  service_type: String?
  /// The app ID, for apps.
  app_id: String?
  /// The app type, for apps.
  app_type: String?
  /// The ID of the user who made the change.
  user_id: String?
  /// The name of the user who made the change.
  user_name: String?
  /// The channel the integration posts to.
  channel: String?
  /// Unix timestamp of the change, as a string.
  date: String?
  /// The kind of change.
  change_type: IntegrationChangeType?
  /// Why the integration was disabled, for `disabled` entries.
  reason: IntegrationDisableReason?
  /// Comma-separated scopes involved.
  scope: String?
  /// `true` when the entry is for an RSS feed.
  rss_feed: Bool?
  /// The kind of RSS feed change.
  rss_feed_change_type: String?
  /// The RSS feed title.
  rss_feed_title: String?
  /// The RSS feed URL.
  rss_feed_url: String?
}

method team.accessLogs {
  args {
    /// End of time range of logs to include in results (inclusive): a Unix timestamp or `now`.
    before: String?
    count: Int?
    page: Int?
  }
  response {
    /// Access log entries.
    logins: List(AccessLog)?
    /// Page-based paging information.
    paging: TeamPaging?
    response_metadata: ResponseMetadata?
  }
}

method team.billableInfo {
  response {
    /// Billing information by user ID.
    billable_info: Dict(BillableInfo)?
    response_metadata: ResponseMetadata?
  }
}

method team.billing.info {
  response {
    /// The workspace's billing plan.
    plan: BillingPlan?
  }
}

method team.externalTeams.disconnect {
  args {
    target_team: String
  }
  response Nil
}

method team.externalTeams.list {
  args {
    /// Filters connected orgs by Slack Connect pref overrides.
    slack_connect_pref_filter: List(String)? comma
    /// Shows connected orgs connected on these workspace IDs.
    workspace_filter: List(String)? comma
    sort_field: ExternalTeamSortField
    sort_direction: SortDirection
    connection_status_filter: ConnectionStatus
  }
  response {
    /// The connected external organizations.
    organizations: List(ExternalOrganization)?
    /// The total number of connected organizations.
    total_count: Int?
    response_metadata: ResponseMetadata?
  }
}

method team.info {
  response {
    /// The workspace.
    team: Team?
  }
}

method team.integrationLogs {
  args {
    count: Int?
    page: Int?
    change_type: IntegrationChangeType
  }
  response {
    /// Integration activity logs.
    logs: List(IntegrationLog)?
    /// Page-based paging information.
    paging: TeamPaging?
  }
}

method team.preferences.list {
  response {
    /// Whether real names are displayed instead of display names.
    display_real_names: Bool?
    /// Who can upload files, such as `disallow_all`, `allow_all`, `type:owner,type:admin` or `type:regular`.
    disable_file_uploads: String?
    /// How many minutes after posting a message can be edited.
    msg_edit_window_mins: Int?
    /// Who can post in the general channel.
    who_can_post_general: String?
  }
}

method team.profile.get {
  args {
    visibility: ProfileVisibility
  }
  response {
    /// The profile field and section definitions.
    profile: TeamProfile?
  }
}

/// How to sort external organizations.
enum ExternalTeamSortField {
  team_name
  last_active_timestamp
  connection_status as SortByConnectionStatus
}

/// Which profile fields to return.
enum ProfileVisibility {
  all as AllFields
  visible as VisibleFields
  hidden as HiddenFields
}
