//// Pinned items (`pins.*`).
module slackline/api/pins

/// The kind of a pinned item.
enum PinnedItemType {
  message as PinnedMessageType
  file as PinnedFileType
  file_comment as PinnedFileCommentType
  .. UnknownPinnedItemType
}

/// A comment on a file.
record PinnedFileComment {
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

/// An item pinned to a channel. Which fields are set depends on `type`.
record PinnedItem {
  /// `message`, `file` or `file_comment`.
  "type" as item_type: PinnedItemType?
  /// The channel the item is pinned to.
  channel: String?
  /// Unix timestamp of when the item was pinned.
  created: Int?
  /// The user who pinned the item.
  created_by: String?
  /// The pinned message, for `message` items.
  message: Message?
  /// The pinned file, for `file` and `file_comment` items.
  file: File?
  /// The pinned comment, for `file_comment` items.
  comment: PinnedFileComment?
}

method pins.add {
  response Nil
}

method pins.list {
  response {
    /// The pinned items.
    items: List(PinnedItem)?
  }
}

method pins.remove {
  response Nil
}
