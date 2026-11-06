//// Agent sessions and code channels: create, configure and render views in agent channels.
module slackline/api/agents

/// A slash command an agent registers in a code channel.
record AgentCommand {
  /// Command name without the leading slash. 1 to 31 characters, unique in the set.
  name: String
  /// What the command does, shown in the composer typeahead.
  description: String?
  /// Hint for the command's arguments, such as `[title]`.
  argument_hint: String?
}

/// An item in a code channel's context bar.
record ContextBarItem {
  /// Unique identifier for the item within the channel. Maximum 64 characters.
  key: String
  /// Display text. Maximum 128 characters.
  label: String
  /// Icon beside the label: `branch`, `folder`, `hierarchy`, `life-ring`, `link`, `globe`, `terminal`, `code`, `search` or `lock`.
  icon: String?
  /// Makes the item a link to this URL. Maximum 2048 characters.
  url: String?
  /// `info` (default, informational) or `action` (clicking delivers a `code_channel_action` event).
  item_type: String?
}

/// Which message in a code channel is the current session summary.
record SummaryMessage {
  /// Timestamp of the summary message in the code channel.
  message_ts: String
  /// If the summary is a thread reply, the parent message timestamp.
  thread_ts: String?
}

/// Code channel properties to set with `agents.conversations.setProperties`. Only provided fields are updated.
record CodeChannelProperties {
  /// Items displayed in the channel context bar (max 5). The array replaces the current set.
  context_bar_items: List(ContextBarItem)?
  /// Records which message in the channel represents the current summary.
  summary_message: SummaryMessage?
}

/// The external resource an agent session is centered on.
record AgentResource {
  /// URL of the external resource. Maximum 2048 characters.
  url: String?
  /// Type of the external resource. Maximum 64 characters.
  resource_type: String?
  /// Display title of the external resource. Maximum 255 characters.
  title: String?
  /// Provider of the external resource. Maximum 64 characters.
  provider: String?
}

/// Content-Security-Policy domain declarations for an `html` view.
record ViewCsp {
  /// Additional `https://` origins the view loads resources from.
  resource_domains: List(String)?
}

/// A view attached to a code channel.
record AgentSessionView {
  /// Encoded channel tab ID.
  view_id: String
  /// View type: `html`, `diff`, `block_kit` or `canvas`.
  type: String?
  /// Agent-assigned stable key. Absent for diff views.
  view_key: String?
  /// Encoded ID of the backing file.
  file_id: String?
  /// Display label for the view tab.
  name: String?
  /// Display label for the view tab (the name used in the response example).
  label: String?
  /// Server-assigned content version.
  content_version: Int?
  /// Unix timestamp of when the view was created.
  date_added: Int?
}

/// A reply in a canvas comment thread.
record CanvasCommentReply {
  /// Timestamp of the reply.
  ts: String?
  /// User who wrote the reply.
  user_id: String?
  /// Text of the reply.
  text: String?
}

/// A comment thread on a canvas.
record CanvasComment {
  /// ID of the comment thread.
  id: String
  /// Timestamp of the top-level comment.
  ts: String?
  /// User who wrote the comment.
  user_id: String?
  /// Text of the comment.
  text: String?
  /// The highlighted canvas text the comment is anchored to.
  quoted_text: String?
  /// Whether the thread is resolved.
  is_resolved: Bool?
  /// Threaded replies, oldest first (at most the 100 most recent).
  replies: List(CanvasCommentReply)?
  /// Whether older replies were dropped.
  has_more_replies: Bool?
}

method agents.conversations.archive {
  response Nil
}

method agents.conversations.create {
  args {
    /// A friendly display name for the code channel. Optional when `origin_channel_id` and `origin_message_ts` are provided.
    name: String?
  }
  response {
    /// ID of the created (or existing, for a repeated `session_id`) code channel.
    channel_id: String
  }
}

method agents.conversations.getCanvas {
  args {
    content_format: CanvasContentFormat
  }
  response {
    canvas_id: String
    /// Title of the canvas.
    title: String?
    /// Canvas content in the requested format (markdown).
    content: String?
    /// Comment threads, oldest first (at most the 100 most recent).
    comments: List(CanvasComment)?
    /// Whether older comment threads were dropped.
    has_more_comments: Bool?
  }
}

method agents.conversations.listViews {
  response {
    /// All views in the channel (up to 5).
    views: List(AgentSessionView)?
  }
}

method agents.conversations.removeView {
  response {
    channel_id: String
    /// ID of the removed view.
    view_id: String?
  }
}

method agents.conversations.setCanvasContent {
  response {
    canvas_id: String
    /// Number of canvas sections that changed.
    sections_changed_count: Int?
  }
}

method agents.conversations.setCommands {
  args {
    /// Full set of commands for the calling agent in this channel. Pass an empty list to clear them. At most 10.
    commands: List(AgentCommand) json
  }
  response {
    channel_id: String
    /// Number of commands registered.
    command_count: Int?
  }
}

method agents.conversations.setProperties {
  args {
    /// Code channel properties to set. Only provided fields are updated.
    code_channel: CodeChannelProperties?
    /// Agent resource properties to set. Only provided fields are updated.
    agent_resource: AgentResource?
    status: AgentStatus
  }
  response {
    channel_id: String
    /// Warning such as `too_many_context_bar_items` or `action_with_url_overridden_to_info`.
    warning: String?
  }
}

method agents.conversations.setView {
  args {
    /// Block Kit blocks to render in the view tab. Required when `type` is `block_kit`.
    blocks: List(Block)? json
    /// Content-Security-Policy domain declarations for the view.
    csp: ViewCsp?
    access_level: ViewAccessLevel
  }
  response {
    channel_id: String
    /// Encoded channel tab ID of the view. Use it as `tab_id` to link to the view.
    view_id: String
    /// Encoded ID of the backing file.
    file_id: String?
    /// Encoded ID of the canvas, for `canvas` views.
    canvas_id: String?
    /// Server-assigned content version, bumped on each update.
    content_version: Int?
    /// View type: `html`, `diff`, `block_kit` or `canvas`.
    type: String?
  }
}

method agents.sessions.rename {
  response {
    /// The new title of the session.
    title: String?
  }
}

method agents.sessions.setStatus {
  args {
    status: AgentStatus
  }
  response {
    /// Session-level status, derived from all agents in the session.
    status: String?
    /// The calling agent's own status.
    agent_status: String?
    /// Title of the session.
    title: String?
  }
}

/// The format of returned canvas content.
enum CanvasContentFormat {
  markdown as MarkdownFormat
}

/// The status of an agent conversation or session.
enum AgentStatus {
  active
  processing
  suspended
  closed
}

/// The access the channel gets to a view.
enum ViewAccessLevel {
  write as WriteAccess
  comment as CommentAccess
  read as ReadAccess
}
