//// Decodes the json examples on the Block Kit reference pages for blocks,
//// composition objects and surfaces, and tests the builders. The examples
//// come from the docs pages. Trailing commas and fragments were fixed so
//// they parse. Elided examples ("...") and json schemas are skipped.

import gleam/dynamic/decode
import gleam/json
import gleam/option.{None, Some}
import known
import slackline/block
import slackline/block/header
import slackline/block/image
import slackline/block/input
import slackline/block/section
import slackline/element
import slackline/element/button
import slackline/element/datepicker
import slackline/element/image as element_image
import slackline/element/multi_static_select
import slackline/element/plain_text_input
import slackline/element/static_select
import slackline/view

pub fn actions_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"actions\", \"block_id\": \"actions1\", \"elements\": [{\"type\": \"static_select\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Which witch is the witchiest witch?\"}, \"action_id\": \"select_2\", \"options\": [{\"text\": {\"type\": \"plain_text\", \"text\": \"Matilda\"}, \"value\": \"matilda\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"Glinda\"}, \"value\": \"glinda\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"Granny Weatherwax\"}, \"value\": \"grannyWeatherwax\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"Hermione\"}, \"value\": \"hermione\"}]}, {\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Cancel\"}, \"value\": \"cancel\", \"action_id\": \"button_1\"}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn actions_block_4_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"actions\", \"block_id\": \"actionblock789\", \"elements\": [{\"type\": \"datepicker\", \"action_id\": \"datepicker123\", \"initial_date\": \"1990-04-28\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Select a date\"}}, {\"type\": \"overflow\", \"options\": [{\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-0\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-1\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-2\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-3\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-4\"}], \"action_id\": \"overflow\"}, {\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Click Me\"}, \"value\": \"click_me_123\", \"action_id\": \"button\"}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn alert_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"alert\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"The work is mysterious and important.\", \"verbatim\": false}, \"level\": \"info\"}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn card_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"card\", \"icon\": {\"type\": \"image\", \"image_url\": \"https://picsum.photos/36/36\", \"alt_text\": \"Icon\"}, \"title\": {\"type\": \"mrkdwn\", \"text\": \"Lumon Industries\", \"verbatim\": false}, \"subtitle\": {\"type\": \"mrkdwn\", \"text\": \"Committed to work-life balance\", \"verbatim\": false}, \"hero_image\": {\"type\": \"image\", \"image_url\": \"https://picsum.photos/400/300\", \"alt_text\": \"Sample hero image\"}, \"body\": {\"type\": \"mrkdwn\", \"text\": \"Please enjoy each card equally.\", \"verbatim\": false}, \"actions\": [{\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Action Button\", \"emoji\": false}, \"action_id\": \"button_action\"}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn carousel_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"carousel\", \"elements\": [{\"type\": \"card\", \"block_id\": \"carousel-card-1\", \"icon\": {\"type\": \"image\", \"image_url\": \"https://picsum.photos/36/36\", \"alt_text\": \"Icon\"}, \"title\": {\"type\": \"mrkdwn\", \"text\": \"MDR\", \"verbatim\": false}, \"subtitle\": {\"type\": \"mrkdwn\", \"text\": \"Refining data files\", \"verbatim\": false}, \"hero_image\": {\"type\": \"image\", \"image_url\": \"https://picsum.photos/400/300\", \"alt_text\": \"Sample hero image\"}, \"body\": {\"type\": \"mrkdwn\", \"text\": \"Blue badge required to gain access.\", \"verbatim\": false}, \"actions\": [{\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Action Button\", \"emoji\": false}, \"action_id\": \"button_action_1\"}]}, {\"type\": \"card\", \"block_id\": \"carousel-card-2\", \"icon\": {\"type\": \"image\", \"image_url\": \"https://picsum.photos/36/36\", \"alt_text\": \"Icon\"}, \"title\": {\"type\": \"mrkdwn\", \"text\": \"O&D\", \"verbatim\": false}, \"subtitle\": {\"type\": \"mrkdwn\", \"text\": \"Storage, maintenance, and rotation of art pieces\", \"verbatim\": false}, \"hero_image\": {\"type\": \"image\", \"image_url\": \"https://picsum.photos/400/300\", \"alt_text\": \"Sample hero image\"}, \"body\": {\"type\": \"mrkdwn\", \"text\": \"Green badge required to gain access.\", \"verbatim\": false}, \"actions\": [{\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Action Button\", \"emoji\": false}, \"action_id\": \"button_action_2\"}]}, {\"type\": \"card\", \"block_id\": \"carousel-card-3\", \"icon\": {\"type\": \"image\", \"image_url\": \"https://picsum.photos/36/36\", \"alt_text\": \"Icon\"}, \"title\": {\"type\": \"mrkdwn\", \"text\": \"Wellness Center\", \"verbatim\": false}, \"subtitle\": {\"type\": \"mrkdwn\", \"text\": \"Wellness sessions\", \"verbatim\": false}, \"hero_image\": {\"type\": \"image\", \"image_url\": \"https://picsum.photos/400/300\", \"alt_text\": \"Sample hero image\"}, \"body\": {\"type\": \"mrkdwn\", \"text\": \"Please take a seat in the waiting room until called.\", \"verbatim\": false}, \"actions\": [{\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Action Button\", \"emoji\": false}, \"action_id\": \"button_action_3\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn container_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"container\", \"block_id\": \"bkb_container_bulk_update\", \"title\": {\"type\": \"plain_text\", \"text\": \"Bulk update: 2 records selected\"}, \"subtitle\": {\"type\": \"plain_text\", \"text\": \"Review changes before confirming\"}, \"is_collapsible\": true, \"child_blocks\": [{\"type\": \"section\", \"block_id\": \"record-row-1\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"*DCW-1024*\\nStatus: Open → Closed\\nAssignee: @princessdonut → @carl\"}}, {\"type\": \"divider\", \"block_id\": \"bulk-div-1\"}, {\"type\": \"section\", \"block_id\": \"record-row-2\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"*DCW-1025*\\nStatus: In Progress → Closed\\nAssignee: @mordecai → @carl\"}}, {\"type\": \"divider\", \"block_id\": \"bulk-div-2\"}, {\"type\": \"context\", \"block_id\": \"bulk-status-bar\", \"elements\": [{\"type\": \"mrkdwn\", \"text\": \":white_check_mark: 2 records will be updated • Status → Closed • Assignee → @carl\"}]}, {\"type\": \"actions\", \"block_id\": \"bulk-actions\", \"elements\": [{\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Confirm All\", \"emoji\": true}, \"style\": \"primary\", \"action_id\": \"bulk_confirm\"}, {\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Cancel\", \"emoji\": true}, \"action_id\": \"bulk_cancel\"}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn context_actions_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"context_actions\", \"elements\": [{\"type\": \"feedback_buttons\", \"action_id\": \"feedback_buttons_1\", \"positive_button\": {\"text\": {\"type\": \"plain_text\", \"text\": \"👍\"}, \"value\": \"positive_feedback\"}, \"negative_button\": {\"text\": {\"type\": \"plain_text\", \"text\": \"👎\"}, \"value\": \"negative_feedback\"}}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn context_actions_block_3_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"context_actions\", \"elements\": [{\"type\": \"icon_button\", \"icon\": \"trash\", \"text\": {\"type\": \"plain_text\", \"text\": \"Delete\"}, \"action_id\": \"delete_button_1\", \"value\": \"delete_item\"}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn context_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"context\", \"elements\": [{\"type\": \"image\", \"image_url\": \"https://image.freepik.com/free-photo/red-drawing-pin_1156-445.jpg\", \"alt_text\": \"images\"}, {\"type\": \"mrkdwn\", \"text\": \"Location: **Dogpatch**\"}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn data_table_block_3_test() {
  known.decodes(
    "{\"type\": \"action_cell\", \"element\": {\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Mark done\"}, \"action_id\": \"mark_done\", \"value\": \"task_123\"}, \"fallback\": {\"type\": \"raw_text\", \"text\": \"Open\"}}",
    block.table_cell_decoder(),
    known.table_cell,
  )
}

pub fn data_table_block_4_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"data_table\", \"caption\": \"A Fabulous Table\", \"rows\": [[{\"type\": \"raw_text\", \"text\": \"Name\"}, {\"type\": \"raw_text\", \"text\": \"Department\"}, {\"type\": \"raw_text\", \"text\": \"Badge\"}], [{\"type\": \"raw_text\", \"text\": \"Data Refinement Department\"}, {\"type\": \"raw_text\", \"text\": \"MDR\"}, {\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Blue\", \"style\": {\"bold\": true}}]}]}], [{\"type\": \"raw_text\", \"text\": \"Art Sourcing Department\"}, {\"type\": \"raw_text\", \"text\": \"O&D\"}, {\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Green\"}, {\"type\": \"text\", \"text\": \"review\", \"style\": {\"italic\": true}}]}]}], [{\"type\": \"raw_text\", \"text\": \"Wellness Department\"}, {\"type\": \"raw_text\", \"text\": \"Wellness Center\"}, {\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Limited\", \"style\": {\"bold\": true}}]}]}]]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn data_visualization_block_0_test() {
  known.decodes(
    "{\"type\": \"data_visualization\", \"title\": \"My Favorite Candy Bars\", \"chart\": {\"type\": \"pie\", \"segments\": [{\"label\": \"Kit Kat\", \"value\": 45}, {\"label\": \"Twix\", \"value\": 28}, {\"label\": \"Crunch\", \"value\": 18}, {\"label\": \"Milky Way\", \"value\": 9}]}}",
    block.block_decoder(),
    known.block,
  )
}

pub fn data_visualization_block_1_test() {
  known.decodes(
    "{\"type\": \"data_visualization\", \"title\": \"My Favorite Pies by Percentage of Tastiness\", \"chart\": {\"type\": \"bar\", \"series\": [{\"name\": \"Pies\", \"data\": [{\"label\": \"Strawberry Rhubarb\", \"value\": 85}, {\"label\": \"Pumpkin\", \"value\": 70}, {\"label\": \"Lemon Meringue\", \"value\": 72}, {\"label\": \"Blueberry\", \"value\": 90}, {\"label\": \"Key Lime\", \"value\": 56}]}], \"axis_config\": {\"categories\": [\"Strawberry Rhubarb\", \"Pumpkin\", \"Lemon Meringue\", \"Blueberry\", \"Key Lime\"], \"x_label\": \"Pies\", \"y_label\": \"Percentage of Tastiness\"}}}",
    block.block_decoder(),
    known.block,
  )
}

pub fn data_visualization_block_2_test() {
  known.decodes(
    "{\"type\": \"data_visualization\", \"title\": \"Daily Active Users\", \"chart\": {\"type\": \"area\", \"series\": [{\"name\": \"Pied Piper Free Tier\", \"data\": [{\"label\": \"Mon\", \"value\": 12000}, {\"label\": \"Tues\", \"value\": 13500}, {\"label\": \"Wed\", \"value\": 15200}, {\"label\": \"Thurs\", \"value\": 14800}, {\"label\": \"Fri\", \"value\": 16400}]}, {\"name\": \"Pied Piper Paid Tier\", \"data\": [{\"label\": \"Mon\", \"value\": 4500}, {\"label\": \"Tues\", \"value\": 4800}, {\"label\": \"Wed\", \"value\": 5100}, {\"label\": \"Thurs\", \"value\": 5600}, {\"label\": \"Fri\", \"value\": 6200}]}], \"axis_config\": {\"categories\": [\"Mon\", \"Tues\", \"Wed\", \"Thurs\", \"Fri\"], \"x_label\": \"Day\", \"y_label\": \"Users\"}}}",
    block.block_decoder(),
    known.block,
  )
}

pub fn data_visualization_block_3_test() {
  known.decodes(
    "{\"type\": \"data_visualization\", \"title\": \"Weekly Paper Sales\", \"chart\": {\"type\": \"line\", \"series\": [{\"name\": \"Dunder Mifflin Infinity Website\", \"data\": [{\"label\": \"Week 1\", \"value\": 32000}, {\"label\": \"Week 2\", \"value\": 35000}, {\"label\": \"Week 3\", \"value\": 29000}, {\"label\": \"Week 4\", \"value\": 41000}, {\"label\": \"Week 5\", \"value\": 45000}]}, {\"name\": \"Dunder Mifflin In-store\", \"data\": [{\"label\": \"Week 1\", \"value\": 32000}, {\"label\": \"Week 2\", \"value\": 35000}, {\"label\": \"Week 3\", \"value\": 29000}, {\"label\": \"Week 4\", \"value\": 41000}, {\"label\": \"Week 5\", \"value\": 45000}]}], \"axis_config\": {\"categories\": [\"Week 1\", \"Week 2\", \"Week 3\", \"Week 4\", \"Week 5\"], \"x_label\": \"Week\", \"y_label\": \"Paper Sales (USD)\"}}}",
    block.block_decoder(),
    known.block,
  )
}

pub fn divider_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"divider\"}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn file_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"file\", \"external_id\": \"ABCD1\", \"source\": \"remote\"}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn header_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"header\", \"text\": {\"type\": \"plain_text\", \"text\": \"A Heartfelt Header\"}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn image_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"image\", \"title\": {\"type\": \"plain_text\", \"text\": \"Please enjoy this photo of a kitten\"}, \"block_id\": \"image4\", \"image_url\": \"http://placekitten.com/500/500\", \"alt_text\": \"An incredibly cute kitten.\"}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn image_block_4_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"image\", \"title\": {\"type\": \"plain_text\", \"text\": \"Please enjoy this photo of a kitten\"}, \"block_id\": \"image4\", \"slack_file\": {\"url\": \"https://files.slack.com/files-pri/T0123456-F0123456/xyz.png\"}, \"alt_text\": \"An incredibly cute kitten.\"}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn image_block_8_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"image\", \"title\": {\"type\": \"plain_text\", \"text\": \"Please enjoy this photo of a kitten\"}, \"block_id\": \"image4\", \"slack_file\": {\"id\": \"F0123456\"}, \"alt_text\": \"An incredibly cute kitten.\"}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn input_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"input\", \"element\": {\"type\": \"plain_text_input\"}, \"label\": {\"type\": \"plain_text\", \"text\": \"Label\", \"emoji\": true}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn layout_block_1_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"layout\", \"block_id\": \"deal_summary_layout\", \"label\": \"Deal summary for Borant Corp\", \"is_label_visible\": true, \"rows\": [{\"items\": [{\"block\": {\"type\": \"section\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"*Stage*\\nNegotiation\"}}}, {\"block\": {\"type\": \"section\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"*Amount*\\n$125,000\"}}}, {\"block\": {\"type\": \"section\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"*Close*\\n2026-08-15\"}}}]}, {\"items\": [{\"block\": {\"type\": \"section\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"*Next Steps*\\nSchedule sponsor meeting and finalize agreement\"}}}]}, {\"items\": [{\"width\": \"narrow\", \"horizontal_alignment\": \"end\", \"block\": {\"type\": \"actions\", \"elements\": [{\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"View in Salesforce\"}, \"style\": \"primary\"}, {\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Update Stage\"}, \"style\": \"danger\"}]}}]}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn markdown_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"markdown\", \"text\": \"**Lots of information here!!**\"}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn plan_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"plan\", \"title\": \"Thinking completed\", \"tasks\": [{\"task_id\": \"call_001\", \"title\": \"Fetched user profile information\", \"status\": \"in_progress\", \"details\": {\"type\": \"rich_text\", \"block_id\": \"viMWO\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Searched database...\"}]}]}, \"output\": {\"type\": \"rich_text\", \"block_id\": \"viMWO\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Profile data loaded\"}]}]}}, {\"task_id\": \"call_002\", \"title\": \"Checked user permissions\", \"status\": \"in_progress\"}, {\"task_id\": \"call_003\", \"title\": \"Generated comprehensive user report\", \"status\": \"complete\", \"output\": {\"type\": \"rich_text\", \"block_id\": \"crsk\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"15 data points compiled\"}]}]}}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn section_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"A message *with some bold text* and _some italicized text_.\"}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn section_block_4_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"text\": {\"text\": \"A message *with some bold text* and _some italicized text_.\", \"type\": \"mrkdwn\"}, \"fields\": [{\"type\": \"mrkdwn\", \"text\": \"High\"}, {\"type\": \"plain_text\", \"emoji\": true, \"text\": \"Silly\"}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn section_block_8_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"text\": {\"text\": \"*Haley* has requested you set a deadline for finding a house\", \"type\": \"mrkdwn\"}, \"accessory\": {\"type\": \"datepicker\", \"action_id\": \"datepicker123\", \"initial_date\": \"1990-04-28\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Select a date\"}}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn table_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"table\", \"column_settings\": [{\"is_wrapped\": true}, {\"align\": \"right\"}], \"rows\": [[{\"type\": \"raw_text\", \"text\": \"Header A\"}, {\"type\": \"raw_text\", \"text\": \"Header B\"}], [{\"type\": \"raw_text\", \"text\": \"Data 1A\"}, {\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"text\": \"Data 1B\", \"type\": \"link\", \"url\": \"https://slack.com\"}]}]}], [{\"type\": \"raw_text\", \"text\": \"Data 2A\"}, {\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"text\": \"Data 2B\", \"type\": \"link\", \"url\": \"https://slack.com\"}]}]}]]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn task_card_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"task_card\", \"task_id\": \"task_1\", \"title\": \"Fetching weather data\", \"status\": \"in_progress\", \"output\": {\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Found weather data for Chicago from 2 sources\"}]}]}, \"sources\": [{\"type\": \"url\", \"url\": \"https://weather.com/\", \"text\": \"weather.com\"}, {\"type\": \"url\", \"url\": \"https://www.accuweather.com/\", \"text\": \"accuweather.com\"}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn video_block_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"video\", \"title\": {\"type\": \"plain_text\", \"text\": \"Use the Events API to create a dynamic App Home\", \"emoji\": true}, \"title_url\": \"https://www.youtube.com/watch?v=8876OZV_Yy0\", \"description\": {\"type\": \"plain_text\", \"text\": \"Slack sure is nifty!\", \"emoji\": true}, \"video_url\": \"https://www.youtube.com/embed/8876OZV_Yy0?feature=oembed&autoplay=1\", \"alt_text\": \"Use the Events API to create a dynamic App Home\", \"thumbnail_url\": \"https://i.ytimg.com/vi/8876OZV_Yy0/hqdefault.jpg\"}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn confirmation_dialog_object_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"actions\", \"elements\": [{\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"emoji\": true, \"text\": \"Approve\"}, \"confirm\": {\"title\": {\"type\": \"plain_text\", \"text\": \"Are you sure?\"}, \"text\": {\"type\": \"mrkdwn\", \"text\": \"Would you not prefer a good game of _chess_?\"}, \"confirm\": {\"type\": \"plain_text\", \"text\": \"Do it\"}, \"deny\": {\"type\": \"plain_text\", \"text\": \"Stop, I changed my mind!\"}}, \"style\": \"primary\", \"value\": \"click_me_123\"}, {\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"emoji\": true, \"text\": \"Deny\"}, \"style\": \"danger\", \"value\": \"click_me_123\"}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn conversation_filter_object_0_test() {
  known.decodes(
    "{\"title\": {\"type\": \"plain_text\", \"text\": \"My App\", \"emoji\": true}, \"submit\": {\"type\": \"plain_text\", \"text\": \"Submit\", \"emoji\": true}, \"type\": \"modal\", \"close\": {\"type\": \"plain_text\", \"text\": \"Cancel\", \"emoji\": true}, \"blocks\": [{\"type\": \"input\", \"element\": {\"type\": \"conversations_select\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Select a conversation\", \"emoji\": true}, \"filter\": {\"include\": [\"public\", \"mpim\"], \"exclude_bot_users\": true}}, \"label\": {\"type\": \"plain_text\", \"text\": \"Choose the conversation to publish your result to:\", \"emoji\": true}}]}",
    view.view_decoder(),
    known.view,
  )
}

pub fn dispatch_action_configuration_object_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"input\", \"dispatch_action\": true, \"element\": {\"type\": \"plain_text_input\", \"multiline\": true, \"dispatch_action_config\": {\"trigger_actions_on\": [\"on_character_entered\"]}}, \"label\": {\"type\": \"plain_text\", \"text\": \"This is a multiline plain-text input\", \"emoji\": true}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn option_group_object_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"text\": {\"type\": \"mrkdwn\", \"text\": \":mag: Search results for *Cata*\"}}, {\"type\": \"divider\"}, {\"type\": \"section\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"*<fakeLink.toYourApp.com|Use Case Catalogue>*\\nUse Case Catalogue for the following departments/roles...\"}, \"accessory\": {\"type\": \"static_select\", \"placeholder\": {\"type\": \"plain_text\", \"emoji\": true, \"text\": \"Manage\"}, \"option_groups\": [{\"label\": {\"type\": \"plain_text\", \"text\": \"Group 1\"}, \"options\": [{\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-0\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-1\"}, {\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-2\"}]}, {\"label\": {\"type\": \"plain_text\", \"text\": \"Group 2\"}, \"options\": [{\"text\": {\"type\": \"plain_text\", \"text\": \"*this is plain_text text*\"}, \"value\": \"value-3\"}]}]}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn option_object_0_test() {
  known.decodes(
    "{\"text\": {\"type\": \"plain_text\", \"emoji\": true, \"text\": \"Save it\"}, \"value\": \"value-2\"}",
    block.select_option_decoder(),
    known.select_option,
  )
}

pub fn option_object_4_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"text\": {\"type\": \"mrkdwn\", \"text\": \":mag: Search results for *Cata*\"}}, {\"type\": \"divider\"}, {\"type\": \"section\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"*<fakeLink.toYourApp.com|Use Case Catalogue>*\\nUse Case Catalogue for the following departments/roles...\"}, \"accessory\": {\"type\": \"static_select\", \"placeholder\": {\"type\": \"plain_text\", \"emoji\": true, \"text\": \"Manage\"}, \"options\": [{\"text\": {\"type\": \"plain_text\", \"emoji\": true, \"text\": \"Edit it\"}, \"value\": \"value-0\"}, {\"text\": {\"type\": \"plain_text\", \"emoji\": true, \"text\": \"Read it\"}, \"value\": \"value-1\"}, {\"text\": {\"type\": \"plain_text\", \"emoji\": true, \"text\": \"Save it\"}, \"value\": \"value-2\"}]}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn slack_file_object_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"image\", \"title\": {\"type\": \"plain_text\", \"text\": \"Please enjoy this photo of a kitten\"}, \"block_id\": \"image4\", \"slack_file\": {\"url\": \"https://files.slack.com/files-pri/T0123456-F0123456/xyz.png\"}, \"alt_text\": \"An incredibly cute kitten.\"}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn slack_file_object_4_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"image\", \"title\": {\"type\": \"plain_text\", \"text\": \"Please enjoy this photo of a kitten\"}, \"block_id\": \"image4\", \"slack_file\": {\"id\": \"F0123456\"}, \"alt_text\": \"An incredibly cute kitten.\"}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn text_object_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"A message *with some bold text* and _some italicized text_.\"}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn trigger_object_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"text\": {\"text\": \"A message *with some bold text* and _some italicized text_.\", \"type\": \"mrkdwn\"}, \"accessory\": {\"type\": \"workflow_button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Run Workflow\"}, \"action_id\": \"workflowbutton123\", \"workflow\": {\"trigger\": {\"url\": \"https://slack.com/shortcuts/Ft0123ABC456/xyz...zyx\", \"customizable_input_parameters\": [{\"name\": \"input_parameter_a\", \"value\": \"Value for input param A\"}, {\"name\": \"input_parameter_b\", \"value\": \"Value for input param B\"}]}}}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn workflow_object_0_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"section\", \"text\": {\"text\": \"A message *with some bold text* and _some italicized text_.\", \"type\": \"mrkdwn\"}, \"accessory\": {\"type\": \"workflow_button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Run Workflow\"}, \"action_id\": \"workflowbutton123\", \"workflow\": {\"trigger\": {\"url\": \"https://slack.com/shortcuts/Ft0123ABC456/xyz...zyx\", \"customizable_input_parameters\": [{\"name\": \"input_parameter_a\", \"value\": \"Value for input param A\"}, {\"name\": \"input_parameter_b\", \"value\": \"Value for input param B\"}]}}}}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn formatting_with_rich_text_0_test() {
  known.decodes(
    "{\"type\": \"header\", \"text\": {\"type\": \"plain_text\", \"text\": \"Onboarding Week 1\"}}",
    block.block_decoder(),
    known.block,
  )
}

pub fn formatting_with_rich_text_1_test() {
  known.decodes(
    "{\"type\": \"context\", \"elements\": [{\"type\": \"mrkdwn\", \"text\": \"Hello there! This is a weekly reminder of what you should be doing during onboarding.\"}]}",
    block.block_decoder(),
    known.block,
  )
}

pub fn formatting_with_rich_text_2_test() {
  known.decodes(
    "{\"type\": \"section\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"*Welcome aboard!*\\n :eye: :lips: :eye:\\n\\nHere are some things you should do in week 1.\\n Of course, reach out to your manager with any questions.\"}, \"accessory\": {\"type\": \"image\", \"image_url\": \"https://media.giphy.com/media/Ae7SI3LoPYj8Q/giphy.gif\", \"alt_text\": \"One of us\"}}",
    block.block_decoder(),
    known.block,
  )
}

pub fn formatting_with_rich_text_3_test() {
  known.decodes("{\"type\": \"divider\"}", block.block_decoder(), known.block)
}

pub fn formatting_with_rich_text_4_test() {
  known.decodes(
    "{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"emoji\", \"name\": \"office\"}, {\"type\": \"text\", \"text\": \" Company business\", \"style\": {\"bold\": true}}]}, {\"type\": \"rich_text_list\", \"style\": \"bullet\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Fill out your W-2\"}]}, {\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Enroll in \"}, {\"type\": \"link\", \"text\": \"benefits\", \"url\": \"https://salesforcebenefits.com\"}]}, {\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Fill out your Slack profile, including:\"}]}]}, {\"type\": \"rich_text_list\", \"style\": \"ordered\", \"indent\": 1, \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Time zone\"}]}, {\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"Pronouns\"}]}]}]}",
    block.block_decoder(),
    known.block,
  )
}

pub fn formatting_with_rich_text_5_test() {
  known.decodes(
    "{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"emoji\", \"name\": \"green_book\"}, {\"type\": \"text\", \"text\": \" Read about our culture\", \"style\": {\"bold\": true}}]}, {\"type\": \"rich_text_list\", \"style\": \"bullet\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"link\", \"text\": \"Four tips for building a digital first culture\", \"url\": \"https://slack.com/blog/collaboration/four-tips-build-digital-first-culture\"}]}, {\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"link\", \"text\": \"6 simple ways to foster a positive hybrid work environment\", \"url\": \"https://slack.com/blog/collaboration/ways-foster-positive-work-environment\"}]}]}]}",
    block.block_decoder(),
    known.block,
  )
}

pub fn formatting_with_rich_text_6_test() {
  known.decodes(
    "{\"blocks\": [{\"type\": \"rich_text\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"emoji\", \"name\": \"speech_balloon\"}, {\"type\": \"text\", \"text\": \" Inspirational quote of the day\", \"style\": {\"bold\": true}}]}, {\"type\": \"rich_text_quote\", \"elements\": [{\"type\": \"text\", \"text\": \"Having no destination I am never lost. - Ikkyū.\"}]}]}, {\"type\": \"input\", \"block_id\": \"quote_input_block\", \"element\": {\"type\": \"plain_text_input\"}, \"label\": {\"type\": \"plain_text\", \"text\": \":envelope: Enter your favorite quote, to be shared with future hires like you:\", \"emoji\": true}}, {\"type\": \"actions\", \"block_id\": \"submit_button_action_block\", \"elements\": [{\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Submit\"}, \"value\": \"submit\", \"action_id\": \"button_1\"}]}]}",
    decode.at(["blocks"], decode.list(block.block_decoder())),
    known.blocks,
  )
}

pub fn home_tab_views_0_test() {
  known.decodes(
    "{\"type\": \"home\", \"blocks\": [{\"type\": \"section\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"A stack of blocks for the sample Block Kit Home tab.\"}}, {\"type\": \"actions\", \"elements\": [{\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Action A\", \"emoji\": true}}, {\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Action B\", \"emoji\": true}}]}]}",
    view.view_decoder(),
    known.view,
  )
}

pub fn modal_views_0_test() {
  known.decodes(
    "{\"type\": \"modal\", \"title\": {\"type\": \"plain_text\", \"text\": \"Modal title\"}, \"blocks\": [{\"type\": \"section\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"It's Block Kit...but _in a modal_\"}, \"block_id\": \"section1\", \"accessory\": {\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Click me\"}, \"action_id\": \"button_abc\", \"value\": \"Button value\", \"style\": \"danger\"}}, {\"type\": \"input\", \"label\": {\"type\": \"plain_text\", \"text\": \"Input label\"}, \"element\": {\"type\": \"plain_text_input\", \"action_id\": \"input1\", \"placeholder\": {\"type\": \"plain_text\", \"text\": \"Type in here\"}, \"multiline\": false}, \"optional\": false}], \"close\": {\"type\": \"plain_text\", \"text\": \"Cancel\"}, \"submit\": {\"type\": \"plain_text\", \"text\": \"Save\"}, \"private_metadata\": \"Shhhhhhhh\", \"callback_id\": \"view_identifier_12\"}",
    view.view_decoder(),
    known.view,
  )
}

// ---------------------------------------------------------------- builders

fn round_trip(
  value: a,
  encode: fn(a) -> json.Json,
  decoder: decode.Decoder(a),
) {
  let assert Ok(decoded) = json.parse(json.to_string(encode(value)), decoder)
  let assert True = decoded == value
}

pub fn builders_round_trip_test() {
  let blocks = [
    block.header("Hello", [header.block_id("hello")]),
    block.section(block.mrkdwn("*bold*"), [
      section.fields([block.text("a"), block.mrkdwn("b")]),
    ]),
    block.divider([]),
    block.context(
      [
        block.context_mrkdwn("ctx"),
        block.context_image(image_url: "https://x/y.png", alt_text: "y"),
      ],
      [],
    ),
    block.actions(
      [
        element.button("Go", "go", [
          button.value("v1.2"),
          button.style(block.Primary),
          button.confirm(block.confirmation_dialog(
            title: "Sure?",
            text: block.text("Really"),
            confirm: "Yes",
            deny: "No",
          )),
        ]),
        element.button("Docs", "docs", [button.url("https://docs.slack.dev")]),
        element.static_select("pick", [
          static_select.options([
            block.option("One", "1"),
            block.option("Two", "2"),
          ]),
          static_select.placeholder("Pick one"),
          static_select.focus_on_load(True),
        ]),
        element.overflow("more", [block.option("A", "a")], []),
        element.datepicker("date", [datepicker.initial_date("2024-01-02")]),
      ],
      [],
    ),
    block.input("Name", element.plain_text_input("name", []), [
      input.hint("Your name"),
      input.optional(True),
    ]),
    block.input(
      "Bio",
      element.plain_text_input("bio", [
        plain_text_input.multiline(True),
        plain_text_input.initial_value("hi"),
      ]),
      [],
    ),
    block.input("Who", element.users_select("who", []), []),
    block.image("y", [image.image_url("https://x/y.png"), image.title("Y")]),
    block.markdown("**hi**", []),
    block.rich_text(
      [block.rich_text_section([block.rich_text_run("plain")])],
      [],
    ),
  ]
  round_trip(
    blocks,
    json.array(_, block.block_to_json),
    decode.list(block.block_decoder()),
  )
}

pub fn builder_sets_attributes_test() {
  let section =
    block.section(block.mrkdwn("Pick"), [
      section.block_id("intro"),
      section.accessory(element.button("Go", "go", [])),
    ])
  round_trip(section, block.block_to_json, block.block_decoder())
  let assert "{\"type\":\"section\",\"text\":{\"type\":\"mrkdwn\",\"text\":\"Pick\"},\"block_id\":\"intro\",\"accessory\":{\"type\":\"button\",\"text\":{\"type\":\"plain_text\",\"text\":\"Go\"},\"action_id\":\"go\"}}" =
    json.to_string(block.block_to_json(section))
}

pub fn select_with_option_groups_leaves_out_options_test() {
  let select =
    element.static_select("pick", [
      static_select.option_groups([
        block.option_group("Group", [block.option("One", "1")]),
      ]),
    ])
  round_trip(select, block.element_to_json, block.element_decoder())
  let assert "{\"type\":\"static_select\",\"action_id\":\"pick\",\"option_groups\":[{\"label\":{\"type\":\"plain_text\",\"text\":\"Group\"},\"options\":[{\"text\":{\"type\":\"plain_text\",\"text\":\"One\"},\"value\":\"1\"}]}]}" =
    json.to_string(block.element_to_json(select))
  let multi =
    element.multi_static_select("many", [
      multi_static_select.options([block.option("A", "a")]),
    ])
  let assert "{\"type\":\"multi_static_select\",\"action_id\":\"many\",\"options\":[{\"text\":{\"type\":\"plain_text\",\"text\":\"A\"},\"value\":\"a\"}]}" =
    json.to_string(block.element_to_json(multi))
}

pub fn image_takes_url_or_slack_file_test() {
  let assert "{\"type\":\"image\",\"alt_text\":\"y\",\"slack_file\":{\"id\":\"F1\"}}" =
    json.to_string(
      block.element_to_json(
        element.image("y", [
          element_image.slack_file(block.SlackFile(url: None, id: Some("F1"))),
        ]),
      ),
    )
  let assert "{\"type\":\"image\",\"alt_text\":\"y\",\"image_url\":\"https://x/y.png\"}" =
    json.to_string(
      block.block_to_json(
        block.image("y", [image.image_url("https://x/y.png")]),
      ),
    )
}

pub fn custom_attribute_test() {
  let assert block.Divider(block.DividerBlock(block_id: Some("d"))) =
    block.divider([
      block.attr(fn(_) { block.DividerBlock(block_id: Some("d")) }),
    ])
}

pub fn plain_text_encodes_type_test() {
  let assert "{\"type\":\"plain_text\",\"text\":\"Hi\"}" =
    json.to_string(block.plain_text_to_json(block.plain_text("Hi")))
}

pub fn unknown_block_keeps_raw_json_test() {
  let text = "{\"type\":\"future_block\",\"x\":1}"
  let assert Ok(block.UnknownBlock(type_: "future_block", raw: _) as unknown) =
    json.parse(text, block.block_decoder())
  let assert True = json.to_string(block.block_to_json(unknown)) == text
}

pub fn table_column_settings_allow_null_test() {
  let text =
    "{\"type\":\"table\",\"rows\":[[{\"type\":\"raw_text\",\"text\":\"a\"},{\"type\":\"raw_text\",\"text\":\"b\"}]],\"column_settings\":[null,{\"align\":\"right\"}]}"
  let assert Ok(
    block.Table(block.TableBlock(column_settings: Some(settings), ..)) as table,
  ) = json.parse(text, block.block_decoder())
  let assert [
    None,
    Some(block.ColumnSetting(align: Some(block.ColumnRight), is_wrapped: None)),
  ] = settings
  let assert True = json.to_string(block.block_to_json(table)) == text
}

pub fn one_record_per_text_object_test() {
  // The same `PlainText` record is a field type, a `Text` variant and a
  // context element, so it can be reused without converting.
  let label = block.plain_text("Hi")
  let assert "{\"type\":\"plain_text\",\"text\":\"Hi\"}" =
    json.to_string(block.text_to_json(block.PlainTextObject(label)))
  let assert "{\"type\":\"plain_text\",\"text\":\"Hi\"}" =
    json.to_string(block.context_element_to_json(block.ContextPlainText(label)))
}

pub fn rich_text_is_one_record_test() {
  let rich =
    block.rich_text_value([block.rich_text_section([block.rich_text_run("x")])])
  let expected =
    "{\"type\":\"rich_text\",\"elements\":[{\"type\":\"rich_text_section\",\"elements\":[{\"type\":\"text\",\"text\":\"x\"}]}]}"
  let assert True =
    json.to_string(block.block_to_json(block.RichTextBlock(rich))) == expected
  let assert True = json.to_string(block.rich_text_to_json(rich)) == expected
  let assert Ok(block.RichTextCell(cell)) =
    json.parse(expected, block.table_cell_decoder())
  let assert True = cell == rich
}
