import gleam/dict
import gleam/json
import gleam/option.{None, Some}
import known
import slackline/interaction
import slackline/view

pub fn block_actions_message_test() {
  let assert Ok(interaction.BlockActions(interaction.BlockActionsPayload(
    actions: Some([interaction.ButtonAction(action_id: "WaXA", ..)]),
    ..,
  ))) =
    json.parse(
      "{\"type\": \"block_actions\", \"team\": {\"id\": \"T9TK3CUKW\", \"domain\": \"example\"}, \"user\": {\"id\": \"UA8RXUSPL\", \"username\": \"jtorrance\", \"team_id\": \"T9TK3CUKW\"}, \"api_app_id\": \"AABA1ABCD\", \"token\": \"9s8d9as89d8as9d8as989\", \"container\": {\"type\": \"message_attachment\", \"message_ts\": \"1548261231.000200\", \"attachment_id\": 1, \"channel_id\": \"CBR2V3XEX\", \"is_ephemeral\": false, \"is_app_unfurl\": false}, \"trigger_id\": \"12321423423.333649436676.d8c1bb837935619ccad0f624c448ffb3\", \"channel\": {\"id\": \"CBR2V3XEX\", \"name\": \"review-updates\"}, \"message\": {\"bot_id\": \"BAH5CA16Z\", \"type\": \"message\", \"text\": \"This content can't be displayed.\", \"user\": \"UAJ2RU415\", \"ts\": \"1548261231.000200\"}, \"response_url\": \"https://hooks.slack.com/actions/AABA1ABCD/1232321423432/D09sSasdasdAS9091209\", \"actions\": [{\"action_id\": \"WaXA\", \"block_id\": \"=qXel\", \"text\": {\"type\": \"plain_text\", \"text\": \"View\", \"emoji\": true}, \"value\": \"click_me_123\", \"type\": \"button\", \"action_ts\": \"1548426417.840180\"}]}",
      interaction.interaction_decoder(),
    )
}

pub fn block_actions_home_tab_test() {
  let assert Ok(interaction.BlockActions(interaction.BlockActionsPayload(
    actions: Some([interaction.ButtonAction(action_id: "XRX", ..)]),
    view: Some(view.View(view_type: view.Home, ..)),
    ..,
  ))) =
    json.parse(
      "{\"type\": \"block_actions\", \"team\": {\"id\": \"T9TK3CUKW\", \"domain\": \"example\"}, \"user\": {\"id\": \"UA8RXUSPL\", \"username\": \"jtorrance\", \"name\": \"jtorrance\", \"team_id\": \"T9TK3CUKW\"}, \"api_app_id\": \"AABA1ABCD\", \"token\": \"9s8d9as89d8as9d8as989\", \"container\": {\"type\": \"view\", \"view_id\": \"V0PKB1ZFV\"}, \"trigger_id\": \"24571818370.22717085937.b9c7ca14b87be6b44ff5864edba8306f\", \"view\": {\"id\": \"V0PKB1ZFV\", \"team_id\": \"T9TK3CUKW\", \"type\": \"home\", \"blocks\": [{\"type\": \"section\", \"block_id\": \"8ZG\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"A stack of blocks for the sample Block Kit Home tab.\", \"verbatim\": false}}, {\"type\": \"actions\", \"block_id\": \"7fhg\", \"elements\": [{\"type\": \"button\", \"action_id\": \"XRX\", \"text\": {\"type\": \"plain_text\", \"text\": \"Action A\", \"emoji\": true}}, {\"type\": \"button\", \"action_id\": \"GFBew\", \"text\": {\"type\": \"plain_text\", \"text\": \"Action B\", \"emoji\": true}}]}, {\"type\": \"section\", \"block_id\": \"6evU\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"And now it's slightly more complex.\", \"verbatim\": false}}], \"private_metadata\": \"\", \"callback_id\": \"\", \"state\": {\"values\": {}}, \"hash\": \"1571318366.2468e46f\", \"clear_on_close\": false, \"notify_on_close\": false, \"close\": null, \"submit\": null, \"previous_view_id\": null, \"root_view_id\": \"V0PKB1ZFV\", \"app_id\": \"AABA1ABCD\", \"external_id\": \"\", \"app_installed_team_id\": \"T9TK3CUKW\", \"bot_id\": \"B0B00B00\"}, \"actions\": [{\"type\": \"button\", \"block_id\": \"7fhg\", \"action_id\": \"XRX\", \"text\": {\"type\": \"plain_text\", \"text\": \"Action A\", \"emoji\": true}, \"action_ts\": \"1571318425.267782\"}]}",
      interaction.interaction_decoder(),
    )
}

pub fn block_suggestion_modal_test() {
  let assert Ok(interaction.BlockSuggestion(interaction.BlockSuggestionPayload(
    action_id: "ext_select_input",
    value: "tech",
    ..,
  ))) =
    json.parse(
      "{\"type\": \"block_suggestion\", \"team\": {\"id\": \"ABC123DEF45\", \"domain\": \"workspace\"}, \"enterprise\": null, \"user\": {\"id\": \"EXAMPLE1234\", \"name\": \"sallyslack\", \"team_id\": \"ABC123DEF45\"}, \"view\": {\"id\": \"DEFGHIJ89101\", \"team_id\": \"ABC123DEF45\", \"app_id\": \"APPID6789101\", \"app_installed_team_id\": \"ABC123DEF45\", \"bot_id\": \"BOTSRCOOL12\", \"title\": {\"type\": \"plain_text\", \"text\": \"Deny Request\", \"emoji\": true}, \"type\": \"modal\", \"blocks\": [], \"close\": null, \"submit\": {\"type\": \"plain_text\", \"text\": \"Next\", \"emoji\": true}, \"state\": {\"values\": {}}, \"hash\": \"1695235327.610lSjjQ\", \"private_metadata\": \"{\\\"messageTS\\\":\\\"1695235212.424669\\\"}\", \"callback_id\": \"deny_modal_main\", \"root_view_id\": \"DEFGHIJ89101\", \"previous_view_id\": null, \"clear_on_close\": false, \"notify_on_close\": true, \"external_id\": \"\"}, \"container\": {\"type\": \"view\", \"view_id\": \"DEFGHIJ89101\"}, \"api_app_id\": \"APPID6789101\", \"action_id\": \"ext_select_input\", \"block_id\": \"ext_select_block\", \"value\": \"tech\", \"function_data\": {\"execution_id\": \"EXECUTEF9101\", \"function\": {\"callback_id\": \"review_approval\"}, \"inputs\": {\"details\": \"test\", \"subject\": \"test\", \"requester_id\": \"EXAMPLE1234\", \"approval_channel_id\": \"APPROVE1234\"}}, \"bot_access_token\": \"xwfp-2335208212870-2354592155553-5925491402867-c2a66a8fb377b19e0d8f6c8d24af530d\"}",
      interaction.interaction_decoder(),
    )
}

pub fn block_suggestion_enterprise_test() {
  let assert Ok(interaction.BlockSuggestion(interaction.BlockSuggestionPayload(
    action_id: "location_select-action",
    value: "test",
    ..,
  ))) =
    json.parse(
      "{\"type\": \"block_suggestion\", \"user\": {\"id\": \"ABCDE6789\", \"username\": \"harry-potter\", \"name\": \"harry-potter\", \"team_id\": \"ENT4567\"}, \"container\": {\"type\": \"message\", \"message_ts\": \"1628851405.000300\", \"channel_id\": \"CHAN56789\", \"is_ephemeral\": false}, \"api_app_id\": \"APP876543\", \"token\": \"XAg1RqiO8jaSczkIQpxq7Z4o\", \"action_id\": \"location_select-action\", \"block_id\": \"bK6\", \"value\": \"test\", \"team\": {\"id\": \"ENT4567\", \"domain\": \"my-workspace\", \"enterprise_id\": \"ENT123789\", \"enterprise_name\": \"my-enterprise\"}, \"enterprise\": {\"id\": \"ENT123789\", \"name\": \"my-enterprise\"}, \"is_enterprise_install\": false, \"channel\": {\"id\": \"CHAN56789\", \"name\": \"channel-team-01\"}, \"message\": {\"bot_id\": \"B0T123456\", \"type\": \"message\", \"text\": \"Text+here+for+notifications\", \"user\": \"ABCDE6789\", \"ts\": \"1628851405.000300\", \"blocks\": [{\"type\": \"input\", \"block_id\": \"bK6\", \"label\": {\"type\": \"plain_text\", \"text\": \"Select+Location\", \"emoji\": true}, \"optional\": false, \"dispatch_action\": false, \"element\": {\"type\": \"external_select\", \"action_id\": \"location_select-action\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Select+location\", \"emoji\": true}}}], \"team\": \"ENT4567\"}}",
      interaction.interaction_decoder(),
    )
}

pub fn global_shortcut_test() {
  let assert Ok(interaction.GlobalShortcut(interaction.GlobalShortcutPayload(
    callback_id: "shortcut_create_task",
    ..,
  ))) =
    json.parse(
      "{\"type\": \"shortcut\", \"token\": \"XXXXXXXXXXXXX\", \"action_ts\": \"1581106241.371594\", \"team\": {\"id\": \"TXXXXXXXX\", \"domain\": \"shortcuts-test\"}, \"user\": {\"id\": \"UXXXXXXXXX\", \"username\": \"aman\", \"team_id\": \"TXXXXXXXX\"}, \"callback_id\": \"shortcut_create_task\", \"trigger_id\": \"944799105734.773906753841.38b5894552bdd4a780554ee59d1f3638\"}",
      interaction.interaction_decoder(),
    )
}

pub fn message_shortcut_test() {
  let assert Ok(interaction.MessageShortcut(interaction.MessageShortcutPayload(
    callback_id: "chirp_message",
    message: Some(_),
    ..,
  ))) =
    json.parse(
      "{\"token\": \"Nj2rfC2hU8mAfgaJLemZgO7H\", \"callback_id\": \"chirp_message\", \"type\": \"message_action\", \"trigger_id\": \"13345224609.8534564800.6f8ab1f53e13d0cd15f96106292d5536\", \"response_url\": \"https://hooks.slack.com/app-actions/T0MJR11A4/21974584944/yk1S9ndf35Q1flupVG5JbpM6\", \"team\": {\"id\": \"T0MJRM1A7\", \"domain\": \"pandamonium\"}, \"channel\": {\"id\": \"D0LFFBKLZ\", \"name\": \"cats\"}, \"user\": {\"id\": \"U0D15K92L\", \"name\": \"dr_maomao\"}, \"message\": {\"type\": \"message\", \"user\": \"U0MJRG1AL\", \"ts\": \"1516229207.000133\", \"text\": \"World's smallest big cat! <https://youtube.com/watch?v=W86cTIoMv2U>\"}}",
      interaction.interaction_decoder(),
    )
}

pub fn view_submission_test() {
  let assert Ok(interaction.ViewSubmission(interaction.ViewSubmissionPayload(
    view: submitted,
    ..,
  ))) =
    json.parse(
      "{\"type\": \"view_submission\", \"team\": {\"id\": \"T1234567\", \"domain\": \"example-domain\"}, \"user\": {\"id\": \"U1234567\", \"username\": \"example-user\"}, \"view\": {\"id\": \"VNHU13V36\", \"type\": \"modal\", \"title\": {\"type\": \"plain_text\", \"text\": \"Modal Title\"}, \"submit\": {\"type\": \"plain_text\", \"text\": \"Submit\"}, \"blocks\": [], \"private_metadata\": \"shhh-its-secret\", \"callback_id\": \"modal-with-inputs\", \"state\": {\"values\": {\"multiline\": {\"mlvalue\": {\"type\": \"plain_text_input\", \"value\": \"This is my example inputted value\"}}, \"target_channel\": {\"target_select\": {\"type\": \"conversations_select\", \"selected_conversation\": \"C123B12DE\"}}}}, \"hash\": \"156663117.cd33ad1f\", \"response_urls\": [{\"block_id\": \"target_channel\", \"action_id\": \"target_select\", \"channel_id\": \"C123B12DE\", \"response_url\": \"https://hooks.slack.com/app/ABC12312/1234567890/A100B100C100d100\"}]}}",
      interaction.interaction_decoder(),
    )
  assert known.view(submitted)
}

pub fn view_closed_test() {
  let assert Ok(interaction.ViewClosed(interaction.ViewClosedPayload(
    view: view.View(view_type: view.Modal, ..),
    ..,
  ))) =
    json.parse(
      "{\"type\": \"view_closed\", \"team\": {\"id\": \"TXXXXXX\", \"domain\": \"coverbands\"}, \"user\": {\"id\": \"UXXXXXX\", \"name\": \"dreamweaver\"}, \"view\": {\"id\": \"VXXXXXX\", \"type\": \"modal\", \"title\": {\"type\": \"plain_text\", \"text\": \"Modal Title\"}, \"blocks\": []}, \"api_app_id\": \"AXXXXXX\", \"is_cleared\": false}",
      interaction.interaction_decoder(),
    )
}

pub fn interactive_message_0_test() {
  let assert Ok(interaction.InteractiveMessage(interaction.InteractiveMessagePayload(
    callback_id: "game_selection",
    actions: Some([interaction.LegacyAction(name: Some("games_list"), ..)]),
    ..,
  ))) =
    json.parse(
      "{\"type\": \"interactive_message\", \"actions\": [{\"name\": \"games_list\", \"selected_options\": [{\"value\": \"maze\"}]}], \"callback_id\": \"game_selection\", \"team\": {\"id\": \"T012AB0A1\", \"domain\": \"pocket-calculator\"}, \"channel\": {\"id\": \"C012AB3CD\", \"name\": \"general\"}, \"user\": {\"id\": \"U012A1BCD\", \"name\": \"muzik\"}, \"action_ts\": \"1481579588.685999\", \"message_ts\": \"1481579582.000003\", \"attachment_id\": \"1\", \"token\": \"verification_token_string\", \"original_message\": {\"text\": \"Pick a game...\", \"bot_id\": \"B08BCU62D\", \"attachments\": [{\"callback_id\": \"game_selection\", \"fallback\": \"Upgrade your Slack client to use messages like these.\", \"id\": 1, \"color\": \"3AA3E3\", \"actions\": [{\"name\": \"games_list\", \"text\": \"Pick a game...\", \"type\": \"select\", \"options\": [{\"text\": \"Chess\", \"value\": \"chess\"}, {\"text\": \"Falken's Maze\", \"value\": \"maze\"}, {\"text\": \"Global Thermonuclear War\", \"value\": \"war\"}]}]}], \"type\": \"message\", \"subtype\": \"bot_message\", \"ts\": \"1481579582.000003\"}, \"response_url\": \"https://hooks.slack.com/actions/T012AB0A1/1234567890/JpmK0yzoZ5eRiqfeduTBYXWQ\", \"trigger_id\": \"13345224609.738474920.8088930838d88f008e0\"}",
      interaction.interaction_decoder(),
    )
}

pub fn interactive_message_1_test() {
  let assert Ok(interaction.InteractiveMessage(interaction.InteractiveMessagePayload(
    callback_id: "select_simple_1234",
    actions: Some([interaction.LegacyAction(name: Some("channels_list"), ..)]),
    ..,
  ))) =
    json.parse(
      "{\"type\": \"interactive_message\", \"actions\": [{\"name\": \"channels_list\", \"selected_options\": [{\"value\": \"C012AB3CD\"}]}], \"callback_id\": \"select_simple_1234\", \"team\": {\"id\": \"T012AB0A1\", \"domain\": \"pocket-calculator\"}, \"channel\": {\"id\": \"C012AB3CD\", \"name\": \"general\"}, \"user\": {\"id\": \"U012A1BCD\", \"name\": \"musik\"}, \"action_ts\": \"1481579588.685999\", \"message_ts\": \"1481579582.000003\", \"attachment_id\": \"1\", \"token\": \"iUeRJkkRC9RMMvSRTd8gdq2m\", \"original_message\": {\"text\": \"It's time to nominate the channel of the week\", \"bot_id\": \"B08BCU62D\", \"attachments\": [{\"callback_id\": \"select_simple_1234\", \"fallback\": \"Upgrade your Slack client to use messages like these.\", \"id\": 1, \"color\": \"3AA3E3\", \"actions\": [{\"id\": \"1\", \"name\": \"channels_list\", \"text\": \"Which channel changed your life this week?\", \"type\": \"select\", \"data_source\": \"channels\"}]}], \"type\": \"message\", \"subtype\": \"bot_message\", \"ts\": \"1481579582.000003\"}, \"response_url\": \"https://hooks.slack.com/actions/T012AB0A1/123456789/JpmK0yzoZDeRiqfeduTBYXWQ\", \"trigger_id\": \"13345224609.738474920.8088930838d88f008e0\"}",
      interaction.interaction_decoder(),
    )
}

pub fn interactive_message_2_test() {
  let assert Ok(interaction.InteractiveMessage(interaction.InteractiveMessagePayload(
    callback_id: "select_remote_1234",
    name: Some("bugs_list"),
    value: Some("bot"),
    ..,
  ))) =
    json.parse(
      "{\"name\": \"bugs_list\", \"value\": \"bot\", \"callback_id\": \"select_remote_1234\", \"type\": \"interactive_message\", \"team\": {\"id\": \"T012AB0A1\", \"domain\": \"pocket-calculator\"}, \"channel\": {\"id\": \"C012AB3CD\", \"name\": \"general\"}, \"user\": {\"id\": \"U012A1BCJ\", \"name\": \"bugcatcher\"}, \"action_ts\": \"1481670445.010908\", \"message_ts\": \"1481670439.000007\", \"attachment_id\": \"1\", \"token\": \"verification_token_string\"}",
      interaction.interaction_decoder(),
    )
}

pub fn interactive_message_3_test() {
  let assert Ok(interaction.InteractiveMessage(interaction.InteractiveMessagePayload(
    callback_id: "select_simple_1234",
    actions: Some([interaction.LegacyAction(name: Some("channels_list"), ..)]),
    ..,
  ))) =
    json.parse(
      "{\"type\": \"interactive_message\", \"actions\": [{\"name\": \"channels_list\", \"selected_options\": [{\"value\": \"C012AB3CD\"}]}], \"callback_id\": \"select_simple_1234\", \"team\": {\"id\": \"T012AB0A1\", \"domain\": \"pocket-calculator\"}, \"channel\": {\"id\": \"C012AB3CD\", \"name\": \"general\"}, \"user\": {\"id\": \"U012A1BCD\", \"name\": \"musik\"}, \"action_ts\": \"1481579588.685999\", \"message_ts\": \"1481579582.000003\", \"attachment_id\": \"1\", \"token\": \"iUeRJkkRC9RMMvSRTd8gdq2m\", \"original_message\": {\"text\": \"It's time to nominate the channel of the week\", \"bot_id\": \"B08BCU62D\", \"attachments\": [{\"callback_id\": \"select_simple_1234\", \"fallback\": \"Upgrade your Slack client to use messages like these.\", \"id\": 1, \"color\": \"3AA3E3\", \"actions\": [{\"id\": \"1\", \"name\": \"channels_list\", \"text\": \"Which channel changed your life this week?\", \"type\": \"select\", \"data_source\": \"channels\"}]}], \"type\": \"message\", \"subtype\": \"bot_message\", \"ts\": \"1481579582.000003\"}, \"response_url\": \"https://hooks.slack.com/actions/T012AB0A1/123456789/JpmK0yzoZDeRiqfeduTBYXWQ\"}",
      interaction.interaction_decoder(),
    )
}

pub fn interactive_message_4_test() {
  let assert Ok(interaction.InteractiveMessage(interaction.InteractiveMessagePayload(
    callback_id: "select_remote_1234",
    name: Some("bugs_list"),
    value: Some("bot"),
    ..,
  ))) =
    json.parse(
      "{\"name\": \"bugs_list\", \"value\": \"bot\", \"callback_id\": \"select_remote_1234\", \"type\": \"interactive_message\", \"team\": {\"id\": \"T012AB0A1\", \"domain\": \"pocket-calculator\"}, \"channel\": {\"id\": \"C012AB3CD\", \"name\": \"general\"}, \"user\": {\"id\": \"U012A1BCJ\", \"name\": \"bugcatcher\"}, \"action_ts\": \"1481670445.010908\", \"message_ts\": \"1481670439.000007\", \"attachment_id\": \"1\", \"token\": \"verification_token_string\"}",
      interaction.interaction_decoder(),
    )
}

pub fn interactive_message_5_test() {
  let assert Ok(interaction.InteractiveMessage(interaction.InteractiveMessagePayload(
    callback_id: "pick_channel_for_fun",
    actions: Some([interaction.LegacyAction(name: Some("channel_list"), ..)]),
    ..,
  ))) =
    json.parse(
      "{\"type\": \"interactive_message\", \"actions\": [{\"name\": \"channel_list\", \"type\": \"select\", \"selected_options\": [{\"value\": \"C24BTKDQW\"}]}], \"callback_id\": \"pick_channel_for_fun\", \"team\": {\"id\": \"T1ABCD2E12\", \"domain\": \"hooli-hq\"}, \"channel\": {\"id\": \"C123ABC456\", \"name\": \"triage-random\"}, \"user\": {\"id\": \"U123ABC456\", \"name\": \"sbutterfield\"}, \"action_ts\": \"1520966872.245369\", \"message_ts\": \"1520965348.000538\", \"attachment_id\": \"1\", \"token\": \"lbAZE0ckwoSNJcsGWE7sqX5j\", \"is_app_unfurl\": false, \"original_message\": {\"text\": \"\", \"username\": \"Belson Bot\", \"bot_id\": \"B9DKHFZ1E\", \"attachments\": [{\"callback_id\": \"pick_channel_for_fun\", \"text\": \"Choose a channel\", \"id\": 1, \"color\": \"2b72cb\", \"actions\": [{\"id\": \"1\", \"name\": \"channel_list\", \"text\": \"Public channels\", \"type\": \"select\", \"data_source\": \"channels\"}], \"fallback\": \"Choose a channel\"}], \"type\": \"message\", \"subtype\": \"bot_message\", \"ts\": \"1520965348.000538\"}, \"response_url\": \"https://hooks.slack.com/actions/T1ABCD2E12/330361579271/0dAEyLY19ofpLwxqozy3firz\", \"trigger_id\": \"328654886736.72393107734.9a0f78bccc3c64093f4b12fe82ccd51e\"}",
      interaction.interaction_decoder(),
    )
}

pub fn interactive_message_6_test() {
  let assert Ok(interaction.InteractiveMessage(interaction.InteractiveMessagePayload(
    callback_id: "comic_1234_xyz",
    actions: Some([interaction.LegacyAction(name: Some("recommend"), ..)]),
    ..,
  ))) =
    json.parse(
      "{\"type\": \"interactive_message\", \"actions\": [{\"name\": \"recommend\", \"value\": \"recommend\", \"type\": \"button\"}], \"callback_id\": \"comic_1234_xyz\", \"team\": {\"id\": \"T123ABC456\", \"domain\": \"watermelonsugar\"}, \"channel\": {\"id\": \"C123ABC456\", \"name\": \"forgotten-works\"}, \"user\": {\"id\": \"U123ABC456\", \"name\": \"brautigan\"}, \"action_ts\": \"1458170917.164398\", \"message_ts\": \"1458170866.000004\", \"attachment_id\": \"1\", \"token\": \"xAB3yVzGS4BQ3O9FACTa8Ho4\", \"original_message\": {\"text\": \"New comic book alert!\", \"attachments\": [{\"title\": \"The Further Adventures of Slackbot\", \"fields\": [{\"title\": \"Volume\", \"value\": \"1\", \"short\": true}, {\"title\": \"Issue\", \"value\": \"3\", \"short\": true}], \"author_name\": \"Stanford S. Strickland\", \"author_icon\": \"https://api.slack.com/img/api/homepage_custom_integrations-2x.png\", \"image_url\": \"http://i.imgur.com/OJkaVOI.jpg?1\"}, {\"title\": \"Synopsis\", \"text\": \"After @episod pushed exciting changes to a devious new branch back in Issue 1, Slackbot notifies @don about an unexpected deploy...\"}, {\"fallback\": \"Would you recommend it to customers?\", \"title\": \"Would you recommend it to customers?\", \"callback_id\": \"comic_1234_xyz\", \"color\": \"#3AA3E3\", \"attachment_type\": \"default\", \"actions\": [{\"name\": \"recommend\", \"text\": \"Recommend\", \"type\": \"button\", \"value\": \"recommend\"}, {\"name\": \"no\", \"text\": \"No\", \"type\": \"button\", \"value\": \"bad\"}]}]}, \"response_url\": \"https://hooks.slack.com/actions/T47563693/6204672533/x7ZLaiVMoECAW50Gw1ZYAXEM\", \"trigger_id\": \"13345224609.738474920.8088930838d88f008e0\"}",
      interaction.interaction_decoder(),
    )
}

pub fn dialog_suggestion_0_test() {
  let assert Ok(interaction.DialogSuggestion(interaction.DialogSuggestionPayload(
    callback_id: "bugs",
    name: Some("external_data"),
    ..,
  ))) =
    json.parse(
      "{\"type\": \"dialog_suggestion\", \"token\": \"W3VDvuzi2nRLsiaDOsmJranO\", \"action_ts\": \"1528203589.238335\", \"team\": {\"id\": \"T24BK35ML\", \"domain\": \"hooli-hq\"}, \"user\": {\"id\": \"U900MV5U7\", \"name\": \"gbelson\"}, \"channel\": {\"id\": \"C012AB3CD\", \"name\": \"triage-platform\"}, \"name\": \"external_data\", \"value\": \"\", \"callback_id\": \"bugs\"}",
      interaction.interaction_decoder(),
    )
}

pub fn dialog_suggestion_1_test() {
  let assert Ok(interaction.DialogSuggestion(interaction.DialogSuggestionPayload(
    callback_id: "bugs",
    value: Some("des"),
    ..,
  ))) =
    json.parse(
      "{\"type\": \"dialog_suggestion\", \"team\": {\"id\": \"T123ABC456\", \"domain\": \"hooli-hq\"}, \"user\": {\"id\": \"U123ABC456\", \"name\": \"sbutterfield\"}, \"channel\": {\"id\": \"C123ABC456\", \"name\": \"triage-platform\"}, \"action_ts\": \"1520635427.671963\", \"token\": \"W3VDvuzi2nRLsiaDOsmJranO\", \"name\": \"external_data\", \"value\": \"des\", \"callback_id\": \"bugs\"}",
      interaction.interaction_decoder(),
    )
}

pub fn dialog_submission_2_test() {
  let assert Ok(interaction.DialogSubmission(interaction.DialogSubmissionPayload(
    callback_id: "employee_offsite_1138b",
    submission:,
    state: Some("vegetarian"),
    ..,
  ))) =
    json.parse(
      "{\"type\": \"dialog_submission\", \"submission\": {\"name\": \"Sigourney Dreamweaver\", \"email\": \"sigdre@example.com\", \"phone\": \"+1 800-555-1212\", \"meal\": \"burrito\", \"comment\": \"No sour cream please\", \"team_channel\": \"C123ABC456\", \"who_should_sing\": \"U123ABC456\"}, \"callback_id\": \"employee_offsite_1138b\", \"state\": \"vegetarian\", \"team\": {\"id\": \"T123ABC456\", \"domain\": \"coverbands\"}, \"user\": {\"id\": \"W123ABC456\", \"name\": \"dreamweaver\"}, \"channel\": {\"id\": \"C123ABC456\", \"name\": \"coverthon-1999\"}, \"action_ts\": \"936893340.702759\", \"token\": \"M1AqUUw3FqayAbqNtsGMch72\", \"response_url\": \"https://hooks.slack.com/app/T012AB0A1/123456789/JpmK0yzoZDeRiqfeduTBYXWQ\"}",
      interaction.interaction_decoder(),
    )
  assert dict.size(submission) == 7
}

pub fn dialog_cancellation_3_test() {
  let assert Ok(interaction.DialogCancellation(interaction.DialogCancellationPayload(
    callback_id: "best_elvis_impersonator_name",
    state: Some("final_round"),
    ..,
  ))) =
    json.parse(
      "{\"type\": \"dialog_cancellation\", \"token\": \"old-and-moldy-verification-token\", \"action_ts\": \"1542993577.333025\", \"team\": {\"id\": \"T123ABC456\", \"domain\": \"coverbands\"}, \"user\": {\"id\": \"U123ABC456\", \"name\": \"leepresson\"}, \"channel\": {\"id\": \"C123ABC456\", \"name\": \"graceland\"}, \"callback_id\": \"best_elvis_impersonator_name\", \"response_url\": \"https://hooks.slack.com/app/T123ABC456/486xxxxxx/jbF9HF\", \"state\": \"final_round\"}",
      interaction.interaction_decoder(),
    )
}

pub fn view_submission_response_update_test() {
  let assert Ok(interaction.UpdateResponse(..)) =
    json.parse(
      "{\"response_action\": \"update\", \"view\": {\"type\": \"modal\", \"title\": {\"type\": \"plain_text\", \"text\": \"Updated view\"}, \"blocks\": [{\"type\": \"section\", \"text\": {\"type\": \"plain_text\", \"text\": \"I've changed and I'll never be the same. You must believe me.\"}}]}}",
      interaction.view_submission_response_decoder(),
    )
}

pub fn view_submission_response_push_test() {
  let assert Ok(interaction.PushResponse(..)) =
    json.parse(
      "{\"response_action\": \"push\", \"view\": {\"type\": \"modal\", \"title\": {\"type\": \"plain_text\", \"text\": \"Updated view\"}, \"blocks\": [{\"type\": \"image\", \"image_url\": \"https://api.slack.com/img/blocks/bkb_template_images/plants.png\", \"alt_text\": \"Plants\"}, {\"type\": \"context\", \"elements\": [{\"type\": \"mrkdwn\", \"text\": \"_Two of the author's cats sit aloof from the austere challenges of modern society_\"}]}]}}",
      interaction.view_submission_response_decoder(),
    )
}

pub fn view_submission_response_clear_test() {
  let assert Ok(interaction.ClearResponse) =
    json.parse(
      "{\"response_action\": \"clear\"}",
      interaction.view_submission_response_decoder(),
    )
}

pub fn view_submission_response_errors_test() {
  let assert Ok(interaction.ErrorsResponse(..)) =
    json.parse(
      "{\"response_action\": \"errors\", \"errors\": {\"ticket-due-date\": \"You may not select a due date in the past\"}}",
      interaction.view_submission_response_decoder(),
    )
}

pub fn dialog_options_response_0_test() {
  let assert Ok(interaction.DialogOptionsResponse(..)) =
    json.parse(
      "{\"options\": [{\"label\": \"[UXD-342] The button color should be artichoke green, not jalape\\u00f1o\", \"value\": \"UXD-342\"}, {\"label\": \"[FE-459] Remove the marquee tag\", \"value\": \"FE-459\"}, {\"label\": \"[FE-238] Too many shades of gray in master CSS\", \"value\": \"FE-238\"}]}",
      interaction.dialog_options_response_decoder(),
    )
}

pub fn dialog_options_response_1_test() {
  let assert Ok(interaction.DialogOptionsResponse(..)) =
    json.parse(
      "{\"option_groups\": [{\"label\": \"Visual Design\", \"options\": [{\"label\": \"[UXD-342] The button color should be artichoke green, not jalape\\u00f1o\", \"value\": \"UXD-342\"}]}, {\"label\": \"Front-End Engineering\", \"options\": [{\"label\": \"[FE-459] Remove the marquee tag\", \"value\": \"FE-459\"}, {\"label\": \"[FE-238] Too many shades of gray in master CSS\", \"value\": \"FE-238\"}]}]}",
      interaction.dialog_options_response_decoder(),
    )
}

pub fn dialog_errors_response_test() {
  let assert Ok(interaction.DialogErrorsResponse(errors: [_, _])) =
    json.parse(
      "{\"errors\": [{\"name\": \"email_address\", \"error\": \"Sorry, this email domain is not authorized!\"}, {\"name\": \"username\", \"error\": \"Uh-oh. This username has been taken!\"}]}",
      interaction.dialog_errors_response_decoder(),
    )
}

/// Docs example.
pub fn response_message_0_test() {
  let assert Ok(_) =
    json.parse(
      "{\"text\": \"Oh hey, this is a nifty ephemeral message response!\"}",
      interaction.response_message_decoder(),
    )
}

/// Docs example.
pub fn response_message_1_test() {
  let assert Ok(_) =
    json.parse(
      "{\"text\": \"Oh hey, this is a fun message in a channel!\", \"response_type\": \"in_channel\"}",
      interaction.response_message_decoder(),
    )
}

/// Docs example sends booleans as strings; Slack documents them as booleans.
pub fn response_message_2_test() {
  let assert Error(_) =
    json.parse(
      "{\"text\": \"Oh hey, this is a marvelous message in a thread!\", \"response_type\": \"in_channel\", \"replace_original\": \"false\", \"thread_ts\": \"1234567890\"}",
      interaction.response_message_decoder(),
    )
}

/// Docs example sends booleans as strings; Slack documents them as booleans.
pub fn response_message_3_test() {
  let assert Error(_) =
    json.parse(
      "{\"delete_original\": \"true\"}",
      interaction.response_message_decoder(),
    )
}

pub fn options_response_test() {
  let assert Ok(interaction.OptionsResponse(
    options: Some([_, _, _]),
    option_groups: None,
  )) =
    json.parse(
      "{\"options\": [{\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-0\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-1\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-2\"}]}",
      interaction.options_response_decoder(),
    )
}

pub fn errors_builder_test() {
  let response = interaction.errors([#("ticket-due-date", "In the past")])
  let assert interaction.ErrorsResponse(errors:) = response
  let assert Ok("In the past") = dict.get(errors, "ticket-due-date")
  let encoded =
    json.to_string(interaction.view_submission_response_to_json(response))
  let assert Ok(interaction.ErrorsResponse(..)) =
    json.parse(encoded, interaction.view_submission_response_decoder())
}

pub fn clear_encodes_tag_test() {
  let assert "{\"response_action\":\"clear\"}" =
    json.to_string(
      interaction.view_submission_response_to_json(interaction.clear()),
    )
}

pub fn block_action_fields_test() {
  let assert Ok(interaction.BlockActions(interaction.BlockActionsPayload(
    actions: Some([action]),
    ..,
  ))) =
    interaction.parse(
      "{\"type\":\"block_actions\",\"user\":{\"id\":\"U1\"},\"actions\":[{\"type\":\"static_select\",\"action_id\":\"a\",\"block_id\":\"b\",\"action_ts\":\"1.2\",\"selected_option\":null}]}",
    )
  let assert interaction.StaticSelectAction(
    action_id: "a",
    block_id: Some("b"),
    selected_option: None,
    ..,
  ) = action
}

pub fn rich_text_input_action_test() {
  let assert Ok(interaction.BlockActions(interaction.BlockActionsPayload(
    actions: Some([action]),
    ..,
  ))) =
    interaction.parse(
      "{\"type\":\"block_actions\",\"user\":{\"id\":\"U1\"},\"actions\":[{\"type\":\"rich_text_input\",\"action_id\":\"rt\",\"rich_text_value\":{\"type\":\"rich_text\",\"elements\":[{\"type\":\"rich_text_section\",\"elements\":[{\"type\":\"text\",\"text\":\"x\"}]}]}}]}",
    )
  let assert interaction.RichTextInputAction(rich_text_value: Some(value), ..) =
    action
  let assert True = known.rich_text(value)
}

pub fn unknown_interaction_test() {
  let assert Ok(interaction.UnknownInteraction(type_: "something_new", ..)) =
    interaction.parse("{\"type\":\"something_new\"}")
}

pub fn response_message_encode_test() {
  let message = interaction.in_channel("hi")
  let assert "{\"text\":\"hi\",\"response_type\":\"in_channel\"}" =
    json.to_string(interaction.response_message_to_json(message))
}
