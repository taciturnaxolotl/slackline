//// Legacy search (`search.*`). Slack recommends the Real-time Search API
//// (`assistant.search.context`) instead.
module slackline/api/search

/// Page-based pagination details.
record SearchPaging {
  /// Number of records per page.
  count: Int?
  /// Total number of records matching the query.
  total: Int?
  /// The page of records returned.
  page: Int?
  /// Total number of pages.
  pages: Int?
}

/// Pagination details by record position.
record SearchPagination {
  /// Position of the first record on this page.
  first: Int?
  /// Position of the last record on this page.
  last: Int?
  /// The page of records returned.
  page: Int?
  /// Total number of pages.
  page_count: Int?
  /// Number of records per page.
  per_page: Int?
  /// Total number of records matching the query.
  total_count: Int?
}

/// The conversation a matched message was posted in. For DMs `name` holds
/// the other user's ID.
record SearchMatchChannel {
  /// The conversation ID.
  id: String
  /// The conversation name.
  name: String?
  /// Whether the channel is shared with an external organization.
  is_ext_shared: Bool?
  /// Whether the conversation is a multi-person DM.
  is_mpim: Bool?
  /// Whether the channel is shared across an Enterprise organization.
  is_org_shared: Bool?
  /// Whether the channel is waiting to be shared externally.
  is_pending_ext_shared: Bool?
  /// Whether the channel is private.
  is_private: Bool?
  /// Whether the channel is shared.
  is_shared: Bool?
  /// Teams the channel is waiting to be shared with.
  pending_shared: List(String)?
}

/// A message next to a match, provided for context. Deprecated by Slack
/// since December 3, 2020.
record SearchContextMessage {
  /// The message ID within the search results.
  iid: String?
  /// The message timestamp.
  ts: String?
  /// The message type.
  "type" as message_type: String?
  /// The user who posted the message.
  user: String?
  /// The username of the poster.
  username: String?
  /// The message text.
  text: String?
}

/// A message matching a search query.
record SearchMessageMatch {
  /// The message timestamp.
  ts: String
  /// The message ID within the search results.
  iid: String?
  /// `message`, or `im` and `group` for DM and private group results.
  "type" as match_type: String?
  /// The user who posted the message.
  user: String?
  /// The username of the poster.
  username: String?
  /// The message text, with highlight markers when `highlight` is `true`.
  text: String?
  /// The team the message belongs to.
  team: String?
  /// A permalink to the message.
  permalink: String?
  /// The conversation the message was posted in.
  channel: SearchMatchChannel?
  /// The message blocks.
  blocks: List(Block)?
  /// The message attachments.
  attachments: List(Attachment)?
  /// Deprecated context message before the match.
  previous: SearchContextMessage?
  /// Deprecated context message two before the match.
  previous_2: SearchContextMessage?
  /// Deprecated context message after the match.
  next: SearchContextMessage?
  /// Deprecated context message two after the match.
  next_2: SearchContextMessage?
}

/// Messages matching a search query.
record SearchMessages {
  /// The matching messages on this page.
  matches: List(SearchMessageMatch)?
  /// Pagination details by record position.
  pagination: SearchPagination?
  /// Page-based pagination details.
  paging: SearchPaging?
  /// The (estimated) total number of matches.
  total: Int?
}

/// Files matching a search query.
record SearchFiles {
  /// The matching files on this page.
  matches: List(File)?
  /// Pagination details by record position.
  pagination: SearchPagination?
  /// Page-based pagination details.
  paging: SearchPaging?
  /// The (estimated) total number of matches.
  total: Int?
}

# The docs only show an empty list.
/// Posts that match a search query.
record SearchPosts {
  /// The matching posts.
  matches: List(Value)?
  /// The total number of matches.
  total: Int?
}

method search.all {
  args {
    sort: SearchSort
    sort_dir: SortDirection
  }
  response {
    /// The query that was run.
    query: String?
    /// Matching messages.
    messages: SearchMessages?
    /// Matching files.
    files: SearchFiles?
    /// Matching posts.
    posts: SearchPosts?
  }
}

method search.files {
  args {
    sort: SearchSort
    sort_dir: SortDirection
  }
  response {
    /// The query that was run.
    query: String?
    /// Matching files.
    files: SearchFiles?
  }
}

method search.messages {
  args {
    sort: SearchSort
    sort_dir: SortDirection
  }
  response {
    /// The query that was run.
    query: String?
    /// Matching messages.
    messages: SearchMessages?
  }
}

