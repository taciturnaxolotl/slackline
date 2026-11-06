//// View examples from the interaction payload docs, plus view builders and
//// state lookups.

import gleam/dict
import gleam/json
import gleam/option.{None, Some}
import known
import slackline/block
import slackline/element
import slackline/element/plain_text_input
import slackline/view.{type View, View}

/// Decodes a view and checks that nothing fell into a catch-all variant.
fn decodes(text: String) -> view.View {
  let assert Ok(decoded) = json.parse(text, view.view_decoder())
  assert known.view(decoded)
  decoded
}

/// The `view` of an example on view-interactions-payload.md.
pub fn view_interactions_payload_0_test() {
  decodes(
    "{\"id\": \"VNHU13V36\", \"type\": \"modal\", \"title\": {\"type\": \"plain_text\", \"text\": \"Modal Title\"}, \"submit\": {\"type\": \"plain_text\", \"text\": \"Submit\"}, \"blocks\": [], \"private_metadata\": \"shhh-its-secret\", \"callback_id\": \"modal-with-inputs\", \"state\": {\"values\": {\"multiline\": {\"mlvalue\": {\"type\": \"plain_text_input\", \"value\": \"This is my example inputted value\"}}, \"target_channel\": {\"target_select\": {\"type\": \"conversations_select\", \"selected_conversation\": \"C123B12DE\"}}}}, \"hash\": \"156663117.cd33ad1f\", \"response_urls\": [{\"block_id\": \"target_channel\", \"action_id\": \"target_select\", \"channel_id\": \"C123B12DE\", \"response_url\": \"https://hooks.slack.com/app/ABC12312/1234567890/A100B100C100d100\"}]}",
  )
}

/// The `view` of an example on view-interactions-payload.md.
pub fn view_interactions_payload_1_test() {
  decodes(
    "{\"type\": \"modal\", \"callback_id\": \"modal-with-inputs\", \"title\": {\"type\": \"plain_text\", \"text\": \"Modal with inputs\"}, \"blocks\": [{\"type\": \"input\", \"block_id\": \"multiline\", \"label\": {\"type\": \"plain_text\", \"text\": \"Enter your value\"}, \"element\": {\"type\": \"plain_text_input\", \"multiline\": true, \"action_id\": \"mlvalue\"}}, {\"block_id\": \"target_channel\", \"type\": \"input\", \"optional\": true, \"label\": {\"type\": \"plain_text\", \"text\": \"Select a channel to post the result on\"}, \"element\": {\"action_id\": \"target_select\", \"type\": \"conversations_select\", \"response_url_enabled\": true}}], \"submit\": {\"type\": \"plain_text\", \"text\": \"Submit\"}}",
  )
}

/// The `view` of an example on view-interactions-payload.md.
pub fn view_interactions_payload_2_test() {
  decodes(
    "{\"id\": \"VXXXXXX\", \"type\": \"modal\", \"title\": {\"type\": \"plain_text\", \"text\": \"Modal Title\"}, \"blocks\": []}",
  )
}

/// The `view` of an example on block_actions-payload.md.
pub fn block_actions_payload_1_test() {
  decodes(
    "{\"id\": \"V0PKB1ZFV\", \"team_id\": \"T9TK3CUKW\", \"type\": \"home\", \"blocks\": [{\"type\": \"section\", \"block_id\": \"8ZG\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"A stack of blocks for the sample Block Kit Home tab.\", \"verbatim\": false}}, {\"type\": \"actions\", \"block_id\": \"7fhg\", \"elements\": [{\"type\": \"button\", \"action_id\": \"XRX\", \"text\": {\"type\": \"plain_text\", \"text\": \"Action A\", \"emoji\": true}}, {\"type\": \"button\", \"action_id\": \"GFBew\", \"text\": {\"type\": \"plain_text\", \"text\": \"Action B\", \"emoji\": true}}]}, {\"type\": \"section\", \"block_id\": \"6evU\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"And now it's slightly more complex.\", \"verbatim\": false}}], \"private_metadata\": \"\", \"callback_id\": \"\", \"state\": {\"values\": {}}, \"hash\": \"1571318366.2468e46f\", \"clear_on_close\": false, \"notify_on_close\": false, \"close\": null, \"submit\": null, \"previous_view_id\": null, \"root_view_id\": \"V0PKB1ZFV\", \"app_id\": \"AABA1ABCD\", \"external_id\": \"\", \"app_installed_team_id\": \"T9TK3CUKW\", \"bot_id\": \"B0B00B00\"}",
  )
}

pub fn submission_state_test() {
  let decoded =
    decodes(
      "{\"type\":\"modal\",\"blocks\":[],\"state\":{\"values\":{\"multiline\":{\"mlvalue\":{\"type\":\"plain_text_input\",\"value\":\"hi\"}},\"target_channel\":{\"target_select\":{\"type\":\"conversations_select\",\"selected_conversation\":\"C123B12DE\"}},\"when\":{\"date\":{\"type\":\"datepicker\",\"selected_date\":\"2024-01-02\"},\"at\":{\"type\":\"datetimepicker\",\"selected_date_time\":1628633820},\"time\":{\"type\":\"timepicker\",\"selected_time\":\"10:30\",\"timezone\":\"America/Chicago\"}},\"pick\":{\"one\":{\"type\":\"static_select\",\"selected_option\":null},\"many\":{\"type\":\"multi_users_select\",\"selected_users\":[\"U1\",\"U2\"]},\"boxes\":{\"type\":\"checkboxes\",\"selected_options\":[{\"text\":{\"type\":\"mrkdwn\",\"text\":\"*a*\"},\"value\":\"a\"}]}},\"rich\":{\"rt\":{\"type\":\"rich_text_input\",\"rich_text_value\":{\"type\":\"rich_text\",\"elements\":[{\"type\":\"rich_text_section\",\"elements\":[{\"type\":\"text\",\"text\":\"x\"}]}]}}},\"up\":{\"files\":{\"type\":\"file_input\",\"files\":[{\"id\":\"F1\"}]}},\"num\":{\"n\":{\"type\":\"number_input\",\"value\":\"4.5\"}}}}}",
    )
  let assert Some(state) = decoded.state
  let assert Ok(value) =
    view.state_value(state, block_id: "multiline", action_id: "mlvalue")
  let assert Some("hi") = view.text_value(value)
  let assert Ok(view.StateConversationsSelect(selected_conversation: Some(
    "C123B12DE",
  ))) =
    view.state_value(
      state,
      block_id: "target_channel",
      action_id: "target_select",
    )
  let assert Ok(view.StateStaticSelect(selected_option: None)) =
    view.state_value(state, block_id: "pick", action_id: "one")
  let assert Error(Nil) =
    view.state_value(state, block_id: "nope", action_id: "x")
  let assert 7 = dict.size(state.values)
}

pub fn modal_builder_round_trip_test() {
  let modal =
    view.modal(
      "Feedback",
      [
        block.input(
          "Thoughts",
          element.plain_text_input("thoughts", [
            plain_text_input.multiline(True),
          ]),
          [],
        ),
      ],
      [view.callback_id("feedback"), view.submit("Send")],
    )
  let assert True =
    modal
    == View(
      ..modal,
      submit: Some(block.plain_text("Send")),
      callback_id: Some("feedback"),
      title: Some(block.plain_text("Feedback")),
    )
  let assert Ok(decoded) =
    json.parse(json.to_string(view.view_to_json(modal)), view.view_decoder())
  let assert True = decoded == modal
}

pub fn home_builder_encodes_type_test() {
  let assert "{\"type\":\"home\",\"blocks\":[{\"type\":\"divider\"}],\"callback_id\":\"home\"}" =
    json.to_string(
      view.view_to_json(
        view.home([block.divider([])], [view.callback_id("home")]),
      ),
    )
}

/// A submitted view with one value of every kind that the state helpers read.
fn submitted() -> View {
  decodes(
    "{\"type\":\"modal\",\"blocks\":[],\"state\":{\"values\":{\"b\":{\"text\":{\"type\":\"plain_text_input\",\"value\":\"hi\"},\"one\":{\"type\":\"static_select\",\"selected_option\":{\"text\":{\"type\":\"plain_text\",\"text\":\"One\"},\"value\":\"1\"}},\"none\":{\"type\":\"static_select\",\"selected_option\":null},\"user\":{\"type\":\"users_select\",\"selected_user\":\"U1\"},\"date\":{\"type\":\"datepicker\",\"selected_date\":\"2024-01-02\"},\"time\":{\"type\":\"timepicker\",\"selected_time\":\"10:30\",\"timezone\":\"America/Chicago\"},\"at\":{\"type\":\"datetimepicker\",\"selected_date_time\":1628633820},\"boxes\":{\"type\":\"checkboxes\",\"selected_options\":[{\"text\":{\"type\":\"mrkdwn\",\"text\":\"*a*\"},\"value\":\"a\"},{\"text\":{\"type\":\"mrkdwn\",\"text\":\"*b*\"},\"value\":\"b\"}]},\"statics\":{\"type\":\"multi_static_select\",\"selected_options\":[{\"text\":{\"type\":\"plain_text\",\"text\":\"X\"},\"value\":\"x\"}]},\"externals\":{\"type\":\"multi_external_select\",\"selected_options\":[]},\"users\":{\"type\":\"multi_users_select\",\"selected_users\":[\"U1\",\"U2\"]},\"convos\":{\"type\":\"multi_conversations_select\",\"selected_conversations\":[\"C1\"]},\"channels\":{\"type\":\"multi_channels_select\",\"selected_channels\":[\"C2\",\"C3\"]},\"unset\":{\"type\":\"multi_users_select\"}}}}}",
  )
}

fn value(name: String) -> view.ViewStateValue {
  let assert Some(value) =
    view.input(submitted(), block_id: "b", action_id: name)
  value
}

pub fn input_test() {
  let assert Some(view.StatePlainTextInput(value: Some("hi"))) =
    view.input(submitted(), block_id: "b", action_id: "text")
  let assert None = view.input(submitted(), block_id: "b", action_id: "nope")
  let assert None = view.input(submitted(), block_id: "nope", action_id: "text")
  let assert None =
    view.input(view.home([], []), block_id: "b", action_id: "text")
  let assert Some("hi") =
    view.input_text(submitted(), block_id: "b", action_id: "text")
}

pub fn selected_value_test() {
  let assert Some("1") = view.selected_value(value("one"))
  let assert None = view.selected_value(value("none"))
  let assert Some("U1") = view.selected_value(value("user"))
  let assert Some("2024-01-02") = view.selected_value(value("date"))
  let assert Some("10:30") = view.selected_value(value("time"))
  let assert Some("1628633820") = view.selected_value(value("at"))
  let assert None = view.selected_value(value("text"))
  let assert None = view.selected_value(value("boxes"))
}

pub fn selected_values_test() {
  let assert ["a", "b"] = view.selected_values(value("boxes"))
  let assert ["x"] = view.selected_values(value("statics"))
  let assert [] = view.selected_values(value("externals"))
  let assert ["U1", "U2"] = view.selected_values(value("users"))
  let assert ["C1"] = view.selected_values(value("convos"))
  let assert ["C2", "C3"] = view.selected_values(value("channels"))
  let assert [] = view.selected_values(value("unset"))
  let assert [] = view.selected_values(value("one"))
}
