//// Work Objects: flexpane details and bidirectional comments for unfurled entities.
module slackline/api/entity

/// A reference to an image uploaded to Slack.
record EntitySlackFile {
  /// ID of the Slack file.
  id: String?
  /// URL of the Slack file.
  url: String?
}

/// An image shown as an avatar or icon in a Work Object.
record EntityIcon {
  /// Summary of the image's content.
  alt_text: String?
  /// Publicly accessible URL of the image. Provide this or `slack_file`.
  url: String?
  /// A Slack file to use as the image. Provide this or `url`.
  slack_file: EntitySlackFile?
}

/// A user in a Work Object: either a Slack user (`user_id`) or an external one (`text`).
record EntityUser {
  /// A Slack user ID. Do not provide `text` when `user_id` is provided.
  user_id: String?
  /// The full name of the user. Do not provide `user_id` when `text` is provided.
  text: String?
  /// A link to an external profile for the user.
  url: String?
  /// The email of the user. Slack shows a matching Slack user instead.
  email: String?
  /// An avatar for the user.
  icon: EntityIcon?
  /// The title or position of an external user, displayed below their name.
  caption: String?
}

/// The content of a comment. Provide one of `blocks` or `value`.
record CommentContent {
  /// A rich text block containing the comment content.
  blocks: Block?
  /// Plain or markdown string, used if `blocks` is not present.
  value: String?
  /// Set to `markdown` to format `value` as markdown.
  format: String?
}

/// A comment on an external entity, presented in the Work Object flexpane.
record EntityComment {
  /// A unique ID from your app. Use it to edit the comment.
  id: String
  /// Who wrote the comment.
  sender: EntityUser
  /// Epoch timestamp in seconds.
  timestamp: Int
  /// The comment content.
  comment: CommentContent
  /// URL which directs to the comment.
  url: String?
  /// If `true`, the comment is editable in the user's flexpane.
  can_edit: Bool?
  /// If `true`, renders the delete button on the comment.
  can_delete: Bool?
  /// If `true`, users may reply to the comment in a thread.
  can_reply: Bool?
  /// Number of replies in the thread under the comment.
  reply_count: Int?
  /// Up to two users who have replied to the thread.
  reply_users: List(EntityUser)?
  /// Epoch timestamp in seconds of the most recent reply.
  latest_reply_ts: Int?
  /// Epoch timestamp in seconds of the last edit.
  last_edit_ts: Int?
  /// The `id` of the parent comment, if this comment is a threaded reply.
  thread_root_id: String?
  /// Pagination cursor for this comment's position in the list.
  cursor: String?
}

/// Loading state of an entity action button.
record EntityProcessingState {
  enabled: Bool
  interstitial_text: String?
}

/// An action button shown with an entity error.
record EntityActionButton {
  action_id: String
  text: String
  accessibility_label: String?
  processing_state: EntityProcessingState?
  /// `primary` or `danger`.
  style: String?
  url: String?
  value: String?
}

/// Why an entity's details could not be presented.
record EntityError {
  /// `restricted`, `internal_error`, `not_found`, `custom`, `custom_partial_view`, `timeout` or `edit_error`.
  status: String
  /// Message shown when `status` is `custom`.
  custom_message: String?
  /// Title shown when `status` is `custom`.
  custom_title: String?
  /// Format of `custom_message`: `markdown`.
  message_format: String?
  /// Action buttons shown with the error.
  actions: List(EntityActionButton)?
}

method entity.acknowledgeCommentAction {
  args {
    /// The persisted comment. Required for successful post and edit actions.
    comment: EntityComment?
  }
  response Nil
}

method entity.presentComments {
  args {
    /// Comments to present to the user (at most 100).
    comments: List(EntityComment) json
    # The docs do not describe this field.
    /// Error details.
    error: Value? json
  }
  response Nil
}

method entity.presentDetails {
  args {
    /// Flexpane metadata for the entity: set `entity_type` and
    /// `entity_payload`.
    metadata: MessageMetadata?
    /// Why the entity could not be presented.
    error: EntityError?
  }
  response Nil
}
