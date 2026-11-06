//// Slack Lists: create and update Lists, manage access, edit items and export Lists.
module slackline/api/slack_lists

/// An option of a select column.
record ListChoice {
  /// Value for the option.
  value: String
  /// Label of the option displayed in the List.
  label: String
  /// Color of the option: `indigo`, `blue`, `cyan`, `pink`, `yellow`, `green`, `gray`, `red`, `purple`, `orange` or `brown`.
  color: String?
}

/// Default values for some columns.
record ListColumnDefaultValue {
  /// Default user IDs for a people column.
  user: List(String)?
  /// Default channel IDs for a channel column.
  channel: List(String)?
  /// Default select values. Each must be a value from `choices`.
  select: List(String)?
}

/// Options of a List column.
record ListColumnOptions {
  /// Options of a select column.
  choices: List(ListChoice)?
  /// `single_select`, `multi_select`, `single_entity` or `multi_entity`.
  format: String?
  /// Number of decimal places of a number column.
  precision: Int?
  /// Date format of a date column, such as `default` or `DD/MM/YYYY`.
  date_format: String?
  /// Emoji displayed by rating and vote columns, such as `:star:`.
  emoji: String?
  /// The team the emoji belongs to.
  emoji_team_id: String?
  /// Maximum value of a rating column.
  max: Int?
  /// Typed default values for the column.
  default_value_typed: ListColumnDefaultValue?
  # The docs examples only show `null`.
  /// Default value, as returned in responses.
  default_value: Value?
  /// Whether entity names are shown in people, channel and canvas columns. Defaults to true.
  show_member_name: Bool?
  /// Whether users are notified when a people column is updated.
  notify_users: Bool?
}

/// A column to create with `slackLists.create`.
record ListColumnInput {
  /// Key of the column.
  key: String
  /// Name of the column displayed in the List.
  name: String
  /// Column type, such as `text`, `number`, `select`, `date`, `user`, `checkbox` or `rating`.
  type: String
  /// Whether the column is the primary column. It must be a text column.
  is_primary_column: Bool?
  /// Column options.
  options: ListColumnOptions?
}

/// A column of a List.
record ListColumn {
  /// Encoded column ID.
  id: String
  /// Key of the column.
  key: String?
  /// Name of the column displayed in the List.
  name: String?
  /// Column type, such as `text`, `rich_text`, `number`, `select`, `todo_completed` or `rating`.
  type: String?
  /// Whether the column is the primary column.
  is_primary_column: Bool?
  /// Column options.
  options: ListColumnOptions?
}

/// A column as placed in a List view.
record ListViewColumn {
  id: String
  key: String?
  visible: Bool?
  position: String?
}

/// A view of a List.
record ListView {
  id: String
  name: String?
  /// View type, such as `table` or `record`.
  type: String?
  is_locked: Bool?
  position: String?
  columns: List(ListViewColumn)?
  date_created: Int?
  created_by: String?
  stick_column_left: Bool?
  is_all_items_view: Bool?
  default_view_key: String?
  show_completed_items: Bool?
}

/// How a List was created.
record ListCreationSource {
  /// Such as `copy_from_list`.
  type: String?
  /// ID of the source, such as the copied List.
  reference_id: String?
}

/// Structure and settings of a List.
record ListMetadata {
  /// Columns of the List.
  schema: List(ListColumn)?
  /// Columns of subtasks.
  subtask_schema: List(ListColumn)?
  views: List(ListView)?
  integrations: List(Value)?
  icon: String?
  description: String?
  /// Rich text description of the List.
  description_blocks: List(Block)?
  is_trial: Bool?
  creation_source: ListCreationSource?
  /// Whether the List tracks todo tasks.
  todo_mode: Bool?
  default_view: String?
}

/// Size limits and counts of a List.
record ListLimits {
  over_row_maximum: Bool?
  row_count_limit: Int?
  row_count: Int?
  archived_row_count: Int?
  over_column_maximum: Bool?
  column_count: Int?
  column_count_limit: Int?
  over_view_maximum: Bool?
  view_count: Int?
  view_count_limit: Int?
  max_attachments_per_cell: Int?
}

/// A List, which is a file of type `list`.
record ListFile {
  id: String
  created: Int?
  timestamp: Int?
  updated: Int?
  name: String?
  title: String?
  mimetype: String?
  filetype: String?
  pretty_type: String?
  /// User who created the List.
  user: String?
  user_team: String?
  editable: Bool?
  size: Int?
  mode: String?
  is_external: Bool?
  external_type: String?
  is_public: Bool?
  public_url_shared: Bool?
  display_as_bot: Bool?
  username: String?
  list_metadata: ListMetadata?
  list_limits: ListLimits?
  url_private: String?
  url_private_download: String?
  permalink: String?
  permalink_public: String?
  last_editor: String?
  list_csv_download_url: String?
  is_starred: Bool?
  skipped_shares: Bool?
  teams_shared_with: List(String)?
  is_restricted_sharing_enabled: Bool?
  has_rich_preview: Bool?
  file_access: String?
  /// The caller's access to the List, such as `owner`.
  access: String?
  org_or_workspace_access: String?
  is_ai_suggested: Bool?
}

/// A message referenced by a message cell.
record ListMessageValue {
  /// The message URL.
  value: String?
  channel_id: String?
  ts: String?
  thread_ts: String?
}

/// A link in a link cell, as returned.
record ListLinkValue {
  /// The link URL.
  "originalUrl" as original_url: String?
  /// Metadata retrieved from the link URL.
  attachment: Value?
  /// If true, the URL is displayed instead of the website name.
  "displayAsUrl" as display_as_url: Bool?
  /// The name to display in the cell.
  "displayName" as display_name: String?
}

/// A link to set in a link cell.
record ListLinkInput {
  original_url: String
  display_as_url: Bool?
  display_name: String?
}

/// A message referenced by a reference cell.
record ListMessageReference {
  channel_id: String
  ts: String
  thread_ts: String?
}

/// A List item referenced by a reference cell.
record ListRecordReference {
  list_id: String
  row_id: String
}

/// A file referenced by a reference cell.
record ListFileReference {
  file_id: String
}

/// A canvas section referenced by a reference cell.
record ListCanvasSectionReference {
  file_id: String
  section_id: String
}

/// A reference to another entity in a reference cell. Set one field.
record ListReference {
  message: ListMessageReference?
  list_record: ListRecordReference?
  file: ListFileReference?
  canvas_section: ListCanvasSectionReference?
}

/// The value of one cell of a List item.
record ListField {
  /// Identifier of the column (an encoded column ID or any text). `column_id` replaces it.
  key: String?
  column_id: String?
  /// Untyped cell value: a boolean, string, number or null.
  value: Value?
  /// Plain text fallback of the cell value.
  text: String?
  rich_text: List(Block)?
  message: List(ListMessageValue)?
  number: List(Float)?
  /// Encoded option IDs.
  select: List(String)?
  /// Dates as `YYYY-MM-DD`.
  date: List(String)?
  user: List(String)?
  channel: List(String)?
  /// Encoded file IDs.
  attachment: List(String)?
  # The docs template shows a list of booleans and the examples a single
  # boolean, so the type is `Value`.
  /// Checkbox state: a boolean or a list of booleans.
  checkbox: Value?
  email: List(String)?
  phone: List(String)?
  rating: List(Int)?
  /// Unix timestamps.
  timestamp: List(Int)?
  link: List(ListLinkValue)?
  reference: List(ListReference)?
}

/// Reminder information for a List item or cell.
record ListSavedReminder {
  is_archived: Bool?
  date_due: Int?
  date_completed: Int?
  /// `archived`, `in_progress` or `completed`.
  state: String?
}

/// A List item (row).
record ListItem {
  id: String
  list_id: String?
  date_created: Int?
  created_by: String?
  updated_by: String?
  updated_timestamp: String?
  /// Present if the item is a subtask.
  parent_record_id: String?
  archived: Bool?
  /// Whether the caller is subscribed to the item.
  is_subscribed: Bool?
  /// Values of the item's cells.
  fields: List(ListField)?
  saved: ListSavedReminder?
  /// Reminders for specific cells, keyed by column ID.
  saved_fields: Dict(ListSavedReminder)?
}

/// A cell value to write. Set `column_id` and one typed value.
record ListCellInput {
  column_id: String
  /// The item to update (for `slackLists.items.update`).
  row_id: String?
  /// Create a new row for this cell.
  row_id_to_create: Bool?
  /// Text cells are always rich text.
  rich_text: List(Block)?
  user: List(String)?
  /// Dates as `YYYY-MM-DD`.
  date: List(String)?
  /// Option values.
  select: List(String)?
  checkbox: Bool?
  number: List(Float)?
  email: List(String)?
  phone: List(String)?
  /// Encoded file IDs.
  attachment: List(String)?
  link: List(ListLinkInput)?
  /// Message URLs.
  message: List(String)?
  rating: List(Int)?
  timestamp: List(Int)?
  channel: List(String)?
  reference: List(ListReference)?
}

method slackLists.access.delete {
  response {
    /// Channels whose access could not be revoked.
    failed_to_update_channel_ids: List(String)?
    /// Users whose access could not be revoked.
    failed_to_update_user_ids: List(String)?
  }
}

method slackLists.access.set {
  response Nil
}

method slackLists.create {
  args {
    description_blocks: List(Block)? json
    schema: List(ListColumnInput)? json
  }
  response {
    list_id: String
    /// Columns of the new List.
    list_metadata: ListMetadata?
  }
}

method slackLists.download.get {
  response {
    /// Status of the export job, such as `COMPLETED`.
    status: String?
    /// Where to download the export once complete.
    download_url: String?
  }
}

method slackLists.download.start {
  response {
    /// Pass to `slackLists.download.get`.
    job_id: String
  }
}

method slackLists.items.create {
  args {
    /// Initial cell values of the item.
    initial_fields: List(ListCellInput)? json
  }
  response {
    item: ListItem
  }
}

method slackLists.items.delete {
  response Nil
}

method slackLists.items.deleteMultiple {
  args {
    ids: List(String) json
  }
  response Nil
}

method slackLists.items.info {
  response {
    list: ListFile?
    record: ListItem
    subtasks: List(ListItem)?
  }
}

method slackLists.items.list {
  response {
    items: List(ListItem)?
    /// The parent List, when `include_list` is set.
    list: ListFile?
    response_metadata: ResponseMetadata?
  }
}

method slackLists.items.update {
  args {
    /// Cells to update (1 to 100).
    cells: List(ListCellInput) json
  }
  response Nil
}

method slackLists.update {
  args {
    description_blocks: List(Block)? json
  }
  response Nil
}
