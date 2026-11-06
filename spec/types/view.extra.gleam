import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import slackline/block

// ---------------------------------------------------------------- builders

/// An optional field of a view, for `modal` and `home`.
///
/// Modals and Home tabs share one `View` record, but some fields only work on
/// modals. `kind` records which surface an attribute is for, so a modal-only
/// attribute on a Home tab does not compile. `callback_id` and the other
/// shared attributes work on both. `submit`, `close` and the other modal
/// attributes only work on `modal`.
pub opaque type Attr(kind) {
  Attr(fn(View) -> View)
}

/// The kind of attributes that only modals accept.
pub type Modal

/// The kind of attributes that only Home tabs accept.
pub type Home

fn empty_view(view_type: ViewType, blocks: List(block.Block)) -> View {
  View(
    view_type: view_type,
    blocks: blocks,
    title: None,
    close: None,
    submit: None,
    private_metadata: None,
    callback_id: None,
    clear_on_close: None,
    notify_on_close: None,
    external_id: None,
    submit_disabled: None,
    id: None,
    team_id: None,
    state: None,
    hash: None,
    previous_view_id: None,
    root_view_id: None,
    app_id: None,
    bot_id: None,
    app_installed_team_id: None,
  )
}

fn apply(view: View, attrs: List(Attr(kind))) -> View {
  list.fold(attrs, view, fn(view, attr) {
    let Attr(set) = attr
    set(view)
  })
}

/// A modal with a plain text title (maximum 24 characters). Set `submit`
/// when the blocks contain an input block:
///
/// ```gleam
/// view.modal(
///   "Feedback",
///   [block.input("Thoughts", element.plain_text_input("thoughts", []), [])],
///   [view.callback_id("feedback"), view.submit("Send")],
/// )
/// ```
pub fn modal(
  title title: String,
  blocks blocks: List(block.Block),
  with attrs: List(Attr(Modal)),
) -> View {
  View(..empty_view(Modal, blocks), title: Some(block.plain_text(title)))
  |> apply(attrs)
}

/// An App Home tab view, for `views.publish`.
pub fn home(
  blocks blocks: List(block.Block),
  with attrs: List(Attr(Home)),
) -> View {
  empty_view(Home, blocks) |> apply(attrs)
}

/// Identifies interactions with the view, such as its `view_submission`.
/// Maximum 255 characters.
pub fn callback_id(callback_id: String) -> Attr(kind) {
  Attr(fn(view) { View(..view, callback_id: Some(callback_id)) })
}

/// Sent back to your app in `view_submission` and `block_actions` payloads.
/// Maximum 3000 characters.
pub fn private_metadata(private_metadata: String) -> Attr(kind) {
  Attr(fn(view) { View(..view, private_metadata: Some(private_metadata)) })
}

/// A custom identifier, unique per team.
pub fn external_id(external_id: String) -> Attr(kind) {
  Attr(fn(view) { View(..view, external_id: Some(external_id)) })
}

/// The submit button text. Required when the blocks contain an input block.
/// Maximum 24 characters.
pub fn submit(text: String) -> Attr(Modal) {
  Attr(fn(view) { View(..view, submit: Some(block.plain_text(text))) })
}

/// The close button text. Maximum 24 characters.
pub fn close(text: String) -> Attr(Modal) {
  Attr(fn(view) { View(..view, close: Some(block.plain_text(text))) })
}

/// Whether closing the modal clears every view in the stack.
pub fn clear_on_close(clear_on_close: Bool) -> Attr(Modal) {
  Attr(fn(view) { View(..view, clear_on_close: Some(clear_on_close)) })
}

/// Whether closing the modal sends a `view_closed` payload.
pub fn notify_on_close(notify_on_close: Bool) -> Attr(Modal) {
  Attr(fn(view) { View(..view, notify_on_close: Some(notify_on_close)) })
}

/// For configuration modals: disables submit until the user completes the
/// inputs.
pub fn submit_disabled(submit_disabled: Bool) -> Attr(Modal) {
  Attr(fn(view) { View(..view, submit_disabled: Some(submit_disabled)) })
}

// ---------------------------------------------------------------- state

/// Looks up the value of the element with `action_id` in the block with
/// `block_id`.
pub fn state_value(
  state: ViewState,
  block_id block_id: String,
  action_id action_id: String,
) -> Result(ViewStateValue, Nil) {
  case dict.get(state.values, block_id) {
    Ok(actions) -> dict.get(actions, action_id)
    Error(Nil) -> Error(Nil)
  }
}

/// The value of the element with `action_id` in the block with `block_id`,
/// in a submitted view.
///
/// ```gleam
/// view.input(submission.view, block_id: "due", action_id: "due")
/// |> option.then(view.selected_value)
/// ```
pub fn input(
  view: View,
  block_id block_id: String,
  action_id action_id: String,
) -> Option(ViewStateValue) {
  view.state
  |> option.to_result(Nil)
  |> result.try(state_value(_, block_id:, action_id:))
  |> option.from_result
}

/// The text typed into an input in a submitted view.
///
/// ```gleam
/// view.input_text(submission.view, block_id: "thoughts", action_id: "thoughts")
/// ```
pub fn input_text(
  view: View,
  block_id block_id: String,
  action_id action_id: String,
) -> Option(String) {
  input(view, block_id:, action_id:) |> option.then(text_value)
}

/// The text of a plain-text, email, URL or number input, if it has one.
pub fn text_value(value: ViewStateValue) -> Option(String) {
  case value {
    StatePlainTextInput(value:) -> value
    StateEmailTextInput(value:) -> value
    StateUrlTextInput(value:) -> value
    StateNumberInput(value:) -> value
    _ -> None
  }
}

/// The selected value of a single-select menu, radio buttons, a user,
/// channel or conversation select, or a date, time or datetime picker. An
/// option gives its `value`. A datetime picker gives its Unix timestamp as
/// a string. Use `selected_values` for checkboxes and multi-select menus.
pub fn selected_value(value: ViewStateValue) -> Option(String) {
  case value {
    StateStaticSelect(selected_option:)
    | StateExternalSelect(selected_option:)
    | StateRadioButtons(selected_option:) ->
      option.map(selected_option, fn(option) { option.value })
    StateUsersSelect(selected_user:) -> selected_user
    StateConversationsSelect(selected_conversation:) -> selected_conversation
    StateChannelsSelect(selected_channel:) -> selected_channel
    StateDatepicker(selected_date:) -> selected_date
    StateTimepicker(selected_time:, ..) -> selected_time
    StateDatetimepicker(selected_date_time:) ->
      option.map(selected_date_time, int.to_string)
    _ -> None
  }
}

/// The selected values of checkboxes or a multi-select menu. An option gives
/// its `value`. A user, channel or conversation select gives its IDs. Other
/// elements give an empty list.
pub fn selected_values(value: ViewStateValue) -> List(String) {
  case value {
    StateCheckboxes(selected_options:)
    | StateMultiStaticSelect(selected_options:)
    | StateMultiExternalSelect(selected_options:) ->
      selected_options
      |> option.unwrap([])
      |> list.map(fn(option) { option.value })
    StateMultiUsersSelect(selected_users: ids)
    | StateMultiConversationsSelect(selected_conversations: ids)
    | StateMultiChannelsSelect(selected_channels: ids) -> option.unwrap(ids, [])
    _ -> []
  }
}
