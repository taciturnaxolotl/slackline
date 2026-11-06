//// Legacy dialogs (`dialog.*`). Slack recommends modals instead.
module slackline/api/dialog

/// A keyboard hint for text inputs.
enum DialogTextSubtype {
  email
  number
  tel
  url
}

/// Where a select element's options come from.
enum DialogDataSource {
  static as StaticDataSource
  users as UsersDataSource
  channels as ChannelsDataSource
  conversations as ConversationsDataSource
  external as ExternalDataSource
}

/// A dialog form element.
union DialogElement tag "type" {
  /// A single-line plain text input.
  text DialogTextElement {
    /// Label displayed to the user. 48 characters maximum.
    label: String
    /// Name of the element, used as the key in the submission. 300
    /// characters maximum.
    name: String
    /// Guides users in completing the element. 150 characters maximum.
    placeholder: String?
    /// Maximum input length, up to 150. Defaults to 150.
    max_length: Int?
    /// Minimum input length, up to 150. Defaults to 0.
    min_length: Int?
    /// `true` when the element is not required.
    optional: Bool?
    /// Helpful text shown with the element. 150 characters maximum.
    hint: String?
    /// Optimizes the input for a kind of value. Does not validate.
    subtype: DialogTextSubtype?
    /// A default value. 150 characters maximum.
    value: String?
  }
  /// A multi-line plain text input.
  textarea DialogTextareaElement {
    /// Label displayed to the user. 48 characters maximum.
    label: String
    /// Name of the element, used as the key in the submission. 300
    /// characters maximum.
    name: String
    /// Guides users in completing the element. 150 characters maximum.
    placeholder: String?
    /// Maximum input length, up to 3000. Defaults to 3000.
    max_length: Int?
    /// Minimum input length, up to 3000. Defaults to 0.
    min_length: Int?
    /// `true` when the element is not required.
    optional: Bool?
    /// Helpful text shown with the element. 150 characters maximum.
    hint: String?
    /// Optimizes the input for a kind of value. Does not validate.
    subtype: DialogTextSubtype?
    /// A default value. 3000 characters maximum.
    value: String?
  }
  /// A select menu with static or dynamic options.
  select DialogSelectElement {
    /// Label displayed to the user. 48 characters maximum.
    label: String
    /// Name of the element, used as the key in the submission. 300
    /// characters maximum.
    name: String
    /// Where the options come from. Defaults to `static`.
    data_source: DialogDataSource?
    /// Characters a user must type before options are requested from an
    /// `external` data source.
    min_query_length: Int?
    /// Guides users in completing the element. 150 characters maximum.
    placeholder: String?
    /// `true` when the element is not required.
    optional: Bool?
    /// The default selected value, for every data source except `external`.
    value: String?
    /// The default selection for an `external` data source: a single option.
    selected_options: List(DialogOption)?
    /// Up to 100 options. `options` or `option_groups` is required for
    /// `static` and `external` menus.
    options: List(DialogOption)?
    /// Up to 100 option groups.
    option_groups: List(DialogOptionGroup)?
  }
  .. UnknownDialogElement
}

/// A legacy dialog definition.
record Dialog {
  /// User-facing title. 24 characters maximum.
  title: String
  /// Identifies submissions of this dialog. 255 characters maximum.
  callback_id: String
  /// The form elements, up to 10.
  elements: List(DialogElement)
  /// A string echoed back on submission and cancellation. Up to 3000
  /// characters.
  state: String?
  /// Label of the submit button. A single word, 48 characters maximum.
  /// Defaults to `Submit`.
  submit_label: String?
  /// When `true`, your request URL is notified when the user cancels.
  notify_on_cancel: Bool?
}

method dialog.open {
  args {
    /// The dialog definition.
    dialog: Dialog
  }
  response Nil
}
