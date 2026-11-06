//// Conversations: public channels, private channels, direct messages (IMs)
//// and multi-person direct messages (MPIMs).
//// See <https://docs.slack.dev/reference/objects/conversation-object>.
////
//// Different fields are included depending on the type of conversation and
//// the method that returned it, so everything except `id` is optional.
module slackline/conversation

/// A channel-like thing: a public or private channel, a DM or an MPIM.
record Conversation {
  /// The conversation ID.
  id: String
  /// The name, without a leading `#`. Names change, so prefer IDs.
  name: String?
  /// The normalized version of the channel name.
  name_normalized: String?
  /// Whether the conversation is a channel. Private channels created before
  /// March 2021 return `false` here and `true` for `is_group`.
  is_channel: Bool?
  /// Whether the conversation is a private channel created before March 2021.
  is_group: Bool?
  /// Whether the conversation is a direct message.
  is_im: Bool?
  /// Whether the conversation is a multi-person direct message.
  is_mpim: Bool?
  /// Whether the conversation is private.
  is_private: Bool?
  /// Unix timestamp, in seconds, of when the conversation was created.
  created: Int?
  /// The ID of the member that created the conversation.
  creator: String?
  /// Whether the conversation is archived.
  is_archived: Bool?
  /// Whether the channel is the workspace's "general" channel.
  is_general: Bool?
  /// Whether the channel was previously shared and then disconnected.
  unlinked: Int?
  /// Whether the conversation is shared between multiple workspaces.
  is_shared: Bool?
  /// Whether the conversation is a Slack Connect channel with another org.
  is_ext_shared: Bool?
  /// Whether the conversation is shared between workspaces of one Enterprise org.
  is_org_shared: Bool?
  /// Whether the conversation is waiting for approval to become externally shared.
  is_pending_ext_shared: Bool?
  /// Whether the channel is shared across an entire Enterprise org.
  is_global_shared: Bool?
  /// Whether the channel is shared on an external workspace.
  is_ext_ws_shared: Bool?
  /// Whether the calling user, bot or app is a member.
  is_member: Bool?
  /// Whether a DM or MPIM is open.
  is_open: Bool?
  /// Whether the conversation is frozen (for example a disconnected Slack
  /// Connect channel on the away-team side).
  is_frozen: Bool?
  /// Reason the conversation is frozen.
  frozen_reason: String?
  /// Whether the calling user cannot write to the conversation.
  is_read_only: Bool?
  /// Whether only thread replies can be posted.
  is_thread_only: Bool?
  /// Whether threads are disabled.
  is_non_threadable: Bool?
  /// Whether this is an org-wide default channel.
  is_org_default: Bool?
  /// Whether this is a mandatory channel for all members of the org.
  is_org_mandatory: Bool?
  /// Whether the calling user has starred the conversation.
  is_starred: Bool?
  /// Whether this is a file channel.
  is_file: Bool?
  /// Whether a channel agent is enabled.
  is_channel_agent_enabled: Bool?
  /// Whether the conversation is being migrated.
  is_migrating: Bool?
  /// Whether the private channel has been deleted.
  is_deleted: Bool?
  /// Non-zero timestamp when the channel was moved (Enterprise orgs).
  is_moved: Int?
  /// For DMs: `true` if the other user's account has been disabled.
  is_user_deleted: Bool?
  /// Whether details of this conversation are redacted for the caller.
  is_redacted: Bool?
  /// Whether the conversation has pinned items.
  has_pins: Bool?
  /// Number of pinned items.
  pin_count: Int?
  /// Whether an information barrier applies to this DM.
  has_barrier: Bool?
  /// The ID of the workspace the conversation is within.
  context_team_id: String?
  /// The workspace a channel belongs to, in some admin responses.
  team_id: String?
  /// The Enterprise organization ID.
  enterprise_id: String?
  /// The "host" of a shared channel: a workspace (`T...`) or org (`E...`) ID.
  conversation_host_id: String?
  /// Timestamp, in milliseconds, of when the channel settings were updated.
  updated: Int?
  /// The parent conversation ID, or `null`.
  parent_conversation: String?
  /// ID of the parent group (nested private channels).
  parent_group: String?
  /// IDs of workspaces the channel is shared with.
  shared_team_ids: List(String)?
  /// Internal team IDs for shared channels.
  internal_team_ids: List(String)?
  /// Connected external team IDs.
  connected_team_ids: List(String)?
  /// Pending connected team IDs.
  pending_connected_team_ids: List(String)?
  /// Pending shared workspace IDs.
  pending_shared: List(String)?
  /// The user who accepted a shared channel invite.
  accepted_user: String?
  /// Share details of an MPIM.
  shares: List(ConversationShare)?
  /// The topic of the channel.
  topic: ConversationTopic?
  /// The purpose of the channel.
  purpose: ConversationTopic?
  /// Previous names the channel has had.
  previous_names: List(String)?
  /// Number of members. May be absent for DMs.
  num_members: Int?
  /// IDs of all members, including disabled accounts.
  members: List(String)?
  /// Additional channel properties.
  properties: ConversationProperties?
  /// Custom message retention duration, in days, when one is set.
  retention_duration: Int?
  /// Channel use-case classification.
  use_case: String?
  /// For DMs: the other user's ID.
  user: String?
  /// For DMs and MPIMs: the other participant's user ID.
  target_user_id: String?
  /// Locale setting of the conversation.
  locale: String?
  /// Sort priority in the user's sidebar.
  priority: Float?
  /// Display and guest counts of an MPIM.
  display_counts: DisplayCounts?
  /// Number of timezones across members.
  timezone_count: Int?
  /// Version number of the conversation object.
  version: Int?
  /// Unix timestamp of when the conversation was created (shared channel invites).
  date_created: Int?

  # State for the calling user
  /// `ts` of the last message the calling user has read.
  last_read: String?
  /// The latest message in the conversation. May be `null` or an empty object.
  latest: Message?
  /// Count of visible messages the calling user has yet to read.
  unread_count: Int?
  /// Count of unread messages that matter to the user (excludes joins/leaves).
  unread_count_display: Int?
}

/// The topic or purpose of a conversation.
record ConversationTopic {
  value: String?
  /// The ID of the user who set it, or an empty string.
  creator: String?
  /// Unix timestamp of when it was set, or `0`.
  last_set: Int?
}

/// One share of an MPIM.
record ConversationShare {
  team: String?
  user: String?
  is_active: Bool?
  accepted_user: String?
}

/// Display and guest counts.
record DisplayCounts {
  display_counts: Int?
  guest_counts: Int?
}

/// Additional channel properties.
record ConversationProperties {
  /// Whether `@channel` mentions are restricted.
  at_channel_restricted: Bool?
  /// Whether `@here` mentions are restricted.
  at_here_restricted: Bool?
  /// Which tab in the channel auto opens.
  auto_open_tab_id: String?
  /// Which tab in the channel is the default.
  default_tab_id: String?
  /// The channel canvas.
  canvas: Value?
  /// `workflow_trigger_ids`, `workflow_workflow_ids`, `canvas_ids`, `list_ids`.
  channel_solutions: Value?
  /// Workflows in the channel.
  channel_workflows: List(Value)?
  /// Properties for Slack CRM.
  crm: Value?
  /// Huddle properties.
  huddles: Value?
  /// Whether huddles are restricted.
  huddles_restricted: Bool?
  /// Channel meeting notes properties.
  meeting_notes: Value?
  /// Limit of users in the channel.
  membership_limit: Int?
  /// Who may post in the channel.
  posting_restricted_to: PostingRestriction?
  /// Who may post in threads.
  threads_restricted_to: PostingRestriction?
  /// Salesforce channel properties.
  record_channel: Value?
  /// Whether sharing is disabled.
  sharing_disabled: Bool?
  /// The channel tabs.
  tabs: List(ConversationTab)?
  /// Who can manage a channel agent: `everyone` or `channel_managers`.
  who_can_manage_channel_agent: String?
  /// Workflow properties (`primary_workflow_url`).
  workflow: Value?
}

/// Restricts who may post: by user group, by user type or by user.
record PostingRestriction {
  /// User group IDs.
  subteam: List(String)?
  /// User types, such as `admin` or `ra`.
  type: List(String)?
  /// User IDs.
  user: List(String)?
}

/// A tab in a channel.
record ConversationTab {
  id: String?
  label: String?
  type: ConversationTabType?
  data: Value?
  is_disabled: Bool?
}

/// The kind of a channel tab.
enum ConversationTabType {
  list as ListTab
  canvas
  files
  bookmarks
  folder
  pins
  workflows
  channel_canvas
  record_list
  record_overview
  record_summary
  record_related_list
  salesforce_list_view
  .. UnknownConversationTabType
}
