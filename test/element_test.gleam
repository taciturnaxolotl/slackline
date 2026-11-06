//// Decodes the json examples on the Block Kit reference pages for block
//// elements and rich text elements. The examples come from the docs pages.
//// Trailing commas and fragments were fixed so they parse.

import gleam/dynamic/decode
import gleam/list
import known
import slackline/block
import slackline/view

pub fn attachment_mention_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"attachment_mention\", \"url\": \"https://example.com/attachment\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn broadcast_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"broadcast\", \"range\": \"everyone\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn button_element_0_test() {
  known.decodes(
    "{\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Click Me\"}, \"value\": \"click_me_123\", \"action_id\": \"button\"}",
    block.element_decoder(),
    known.element,
  )
}

pub fn button_element_4_test() {
  known.decodes(
    "{\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Save\"}, \"style\": \"primary\", \"value\": \"click_me_123\", \"action_id\": \"button\"}",
    block.element_decoder(),
    known.element,
  )
}

pub fn button_element_8_test() {
  known.decodes(
    "{\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Link Button\"}, \"url\": \"https://docs.slack.dev/block-kit\"}",
    block.element_decoder(),
    known.element,
  )
}

pub fn button_element_12_test() {
  known.decodes(
    "{\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Summarize with Slackbot\"}, \"action_id\": \"summarize_incident\", \"agent_prompt\": \"Summarize this incident and suggest next steps.\", \"agent_prompt_display\": \"Summarize this incident\"}",
    block.element_decoder(),
    known.element,
  )
}

pub fn button_element_13_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"This is a section block with a button.\"}, \"accessory\": {\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Click Me\"}, \"value\": \"click_me_123\", \"action_id\": \"button\"}}, {\"type\": \"actions\", \"block_id\": \"actionblock789\", \"elements\": [{\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Primary Button\"}, \"style\": \"primary\", \"value\": \"click_me_456\"}, {\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Link Button\"}, \"url\": \"https://api.slack.com/block-kit\"}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn canvas_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"canvas\", \"file_id\": \"F123ABC456\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn canvas_message_unfurl_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"canvas_message_unfurl\", \"root_message_ts\": \"1783613573\", \"root_message_channel\": \"CABCDEFGHI\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn canvas_user_mention_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"canvas_user_mention\", \"user_id\": \"U123ABC456\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn channel_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"channel\", \"channel_id\": \"C123ABC456\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn checkboxes_element_0_test() {
  known.decodes(
    "{\"type\": \"modal\", \"title\": {\"type\": \"plain_text\", \"text\": \"My App\", \"emoji\": true}, \"submit\": {\"type\": \"plain_text\", \"text\": \"Submit\", \"emoji\": true}, \"close\": {\"type\": \"plain_text\", \"text\": \"Cancel\", \"emoji\": true}, \"blocks\": [{\"type\": \"section\", \"text\": {\"type\": \"plain_text\", \"text\": \"Check out these charming checkboxes\"}, \"accessory\": {\"type\": \"checkboxes\", \"action_id\": \"this_is_an_action_id\", \"initial_options\": [{\"value\": \"A1\", \"text\": {\"type\": \"plain_text\", \"text\": \"Checkbox 1\"}}], \"options\": [{\"value\": \"A1\", \"text\": {\"type\": \"plain_text\", \"text\": \"Checkbox 1\"}}, {\"value\": \"A2\", \"text\": {\"type\": \"plain_text\", \"text\": \"Checkbox 2\"}, \"description\": {\"type\": \"mrkdwn\", \"text\": \"*A description of option two*\"}}]}}]}",
    view.view_decoder(),
    known.view,
  )
}

pub fn citation_element_5_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"citation\", \"url\": \"https://example.com/source\", \"text\": \"Source title\", \"index\": 1, \"details\": {\"citation_type\": \"file\", \"descriptor\": \"Team canvas\", \"file_id\": \"F0ABCDEFG12\"}}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn color_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"color\", \"value\": \"#F405B3\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn date_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"date\", \"timestamp\": 1720710212, \"format\": \"{date_num} at {time}\", \"fallback\": \"timey\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn date_picker_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"block_id\": \"section1234\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"Pick a date for the deadline.\"}, \"accessory\": {\"type\": \"datepicker\", \"action_id\": \"datepicker123\", \"initial_date\": \"1990-04-28\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Select a date\"}}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn datetime_picker_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"input\", \"element\": {\"type\": \"datetimepicker\", \"action_id\": \"datetimepicker-action\"}, \"hint\": {\"type\": \"plain_text\", \"text\": \"This is some hint text\", \"emoji\": true}, \"label\": {\"type\": \"plain_text\", \"text\": \"Start date\", \"emoji\": true}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn email_input_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"input\", \"block_id\": \"input123\", \"label\": {\"type\": \"plain_text\", \"text\": \"Email Address\"}, \"element\": {\"type\": \"email_text_input\", \"action_id\": \"email_text_input-action\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Enter an email\"}}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn emoji_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"emoji\", \"name\": \"basketball\"}, {\"type\": \"text\", \"text\": \" \"}, {\"type\": \"emoji\", \"name\": \"snowboarder\"}, {\"type\": \"text\", \"text\": \" \"}, {\"type\": \"emoji\", \"name\": \"checkered_flag\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn feedback_buttons_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"context_actions\", \"elements\": [{\"type\": \"feedback_buttons\", \"action_id\": \"feedback_buttons_1\", \"positive_button\": {\"text\": {\"type\": \"plain_text\", \"text\": \"Good\"}, \"value\": \"positive_feedback\", \"accessibility_label\": \"Mark this response as good\"}, \"negative_button\": {\"text\": {\"type\": \"plain_text\", \"text\": \"Bad\"}, \"value\": \"negative_feedback\", \"accessibility_label\": \"Mark this response as bad\"}}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn file_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"file\", \"file_id\": \"F123ABC456\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn file_input_element_0_test() {
  known.decodes(
    "{\"title\": {\"type\": \"plain_text\", \"text\": \"My App\", \"emoji\": true}, \"submit\": {\"type\": \"plain_text\", \"text\": \"Submit\", \"emoji\": true}, \"type\": \"modal\", \"close\": {\"type\": \"plain_text\", \"text\": \"Cancel\", \"emoji\": true}, \"blocks\": [{\"type\": \"input\", \"block_id\": \"input_block_id\", \"label\": {\"type\": \"plain_text\", \"text\": \"Upload Files\"}, \"element\": {\"type\": \"file_input\", \"action_id\": \"file_input_action_id_1\", \"filetypes\": [\"jpg\", \"png\"], \"max_files\": 5}}]}",
    view.view_decoder(),
    known.view,
  )
}

pub fn icon_button_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"context_actions\", \"elements\": [{\"type\": \"icon_button\", \"icon\": \"trash\", \"text\": {\"type\": \"plain_text\", \"text\": \"Delete\"}, \"action_id\": \"delete_button\", \"value\": \"delete_item\"}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn image_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"block_id\": \"section567\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"This is a section block with an accessory image.\"}, \"accessory\": {\"type\": \"image\", \"image_url\": \"https://pbs.twimg.com/profile_images/625633822235693056/lNGUneLX_400x400.jpg\", \"alt_text\": \"cute cat\"}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn image_element_4_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"block_id\": \"section567\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"This is a section block with an accessory image.\"}, \"accessory\": {\"type\": \"image\", \"slack_file\": {\"url\": \"https://files.slack.com/files-pri/T0123456-F0123456/xyz.png\"}, \"alt_text\": \"Slack file object.\"}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn image_element_8_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"block_id\": \"section567\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"This is a section block with an accessory image.\"}, \"accessory\": {\"type\": \"image\", \"slack_file\": {\"id\": \"F01234567\"}, \"alt_text\": \"Slack file object.\"}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn link_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"link\", \"url\": \"https://docs.slack.dev\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn list_record_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"list_record\", \"file_id\": \"F123ABC456\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn message_mention_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"message_mention\", \"channel_id\": \"C123ABC456\", \"message_ts\": \"1720710212.123456\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn multi_select_menu_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"block_id\": \"section678\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"Pick items from the list\"}, \"accessory\": {\"action_id\": \"text1234\", \"type\": \"multi_static_select\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Select items\"}, \"options\": [{\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-0\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-1\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-2\"}]}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn multi_select_menu_element_4_test() {
  known.decodes(
    "{\"options\": [{\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-0\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-1\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-2\"}]}",
    decode.at(["options"], decode.list(block.select_option_decoder())),
    list.all(_, known.select_option),
  )
}

pub fn multi_select_menu_element_5_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"block_id\": \"section678\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"Pick items from the list\"}, \"accessory\": {\"action_id\": \"text1234\", \"type\": \"multi_external_select\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Select items\"}, \"min_query_length\": 3}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn multi_select_menu_element_9_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"block_id\": \"section678\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"Pick users from the list\"}, \"accessory\": {\"action_id\": \"text1234\", \"type\": \"multi_users_select\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Select users\"}}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn multi_select_menu_element_13_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"block_id\": \"section678\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"Pick conversations from the list\"}, \"accessory\": {\"action_id\": \"text1234\", \"type\": \"multi_conversations_select\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Select conversations\"}}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn multi_select_menu_element_17_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"block_id\": \"section678\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"Pick channels from the list\"}, \"accessory\": {\"action_id\": \"text1234\", \"type\": \"multi_channels_select\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Select channels\"}}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn number_input_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"input\", \"element\": {\"type\": \"number_input\", \"is_decimal_allowed\": false, \"action_id\": \"number_input-action\"}, \"label\": {\"type\": \"plain_text\", \"text\": \"Label\", \"emoji\": true}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn overflow_menu_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"block_id\": \"section 890\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"This is a section block with an overflow menu.\"}, \"accessory\": {\"type\": \"overflow\", \"options\": [{\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-0\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-1\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-2\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-3\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-4\"}], \"action_id\": \"overflow\"}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn plain_text_input_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"input\", \"element\": {\"type\": \"plain_text_input\", \"action_id\": \"plain_text_input-action\"}, \"label\": {\"type\": \"plain_text\", \"text\": \"Label\", \"emoji\": true}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn radio_button_group_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"text\": {\"type\": \"plain_text\", \"text\": \"Check out these rad radio buttons\"}, \"accessory\": {\"type\": \"radio_buttons\", \"action_id\": \"this_is_an_action_id\", \"initial_option\": {\"value\": \"A1\", \"text\": {\"type\": \"plain_text\", \"text\": \"Radio 1\"}}, \"options\": [{\"value\": \"A1\", \"text\": {\"type\": \"plain_text\", \"text\": \"Radio 1\"}}, {\"value\": \"A2\", \"text\": {\"type\": \"plain_text\", \"text\": \"Radio 2\"}}]}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn rich_text_input_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"input\", \"element\": {\"type\": \"rich_text_input\", \"action_id\": \"rich_text_input-action\", \"dispatch_action_config\": {\"trigger_actions_on\": [\"on_character_entered\"]}, \"focus_on_load\": true, \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Enter text\"}}, \"label\": {\"type\": \"plain_text\", \"text\": \"Label\", \"emoji\": true}}], \"type\": \"home\"}",
    view.view_decoder(),
    known.view,
  )
}

pub fn rich_text_list_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"block_id\": \"block1\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"My favorite Slack features (in no particular order):\"}]}, {\"type\": \"rich_text_list\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Huddles\"}]}, {\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Canvas\"}]}, {\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Developing with Block Kit\"}]}], \"style\": \"bullet\", \"indent\": 0, \"border\": 1}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn rich_text_list_element_4_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"block_id\": \"block1\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Breakfast foods I enjoy:\"}]}, {\"type\": \"rich_text_list\", \"style\": \"bullet\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Hashbrowns\"}]}, {\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Eggs\"}]}]}, {\"type\": \"rich_text_list\", \"style\": \"bullet\", \"indent\": 1, \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Scrambled\"}]}, {\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Over easy\"}]}]}, {\"type\": \"rich_text_list\", \"style\": \"bullet\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Pancakes, extra syrup\"}]}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn rich_text_preformatted_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_preformatted\", \"elements\": [{\"type\": \"text\", \"text\": \"{\\n  \\\"object\\\": {\\n    \\\"description\\\": \\\"this is an example of a json object\\\"\\n  }\\n}\"}], \"border\": 0}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn rich_text_quote_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"block_id\": \"Vrzsu\", \"elements\": [{\"type\": \"rich_text_quote\", \"elements\": [{\"type\": \"text\", \"text\": \"What we need is good examples in our documentation.\"}]}, {\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Yes - I completely agree, Luke!\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn rich_text_section_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Hello there, I am a basic rich text block!\"}]}]}, {\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Hello there, \"}, {\"type\": \"text\", \"text\": \"I am a bold rich text block!\", \"style\": {\"bold\": true}}]}]}, {\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Hello there, \"}, {\"type\": \"text\", \"text\": \"I am an italic rich text block!\", \"style\": {\"italic\": true}}]}]}, {\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Hello there, \"}, {\"type\": \"text\", \"text\": \"I am a strikethrough rich text block!\", \"style\": {\"strike\": true}}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn salesforce_data_field_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"salesforce_data_field\", \"salesforce_record_id\": \"001ABC456DEF789\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn select_menu_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"block_id\": \"section678\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"Pick an item from the dropdown list\"}, \"accessory\": {\"action_id\": \"text1234\", \"type\": \"static_select\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Select an item\"}, \"options\": [{\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-0\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-1\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-2\"}]}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn select_menu_element_4_test() {
  known.decodes(
    "{\"options\": [{\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-0\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-1\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-2\"}]}",
    decode.at(["options"], decode.list(block.select_option_decoder())),
    list.all(_, known.select_option),
  )
}

pub fn select_menu_element_5_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"block_id\": \"section678\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"Pick an item from the dropdown list\"}, \"accessory\": {\"action_id\": \"text1234\", \"type\": \"external_select\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Select an item\"}, \"min_query_length\": 3}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn select_menu_element_9_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"block_id\": \"section678\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"Pick a user from the dropdown list\"}, \"accessory\": {\"action_id\": \"text1234\", \"type\": \"users_select\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Select an item\"}}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn select_menu_element_13_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"block_id\": \"section678\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"Pick a conversation from the dropdown list\"}, \"accessory\": {\"action_id\": \"text1234\", \"type\": \"conversations_select\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Select an item\"}}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn select_menu_element_17_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"block_id\": \"section678\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"Pick a channel from the dropdown list\"}, \"accessory\": {\"action_id\": \"text1234\", \"type\": \"channels_select\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Select an item\"}}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn tag_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"tag\", \"text\": \"In progress\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn team_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"team\", \"team_id\": \"T123ABC456\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn text_element_0_test() {
  known.decodes(
    "{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Hello there, \"}, {\"type\": \"text\", \"text\": \"I am a bold rich text block!\", \"style\": {\"bold\": true}}]}]}",
    block.block_decoder(),
    known.block,
  )
}

pub fn time_picker_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"block_id\": \"section1234\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"Pick a date for the deadline.\"}, \"accessory\": {\"type\": \"timepicker\", \"timezone\": \"America/Los_Angeles\", \"action_id\": \"timepicker123\", \"initial_time\": \"11:40\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Select a time\"}}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn url_input_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"input\", \"element\": {\"type\": \"url_text_input\", \"action_id\": \"url_text_input-action\"}, \"label\": {\"type\": \"plain_text\", \"text\": \"Label\", \"emoji\": true}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn url_source_element_0_test() {
  known.decodes(
    "{\"type\": \"url\", \"url\": \"https://docs.slack.dev/\", \"text\": \"Slack API docs\"}",
    block.url_source_decoder(),
    fn(_) { True },
  )
}

pub fn url_source_element_3_test() {
  known.decodes(
    "{\"type\": \"task_card\", \"task_id\": \"task_1\", \"title\": \"Scientific findings\", \"status\": \"complete\", \"sources\": [{\"type\": \"url\", \"url\": \"https://docs.example.com/\", \"text\": \"Tracy's delightful docs\"}, {\"type\": \"url\", \"url\": \"https://research.example.com/\", \"text\": \"Haley's resourceful research\"}]}",
    block.block_decoder(),
    known.block,
  )
}

pub fn user_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"user\", \"user_id\": \"U123ABC456\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn usergroup_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"usergroup\", \"usergroup_id\": \"G123ABC456\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn work_object_mention_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"work_object_mention\", \"entity_id\": \"E123ABC456\", \"app_id\": \"A123ABC456\", \"text\": \"Work object\", \"url\": \"https://example.com/work-object\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn workflow_button_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"text\": {\"text\": \"A message *with some bold text* and _some italicized text_.\", \"type\": \"mrkdwn\"}, \"accessory\": {\"type\": \"workflow_button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Run Workflow\"}, \"action_id\": \"workflowbutton123\", \"workflow\": {\"trigger\": {\"url\": \"https://slack.com/shortcuts/Ft0123ABC456/xyz...zyx\", \"customizable_input_parameters\": [{\"name\": \"input_parameter_a\", \"value\": \"Value for input param A\"}, {\"name\": \"input_parameter_b\", \"value\": \"Value for input param B\"}]}}}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn workflow_mention_element_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"workflow_mention\", \"workflow_id\": \"Wf123ABC456\", \"function_trigger_id\": \"Ft123ABC456\", \"text\": \"Run workflow\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}
