//// Post, update, schedule, stream and unfurl messages (`chat.*`).
module slackline/api/chat

# ------------------------------------------------------------ unfurls

/// A custom preview for a link unfurled inside the message composer.
record UnfurlPreview {
  /// A `plain_text` title for the preview.
  title: Text?
  /// URL of an icon for the preview.
  icon_url: String?
}

/// An unfurl made of Block Kit blocks.
record BlocksUnfurl {
  /// The blocks to show for the URL.
  blocks: List(Block)
  /// A custom preview, used only for links in the message composer.
  preview: UnfurlPreview?
  /// Set to `true` to remove the color bar. Only valid with a single file
  /// block.
  hide_color: Bool?
}

/// What to show for one unfurled URL: blocks, or a single legacy attachment.
oneof Unfurl {
  BlocksUnfurlContent(BlocksUnfurl)
  AttachmentUnfurlContent(Attachment)
}

# ------------------------------------------------------------ streaming

/// An icon for a streamed task.
record TaskIcon {
  type = "icon"
  /// The icon name or image URL.
  name: String
}

/// A URL source used to produce a task's output.
record TaskSource {
  type = "url"
  /// The URL of the source.
  url: String
  /// Display text for the URL.
  text: String
}

/// A chunk of content streamed with `chat.startStream`, `chat.appendStream`
/// or `chat.stopStream`.
union StreamChunk tag "type" {
  /// Text content with markdown formatting.
  markdown_text MarkdownTextChunk {
    /// The markdown text to stream.
    text: String
  }
  /// Displays or updates a task, rendered like a task card.
  task_update TaskUpdateChunk {
    /// A unique ID for the task. Later chunks with the same ID update it.
    id: String
    /// Title of the task.
    title: String
    /// The state of the task.
    status: TaskStatus
    /// When `true`, the title is not displayed.
    hide_title: Bool?
    /// Icon associated with the task.
    icon: TaskIcon?
    /// Details of the task. Up to 12,000 characters.
    details: String?
    /// Output of the task. Up to 12,000 characters.
    output: String?
    /// Sources used to produce the task's output. At most 50.
    sources: List(TaskSource)?
  }
  /// Updates the title of the plan when `task_display_mode` is `plan`.
  plan_update PlanUpdateChunk {
    /// The new title of the plan.
    title: String
  }
  /// Passes blocks within the message. At most 50 blocks per stream.
  blocks BlocksChunk {
    /// The blocks to add.
    blocks: List(Block)
  }
  .. UnknownStreamChunk
}

# ------------------------------------------------------------ scheduled messages

# The docs show this as an integer in `chat.scheduledMessages.list` and as a
# string in `chat.scheduleMessage`.
/// The `post_at` of a scheduled message, as an integer or a string.
oneof ScheduledPostAt {
  ScheduledPostAtUnix(Int)
  ScheduledPostAtString(String)
}

# The docs show this as a string (`Q1298393284`) in `chat.scheduleMessage`
# and as an integer in `chat.scheduledMessages.list`.
/// A scheduled message ID, as a string or an integer.
oneof ScheduledMessageId {
  ScheduledMessageIdString(String)
  ScheduledMessageIdInt(Int)
}

/// A pending scheduled message.
record ScheduledMessage {
  /// The ID of the scheduled message.
  id: ScheduledMessageId
  /// The channel the message will be posted to.
  channel_id: String?
  /// Unix timestamp of when the message will be posted.
  post_at: Int?
  /// Unix timestamp of when the message was scheduled.
  date_created: Int?
  /// The text of the message.
  text: String?
}

# ------------------------------------------------------------ methods

method chat.postMessage {
  args {
    /// The message text: the whole message, or the notification and
    /// screen-reader fallback when `blocks` or `attachments` are set.
    /// Required by slackline so messages are never empty in notifications.
    text: String!
    /// A list of structured attachments.
    attachments: List(Attachment)
    /// A list of structured blocks.
    blocks: List(Block)
    /// A JSON object with `event_type` and `event_payload` fields, or Work
    /// Object entity metadata. Metadata you post to Slack is accessible to
    /// any app or user who is a member of that workspace.
    metadata: MessageMetadata
    parse: ParseMode
  }
  response {
    /// The ID of the conversation the message was posted to.
    channel: String
    /// The timestamp ID of the posted message.
    ts: String
    /// The message as parsed by Slack. May differ from what was sent.
    message: Message?
    /// A warning, such as `message_truncated`.
    warning: String?
    response_metadata: ResponseMetadata?
  }
}

method chat.postEphemeral {
  args {
    /// The message text: the whole message, or the notification and
    /// screen-reader fallback when `blocks` or `attachments` are set.
    /// Required by slackline so messages are never empty in notifications.
    text: String!
    /// A list of structured attachments.
    attachments: List(Attachment)
    /// A list of structured blocks.
    blocks: List(Block)
    /// Work Object entity metadata. Set only `entities`: ephemeral messages
    /// are not stored, so event metadata does not apply.
    metadata: MessageMetadata
    parse: ParseMode
  }
  response {
    /// The timestamp of the ephemeral message. It cannot be used with
    /// `chat.update`.
    message_ts: String
    response_metadata: ResponseMetadata?
  }
}

method chat.update {
  args {
    /// Pass true to update the message as the authed user. Bot users in this
    /// context are considered authed users.
    as_user: Bool
    /// A list of structured attachments. Without it, Slack keeps the previous
    /// attachments. Send an empty list to remove them.
    attachments: List(Attachment)
    /// A list of structured attachments for unfurled content.
    unfurled_attachments: List(Attachment)
    /// A list of structured blocks. Pass an empty list to remove the previous
    /// blocks.
    blocks: List(Block)
    /// A JSON object with `event_type` and `event_payload` fields. If omitted,
    /// the previous metadata is kept.
    metadata: MessageMetadata
    /// Find and link channel names and usernames. If not specified, the
    /// original value set for the message is overwritten with the default.
    link_names: Bool
    parse: ParseMode
  }
  response {
    /// The ID of the conversation containing the message.
    channel: String
    /// The timestamp of the updated message.
    ts: String
    /// The text of the updated message.
    text: String?
    /// The updated message.
    message: Message?
    response_metadata: ResponseMetadata?
  }
}

method chat.scheduleMessage {
  args {
    /// The message text: the whole message, or the notification and
    /// screen-reader fallback when `blocks` or `attachments` are set.
    /// Required by slackline so messages are never empty in notifications.
    text: String!
    /// A list of structured attachments.
    attachments: List(Attachment)
    /// A list of structured blocks.
    blocks: List(Block)
    /// A JSON object with `event_type` and `event_payload` fields. Messages
    /// scheduled with `metadata` currently do not post (a documented bug).
    metadata: MessageMetadata
    parse: ParseMode
  }
  response {
    /// The ID of the conversation the message will be posted to.
    channel: String
    /// The ID of the scheduled message, for `chat.deleteScheduledMessage`.
    scheduled_message_id: String
    /// When the message will be posted.
    post_at: ScheduledPostAt?
    /// The scheduled message.
    message: Message?
    response_metadata: ResponseMetadata?
  }
}

method chat.scheduledMessages.list {
  response {
    /// The pending scheduled messages.
    scheduled_messages: List(ScheduledMessage)?
    response_metadata: ResponseMetadata?
  }
}

method chat.deleteScheduledMessage {
  response Nil
}

method chat.delete {
  response {
    /// The ID of the conversation the message was deleted from.
    channel: String
    /// The timestamp of the deleted message.
    ts: String
  }
}

method chat.getPermalink {
  response {
    /// The ID of the conversation containing the message.
    channel: String
    /// The permalink URL of the message.
    permalink: String
  }
}

method chat.meMessage {
  response {
    /// The ID of the conversation the message was posted to.
    channel: String
    /// The timestamp of the posted message.
    ts: String
  }
}

method chat.unfurl {
  args {
    /// A map keyed on the URLs in the message, pointing to their unfurl
    /// blocks or a single message attachment. Either `unfurls` or `metadata`
    /// must be provided.
    unfurls: Dict(Unfurl)
    /// Text with simple formatting, sent as an ephemeral message that asks
    /// the user to authenticate. Implies `user_auth_required`.
    user_auth_message: String
    /// Blocks sent as an ephemeral message inviting the user to authenticate.
    /// They override the default buttons of `user_auth_message`.
    user_auth_blocks: List(Block)
    /// Work Object entities for the unfurled resources, in `entities`. Either
    /// `unfurls` or `metadata` must be provided.
    metadata: MessageMetadata
    source: UnfurlSource
  }
  response Nil
}

method chat.startStream {
  args {
    /// Streaming chunks: markdown text, task updates, plan updates or
    /// blocks. Cannot be mixed with `markdown_text` within one stream.
    chunks: List(StreamChunk)
    /// The encoded ID of the user to receive the streaming text. Required
    /// when streaming to channels.
    recipient_user_id: String
    task_display_mode: TaskDisplayMode
  }
  response {
    /// The ID of the conversation the stream is posted to.
    channel: String
    /// The timestamp of the streaming message.
    ts: String
    response_metadata: ResponseMetadata?
  }
}

method chat.appendStream {
  args {
    /// The timestamp of the streaming message.
    ts: String
    /// Streaming chunks: markdown text, task updates, plan updates or
    /// blocks. Cannot be mixed with `markdown_text` within one stream.
    chunks: List(StreamChunk)
  }
  response {
    /// The ID of the conversation the stream is posted to.
    channel: String
    /// The timestamp of the streaming message.
    ts: String
    response_metadata: ResponseMetadata?
  }
}

method chat.stopStream {
  args {
    /// The timestamp of the streaming message.
    ts: String
    /// Streaming chunks: markdown text, task updates, plan updates or
    /// blocks. Cannot be mixed with `markdown_text` within one stream.
    chunks: List(StreamChunk)
    /// Blocks rendered at the bottom of the finalized message. Up to 50.
    blocks: List(Block)
    /// A JSON object with `event_type` and `event_payload` fields. Metadata
    /// you post to Slack is accessible to any app or user who is a member of
    /// that workspace.
    metadata: MessageMetadata
    session_status: SessionStatus
  }
  response {
    /// The ID of the conversation the stream was posted to.
    channel: String
    /// The timestamp of the streamed message.
    ts: String
    /// The finalized message.
    message: Message?
    response_metadata: ResponseMetadata?
  }
}

/// How Slack parses message text. See the formatting docs.
enum ParseMode {
  none as ParseNone
  full as ParseFull
}

/// How a stream displays task updates.
enum TaskDisplayMode {
  timeline
  plan
}

/// The status to leave an agent session in when a stream stops.
enum SessionStatus {
  active as SessionActive
  processing as SessionProcessing
  suspended as SessionSuspended
  closed as SessionClosed
}

/// Where the unfurled link was posted.
enum UnfurlSource {
  composer
  conversations_history
}
