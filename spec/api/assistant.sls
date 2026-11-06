//// Assistant and AI app threads: real-time search, thread status, titles and suggested prompts.
module slackline/api/assistant

/// A message sent directly before or after a search result.
record ContextMessage {
  /// Text of the message.
  text: String?
  /// Author of the message.
  user_id: String?
  # The docs example spells the key `user_id:`.
  /// Author of the message.
  "user_id:" as user_id_colon: String?
  /// Display name of the author.
  author_name: String?
  /// Timestamp of the message.
  ts: String?
  /// Blocks of the message, when `include_message_blocks` is set.
  blocks: List(Block)?
}

/// Messages surrounding a search result.
record SearchContextMessages {
  /// Messages sent before the result.
  before: List(ContextMessage)?
  /// Messages sent after the result.
  after: List(ContextMessage)?
}

/// A message found by `assistant.search.context`.
record SearchMessageResult {
  /// Display name of the author.
  author_name: String?
  /// Author of the message.
  author_user_id: String?
  team_id: String?
  channel_id: String?
  /// Name of the channel the message is in.
  channel_name: String?
  /// Timestamp of the message.
  message_ts: String?
  /// Timestamp of the thread the message is in, if any.
  thread_ts: String?
  /// Text content of the message.
  content: String?
  /// Whether the author is a bot.
  is_author_bot: Bool?
  /// Permalink to the message.
  permalink: String?
  /// Blocks of the message, when `include_message_blocks` is set.
  blocks: List(Block)?
  /// Messages surrounding this one, when `include_context_messages` is set.
  context_messages: SearchContextMessages?
}

/// A file found by `assistant.search.context`.
record SearchFileResult {
  file_id: String?
  /// User who uploaded the file.
  uploader_user_id: String?
  /// Author of the file.
  author_user_id: String?
  /// Display name of the author.
  author_name: String?
  team_id: String?
  /// Unix timestamp of creation.
  date_created: Int?
  /// Unix timestamp of the last update.
  date_updated: Int?
  title: String?
  /// MIME type of the file.
  file_type: String?
  permalink: String?
  /// Text content of the file.
  content: String?
}

/// A channel found by `assistant.search.context`.
record SearchChannelResult {
  team_id: String?
  /// User who created the channel.
  creator_user_id: String?
  /// Display name of the creator.
  creator_name: String?
  /// Unix timestamp of creation.
  date_created: Int?
  /// Unix timestamp of the last update.
  date_updated: Int?
  name: String?
  topic: String?
  purpose: String?
  permalink: String?
}

/// A user found by `assistant.search.context`.
record SearchUserResult {
  user_id: String?
  /// Link to the user's profile.
  permalink: String?
  full_name: String?
  /// The user's title.
  title: String?
  timezone: String?
  email: String?
  /// URL of the user's profile picture.
  profile_pic_permalink: String?
}

/// Results of `assistant.search.context`, grouped by content type.
record SearchContextResults {
  messages: List(SearchMessageResult)?
  files: List(SearchFileResult)?
  channels: List(SearchChannelResult)?
  users: List(SearchUserResult)?
}

method assistant.search.context {
  args {
    /// Search term clauses. Results match every clause. Between 1 and 5.
    term_clauses: List(String)? json
    # The docs show this argument in the usage examples, not in the arguments list.
    /// Groups of keywords. A result matches any keyword in each group.
    keywords_clauses: List(List(String))? json
    sort: SearchSort
    sort_dir: SortDirection
  }
  response {
    /// Search results by content type.
    results: SearchContextResults?
    response_metadata: ResponseMetadata?
  }
}

method assistant.search.info {
  response {
    /// Whether AI search is enabled for the workspace.
    is_ai_search_enabled: Bool?
  }
}

method assistant.threads.setStatus {
  args {
    /// Messages to rotate through as a loading indicator. Between 1 and 10.
    loading_messages: List(String)? json
  }
  response Nil
}

method assistant.threads.setSuggestedPrompts {
  args {
    /// Up to four prompts, each with a `title` and `message`.
    prompts: List(SuggestedPrompt) json
  }
  response Nil
}

method assistant.threads.setTitle {
  response Nil
}

