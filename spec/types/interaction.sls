//// Interactivity: the payloads Slack sends to an app's interactivity
//// Request URL (as the json in the `payload` form field) or over Socket
//// Mode `interactive` envelopes, and the responses an app sends back.
////
//// See <https://docs.slack.dev/reference/interaction-payloads> and
//// <https://docs.slack.dev/interactivity/handling-user-interaction>.
module slackline/interaction

# ---------------------------------------------------------------- payloads

/// Received when a user interacts with a Block Kit interactive component.
/// <https://docs.slack.dev/reference/interaction-payloads/block_actions-payload>
record BlockActionsPayload {
  type = "block_actions"
  /// The user who interacted to trigger this request.
  user: InteractionUser
  /// The workspace the app is installed on. Null if the app is org-installed.
  team: InteractionTeam?
  /// The enterprise the installed app is part of, if the app is either workspace-installed on an org, or org-installed.
  enterprise: InteractionEnterprise?
  /// Whether the app is installed at the org level.
  is_enterprise_install: Bool?
  /// A string representing the app ID.
  api_app_id: String?
  /// A deprecated verification token. Validate requests with the signing secret instead.
  token: String?
  /// The container where this block action took place.
  container: Container?
  /// A short-lived ID that can be used to open modals.
  trigger_id: String?
  /// The channel where this block action took place.
  channel: InteractionChannel?
  /// The message where this block action took place, if the block was contained in a message.
  message: Message?
  /// The view where this block action took place, if the block was contained in a view.
  view: View?
  /// Data from the specific interactive components that were used.
  actions: List(BlockAction)?
  /// All stateful elements of the surface, not only input blocks.
  state: ViewState?
  /// A value accepted by `views.update` and `views.publish` to make sure only the most recent view is updated.
  hash: String?
  /// A short-lived webhook that can be used to send messages in response to interactions.
  response_url: String?
  /// Metadata about the function execution that generated the block (apps built with the Deno Slack SDK).
  function_data: FunctionData?
  /// An interactivity object generated as a result of the block action (functions only).
  interactivity: Interactivity?
  /// A workflow (just-in-time) token generated for this block action (functions only).
  bot_access_token: String?
}

/// Received when a select menu of external data source needs options.
/// Respond with an `OptionsResponse`.
/// <https://docs.slack.dev/reference/interaction-payloads/block_suggestion-payload>
record BlockSuggestionPayload {
  type = "block_suggestion"
  /// The user that initiated the block suggestion interaction. `team_id` is an enterprise ID on Enterprise orgs.
  user: InteractionUser
  /// The workspace the interaction originated from.
  team: InteractionTeam?
  /// The enterprise the installed app is part of, if any.
  enterprise: InteractionEnterprise?
  /// Whether the app is installed at the org level.
  is_enterprise_install: Bool?
  /// The encoded application ID the event was dispatched to.
  api_app_id: String?
  /// A deprecated verification token.
  token: String?
  /// The container where this block suggestion took place.
  container: Container?
  /// Identifies the block that contained the select menu.
  block_id: String
  /// Identifies the select menu itself.
  action_id: String
  /// The value the user entered into the select menu.
  value: String
  /// The channel the interaction originated from.
  channel: InteractionChannel?
  /// The message where this block suggestion took place, if the block was contained in a message.
  message: Message?
  /// The view where this block suggestion took place, if the block was contained in a view.
  view: View?
  /// Metadata about the function execution (functions only).
  function_data: FunctionData?
  /// A workflow (just-in-time) token (functions only).
  bot_access_token: String?
}

/// Received when a user submits a modal.
/// Respond with a `ViewSubmissionResponse` or an empty 200.
/// <https://docs.slack.dev/reference/interaction-payloads/view-interactions-payload#view_submission>
record ViewSubmissionPayload {
  type = "view_submission"
  /// The user who submitted the view.
  user: InteractionUser
  /// The workspace the view was submitted from. Null if the app is org-installed.
  team: InteractionTeam?
  # The docs mark this field required, but the docs example leaves it out.
  /// The enterprise the installed app is part of, if any.
  enterprise: InteractionEnterprise?
  /// Whether the app is installed at the org level.
  is_enterprise_install: Bool?
  /// A string representing the app ID.
  api_app_id: String?
  /// A deprecated verification token.
  token: String?
  /// A short-lived ID that can be used to open modals.
  trigger_id: String?
  /// The source view of the modal the user submitted. `view.state.values` holds the submitted values.
  view: View
  /// A value accepted by `views.update` and `views.publish`.
  hash: String?
  /// Present when the view contained elements with `response_url_enabled`.
  response_urls: List(ResponseUrl)?
  /// Metadata about the function execution (functions only).
  function_data: FunctionData?
  /// An interactivity object generated as a result of the view submission (functions only).
  interactivity: Interactivity?
  /// A workflow (just-in-time) token (functions only).
  bot_access_token: String?
}

/// Received when a user dismisses a modal created with `notify_on_close: true`.
/// <https://docs.slack.dev/reference/interaction-payloads/view-interactions-payload#view_closed>
record ViewClosedPayload {
  type = "view_closed"
  /// The user who dismissed the modal.
  user: InteractionUser
  /// The workspace that the interaction happened in.
  team: InteractionTeam?
  /// The enterprise the installed app is part of, if any.
  enterprise: InteractionEnterprise?
  /// Whether the app is installed at the org level.
  is_enterprise_install: Bool?
  /// A string representing the app ID.
  api_app_id: String?
  /// A deprecated verification token.
  token: String?
  /// The source modal view that the user dismissed, excluding input blocks.
  view: View
  /// Whether the whole view stack was cleared.
  is_cleared: Bool?
  /// Metadata about the function execution (functions only).
  function_data: FunctionData?
  /// An interactivity object (functions only).
  interactivity: Interactivity?
  /// A workflow (just-in-time) token (functions only).
  bot_access_token: String?
}

/// Received when a global shortcut is used.
/// <https://docs.slack.dev/reference/interaction-payloads/shortcuts-interaction-payload>
record GlobalShortcutPayload {
  type = "shortcut"
  /// The ID defined when creating the shortcut.
  callback_id: String
  /// A temporary ID that can be used to open modals.
  trigger_id: String?
  /// The user who initiated the shortcut.
  user: InteractionUser
  /// The workspace the shortcut was initiated in.
  team: InteractionTeam?
  /// The enterprise the installed app is part of, if any.
  enterprise: InteractionEnterprise?
  /// Whether the app is installed at the org level.
  is_enterprise_install: Bool?
  /// A deprecated verification token.
  token: String?
  /// When the shortcut was used.
  action_ts: String?
}

# The reference page calls this type `message_actions`. The example (real
# data) uses `message_action`.
/// Sent when a user runs a message shortcut from the message context menu.
record MessageShortcutPayload {
  type = "message_action"
  /// The ID defined when creating the shortcut.
  callback_id: String
  /// A temporary ID that can be used to open modals.
  trigger_id: String?
  /// A temporary webhook that can be used to send messages in response.
  response_url: String?
  /// The user who initiated the shortcut.
  user: InteractionUser
  /// The workspace the shortcut was initiated in.
  team: InteractionTeam?
  /// The enterprise the installed app is part of, if any.
  enterprise: InteractionEnterprise?
  /// Whether the app is installed at the org level.
  is_enterprise_install: Bool?
  /// The channel that the source message was located in.
  channel: InteractionChannel?
  /// The message that the user initiated the shortcut from.
  message: Message?
  /// The `ts` of the source message.
  message_ts: String?
  /// A deprecated verification token.
  token: String?
  /// When the shortcut was used.
  action_ts: String?
}

/// Legacy: a message button or menu in a secondary attachment was used, or
/// an attachment menu with `data_source: external` needs options (then
/// `name` and `value` are set instead of `actions`).
/// <https://docs.slack.dev/legacy/legacy-messaging/legacy-interactive-message-field-guide#action_payload>
record InteractiveMessagePayload {
  type = "interactive_message"
  /// The actions that were clicked. Only one action is sent per invocation.
  actions: List(LegacyAction)?
  /// The `callback_id` of the attachment that contained the action.
  callback_id: String
  /// The workspace where this action occurred.
  team: InteractionTeam?
  /// The enterprise the installed app is part of, if any.
  enterprise: InteractionEnterprise?
  /// Whether the app is installed at the org level.
  is_enterprise_install: Bool?
  /// The channel housing the originating message.
  channel: InteractionChannel?
  /// The user who invoked the action.
  user: InteractionUser
  /// When the action occurred.
  action_ts: String?
  /// When the message containing the action was posted.
  message_ts: String?
  /// A 1-indexed identifier for the attachment within the message, as a string.
  attachment_id: String?
  /// A deprecated verification token.
  token: String?
  /// Whether the message is an app unfurl.
  is_app_unfurl: Bool?
  /// The original message that triggered this action. Not provided for ephemeral messages.
  original_message: Message?
  /// A URL used to respond to this invocation.
  response_url: String?
  /// A short-lived ID that can be used to open modals or dialogs.
  trigger_id: String?
  /// Options load requests only: the name of the message menu being invoked.
  name: String?
  /// Options load requests only: what the user typed into the menu.
  value: String?
}

/// Legacy: a dialog was submitted. Respond with an empty 200 or a `DialogErrorsResponse`.
/// <https://docs.slack.dev/legacy/legacy-dialogs#submit>
record DialogSubmissionPayload {
  type = "dialog_submission"
  /// The submitted values, keyed by the element `name`. Values are strings (or null for empty optional elements).
  submission: Dict(Value)
  /// The `callback_id` the app gave this dialog.
  callback_id: String
  /// The `state` string the app passed to `dialog.open`.
  state: String?
  /// The workspace from which this interaction occurred.
  team: InteractionTeam?
  /// The enterprise the installed app is part of, if any.
  enterprise: InteractionEnterprise?
  /// The user who completed the form.
  user: InteractionUser
  /// The channel where this dialog was completed.
  channel: InteractionChannel?
  /// A unique identifier for this action occurrence.
  action_ts: String?
  /// A deprecated verification token.
  token: String?
  /// A URL that can be used to post responses to the submission.
  response_url: String?
}

/// Legacy: a dialog opened with `notify_on_cancel: true` was dismissed.
record DialogCancellationPayload {
  type = "dialog_cancellation"
  /// The `callback_id` the app gave this dialog.
  callback_id: String
  /// The `state` string the app passed to `dialog.open`.
  state: String?
  /// The workspace from which this interaction occurred.
  team: InteractionTeam?
  /// The enterprise the installed app is part of, if any.
  enterprise: InteractionEnterprise?
  /// The user who dismissed the dialog.
  user: InteractionUser
  /// The channel where the dialog was opened.
  channel: InteractionChannel?
  /// A unique identifier for this action occurrence.
  action_ts: String?
  /// A deprecated verification token.
  token: String?
  /// A URL that can be used to follow up with the user.
  response_url: String?
}

/// Legacy: a dialog `select` with `data_source: external` needs options.
/// Respond with a `DialogOptionsResponse`.
record DialogSuggestionPayload {
  type = "dialog_suggestion"
  /// The `callback_id` the app gave this dialog.
  callback_id: String
  /// The name of the select element.
  name: String?
  /// What the user has typed so far.
  value: String?
  /// The workspace from which this interaction occurred.
  team: InteractionTeam?
  /// The enterprise the installed app is part of, if any.
  enterprise: InteractionEnterprise?
  /// The user interacting with the dialog.
  user: InteractionUser
  /// The channel where the dialog was opened.
  channel: InteractionChannel?
  /// A unique identifier for this action occurrence.
  action_ts: String?
  /// A deprecated verification token.
  token: String?
}

/// An interaction payload, dispatched on `type`. Each variant wraps the
/// payload record, so handlers can take exactly the payload they handle.
union Interaction tag "type" {
  block_actions BlockActions(BlockActionsPayload)
  block_suggestion BlockSuggestion(BlockSuggestionPayload)
  view_submission ViewSubmission(ViewSubmissionPayload)
  view_closed ViewClosed(ViewClosedPayload)
  shortcut GlobalShortcut(GlobalShortcutPayload)
  message_action MessageShortcut(MessageShortcutPayload)
  interactive_message InteractiveMessage(InteractiveMessagePayload)
  dialog_submission DialogSubmission(DialogSubmissionPayload)
  dialog_cancellation DialogCancellation(DialogCancellationPayload)
  dialog_suggestion DialogSuggestion(DialogSuggestionPayload)
  .. UnknownInteraction
}

/// The user who triggered an interaction.
record InteractionUser {
  /// The user ID.
  id: String
  /// The user's handle.
  username: String?
  /// The user's name (deprecated in favor of `id`).
  name: String?
  /// The user's workspace, or an enterprise ID (starting with `E`) on Enterprise organizations.
  team_id: String?
}

/// The workspace an interaction happened in.
record InteractionTeam {
  /// The workspace ID.
  id: String
  /// The slack.com subdomain of the workspace.
  domain: String?
  /// On Enterprise organizations, the ID of the org.
  enterprise_id: String?
  /// On Enterprise organizations, the name of the org.
  enterprise_name: String?
}

/// The enterprise organization an app is installed in.
record InteractionEnterprise {
  /// The enterprise ID.
  id: String
  /// The enterprise name.
  name: String?
}

/// The channel an interaction happened in.
record InteractionChannel {
  /// The channel ID.
  id: String
  /// The channel name, without the leading `#`.
  name: String?
}

/// Where a block action or suggestion took place.
union Container tag "type" {
  /// A block in a message.
  message MessageContainer {
    message_ts: String?
    channel_id: String?
    is_ephemeral: Bool?
    thread_ts: String?
  }
  /// A block in a secondary message attachment.
  message_attachment MessageAttachmentContainer {
    message_ts: String?
    attachment_id: Int?
    channel_id: String?
    is_ephemeral: Bool?
    is_app_unfurl: Bool?
  }
  /// A block in a modal or Home tab view.
  view ViewContainer {
    view_id: String?
  }
  .. UnknownContainer
}

/// Metadata about the function execution that generated a block or view.
record FunctionData {
  /// The function execution ID.
  execution_id: String?
  /// The function being executed.
  function: FunctionRef?
  /// The inputs the function was called with.
  inputs: Dict(Value)?
}

/// A reference to a function by its `callback_id`.
record FunctionRef {
  callback_id: String
}

/// An interactivity context, as passed between functions.
/// <https://docs.slack.dev/reference/types/interactivity-type>
record Interactivity {
  /// The user who initiated the interactivity.
  interactor: Interactor?
  /// A pointer used to confirm user-initiated interactivity in a function.
  interactivity_pointer: String?
}

/// The user who initiated an interactivity.
record Interactor {
  id: String
  secret: String?
}

/// A `response_url` generated for a modal element with `response_url_enabled`.
record ResponseUrl {
  /// The block that contained the element.
  block_id: String?
  /// The element that generated the URL.
  action_id: String?
  /// Where the `response_url` will publish to.
  channel_id: String?
  /// The webhook URL.
  response_url: String
}

# ---------------------------------------------------------------- block actions

# The docs only spell out `action_id`, `block_id`, `value` and `action_ts`.
# The `selected_*` fields follow the `initial_*` field names of the element
# and the shape Slack sends in view state.
/// One action in a `block_actions` payload. The element `type` selects the
/// variant.
union BlockAction tag "type" {
  button ButtonAction {
    action_id: String
    block_id: String?
    action_ts: String?
    /// The button's text.
    text: Text?
    /// The value set on the button.
    value: String?
    /// The button style, `primary` or `danger`.
    style: String?
  }
  workflow_button WorkflowButtonAction {
    action_id: String
    block_id: String?
    action_ts: String?
    text: Text?
    value: String?
  }
  icon_button IconButtonAction {
    action_id: String
    block_id: String?
    action_ts: String?
    value: String?
  }
  feedback_buttons FeedbackButtonsAction {
    action_id: String
    block_id: String?
    action_ts: String?
    /// The `value` of the button that was pressed.
    value: String?
  }
  overflow OverflowAction {
    action_id: String
    block_id: String?
    action_ts: String?
    /// The option that was clicked.
    selected_option: SelectOption?
  }
  checkboxes CheckboxesAction {
    action_id: String
    block_id: String?
    action_ts: String?
    /// Every checked option.
    selected_options: List(SelectOption)?
  }
  radio_buttons RadioButtonsAction {
    action_id: String
    block_id: String?
    action_ts: String?
    /// The selected radio button. Null after deselection.
    selected_option: SelectOption?
  }
  static_select StaticSelectAction {
    action_id: String
    block_id: String?
    action_ts: String?
    placeholder: Text?
    /// The chosen option. Null when the user deselects it.
    selected_option: SelectOption?
  }
  external_select ExternalSelectAction {
    action_id: String
    block_id: String?
    action_ts: String?
    placeholder: Text?
    selected_option: SelectOption?
  }
  users_select UsersSelectAction {
    action_id: String
    block_id: String?
    action_ts: String?
    placeholder: Text?
    /// The chosen user ID.
    selected_user: String?
  }
  conversations_select ConversationsSelectAction {
    action_id: String
    block_id: String?
    action_ts: String?
    placeholder: Text?
    /// The chosen conversation ID.
    selected_conversation: String?
  }
  channels_select ChannelsSelectAction {
    action_id: String
    block_id: String?
    action_ts: String?
    placeholder: Text?
    /// The chosen public channel ID.
    selected_channel: String?
  }
  multi_static_select MultiStaticSelectAction {
    action_id: String
    block_id: String?
    action_ts: String?
    placeholder: Text?
    selected_options: List(SelectOption)?
  }
  multi_external_select MultiExternalSelectAction {
    action_id: String
    block_id: String?
    action_ts: String?
    placeholder: Text?
    selected_options: List(SelectOption)?
  }
  multi_users_select MultiUsersSelectAction {
    action_id: String
    block_id: String?
    action_ts: String?
    placeholder: Text?
    selected_users: List(String)?
  }
  multi_conversations_select MultiConversationsSelectAction {
    action_id: String
    block_id: String?
    action_ts: String?
    placeholder: Text?
    selected_conversations: List(String)?
  }
  multi_channels_select MultiChannelsSelectAction {
    action_id: String
    block_id: String?
    action_ts: String?
    placeholder: Text?
    selected_channels: List(String)?
  }
  datepicker DatepickerAction {
    action_id: String
    block_id: String?
    action_ts: String?
    /// The chosen date, `YYYY-MM-DD`.
    selected_date: String?
  }
  timepicker TimepickerAction {
    action_id: String
    block_id: String?
    action_ts: String?
    /// The chosen time, `HH:mm`.
    selected_time: String?
    /// The IANA timezone configured on the element.
    timezone: String?
  }
  datetimepicker DatetimepickerAction {
    action_id: String
    block_id: String?
    action_ts: String?
    /// The chosen date and time as a UNIX timestamp in seconds.
    selected_date_time: Int?
  }
  /// Sent when the input block has `dispatch_action` set.
  plain_text_input PlainTextInputAction {
    action_id: String
    block_id: String?
    action_ts: String?
    value: String?
  }
  email_text_input EmailTextInputAction {
    action_id: String
    block_id: String?
    action_ts: String?
    value: String?
  }
  url_text_input UrlTextInputAction {
    action_id: String
    block_id: String?
    action_ts: String?
    value: String?
  }
  number_input NumberInputAction {
    action_id: String
    block_id: String?
    action_ts: String?
    /// The number as typed, a string.
    value: String?
  }
  rich_text_input RichTextInputAction {
    action_id: String
    block_id: String?
    action_ts: String?
    /// The entered text as a `rich_text` object.
    rich_text_value: RichText?
  }
  .. UnknownBlockAction
}

/// Legacy: an action from an interactive message attachment.
record LegacyAction {
  /// The `name` set on the originating action.
  name: String?
  /// The `value` set on the originating button.
  value: String?
  /// `button` or `select`.
  "type" as action_type: String?
  /// For message menus, the selected option.
  selected_options: List(LegacySelectedOption)?
}

/// Legacy: an option chosen from a message menu.
record LegacySelectedOption {
  value: String
}

# ---------------------------------------------------------------- responses

/// The body an app returns to a `view_submission` payload, on `response_action`.
/// <https://docs.slack.dev/surfaces/modals#updating_response>
union ViewSubmissionResponse tag "response_action" {
  /// Show validation errors, keyed by the `block_id` of the input block.
  errors ErrorsResponse {
    errors: Dict(String)
  }
  /// Replace the submitted view.
  update UpdateResponse {
    view: View
  }
  /// Push a new view onto the stack.
  push PushResponse {
    view: View
  }
  /// Close every view in the stack.
  clear ClearResponse
  .. UnknownViewSubmissionResponse
}

/// The body an app returns to a `block_suggestion` payload. Send either
/// `options` or `option_groups`, at most 100 of either.
/// <https://docs.slack.dev/reference/block-kit/block-elements/select-menu-element#external_select>
record OptionsResponse {
  options: List(SelectOption)?
  option_groups: List(OptionGroup)?
}

/// Legacy: the body an app returns to a `dialog_suggestion` payload.
record DialogOptionsResponse {
  options: List(DialogOption)?
  option_groups: List(DialogOptionGroup)?
}

/// Legacy: a dialog select option. Dialogs use `label`, not `text`.
record DialogOption {
  /// A user-facing label, 75 characters maximum.
  label: String
  /// The value sent to the app, 75 characters maximum.
  value: String
}

/// Legacy: a group of dialog select options.
record DialogOptionGroup {
  /// A user-facing label for the group, 75 characters maximum.
  label: String
  /// The options in the group.
  options: List(DialogOption)
}

/// Legacy: the body an app returns to reject a `dialog_submission`.
record DialogErrorsResponse {
  errors: List(DialogError)
}

/// Legacy: one rejected dialog element.
record DialogError {
  /// The `name` of the element being rejected.
  name: String
  /// Why the element is being rejected.
  error: String
}

/// Where a `response_url` message is shown.
enum ResponseType {
  /// Visible to everyone in the conversation.
  in_channel
  /// Visible only to the user who interacted (the default).
  ephemeral
}

/// A message posted to a `response_url`, or returned in the body of a slash
/// command response.
/// <https://docs.slack.dev/interactivity/handling-user-interaction#message_responses>
record ResponseMessage {
  /// The message text. Used as the fallback when `blocks` are present.
  text: String?
  /// Block Kit blocks.
  blocks: List(Block)?
  /// Legacy secondary attachments.
  attachments: List(Attachment)?
  /// `in_channel` or `ephemeral` (the default).
  response_type: ResponseType?
  /// Replace the message the interaction came from.
  replace_original: Bool?
  /// Delete the message the interaction came from. Not supported for slash commands.
  delete_original: Bool?
  /// Post as a reply in this thread (with `response_type: in_channel`).
  thread_ts: String?
  /// Whether `text` uses mrkdwn formatting.
  mrkdwn: Bool?
}
