//// Attachment examples from the legacy messaging docs, plus a round trip
//// with blocks inside an attachment.

import gleam/dynamic/decode
import gleam/json
import gleam/option.{None, Some}
import known
import slackline/attachment.{type Attachment, Attachment}
import slackline/block

/// Decodes attachments and checks that nothing fell into a catch-all
/// variant.
fn decodes(text: String) -> List(Attachment) {
  let assert Ok(decoded) =
    json.parse(text, decode.list(attachment.attachment_decoder()))
  assert known.attachments(decoded)
  decoded
}

pub fn legacy_adding_menus_to_messages_0_0_test() {
  decodes(
    "[{\"text\": \"Choose a game to play\", \"fallback\": \"If you could read this message, you'd be choosing something fun to do right now.\", \"color\": \"#3AA3E3\", \"attachment_type\": \"default\", \"callback_id\": \"game_selection\", \"actions\": [{\"name\": \"games_list\", \"text\": \"Pick a game...\", \"type\": \"select\", \"options\": [{\"text\": \"Hearts\", \"value\": \"hearts\"}, {\"text\": \"Bridge\", \"value\": \"bridge\"}, {\"text\": \"Checkers\", \"value\": \"checkers\"}, {\"text\": \"Chess\", \"value\": \"chess\"}, {\"text\": \"Poker\", \"value\": \"poker\"}, {\"text\": \"Falken's Maze\", \"value\": \"maze\"}, {\"text\": \"Global Thermonuclear War\", \"value\": \"war\"}]}]}]",
  )
}

pub fn legacy_adding_menus_to_messages_1_0_test() {
  decodes(
    "[{\"callback_id\": \"game_selection\", \"fallback\": \"Upgrade your Slack client to use messages like these.\", \"id\": 1, \"color\": \"3AA3E3\", \"actions\": [{\"name\": \"games_list\", \"text\": \"Pick a game...\", \"type\": \"select\", \"options\": [{\"text\": \"Chess\", \"value\": \"chess\"}, {\"text\": \"Falken's Maze\", \"value\": \"maze\"}, {\"text\": \"Global Thermonuclear War\", \"value\": \"war\"}]}]}]",
  )
}

pub fn legacy_adding_menus_to_messages_2_0_test() {
  decodes(
    "[{\"text\": \"Who wins the lifetime supply of chocolate?\", \"fallback\": \"You could be telling the computer exactly what it can do with a lifetime supply of chocolate.\", \"color\": \"#3AA3E3\", \"attachment_type\": \"default\", \"callback_id\": \"select_simple_1234\", \"actions\": [{\"name\": \"winners_list\", \"text\": \"Who should win?\", \"type\": \"select\", \"data_source\": \"users\"}]}]",
  )
}

pub fn legacy_adding_menus_to_messages_3_0_test() {
  decodes(
    "[{\"fallback\": \"Upgrade your Slack client to use messages like these.\", \"color\": \"#3AA3E3\", \"attachment_type\": \"default\", \"callback_id\": \"select_simple_1234\", \"actions\": [{\"name\": \"channels_list\", \"text\": \"Which channel changed your life this week?\", \"type\": \"select\", \"data_source\": \"channels\"}]}]",
  )
}

pub fn legacy_adding_menus_to_messages_4_0_test() {
  decodes(
    "[{\"fallback\": \"Upgrade your Slack client to use messages like these.\", \"color\": \"#3AA3E3\", \"attachment_type\": \"default\", \"callback_id\": \"conversations_123\", \"actions\": [{\"name\": \"conversations_list\", \"text\": \"Who did you talk to last?\", \"type\": \"select\", \"data_source\": \"conversations\"}]}]",
  )
}

pub fn legacy_adding_menus_to_messages_5_0_test() {
  decodes(
    "[{\"callback_id\": \"select_simple_1234\", \"fallback\": \"Upgrade your Slack client to use messages like these.\", \"id\": 1, \"color\": \"3AA3E3\", \"actions\": [{\"id\": \"1\", \"name\": \"channels_list\", \"text\": \"Which channel changed your life this week?\", \"type\": \"select\", \"data_source\": \"channels\"}]}]",
  )
}

pub fn legacy_adding_menus_to_messages_6_0_test() {
  decodes(
    "[{\"fallback\": \"Upgrade your Slack client to use messages like these.\", \"color\": \"3AA3E3\", \"attachment_type\": \"default\", \"callback_id\": \"select_remote_1234\", \"actions\": [{\"name\": \"bugs_list\", \"text\": \"Which random bug do you want to resolve?\", \"type\": \"select\", \"data_source\": \"external\", \"min_query_length\": 3}]}]",
  )
}

pub fn legacy_adding_menus_to_messages_10_0_test() {
  decodes(
    "[{\"callback_id\": \"select_simple_1234\", \"actions\": [{\"name\": \"games_list\", \"text\": \"Pick a game...\", \"type\": \"select\", \"options\": [{\"text\": \"Chess\", \"value\": \"chess\"}, {\"text\": \"Falken's Maze\", \"value\": \"maze\"}, {\"text\": \"Thermonuclear War\", \"value\": \"war\"}], \"selected_options\": [{\"text\": \"Falken's Maze\", \"value\": \"maze\"}]}]}]",
  )
}

pub fn legacy_interactive_message_field_guide_3_0_test() {
  decodes(
    "[{\"callback_id\": \"select_simple_1234\", \"fallback\": \"Upgrade your Slack client to use messages like these.\", \"id\": 1, \"color\": \"3AA3E3\", \"actions\": [{\"id\": \"1\", \"name\": \"channels_list\", \"text\": \"Which channel changed your life this week?\", \"type\": \"select\", \"data_source\": \"channels\"}]}]",
  )
}

pub fn legacy_making_messages_interactive_2_0_test() {
  decodes(
    "[{\"callback_id\": \"pick_channel_for_fun\", \"text\": \"Choose a channel\", \"id\": 1, \"color\": \"2b72cb\", \"actions\": [{\"id\": \"1\", \"name\": \"channel_list\", \"text\": \"Public channels\", \"type\": \"select\", \"data_source\": \"channels\"}], \"fallback\": \"Choose a channel\"}]",
  )
}

pub fn legacy_message_buttons_0_0_test() {
  decodes(
    "[{\"text\": \"Choose a game to play\", \"fallback\": \"You are unable to choose a game\", \"callback_id\": \"wopr_game\", \"color\": \"#3AA3E3\", \"attachment_type\": \"default\", \"actions\": [{\"name\": \"game\", \"text\": \"Chess\", \"type\": \"button\", \"value\": \"chess\"}, {\"name\": \"game\", \"text\": \"Falken's Maze\", \"type\": \"button\", \"value\": \"maze\"}, {\"name\": \"game\", \"text\": \"Thermonuclear War\", \"style\": \"danger\", \"type\": \"button\", \"value\": \"war\", \"confirm\": {\"title\": \"Are you sure?\", \"text\": \"Wouldn't you prefer a good game of chess?\", \"ok_text\": \"Yes\", \"dismiss_text\": \"No\"}}]}]",
  )
}

pub fn legacy_message_buttons_1_0_test() {
  decodes(
    "[{\"title\": \"The Further Adventures of Slackbot\", \"fields\": [{\"title\": \"Volume\", \"value\": \"1\", \"short\": true}, {\"title\": \"Issue\", \"value\": \"3\", \"short\": true}], \"author_name\": \"Stanford S. Strickland\", \"author_icon\": \"http://a.slack-edge.com/7f18/img/api/homepage_custom_integrations-2x.png\", \"image_url\": \"http://i.imgur.com/OJkaVOI.jpg?1\"}, {\"title\": \"Synopsis\", \"text\": \"After @episod pushed exciting changes to a devious new branch back in Issue 1, Slackbot notifies @don about an unexpected deploy...\"}, {\"fallback\": \"Would you recommend it to customers?\", \"title\": \"Would you recommend it to customers?\", \"callback_id\": \"comic_1234_xyz\", \"color\": \"#3AA3E3\", \"attachment_type\": \"default\", \"actions\": [{\"name\": \"recommend\", \"text\": \"Recommend\", \"type\": \"button\", \"value\": \"recommend\"}, {\"name\": \"no\", \"text\": \"No\", \"type\": \"button\", \"value\": \"bad\"}]}]",
  )
}

pub fn legacy_message_buttons_2_0_test() {
  decodes(
    "[{\"title\": \"The Further Adventures of Slackbot\", \"fields\": [{\"title\": \"Volume\", \"value\": \"1\", \"short\": true}, {\"title\": \"Issue\", \"value\": \"3\", \"short\": true}], \"author_name\": \"Stanford S. Strickland\", \"author_icon\": \"https://api.slack.com/img/api/homepage_custom_integrations-2x.png\", \"image_url\": \"http://i.imgur.com/OJkaVOI.jpg?1\"}, {\"title\": \"Synopsis\", \"text\": \"After @episod pushed exciting changes to a devious new branch back in Issue 1, Slackbot notifies @don about an unexpected deploy...\"}, {\"fallback\": \"Would you recommend it to customers?\", \"title\": \"Would you recommend it to customers?\", \"callback_id\": \"comic_1234_xyz\", \"color\": \"#3AA3E3\", \"attachment_type\": \"default\", \"actions\": [{\"name\": \"recommend\", \"text\": \"Recommend\", \"type\": \"button\", \"value\": \"recommend\"}, {\"name\": \"no\", \"text\": \"No\", \"type\": \"button\", \"value\": \"bad\"}]}]",
  )
}

pub fn legacy_secondary_message_attachments_0_0_test() {
  decodes(
    "[{\"mrkdwn_in\": [\"text\"], \"color\": \"#36a64f\", \"pretext\": \"Optional pre-text that appears above the attachment block\", \"author_name\": \"author_name\", \"author_link\": \"http://flickr.com/bobby/\", \"author_icon\": \"https://placeimg.com/16/16/people\", \"title\": \"title\", \"title_link\": \"https://docs.slack.dev/\", \"text\": \"Optional `text` that appears within the attachment\", \"fields\": [{\"title\": \"A field's title\", \"value\": \"This field's value\", \"short\": false}, {\"title\": \"A short field's title\", \"value\": \"A short field's value\", \"short\": true}, {\"title\": \"A second short field's title\", \"value\": \"A second short field's value\", \"short\": true}], \"thumb_url\": \"http://placekitten.com/g/200/200\", \"footer\": \"footer\", \"footer_icon\": \"https://platform.slack-edge.com/img/default_application_icon.png\", \"ts\": 123456789}]",
  )
}

pub fn string_ts_test() {
  let assert [
    Attachment(ts: Some(attachment.StringTs("1481579582.000003")), ..),
  ] = decodes("[{\"ts\":\"1481579582.000003\",\"text\":\"hi\"}]")
}

pub fn attachment_with_blocks_round_trip_test() {
  let value =
    Attachment(
      blocks: Some([block.section(block.mrkdwn("*inside*"), [])]),
      color: Some("#36a64f"),
      fallback: Some("inside"),
      callback_id: None,
      actions: None,
      attachment_type: None,
      author_name: None,
      author_link: None,
      author_icon: None,
      title: None,
      title_link: None,
      pretext: None,
      text: None,
      fields: Some([
        attachment.AttachmentField(
          title: Some("Priority"),
          value: Some("High"),
          short: Some(True),
        ),
      ]),
      image_url: None,
      thumb_url: None,
      footer: None,
      footer_icon: None,
      ts: Some(attachment.IntTs(123_456_789)),
      mrkdwn_in: Some(["text"]),
      id: None,
      thumb_width: None,
      thumb_height: None,
      service_name: None,
    )
  let assert Ok(decoded) =
    json.parse(
      json.to_string(attachment.attachment_to_json(value)),
      attachment.attachment_decoder(),
    )
  let assert True = decoded == value
}
