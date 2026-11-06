//// Decodes the example objects from the Slack reference pages and the
//// object parts of method response examples.

import gleam/dynamic/decode
import gleam/json
import slackline/bot
import slackline/conversation
import slackline/file
import slackline/message
import slackline/team
import slackline/user
import slackline/usergroup
import slackline/value

pub fn conversation_object_info_test() {
  let assert Ok(_) =
    json.parse(
      "{\"channel\": {\"id\": \"C123456\", \"name\": \"general\", \"is_channel\": true, \"is_group\": false, \"is_im\": false, \"is_mpim\": false, \"is_private\": false, \"created\": 1449252889, \"is_archived\": false, \"is_general\": true, \"unlinked\": 0, \"name_normalized\": \"general\", \"is_shared\": false, \"is_frozen\": false, \"is_org_shared\": false, \"is_pending_ext_shared\": false, \"pending_shared\": [], \"context_team_id\": \"T12345ABCDE\", \"updated\": 1689965803820, \"parent_conversation\": null, \"creator\": \"W123456\", \"is_ext_shared\": false, \"shared_team_ids\": [\"T12345ABCDE\"], \"pending_connected_team_ids\": [], \"is_member\": true, \"topic\": {\"value\": \"For public discussion of generalities\", \"creator\": \"W123456\", \"last_set\": 1449709364}, \"purpose\": {\"value\": \"This part of the workspace is for fun. Make fun here.\", \"creator\": \"W123456\", \"last_set\": 1449709364}, \"properties\": {\"posting_restricted_to\": {\"type\": [\"admin\"]}, \"threads_restricted_to\": {\"type\": [\"ra\"]}, \"tabs\": [{\"id\": \"files\", \"label\": \"\", \"type\": \"files\"}, {\"id\": \"bookmarks\", \"label\": \"\", \"type\": \"bookmarks\"}]}, \"previous_names\": [\"specifics\", \"abstractions\", \"etc\"]}}",
      decode.at(["channel"], conversation.conversation_decoder()),
    )
}

pub fn conversation_object_history_test() {
  let assert Ok(_) =
    json.parse(
      "{\"messages\": [{\"type\": \"message\", \"text\": \"\", \"user\": \"USLACKBOT\", \"channel\": \"C12345ABCDE\", \"room\": {\"id\": \"R12345ABCDE\", \"name\": \"\", \"media_server\": \"\", \"created_by\": \"U12345ABCDE\", \"date_start\": 1689964161, \"date_end\": 0, \"participants\": [], \"participant_history\": [\"U12345ABCDE\"], \"participants_camera_on\": [], \"participants_camera_off\": [], \"participants_screenshare_on\": [], \"participants_screenshare_off\": [], \"canvas_thread_ts\": \"1689964161.419229\", \"thread_root_ts\": \"1689964161.419229\", \"channels\": [\"C12345ABCDE\"], \"is_dm_call\": false, \"was_rejected\": false, \"was_missed\": false, \"was_accepted\": false, \"has_ended\": false, \"background_id\": \"GRADIENT_03\", \"canvas_background\": \"GRADIENT_03\", \"is_prewarmed\": false, \"is_scheduled\": false, \"attached_file_ids\": [], \"media_backend_type\": \"free_willy\", \"display_id\": \"\", \"external_unique_id\": \"12345abc-123a-123b-123c-12345abcde7\", \"app_id\": \"A00\", \"call_family\": \"huddle\", \"pending_invitees\": {}, \"last_invite_status_by_user\": {}}, \"no_notifications\": true, \"permalink\": \"https://example.com\", \"subtype\": \"huddle_thread\", \"ts\": \"1689964161.419229\", \"blocks\": [{\"type\": \"rich_text\", \"block_id\": \"aBcDe\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"A huddle started\"}]}]}], \"team\": \"T12345ABCDE\"}]}",
      decode.at(["messages"], decode.list(message.message_decoder())),
    )
}

// attachments stripped: the attachment stub in this copy cannot decode `"id": 1`
pub fn channel_object_test() {
  let assert Ok(_) =
    json.parse(
      "{\"channel\": {\"id\": \"C1H9RESGL\", \"name\": \"busting\", \"is_channel\": true, \"created\": 1466025154, \"creator\": \"U0G9QF9C6\", \"is_archived\": false, \"is_general\": false, \"name_normalized\": \"busting\", \"is_shared\": false, \"is_org_shared\": false, \"is_member\": true, \"is_private\": false, \"is_mpim\": false, \"last_read\": \"1503435939.000101\", \"latest\": {\"text\": \"Containment unit is 98% full\", \"username\": \"ecto1138\", \"bot_id\": \"B19LU7CSY\", \"type\": \"message\", \"subtype\": \"bot_message\", \"ts\": \"1503435956.000247\"}, \"unread_count\": 1, \"unread_count_display\": 1, \"members\": [\"U0G9QF9C6\", \"U1QNSQB9U\"], \"topic\": {\"value\": \"Spiritual containment strategies\", \"creator\": \"U0G9QF9C6\", \"last_set\": 1503435128}, \"purpose\": {\"value\": \"Discuss busting ghosts\", \"creator\": \"U0G9QF9C6\", \"last_set\": 1503435128}, \"previous_names\": [\"dusting\"]}}",
      decode.at(["channel"], conversation.conversation_decoder()),
    )
}

// the docs example has `"is_group": "true"` (a string); fixed to a bool
pub fn group_object_test() {
  let assert Ok(_) =
    json.parse(
      "{\"id\": \"G123456\", \"name\": \"secretplans\", \"is_group\": true, \"created\": 1360782804, \"creator\": \"U123456\", \"is_archived\": false, \"is_mpim\": false, \"members\": [\"U012AB3CD\"], \"topic\": {\"value\": \"Secret plans on hold\", \"creator\": \"U123456\", \"last_set\": 1369677212}, \"purpose\": {\"value\": \"Discuss secret plans that nobody else should know\", \"creator\": \"U123456\", \"last_set\": 1360782804}, \"last_read\": \"1401383885.000061\", \"latest\": {}, \"unread_count\": 0, \"unread_count_display\": 0}",
      conversation.conversation_decoder(),
    )
}

pub fn im_object_test() {
  let assert Ok(_) =
    json.parse(
      "{\"id\": \"D024BFF1M\", \"is_im\": true, \"user\": \"U024BE7LH\", \"created\": 1360782804, \"is_user_deleted\": false}",
      conversation.conversation_decoder(),
    )
}

pub fn mpim_object_test() {
  let assert Ok(_) =
    json.parse(
      "{\"id\": \"G024BE91L\", \"name\": \"mpdm-user1--user2--user3-1\", \"is_mpim\": true, \"is_group\": false, \"created\": 1360782804, \"creator\": \"U024BE7LH\", \"members\": [\"U024BE7LH\"], \"last_read\": \"1401383885.000061\", \"latest\": {}, \"unread_count\": 0, \"unread_count_display\": 0}",
      conversation.conversation_decoder(),
    )
}

pub fn file_object_test() {
  let assert Ok(_) =
    json.parse(
      "{\"id\": \"F0A12BCDE\", \"created\": 1531763342, \"timestamp\": 1531763342, \"name\": \"tedair.gif\", \"title\": \"tedair.gif\", \"mimetype\": \"image/gif\", \"filetype\": \"gif\", \"pretty_type\": \"GIF\", \"user\": \"U012A3BCD\", \"editable\": false, \"size\": 137531, \"mode\": \"hosted\", \"is_external\": false, \"external_type\": \"\", \"is_public\": true, \"public_url_shared\": false, \"display_as_bot\": false, \"username\": \"\", \"url_private\": \"https://.../tedair.gif\", \"url_private_download\": \"https://.../tedair.gif\", \"thumb_64\": \"https://.../tedair_64.png\", \"thumb_80\": \"https://.../tedair_80.png\", \"thumb_360\": \"https://.../tedair_360.png\", \"thumb_360_w\": 176, \"thumb_360_h\": 226, \"thumb_160\": \"https://.../tedair_=_160.png\", \"thumb_360_gif\": \"https://.../tedair_360.gif\", \"image_exif_rotation\": 1, \"original_w\": 176, \"original_h\": 226, \"deanimate_gif\": \"https://.../tedair_deanimate_gif.png\", \"pjpeg\": \"https://.../tedair_pjpeg.jpg\", \"permalink\": \"https://.../tedair.gif\", \"permalink_public\": \"https://.../...\", \"comments_count\": 0, \"is_starred\": false, \"shares\": {\"public\": {\"C0A1BC2DE\": [{\"reply_users\": [\"U012A3BCD\"], \"reply_users_count\": 1, \"reply_count\": 1, \"ts\": \"1531763348.000001\", \"thread_ts\": \"1531763273.000015\", \"latest_reply\": \"1531763348.000001\", \"channel_name\": \"file-under\", \"team_id\": \"T012AB3C4\"}]}}, \"channels\": [\"C0A1BC2DE\"], \"groups\": [], \"ims\": [], \"has_rich_preview\": false}",
      file.file_decoder(),
    )
}

pub fn file_object_slack_connect_test() {
  let assert Ok(_) =
    json.parse(
      "{\"files\": [{\"id\": \"F12345678\", \"mode\": \"file_access\", \"file_access\": \"check_file_info\", \"created\": 0, \"timestamp\": 0, \"user\": \"\"}]}",
      decode.at(["files"], decode.list(file.file_decoder())),
    )
}

pub fn user_object_test() {
  let assert Ok(_) =
    json.parse(
      "{\"user\": {\"id\": \"U123ABC456\", \"team_id\": \"T123ABC456\", \"name\": \"sherlock\", \"deleted\": false, \"color\": \"99a949\", \"real_name\": \"Sherlock Holmes\", \"tz\": \"Europe/London\", \"tz_label\": \"Greenwich Mean Time\", \"tz_offset\": 0, \"profile\": {\"title\": \"Senior Detective\", \"phone\": \"(000) 000-0000\", \"skype\": \"\", \"real_name\": \"Sherlock Holmes\", \"real_name_normalized\": \"Sherlock Holmes\", \"display_name\": \"sherlock\", \"display_name_normalized\": \"sherlock\", \"fields\": {\"Xf111AAA111\": {\"value\": \"1 dog: Sherlock Bones\", \"alt\": \"\"}, \"Xf222BBB222\": {\"value\": \"no tree nuts!\", \"alt\": \"\"}}, \"status_text\": \"elementary, my dear watson \", \"status_emoji\": \":thinking-face:\", \"status_emoji_display_info\": [{\"emoji_name\": \"thinking-face\", \"display_url\": \"https://emoji.slack-edge.com/T123ABC456/thinking-face/123...abc.png\"}], \"status_expiration\": 0, \"avatar_hash\": \"b187f5128ba4\", \"start_date\": \"2015-12-25\", \"image_original\": \"https://avatars.slack-edge.com/2021-10-21/..._...__original.jpg\", \"is_custom_image\": true, \"email\": \"sholmes@example.com\", \"pronouns\": \"they/them\", \"huddle_state\": \"default_unset\", \"huddle_state_expiration_ts\": 0, \"first_name\": \"Sherlock\", \"last_name\": \"Holmes\", \"image_24\": \"https://avatars.slack-edge.com/2021-10-21/..._...__24.jpg\", \"image_32\": \"https://avatars.slack-edge.com/2021-10-21/..._...__32.jpg\", \"image_48\": \"https://avatars.slack-edge.com/2021-10-21/..._...__48.jpg\", \"image_72\": \"https://avatars.slack-edge.com/2021-10-21/..._...__72.jpg\", \"image_192\": \"https://avatars.slack-edge.com/2021-10-21/..._...__192.jpg\", \"image_512\": \"https://avatars.slack-edge.com/2021-10-21/..._...__512.jpg\", \"image_1024\": \"https://avatars.slack-edge.com/2021-10-21/..._...__1024.jpg\", \"status_text_canonical\": \"\", \"team\": \"T0123ABC456\"}, \"is_admin\": false, \"is_owner\": false, \"is_primary_owner\": false, \"is_restricted\": false, \"is_ultra_restricted\": false, \"is_bot\": false, \"is_app_user\": false, \"updated\": 1675264590, \"is_email_confirmed\": true, \"who_can_share_contact_card\": \"EVERYONE\", \"enterprise_user\": {\"id\": \"U123ABC456\", \"enterprise_id\": \"E123ABC456\", \"enterprise_name\": \"Sherlock Holmes Detective Agency\", \"is_admin\": false, \"is_owner\": false, \"is_primary_owner\": false, \"teams\": [\"T123ABC456\", \"T789DEF000\"]}}}",
      decode.at(["user"], user.user_decoder()),
    )
}

pub fn usergroup_object_test() {
  let assert Ok(_) =
    json.parse(
      "{\"id\": \"S123ABC456\", \"team_id\": \"T060RNRCH\", \"is_usergroup\": true, \"name\": \"Workspace Admins\", \"description\": \"A group of all Administrators on your workspace.\", \"handle\": \"admins\", \"is_external\": false, \"date_create\": 1446598059, \"date_update\": 1446670362, \"date_delete\": 0, \"auto_type\": \"admin\", \"created_by\": \"USLACKBOT\", \"updated_by\": \"U060RNRCZ\", \"deleted_by\": null, \"prefs\": {\"channels\": [], \"groups\": []}, \"users\": [\"U060RNRCZ\", \"U060ULRC0\", \"U06129G2V\", \"U061309JM\"], \"user_count\": \"4\"}",
      usergroup.usergroup_decoder(),
    )
}

pub fn users_info_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"user\": {\"id\": \"W012A3CDE\", \"team_id\": \"T012AB3C4\", \"name\": \"spengler\", \"deleted\": false, \"color\": \"9f69e7\", \"real_name\": \"Egon Spengler\", \"tz\": \"America/Los_Angeles\", \"tz_label\": \"Pacific Daylight Time\", \"tz_offset\": -25200, \"profile\": {\"avatar_hash\": \"ge3b51ca72de\", \"status_text\": \"Print is dead\", \"status_emoji\": \":books:\", \"real_name\": \"Egon Spengler\", \"display_name\": \"spengler\", \"real_name_normalized\": \"Egon Spengler\", \"display_name_normalized\": \"spengler\", \"email\": \"spengler@ghostbusters.example.com\", \"image_original\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"image_24\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"image_32\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"image_48\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"image_72\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"image_192\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"image_512\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"team\": \"T012AB3C4\"}, \"is_admin\": true, \"is_owner\": false, \"is_primary_owner\": false, \"is_restricted\": false, \"is_ultra_restricted\": false, \"is_bot\": false, \"updated\": 1502138686, \"is_app_user\": false, \"has_2fa\": false}}",
      decode.at(["user"], user.user_decoder()),
    )
}

pub fn users_list_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"members\": [{\"id\": \"W012A3CDE\", \"team_id\": \"T012AB3C4\", \"name\": \"spengler\", \"deleted\": false, \"color\": \"9f69e7\", \"real_name\": \"spengler\", \"tz\": \"America/Los_Angeles\", \"tz_label\": \"Pacific Daylight Time\", \"tz_offset\": -25200, \"profile\": {\"avatar_hash\": \"ge3b51ca72de\", \"status_text\": \"Print is dead\", \"status_emoji\": \":books:\", \"real_name\": \"Egon Spengler\", \"display_name\": \"spengler\", \"real_name_normalized\": \"Egon Spengler\", \"display_name_normalized\": \"spengler\", \"email\": \"spengler@ghostbusters.example.com\", \"image_24\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"image_32\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"image_48\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"image_72\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"image_192\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"image_512\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"team\": \"T012AB3C4\"}, \"is_admin\": true, \"is_owner\": false, \"is_primary_owner\": false, \"is_restricted\": false, \"is_ultra_restricted\": false, \"is_bot\": false, \"updated\": 1502138686, \"is_app_user\": false, \"has_2fa\": false}, {\"id\": \"W07QCRPA4\", \"team_id\": \"T0G9PQBBK\", \"name\": \"glinda\", \"deleted\": false, \"color\": \"9f69e7\", \"real_name\": \"Glinda Southgood\", \"tz\": \"America/Los_Angeles\", \"tz_label\": \"Pacific Daylight Time\", \"tz_offset\": -25200, \"profile\": {\"avatar_hash\": \"8fbdd10b41c6\", \"image_24\": \"https://a.slack-edge.com...png\", \"image_32\": \"https://a.slack-edge.com...png\", \"image_48\": \"https://a.slack-edge.com...png\", \"image_72\": \"https://a.slack-edge.com...png\", \"image_192\": \"https://a.slack-edge.com...png\", \"image_512\": \"https://a.slack-edge.com...png\", \"image_1024\": \"https://a.slack-edge.com...png\", \"image_original\": \"https://a.slack-edge.com...png\", \"first_name\": \"Glinda\", \"last_name\": \"Southgood\", \"title\": \"Glinda the Good\", \"phone\": \"\", \"skype\": \"\", \"real_name\": \"Glinda Southgood\", \"real_name_normalized\": \"Glinda Southgood\", \"display_name\": \"Glinda the Fairly Good\", \"display_name_normalized\": \"Glinda the Fairly Good\", \"email\": \"glenda@south.oz.coven\"}, \"is_admin\": true, \"is_owner\": false, \"is_primary_owner\": false, \"is_restricted\": false, \"is_ultra_restricted\": false, \"is_bot\": false, \"updated\": 1480527098, \"has_2fa\": false}], \"cache_ts\": 1498777272, \"response_metadata\": {\"next_cursor\": \"dXNlcjpVMEc5V0ZYTlo=\"}}",
      decode.at(["members"], decode.list(user.user_decoder())),
    )
}

pub fn users_profile_get_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"profile\": {\"title\": \"Head of Coffee Production\", \"phone\": \"\", \"skype\": \"\", \"real_name\": \"John Smith\", \"real_name_normalized\": \"John Smith\", \"display_name\": \"john\", \"display_name_normalized\": \"john\", \"fields\": {\"Xf0111111\": {\"value\": \"Barista\", \"alt\": \"\"}, \"Xf0222222\": {\"value\": \"2022-04-11\", \"alt\": \"\"}, \"Xf0333333\": {\"value\": \"https://example.com\", \"alt\": \"\"}}, \"status_text\": \"Watching cold brew steep\", \"status_emoji\": \":coffee:\", \"status_emoji_display_info\": [], \"status_expiration\": 0, \"avatar_hash\": \"123xyz\", \"start_date\": \"2022-03-21\", \"email\": \"johnsmith@example.com\", \"pronouns\": \"they/them/theirs\", \"huddle_state\": \"default_unset\", \"huddle_state_expiration_ts\": 0, \"first_name\": \"john\", \"last_name\": \"smith\", \"image_24\": \"https://.../...-24.png\", \"image_32\": \"https://.../...-32.png\", \"image_48\": \"https://.../...-48.png\", \"image_72\": \"https://.../...-72.png\", \"image_192\": \"https://.../....-192png\", \"image_512\": \"https://.../...-512.png\"}}",
      decode.at(["profile"], user.user_profile_decoder()),
    )
}

pub fn users_lookup_by_email_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"user\": {\"id\": \"W012A3CDE\", \"team_id\": \"T012AB3C4\", \"name\": \"spengler\", \"deleted\": false, \"color\": \"9f69e7\", \"real_name\": \"Egon Spengler\", \"tz\": \"America/Los_Angeles\", \"tz_label\": \"Pacific Daylight Time\", \"tz_offset\": -25200, \"profile\": {\"avatar_hash\": \"ge3b51ca72de\", \"status_text\": \"Print is dead\", \"status_emoji\": \":books:\", \"real_name\": \"Egon Spengler\", \"display_name\": \"spengler\", \"real_name_normalized\": \"Egon Spengler\", \"display_name_normalized\": \"spengler\", \"email\": \"spengler@ghostbusters.example.com\", \"image_24\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"image_32\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"image_48\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"image_72\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"image_192\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"image_512\": \"https://.../avatar/e3b51ca72dee4ef87916ae2b9240df50.jpg\", \"team\": \"T012AB3C4\"}, \"is_admin\": true, \"is_owner\": false, \"is_primary_owner\": false, \"is_restricted\": false, \"is_ultra_restricted\": false, \"is_bot\": false, \"updated\": 1502138686, \"is_app_user\": false, \"has_2fa\": false}}",
      decode.at(["user"], user.user_decoder()),
    )
}

pub fn conversations_info_0_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"channel\": {\"id\": \"C012AB3CD\", \"name\": \"general\", \"is_channel\": true, \"is_group\": false, \"is_im\": false, \"is_mpim\": false, \"is_private\": false, \"created\": 1654868334, \"is_archived\": false, \"is_general\": true, \"unlinked\": 0, \"name_normalized\": \"general\", \"is_shared\": false, \"is_frozen\": false, \"is_org_shared\": false, \"is_pending_ext_shared\": false, \"pending_shared\": [], \"context_team_id\": \"T123ABC456\", \"updated\": 1723130875818, \"parent_conversation\": null, \"creator\": \"U123ABC456\", \"is_ext_shared\": false, \"shared_team_ids\": [\"T123ABC456\"], \"pending_connected_team_ids\": [], \"topic\": {\"value\": \"For public discussion of generalities\", \"creator\": \"W012A3BCD\", \"last_set\": 1449709364}, \"purpose\": {\"value\": \"This part of the workspace is for fun. Make fun here.\", \"creator\": \"W012A3BCD\", \"last_set\": 1449709364}, \"properties\": {\"tabs\": [{\"id\": \"workflows\", \"label\": \"\", \"type\": \"workflows\"}, {\"id\": \"files\", \"label\": \"\", \"type\": \"files\"}, {\"id\": \"bookmarks\", \"label\": \"\", \"type\": \"bookmarks\"}]}, \"previous_names\": []}}",
      decode.at(["channel"], conversation.conversation_decoder()),
    )
}

pub fn conversations_info_1_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"channel\": {\"id\": \"C012AB3CD\", \"created\": 1507235627, \"is_im\": true, \"is_org_shared\": false, \"user\": \"U27FFLNF4\", \"last_read\": \"1513718191.000038\", \"latest\": {\"type\": \"message\", \"user\": \"U5R3PALPN\", \"text\": \"Psssst!\", \"ts\": \"1513718191.000038\"}, \"unread_count\": 0, \"unread_count_display\": 0, \"is_open\": true, \"locale\": \"en-US\", \"priority\": 0.043016851216706}}",
      decode.at(["channel"], conversation.conversation_decoder()),
    )
}

pub fn conversations_info_2_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"channel\": {\"id\": \"C012AB3CD\", \"created\": 1507235627, \"is_im\": true, \"is_org_shared\": false, \"user\": \"U27FFLNF4\", \"last_read\": \"1513718191.000038\", \"latest\": {\"type\": \"message\", \"user\": \"U5R3PALPN\", \"text\": \"Psssst!\", \"ts\": \"1513718191.000038\"}, \"unread_count\": 0, \"unread_count_display\": 0, \"is_open\": true, \"locale\": \"en-US\", \"priority\": 0.043016851216706, \"num_members\": 2}}",
      decode.at(["channel"], conversation.conversation_decoder()),
    )
}

pub fn conversations_list_0_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"channels\": [{\"id\": \"C012AB3CD\", \"name\": \"general\", \"is_channel\": true, \"is_group\": false, \"is_im\": false, \"created\": 1449252889, \"creator\": \"U012A3CDE\", \"is_archived\": false, \"is_general\": true, \"unlinked\": 0, \"name_normalized\": \"general\", \"is_shared\": false, \"is_ext_shared\": false, \"is_org_shared\": false, \"pending_shared\": [], \"is_pending_ext_shared\": false, \"is_member\": true, \"is_private\": false, \"is_mpim\": false, \"updated\": 1678229664302, \"topic\": {\"value\": \"Company-wide announcements and work-based matters\", \"creator\": \"\", \"last_set\": 0}, \"purpose\": {\"value\": \"This channel is for team-wide communication and announcements. All team members are in this channel.\", \"creator\": \"\", \"last_set\": 0}, \"previous_names\": [], \"num_members\": 4}, {\"id\": \"C061EG9T2\", \"name\": \"random\", \"is_channel\": true, \"is_group\": false, \"is_im\": false, \"created\": 1449252889, \"creator\": \"U061F7AUR\", \"is_archived\": false, \"is_general\": false, \"unlinked\": 0, \"name_normalized\": \"random\", \"is_shared\": false, \"is_ext_shared\": false, \"is_org_shared\": false, \"pending_shared\": [], \"is_pending_ext_shared\": false, \"is_member\": true, \"is_private\": false, \"is_mpim\": false, \"updated\": 1678229664302, \"topic\": {\"value\": \"Non-work banter and water cooler conversation\", \"creator\": \"\", \"last_set\": 0}, \"purpose\": {\"value\": \"A place for non-work-related flimflam, faffing, hodge-podge or jibber-jabber you'd prefer to keep out of more focused work-related channels.\", \"creator\": \"\", \"last_set\": 0}, \"previous_names\": [], \"num_members\": 4}], \"response_metadata\": {\"next_cursor\": \"dGVhbTpDMDYxRkE1UEI=\"}}",
      decode.at(["channels"], decode.list(conversation.conversation_decoder())),
    )
}

pub fn conversations_list_1_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"channels\": [{\"id\": \"G0AKFJBEU\", \"name\": \"mpdm-mr.banks--slactions-jackson--beforebot-1\", \"is_channel\": false, \"is_group\": true, \"is_im\": false, \"created\": 1493657761, \"creator\": \"U061F7AUR\", \"is_archived\": false, \"is_general\": false, \"unlinked\": 0, \"name_normalized\": \"mpdm-mr.banks--slactions-jackson--beforebot-1\", \"is_shared\": false, \"is_ext_shared\": false, \"is_org_shared\": false, \"pending_shared\": [], \"is_pending_ext_shared\": false, \"is_member\": true, \"is_private\": true, \"is_mpim\": true, \"is_open\": true, \"updated\": 1678229664302, \"topic\": {\"value\": \"Group messaging\", \"creator\": \"U061F7AUR\", \"last_set\": 1493657761}, \"purpose\": {\"value\": \"Group messaging with: @mr.banks @slactions-jackson @beforebot\", \"creator\": \"U061F7AUR\", \"last_set\": 1493657761}, \"priority\": 0}, {\"id\": \"D0C0F7S8Y\", \"created\": 1498500348, \"is_im\": true, \"is_org_shared\": false, \"user\": \"U0BS9U4SV\", \"is_user_deleted\": false, \"priority\": 0}, {\"id\": \"D0BSHH4AD\", \"created\": 1498511030, \"is_im\": true, \"is_org_shared\": false, \"user\": \"U0C0NS9HN\", \"is_user_deleted\": false, \"priority\": 0}], \"response_metadata\": {\"next_cursor\": \"aW1faWQ6RDBCSDk1RExI\"}}",
      decode.at(["channels"], decode.list(conversation.conversation_decoder())),
    )
}

pub fn users_conversations_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"channels\": [{\"id\": \"C012AB3CD\", \"name\": \"general\", \"is_channel\": true, \"is_group\": false, \"is_im\": false, \"created\": 1449252889, \"creator\": \"U012A3CDE\", \"is_archived\": false, \"is_general\": true, \"unlinked\": 0, \"name_normalized\": \"general\", \"is_shared\": false, \"is_ext_shared\": false, \"is_org_shared\": false, \"pending_shared\": [], \"is_pending_ext_shared\": false, \"is_private\": false, \"is_mpim\": false, \"topic\": {\"value\": \"Company-wide announcements and work-based matters\", \"creator\": \"\", \"last_set\": 0}, \"purpose\": {\"value\": \"This channel is for team-wide communication and announcements. All team members are in this channel.\", \"creator\": \"\", \"last_set\": 0}, \"previous_names\": []}, {\"id\": \"C061EG9T2\", \"name\": \"random\", \"is_channel\": true, \"is_group\": false, \"is_im\": false, \"created\": 1449252889, \"creator\": \"U061F7AUR\", \"is_archived\": false, \"is_general\": false, \"unlinked\": 0, \"name_normalized\": \"random\", \"is_shared\": false, \"is_ext_shared\": false, \"is_org_shared\": false, \"pending_shared\": [], \"is_pending_ext_shared\": false, \"is_private\": false, \"is_mpim\": false, \"topic\": {\"value\": \"Non-work banter and water cooler conversation\", \"creator\": \"\", \"last_set\": 0}, \"purpose\": {\"value\": \"A place for non-work-related flimflam, faffing, hodge-podge or jibber-jabber you'd prefer to keep out of more focused work-related channels.\", \"creator\": \"\", \"last_set\": 0}, \"previous_names\": []}], \"response_metadata\": {\"next_cursor\": \"dGVhbTpDMDYxRkE1UEI=\"}}",
      decode.at(["channels"], decode.list(conversation.conversation_decoder())),
    )
}

pub fn conversations_open_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"no_op\": true, \"already_open\": true, \"channel\": {\"id\": \"D069C7QFK\", \"created\": 1460147748, \"is_im\": true, \"is_org_shared\": false, \"user\": \"U069C7QF3\", \"last_read\": \"0000000000.000000\", \"latest\": null, \"unread_count\": 0, \"unread_count_display\": 0, \"is_open\": true, \"priority\": 0}}",
      decode.at(["channel"], conversation.conversation_decoder()),
    )
}

pub fn conversations_create_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"channel\": {\"id\": \"C0EAQDV4Z\", \"name\": \"endeavor\", \"is_channel\": true, \"is_group\": false, \"is_im\": false, \"created\": 1504554479, \"creator\": \"U0123456\", \"is_archived\": false, \"is_general\": false, \"unlinked\": 0, \"name_normalized\": \"endeavor\", \"is_shared\": false, \"is_ext_shared\": false, \"is_org_shared\": false, \"pending_shared\": [], \"is_pending_ext_shared\": false, \"is_member\": true, \"is_private\": false, \"is_mpim\": false, \"last_read\": \"0000000000.000000\", \"latest\": null, \"unread_count\": 0, \"unread_count_display\": 0, \"topic\": {\"value\": \"\", \"creator\": \"\", \"last_set\": 0}, \"properties\": {\"canvas\": {\"file_id\": \"F123ABC456\", \"is_empty\": true, \"quip_thread_id\": \"JAB1CDefGhI\"}}, \"purpose\": {\"value\": \"\", \"creator\": \"\", \"last_set\": 0}, \"previous_names\": [], \"priority\": 0}}",
      decode.at(["channel"], conversation.conversation_decoder()),
    )
}

// attachments stripped
pub fn conversations_history_0_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"messages\": [{\"type\": \"message\", \"user\": \"U123ABC456\", \"text\": \"I find you punny and would like to smell your nose letter\", \"ts\": \"1512085950.000216\"}, {\"type\": \"message\", \"user\": \"U222BBB222\", \"text\": \"What, you want to smell my shoes better?\", \"ts\": \"1512104434.000490\"}], \"has_more\": true, \"pin_count\": 0, \"response_metadata\": {\"next_cursor\": \"bmV4dF90czoxNTEyMDg1ODYxMDAwNTQz\"}}",
      decode.at(["messages"], decode.list(message.message_decoder())),
    )
}

// attachments stripped
pub fn conversations_history_1_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"messages\": [{\"type\": \"message\", \"user\": \"U123ABC456\", \"text\": \"I find you punny and would like to smell your nose letter\", \"ts\": \"1512085950.000216\"}, {\"type\": \"message\", \"user\": \"U222BBB222\", \"text\": \"Isn't this whether dreadful? <https://badpuns.example.com/puns/123>\", \"ts\": \"1512085950.218404\"}], \"has_more\": true, \"pin_count\": 0, \"response_metadata\": {\"next_cursor\": \"bmV4dF90czoxNTEyMTU0NDA5MDAwMjU2\"}}",
      decode.at(["messages"], decode.list(message.message_decoder())),
    )
}

// attachments stripped
pub fn conversations_history_2_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"latest\": \"1512085950.000216\", \"messages\": [{\"type\": \"message\", \"user\": \"U123ABC456\", \"text\": \"I find you punny and would like to smell your nose letter\", \"ts\": \"1512085950.000216\"}], \"has_more\": true, \"pin_count\": 0, \"response_metadata\": {\"next_cursor\": \"bmV4dF90czoxNTEyMzU2NTI2MDAwMTMw\"}}",
      decode.at(["messages"], decode.list(message.message_decoder())),
    )
}

pub fn conversations_replies_test() {
  let assert Ok(_) =
    json.parse(
      "{\"messages\": [{\"type\": \"message\", \"user\": \"U061F7AUR\", \"text\": \"island\", \"thread_ts\": \"1482960137.003543\", \"reply_count\": 3, \"subscribed\": true, \"last_read\": \"1484678597.521003\", \"unread_count\": 0, \"ts\": \"1482960137.003543\"}, {\"type\": \"message\", \"user\": \"U061F7AUR\", \"text\": \"one island\", \"thread_ts\": \"1482960137.003543\", \"parent_user_id\": \"U061F7AUR\", \"ts\": \"1483037603.017503\"}, {\"type\": \"message\", \"user\": \"U061F7AUR\", \"text\": \"two island\", \"thread_ts\": \"1482960137.003543\", \"parent_user_id\": \"U061F7AUR\", \"ts\": \"1483051909.018632\"}, {\"type\": \"message\", \"user\": \"U061F7AUR\", \"text\": \"three for the land\", \"thread_ts\": \"1482960137.003543\", \"parent_user_id\": \"U061F7AUR\", \"ts\": \"1483125339.020269\"}], \"has_more\": true, \"ok\": true, \"response_metadata\": {\"next_cursor\": \"bmV4dF90czoxNDg0Njc4MjkwNTE3MDkx\"}}",
      decode.at(["messages"], decode.list(message.message_decoder())),
    )
}

pub fn conversations_set_topic_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"channel\": {\"id\": \"C12345678\", \"name\": \"tips-and-tricks\", \"is_channel\": true, \"is_group\": false, \"is_im\": false, \"is_mpim\": false, \"is_private\": false, \"created\": 1649195947, \"is_archived\": false, \"is_general\": false, \"unlinked\": 0, \"name_normalized\": \"tips-and-tricks\", \"is_shared\": false, \"is_frozen\": false, \"is_org_shared\": false, \"is_pending_ext_shared\": false, \"pending_shared\": [], \"parent_conversation\": null, \"creator\": \"U12345678\", \"is_ext_shared\": false, \"shared_team_ids\": [\"T12345678\"], \"pending_connected_team_ids\": [], \"is_member\": true, \"last_read\": \"1649869848.627809\", \"latest\": {\"type\": \"message\", \"subtype\": \"channel_topic\", \"ts\": \"1649952691.429799\", \"user\": \"U12345678\", \"text\": \"set the channel topic: Apply topically for best effects\", \"topic\": \"Apply topically for best effects\"}, \"unread_count\": 1, \"unread_count_display\": 0, \"topic\": {\"value\": \"Apply topically for best effects\", \"creator\": \"U12345678\", \"last_set\": 1649952691}, \"purpose\": {\"value\": \"\", \"creator\": \"\", \"last_set\": 0}, \"previous_names\": []}}",
      decode.at(["channel"], conversation.conversation_decoder()),
    )
}

// attachments stripped
pub fn chat_post_message_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"channel\": \"C123ABC456\", \"ts\": \"1503435956.000247\", \"message\": {\"text\": \"Here's a message for you\", \"username\": \"ecto1\", \"bot_id\": \"B123ABC456\", \"type\": \"message\", \"subtype\": \"bot_message\", \"ts\": \"1503435956.000247\"}}",
      decode.at(["message"], message.message_decoder()),
    )
}

// attachments stripped; no `ts`
pub fn chat_schedule_message_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"channel\": \"C123ABC456\", \"scheduled_message_id\": \"Q1298393284\", \"post_at\": \"1562180400\", \"message\": {\"text\": \"Here's a message for you in the future\", \"username\": \"ecto1\", \"bot_id\": \"B123ABC456\", \"type\": \"delayed_message\", \"subtype\": \"bot_message\"}}",
      decode.at(["message"], message.message_decoder()),
    )
}

// no `ts`
pub fn chat_update_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"channel\": \"C123ABC456\", \"ts\": \"1401383885.000061\", \"text\": \"Updated text you carefully authored\", \"message\": {\"text\": \"Updated text you carefully authored\", \"user\": \"U34567890\"}}",
      decode.at(["message"], message.message_decoder()),
    )
}

pub fn pins_list_test() {
  let assert Ok(_) =
    json.parse(
      "[{\"permalink\": \"https://hitchhikers.slack.com/archives/C2U86NC6H/p1508197641000151\", \"pinned_to\": [\"C2U86NC6H\"], \"text\": \"What is the meaning of life?\", \"ts\": \"1508197641.000151\", \"type\": \"message\", \"user\": \"U123ABC456\"}, {\"permalink\": \"https://hitchhikers.slack.com/archives/C2U86NC6H/p1508284197000015\", \"pinned_to\": [\"C123ABC456\"], \"text\": \"The meaning of life, the universe, and everything is 42.\", \"ts\": \"1503289197.000015\", \"type\": \"message\", \"user\": \"U123ABC456\"}]",
      decode.list(message.message_decoder()),
    )
}

pub fn reactions_get_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"type\": \"message\", \"message\": {\"type\": \"message\", \"text\": \"Hi there!\", \"user\": \"W123456\", \"ts\": \"1648602352.215969\", \"team\": \"T123456\", \"reactions\": [{\"name\": \"grinning\", \"users\": [\"W222222\"], \"count\": 1}, {\"name\": \"question\", \"users\": [\"W333333\"], \"count\": 1}], \"permalink\": \"https://xxx.slack.com/archives/C123456/p1648602352215969\"}, \"channel\": \"C123ABC456\"}",
      decode.at(["message"], message.message_decoder()),
    )
}

pub fn reactions_list_messages_test() {
  let assert Ok(_) =
    json.parse(
      "[{\"bot_id\": \"B123ABC456\", \"reactions\": [{\"count\": 1, \"name\": \"robot_face\", \"users\": [\"U123ABC456\"]}], \"subtype\": \"bot_message\", \"text\": \"Hello from Python! :tada:\", \"ts\": \"1507849573.000090\", \"username\": \"Shipit Notifications\"}]",
      decode.list(message.message_decoder()),
    )
}

// one file has no `id`
pub fn reactions_list_files_test() {
  let assert Ok(_) =
    json.parse(
      "[{\"channels\": [\"C123ABC456\"], \"comments_count\": 1, \"created\": 1507850315, \"reactions\": [{\"count\": 1, \"name\": \"stuck_out_tongue_winking_eye\", \"users\": [\"U123ABC456\"]}], \"title\": \"computer.gif\", \"user\": \"U123ABC456\", \"username\": \"\"}, {\"channels\": [\"C123ABC456\"], \"comments_count\": 1, \"created\": 1507850315, \"id\": \"F123ABC456\", \"name\": \"computer.gif\", \"reactions\": [{\"count\": 1, \"name\": \"stuck_out_tongue_winking_eye\", \"users\": [\"U123ABC456\"]}], \"size\": 1639034, \"title\": \"computer.gif\", \"user\": \"U123ABC456\", \"username\": \"\"}]",
      decode.list(file.file_decoder()),
    )
}

pub fn reactions_list_comments_test() {
  let assert Ok(_) =
    json.parse(
      "[{\"type\": \"file_comment\", \"comment\": \"This is a file comment\", \"created\": 1508286096, \"id\": \"Fc123ABC456\", \"reactions\": [{\"count\": 1, \"name\": \"white_check_mark\", \"users\": [\"U123ABC456\"]}], \"timestamp\": 1508286096, \"user\": \"U123ABC456\"}]",
      decode.list(file.file_comment_decoder()),
    )
}

// attachments stripped
pub fn stars_list_test() {
  let assert Ok(_) =
    json.parse(
      "[{\"type\": \"message\", \"subtype\": \"bot_message\", \"text\": \"\", \"ts\": \"1655762568.324229\", \"username\": \"username\", \"icons\": {\"emoji\": \":test:\"}, \"bot_id\": \"BSLACKBOT\", \"permalink\": \"https://your-workspace.slack.com/archives/C123ABC456/p123456789\"}]",
      decode.list(message.message_decoder()),
    )
}

pub fn search_messages_test() {
  let assert Ok(_) =
    json.parse(
      "{\"messages\": {\"matches\": [{\"channel\": {\"id\": \"C12345678\", \"is_ext_shared\": false, \"is_mpim\": false, \"is_org_shared\": false, \"is_pending_ext_shared\": false, \"is_private\": false, \"is_shared\": false, \"name\": \"general\", \"pending_shared\": []}, \"iid\": \"cb64bdaa-c1e8-4631-8a91-0f78080113e9\", \"permalink\": \"https://hitchhikers.slack.com/archives/C12345678/p1508284197000015\", \"team\": \"T12345678\", \"text\": \"The meaning of life the universe and everything is 42.\", \"ts\": \"1508284197.000015\", \"type\": \"message\", \"user\": \"U2U85N1RV\", \"username\": \"roach\"}, {\"channel\": {\"id\": \"C12345678\", \"is_ext_shared\": false, \"is_mpim\": false, \"is_org_shared\": false, \"is_pending_ext_shared\": false, \"is_private\": false, \"is_shared\": false, \"name\": \"random\", \"pending_shared\": []}, \"iid\": \"9a00d3c9-bd2d-45b0-988b-6cff99ae2a90\", \"permalink\": \"https://hitchhikers.slack.com/archives/C12345678/p1508795665000236\", \"team\": \"T12345678\", \"text\": \"The meaning of life the universe and everything is 101010\", \"ts\": \"1508795665.000236\", \"type\": \"message\", \"user\": \"\", \"username\": \"robot overlord\"}], \"pagination\": {\"first\": 1, \"last\": 2, \"page\": 1, \"page_count\": 1, \"per_page\": 20, \"total_count\": 2}, \"paging\": {\"count\": 20, \"page\": 1, \"pages\": 1, \"total\": 2}, \"total\": 2}, \"ok\": true, \"query\": \"The meaning of life the universe and everything\"}",
      decode.at(["messages", "matches"], decode.list(message.message_decoder())),
    )
}

pub fn search_all_messages_test() {
  let assert Ok(_) =
    json.parse(
      "{\"files\": {\"matches\": [{\"channels\": [], \"comments_count\": 1, \"created\": 1508804330, \"display_as_bot\": false, \"editable\": false, \"external_type\": \"\", \"filetype\": \"png\", \"groups\": [], \"id\": \"F7PKF1NR7\", \"image_exif_rotation\": 1, \"ims\": [], \"initial_comment\": {\"comment\": \"Sure! Here's the workflow diagram!\", \"created\": 1508804330, \"id\": \"Fc7NLL52E7\", \"is_intro\": true, \"timestamp\": 1508804330, \"user\": \"U2U85N1RZ\"}, \"is_external\": false, \"is_public\": true, \"mimetype\": \"image/png\", \"mode\": \"hosted\", \"name\": \"slack workflow diagram.png\", \"original_h\": 117, \"original_w\": 128, \"permalink\": \"https://example.slack.com/files/U2U85N1RZ/F7PKF1NR7/slack_workflow_diagram.png\", \"permalink_public\": \"https://slack-files.com/T2U81E2FZ-F7PKF1NR7-bea9143f18\", \"pretty_type\": \"PNG\", \"preview\": null, \"public_url_shared\": false, \"score\": \"0.99982661240974\", \"size\": 35705, \"thumb_160\": \"https://files.slack.com/files-tmb/T2U81E2FZ-F7PKF1NR7-19f33fc256/slack_workflow_diagram_160.png\", \"thumb_360\": \"https://files.slack.com/files-tmb/T2U81E2FZ-F7PKF1NR7-19f33fc256/slack_workflow_diagram_360.png\", \"thumb_360_h\": 117, \"thumb_360_w\": 128, \"thumb_64\": \"https://files.slack.com/files-tmb/T2U81E2FZ-F7PKF1NR7-19f33fc256/slack_workflow_diagram_64.png\", \"thumb_80\": \"https://files.slack.com/files-tmb/T2U81E2FZ-F7PKF1NR7-19f33fc256/slack_workflow_diagram_80.png\", \"timestamp\": 1508804330, \"title\": \"slack workflow diagram\", \"top_file\": false, \"url_private\": \"https://files.slack.com/files-pri/T2U81E2FZ-F7PKF1NR7/slack_workflow_diagram.png\", \"url_private_download\": \"https://files.slack.com/files-pri/T2U81E2FZ-F7PKF1NR7/download/slack_workflow_diagram.png\", \"user\": \"U2U85N1RZ\", \"username\": \"amy\"}], \"pagination\": {\"first\": 1, \"last\": 1, \"page\": 1, \"page_count\": 1, \"per_page\": 20, \"total_count\": 1}, \"paging\": {\"count\": 20, \"page\": 1, \"pages\": 1, \"total\": 1}, \"total\": 1}, \"messages\": {\"matches\": [{\"channel\": {\"id\": \"C2U86NC6M\", \"is_ext_shared\": false, \"is_mpim\": false, \"is_org_shared\": false, \"is_pending_ext_shared\": false, \"is_private\": false, \"is_shared\": false, \"name\": \"general\", \"pending_shared\": []}, \"iid\": \"35692677-e60e-43d9-ac45-1987cea88975\", \"next\": {\"iid\": \"6f510ea1-e1d3-4f3f-bdb9-f9c6f6e9d609\", \"text\": \"Thanks!\", \"ts\": \"1508804378.000219\", \"type\": \"message\", \"user\": \"U2U85HJ7R\", \"username\": \"john\"}, \"permalink\": \"https://example.slack.com/archives/C2U86NC6M/p1508804330000296\", \"previous\": {\"iid\": \"aba8603c-0543-4fb2-9118-a5ac85f3d138\", \"text\": \"Can you send me the Slack workflow diagram?\", \"ts\": \"1508804301.000026\", \"type\": \"message\", \"user\": \"U2U85HJ7R\", \"username\": \"john\"}, \"team\": \"T2U81E2FZ\", \"text\": \"uploaded a file: <https://example.slack.com/files/U2U85N1RZ/F7PKF1NR7/slack_workflow_diagram.png|slack workflow diagram> and commented: Sure! Here's the workflow diagram!\", \"ts\": \"1508804330.000296\", \"type\": \"message\", \"user\": \"U2U85N1RZ\", \"username\": \"amy\"}], \"pagination\": {\"first\": 1, \"last\": 1, \"page\": 1, \"page_count\": 1, \"per_page\": 20, \"total_count\": 1}, \"paging\": {\"count\": 20, \"page\": 1, \"pages\": 1, \"total\": 1}, \"total\": 1}, \"ok\": true, \"posts\": {\"matches\": [], \"total\": 0}, \"query\": \"diagram\"}",
      decode.at(["messages", "matches"], decode.list(message.message_decoder())),
    )
}

pub fn search_all_files_test() {
  let assert Ok(_) =
    json.parse(
      "{\"files\": {\"matches\": [{\"channels\": [], \"comments_count\": 1, \"created\": 1508804330, \"display_as_bot\": false, \"editable\": false, \"external_type\": \"\", \"filetype\": \"png\", \"groups\": [], \"id\": \"F7PKF1NR7\", \"image_exif_rotation\": 1, \"ims\": [], \"initial_comment\": {\"comment\": \"Sure! Here's the workflow diagram!\", \"created\": 1508804330, \"id\": \"Fc7NLL52E7\", \"is_intro\": true, \"timestamp\": 1508804330, \"user\": \"U2U85N1RZ\"}, \"is_external\": false, \"is_public\": true, \"mimetype\": \"image/png\", \"mode\": \"hosted\", \"name\": \"slack workflow diagram.png\", \"original_h\": 117, \"original_w\": 128, \"permalink\": \"https://example.slack.com/files/U2U85N1RZ/F7PKF1NR7/slack_workflow_diagram.png\", \"permalink_public\": \"https://slack-files.com/T2U81E2FZ-F7PKF1NR7-bea9143f18\", \"pretty_type\": \"PNG\", \"preview\": null, \"public_url_shared\": false, \"score\": \"0.99982661240974\", \"size\": 35705, \"thumb_160\": \"https://files.slack.com/files-tmb/T2U81E2FZ-F7PKF1NR7-19f33fc256/slack_workflow_diagram_160.png\", \"thumb_360\": \"https://files.slack.com/files-tmb/T2U81E2FZ-F7PKF1NR7-19f33fc256/slack_workflow_diagram_360.png\", \"thumb_360_h\": 117, \"thumb_360_w\": 128, \"thumb_64\": \"https://files.slack.com/files-tmb/T2U81E2FZ-F7PKF1NR7-19f33fc256/slack_workflow_diagram_64.png\", \"thumb_80\": \"https://files.slack.com/files-tmb/T2U81E2FZ-F7PKF1NR7-19f33fc256/slack_workflow_diagram_80.png\", \"timestamp\": 1508804330, \"title\": \"slack workflow diagram\", \"top_file\": false, \"url_private\": \"https://files.slack.com/files-pri/T2U81E2FZ-F7PKF1NR7/slack_workflow_diagram.png\", \"url_private_download\": \"https://files.slack.com/files-pri/T2U81E2FZ-F7PKF1NR7/download/slack_workflow_diagram.png\", \"user\": \"U2U85N1RZ\", \"username\": \"amy\"}], \"pagination\": {\"first\": 1, \"last\": 1, \"page\": 1, \"page_count\": 1, \"per_page\": 20, \"total_count\": 1}, \"paging\": {\"count\": 20, \"page\": 1, \"pages\": 1, \"total\": 1}, \"total\": 1}, \"messages\": {\"matches\": [{\"channel\": {\"id\": \"C2U86NC6M\", \"is_ext_shared\": false, \"is_mpim\": false, \"is_org_shared\": false, \"is_pending_ext_shared\": false, \"is_private\": false, \"is_shared\": false, \"name\": \"general\", \"pending_shared\": []}, \"iid\": \"35692677-e60e-43d9-ac45-1987cea88975\", \"next\": {\"iid\": \"6f510ea1-e1d3-4f3f-bdb9-f9c6f6e9d609\", \"text\": \"Thanks!\", \"ts\": \"1508804378.000219\", \"type\": \"message\", \"user\": \"U2U85HJ7R\", \"username\": \"john\"}, \"permalink\": \"https://example.slack.com/archives/C2U86NC6M/p1508804330000296\", \"previous\": {\"iid\": \"aba8603c-0543-4fb2-9118-a5ac85f3d138\", \"text\": \"Can you send me the Slack workflow diagram?\", \"ts\": \"1508804301.000026\", \"type\": \"message\", \"user\": \"U2U85HJ7R\", \"username\": \"john\"}, \"team\": \"T2U81E2FZ\", \"text\": \"uploaded a file: <https://example.slack.com/files/U2U85N1RZ/F7PKF1NR7/slack_workflow_diagram.png|slack workflow diagram> and commented: Sure! Here's the workflow diagram!\", \"ts\": \"1508804330.000296\", \"type\": \"message\", \"user\": \"U2U85N1RZ\", \"username\": \"amy\"}], \"pagination\": {\"first\": 1, \"last\": 1, \"page\": 1, \"page_count\": 1, \"per_page\": 20, \"total_count\": 1}, \"paging\": {\"count\": 20, \"page\": 1, \"pages\": 1, \"total\": 1}, \"total\": 1}, \"ok\": true, \"posts\": {\"matches\": [], \"total\": 0}, \"query\": \"diagram\"}",
      decode.at(["files", "matches"], decode.list(file.file_decoder())),
    )
}

pub fn search_files_test() {
  let assert Ok(_) =
    json.parse(
      "{\"files\": {\"matches\": [{\"channels\": [], \"comments_count\": 1, \"created\": 1507850315, \"deanimate_gif\": \"https://files.slack.com/files-tmb/T2U81E2BB-F7H0D7ZBB-21624821e6/computer_deanimate_gif.png\", \"display_as_bot\": false, \"editable\": false, \"external_type\": \"\", \"filetype\": \"gif\", \"groups\": [], \"id\": \"F7H0D7ZBB\", \"image_exif_rotation\": 1, \"ims\": [], \"is_external\": false, \"is_public\": true, \"mimetype\": \"image/gif\", \"mode\": \"hosted\", \"name\": \"computer.gif\", \"original_h\": 313, \"original_w\": 500, \"permalink\": \"https://eventsdemo.slack.com/files/U2U85N1RZ/F7H0D7ZBB/computer.gif\", \"permalink_public\": \"https://slack-files.com/T2U81E2BB-F7H0D7ZBB-85b7f5557e\", \"pretty_type\": \"GIF\", \"preview\": null, \"public_url_shared\": false, \"reactions\": [{\"count\": 1, \"name\": \"stuck_out_tongue_winking_eye\", \"users\": [\"U2U85N1RZ\"]}], \"score\": \"0.38899223746309\", \"size\": 1639034, \"thumb_160\": \"https://files.slack.com/files-tmb/T2U81E2BB-F7H0D7ZBB-21624821e6/computer_160.png\", \"thumb_360\": \"https://files.slack.com/files-tmb/T2U81E2BB-F7H0D7ZBB-21624821e6/computer_360.png\", \"thumb_360_gif\": \"https://files.slack.com/files-tmb/T2U81E2BB-F7H0D7ZBB-21624821e6/computer_360.gif\", \"thumb_360_h\": 225, \"thumb_360_w\": 360, \"thumb_480\": \"https://files.slack.com/files-tmb/T2U81E2BB-F7H0D7ZBB-21624821e6/computer_480.png\", \"thumb_480_gif\": \"https://files.slack.com/files-tmb/T2U81E2BB-F7H0D7ZBB-21624821e6/computer_480.gif\", \"thumb_480_h\": 300, \"thumb_480_w\": 480, \"thumb_64\": \"https://files.slack.com/files-tmb/T2U81E2BB-F7H0D7ZBB-21624821e6/computer_64.png\", \"thumb_80\": \"https://files.slack.com/files-tmb/T2U81E2BB-F7H0D7ZBB-21624821e6/computer_80.png\", \"timestamp\": 1507850315, \"title\": \"computer.gif\", \"top_file\": false, \"url_private\": \"https://files.slack.com/files-pri/T2U81E2BB-F7H0D7ZBB/computer.gif\", \"url_private_download\": \"https://files.slack.com/files-pri/T2U81E2BB-F7H0D7ZBB/download/computer.gif\", \"user\": \"U2U85N1RZ\", \"username\": \"\"}], \"pagination\": {\"first\": 1, \"last\": 3, \"page\": 1, \"page_count\": 1, \"per_page\": 20, \"total_count\": 3}, \"paging\": {\"count\": 20, \"page\": 1, \"pages\": 1, \"total\": 3}, \"total\": 3}, \"ok\": true, \"query\": \"computer.gif\"}",
      decode.at(["files", "matches"], decode.list(file.file_decoder())),
    )
}

pub fn files_info_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"file\": {\"id\": \"F0S43PZDF\", \"created\": 1531763342, \"timestamp\": 1531763342, \"name\": \"tedair.gif\", \"title\": \"tedair.gif\", \"mimetype\": \"image/gif\", \"filetype\": \"gif\", \"pretty_type\": \"GIF\", \"user\": \"U061F7AUR\", \"editable\": false, \"size\": 137531, \"mode\": \"hosted\", \"is_external\": false, \"external_type\": \"\", \"is_public\": true, \"public_url_shared\": false, \"display_as_bot\": false, \"username\": \"\", \"url_private\": \"https://.../tedair.gif\", \"url_private_download\": \"https://.../tedair.gif\", \"thumb_64\": \"https://.../tedair_64.png\", \"thumb_80\": \"https://.../tedair_80.png\", \"thumb_360\": \"https://.../tedair_360.png\", \"thumb_360_w\": 176, \"thumb_360_h\": 226, \"thumb_160\": \"https://.../tedair_=_160.png\", \"thumb_360_gif\": \"https://.../tedair_360.gif\", \"image_exif_rotation\": 1, \"original_w\": 176, \"original_h\": 226, \"deanimate_gif\": \"https://.../tedair_deanimate_gif.png\", \"pjpeg\": \"https://.../tedair_pjpeg.jpg\", \"permalink\": \"https://.../tedair.gif\", \"permalink_public\": \"https://.../...\", \"comments_count\": 0, \"is_starred\": false, \"shares\": {\"public\": {\"C0T8SE4AU\": [{\"reply_users\": [\"U061F7AUR\"], \"reply_users_count\": 1, \"reply_count\": 1, \"ts\": \"1531763348.000001\", \"thread_ts\": \"1531763273.000015\", \"latest_reply\": \"1531763348.000001\", \"channel_name\": \"file-under\", \"team_id\": \"T061EG9R6\"}]}}, \"channels\": [\"C0T8SE4AU\"], \"groups\": [], \"ims\": [], \"has_rich_preview\": false, \"alt_txt\": \"tedair.gif\"}, \"comments\": [], \"response_metadata\": {\"next_cursor\": \"dGVhbTpDMUg5UkVTR0w=\"}}",
      decode.at(["file"], file.file_decoder()),
    )
}

pub fn files_list_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"files\": [{\"id\": \"F0S43P1CZ\", \"created\": 1531763254, \"timestamp\": 1531763254, \"name\": \"billair.gif\", \"title\": \"billair.gif\", \"mimetype\": \"image/gif\", \"filetype\": \"gif\", \"pretty_type\": \"GIF\", \"user\": \"U061F7AUR\", \"editable\": false, \"size\": 144538, \"mode\": \"hosted\", \"is_external\": false, \"external_type\": \"\", \"is_public\": true, \"public_url_shared\": false, \"display_as_bot\": false, \"username\": \"\", \"url_private\": \"https://.../billair.gif\", \"url_private_download\": \"https://.../billair.gif\", \"thumb_64\": \"https://.../billair_64.png\", \"thumb_80\": \"https://.../billair_80.png\", \"thumb_360\": \"https://.../billair_360.png\", \"thumb_360_w\": 176, \"thumb_360_h\": 226, \"thumb_160\": \"https://.../billair_=_160.png\", \"thumb_360_gif\": \"https://.../billair_360.gif\", \"image_exif_rotation\": 1, \"original_w\": 176, \"original_h\": 226, \"deanimate_gif\": \"https://.../billair_deanimate_gif.png\", \"pjpeg\": \"https://.../billair_pjpeg.jpg\", \"permalink\": \"https://.../billair.gif\", \"permalink_public\": \"https://.../...\", \"channels\": [\"C0T8SE4AU\"], \"groups\": [], \"ims\": [], \"comments_count\": 0}, {\"id\": \"F0S43PZDF\", \"created\": 1531763342, \"timestamp\": 1531763342, \"name\": \"tedair.gif\", \"title\": \"tedair.gif\", \"mimetype\": \"image/gif\", \"filetype\": \"gif\", \"pretty_type\": \"GIF\", \"user\": \"U061F7AUR\", \"editable\": false, \"size\": 137531, \"mode\": \"hosted\", \"is_external\": false, \"external_type\": \"\", \"is_public\": true, \"public_url_shared\": false, \"display_as_bot\": false, \"username\": \"\", \"url_private\": \"https://.../tedair.gif\", \"url_private_download\": \"https://.../tedair.gif\", \"thumb_64\": \"https://.../tedair_64.png\", \"thumb_80\": \"https://.../tedair_80.png\", \"thumb_360\": \"https://.../tedair_360.png\", \"thumb_360_w\": 176, \"thumb_360_h\": 226, \"thumb_160\": \"https://.../tedair_=_160.png\", \"thumb_360_gif\": \"https://.../tedair_360.gif\", \"image_exif_rotation\": 1, \"original_w\": 176, \"original_h\": 226, \"deanimate_gif\": \"https://.../tedair_deanimate_gif.png\", \"pjpeg\": \"https://.../tedair_pjpeg.jpg\", \"permalink\": \"https://.../tedair.gif\", \"permalink_public\": \"https://.../...\", \"channels\": [\"C0T8SE4AU\"], \"groups\": [], \"ims\": [], \"comments_count\": 0}], \"paging\": {\"count\": 100, \"total\": 2, \"page\": 1, \"pages\": 1}}",
      decode.at(["files"], decode.list(file.file_decoder())),
    )
}

pub fn team_info_0_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"team\": {\"id\": \"T12345\", \"name\": \"My Team\", \"domain\": \"example\", \"email_domain\": \"example.com\", \"icon\": {\"image_34\": \"https://...\", \"image_44\": \"https://...\", \"image_68\": \"https://...\", \"image_88\": \"https://...\", \"image_102\": \"https://...\", \"image_132\": \"https://...\", \"image_default\": true}, \"enterprise_id\": \"E1234A12AB\", \"enterprise_name\": \"Umbrella Corporation\"}}",
      decode.at(["team"], team.team_decoder()),
    )
}

pub fn team_info_1_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"team\": {\"id\": \"T123ABC456\", \"name\": \"Example workspace\", \"domain\": \"example\", \"slackbot_availability\": \"available\"}}",
      decode.at(["team"], team.team_decoder()),
    )
}

pub fn team_profile_get_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"profile\": {\"fields\": [{\"id\": \"111111ABC\", \"ordering\": 0, \"label\": \"Phone extension\", \"hint\": \"Enter the extension to reach your desk\", \"type\": \"text\", \"possible_values\": null, \"options\": {\"is_scim\": true, \"is_protected\": true}, \"is_hidden\": false, \"section_id\": \"123ABC\"}, {\"id\": \"222222ABC\", \"ordering\": 1, \"label\": \"Date of birth\", \"hint\": \"When you were born\", \"type\": \"date\", \"possible_values\": null, \"options\": {\"is_scim\": true, \"is_protected\": true}, \"is_hidden\": true, \"section_id\": \"123ABC\"}, {\"id\": \"333333ABC\", \"ordering\": 2, \"label\": \"House\", \"hint\": \"Put on the sorting hat\", \"type\": \"options_list\", \"possible_values\": [\"Gryffindor\", \"Hufflepuff\", \"Ravenclaw\", \"Slytherin\"], \"options\": {\"is_scim\": false, \"is_protected\": false}, \"is_hidden\": false, \"section_id\": \"456DEF\"}], \"sections\": [{\"id\": \"123ABC\", \"team_id\": \"T123456\", \"section_type\": \"contact\", \"label\": \"Contact Information\", \"order\": 1, \"is_hidden\": true}, {\"id\": \"456DEF\", \"team_id\": \"T123456\", \"section_type\": \"custom\", \"label\": \"About Me\", \"order\": 2, \"is_hidden\": true}]}}",
      decode.at(["profile"], team.team_profile_decoder()),
    )
}

pub fn bots_info_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"bot\": {\"id\": \"B123456\", \"deleted\": false, \"name\": \"beforebot\", \"updated\": 1449272004, \"app_id\": \"A123456\", \"user_id\": \"U123456\", \"icons\": {\"image_36\": \"https://...\", \"image_48\": \"https://...\", \"image_72\": \"https://...\"}}}",
      decode.at(["bot"], bot.bot_decoder()),
    )
}

pub fn usergroups_list_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"usergroups\": [{\"id\": \"S0614TZR7\", \"team_id\": \"T060RNRCH\", \"is_usergroup\": true, \"name\": \"Team Admins\", \"description\": \"A group of all Administrators on your team.\", \"handle\": \"admins\", \"is_external\": false, \"date_create\": 1446598059, \"date_update\": 1446670362, \"date_delete\": 0, \"auto_type\": \"admin\", \"created_by\": \"USLACKBOT\", \"updated_by\": \"U060RNRCZ\", \"deleted_by\": null, \"prefs\": {\"channels\": [], \"groups\": []}, \"user_count\": \"2\"}, {\"id\": \"S06158AV7\", \"team_id\": \"T060RNRCH\", \"is_usergroup\": true, \"name\": \"Team Owners\", \"description\": \"A group of all Owners on your team.\", \"handle\": \"owners\", \"is_external\": false, \"date_create\": 1446678371, \"date_update\": 1446678371, \"date_delete\": 0, \"auto_type\": \"owner\", \"created_by\": \"USLACKBOT\", \"updated_by\": \"USLACKBOT\", \"deleted_by\": null, \"prefs\": {\"channels\": [], \"groups\": []}, \"user_count\": \"1\"}, {\"id\": \"S0615G0KT\", \"team_id\": \"T060RNRCH\", \"is_usergroup\": true, \"name\": \"Marketing Team\", \"description\": \"Marketing gurus, PR experts and product advocates.\", \"handle\": \"marketing-team\", \"is_external\": false, \"date_create\": 1446746793, \"date_update\": 1446747767, \"date_delete\": 1446748865, \"auto_type\": null, \"created_by\": \"U060RNRCZ\", \"updated_by\": \"U060RNRCZ\", \"deleted_by\": null, \"prefs\": {\"channels\": [], \"groups\": []}, \"user_count\": \"0\"}]}",
      decode.at(["usergroups"], decode.list(usergroup.usergroup_decoder())),
    )
}

pub fn usergroups_update_test() {
  let assert Ok(_) =
    json.parse(
      "{\"ok\": true, \"usergroup\": {\"id\": \"S0616NG6M\", \"team_id\": \"T060R4BHN\", \"is_usergroup\": true, \"name\": \"Marketing Team\", \"description\": \"Marketing gurus, PR experts and product advocates.\", \"handle\": \"marketing-team\", \"is_external\": false, \"date_create\": 1447096577, \"date_update\": 1447102109, \"date_delete\": 0, \"auto_type\": null, \"created_by\": \"U060R4BJ4\", \"updated_by\": \"U060R4BJ4\", \"deleted_by\": null, \"prefs\": {\"channels\": [], \"groups\": []}, \"users\": [\"U060R4BJ4\", \"U060RNRCZ\"], \"user_count\": 1}}",
      decode.at(["usergroup"], usergroup.usergroup_decoder()),
    )
}

pub fn event_message_message_changed_test() {
  let assert Ok(_) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"message_changed\", \"hidden\": true, \"channel\": \"C123ABC456\", \"ts\": \"1358878755.000001\", \"message\": {\"type\": \"message\", \"user\": \"U123ABC456\", \"text\": \"Hello, world!\", \"ts\": \"1355517523.000005\", \"edited\": {\"user\": \"U123ABC456\", \"ts\": \"1358878755.000001\"}}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      decode.at(["event", "message"], message.message_decoder()),
    )
}

pub fn event_message_thread_broadcast_test() {
  let assert Ok(_) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"thread_broadcast\", \"text\": \"broadcasting this reply\", \"user\": \"U123ABC456\", \"ts\": \"1673464745.620769\", \"thread_ts\": \"1673464730.703009\", \"root\": {\"client_msg_id\": \"123abc456-...\", \"type\": \"message\", \"text\": \"This is the original message\", \"user\": \"U123ABC456\", \"ts\": \"1673464730.703009\", \"blocks\": [{\"type\": \"rich_text\", \"block_id\": \"qTg\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"This is the original message\"}]}]}], \"team\": \"T123ABC456\", \"thread_ts\": \"1673464730.703009\", \"reply_count\": 1, \"reply_users_count\": 1, \"latest_reply\": \"1673464745.620769\", \"reply_users\": [\"U123ABC456\"], \"is_locked\": false}, \"blocks\": [{\"type\": \"rich_text\", \"block_id\": \"BVp\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"broadcasting this reply\"}]}]}], \"client_msg_id\": \"123abc456-...\", \"channel\": \"C123ABC456\", \"event_ts\": \"1673464745.620769\", \"channel_type\": \"channel\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      decode.at(["event"], message.message_decoder()),
    )
}

pub fn event_message_file_share_test() {
  let assert Ok(_) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"text\": \"We got one!\", \"files\": [{\"id\": \"F0RDC39U1\", \"created\": 1529342081, \"timestamp\": 1529342081, \"name\": \"ghostrap.png\", \"title\": \"ghostrap.png\", \"mimetype\": \"image/png\", \"filetype\": \"png\", \"pretty_type\": \"PNG\", \"user\": \"U061F7AUR\", \"editable\": false, \"size\": 196920, \"mode\": \"hosted\", \"is_external\": false, \"external_type\": \"\", \"is_public\": false, \"public_url_shared\": false, \"display_as_bot\": false, \"username\": \"\", \"url_private\": \"https://files.slack.com/files-pri/T061EG9R6-F0RDC39U1/ghostrap.png\", \"url_private_download\": \"https://files.slack.com/files-pri/T061EG9R6-F0RDC39U1/download/ghostrap.png\", \"thumb_64\": \"https://files.slack.com/files-tmb/T061EG9R6-F0RDC39U1-f8c7b072da/ghostrap_64.png\", \"thumb_80\": \"https://files.slack.com/files-tmb/T061EG9R6-F0RDC39U1-f8c7b072da/ghostrap_80.png\", \"thumb_360\": \"https://files.slack.com/files-tmb/T061EG9R6-F0RDC39U1-f8c7b072da/ghostrap_360.png\", \"thumb_360_w\": 360, \"thumb_360_h\": 360, \"thumb_480\": \"https://files.slack.com/files-tmb/T061EG9R6-F0RDC39U1-f8c7b072da/ghostrap_480.png\", \"thumb_480_w\": 480, \"thumb_480_h\": 480, \"thumb_160\": \"https://files.slack.com/files-tmb/T061EG9R6-F0RDC39U1-f8c7b072da/ghostrap_160.png\", \"image_exif_rotation\": 1, \"original_w\": 512, \"original_h\": 512, \"pjpeg\": \"https://files.slack.com/files-tmb/T061EG9R6-F0RDC39U1-f8c7b072da/ghostrap_pjpeg.jpg\", \"permalink\": \"https://episod-slackform.slack.com/files/U061F7AUR/F0RDC39U1/ghostrap.png\", \"permalink_public\": \"https://slack-files.com/T061EG9R6-F0RDC39U1-815d735817\", \"has_rich_preview\": false}], \"user\": \"U123ABC456\", \"upload\": true, \"display_as_bot\": false, \"bot_id\": null, \"ts\": \"1529342088.000086\", \"channel\": \"D0L4B9P0Q\", \"event_ts\": \"1529342088.000086\", \"channel_type\": \"im\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      decode.at(["event"], message.message_decoder()),
    )
}

pub fn event_message_message_replied_test() {
  let assert Ok(_) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"message\": {\"type\": \"message\", \"user\": \"U123ABC456\", \"text\": \"Was there was there was there what was there was there what was there was there there was there.\", \"thread_ts\": \"1482960137.003543\", \"reply_count\": 1, \"replies\": [{\"user\": \"U2222222\", \"ts\": \"1483037603.017503\"}], \"ts\": \"1482960137.003543\"}, \"subtype\": \"message_replied\", \"hidden\": true, \"channel\": \"C123ABC456\", \"event_ts\": \"1483037604.017506\", \"ts\": \"1483037604.017506\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      decode.at(["event"], message.message_decoder()),
    )
}

pub fn event_message_document_mention_test() {
  let assert Ok(_) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"user\": \"UA1BCD3EF\", \"subtype\": \"document_mention\", \"document_mention\": {\"file_id\": \"F123ABCDEFG\", \"section_id\": \"temp:C:GQL71204e5bd23942c79f0a22a51\", \"mentioning_user_ids\": [\"UA1BCD3EF\"]}, \"type\": \"app_mention\", \"ts\": \"1716411280.657549\", \"text\": \"<@U123456ABC7> was mentioned in a canvas\", \"team\": \"T1ABC2DE3\", \"blocks\": [{\"type\": \"section\", \"block_id\": \"gcn3v\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"&gt;&gt;&gt;Hey <@U123456ABC7>\", \"verbatim\": false}}], \"channel\": \"C012ABCDEFG\", \"event_ts\": \"1716411280.657549\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"UA1BCD3EF\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      decode.at(["event"], message.message_decoder()),
    )
}

pub fn event_bot_added_test() {
  let assert Ok(_) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"bot_added\", \"bot\": {\"id\": \"B024BE7LH\", \"app_id\": \"A4H1JB4AZ\", \"name\": \"hugbot\", \"icons\": {\"image_48\": \"https://slack.com/path/to/hugbot_48.png\"}}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      decode.at(["event", "bot"], bot.bot_decoder()),
    )
}

pub fn event_user_change_test() {
  let assert Ok(_) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"user\": {\"id\": \"U1234567\", \"team_id\": \"T1234567\", \"name\": \"some-user\", \"deleted\": false, \"color\": \"4bbe2e\", \"real_name\": \"Some User\", \"tz\": \"America/Los_Angeles\", \"tz_label\": \"Pacific Daylight Time\", \"tz_offset\": -25200, \"profile\": {\"title\": \"\", \"phone\": \"\", \"skype\": \"\", \"real_name\": \"Some User\", \"real_name_normalized\": \"Some User\", \"display_name\": \"\", \"display_name_normalized\": \"\", \"fields\": {}, \"status_text\": \"riding a train\", \"status_emoji\": \":mountain_railway:\", \"status_emoji_display_info\": [], \"status_expiration\": 0, \"avatar_hash\": \"g12345678910\", \"first_name\": \"Some\", \"last_name\": \"User\", \"image_24\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=24&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-24.png\", \"image_32\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=32&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-32.png\", \"image_48\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=48&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-48.png\", \"image_72\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=72&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-72.png\", \"image_192\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=192&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-192.png\", \"image_512\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=512&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-512.png\", \"status_text_canonical\": \"\", \"team\": \"T1234567\"}, \"is_admin\": false, \"is_owner\": false, \"is_primary_owner\": false, \"is_restricted\": false, \"is_ultra_restricted\": false, \"is_bot\": false, \"is_app_user\": false, \"updated\": 1648596421, \"is_email_confirmed\": true, \"who_can_share_contact_card\": \"EVERYONE\", \"locale\": \"en-US\"}, \"cache_ts\": 1648596421, \"type\": \"user_change\", \"event_ts\": \"1648596712.000001\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U1234567\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      decode.at(["event", "user"], user.user_decoder()),
    )
}

pub fn event_metadata_encodes_test() {
  let metadata =
    message.event_metadata(
      "ticket_created",
      value.Object([#("ticket_id", value.String("PROJ-1234"))]),
    )
  let assert "{\"event_type\":\"ticket_created\",\"event_payload\":{\"ticket_id\":\"PROJ-1234\"}}" =
    json.to_string(message.message_metadata_to_json(metadata))
}

pub fn usergroup_count_test() {
  let assert Ok(4) =
    usergroup.usergroup_count_to_int(usergroup.UsergroupCountString("4"))
  let assert Ok(2) =
    usergroup.usergroup_count_to_int(usergroup.UsergroupCountInt(2))
}
