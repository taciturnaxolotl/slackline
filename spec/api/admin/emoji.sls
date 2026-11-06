//// Admin emoji: manage custom emoji across an Enterprise organization.
module slackline/api/admin/emoji

/// A custom emoji from `admin.emoji.list`.
record AdminEmoji {
  /// The emoji image URL.
  url: String?
  /// When the emoji was added (Unix time).
  date_created: Int?
  /// The user who uploaded the emoji.
  uploaded_by: String?
}

method admin.emoji.add {
  args {
    /// The URL of a file to use as an image for the emoji. Square images under 128KB with transparent backgrounds work best.
    url: String!
  }
  response Nil
}

method admin.emoji.addAlias {
  response Nil
}

method admin.emoji.list {
  response {
    /// Custom emoji, keyed by name.
    emoji: Dict(AdminEmoji)?
    # Only the docs prose mentions this field.
    /// The last time the emoji set changed.
    cache_ts: String?
    response_metadata: ResponseMetadata?
  }
}

method admin.emoji.remove {
  response Nil
}

method admin.emoji.rename {
  response Nil
}
