//// Block Kit: blocks, block elements, composition objects and rich text.
////
//// Every type here can be sent to Slack (messages, modals, Home tabs) and
//// decoded from what Slack sends back (events, interaction payloads, API
//// responses). Unions dispatch on `type`. Anything they do not recognize
//// goes in a catch-all variant, so new Slack features do not break decoding.
////
//// Build a block with the function named after it. The function takes the
//// required fields and a list of attributes for the optional ones.
//// `slackline/element` builds elements the same way. The attributes of a
//// block are in a module named after the block. An attribute of another
//// block is a type error:
////
//// ```gleam
//// import slackline/block
//// import slackline/block/section
//// import slackline/element
//// import slackline/element/button
////
//// block.section(block.mrkdwn("*Hello*"), [
////   section.block_id("intro"),
////   section.accessory(element.button("Go", "go", [button.style(block.Primary)])),
//// ])
//// ```
////
//// The records (`SectionBlock`, `ButtonElement`, ...) are public too, for
//// reading payloads and for building blocks field by field.
////
//// Reference: https://docs.slack.dev/reference/block-kit
module slackline/block

# ---------------------------------------------------------------- composition objects

/// A `plain_text` text object, for the many fields that only accept plain
/// text (labels, titles, placeholders, button text, headers).
/// https://docs.slack.dev/reference/block-kit/composition-objects/text-object
record PlainText {
  type = "plain_text"
  /// The text. Minimum length 1, maximum 3000 characters.
  text: String
  /// Whether emojis should be escaped into the colon emoji format.
  emoji: Bool?
}

/// A `mrkdwn` text object: text using Slack's `mrkdwn` formatting.
/// https://docs.slack.dev/reference/block-kit/composition-objects/text-object
record Mrkdwn {
  type = "mrkdwn"
  /// The text, using standard Slack mrkdwn markup.
  text: String
  /// When `true`, URLs, conversation names and mentions are not
  /// auto-linked or parsed. Defaults to `false`.
  verbatim: Bool?
}

/// A text object: `plain_text` or `mrkdwn`.
/// https://docs.slack.dev/reference/block-kit/composition-objects/text-object
union Text {
  plain_text PlainTextObject(PlainText)
  mrkdwn MrkdwnObject(Mrkdwn)
  .. UnknownText
}

/// Color scheme for buttons and the confirm button of a confirmation dialog.
enum ButtonStyle {
  /// Green: affirmation or confirmation. Use for one button at most.
  primary
  /// Red: destructive actions. Use sparingly.
  danger
  .. UnknownButtonStyle
}

/// A dialog that asks the user to confirm an action before it runs.
/// https://docs.slack.dev/reference/block-kit/composition-objects/confirmation-dialog-object
record ConfirmationDialog {
  /// The dialog title. Maximum 100 characters.
  title: PlainText
  # The docs say `plain_text`, but their own example uses `mrkdwn`.
  /// The explanatory text, `plain_text` or `mrkdwn`. Maximum 300 characters.
  text: Text
  /// The text of the confirm button. Maximum 30 characters.
  confirm: PlainText
  /// The text of the cancel button. Maximum 30 characters.
  deny: PlainText
  /// Color scheme of the confirm button. Defaults to the default style.
  style: ButtonStyle?
}

/// Conversation types for a `ConversationFilter`.
enum ConversationKind {
  im
  mpim
  private
  public
  .. UnknownConversationKind
}

/// Filters the conversations offered by conversation select menus.
/// https://docs.slack.dev/reference/block-kit/composition-objects/conversation-filter-object
record ConversationFilter {
  /// Conversation types to include. Cannot be empty.
  include: List(ConversationKind)?
  /// Whether to exclude externally shared channels. Defaults to `false`.
  exclude_external_shared_channels: Bool?
  /// Whether to exclude bot users. Defaults to `false`.
  exclude_bot_users: Bool?
}

/// When a text input dispatches a `block_actions` payload.
enum TriggerAction {
  /// When the user presses enter while the input is focused.
  on_enter_pressed
  /// When a character is entered or removed.
  on_character_entered
  .. UnknownTriggerAction
}

/// Determines when a text input element returns a `block_actions` payload.
/// https://docs.slack.dev/reference/block-kit/composition-objects/dispatch-action-configuration-object
record DispatchActionConfig {
  /// One or both interaction types to dispatch on.
  trigger_actions_on: List(TriggerAction)?
}

/// A single selectable item in a select menu, multi-select, overflow menu,
/// checkbox group or radio button group.
/// https://docs.slack.dev/reference/block-kit/composition-objects/option-object
record SelectOption {
  /// The text shown for the option. Menus only accept `plain_text`.
  /// Checkboxes and radio buttons also accept `mrkdwn`. Maximum 75 characters.
  text: Text
  /// The value sent to your app when this option is chosen. Maximum 150 characters.
  value: String
  /// A line of descriptive text shown below `text`. `mrkdwn` is only
  /// allowed in checkboxes and radio buttons.
  description: Text?
  /// A URL to open when the option is clicked. Only available in overflow menus.
  url: String?
}

/// A labelled group of options in a select menu.
/// https://docs.slack.dev/reference/block-kit/composition-objects/option-group-object
record OptionGroup {
  /// The label shown above the group. Maximum 75 characters.
  label: PlainText
  /// The options in the group. Maximum 100.
  options: List(SelectOption)
}

/// A reference to an image file hosted on Slack. Provide `url` or `id`.
/// https://docs.slack.dev/reference/block-kit/composition-objects/slack-file-object
record SlackFile {
  /// The `url_private` or `permalink` of the Slack file.
  url: String?
  /// The Slack ID of the file.
  id: String?
}

/// Names of the built-in Slack icons.
enum SlackIconName {
  "archive" as IconArchive
  "book" as IconBook
  "bookmark" as IconBookmark
  "bot" as IconBot
  "bug" as IconBug
  "calendar" as IconCalendar
  "call" as IconCall
  "caret-left" as IconCaretLeft
  "caret-right" as IconCaretRight
  "check" as IconCheck
  "clipboard" as IconClipboard
  "code" as IconCode
  "comment" as IconComment
  "compass" as IconCompass
  "copy" as IconCopy
  "cube" as IconCube
  "download" as IconDownload
  "edit" as IconEdit
  "email" as IconEmail
  "eye-closed" as IconEyeClosed
  "eye-open" as IconEyeOpen
  "file" as IconFile
  "flag" as IconFlag
  "folder" as IconFolder
  "gear" as IconGear
  "globe" as IconGlobe
  "heart" as IconHeart
  "help" as IconHelp
  "image" as IconImage
  "info" as IconInfo
  "key" as IconKey
  "lightbulb" as IconLightbulb
  "link" as IconLink
  "map" as IconMap
  "mobile" as IconMobile
  "new-window" as IconNewWindow
  "pin" as IconPin
  "plus" as IconPlus
  "refine" as IconRefine
  "refresh" as IconRefresh
  "rocket" as IconRocket
  "save" as IconSave
  "screen" as IconScreen
  "share" as IconShare
  "sparkle" as IconSparkle
  "star" as IconStar
  "star-filled" as IconStarFilled
  "tag" as IconTag
  "thumbs-down" as IconThumbsDown
  "thumbs-up" as IconThumbsUp
  "trash" as IconTrash
  "upload" as IconUpload
  "user" as IconUser
  "warning" as IconWarning
  .. UnknownSlackIconName
}

/// A built-in Slack icon, used in card blocks.
/// https://docs.slack.dev/reference/block-kit/composition-objects/slack-icon-object
record SlackIcon {
  type = "icon"
  /// Which icon to show.
  name: SlackIconName
}

/// A customizable input parameter passed to a workflow trigger.
record TriggerInputParameter {
  /// Must match an input parameter defined on the workflow of the trigger.
  name: String
  /// Must match the type of the workflow input parameter.
  value: Value
}

/// Information about a workflow's link trigger.
/// https://docs.slack.dev/reference/block-kit/composition-objects/trigger-object
record Trigger {
  /// A link trigger URL. Must be associated with a valid trigger.
  url: String
  /// Values for input parameters marked `customizable: true` on the trigger.
  customizable_input_parameters: List(TriggerInputParameter)?
}

/// The workflow run by a workflow button.
/// https://docs.slack.dev/reference/block-kit/composition-objects/workflow-object
record Workflow {
  /// The workflow's trigger.
  trigger: Trigger
}

# ---------------------------------------------------------------- interactive elements

/// A button. Works in section (accessory), actions and data table cells.
/// https://docs.slack.dev/reference/block-kit/block-elements/button-element
record ButtonElement {
  type = "button"
  /// The button text. Slack can truncate it at about 30 characters. Maximum 75.
  text: PlainText
  /// Identifies the source of the action in interaction payloads. Unique in
  /// the containing block. Maximum 255 characters.
  action_id: String?
  /// A URL to open in the user's browser when the button is clicked. You
  /// still receive an interaction payload and must acknowledge it.
  url: String?
  /// The value sent with the interaction payload. Maximum 2000 characters.
  value: String?
  /// Visual color scheme. Defaults to the default (neutral) style.
  style: ButtonStyle?
  /// A confirmation dialog shown after the button is clicked.
  confirm: ConfirmationDialog?
  /// Text read by screen readers instead of `text`. Maximum 75 characters.
  accessibility_label: String?
  /// A prompt sent to Slackbot when clicked, if Slackbot AI is available.
  /// Up to 4000 characters.
  agent_prompt: String?
  /// Short text shown instead of the full `agent_prompt`. Requires `agent_prompt`.
  agent_prompt_display: String?
  /// User IDs the button is visible to. Visible to everyone if omitted.
  visible_to_user_ids: List(String)?
}

/// A group of checkboxes. Works in section, actions and input.
/// https://docs.slack.dev/reference/block-kit/block-elements/checkboxes-element
record CheckboxesElement {
  type = "checkboxes"
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
  /// The options. Maximum 10. `mrkdwn` text is allowed.
  options: List(SelectOption)
  /// Options selected when the group first loads. They must match `options`.
  initial_options: List(SelectOption)?
  /// A confirmation dialog shown after clicking a checkbox.
  confirm: ConfirmationDialog?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// User IDs the element is visible to. Visible to everyone if omitted.
  visible_to_user_ids: List(String)?
}

/// A calendar date picker. Works in section, actions and input.
/// https://docs.slack.dev/reference/block-kit/block-elements/date-picker-element
record DatepickerElement {
  type = "datepicker"
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
  /// The initially selected date, `YYYY-MM-DD`.
  initial_date: String?
  /// A confirmation dialog shown after a date is selected.
  confirm: ConfirmationDialog?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
}

/// A date and time picker. Works in actions and input.
/// https://docs.slack.dev/reference/block-kit/block-elements/datetime-picker-element
record DatetimepickerElement {
  type = "datetimepicker"
  /// Identifies the input value on submission. Maximum 255 characters.
  action_id: String?
  /// The initial date and time as a UNIX timestamp in seconds.
  initial_date_time: Int?
  /// A confirmation dialog shown after a time is selected.
  confirm: ConfirmationDialog?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
}

/// An email address input. Works in input blocks.
/// https://docs.slack.dev/reference/block-kit/block-elements/email-input-element
record EmailTextInputElement {
  type = "email_text_input"
  /// Identifies the input value on submission. Maximum 255 characters.
  action_id: String?
  /// The initial value.
  initial_value: String?
  /// When the element dispatches `block_actions` payloads.
  dispatch_action_config: DispatchActionConfig?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
}

/// A file upload input. Works in input blocks in modals.
/// https://docs.slack.dev/reference/block-kit/block-elements/file-input-element
record FileInputElement {
  type = "file_input"
  /// Identifies the input value on submission. Maximum 255 characters.
  action_id: String?
  /// Accepted file extensions. All are accepted if omitted.
  filetypes: List(String)?
  /// Maximum number of files, 1 to 10. Defaults to 10.
  max_files: Int?
}

/// An image element. Works as a section accessory and in context blocks.
/// Provide `image_url` or `slack_file`.
/// https://docs.slack.dev/reference/block-kit/block-elements/image-element
record ImageElement {
  type = "image"
  /// A plain-text summary of the image, without markup.
  alt_text: String
  /// The URL of a publicly hosted image. Maximum 3000 characters.
  image_url: String?
  /// A Slack image file.
  slack_file: SlackFile?
}

/// A select menu with a static list of options. Provide `options` or
/// `option_groups`, not both.
/// https://docs.slack.dev/reference/block-kit/block-elements/select-menu-element
record StaticSelectElement {
  type = "static_select"
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
  # The docs mark this field required.
  /// The options. Maximum 100. Leave it out when you set `option_groups`.
  options: List(SelectOption)?
  /// Option groups. Maximum 100. Leave it out when you set `options`.
  option_groups: List(OptionGroup)?
  /// The option selected when the menu loads.
  initial_option: SelectOption?
  /// A confirmation dialog shown after an item is selected.
  confirm: ConfirmationDialog?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
}

/// A select menu whose options are loaded from your app's options URL.
record ExternalSelectElement {
  type = "external_select"
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
  /// The option selected when the menu loads.
  initial_option: SelectOption?
  /// Characters typed before Slack queries your app. Defaults to 3.
  min_query_length: Int?
  /// A confirmation dialog shown after an item is selected.
  confirm: ConfirmationDialog?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
}

/// A select menu listing the users in the workspace.
record UsersSelectElement {
  type = "users_select"
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
  /// The user ID selected when the menu loads.
  initial_user: String?
  /// A confirmation dialog shown after an item is selected.
  confirm: ConfirmationDialog?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
}

/// A select menu listing conversations the user can see.
record ConversationsSelectElement {
  type = "conversations_select"
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
  /// The conversation ID selected when the menu loads. Takes precedence
  /// over `default_to_current_conversation`.
  initial_conversation: String?
  /// Pre-select the conversation the user was viewing. Defaults to `false`.
  default_to_current_conversation: Bool?
  /// A confirmation dialog shown after an item is selected.
  confirm: ConfirmationDialog?
  /// Include a `response_url` in the `view_submission` payload. Only for
  /// menus in input blocks in modals.
  response_url_enabled: Bool?
  /// Narrows the conversations offered.
  filter: ConversationFilter?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
}

/// A select menu listing public channels.
record ChannelsSelectElement {
  type = "channels_select"
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
  /// The public channel ID selected when the menu loads.
  initial_channel: String?
  /// A confirmation dialog shown after an item is selected.
  confirm: ConfirmationDialog?
  /// Include a `response_url` in the `view_submission` payload. Only for
  /// menus in input blocks in modals.
  response_url_enabled: Bool?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
}

/// A multi-select menu with a static list of options. Provide `options` or
/// `option_groups`, not both.
/// https://docs.slack.dev/reference/block-kit/block-elements/multi-select-menu-element
record MultiStaticSelectElement {
  type = "multi_static_select"
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
  /// The options. Maximum 100. Leave it out when you set `option_groups`.
  options: List(SelectOption)?
  /// Option groups. Maximum 100. Leave it out when you set `options`.
  option_groups: List(OptionGroup)?
  /// Options selected when the menu loads.
  initial_options: List(SelectOption)?
  /// A confirmation dialog shown before the choices are submitted.
  confirm: ConfirmationDialog?
  /// Maximum number of selected items. Minimum 1.
  max_selected_items: Int?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
}

/// A multi-select menu whose options are loaded from your app's options URL.
record MultiExternalSelectElement {
  type = "multi_external_select"
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
  /// Characters typed before Slack queries your app. Defaults to 3.
  min_query_length: Int?
  /// Options selected when the menu loads.
  initial_options: List(SelectOption)?
  /// A confirmation dialog shown before the choices are submitted.
  confirm: ConfirmationDialog?
  /// Maximum number of selected items. Minimum 1.
  max_selected_items: Int?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
}

/// A multi-select menu listing the users in the workspace.
record MultiUsersSelectElement {
  type = "multi_users_select"
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
  /// User IDs selected when the menu loads.
  initial_users: List(String)?
  /// A confirmation dialog shown before the choices are submitted.
  confirm: ConfirmationDialog?
  /// Maximum number of selected items. Minimum 1.
  max_selected_items: Int?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
}

/// A multi-select menu listing conversations the user can see.
record MultiConversationsSelectElement {
  type = "multi_conversations_select"
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
  /// Conversation IDs selected when the menu loads. Ignored when
  /// `default_to_current_conversation` is set.
  initial_conversations: List(String)?
  /// Pre-select the conversation the user was viewing. Defaults to `false`.
  default_to_current_conversation: Bool?
  /// A confirmation dialog shown before the choices are submitted.
  confirm: ConfirmationDialog?
  /// Maximum number of selected items. Minimum 1.
  max_selected_items: Int?
  /// Narrows the conversations offered.
  filter: ConversationFilter?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
}

/// A multi-select menu listing public channels.
record MultiChannelsSelectElement {
  type = "multi_channels_select"
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
  /// Public channel IDs selected when the menu loads.
  initial_channels: List(String)?
  /// A confirmation dialog shown before the choices are submitted.
  confirm: ConfirmationDialog?
  /// Maximum number of selected items. Minimum 1.
  max_selected_items: Int?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
}

/// A number input. Works in input blocks.
/// https://docs.slack.dev/reference/block-kit/block-elements/number-input-element
record NumberInputElement {
  type = "number_input"
  /// Whether decimal numbers are allowed.
  is_decimal_allowed: Bool
  /// Identifies the input value on submission. Maximum 255 characters.
  action_id: String?
  /// The initial value.
  initial_value: String?
  /// The minimum value. It cannot be greater than `max_value`.
  min_value: String?
  /// The maximum value. It cannot be less than `min_value`.
  max_value: String?
  /// When the element dispatches `block_actions` payloads.
  dispatch_action_config: DispatchActionConfig?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
}

/// An overflow ("...") menu. Works in section and actions.
/// https://docs.slack.dev/reference/block-kit/block-elements/overflow-menu-element
record OverflowElement {
  type = "overflow"
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
  /// Up to five options. Options may set `url`.
  options: List(SelectOption)
  /// A confirmation dialog shown after an item is selected.
  confirm: ConfirmationDialog?
}

/// A single or multi-line plain-text input. Works in input blocks.
/// https://docs.slack.dev/reference/block-kit/block-elements/plain-text-input-element
record PlainTextInputElement {
  type = "plain_text_input"
  /// Identifies the input value on submission. Maximum 255 characters.
  action_id: String?
  /// The initial value.
  initial_value: String?
  /// Whether to show a larger textarea. Defaults to `false`.
  multiline: Bool?
  /// Minimum input length, 0 to 3000.
  min_length: Int?
  /// Maximum input length, 1 to 3000.
  max_length: Int?
  /// When the element dispatches `block_actions` payloads.
  dispatch_action_config: DispatchActionConfig?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
}

/// A group of radio buttons. Works in section, actions and input.
/// https://docs.slack.dev/reference/block-kit/block-elements/radio-button-group-element
record RadioButtonsElement {
  type = "radio_buttons"
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
  /// The options. Maximum 10. `mrkdwn` text is allowed.
  options: List(SelectOption)
  /// The option selected when the group loads. It must match `options`.
  initial_option: SelectOption?
  /// A confirmation dialog shown after clicking a radio button.
  confirm: ConfirmationDialog?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
}

/// A rich text editor. Works in input blocks.
/// https://docs.slack.dev/reference/block-kit/block-elements/rich-text-input-element
record RichTextInputElement {
  type = "rich_text_input"
  /// Identifies the input value on submission. Maximum 255 characters.
  action_id: String
  /// The initial content.
  initial_value: RichText?
  /// When the element dispatches `block_actions` payloads.
  dispatch_action_config: DispatchActionConfig?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
  /// Minimum visible lines before scrolling, 1 to 100.
  min_lines: Int?
  /// Maximum visible lines before scrolling, 1 to 100. Defaults to 8.
  max_lines: Int?
}

/// A time picker. Works in section, actions and input.
/// https://docs.slack.dev/reference/block-kit/block-elements/time-picker-element
record TimepickerElement {
  type = "timepicker"
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
  /// The initial time, `HH:mm` in 24-hour format.
  initial_time: String?
  /// A confirmation dialog shown after a time is selected.
  confirm: ConfirmationDialog?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
  /// An IANA timezone, such as `America/Chicago`, shown as hint text.
  timezone: String?
}

/// A URL input. Works in input blocks.
/// https://docs.slack.dev/reference/block-kit/block-elements/url-input-element
record UrlTextInputElement {
  type = "url_text_input"
  /// Identifies the input value on submission. Maximum 255 characters.
  action_id: String?
  /// The initial value.
  initial_value: String?
  /// When the element dispatches `block_actions` payloads.
  dispatch_action_config: DispatchActionConfig?
  /// Whether to auto focus this element in a view. Defaults to `false`.
  focus_on_load: Bool?
  /// Placeholder text. Maximum 150 characters.
  placeholder: PlainText?
}

/// A button that runs a workflow. Works in section and actions.
/// https://docs.slack.dev/reference/block-kit/block-elements/workflow-button-element
record WorkflowButtonElement {
  type = "workflow_button"
  /// The button text. Maximum 75 characters.
  text: PlainText
  /// The workflow to run.
  workflow: Workflow
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String
  /// Visual color scheme.
  style: ButtonStyle?
  /// Text read by screen readers instead of `text`. Maximum 75 characters.
  accessibility_label: String?
}

/// The interactive block elements.
///
/// Where each variant is allowed:
/// - section `accessory`: button, checkboxes, datepicker, image, all
///   selects and multi-selects, overflow, radio_buttons, timepicker,
///   workflow_button
/// - actions `elements`: button, checkboxes, datepicker, datetimepicker,
///   all selects and multi-selects, overflow, radio_buttons, timepicker,
///   workflow_button
/// - input `element`: checkboxes, datepicker, datetimepicker,
///   email_text_input, file_input, all selects and multi-selects,
///   number_input, plain_text_input, radio_buttons, rich_text_input,
///   timepicker, url_text_input
union Element builders "slackline/element" {
  button Button(ButtonElement) builder(text, action_id)
  checkboxes Checkboxes(CheckboxesElement) builder(action_id, options)
  datepicker Datepicker(DatepickerElement) builder(action_id)
  datetimepicker Datetimepicker(DatetimepickerElement) builder(action_id)
  email_text_input EmailTextInput(EmailTextInputElement) builder(action_id)
  file_input FileInput(FileInputElement) builder(action_id)
  /// An image. Only allowed as a section accessory (and in card and
  /// container icons). Context blocks use `ContextElement`. Set `image_url`
  /// or `slack_file`.
  image ImageAccessory(ImageElement) builder(alt_text)
  /// A select menu with a static list of options. Set `options` or
  /// `option_groups`.
  /// https://docs.slack.dev/reference/block-kit/block-elements/select-menu-element
  static_select StaticSelect(StaticSelectElement) builder(action_id)
  external_select ExternalSelect(ExternalSelectElement) builder(action_id)
  users_select UsersSelect(UsersSelectElement) builder(action_id)
  conversations_select ConversationsSelect(ConversationsSelectElement) builder(action_id)
  channels_select ChannelsSelect(ChannelsSelectElement) builder(action_id)
  /// A multi-select menu with a static list of options. Set `options` or
  /// `option_groups`.
  /// https://docs.slack.dev/reference/block-kit/block-elements/multi-select-menu-element
  multi_static_select MultiStaticSelect(MultiStaticSelectElement) builder(action_id)
  multi_external_select MultiExternalSelect(MultiExternalSelectElement) builder(action_id)
  multi_users_select MultiUsersSelect(MultiUsersSelectElement) builder(action_id)
  multi_conversations_select MultiConversationsSelect(MultiConversationsSelectElement) builder(action_id)
  multi_channels_select MultiChannelsSelect(MultiChannelsSelectElement) builder(action_id)
  number_input NumberInput(NumberInputElement) builder(action_id, is_decimal_allowed)
  overflow Overflow(OverflowElement) builder(action_id, options)
  plain_text_input PlainTextInput(PlainTextInputElement) builder(action_id)
  radio_buttons RadioButtons(RadioButtonsElement) builder(action_id, options)
  rich_text_input RichTextInput(RichTextInputElement)
  timepicker Timepicker(TimepickerElement) builder(action_id)
  url_text_input UrlTextInput(UrlTextInputElement) builder(action_id)
  workflow_button WorkflowButton(WorkflowButtonElement)
  .. UnknownElement
}

/// The elements of a context block: images and text objects.
/// https://docs.slack.dev/reference/block-kit/blocks/context-block
union ContextElement {
  image ContextImage(ImageElement)
  plain_text ContextPlainText(PlainText)
  mrkdwn ContextMrkdwn(Mrkdwn)
  .. UnknownContextElement
}

/// One of the two buttons of a feedback buttons element.
record FeedbackButton {
  /// The button text. Maximum 75 characters.
  text: PlainText
  /// The value sent with the interaction payload. Maximum 2000 characters.
  value: String
  /// Text read by screen readers instead of `text`. Maximum 75 characters.
  accessibility_label: String?
}

/// Thumbs up / thumbs down style feedback buttons.
/// https://docs.slack.dev/reference/block-kit/block-elements/feedback-buttons-element
record FeedbackButtonsElement {
  type = "feedback_buttons"
  /// The button for positive feedback.
  positive_button: FeedbackButton
  /// The button for negative feedback.
  negative_button: FeedbackButton
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
}

/// A small button showing an icon.
/// https://docs.slack.dev/reference/block-kit/block-elements/icon-button-element
record IconButtonElement {
  type = "icon_button"
  /// The icon to show. `trash` is the only icon available at this time.
  icon: String
  /// The button text.
  text: PlainText
  /// Identifies the source of the action. Maximum 255 characters.
  action_id: String?
  /// The value sent with the interaction payload. Maximum 2000 characters.
  value: String?
  /// A confirmation dialog shown after the button is clicked.
  confirm: ConfirmationDialog?
  /// Text read by screen readers instead of `text`. Maximum 75 characters.
  accessibility_label: String?
  /// User IDs the button is visible to. Visible to everyone if omitted.
  visible_to_user_ids: List(String)?
}

/// The elements of a context actions block.
/// https://docs.slack.dev/reference/block-kit/blocks/context-actions-block
union ContextActionsElement {
  feedback_buttons FeedbackButtons(FeedbackButtonsElement)
  icon_button IconButton(IconButtonElement)
  .. UnknownContextActionsElement
}

/// A URL source shown on a task card.
/// https://docs.slack.dev/reference/block-kit/block-elements/url-source-element
record UrlSource {
  type = "url"
  /// The source URL.
  url: String
  /// Display text for the URL.
  text: String
}

# ---------------------------------------------------------------- rich text

/// Optional styling of rich text elements. `code` only applies to `text`
/// elements. `unlink` does not apply to `color`, `date` and
/// `canvas_message_unfurl`.
record RichTextStyle {
  bold: Bool?
  italic: Bool?
  strike: Bool?
  code: Bool?
  highlight: Bool?
  client_highlight: Bool?
  underline: Bool?
  unlink: Bool?
}

/// Who a broadcast mention notifies.
enum BroadcastRange {
  /// Active members of the channel.
  here
  /// All members of the channel.
  channel
  /// Every person in the #general channel.
  everyone
  .. UnknownBroadcastRange
}

/// Colors for tag elements.
enum TagColor {
  gray
  brown
  purple
  indigo
  blue
  green
  yellow
  orange
  red
  .. UnknownTagColor
}

/// Details about the source of a citation, tagged by `citation_type`.
union CitationDetails tag "citation_type" {
  file CitationFile {
    descriptor: String?
    file_id: String?
  }
  external CitationExternal {
    app_name: String?
    app_icon_url: String?
  }
  web CitationWeb {
    display_name: String?
    title: String?
    snippet: String?
  }
  message CitationMessage {
    channel: String?
    message_ts: String?
  }
  memory CitationMemory {
    memory_id: String?
  }
  .. UnknownCitationDetails
}

/// The inline elements of rich text sections, lists, quotes and
/// preformatted blocks.
/// https://docs.slack.dev/reference/block-kit/blocks/rich-text-block
union RichTextElement {
  /// Text, optionally styled.
  text TextElement {
    /// The text shown to the user.
    text: String
    style: RichTextStyle?
  }
  /// A link.
  link LinkElement {
    /// The link's URL.
    url: String
    /// The text shown instead of the URL.
    text: String?
    /// Whether the link is unsafe.
    unsafe: Bool?
    /// Whether the link was generated by an LLM.
    from_llm: Bool?
    /// Whether the link is a Slack URL.
    is_slack_url: Bool?
    /// Whether the link has been truncated.
    truncated: Bool?
    style: RichTextStyle?
  }
  /// An emoji.
  emoji EmojiElement {
    /// The emoji name, such as `wave` or `wave::skin-tone-2`.
    name: String
    /// The unicode code point, where applicable.
    unicode: String?
  }
  /// A user mention.
  user UserElement {
    user_id: String
    style: RichTextStyle?
    /// Whether the user was generated by an LLM.
    from_llm: Bool?
  }
  /// A channel mention.
  channel ChannelElement {
    channel_id: String
    /// A specific channel tab.
    tab_id: String?
    style: RichTextStyle?
    /// Whether the channel was generated by an LLM.
    from_llm: Bool?
  }
  /// A user group mention.
  usergroup UsergroupElement {
    usergroup_id: String
    style: RichTextStyle?
  }
  /// A workspace mention.
  team TeamElement {
    team_id: String
    style: RichTextStyle?
  }
  /// An `@here`, `@channel` or `@everyone` mention.
  broadcast BroadcastElement {
    range: BroadcastRange
    style: RichTextStyle?
  }
  /// A date formatted for the reader's locale and timezone.
  date DateElement {
    /// A Unix timestamp in seconds.
    timestamp: Int
    /// A template with tokens such as `{date_num}` or `{time}`.
    format: String
    /// The timezone of the date.
    timezone: String?
    /// A URL to link the whole formatted string to.
    url: String?
    /// Text shown when the date cannot be rendered.
    fallback: String?
    style: RichTextStyle?
  }
  /// A color swatch.
  color ColorElement {
    /// The hex value of the color.
    value: String
    style: RichTextStyle?
  }
  /// A link to a canvas.
  canvas CanvasElement {
    file_id: String
    label: String?
    hide_title: Bool?
    section_id: String?
    style: RichTextStyle?
    /// Title of the canvas.
    text: String?
    url: String?
    is_skill_invocation: Bool?
  }
  /// A user mention inside canvas content.
  canvas_user_mention CanvasUserMentionElement {
    user_id: String
    thread_id: String?
    style: RichTextStyle?
  }
  /// A message unfurled inside a canvas.
  canvas_message_unfurl CanvasMessageUnfurlElement {
    root_message_ts: String
    root_message_channel: String
    style: RichTextStyle?
  }
  /// A citation of a source.
  citation CitationElement {
    url: String
    text: String
    index: Int
    details: CitationDetails
    from_llm: Bool?
    is_slack_url: Bool?
  }
  /// A link to a file.
  file FileElement {
    file_id: String
    style: RichTextStyle?
    /// Title of the file.
    text: String?
    url: String?
    is_skill_invocation: Bool?
  }
  /// A link to a Slack list record.
  list_record ListRecordElement {
    file_id: String
    record_id: String?
    view_id: String?
    style: RichTextStyle?
    text: String?
    url: String?
  }
  /// A link to a message.
  message_mention MessageMentionElement {
    channel_id: String
    message_ts: String
    author_id: String?
    thread_ts: String?
    style: RichTextStyle?
    text: String?
    url: String?
  }
  /// A Salesforce record field.
  salesforce_data_field SalesforceDataFieldElement {
    salesforce_record_id: String
    salesforce_field_label: String?
    salesforce_field_api_name: String?
    salesforce_include_field_label: Bool?
    style: RichTextStyle?
  }
  /// A colored tag.
  tag TagElement {
    text: String
    color: TagColor?
    style: RichTextStyle?
  }
  /// A Work Object reference.
  work_object_mention WorkObjectMentionElement {
    entity_id: String
    app_id: String
    text: String
    url: String
    icon_url: String?
    full_size_preview_enabled: Bool?
    product_name: String?
    style: RichTextStyle?
  }
  /// A link to a workflow.
  workflow_mention WorkflowMentionElement {
    workflow_id: String
    function_trigger_id: String
    text: String
    url: String?
    channel_id: String?
    ts: String?
    style: RichTextStyle?
  }
  /// A reference to an app attachment or Work Object.
  attachment_mention AttachmentMentionElement {
    url: String
    /// Fallback text if the attachment is not found.
    text: String?
    app_id: String?
    entity_id: String?
    icon_url: String?
    channel_id: String?
    ts: String?
    full_size_preview_enabled: Bool?
    icon_name: String?
    reference_object_type: String?
    product_name: String?
    style: RichTextStyle?
  }
  .. UnknownRichTextElement
}

/// Rich text list styles.
enum RichTextListStyle {
  bullet
  /// A numbered list.
  ordered
  .. UnknownRichTextListStyle
}

/// The top-level children of a rich text block.
union RichTextObject {
  /// A paragraph of inline elements.
  rich_text_section RichTextSection {
    elements: List(RichTextElement)
  }
  /// A bulleted or numbered list. Each item is a `rich_text_section`.
  rich_text_list RichTextList {
    # The docs mark this field required, but one docs example leaves it out.
    /// `bullet` or `ordered`.
    style: RichTextListStyle?
    elements: List(RichTextObject)
    /// Sub-list indent level.
    indent: Int?
    /// Number to offset the first number of an ordered list by.
    offset: Int?
    /// Border on (1) or off (0).
    border: Int?
  }
  /// A code block of `text` and `link` elements.
  rich_text_preformatted RichTextPreformatted {
    elements: List(RichTextElement)
    border: Int?
    /// Language for syntax highlighting, such as `python`.
    language: String?
  }
  /// A quote.
  rich_text_quote RichTextQuote {
    elements: List(RichTextElement)
    border: Int?
  }
  .. UnknownRichTextObject
}

/// A rich text object. As a block it is the `rich_text` variant of `Block`.
/// Rich text inputs, container titles, table cells and task cards use it
/// directly.
/// https://docs.slack.dev/reference/block-kit/blocks/rich-text-block
record RichText {
  type = "rich_text"
  elements: List(RichTextObject)
  block_id: String?
}

# ---------------------------------------------------------------- table cells and charts

/// A table cell. `action_cell` is only allowed in data table blocks.
union TableCell {
  /// Simple text.
  raw_text RawTextCell {
    text: String
  }
  /// A numeric value. Numeric columns sort by value.
  raw_number RawNumberCell {
    value: Float?
    text: String?
  }
  /// Rich text. Not allowed in header (first row) cells of data tables.
  rich_text RichTextCell(RichText)
  /// A button. Data table blocks only.
  action_cell ActionCell {
    /// Must be a button element.
    element: Element
    /// A `raw_text` or `raw_number` cell shown on clients without action cells.
    fallback: TableCell?
  }
  .. UnknownTableCell
}

/// Column alignment in a table block.
enum ColumnAlign {
  "left" as ColumnLeft
  "center" as ColumnCenter
  "right" as ColumnRight
  .. UnknownColumnAlign
}

/// Behavior of one table column.
record ColumnSetting {
  /// Defaults to `left`.
  align: ColumnAlign?
  /// Whether the column wraps. Defaults to `false`.
  is_wrapped: Bool?
}

/// A slice of a pie chart.
record ChartSegment {
  /// Legend label. Maximum 20 characters.
  label: String
  /// Weight of the slice. Greater than 0.
  value: Float
}

/// One point of a data series.
record ChartDataPoint {
  /// The x-axis category. It must be one of `axis_config.categories`.
  label: String
  /// The y-axis value. Negative values are allowed.
  value: Float
}

/// A named series of data points.
record ChartDataSeries {
  /// Legend name, unique within the chart. Maximum 20 characters.
  name: String
  /// One point per category, 1 to 20.
  data: List(ChartDataPoint)
}

/// X-axis categories and axis titles.
record ChartAxisConfig {
  /// Category labels, in display order.
  categories: List(String)
  x_label: String?
  y_label: String?
}

/// The chart of a data visualization block.
union Chart {
  pie PieChart {
    /// 1 to 12 slices.
    segments: List(ChartSegment)
  }
  bar BarChart {
    series: List(ChartDataSeries)
    axis_config: ChartAxisConfig
  }
  area AreaChart {
    series: List(ChartDataSeries)
    axis_config: ChartAxisConfig
  }
  line LineChart {
    series: List(ChartDataSeries)
    axis_config: ChartAxisConfig
  }
  .. UnknownChart
}

# ---------------------------------------------------------------- blocks

/// Holds up to 25 interactive elements.
/// https://docs.slack.dev/reference/block-kit/blocks/actions-block
record ActionsBlock {
  type = "actions"
  /// Interactive elements: buttons, selects, overflow menus, date pickers...
  elements: List(Element)
  /// A unique identifier for the block. Maximum 255 characters.
  block_id: String?
}

/// Alert levels.
enum AlertLevel {
  "default" as AlertDefault
  "info" as AlertInfo
  "warning" as AlertWarning
  "error" as AlertError
  "success" as AlertSuccess
  .. UnknownAlertLevel
}

/// Displays an alert, warning or informational message.
/// https://docs.slack.dev/reference/block-kit/blocks/alert-block
record AlertBlock {
  type = "alert"
  /// The alert message. Maximum 200 characters.
  text: Text
  /// Defaults to `default`.
  level: AlertLevel?
  block_id: String?
}

/// Displays content in a card. At least one of `hero_image`, `title`,
/// `actions` or `body` is required.
/// https://docs.slack.dev/reference/block-kit/blocks/card-block
record CardBlock {
  type = "card"
  block_id: String?
  /// The top image. Must be an image element.
  hero_image: Element?
  /// A small image next to the title. Must be an image element.
  /// Mutually exclusive with `slack_icon`.
  icon: Element?
  # The docs table says String, but the examples use text objects.
  /// Card title. Maximum 150 characters.
  title: Text?
  /// Card subtitle. Maximum 150 characters.
  subtitle: Text?
  /// Card content. Maximum 200 characters.
  body: Text?
  # The docs call this an actions block, but the examples send a plain
  # array of buttons.
  /// Up to 3 buttons.
  actions: List(Element)?
  /// A Slack icon next to the title. Mutually exclusive with `icon`.
  slack_icon: SlackIcon?
  /// Text below the body. Maximum 200 characters.
  subtext: Text?
}

/// A horizontally scrolling list of 1 to 10 card blocks.
/// https://docs.slack.dev/reference/block-kit/blocks/carousel-block
record CarouselBlock {
  type = "carousel"
  /// The cards (`Card` blocks).
  elements: List(Block)
  block_id: String?
}

/// Container widths.
enum ContainerWidth {
  "narrow" as ContainerNarrow
  "standard" as ContainerStandard
  "wide" as ContainerWide
  "full" as ContainerFull
  .. UnknownContainerWidth
}

/// Groups up to 10 child blocks. One of `title` or `rich_text_title` is
/// required.
/// https://docs.slack.dev/reference/block-kit/blocks/container-block
record ContainerBlock {
  type = "container"
  /// Title. Maximum 150 characters.
  title: PlainText?
  /// Title as rich text. It takes precedence over `title`.
  rich_text_title: RichText?
  /// Subtitle. Maximum 150 characters.
  subtitle: Text?
  /// The blocks inside: actions, context, divider, file, header, image,
  /// input, layout, rich_text, section, table or video.
  child_blocks: List(Block)
  block_id: String?
  /// Defaults to `standard`.
  width: ContainerWidth?
  /// A small image next to the title. Must be an image element.
  icon: Element?
  /// Whether it can be collapsed to its title. Defaults to `false`.
  is_collapsible: Bool?
  /// Start collapsed (needs `is_collapsible`). Defaults to `false`.
  default_collapsed: Bool?
  /// Draw a border below the header. Defaults to `false`.
  has_header_divider: Bool?
}

/// Feedback and icon buttons shown as contextual info. Maximum 5 elements.
/// https://docs.slack.dev/reference/block-kit/blocks/context-actions-block
record ContextActionsBlock {
  type = "context_actions"
  elements: List(ContextActionsElement)
  block_id: String?
}

/// Images and text shown as small contextual info. Maximum 10 elements.
/// https://docs.slack.dev/reference/block-kit/blocks/context-block
record ContextBlock {
  type = "context"
  elements: List(ContextElement)
  block_id: String?
}

/// A table with pagination, sorting, filtering and buttons.
/// https://docs.slack.dev/reference/block-kit/blocks/data-table-block
record DataTableBlock {
  type = "data_table"
  /// The rows. The first row is the header.
  rows: List(List(TableCell))
  block_id: String?
  /// Rows per page, 1 to 100. Defaults to 5.
  page_size: Int?
  /// A caption for the table.
  caption: String
  /// The 0-based index of the row header column. Defaults to 0.
  row_header_column_index: Int?
}

/// A pie, bar, area or line chart.
/// https://docs.slack.dev/reference/block-kit/blocks/data-visualization-block
record DataVisualizationBlock {
  type = "data_visualization"
  /// A label above the chart. Maximum 50 characters.
  title: String
  chart: Chart
  block_id: String?
}

/// A Call registered with `calls.add`. Only messages and `chat.unfurl` can
/// show it.
/// https://docs.slack.dev/apis/web-api/using-the-calls-api
record CallBlock {
  type = "call"
  /// The Call ID that `calls.add` returned.
  call_id: String
  block_id: String?
}

/// A visual separator.
/// https://docs.slack.dev/reference/block-kit/blocks/divider-block
record DividerBlock {
  type = "divider"
  block_id: String?
}

/// A remote file.
/// https://docs.slack.dev/reference/block-kit/blocks/file-block
record FileBlock {
  type = "file"
  /// The external unique ID of the file.
  external_id: String
  /// Always `remote`.
  source: String
  block_id: String?
}

/// Larger, bold text.
/// https://docs.slack.dev/reference/block-kit/blocks/header-block
record HeaderBlock {
  type = "header"
  /// The header text. Maximum 150 characters.
  text: PlainText
  block_id: String?
  /// Heading level, 1 to 4.
  level: Int?
}

/// An image. Provide `image_url` or `slack_file`.
/// https://docs.slack.dev/reference/block-kit/blocks/image-block
record ImageBlock {
  type = "image"
  /// A plain-text summary of the image. Maximum 2000 characters.
  alt_text: String
  /// The URL of a publicly hosted image. Maximum 3000 characters.
  image_url: String?
  /// A Slack image file.
  slack_file: SlackFile?
  /// A title. Maximum 2000 characters.
  title: PlainText?
  block_id: String?
}

/// Collects information from users with a single element.
/// https://docs.slack.dev/reference/block-kit/blocks/input-block
record InputBlock {
  type = "input"
  /// The label above the element. Maximum 2000 characters.
  label: PlainText
  /// An input-compatible element.
  element: Element
  /// Whether using the element dispatches a `block_actions` payload.
  /// Defaults to `false`. Incompatible with `file_input`.
  dispatch_action: Bool?
  block_id: String?
  /// A hint below the element. Maximum 2000 characters.
  hint: PlainText?
  /// Whether the element may be empty on submission. Defaults to `false`.
  optional: Bool?
}

/// Grid lines of a layout block.
enum GridLines {
  "none" as GridNone
  "rows" as GridRows
  "outer" as GridOuter
  .. UnknownGridLines
}

/// Widths of layout items.
enum LayoutItemWidth {
  "narrow" as LayoutNarrow
  "standard" as LayoutStandard
  "wide" as LayoutWide
  .. UnknownLayoutItemWidth
}

/// Horizontal alignment of a layout item.
enum HorizontalAlignment {
  "start" as AlignStart
  "center" as AlignCenter
  "end" as AlignEnd
  .. UnknownHorizontalAlignment
}

/// One cell of a layout row.
record LayoutItem {
  /// The child block.
  block: Block
  /// Relative width. Defaults to `standard`.
  width: LayoutItemWidth?
  /// Content alignment. Fills the cell if omitted.
  horizontal_alignment: HorizontalAlignment?
}

/// A row of 1 to 3 layout items.
record LayoutRow {
  items: List(LayoutItem)
}

/// Arranges blocks in a grid of rows and side-by-side items.
/// https://docs.slack.dev/reference/block-kit/blocks/layout-block
record LayoutBlock {
  type = "layout"
  /// Describes the layout. Maximum 150 characters.
  label: String
  /// 1 to 5 rows.
  rows: List(LayoutRow)
  /// Show `label` above the grid. Defaults to `false`.
  is_label_visible: Bool?
  /// Defaults to `none`.
  grid_lines: GridLines?
  /// Blocks shown by clients without layout support.
  fallback: List(Block)?
  block_id: String?
}

/// Standard markdown text.
/// https://docs.slack.dev/reference/block-kit/blocks/markdown-block
record MarkdownBlock {
  type = "markdown"
  /// The markdown. All markdown blocks in a payload share a 12,000 character limit.
  text: String
  /// Ignored by Slack and not retained.
  block_id: String?
}

/// The state of a task, in a task card, a plan or a streamed message.
enum TaskStatus {
  pending as TaskPending
  in_progress as TaskInProgress
  complete as TaskComplete
  "error" as TaskError
  .. UnknownTaskStatus
}

/// A single task shown as a block.
/// https://docs.slack.dev/reference/block-kit/blocks/task-card-block
record TaskCardBlock {
  type = "task_card"
  /// The task ID, unique within a plan.
  task_id: String
  /// Title of the task in plain text.
  title: String
  status: TaskStatus
  /// Details of the task.
  details: RichText?
  /// Output of the task.
  output: RichText?
  /// Sources used to generate a response.
  sources: List(UrlSource)?
  block_id: String?
  # The docs only say "Icon", so the type is `Value`.
  /// Icon of the task.
  icon: Value?
  /// Hide `title` so `details` becomes the top element.
  hide_title: Bool?
}

# The docs say plan tasks have no `type`, so this is not `TaskCardBlock`.
/// A task inside a plan block. It has the same fields as a `TaskCardBlock`,
/// without a `type`.
/// https://docs.slack.dev/reference/block-kit/blocks/plan-block
record PlanTask {
  /// The task ID, unique within a plan.
  task_id: String
  /// Title of the task in plain text.
  title: String
  status: TaskStatus
  /// Details of the task.
  details: RichText?
  /// Output of the task.
  output: RichText?
  /// Sources used to generate a response.
  sources: List(UrlSource)?
  /// Icon associated with the task. The docs only say "Icon", so this is raw json.
  icon: Value?
  /// Hide `title` so `details` becomes the top element.
  hide_title: Bool?
}

/// A collection of related tasks.
/// https://docs.slack.dev/reference/block-kit/blocks/plan-block
record PlanBlock {
  type = "plan"
  /// Title of the plan in plain text.
  title: String
  /// Up to 50 tasks.
  tasks: List(PlanTask)
  block_id: String?
}

/// Displays text, possibly with an accessory element. Provide `text`,
/// `fields`, or both.
/// https://docs.slack.dev/reference/block-kit/blocks/section-block
record SectionBlock {
  type = "section"
  /// The text. 1 to 3000 characters.
  text: Text?
  block_id: String?
  /// Up to 10 text objects in two columns. Maximum 2000 characters each.
  fields: List(Text)?
  /// A section-compatible element.
  accessory: Element?
  /// Always show the full text, without "see more".
  expand: Bool?
}

/// Structured information in a table.
/// https://docs.slack.dev/reference/block-kit/blocks/table-block
record TableBlock {
  type = "table"
  block_id: String?
  /// Up to 100 rows of up to 20 `raw_text`, `raw_number` or `rich_text` cells.
  rows: List(List(TableCell))
  /// Column behavior, in column order. `null` (`None`) keeps a column's
  /// defaults.
  column_settings: List(ColumnSetting?)?
}

/// An embedded video player.
/// https://docs.slack.dev/reference/block-kit/blocks/video-block
record VideoBlock {
  type = "video"
  /// A tooltip for the video.
  alt_text: String
  /// Author name. Less than 50 characters.
  author_name: String?
  block_id: String?
  /// Description. Less than 200 characters.
  description: PlainText?
  /// Icon of the video provider.
  provider_icon_url: String?
  /// The originating application or domain, such as YouTube.
  provider_name: String?
  /// Video title. Less than 200 characters.
  title: PlainText
  /// Non-embeddable HTTPS link for the title.
  title_url: String?
  /// The thumbnail image URL.
  thumbnail_url: String
  /// The HTTPS URL to embed. It must match an unfurl domain of the app.
  video_url: String
}

/// A Block Kit block.
/// https://docs.slack.dev/reference/block-kit/blocks
union Block builders {
  actions Actions(ActionsBlock)
  alert Alert(AlertBlock)
  call Call(CallBlock)
  card Card(CardBlock)
  carousel Carousel(CarouselBlock)
  container Container(ContainerBlock)
  context Context(ContextBlock)
  context_actions ContextActions(ContextActionsBlock)
  data_table DataTable(DataTableBlock)
  data_visualization DataVisualization(DataVisualizationBlock)
  divider Divider(DividerBlock)
  file File(FileBlock)
  header Header(HeaderBlock)
  /// An image. Set `image_url` or `slack_file`.
  /// https://docs.slack.dev/reference/block-kit/blocks/image-block
  image Image(ImageBlock) builder(alt_text)
  input Input(InputBlock)
  layout Layout(LayoutBlock)
  markdown Markdown(MarkdownBlock)
  plan Plan(PlanBlock)
  /// Formatted, structured text.
  rich_text RichTextBlock(RichText)
  section Section(SectionBlock) builder(text)
  table Table(TableBlock)
  task_card TaskCard(TaskCardBlock)
  video Video(VideoBlock)
  .. UnknownBlock
}
