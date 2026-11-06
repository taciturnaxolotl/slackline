//// Types that more than one module uses, such as reactions (on messages and
//// files) and the enums that several Web API families share.
module slackline/common

/// The order to sort results in.
enum SortDirection {
  asc as Ascending
  desc as Descending
}

/// A reaction on a message, file or file comment.
record Reaction {
  /// The emoji name, without colons.
  name: String
  /// The total number of users who reacted. It can be more than the length of `users`.
  count: Int?
  /// A possibly incomplete list of users who reacted. The calling user is
  /// always included if they reacted.
  users: List(String)?
  url: String?
}

/// The severity of an app activity log entry.
enum ActivityLogLevel {
  "trace" as LogLevelTrace
  "debug" as LogLevelDebug
  "info" as LogLevelInfo
  "warn" as LogLevelWarn
  "error" as LogLevelError
  "fatal" as LogLevelFatal
  .. UnknownActivityLogLevel
}

/// One log entry from `apps.activities.list` or `admin.apps.activities.list`.
record AppActivity {
  app_id: String?
  /// The severity of the entry.
  level: ActivityLogLevel?
  /// Such as `function_execution_started` or `workflow_execution_result`.
  event_type: String?
  /// `slack` or `developer`.
  source: String?
  /// `events_api`, `workflows`, `functions` or `tables`.
  component_type: String?
  /// `FnXXXXXX` for functions, `WfXXXXXX` for workflows.
  component_id: String?
  /// Event details. The shape depends on `event_type`.
  payload: Value?
  /// When the entry was logged (epoch microseconds).
  created: Int?
  /// The trace ID of the event.
  trace_id: String?
}

/// Canvas content. Only markdown is supported, limited to 1 MiB.
record CanvasDocumentContent {
  type = "markdown"
  /// The markdown content of the canvas, up to 1,048,576 characters.
  markdown: String
}

/// How the token is being granted.
enum GrantType {
  authorization_code
  refresh_token
}

/// How to sort search results.
enum SearchSort {
  score as SortByScore
  timestamp as SortByTimestamp
}

/// The category of a Slackbot skill.
enum SkillCategory {
  communication
  customer_support
  data_and_analytics
  engineering
  product_management
  productivity
  professional_development
  project_management
  sales
  system
  team_management
  other
  .. UnknownSkillCategory
}
