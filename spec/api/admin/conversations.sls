//// Admin conversations: manage channels across an Enterprise organization.
module slackline/api/admin/conversations

/// A channel that could not be added to a bulk action.
record BulkActionFailure {
  channel_id: String
  /// Why the channel was not added, such as `invalid_channel`.
  error: String?
}

/// The response from the `admin.conversations.bulk*` methods.
record BulkActionResponse {
  /// The ID of the bulk action that was started.
  bulk_action_id: String?
  /// Channels left out of the bulk action because they failed validation.
  not_added: List(BulkActionFailure)?
}

/// The response from methods that create a channel.
record CreatedChannel {
  /// The ID of the new channel.
  channel_id: String
}

# The docs example shows the placeholder string `"array"` instead of a list.
/// `internal_team_ids` of a frozen channel: a list, or a placeholder string.
oneof EkmInternalTeamIds {
  EkmInternalTeamIdList(List(String))
  EkmInternalTeamIdsOther(Value)
}

/// A read-only (frozen) channel and the original channel used for its EKM keys.
record EkmChannelInfo {
  id: String
  internal_team_ids: EkmInternalTeamIds?
  original_connected_host_id: String?
  original_connected_channel_id: String?
}

/// A string Slack sends either as one comma separated string or as a list.
oneof PrefValues {
  PrefValueList(List(String))
  PrefValueString(String)
}

/// Who a conversation permission applies to.
record ConversationPermission {
  /// Kinds of users, such as `admin`, `org_admin`, `regular` or `ra` (everyone).
  type: PrefValues?
  /// Specific user IDs.
  user: PrefValues?
}

/// A pref that is either enabled or not.
record EnabledPref {
  enabled: Bool?
}

/// Posting, threading, huddle and mention permissions for a channel.
record ConversationPrefs {
  /// Who can post in the channel.
  who_can_post: ConversationPermission?
  /// Who can respond in threads.
  can_thread: ConversationPermission?
  # The docs do not show the shape of this field.
  /// Whether a huddle can start in the channel.
  can_huddle: Value?
  /// Whether `@channel` mentions can be used. Enabled when absent.
  enable_at_channel: EnabledPref?
  /// Whether `@here` mentions can be used. Enabled when absent.
  enable_at_here: EnabledPref?
}

/// A user who could not be removed from a channel.
record KickFailure {
  user_id: String
  /// Such as `not_in_channel`.
  error: String?
}

/// A channel from `admin.conversations.search`.
record SearchedConversation {
  id: String
  name: String?
  purpose: String?
  /// `-1` when the channel is archived.
  member_count: Int?
  created: Int?
  creator_id: String?
  is_private: Bool?
  is_archived: Bool?
  is_general: Bool?
  /// Time of the last activity, in microseconds.
  last_activity_ts: Int?
  is_ext_shared: Bool?
  is_global_shared: Bool?
  is_org_default: Bool?
  is_org_mandatory: Bool?
  is_org_shared: Bool?
  is_frozen: Bool?
  connected_team_ids: List(String)?
  internal_team_ids_count: Int?
  internal_team_ids_sample_team: String?
  pending_connected_team_ids: List(String)?
  is_pending_ext_shared: Bool?
}

method admin.conversations.archive {
  response Nil
}

method admin.conversations.bulkArchive {
  response BulkActionResponse
}

method admin.conversations.bulkDelete {
  response BulkActionResponse
}

method admin.conversations.bulkMove {
  response BulkActionResponse
}

method admin.conversations.bulkSetExcludeFromSlackAi {
  response BulkActionResponse
}

method admin.conversations.bulkSetProperties {
  args {
    /// The property to set, as a json object such as `{"exclude_from_slack_ai": true}`. Only one property can be updated at a time.
    property: Value json
  }
  response BulkActionResponse
}

method admin.conversations.convertToPrivate {
  response Nil
}

method admin.conversations.convertToPublic {
  response Nil
}

method admin.conversations.create {
  response CreatedChannel
}

method admin.conversations.createForObjects {
  response CreatedChannel
}

method admin.conversations.delete {
  response Nil
}

method admin.conversations.disconnectShared {
  response Nil
}

method admin.conversations.ekm.listOriginalConnectedChannelInfo {
  args {
    /// The channels to filter to.
    channel_ids: List(String)? comma
    /// The workspaces the returned channels belong to.
    team_ids: List(String)? comma
  }
  response {
    channels: List(EkmChannelInfo)?
    response_metadata: ResponseMetadata?
  }
}

method admin.conversations.getConversationPrefs {
  response {
    prefs: ConversationPrefs?
  }
}

method admin.conversations.getCustomRetention {
  response {
    /// Whether a custom retention policy is enabled for the conversation.
    is_policy_enabled: Bool?
    /// The message retention duration in days.
    duration_days: Int?
  }
}

method admin.conversations.getTeams {
  response {
    team_ids: List(String)?
    response_metadata: ResponseMetadata?
  }
}

method admin.conversations.invite {
  response Nil
}

method admin.conversations.kick {
  response {
    removed_user_ids: List(String)?
    failed_user_ids: List(KickFailure)?
    /// `failed_for_some_users` when some users could not be removed.
    warning: String?
    response_metadata: ResponseMetadata?
  }
}

method admin.conversations.linkObjects {
  response Nil
}

method admin.conversations.lookup {
  response {
    /// IDs of the matching channels.
    channels: List(String)?
    response_metadata: ResponseMetadata?
  }
}

method admin.conversations.removeCustomRetention {
  response Nil
}

method admin.conversations.rename {
  response Nil
}

method admin.conversations.restrictAccess.addGroup {
  response Nil
}

method admin.conversations.restrictAccess.listGroups {
  response {
    /// IDP groups allowed to access the private channel.
    group_ids: List(String)?
  }
}

method admin.conversations.restrictAccess.removeGroup {
  args {
    /// The workspace where the channel exists. Required for channels tied to one workspace, optional for org-shared channels.
    team_id: String?
  }
  response Nil
}

method admin.conversations.search {
  args {
    sort: ConversationSearchSort
    sort_dir: SortDirection
  }
  response {
    conversations: List(SearchedConversation)?
    /// Pass as `cursor` to get the next page. Empty or absent on the last page.
    next_cursor: String?
    /// Total number of matching channels.
    total_count: Int?
  }
}

method admin.conversations.setConversationPrefs {
  response Nil
}

method admin.conversations.setCustomRetention {
  response Nil
}

method admin.conversations.setTeams {
  response Nil
}

method admin.conversations.unarchive {
  response Nil
}

method admin.conversations.unlinkObjects {
  response Nil
}

/// How to sort conversation search results.
enum ConversationSearchSort {
  relevant
  name as SortByName
  member_count
  created
}
