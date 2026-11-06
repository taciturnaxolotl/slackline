//// Starred items (`stars.*`). Later replaced stars in the Slack clients.
//// `stars.list` does not show newly saved items.
module slackline/api/stars

/// The kind of a starred item.
enum StarredItemType {
  message as StarredMessageType
  file as StarredFileType
  file_comment as StarredFileCommentType
  channel as StarredChannelType
  im as StarredImType
  group as StarredGroupType
  .. UnknownStarredItemType
}

/// A comment on a file.
record StarredFileComment {
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

/// A starred item. Which fields are set depends on `type`.
record StarredItem {
  /// The kind of item.
  "type" as item_type: StarredItemType?
  /// The channel ID, for `message`, `channel` and `im` items.
  channel: String?
  /// The private channel ID, for `group` items.
  group: String?
  /// The message, for `message` items.
  message: Message?
  /// The file, for `file` and `file_comment` items.
  file: File?
  /// The comment, for `file_comment` items.
  comment: StarredFileComment?
  /// Unix timestamp of when the item was starred.
  date_create: Int?
}

/// Page-based pagination details.
record StarsPaging {
  /// Number of items per page.
  count: Int?
  /// Number of items per page.
  per_page: Int?
  /// Number of items carried over from the previous page.
  spill: Int?
  /// Total number of items.
  total: Int?
  /// The current page.
  page: Int?
  /// Total number of pages.
  pages: Int?
}

method stars.add {
  response Nil
}

method stars.list {
  response {
    /// The starred items.
    items: List(StarredItem)?
    /// Page-based pagination details.
    paging: StarsPaging?
    response_metadata: ResponseMetadata?
  }
}

method stars.remove {
  response Nil
}
