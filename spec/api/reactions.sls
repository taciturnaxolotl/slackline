//// Emoji reactions (`reactions.*`).
module slackline/api/reactions

/// The kind of a reacted item.
enum ReactedItemType {
  message as ReactedMessageType
  file as ReactedFileType
  file_comment as ReactedFileCommentType
  .. UnknownReactedItemType
}

/// A comment on a file.
record ReactedFileComment {
  /// The comment ID.
  id: String?
  /// Unix timestamp of when the comment was created.
  created: Int?
  /// Unix timestamp of the comment.
  timestamp: Int?
  /// The user who wrote the comment.
  user: String?
  /// The comment text.
  comment: String?
  /// Whether this is the file's initial comment.
  is_intro: Bool?
  /// Reactions to the comment.
  reactions: List(Reaction)?
}

/// An item with reactions. Which fields are set depends on `type`. The
/// `users` of each reaction always contain the calling user but may not list
/// everyone. `count` is always the full count.
record ReactedItem {
  # The docs example leaves this out for a file comment.
  /// `message`, `file` or `file_comment`.
  "type" as item_type: ReactedItemType?
  /// The channel of the message, for `message` items.
  channel: String?
  /// The message, for `message` items.
  message: Message?
  /// The file, for `file` and `file_comment` items.
  file: File?
  /// The comment, for `file_comment` items.
  comment: ReactedFileComment?
}

/// Page-based pagination details.
record ReactionsPaging {
  /// Number of items per page.
  count: Int?
  /// Total number of items.
  total: Int?
  /// The current page.
  page: Int?
  /// Total number of pages.
  pages: Int?
}

method reactions.add {
  response Nil
}

method reactions.get {
  response {
    /// `message`, `file` or `file_comment`.
    "type" as item_type: ReactedItemType?
    /// The channel of the message, for `message` items.
    channel: String?
    /// The message and its reactions, for `message` items.
    message: Message?
    /// The file, for `file` and `file_comment` items.
    file: File?
    /// The comment, for `file_comment` items.
    comment: ReactedFileComment?
  }
}

method reactions.list {
  response {
    /// Items the user reacted to. A message with several reactions from the
    /// user appears once per reaction.
    items: List(ReactedItem)?
    /// Page-based pagination details.
    paging: ReactionsPaging?
    response_metadata: ResponseMetadata?
  }
}

method reactions.remove {
  response Nil
}
