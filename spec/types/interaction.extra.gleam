import gleam/dict
import gleam/dynamic/decode
import gleam/json

/// A `view_submission` response that shows `errors` on the input blocks,
/// given as `#(block_id, message)` pairs.
pub fn errors(errors: List(#(String, String))) -> ViewSubmissionResponse {
  ErrorsResponse(errors: dict.from_list(errors))
}

/// A `view_submission` response that replaces the submitted view.
pub fn update(view: view.View) -> ViewSubmissionResponse {
  UpdateResponse(view:)
}

/// A `view_submission` response that pushes a new view onto the stack.
pub fn push(view: view.View) -> ViewSubmissionResponse {
  PushResponse(view:)
}

/// A `view_submission` response that closes every view in the stack.
pub fn clear() -> ViewSubmissionResponse {
  ClearResponse
}

/// A `block_suggestion` response listing options.
pub fn options(options: List(block.SelectOption)) -> OptionsResponse {
  OptionsResponse(options: Some(options), option_groups: None)
}

/// A `block_suggestion` response listing option groups.
pub fn option_groups(groups: List(block.OptionGroup)) -> OptionsResponse {
  OptionsResponse(options: None, option_groups: Some(groups))
}

/// An empty `response_url` message. Set fields with record update syntax.
pub fn response_message() -> ResponseMessage {
  ResponseMessage(
    text: None,
    blocks: None,
    attachments: None,
    response_type: None,
    replace_original: None,
    delete_original: None,
    thread_ts: None,
    mrkdwn: None,
  )
}


/// A text message only the user who interacted can see.
pub fn ephemeral(text: String) -> ResponseMessage {
  ResponseMessage(
    ..response_message(),
    text: Some(text),
    response_type: Some(Ephemeral),
  )
}

/// A text message everyone in the conversation can see.
pub fn in_channel(text: String) -> ResponseMessage {
  ResponseMessage(
    ..response_message(),
    text: Some(text),
    response_type: Some(InChannel),
  )
}

/// A `response_url` message that deletes the source message.
pub fn delete_original() -> ResponseMessage {
  ResponseMessage(..response_message(), delete_original: Some(True))
}

/// Parses the json in the `payload` form field of an interactivity request.
pub fn parse(payload: String) -> Result(Interaction, json.DecodeError) {
  json.parse(payload, interaction_decoder())
}

/// Decodes the `payload` field of a Socket Mode `interactive` envelope.
pub fn envelope_payload_decoder() -> decode.Decoder(Interaction) {
  decode.at(["payload"], interaction_decoder())
}

/// The `action_id` of a block action. For an action type that this version
/// of slackline does not know, it reads `action_id` from the raw json.
pub fn action_id(action: BlockAction) -> Option(String) {
  case action {
    ButtonAction(action_id:, ..)
    | WorkflowButtonAction(action_id:, ..)
    | IconButtonAction(action_id:, ..)
    | FeedbackButtonsAction(action_id:, ..)
    | OverflowAction(action_id:, ..)
    | CheckboxesAction(action_id:, ..)
    | RadioButtonsAction(action_id:, ..)
    | StaticSelectAction(action_id:, ..)
    | ExternalSelectAction(action_id:, ..)
    | UsersSelectAction(action_id:, ..)
    | ConversationsSelectAction(action_id:, ..)
    | ChannelsSelectAction(action_id:, ..)
    | MultiStaticSelectAction(action_id:, ..)
    | MultiExternalSelectAction(action_id:, ..)
    | MultiUsersSelectAction(action_id:, ..)
    | MultiConversationsSelectAction(action_id:, ..)
    | MultiChannelsSelectAction(action_id:, ..)
    | DatepickerAction(action_id:, ..)
    | TimepickerAction(action_id:, ..)
    | DatetimepickerAction(action_id:, ..)
    | PlainTextInputAction(action_id:, ..)
    | EmailTextInputAction(action_id:, ..)
    | UrlTextInputAction(action_id:, ..)
    | NumberInputAction(action_id:, ..)
    | RichTextInputAction(action_id:, ..) -> Some(action_id)
    UnknownBlockAction(raw:, ..) ->
      case value.string_field(raw, "action_id") {
        Ok(id) -> Some(id)
        Error(Nil) -> None
      }
  }
}
