//// Admin analytics: Enterprise member and public channel analytics, and message activity.
module slackline/api/admin/analytics

/// One line of a decompressed `member` analytics file from `admin.analytics.getFile`.
record MemberAnalytics {
  /// The date this row of data is representative of.
  date: String?
  /// Unique ID of the involved Enterprise organization.
  enterprise_id: String?
  /// The canonical, organization-wide user ID this row concerns.
  user_id: String?
  /// The email address of record for the same user.
  email_address: String?
  /// Taken from data that a SCIM API custom attribute syncs.
  enterprise_employee_number: String?
  /// User is classified as a guest on the date in the request.
  is_guest: Bool?
  /// User is a billable monthly active user. Only accurate for invoiced customers.
  is_billable_seat: Bool?
  /// User posted a message or read at least one channel or DM on the date.
  is_active: Bool?
  /// Active in the Slack iOS app.
  is_active_ios: Bool?
  /// Active in the Slack Android app.
  is_active_android: Bool?
  /// Active in the Slack desktop app.
  is_active_desktop: Bool?
  /// Total reactions added by the user on the date. Not de-duplicated by message.
  reactions_added_count: Int?
  /// Total messages posted by the user on the date, in all conversation types.
  messages_posted_count: Int?
  /// Messages posted in public and private channels, not including DMs.
  channel_messages_posted_count: Int?
  /// Total files uploaded by the user on the date.
  files_added_count: Int?
  /// The member interacted with a Slack app or custom integration on the date.
  is_active_apps: Bool?
  /// The member interacted with at least one workflow on the date.
  is_active_workflows: Bool?
  /// The member read or posted in a conversation shared with an external workspace.
  is_active_slack_connect: Bool?
  /// Total calls made or joined on the date, including huddles and third-party calls.
  total_calls_count: Int?
  /// Slack calls made or joined on the date.
  slack_calls_count: Int?
  /// Slack huddles made or joined on the date.
  slack_huddles_count: Int?
  /// Searches the user performed on the date.
  search_count: Int?
  /// When the member first signed in to any workspace in the org (Unix time).
  date_claimed: Int?
}

/// A workspace referenced by public channel analytics.
record AnalyticsTeam {
  team_id: String?
  name: String?
}

/// An external organization a channel is shared with.
record AnalyticsExternalOrganization {
  name: String?
  domain: String?
}

/// One line of a decompressed `public_channel` analytics file from `admin.analytics.getFile`.
record PublicChannelAnalytics {
  /// Unique ID of the Enterprise organization, `"0"` outside an Enterprise organization.
  enterprise_id: String?
  /// Unique ID of the team.
  team_id: String?
  /// The workspace that created this public channel.
  originating_team: AnalyticsTeam?
  /// The channel this row concerns.
  channel_id: String?
  /// `single_workspace_channel`, `multi_workspace_channel` or `org_wide_channel`.
  channel_type: String?
  /// `public` or `private`. Only public channel analytics are available.
  visibility: String?
  /// Workspaces in the same organization this channel is shared with.
  shared_with: List(AnalyticsTeam)?
  /// Whether the channel is shared with workspaces outside this organization.
  is_shared_externally: Bool?
  /// External organizations this channel is shared with.
  externally_shared_with_organizations: List(AnalyticsExternalOrganization)?
  /// When the channel was created (Unix time).
  date_created: Int?
  /// When the channel last had a message posted in it (Unix time).
  date_last_active: Int?
  /// Full members and guests.
  total_members_count: Int?
  /// People with a full member account.
  full_members_count: Int?
  /// People with a guest account.
  guest_member_count: Int?
  /// Messages posted on the day, including from apps and integrations.
  messages_posted_count: Int?
  /// Messages posted by human members and guests on the day.
  messages_posted_by_members_count: Int?
  /// Unique human users who posted on the day.
  members_who_posted_count: Int?
  /// Unique human users who read a message on the day.
  members_who_viewed_count: Int?
  /// Reactions left by human users on the day.
  reactions_added_count: Int?
  /// The day in question.
  date: String?
}

/// One line of a decompressed `metadata_only` public channel file from `admin.analytics.getFile`.
record PublicChannelMetadata {
  /// The channel's unique identifier.
  channel_id: String?
  /// The latest name of the channel.
  name: String?
  /// The latest channel topic.
  topic: String?
  /// A longer description about the purpose of the channel.
  description: String?
  /// The date these details are current as of.
  date: String?
}

/// Unique views of a message by client.
record MessageViewsByClient {
  desktop_views_count: Int?
  mobile_views_count: Int?
  web_views_count: Int?
}

/// Unique engagement with a message from one department.
record MessageDepartmentStats {
  department: String?
  views: Int?
  reactions: Int?
  shares: Int?
  clicks: Int?
}

/// Unique engagement with a message from one workspace.
record MessageOrgStats {
  team_id: String?
  views: Int?
  reactions: Int?
  shares: Int?
  clicks: Int?
}

/// Activity metrics for one message.
record MessageActivity {
  channel_id: String?
  /// The message timestamp.
  timestamp: String?
  unique_user_reactions_count: Int?
  unique_user_shares_count: Int?
  unique_user_views_count: Int?
  unique_user_clicks_count: Int?
  unique_views_client: MessageViewsByClient?
  unique_stats_by_department: List(MessageDepartmentStats)?
  unique_stats_by_org: List(MessageOrgStats)?
}

/// A reaction count on a message from `admin.analytics.messages.metadata`.
record MessageMetadataReaction {
  /// Name of the reaction emoji.
  name: String
  /// Number of times this reaction was used.
  count: Int?
}

/// File metadata on a message from `admin.analytics.messages.metadata`.
record MessageMetadataFile {
  /// Encoded file ID.
  id: String
  /// Unix timestamp when the file was created.
  created: Int?
  /// Unix timestamp of the file.
  timestamp: Int?
  mimetype: String?
  filetype: String?
  subtype: String?
  pretty_type: String?
  is_external: Bool?
  external_type: String?
  is_public: Bool?
  public_url_shared: Bool?
  display_as_bot: Bool?
  /// Duration in milliseconds for media files.
  duration_ms: Int?
  media_display_type: String?
}

/// Message metadata from `admin.analytics.messages.metadata`.
record MessageMetadataEntry {
  /// Message type.
  type: String?
  /// Timestamp of the message.
  ts: String
  /// Encoded ID of the user who authored the message.
  user_id: String?
  /// Message subtype, such as `bot_message` or `channel_join`.
  subtype: String?
  /// Timestamp of the root message if this is a threaded reply.
  thread_ts: String?
  display_as_bot: Bool?
  client_msg_id: String?
  /// Number of characters in the message text.
  text_character_count: Int?
  reactions: List(MessageMetadataReaction)?
  files: List(MessageMetadataFile)?
}

method admin.analytics.getFile {
  args {
    /// Date to retrieve the analytics data for, as `YYYY-MM-DD` in UTC. Required unless `metadata_only` is true.
    date: String?
    type: AnalyticsFileType
  }
}

method admin.analytics.messages.activity {
  response {
    message_activities: List(MessageActivity)?
    response_metadata: ResponseMetadata?
  }
}

method admin.analytics.messages.metadata {
  args {
    /// Maximum number of messages to return. Mentioned in the pagination example, not in the arguments list.
    limit: Int?
  }
  response {
    messages: List(MessageMetadataEntry)?
    response_metadata: ResponseMetadata?
  }
}

/// Which analytics file to fetch.
enum AnalyticsFileType {
  member
  public_channel
}
