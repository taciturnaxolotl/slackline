//// Channel bookmarks (`bookmarks.*`).
module slackline/api/bookmarks

/// A bookmark in a channel's header.
record Bookmark {
  /// The bookmark ID.
  id: String
  /// The channel the bookmark belongs to.
  channel_id: String?
  /// Title of the bookmark.
  title: String?
  /// The bookmarked link.
  link: String?
  /// Emoji tag applied to the bookmark.
  emoji: String?
  /// URL of the bookmark's icon.
  icon_url: String?
  /// The type of the bookmark, such as `link`.
  "type" as bookmark_type: String?
  /// ID of the bookmarked entity, for message and file bookmarks.
  entity_id: String?
  /// Unix timestamp of when the bookmark was created.
  date_created: Int?
  /// Unix timestamp of the last update, `0` if never updated.
  date_updated: Int?
  /// Sort key of the bookmark.
  rank: String?
  /// The user who last updated the bookmark.
  last_updated_by_user_id: String?
  /// The team of the user who last updated the bookmark.
  last_updated_by_team_id: String?
  /// ID of the shortcut, for workflow bookmarks.
  shortcut_id: String?
  /// ID of the app, for app bookmarks.
  app_id: String?
}

/// A response holding one bookmark.
record BookmarkResponse {
  /// The bookmark.
  bookmark: Bookmark
}

method bookmarks.add {
  args {
    access_level: BookmarkAccessLevel
  }
  response BookmarkResponse
}

method bookmarks.edit {
  response BookmarkResponse
}

method bookmarks.list {
  response {
    /// The channel's bookmarks.
    bookmarks: List(Bookmark)?
  }
}

method bookmarks.remove {
  response Nil
}

/// The access level of a bookmark.
enum BookmarkAccessLevel {
  read as ReadAccess
  write as WriteAccess
}
