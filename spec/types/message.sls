//// Messages, message metadata and reactions.
////
//// `Message` is one record covering every message shape the Web API returns:
//// `conversations.history` and `conversations.replies`, `chat.postMessage`
//// and friends, pins, stars, reactions and search results. Every field is
//// optional because the shapes differ a lot (scheduled messages and
//// `chat.update` responses have no `ts`, `latest` can be an empty object).
//// See <https://docs.slack.dev/reference/events/message>.
module slackline/message

/// A message in a conversation.
record Message {
  /// Usually `message`. Scheduled messages use `delayed_message`.
  type: String?
  /// The message subtype, such as `bot_message` or `channel_join`. Absent
  /// for ordinary user messages.
  subtype: MessageSubtype?
  /// The unique (per-channel) timestamp of the message.
  ts: String?
  /// The timestamp of the thread's parent message, for threaded messages.
  thread_ts: String?
  /// The ID of the user who sent the message.
  user: String?
  /// The ID of the bot that sent the message, for bot messages.
  bot_id: String?
  /// The ID of the app that sent the message.
  app_id: String?
  /// The display name used for bot messages or search results.
  username: String?
  /// The text of the message.
  text: String?
  /// Block Kit blocks in the message.
  blocks: List(Block)?
  /// Legacy secondary attachments.
  attachments: List(Attachment)?
  /// Files shared in the message.
  files: List(File)?
  /// `true` when the message is a file upload.
  upload: Bool?
  display_as_bot: Bool?
  /// Present if the message has been edited: the editor and the edit time.
  edited: MessageEdited?
  /// Reactions on the message. `users` can be incomplete. `count` is exact.
  reactions: List(Reaction)?
  /// Present and `true` if the calling user has starred the message.
  is_starred: Bool?
  /// IDs of channels the message is currently pinned to.
  pinned_to: List(String)?
  /// A permanent link to the message.
  permalink: String?
  /// The workspace the message was sent from.
  team: String?
  user_team: String?
  source_team: String?
  /// The channel the message was posted in. An ID in most responses, a
  /// summary object in search results.
  channel: MessageChannelRef?
  /// `channel`, `group`, `im`, `mpim` or `app_home` (events only).
  channel_type: String?
  event_ts: String?
  /// Hidden messages are part of channel history but are not displayed.
  hidden: Bool?
  /// For `message_deleted`: the `ts` of the deleted message.
  deleted_ts: String?
  /// A client-generated ID for messages sent by Slack clients.
  client_msg_id: String?
  /// Icons used for bot messages.
  icons: MessageIcons?
  /// Details about the bot that sent the message.
  bot_profile: BotProfile?
  /// A short profile of the sender, included in some events and Slack
  /// Connect channels.
  user_profile: MessageUserProfile?
  /// Metadata attached to the message by an app.
  metadata: MessageMetadata?
  /// Context about what the user was viewing (`app_context_changed`).
  app_context: Value?

  # Threads
  /// Number of replies in the thread (parent messages only).
  reply_count: Int?
  /// Number of distinct users who replied.
  reply_users_count: Int?
  /// Up to a few user IDs of repliers.
  reply_users: List(String)?
  /// `ts` of the latest reply.
  latest_reply: String?
  /// Legacy list of replies.
  replies: List(MessageReply)?
  /// Whether the calling user is subscribed to the thread.
  subscribed: Bool?
  /// `ts` of the last reply read by the calling user.
  last_read: String?
  unread_count: Int?
  /// The user who posted the thread's parent message.
  parent_user_id: String?
  /// Whether the thread is locked.
  is_locked: Bool?
  /// For `thread_broadcast`: the thread's parent message.
  root: Message?

  # Subtype-specific fields
  /// For `channel_join` and `group_join`: the user who invited the member.
  inviter: String?
  /// For `channel_topic` and `group_topic`: the new topic.
  topic: String?
  /// For `channel_purpose` and `group_purpose`: the new purpose.
  purpose: String?
  /// For `channel_name` and `group_name`: the new name.
  name: String?
  /// For `channel_name` and `group_name`: the old name.
  old_name: String?
  /// For `group_archive`: the members of the group.
  members: List(String)?
  /// For `pinned_item` and `unpinned_item`: the kind of item (`F`, `G`, ...).
  item_type: String?
  /// For `pinned_item` and `unpinned_item`: the pinned item.
  item: Value?
  /// For `file_comment`: the comment.
  comment: FileComment?
  /// For `file_comment` and `file_mention`: the file.
  file: File?
  /// For `message_changed` and `message_replied`: the new message.
  message: Message?
  /// For `message_changed`: the message before the change.
  previous_message: Message?
  /// For `document_mention`: the canvas mention.
  document_mention: CanvasMention?
  /// For `assistant_app_thread`: the assistant thread.
  assistant_app_thread: AssistantAppThreadInfo?
  /// For `huddle_thread`: the huddle.
  room: HuddleRoom?
  no_notifications: Bool?

  # Search results
  /// Search result ID.
  iid: String?
  score: Float?
  previous: Message?
  previous_2: Message?
  next: Message?
  next_2: Message?
}

/// Message subtypes. See <https://docs.slack.dev/reference/events/message#subtypes>.
enum MessageSubtype {
  assistant_app_thread
  bot_message
  channel_archive
  channel_convert_to_private
  channel_convert_to_public
  channel_join
  channel_leave
  channel_name
  channel_posting_permissions
  channel_purpose
  channel_topic
  channel_unarchive
  document_mention
  ekm_access_denied
  file_comment
  file_mention
  file_share
  group_archive
  group_join
  group_leave
  group_name
  group_purpose
  group_topic
  group_unarchive
  huddle_thread
  me_message
  message_changed
  message_deleted
  message_replied
  pinned_item
  reminder_add
  reply_broadcast
  thread_broadcast
  unpinned_item
  # The next two are not in the docs but appear in live history.
  /// A reply from Slackbot, such as a custom response.
  slackbot_response
  /// A canvas tab in the channel was updated.
  tabbed_canvas_updated
  /// A deleted thread parent that remains as a placeholder for its replies.
  tombstone
  .. UnknownMessageSubtype
}

/// The channel of a message: an ID, or a summary object in search results.
oneof MessageChannelRef {
  MessageChannelId(String)
  MessageChannelInfo(MessageChannel)
}

/// The channel summary included with search results.
record MessageChannel {
  id: String
  name: String?
  is_channel: Bool?
  is_group: Bool?
  is_im: Bool?
  is_mpim: Bool?
  is_private: Bool?
  is_shared: Bool?
  is_ext_shared: Bool?
  is_org_shared: Bool?
  is_pending_ext_shared: Bool?
  pending_shared: List(String)?
  user: String?
}

/// Who edited a message and when.
record MessageEdited {
  /// The user ID of the editor.
  user: String?
  /// The timestamp of the edit.
  ts: String?
}

/// A reply in the legacy `replies` list of a thread parent.
record MessageReply {
  user: String?
  ts: String?
}

/// Icons used for a bot message: an emoji or image URLs.
record MessageIcons {
  emoji: String?
  image_36: String?
  image_48: String?
  image_64: String?
  image_72: String?
}

/// The bot that sent a message.
record BotProfile {
  id: String?
  app_id: String?
  name: String?
  deleted: Bool?
  updated: Int?
  team_id: String?
  icons: MessageIcons?
}

/// The short sender profile included with some messages.
record MessageUserProfile {
  avatar_hash: String?
  image_72: String?
  first_name: String?
  real_name: String?
  display_name: String?
  team: String?
  name: String?
  is_restricted: Bool?
  is_ultra_restricted: Bool?
}

/// A bot mention inside a canvas.
record CanvasMention {
  file_id: String?
  section_id: String?
  mentioning_user_ids: List(String)?
}

/// The assistant thread attached to an `assistant_app_thread` message.
record AssistantAppThreadInfo {
  title: String?
  title_blocks: List(Block)?
  artifacts: List(Value)?
}

/// A huddle attached to a `huddle_thread` message.
record HuddleRoom {
  id: String?
  name: String?
  media_server: String?
  created_by: String?
  date_start: Int?
  date_end: Int?
  participants: List(String)?
  participant_history: List(String)?
  participants_camera_on: List(String)?
  participants_camera_off: List(String)?
  participants_screenshare_on: List(String)?
  participants_screenshare_off: List(String)?
  canvas_thread_ts: String?
  thread_root_ts: String?
  channels: List(String)?
  is_dm_call: Bool?
  was_rejected: Bool?
  was_missed: Bool?
  was_accepted: Bool?
  has_ended: Bool?
  background_id: String?
  canvas_background: String?
  is_prewarmed: Bool?
  is_scheduled: Bool?
  attached_file_ids: List(String)?
  media_backend_type: String?
  display_id: String?
  external_unique_id: String?
  app_id: String?
  call_family: String?
  pending_invitees: Value?
  last_invite_status_by_user: Value?
}

/// Structured metadata attached to a message. Used both when sending (the
/// `metadata` argument of `chat.postMessage`, `chat.update`, `chat.unfurl`
/// and `entity.presentDetails`) and when receiving.
///
/// Event metadata sets `event_type` and `event_payload`. Work Object metadata
/// sets `entities` (for `chat.postMessage` and `chat.unfurl`) or a single
/// `entity_type` and `entity_payload` (for `entity.presentDetails`).
/// See <https://docs.slack.dev/messaging/message-metadata>.
record MessageMetadata {
  /// Identifies the type of event, such as `ticket_created`. Letters,
  /// numbers, underscores and hyphens only. Standard schemas include
  /// `notification` and `approval`.
  event_type: String?
  /// The event-specific fields.
  event_payload: Value?
  /// Work Object entities to unfurl or post.
  entities: List(WorkObjectEntity)?
  /// A single Work Object entity type (`entity.presentDetails`).
  entity_type: String?
  /// A single Work Object entity payload (`entity.presentDetails`).
  entity_payload: Value?
}

/// A Work Object entity in message metadata, as sent to `chat.postMessage`,
/// `chat.postEphemeral` and `chat.unfurl`.
/// See <https://docs.slack.dev/messaging/work-objects-implementation>.
record WorkObjectEntity {
  /// The entity type, such as `slack#/entities/file` or `slack#/entities/task`.
  entity_type: String
  /// Uniquely identifies the resource in the third-party system.
  external_ref: ExternalRef
  /// The URL that directs the user to the resource in the third-party system.
  url: String
  /// The properties displayed in the Work Object (`attributes`, `fields`,
  /// `custom_fields`, ...).
  entity_payload: Value
  /// The URL posted by the user in a conversation, as found in the
  /// `link_shared` event. `chat.unfurl` uses it. Posting a message does not
  /// need it.
  app_unfurl_url: String?
  /// Set to `false` to hide the refresh button and opt out of automatic
  /// refreshes.
  is_refreshable: Bool?
  /// A comment summary for the entity.
  entity_comments: EntityComments?
}

/// Identifies a Work Object resource in the app's own system.
record ExternalRef {
  /// A string ID that uniquely identifies the resource. Use the same ID that
  /// your system uses to get the resource through its APIs.
  id: String
  /// An optional internal type for the entity in the source system. It is
  /// only needed when the ID is not globally unique.
  "type" as ref_type: String?
}

/// A comment summary shown on a Work Object.
record EntityComments {
  /// The number of comments on the entity.
  count: Int?
  /// The Unix timestamp of the latest comment.
  latest_timestamp: Int?
}
