//// Views: modals and App Home tabs, plus the state Slack reports back for
//// their input elements.
////
//// One `View` record covers both surfaces. `view_type` says which. Fields
//// that Slack only adds in responses and payloads (`id`, `hash`, `state`,
//// ...) are optional. Use `modal` and `home` to build views with the fields
//// that each surface requires.
////
//// Reference: https://docs.slack.dev/reference/views
module slackline/view

/// The kind of surface a view is shown on.
enum ViewType {
  /// A modal dialog.
  modal
  /// An App Home tab.
  home
  .. UnknownViewType
}

/// The value of one input element in a view's state. Which field is set
/// depends on the element type.
/// https://docs.slack.dev/reference/interaction-payloads/view-interactions-payload
union ViewStateValue {
  plain_text_input StatePlainTextInput {
    value: String?
  }
  email_text_input StateEmailTextInput {
    value: String?
  }
  url_text_input StateUrlTextInput {
    value: String?
  }
  /// The number as typed, for example `"4.5"`.
  number_input StateNumberInput {
    value: String?
  }
  static_select StateStaticSelect {
    selected_option: SelectOption?
  }
  external_select StateExternalSelect {
    selected_option: SelectOption?
  }
  multi_static_select StateMultiStaticSelect {
    selected_options: List(SelectOption)?
  }
  multi_external_select StateMultiExternalSelect {
    selected_options: List(SelectOption)?
  }
  users_select StateUsersSelect {
    selected_user: String?
  }
  multi_users_select StateMultiUsersSelect {
    selected_users: List(String)?
  }
  conversations_select StateConversationsSelect {
    selected_conversation: String?
  }
  multi_conversations_select StateMultiConversationsSelect {
    selected_conversations: List(String)?
  }
  channels_select StateChannelsSelect {
    selected_channel: String?
  }
  multi_channels_select StateMultiChannelsSelect {
    selected_channels: List(String)?
  }
  /// `YYYY-MM-DD`.
  datepicker StateDatepicker {
    selected_date: String?
  }
  /// `HH:mm`, with the timezone configured on the element.
  timepicker StateTimepicker {
    selected_time: String?
    timezone: String?
  }
  /// A UNIX timestamp in seconds.
  datetimepicker StateDatetimepicker {
    selected_date_time: Int?
  }
  checkboxes StateCheckboxes {
    selected_options: List(SelectOption)?
  }
  radio_buttons StateRadioButtons {
    selected_option: SelectOption?
  }
  rich_text_input StateRichTextInput {
    rich_text_value: RichText?
  }
  /// The uploaded files, as file objects (raw json, since the file module
  /// comes later in the dependency order).
  file_input StateFileInput {
    files: List(Value)?
  }
  .. UnknownViewStateValue
}

/// The state of a view's input elements.
record ViewState {
  /// `block_id` to `action_id` to the element's value.
  values: Dict(Dict(ViewStateValue))
}

/// A modal or Home tab view.
/// https://docs.slack.dev/reference/views/modal-views
/// https://docs.slack.dev/reference/views/home-tab-views
record View {
  /// `modal` or `home`.
  "type" as view_type: ViewType
  /// The content of the view. Maximum 100 blocks.
  blocks: List(Block)
  /// Modal title, top left. Required for modals. Maximum 24 characters.
  title: PlainText?
  /// Modal close button text. Maximum 24 characters.
  close: PlainText?
  /// Modal submit button text. Required when `blocks` contains an input
  /// block. Maximum 24 characters.
  submit: PlainText?
  /// Sent back to your app in `view_submission` and `block_actions`
  /// payloads. Maximum 3000 characters.
  private_metadata: String?
  /// Identifies interactions with this view. Maximum 255 characters.
  callback_id: String?
  /// Modals: close clears every view in the stack. Defaults to `false`.
  clear_on_close: Bool?
  /// Modals: send a `view_closed` event on close. Defaults to `false`.
  notify_on_close: Bool?
  /// A custom identifier, unique per team.
  external_id: String?
  /// Configuration modals: disable submit until inputs are completed.
  submit_disabled: Bool?
  /// The view ID. Set by Slack.
  id: String?
  /// The workspace the view belongs to. Set by Slack.
  team_id: String?
  /// Current values of the input elements. Set by Slack.
  state: ViewState?
  /// Pass to `views.update` to avoid race conditions. Set by Slack.
  hash: String?
  /// The view this one was pushed on top of. Set by Slack.
  previous_view_id: String?
  /// The first view of the modal stack. Set by Slack.
  root_view_id: String?
  /// The app that owns the view. Set by Slack.
  app_id: String?
  /// The bot user of the app. Set by Slack.
  bot_id: String?
  /// The workspace the app is installed on. Set by Slack.
  app_installed_team_id: String?
}
