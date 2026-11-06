//// Events API envelopes and every event type delivered over the Events API.
////
//// Reference: https://docs.slack.dev/apis/events-api and
//// https://docs.slack.dev/reference/events
module slackline/event

# ---------------------------------------------------------------- envelopes

/// What Slack posts to your request URL, or puts in the `payload` of a Socket
/// Mode `events_api` message.
union Envelope tag "type" {
  /// The outer event wrapper around every inner event.
  event_callback EventCallback {
    /// Deprecated verification token. Verify requests with signing secrets instead.
    token: String?
    /// The workspace where this event occurred. `null` for some org-wide events.
    team_id: String?
    /// The app this event is intended for.
    api_app_id: String?
    /// The enterprise org, sent at the top level for org-wide events such as `team_access_granted`.
    enterprise_id: String?
    /// The inner event.
    event: Event
    /// An identifier for this event, usable with `apps.event.authorizations.list`.
    event_context: String?
    /// A unique identifier for this event, globally unique across all workspaces.
    event_id: String?
    /// The epoch timestamp in seconds indicating when this event was dispatched.
    event_time: Int?
    /// One of the installations of your app this event is visible to.
    authorizations: List(EnvelopeAuthorization)?
    /// Whether the event occurred in an externally shared channel.
    is_ext_shared_channel: Bool?
    /// The workspace through which your app is receiving the event.
    context_team_id: String?
    /// The enterprise org through which your app is receiving the event.
    context_enterprise_id: String?
  }
  /// Sent once when you configure a request URL. Respond with `challenge`.
  url_verification UrlVerification {
    /// Deprecated verification token.
    token: String?
    /// Respond with this value to verify the request URL.
    challenge: String
  }
  /// Your app's event subscriptions are being rate limited.
  app_rate_limited AppRateLimited {
    /// Deprecated verification token.
    token: String?
    /// Subscriptions between your app and this workspace are being rate limited.
    team_id: String?
    /// A rounded epoch time for the minute your app became rate limited.
    minute_rate_limited: Int?
    /// Your application's ID.
    api_app_id: String?
  }
  .. UnknownEnvelope
}

/// An installation of your app that an event is visible to. Installations may
/// not have all of `enterprise_id`, `team_id` and `user_id` defined.
record EnvelopeAuthorization {
  enterprise_id: String?
  team_id: String?
  user_id: String?
  is_bot: Bool?
  is_enterprise_install: Bool?
}

# ---------------------------------------------------------------- events

/// An inner event, dispatching on `type`.
union Event tag "type" {
  /// A user clicked the stop button on an agent session.
  agent_session_stopped AgentSessionStopped {
    channel: String
    user: String?
    thread_ts: String?
    /// Timestamps of your app's in-progress streaming messages that Slack stopped. Empty when no stream was active.
    streaming_message_ts: List(String)?
    event_ts: String?
  }
  /// A user changed the title of an agent session.
  agent_session_title_changed AgentSessionTitleChanged {
    channel: String
    user: String?
    team_id: String?
    /// Included for org-level installs.
    enterprise_id: String?
    thread_ts: String?
    title: String?
    /// Omitted when the session had no title before the change.
    previous_title: String?
    event_ts: String?
  }
  /// The context changed while an app was visible.
  app_context_changed AppContextChanged {
    /// What the user is currently viewing. Empty when no entities are present.
    context: AppContext?
    event_ts: String?
  }
  /// An organization-wide app was deleted from a team.
  app_deleted AppDeleted {
    app_id: String?
    app_name: String?
    app_owner_id: String?
    team_id: String?
    team_domain: String?
    event_ts: String?
  }
  /// A user clicked into your App Home.
  app_home_opened AppHomeOpened {
    user: String?
    channel: String?
    /// The tab opened: `home` or `messages`.
    tab: String?
    /// The current Home tab view, included if one was published before.
    view: View?
    /// Sent when the app is subscribed to `app_context_changed`.
    context: AppContext?
    event_ts: String?
  }
  /// An organization-wide app was installed on a team.
  app_installed AppInstalled {
    app_id: String?
    app_name: String?
    app_owner_id: String?
    /// The user that installed the app.
    user_id: String?
    team_id: String?
    team_domain: String?
    event_ts: String?
  }
  /// A message mentioned your app. Also used, with `subtype: "document_mention"`, when your bot is mentioned in a canvas.
  app_mention AppMention {
    user: String?
    text: String?
    ts: String?
    channel: String
    thread_ts: String?
    team: String?
    blocks: List(Block)?
    attachments: List(Attachment)?
    files: List(File)?
    edited: MessageEdited?
    client_msg_id: String?
    bot_id: String?
    /// `document_mention` when the mention is in the body of a canvas.
    subtype: String?
    /// Present for canvas mentions.
    document_mention: DocumentMention?
    event_ts: String?
  }
  /// A user requested an app.
  app_requested AppRequested {
    app_request: AppRequest
  }
  /// Your Slack app was completely uninstalled.
  app_uninstalled AppUninstalled {
    event_ts: String?
  }
  /// An organization-wide app was uninstalled from a team.
  app_uninstalled_team AppUninstalledTeam {
    app_id: String?
    app_name: String?
    app_owner_id: String?
    /// The user that uninstalled the app (if available).
    user_id: String?
    team_id: String?
    team_domain: String?
    event_ts: String?
  }
  /// The context changed while an AI assistant thread was visible.
  assistant_thread_context_changed AssistantThreadContextChanged {
    assistant_thread: AssistantThread
    event_ts: String?
  }
  /// An AI assistant thread was started.
  assistant_thread_started AssistantThreadStarted {
    assistant_thread: AssistantThread
    event_ts: String?
  }
  /// A user rejected a call shared in a DM.
  call_rejected CallRejected {
    call_id: String
    user_id: String?
    channel_id: String?
    external_unique_id: String?
    event_ts: String?
  }
  /// A public channel was archived.
  channel_archive ChannelArchive {
    channel: String
    user: String?
    is_moved: Int?
    event_ts: String?
  }
  /// A channel was created.
  channel_created ChannelCreated {
    channel: EventChannel
    event_ts: String?
  }
  /// A channel was deleted.
  channel_deleted ChannelDeleted {
    channel: String
    event_ts: String?
  }
  /// Bulk updates were made to a channel's history.
  channel_history_changed ChannelHistoryChanged {
    /// Reload history for cached messages before this timestamp.
    latest: String?
    ts: String?
    event_ts: String?
  }
  /// A private channel's ID changed because it was shared with Slack Connect.
  channel_id_changed ChannelIdChanged {
    old_channel_id: String
    new_channel_id: String
    event_ts: String?
  }
  /// You left a channel.
  channel_left ChannelLeft {
    channel: String
    actor_id: String?
    event_ts: String?
  }
  /// A channel was renamed.
  channel_rename ChannelRename {
    channel: EventChannel
    event_ts: String?
  }
  /// A channel has been shared with an external workspace.
  channel_shared ChannelShared {
    /// The workspace or organization (`E` prefix) that joined the channel.
    connected_team_id: String?
    channel: String
    event_ts: String?
  }
  /// A channel was unarchived.
  channel_unarchive ChannelUnarchive {
    channel: String
    user: String?
    event_ts: String?
  }
  /// A channel has been unshared with an external workspace.
  channel_unshared ChannelUnshared {
    /// The workspace or organization (`E` prefix) removed from the channel.
    previously_connected_team_id: String?
    channel: String
    /// `true` if the channel is still externally shared.
    is_ext_shared: Bool?
    event_ts: String?
  }
  /// Do Not Disturb settings changed for the current user.
  dnd_updated DndUpdated {
    user: String?
    dnd_status: EventDndStatus?
    event_ts: String?
  }
  /// Do Not Disturb settings changed for a member.
  dnd_updated_user DndUpdatedUser {
    user: String?
    dnd_status: EventDndStatus?
    event_ts: String?
  }
  /// The workspace email domain has changed.
  email_domain_changed EmailDomainChanged {
    email_domain: String?
    event_ts: String?
  }
  /// A custom emoji has been added or changed. Fields present depend on `subtype`.
  emoji_changed EmojiChanged {
    /// Absent or unknown subtypes should be handled by reloading `emoji.list`.
    subtype: EmojiChangeSubtype?
    /// The added emoji (`add`).
    name: String?
    /// The removed emoji, always at least one (`remove`).
    names: List(String)?
    /// The image URL or an `alias:` to an existing name (`add`, `rename`).
    value: String?
    /// The previous name (`rename`).
    old_name: String?
    /// The new name (`rename`).
    new_name: String?
    event_ts: String?
  }
  /// A user opened, refreshed or paged the comments tab of a Work Object flexpane.
  entity_comments_requested EntityCommentsRequested {
    user: String?
    external_ref: ExternalRef?
    entity_url: String?
    link: SharedLink?
    /// The pagination cursor your app supplied in a previous response.
    cursor: String?
    limit: Int?
    /// When present, return the replies for this comment thread.
    thread_root_id: String?
    trigger_id: String?
    event_ts: String?
  }
  /// A user clicked a Work Object unfurl or refreshed the flexpane.
  entity_details_requested EntityDetailsRequested {
    user: String?
    external_ref: ExternalRef?
    entity_url: String?
    link: SharedLink?
    app_unfurl_url: String?
    trigger_id: String?
    user_locale: String?
    channel: String?
    message_ts: String?
    thread_ts: String?
    event_ts: String?
  }
  /// A file was changed.
  file_change FileChange {
    file_id: String
    file: FileRef?
    user_id: String?
    event_ts: String?
  }
  /// A file comment was deleted.
  file_comment_deleted FileCommentDeleted {
    /// The ID of the deleted comment.
    comment: String?
    file_id: String
    file: FileRef?
    event_ts: String?
  }
  /// A file was created.
  file_created FileCreated {
    file_id: String
    file: FileRef?
    user_id: String?
    event_ts: String?
  }
  /// A file was deleted. `file_id` is an ID, not a file object.
  file_deleted FileDeleted {
    file_id: String
    channel_ids: List(String)?
    event_ts: String?
  }
  /// A file was made public.
  file_public FilePublic {
    file_id: String
    file: FileRef?
    user_id: String?
    event_ts: String?
  }
  /// A file was shared.
  file_shared FileShared {
    file_id: String
    file: FileRef?
    user_id: String?
    channel_id: String?
    event_ts: String?
  }
  /// A file was unshared.
  file_unshared FileUnshared {
    file_id: String
    file: FileRef?
    user_id: String?
    channel_id: String?
    event_ts: String?
  }
  /// Your app's function is executed as a step in a workflow.
  function_executed FunctionExecuted {
    function: ExecutedFunction
    /// The function's inputs, keyed by parameter name.
    inputs: Dict(Value)?
    function_execution_id: String
    workflow_execution_id: String?
    /// A short-lived bot token for this execution.
    bot_access_token: String?
    event_ts: String?
  }
  /// An enterprise org migration has finished on this workspace.
  grid_migration_finished GridMigrationFinished {
    enterprise_id: String?
    event_ts: String?
  }
  /// An enterprise org migration has started on this workspace.
  grid_migration_started GridMigrationStarted {
    enterprise_id: String?
    event_ts: String?
  }
  /// A private channel was archived.
  group_archive GroupArchive {
    channel: String
    user: String?
    event_ts: String?
  }
  /// You closed a private channel.
  group_close GroupClose {
    user: String?
    channel: String
    event_ts: String?
  }
  /// A private channel was deleted.
  group_deleted GroupDeleted {
    channel: String
    event_ts: String?
  }
  /// Bulk updates were made to a private channel's history.
  group_history_changed GroupHistoryChanged {
    latest: String?
    ts: String?
    event_ts: String?
  }
  /// You left a private channel.
  group_left GroupLeft {
    channel: String
    actor_id: String?
    event_ts: String?
  }
  /// You created a group DM.
  group_open GroupOpen {
    user: String?
    channel: String
    event_ts: String?
  }
  /// A private channel was renamed.
  group_rename GroupRename {
    channel: EventChannel
    event_ts: String?
  }
  /// A private channel was unarchived.
  group_unarchive GroupUnarchive {
    channel: String
    user: String?
    event_ts: String?
  }
  /// You closed a DM.
  im_close ImClose {
    user: String?
    channel: String
    event_ts: String?
  }
  /// A DM was created.
  im_created ImCreated {
    user: String?
    channel: Conversation
    event_ts: String?
  }
  /// Bulk updates were made to a DM's history.
  im_history_changed ImHistoryChanged {
    latest: String?
    ts: String?
    event_ts: String?
  }
  /// You opened a DM.
  im_open ImOpen {
    user: String?
    channel: String
    event_ts: String?
  }
  /// A user requested an invite.
  invite_requested InviteRequested {
    invite_request: InviteRequest
    event_ts: String?
  }
  /// A message containing a known link was posted, or typed into the composer.
  link_shared LinkShared {
    /// `COMPOSER` when the link is in the message composer.
    channel: String
    /// Whether the app's bot user is a member of the conversation.
    is_bot_user_member: Bool?
    /// `true` when a user asks to refresh an existing Work Object unfurl.
    is_unfurl_refresh: Bool?
    user: String?
    /// Not a real timestamp when `source` is `composer`.
    message_ts: String
    /// Identifies the link for `chat.unfurl`. Absent in Enterprise organizations.
    unfurl_id: String?
    /// Only present when the link was shared within a thread.
    thread_ts: String?
    /// Absent in Enterprise organizations.
    source: LinkSource?
    links: List(SharedLink)
    /// The user's locale, for localizing unfurls.
    user_locale: String?
    event_ts: String?
  }
  /// A user joined a channel.
  member_joined_channel MemberJoinedChannel {
    user: String
    channel: String
    /// `C` or `G`. Use `conversations.info` for the actual channel type.
    channel_type: MembershipChannelType?
    team: String?
    /// The inviting user. Absent or blank if the user joined on their own.
    inviter: String?
    /// The user's org. Blank if the team is not part of an Enterprise organization.
    enterprise: String?
    event_ts: String?
  }
  /// A user left a channel.
  member_left_channel MemberLeftChannel {
    user: String
    channel: String
    channel_type: MembershipChannelType?
    team: String?
    enterprise: String?
    event_ts: String?
  }
  /// A message was sent, changed, or otherwise touched a conversation. Used
  /// for the `message.channels`, `message.groups`, `message.im`,
  /// `message.mpim` and `message.app_home` subscriptions.
  message MessageEvent(MessageEvent)
  /// Message metadata was deleted.
  message_metadata_deleted MessageMetadataDeleted {
    channel_id: String
    message_ts: String?
    deleted_ts: String?
    previous_metadata: MessageMetadata?
    app_id: String?
    bot_id: String?
    user_id: String?
    team_id: String?
    event_ts: String?
  }
  /// A message with metadata was posted.
  message_metadata_posted MessageMetadataPosted {
    channel_id: String
    message_ts: String?
    metadata: MessageMetadata?
    app_id: String?
    bot_id: String?
    user_id: String?
    team_id: String?
    event_ts: String?
  }
  /// Message metadata was updated.
  message_metadata_updated MessageMetadataUpdated {
    channel_id: String
    message_ts: String?
    metadata: MessageMetadata?
    previous_metadata: MessageMetadata?
    app_id: String?
    bot_id: String?
    user_id: String?
    team_id: String?
    event_ts: String?
  }
  /// An item was pinned to a channel.
  pin_added PinAdded {
    user: String?
    channel_id: String
    item: EventPinItem?
    event_ts: String?
  }
  /// An item was unpinned from a channel.
  pin_removed PinRemoved {
    user: String?
    channel_id: String
    item: EventPinItem?
    /// Whether there are other pinned items in the channel.
    has_pins: Bool?
    event_ts: String?
  }
  /// A member added an emoji reaction to an item.
  reaction_added ReactionAdded {
    user: String
    reaction: String
    /// The author of the item. Absent for items not authored by users.
    item_user: String?
    item: ReactionItem
    event_ts: String?
  }
  /// A member removed an emoji reaction.
  reaction_removed ReactionRemoved {
    user: String
    reaction: String
    item_user: String?
    item: ReactionItem
    event_ts: String?
  }
  /// A Slack Connect invitation was accepted.
  shared_channel_invite_accepted SharedChannelInviteAccepted {
    approval_required: Bool?
    invite: SharedChannelInvite?
    channel: SharedChannelRef?
    teams_in_channel: List(Team)?
    accepting_user: User?
    event_ts: String?
  }
  /// A Slack Connect invitation was approved.
  shared_channel_invite_approved SharedChannelInviteApproved {
    invite: SharedChannelInvite?
    channel: SharedChannelRef?
    approving_team_id: String?
    teams_in_channel: List(Team)?
    approving_user: User?
    event_ts: String?
  }
  /// A Slack Connect invitation was declined.
  shared_channel_invite_declined SharedChannelInviteDeclined {
    invite: SharedChannelInvite?
    channel: SharedChannelRef?
    declining_team_id: String?
    teams_in_channel: List(Team)?
    declining_user: User?
    event_ts: String?
  }
  /// A bot or app was invited to a Slack Connect channel.
  shared_channel_invite_received SharedChannelInviteReceived {
    invite: SharedChannelInvite?
    channel: SharedChannelRef?
    event_ts: String?
  }
  /// A user asked to invite external users to a Slack Connect channel.
  shared_channel_invite_requested SharedChannelInviteRequested {
    actor: User?
    channel: SharedChannelRef?
    is_external_limited: Bool?
    target_users: List(SharedInviteTarget)?
    teams_in_channel: List(Team)?
    event_ts: String?
  }
  /// An item was starred (no longer dispatched).
  star_added StarAdded {
    user: String?
    item: EventStarItem?
    event_ts: String?
  }
  /// An item was unstarred (no longer dispatched).
  star_removed StarRemoved {
    user: String?
    item: EventStarItem?
    event_ts: String?
  }
  /// A User Group was created.
  subteam_created SubteamCreated {
    subteam: Usergroup
    event_ts: String?
  }
  /// Users were added to or removed from a User Group.
  subteam_members_changed SubteamMembersChanged {
    subteam_id: String
    team_id: String?
    date_previous_update: Int?
    date_update: Int?
    added_users: List(String)?
    # The docs show a string; live events send a number. Both decode.
    added_users_count: Int?
    removed_users: List(String)?
    removed_users_count: Int?
    event_ts: String?
  }
  /// You were added to a User Group.
  subteam_self_added SubteamSelfAdded {
    subteam_id: String
    event_ts: String?
  }
  /// You were removed from a User Group.
  subteam_self_removed SubteamSelfRemoved {
    subteam_id: String
    event_ts: String?
  }
  /// A User Group was updated. `users` is truncated at 500.
  subteam_updated SubteamUpdated {
    subteam: Usergroup
    event_ts: String?
  }
  /// Your org-ready app was given access to new workspaces.
  team_access_granted TeamAccessGranted {
    team_ids: List(String)
    event_ts: String?
  }
  /// Your org-ready app lost access to workspaces.
  team_access_revoked TeamAccessRevoked {
    team_ids: List(String)
    event_ts: String?
  }
  /// The workspace domain has changed.
  team_domain_change TeamDomainChange {
    url: String?
    domain: String?
    team_id: String?
    event_ts: String?
  }
  /// A new member has joined.
  team_join TeamJoin {
    user: User
    event_ts: String?
  }
  /// The workspace name has changed.
  team_rename TeamRename {
    name: String?
    team_id: String?
    event_ts: String?
  }
  /// API tokens for your app were revoked. Lists user IDs, not tokens.
  tokens_revoked TokensRevoked {
    tokens: RevokedTokens
    event_ts: String?
  }
  /// A member's data has changed.
  user_change UserChange {
    user: User
    cache_ts: Int?
    event_ts: String?
  }
  /// A user asked to connect to or disconnect from your app.
  user_connection UserConnection {
    subtype: UserConnectionSubtype?
    user: String
    enterprise_id: String?
    /// Present for `connect`, to open a modal for the connection flow.
    trigger_id: String?
    event_ts: String?
  }
  /// A user's guest status changed.
  user_guest_status_changed UserGuestStatusChanged {
    user: User
    cache_ts: Int?
    event_ts: String?
  }
  /// A user's huddle status changed.
  user_huddle_changed UserHuddleChanged {
    user: User
    cache_ts: Int?
    event_ts: String?
  }
  /// A user's profile data changed.
  user_profile_changed UserProfileChanged {
    user: User
    cache_ts: Int?
    event_ts: String?
  }
  /// A user's status changed.
  user_status_changed UserStatusChanged {
    user: User
    cache_ts: Int?
    event_ts: String?
  }
  .. UnknownEvent
}

# ---------------------------------------------------------------- message events

/// A `message` event, dispatching on `subtype`. Plain messages have no
/// subtype. `message_replied` events arrive without a subtype over the Events
/// API, so check `thread_ts` on plain messages too.
union MessageEvent tag "subtype" optional {
  /// A plain message, possibly with files, blocks or attachments.
  "" PlainMessage {
    type = "message"
    channel: String
    user: String?
    text: String?
    # One docs example leaves this out.
    ts: String?
    thread_ts: String?
    channel_type: MessageChannelType?
    team: String?
    blocks: List(Block)?
    attachments: List(Attachment)?
    files: List(File)?
    /// Whether the share happened at upload time.
    upload: Bool?
    display_as_bot: Bool?
    edited: MessageEdited?
    client_msg_id: String?
    bot_id: String?
    bot_profile: BotProfile?
    app_id: String?
    parent_user_id: String?
    metadata: MessageMetadata?
    reactions: List(Reaction)?
    is_starred: Bool?
    pinned_to: List(String)?
    /// Sent when the app is subscribed to `app_context_changed`.
    app_context: AppContext?
    /// Present when Slack omits the `message_replied` subtype.
    message: Message?
    hidden: Bool?
    event_ts: String?
  }
  /// The root message of an assistant thread.
  assistant_app_thread AssistantAppThreadMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String?
    thread_ts: String?
    channel_type: MessageChannelType?
    team: String?
    blocks: List(Block)?
    assistant_app_thread: AssistantAppThreadInfo?
    event_ts: String?
  }
  # bot_add and bot_remove are not in the docs but appear in live history.
  /// An app was added to the channel.
  bot_add BotAddMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    /// The app's bot ID.
    bot_id: String?
    /// A Slack link to the app, as `<url|name>`.
    bot_link: String?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// An app was removed from the channel.
  bot_remove BotRemoveMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    /// The app's bot ID.
    bot_id: String?
    /// A Slack link to the app, as `<url|name>`.
    bot_link: String?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A message was posted by an integration.
  bot_message BotMessage {
    type = "message"
    channel: String?
    text: String?
    ts: String
    thread_ts: String?
    channel_type: MessageChannelType?
    bot_id: String?
    bot_profile: BotProfile?
    /// Overrides the bot's default username.
    username: String?
    /// Overrides the bot's default icons.
    icons: Dict(String)?
    blocks: List(Block)?
    attachments: List(Attachment)?
    app_id: String?
    event_ts: String?
  }
  /// A channel was archived.
  channel_archive ChannelArchiveMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A channel was made private.
  channel_convert_to_private ChannelConvertToPrivateMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A channel was made public.
  channel_convert_to_public ChannelConvertToPublicMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A member joined a channel.
  channel_join ChannelJoinMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    /// The inviting user, absent if the user was not invited.
    inviter: String?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A member left a channel.
  channel_leave ChannelLeaveMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A channel was renamed.
  channel_name ChannelNameMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    old_name: String?
    name: String?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// The posting permissions for a channel changed.
  channel_posting_permissions ChannelPostingPermissionsMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A channel purpose was updated.
  channel_purpose ChannelPurposeMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    purpose: String?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A channel topic was updated.
  channel_topic ChannelTopicMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    topic: String?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A channel was unarchived.
  channel_unarchive ChannelUnarchiveMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    channel_type: MessageChannelType?
    event_ts: String?
  }
  # The docs example arrives with `type: "app_mention"`, which decodes as
  # `AppMention`.
  /// A bot was mentioned in the body of a canvas.
  document_mention DocumentMentionMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    team: String?
    blocks: List(Block)?
    document_mention: DocumentMention?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// Message content redacted due to Enterprise Key Management. The author is `UREVOKEDU`.
  ekm_access_denied EkmAccessDeniedMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A comment was added to a file (no longer served).
  file_comment FileCommentMessage {
    type = "message"
    channel: String?
    text: String?
    ts: String
    file: File?
    /// The file comment object.
    comment: Value?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A file was mentioned in a channel (no longer served).
  file_mention FileMentionMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    file: File?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A file was shared into a channel. In the Events API, a shared file can
  /// also arrive without a subtype. See `PlainMessage.files`.
  file_share FileShareMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    files: List(File)?
    upload: Bool?
    display_as_bot: Bool?
    bot_id: String?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A private group was archived.
  group_archive GroupArchiveMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    members: List(String)?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A member joined a private group.
  group_join GroupJoinMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    inviter: String?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A member left a private group.
  group_leave GroupLeaveMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A private group was renamed.
  group_name GroupNameMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    old_name: String?
    name: String?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A private group purpose was updated.
  group_purpose GroupPurposeMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    purpose: String?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A private group topic was updated.
  group_topic GroupTopicMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    topic: String?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A private group was unarchived.
  group_unarchive GroupUnarchiveMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A `/me` message was sent.
  me_message MeMessage {
    type = "message"
    channel: String
    user: String?
    text: String?
    ts: String
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A message was changed. Replace the message with the same `message.ts`.
  message_changed MessageChanged {
    type = "message"
    channel: String
    hidden: Bool?
    ts: String
    /// The updated message.
    message: Message
    /// The message before the change.
    previous_message: Message?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A message was deleted.
  message_deleted MessageDeleted {
    type = "message"
    channel: String
    hidden: Bool?
    ts: String
    /// The timestamp of the deleted message.
    deleted_ts: String
    previous_message: Message?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A message thread received a reply. Over the Events API this usually
  /// arrives without a subtype, as a `PlainMessage`.
  message_replied MessageReplied {
    type = "message"
    channel: String
    hidden: Bool?
    ts: String
    /// The parent message.
    message: Message
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// An item was pinned in a channel.
  pinned_item PinnedItemMessage {
    type = "message"
    channel: String
    user: String?
    text: String?
    ts: String
    item_type: PinnedMessageItemType?
    item: EventPinItem?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A reminder was added to the channel.
  reminder_add ReminderAddMessage {
    type = "message"
    channel: String?
    user: String?
    team: String?
    text: String?
    ts: String
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A thread reply was broadcast to the channel (no longer served, see `thread_broadcast`).
  reply_broadcast ReplyBroadcastMessage {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    thread_ts: String?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// A thread reply was broadcast to the channel.
  thread_broadcast ThreadBroadcast {
    type = "message"
    channel: String?
    user: String?
    text: String?
    ts: String
    thread_ts: String?
    /// A modified form of the thread's original message.
    root: Message?
    blocks: List(Block)?
    client_msg_id: String?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  /// An item was unpinned from a channel.
  unpinned_item UnpinnedItemMessage {
    type = "message"
    channel: String
    user: String?
    text: String?
    ts: String
    item_type: PinnedMessageItemType?
    item: EventPinItem?
    channel_type: MessageChannelType?
    event_ts: String?
  }
  .. UnknownMessageEvent
}

/// The kind of conversation a message event happened in.
enum MessageChannelType {
  /// A public channel (`message.channels`).
  channel
  /// A private channel or multi-party DM (`message.groups`).
  group
  /// A direct message (`message.im`).
  im
  /// A multi-party direct message (`message.mpim`).
  mpim
  /// An App Home (`message.app_home`).
  app_home
  .. UnknownMessageChannelType
}

/// The single-letter channel type in membership events.
enum MembershipChannelType {
  /// A channel with a `C` prefix (public, or private created after March 2021).
  "C" as CPrefixedChannel
  /// A private channel created before March 2021.
  "G" as GPrefixedChannel
  .. UnknownMembershipChannelType
}

/// The kind of item a `pinned_item` / `unpinned_item` message refers to.
enum PinnedMessageItemType {
  /// A channel message.
  "C" as PinnedChannelMessage
  /// A private group message.
  "G" as PinnedGroupMessage
  /// A file.
  "F" as PinnedFileItem
  /// A file comment.
  "Fc" as PinnedFileCommentItem
  .. UnknownPinnedMessageItemType
}

/// Where in a canvas a bot was mentioned.
record DocumentMention {
  /// The canvas file.
  file_id: String
  /// The canvas section.
  section_id: String
  mentioning_user_ids: List(String)?
}

# ---------------------------------------------------------------- event parts

/// What a user is currently viewing, ordered by relevance.
record AppContext {
  entities: List(AppContextEntity)?
}

/// One thing a user is viewing.
record AppContextEntity {
  /// For example `slack#/types/channel_id` or `slack#/types/message_context`.
  "type" as entity_type: String
  /// A string ID, or an object such as `{message_ts, channel_id}`.
  value: Value?
  team_id: String?
}

/// An assistant thread and the context the user is viewing.
record AssistantThread {
  user_id: String?
  /// The DM channel of the assistant thread.
  channel_id: String
  thread_ts: String
  context: AssistantThreadContext?
}

/// The channel a user is viewing while the assistant container is open.
record AssistantThreadContext {
  channel_id: String?
  team_id: String?
  enterprise_id: String?
  # The next two are not in the docs but appear in live events.
  /// Where the user opened the thread, such as `chat`.
  thread_entry_point: String?
  /// Whether the user asked the assistant to search.
  force_search: Bool?
}

/// The partial channel in `channel_created`, `channel_rename` and `group_rename`.
record EventChannel {
  id: String
  name: String?
  created: Int?
  creator: String?
  is_channel: Bool?
  is_mpim: Bool?
}

/// A file reference with only the ID. Use `files.info` for the full object.
record FileRef {
  id: String
}

/// Do Not Disturb status in `dnd_updated` events.
record EventDndStatus {
  dnd_enabled: Bool?
  next_dnd_start_ts: Int?
  next_dnd_end_ts: Int?
  snooze_enabled: Bool?
  snooze_endtime: Int?
}

/// The `subtype` of an `emoji_changed` event.
enum EmojiChangeSubtype {
  add as EmojiAdded
  remove as EmojiRemoved
  rename as EmojiRenamed
  .. UnknownEmojiChangeSubtype
}

/// The `subtype` of a `user_connection` event.
enum UserConnectionSubtype {
  connect as UserConnect
  disconnect as UserDisconnect
  .. UnknownUserConnectionSubtype
}

/// Where a shared link was seen.
enum LinkSource {
  /// Typed into the message composer.
  composer as LinkSourceComposer
  /// In a sent message.
  conversations_history as LinkSourceConversationsHistory
  .. UnknownLinkSource
}

/// A link in `link_shared` and Work Object events.
record SharedLink {
  url: String
  domain: String?
}

/// The function in a `function_executed` event.
record ExecutedFunction {
  id: String
  callback_id: String?
  title: String?
  description: String?
  "type" as function_type: String?
  input_parameters: List(FunctionParameter)?
  output_parameters: List(FunctionParameter)?
  app_id: String?
  date_created: Int?
  date_updated: Int?
  date_deleted: Int?
}

/// An input or output parameter of a function.
record FunctionParameter {
  "type" as parameter_type: String?
  name: String
  description: String?
  title: String?
  is_required: Bool?
}

/// A request, made by a member, to invite someone to a workspace. It comes
/// in `invite_requested` events and from the `admin.inviteRequests.*` methods.
record InviteRequest {
  /// The invite request ID, such as `Ir558ULC1J`.
  id: String
  /// Email address of the person to invite.
  email: String?
  /// When the request was made, in Unix seconds.
  date_created: Int?
  /// IDs of the members who asked for this invite.
  requester_ids: List(String)?
  /// Channels the invited person would join.
  channel_ids: List(String)?
  /// The kind of account requested, such as `full_member`.
  invite_type: String?
  /// Whether the request is for a multi-channel guest.
  is_restricted: Bool?
  /// Whether the request is for a single-channel guest.
  is_ultra_restricted: Bool?
  /// Full name of the person to invite, if given.
  real_name: String?
  /// When a guest account would expire, in Unix seconds.
  date_expire: Int?
  /// The reason the requester gave, if any.
  request_reason: String?
  /// The workspace the request is for, in `invite_requested` events.
  team: Team?
}

/// Icon URLs for an app, keyed by size.
record AppIcons {
  image_32: String?
  image_36: String?
  image_48: String?
  image_64: String?
  image_72: String?
  image_96: String?
  image_128: String?
  image_192: String?
  image_512: String?
  image_1024: String?
  image_original: String?
}

/// An app as described by the app management API.
record AppDetails {
  id: String
  name: String?
  description: String?
  help_url: String?
  privacy_policy_url: String?
  app_homepage_url: String?
  app_directory_url: String?
  is_app_directory_approved: Bool?
  is_internal: Bool?
  is_granular_bot_app: Bool?
  /// Such as `third_party` or `internal`.
  developer_type: String?
  socket_mode_enabled: Bool?
  icons: AppIcons?
  additional_info: String?
}

/// A scope an app requests or was granted.
record AppScope {
  name: String
  description: String?
  is_sensitive: Bool?
  /// `bot` or `user`.
  token_type: String?
  is_optional: Bool?
  is_approved: Bool?
}

/// Whether an app was previously approved or restricted in this org.
record AppPreviousResolution {
  /// Such as `approved` or `restricted`.
  status: String?
  scopes: List(AppScope)?
}

/// The user who requested an app install.
record AppRequestUser {
  id: String
  name: String?
  email: String?
}

/// A request to install an app, from `app_requested` or
/// `admin.apps.requests.list`.
record AppRequest {
  id: String
  app: AppDetails?
  /// Absent or null when the app has not been requested before.
  previous_resolution: AppPreviousResolution?
  user: AppRequestUser?
  /// Null when the request is for the whole enterprise.
  team: Team?
  /// Present when the approval is for the whole enterprise.
  enterprise: Value?
  scopes: List(AppScope)?
  /// An optional message from the requesting user.
  message: String?
  is_user_app_collaborator: Bool?
  /// App ID of the manager app, if one provisioned the requested app.
  manager_app_id: String?
  /// When the request was made (Unix time).
  date_created: Int?
}

/// A Slack Connect invitation.
record SharedChannelInvite {
  id: String
  date_created: Int?
  date_invalid: Int?
  inviting_team: Team?
  inviting_user: User?
  recipient_email: String?
  recipient_user_id: String?
}

/// The partial channel in Slack Connect invitation events.
record SharedChannelRef {
  id: String
  name: String?
  is_private: Bool?
  is_im: Bool?
  date_created: Int?
  message_latest_counted_timestamp: Int?
}

/// An external user someone asked to invite.
record SharedInviteTarget {
  email: String?
  invite_id: String?
}

/// The `item` of a `pin_added` / `pin_removed` event.
record EventPinItem {
  /// `message`, `file` or `file_comment`.
  "type" as item_type: String?
  channel: String?
  created: Int?
  created_by: String?
  message: Message?
  file: File?
  comment: Value?
}

/// The `item` of a `star_added` / `star_removed` event.
record EventStarItem {
  /// `message`, `file`, `file_comment`, `channel`, `im` or `group`.
  "type" as item_type: String?
  channel: String?
  message: Message?
  file: File?
  comment: Value?
  date_create: Int?
}

/// A brief reference to what was reacted to.
union ReactionItem tag "type" {
  message ReactionItemMessage {
    channel: String
    ts: String
    channel_type: MessageChannelType?
  }
  file ReactionItemFile {
    file: String
  }
  file_comment ReactionItemFileComment {
    file_comment: String
    file: String?
  }
  .. UnknownReactionItem
}

/// User IDs whose tokens were revoked, by token type.
record RevokedTokens {
  /// User tokens (`xoxp-`).
  oauth: List(String)?
  /// Bot tokens (`xoxb-`).
  bot: List(String)?
}
