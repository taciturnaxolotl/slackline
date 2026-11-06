//// Files shared in Slack: uploads, snippets, posts, canvases, lists, remote
//// files and emails. See <https://docs.slack.dev/reference/objects/file-object>.
////
//// Almost every field is optional: the fields present depend on the file's
//// type and on the API that returned it.
module slackline/file

/// A file object contains information about a file shared with a workspace.
record File {
  /// The ID of the file object. Optional because some responses (for example
  /// `reactions.list`) return file objects without one.
  id: String?
  /// Unix timestamp of when the file was created.
  created: Int?
  /// Deprecated. Slack sends it only for older clients.
  timestamp: Int?
  /// Name of the file. `null` for unnamed files.
  name: String?
  /// Title of the file.
  title: String?
  /// The file's mimetype.
  mimetype: String?
  /// The file's type, such as `gif`, `pdf` or `python`. Not a 1-to-1 mapping
  /// with `mimetype`. See the file types table on the file object page.
  filetype: String?
  /// A human-readable version of the type.
  pretty_type: String?
  /// The ID of the user who created the object.
  user: String?
  /// Team of the user who created the file.
  user_team: String?
  /// Team where the file originated.
  source_team: String?
  /// ID of the bot that uploaded the file.
  bot_id: String?
  /// Bot user ID associated with the file.
  bot_user_id: String?
  /// ID of the associated app.
  app_id: String?
  /// Name of the associated app.
  app_name: String?
  /// Whether files are stored in editable mode.
  editable: Bool?
  /// The filesize in bytes.
  size: Int?
  /// One of `hosted`, `external`, `snippet` or `post` (among others).
  mode: FileMode?
  /// File subtype.
  subtype: String?
  /// Current file state.
  state: String?
  /// Whether the master copy of the file is stored outside Slack.
  is_external: Bool?
  /// What kind of external file it is.
  external_type: ExternalFileType?
  /// ID of the file in an external system.
  external_id: String?
  /// URL of the file in an external system.
  external_url: String?
  /// `true` if the file is public.
  is_public: Bool?
  /// `true` if the file's public URL has been shared.
  public_url_shared: Bool?
  display_as_bot: Bool?
  username: String?
  /// URL with the file contents. Files hosted by Slack need an authorization
  /// header. For remote files it is the `external_url` from the app.
  url_private: String?
  /// Like `url_private`, with headers that force a browser download.
  url_private_download: String?
  /// A single page for the file containing details, comments and a download link.
  permalink: String?
  /// Points to the public file itself, if the file is public.
  permalink_public: String?
  /// For posts and snippets: the page at which the file can be edited.
  edit_link: String?
  /// For Post filetypes only: Unix timestamp of when the Post was last edited.
  updated: Int?
  /// IDs of channels the file is currently shared in.
  channels: List(String)?
  /// IDs of private groups the file is shared in (only those the caller is in).
  groups: List(String)?
  /// IDs of direct message channels the file is shared in.
  ims: List(String)?
  /// Where the file has been shared, keyed by visibility then channel ID.
  shares: FileShares?
  /// Whether there are additional shares not returned.
  has_more_shares: Bool?
  /// Whether some shares were skipped in the response.
  skipped_shares: Bool?
  /// A comment from the uploader, set when they commented at upload time.
  initial_comment: FileComment?
  comments_count: Int?
  /// Number of users who starred this file. Absent when nobody has.
  num_stars: Int?
  /// `true` if the calling user has starred the file, else omitted.
  is_starred: Bool?
  /// IDs of channels in which the file is currently pinned.
  pinned_to: List(String)?
  /// Reactions added to the file. `users` can be incomplete. `count` is exact.
  reactions: List(Reaction)?
  has_rich_preview: Bool?
  /// Alternative text for image files.
  alt_txt: String?
  /// Whether the file was AI-generated.
  ai_generated: Bool?
  /// How the media should be displayed.
  media_display_type: String?

  # Previews
  /// Plain-text preview for posts, or a few truncated lines for snippets.
  preview: String?
  /// Syntax-highlighted HTML preview of a snippet.
  preview_highlight: String?
  /// Total number of lines in a snippet.
  lines: Int?
  /// Number of lines not shown in the preview.
  lines_more: Int?
  /// Whether the preview was truncated.
  preview_is_truncated: Bool?
  preview_plain_text: String?

  # Images and thumbnails
  image_exif_rotation: Int?
  original_w: Int?
  original_h: Int?
  /// URL of a 64x64 thumbnail.
  thumb_64: String?
  /// URL of an 80x80 thumbnail (padded if the source is smaller).
  thumb_80: String?
  thumb_160: String?
  /// URL of a thumbnail whose longest side is at most 360 pixels.
  thumb_360: String?
  thumb_360_w: Int?
  thumb_360_h: Int?
  /// Animated 360px thumbnail for large animated GIFs.
  thumb_360_gif: String?
  thumb_480: String?
  thumb_480_w: Int?
  thumb_480_h: Int?
  thumb_480_gif: String?
  thumb_720: String?
  thumb_720_w: Int?
  thumb_720_h: Int?
  thumb_800: String?
  thumb_800_w: Int?
  thumb_800_h: Int?
  thumb_960: String?
  thumb_960_w: Int?
  thumb_960_h: Int?
  thumb_1024: String?
  thumb_1024_w: Int?
  thumb_1024_h: Int?
  thumb_pdf: String?
  thumb_pdf_w: Int?
  thumb_pdf_h: Int?
  /// Tiny inline thumbnail (base64-encoded).
  thumb_tiny: String?
  thumb_video: String?
  thumb_video_w: Int?
  thumb_video_h: Int?
  /// Timestamp within the video used for the thumbnail.
  thumb_video_ts: String?
  deanimate: String?
  deanimate_gif: String?
  pjpeg: String?
  /// URL to a converted PDF version of the file.
  converted_pdf: String?
  url_static_preview: String?

  # Access control
  /// Access level of the file.
  access: String?
  /// `check_file_info` for Slack Connect files whose details must be fetched
  /// with `files.info`.
  file_access: FileAccess?
  dm_mpdm_users_with_file_access: List(FileAccessUser)?
  external_workspaces_with_read_access: List(String)?
  is_restricted_sharing_enabled: Bool?
  /// Unix timestamp of when the file was last read.
  last_read: Int?
  most_recent_access_request_ts: Int?
  org_or_workspace_access: String?
  private_channels_with_file_access_count: Int?
  private_external_workspaces_with_read_access_count: Int?
  /// `0` = no restrictions, `1` = DSA restricted.
  restriction_type: Int?
  teams_shared_with: List(String)?

  # AI and skills
  ai_skill_example_prompts: List(String)?
  ai_skill_library_count: Int?
  ai_skill_usage_count: Int?
  /// AI-generated file summary.
  ai_summary: Value?
  excluded_from_slack_ai: Bool?
  is_ai_suggested: Bool?
  /// Whether this canvas is a Slackbot AI skill.
  is_skill: Bool?
  skill_description: String?

  # Audio, video and media
  aac: String?
  acc: String?
  audio_wave_samples: List(Int)?
  duration_ms: Int?
  hls: String?
  hls_embed: String?
  hls_preview: String?
  is_transcription_region_supported: Bool?
  media_progress: Value?
  mp4: String?
  mp4_low: String?
  /// WebVTT subtitle/caption content.
  vtt: String?

  # Canvases
  canvas_agent_creator_id: String?
  canvas_creator_id: String?
  canvas_default_agent_id: String?
  /// Canvas metadata (contains `originating_huddle_id`, `items`).
  canvas_metadata: Value?
  canvas_printing_enabled: Bool?
  canvas_readtime: Float?
  is_channel_space: Bool?
  linked_channel_id: String?
  source_canvas_id: String?
  team_pref_version_history_enabled: Bool?
  /// Structured title blocks for canvases (`rich_text_title_block`).
  title_blocks: List(Value)?
  /// Template publication status: `draft`, `published`, `sales_draft`, ...
  canvas_template_mode: String?
  is_global_template: Bool?
  is_org_visible: Bool?
  template_conversion_ts: Int?
  template_converter_id: String?
  template_description: String?
  template_icon: String?
  template_locale: String?
  template_name: String?
  template_title: String?

  # Editing and collaboration
  can_toggle_canvas_lock: Bool?
  edit_timestamp: Int?
  editor: String?
  editors: List(String)?
  editors_count: Int?
  is_locked: Bool?
  last_editor: String?
  non_owner_editable: Bool?
  show_badge: Bool?

  # Email
  /// Email attachments (each has `filename`, `size`, `mimetype`, `url`, ...).
  attachments: List(Value)?
  cc: List(EmailAddress)?
  email_security: Value?
  from: List(EmailAddress)?
  headers: Value?
  inline_attachment_count: Int?
  meeting_metadata: Value?
  office_pdf: String?
  original_attachment_count: Int?
  sent_to_self: Bool?
  simplified_html: String?
  subject: String?
  to: List(EmailAddress)?

  # Lifecycle
  date_delete: Int?
  is_archived: Bool?
  is_deleted: Bool?
  is_hidden_by_limit: Int?
  is_legally_held: Bool?
  is_tombstoned: Bool?
  migrated_id: String?
  update_notification: Int?

  # Lists
  list_csv_download_url: String?
  list_limits: Value?
  list_metadata: Value?
  list_records: List(Value)?
  list_template_localization_status: String?
  list_template_mode: String?
  list_template_type: String?
  todos: Value?

  # Stars, saved and pinning
  actions: List(FileAction)?
  favorites: List(FileFavorite)?
  pinned_info: Value?
  saved: Value?

  # Text content
  alt_text_highlights: String?
  annotation_count: Int?
  contents: String?
  contents_extracts: List(String)?
  contents_highlight: String?
  file_contents_hl: Value?
  formatted: String?
  has_more: Bool?
  path_to_root: List(String)?
  plain_text: String?

  # Huddles and transcription
  huddle_date_end: Int?
  huddle_date_start: Int?
  huddle_participant_ids: List(String)?
  huddle_summary_id: String?
  huddle_transcript_file_id: String?
  huddle_transcription: Value?
  is_huddle_canvas: Bool?
  transcription: Value?
  transcription_hl: Value?

  # Work Objects and app integration
  app_provides_file_work_objects: Bool?
  embedded_file_ids: List(String)?
  entity_id: String?
  full_size_preview_supported: Bool?
  is_salesforce_file: Bool?
  product_icon: Value?
  quip_thread_id: String?
}

/// How a file is stored.
enum FileMode {
  hosted
  external
  snippet
  post
  /// Slack Connect file whose details must be fetched with `files.info`.
  file_access
  hidden_by_limit
  list as ListFile
  # The next three are not in the docs but appear in live responses.
  /// A canvas.
  quip
  /// An email forwarded into Slack.
  email
  /// A deleted file that still has a placeholder in a conversation.
  tombstone
  .. UnknownFileMode
}

/// Where an external file lives.
enum ExternalFileType {
  /// Not an external file.
  "" as NotExternal
  gdrive
  dropbox
  box
  onedrive
  app
  undefined
  salesforce
  .. UnknownExternalFileType
}

/// Whether the file's details are visible to the app.
enum FileAccess {
  visible
  /// Call `files.info` to see the file's metadata.
  check_file_info
  .. UnknownFileAccess
}

/// Where a file has been shared, keyed by channel ID.
record FileShares {
  public: Dict(List(FileShare))?
  private: Dict(List(FileShare))?
}

/// One message that shared a file into a channel.
record FileShare {
  ts: String?
  thread_ts: String?
  channel_name: String?
  team_id: String?
  share_user_id: String?
  source: String?
  reply_users: List(String)?
  reply_users_count: Int?
  reply_count: Int?
  latest_reply: String?
}

/// A comment on a file.
record FileComment {
  /// The comment ID.
  id: String
  /// When the comment was created, in Unix seconds.
  created: Int?
  /// When the comment was created, in Unix seconds.
  timestamp: Int?
  /// The ID of the user who wrote the comment.
  user: String?
  /// The comment text.
  comment: String?
  is_intro: Bool?
  reactions: List(Reaction)?
}

/// A DM or MPDM member with access to a file.
record FileAccessUser {
  user_id: String?
  access: String?
}

/// An email address on an email file.
record EmailAddress {
  address: String?
  name: String?
  original: String?
  slack_user_id: String?
}

/// An action taken on a file.
record FileAction {
  ts: String?
  event_type: String?
}

/// A favorites collection containing a file.
record FileFavorite {
  collection_id: String?
  collection_name: String?
  position: Value?
}
