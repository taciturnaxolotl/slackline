//// Legacy secondary message attachments.
////
//// Slack recommends Block Kit instead. Attachments are still the only way
//// to get a colored side bar, and you can put `blocks` inside them. Apps
//// mostly read attachments from the messages of other apps, so every field
//// is optional.
////
//// Reference: https://docs.slack.dev/legacy/legacy-messaging/legacy-secondary-message-attachments
module slackline/attachment

/// A field shown in the table of an attachment.
record AttachmentField {
  /// A bold heading. Cannot contain markup.
  title: String?
  /// The value. Uses mrkdwn when `fields` is listed in `mrkdwn_in`.
  value: String?
  /// Whether the field is short enough to sit side by side with others.
  /// Defaults to `false`.
  short: Bool?
}

/// A legacy confirmation dialog for attachment actions.
record AttachmentConfirmation {
  /// Title of the pop up window.
  title: String?
  /// The consequences of the action.
  text: String
  /// The continue button label. Defaults to `Okay`.
  ok_text: String?
  /// The cancel button label. Defaults to `Cancel`.
  dismiss_text: String?
}

/// An option of a legacy message menu.
record AttachmentOption {
  /// The user-facing label.
  text: String
  /// The value sent to your Action URL.
  value: String
  /// More details about the option.
  description: String?
}

/// A group of options of a legacy message menu.
record AttachmentOptionGroup {
  /// The group label.
  text: String
  options: List(AttachmentOption)
}

/// Kinds of legacy attachment actions.
enum AttachmentActionType {
  /// A message button.
  button
  /// A message menu.
  select
  .. UnknownAttachmentActionType
}

/// Styles of legacy message buttons.
enum AttachmentActionStyle {
  "default" as ActionDefault
  "primary" as ActionPrimary
  "danger" as ActionDanger
  .. UnknownAttachmentActionStyle
}

/// Where a legacy message menu gets its options.
enum AttachmentDataSource {
  "static" as SourceStatic
  "users" as SourceUsers
  "channels" as SourceChannels
  "conversations" as SourceConversations
  "external" as SourceExternal
  "default" as SourceDefault
  .. UnknownAttachmentDataSource
}

/// A legacy message button or menu.
/// https://docs.slack.dev/legacy/legacy-messaging/legacy-interactive-message-field-guide#action_fields
record AttachmentAction {
  /// `button` or `select`.
  "type" as action_type: AttachmentActionType
  /// Identifies the action. Sent to your Action URL with the `callback_id`.
  name: String?
  # The docs mark this field required.
  /// The user-facing label.
  text: String?
  /// Identifies this specific action. Up to 2000 characters.
  value: String?
  /// The action ID Slack assigns, such as `"1"`.
  id: String?
  /// A confirmation dialog.
  confirm: AttachmentConfirmation?
  /// Buttons only.
  style: AttachmentActionStyle?
  /// Menus only: the options. Up to 100.
  options: List(AttachmentOption)?
  /// Menus only: grouped options. Supersedes `options`.
  option_groups: List(AttachmentOptionGroup)?
  /// Menus only. Defaults to `static`.
  data_source: AttachmentDataSource?
  /// Menus only: the first one is pre-selected.
  selected_options: List(AttachmentOption)?
  /// External menus only: characters typed before Slack queries your app.
  min_query_length: Int?
  /// A URL to open (link buttons).
  url: String?
}

/// A timestamp. The docs use an integer, but Slack also sends strings.
oneof AttachmentTs {
  IntTs(Int)
  StringTs(String)
}

/// A legacy secondary attachment.
record Attachment {
  /// Blocks to show inside the attachment.
  blocks: List(Block)?
  /// Side bar color: `good`, `warning`, `danger` or a hex code like `#439FE0`.
  color: String?
  /// A plain-text summary for clients that cannot show attachments.
  fallback: String?
  /// Identifies the attachment's buttons. Required when using actions.
  callback_id: String?
  /// Up to 5 buttons or menus.
  actions: List(AttachmentAction)?
  /// Always `default`.
  attachment_type: String?
  /// Small text with the author's name.
  author_name: String?
  /// A URL that links the `author_name`.
  author_link: String?
  /// A 16x16 image shown left of `author_name`.
  author_icon: String?
  /// Large title text.
  title: String?
  /// A URL that links the `title`.
  title_link: String?
  /// Text above the attachment.
  pretext: String?
  /// The main body text.
  text: String?
  /// Fields shown in a table.
  fields: List(AttachmentField)?
  /// An image shown at the bottom. Cannot be used with `thumb_url`.
  image_url: String?
  /// A thumbnail shown on the right.
  thumb_url: String?
  /// Brief text in the footer. Up to 300 characters.
  footer: String?
  /// A 16x16 image shown beside the `footer`.
  footer_icon: String?
  /// A Unix timestamp shown in the footer.
  ts: AttachmentTs?
  /// Field names formatted with mrkdwn: `pretext`, `text`, `fields`.
  mrkdwn_in: List(String)?
  /// The attachment index Slack assigns.
  id: Int?
  /// Thumbnail width Slack reports.
  thumb_width: Int?
  /// Thumbnail height Slack reports.
  thumb_height: Int?
  /// The unfurled service's name.
  service_name: String?
}
