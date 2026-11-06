//// Decodes the json examples on the Events API reference pages for
//// `message` events and their subtypes.

import gleam/dynamic/decode
import gleam/json
import slackline/event
import slackline/file

fn round_trip_envelope(it: event.Envelope) -> Nil {
  let assert Ok(again) =
    json.parse(
      json.to_string(event.envelope_to_json(it)),
      event.envelope_decoder(),
    )
  assert again == it
  Nil
}

fn round_trip_event(it: event.Event) -> Nil {
  let assert Ok(again) =
    json.parse(json.to_string(event.event_to_json(it)), event.event_decoder())
  assert again == it
  Nil
}

/// .docs/reference/events/message.app_home.md example 0
pub fn message_app_home_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"one-long-verification-token\", \"team_id\": \"T012345678\", \"api_app_id\": \"A0PNCHHK2\", \"event\": {\"type\": \"message\", \"user\": \"U012345ABCD\", \"text\": \"How many cats did we herd yesterday?\", \"ts\": \"1525215129.000001\", \"channel\": \"D0PNCRP9N\", \"event_ts\": \"1525215129.000001\", \"channel_type\": \"app_home\"}, \"type\": \"event_callback\", \"authorizations\": [{\"enterprise_id\": \"E123ABC456\", \"user_id\": \"U012345ABCD\", \"team_id\": \"T012345678\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev0PV52K25\", \"event_time\": 1525215129}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.PlainMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message.channels.md example 0
pub fn message_channels_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"one-long-verification-token\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"channel\": \"C123ABC456\", \"user\": \"U123ABC456\", \"text\": \"Live long and prospect.\", \"ts\": \"1355517523.000005\", \"event_ts\": \"1355517523.000005\", \"channel_type\": \"channel\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 1355517523}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.PlainMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message.groups.md example 0
pub fn message_groups_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"one-long-verification-token\", \"team_id\": \"T061EG9R6\", \"api_app_id\": \"A0PNCHHK2\", \"event\": {\"type\": \"message\", \"channel\": \"G024BE91L\", \"user\": \"U2147483697\", \"text\": \"One cannot programmatically detect the difference between `message.mpim` and `message.groups`.\", \"ts\": \"1355517523.000005\", \"event_ts\": \"1355517523.000005\", \"channel_type\": \"group\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T061EG9R6\", \"user_id\": \"U2147483697\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev0PV52K21\", \"event_time\": 1355517523}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.PlainMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message.im.md example 0
pub fn message_im_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"one-long-verification-token\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A0PNCHHK2\", \"event\": {\"type\": \"message\", \"channel\": \"D024BE91L\", \"user\": \"U2147483697\", \"text\": \"Hello hello can you hear me?\", \"ts\": \"1355517523.000005\", \"event_ts\": \"1355517523.000005\", \"channel_type\": \"im\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U2147483697\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev0PV52K21\", \"event_time\": 1355517523}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.PlainMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message.md example 0
pub fn message_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"channel\": \"C123ABC456\", \"user\": \"U123ABC456\", \"text\": \"Hello world\", \"ts\": \"1355517523.000005\", \"channel_type\": \"channel\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.PlainMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message.md example 1
pub fn message_1_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"message\", \"channel\": \"C123ABC456\", \"user\": \"U123ABC456\", \"text\": \"Hello, world!\", \"ts\": \"1355517523.000005\", \"edited\": {\"user\": \"U123ABC456\", \"ts\": \"1355517536.000001\"}}",
      event.event_decoder(),
    )
  let assert event.MessageEvent(event.PlainMessage(..)) = decoded
  round_trip_event(decoded)
}

/// .docs/reference/events/message.md example 2
pub fn message_2_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"message\", \"user\": \"U012345ABCDEF\", \"text\": \"What's the latest on agents?\", \"app_context\": {\"entities\": [{\"type\": \"slack#/types/channel_id\", \"value\": \"C0123456ABC\", \"team_id\": \"T0123ABCDEF\"}]}, \"channel\": \"D01ABCDEFG9\", \"channel_type\": \"im\"}",
      event.event_decoder(),
    )
  let assert event.MessageEvent(event.PlainMessage(..)) = decoded
  round_trip_event(decoded)
}

/// .docs/reference/events/message.md example 3
pub fn message_3_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"message\", \"subtype\": \"channel_join\", \"text\": \"<@U123ABC456|bobby> has joined the channel\", \"ts\": \"1403051575.000407\", \"user\": \"U123ABC456\"}",
      event.event_decoder(),
    )
  let assert event.MessageEvent(event.ChannelJoinMessage(..)) = decoded
  round_trip_event(decoded)
}

/// .docs/reference/events/message.md example 4
pub fn message_4_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"message\", \"subtype\": \"message_deleted\", \"hidden\": true, \"channel\": \"C123ABC456\", \"ts\": \"1358878755.000001\", \"deleted_ts\": \"1358878749.000002\", \"event_ts\": \"1358878755.000002\"}",
      event.event_decoder(),
    )
  let assert event.MessageEvent(event.MessageDeleted(..)) = decoded
  round_trip_event(decoded)
}

/// .docs/reference/events/message.md example 5
pub fn message_5_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"message\", \"channel\": \"C123ABC456\", \"user\": \"U123ABC456\", \"text\": \"Hello world\", \"ts\": \"1355517523.000005\", \"is_starred\": true, \"pinned_to\": [\"C024BE7LT\"], \"reactions\": [{\"name\": \"astonished\", \"count\": 3, \"users\": [\"U1\", \"U2\", \"U3\"]}, {\"name\": \"facepalm\", \"count\": 1034, \"users\": [\"U1\", \"U2\", \"U3\", \"U4\", \"U5\"]}]}",
      event.event_decoder(),
    )
  let assert event.MessageEvent(event.PlainMessage(..)) = decoded
  round_trip_event(decoded)
}

/// .docs/reference/events/message.mpim.md example 0
pub fn message_mpim_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"one-long-verification-token\", \"team_id\": \"T061EG9R6\", \"api_app_id\": \"A0PNCHHK2\", \"event\": {\"type\": \"message\", \"channel\": \"G024BE91L\", \"user\": \"U2147483697\", \"text\": \"Let's make a pact.\", \"ts\": \"1355517523.000005\", \"event_ts\": \"1355517523.000005\", \"channel_type\": \"mpim\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T061EG9R6\", \"user_id\": \"U2147483697\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev0PV52K21\", \"event_time\": 1355517523}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.PlainMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message_metadata_deleted.md example 0
pub fn message_metadata_deleted_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message_metadata_deleted\", \"channel_id\": \"CJN879K8A\", \"event_ts\": \"1658907498.002500\", \"previous_metadata\": {\"event_type\": \"task_created\", \"event_payload\": {\"id\": \"TK-2135\", \"summary\": \"New issue with the display of mobile element\", \"description\": \"An end user has found a problem with the new mobile container for data entry. It was reproduced in the current version of IOS.\", \"priority\": \"HIGH\", \"resource_type\": \"TASK\"}}, \"app_id\": \"AQF4F123M\", \"bot_id\": \"B8241P2B34D\", \"user_id\": \"U123ABC456\", \"team_id\": \"T12F3JCAP\", \"message_ts\": \"1658905974.587109\", \"deleted_ts\": \"1658907498.002500\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.MessageMetadataDeleted(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message_metadata_posted.md example 0
pub fn message_metadata_posted_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message_metadata_posted\", \"app_id\": \"AQF4F123M\", \"bot_id\": \"B8241P2B34D\", \"user_id\": \"U123ABC456\", \"team_id\": \"T12F3JCAP\", \"channel_id\": \"CJN879K8A\", \"metadata\": {\"event_type\": \"task_created\", \"event_payload\": {\"id\": \"TK-2132\", \"summary\": \"New issue with the display of mobile element\", \"description\": \"An end user has found a problem with the new mobile container for data entry. It was reproduced in the current version of IOS.\", \"priority\": \"HIGH\", \"resource_type\": \"TASK\"}}, \"message_ts\": \"1658903885.673769\", \"event_ts\": \"1658903885.673769\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.MessageMetadataPosted(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message_metadata_updated.md example 0
pub fn message_metadata_updated_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message_metadata_updated\", \"channel_id\": \"CJN879K8A\", \"event_ts\": \"1658906295.002200\", \"previous_metadata\": {\"event_type\": \"task_created\", \"event_payload\": {\"id\": \"TK-2132\", \"summary\": \"New issue with the display of mobile element\", \"description\": \"An end user has found a problem with the new mobile container for data entry. It was reproduced in the current version of IOS.\", \"priority\": \"HIGH\", \"resource_type\": \"TASK\"}}, \"app_id\": \"AQF4F123M\", \"bot_id\": \"B8241P2B34D\", \"user_id\": \"U123ABC456\", \"team_id\": \"T12F3JCAP\", \"message_ts\": \"1658905974.587109\", \"metadata\": {\"event_type\": \"task_created\", \"event_payload\": {\"id\": \"TK-2135\", \"summary\": \"New issue with the display of mobile element\", \"description\": \"An end user has found a problem with the new mobile container for data entry. It was reproduced in the current version of IOS.\", \"priority\": \"HIGH\", \"resource_type\": \"TASK\"}}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.MessageMetadataUpdated(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/assistant_app_thread.md example 1
pub fn message_assistant_app_thread_1_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"message_changed\", \"message\": {\"text\": \"Chats from 2024-09-28T00:41:31.923Z\", \"subtype\": \"assistant_app_thread\", \"user\": \"U123456ABCD\", \"type\": \"message\", \"edited\": {\"user\": \"U123456ABCD\", \"ts\": \"1727484103.000000\"}, \"team\": \"T123456ABCD\", \"thread_ts\": \"1727484091.821349\", \"reply_count\": 1, \"reply_users_count\": 1, \"latest_reply\": \"1727484101.719749\", \"reply_users\": [\"U123456ABCD\"], \"is_locked\": false, \"blocks\": [], \"assistant_app_thread\": {\"title\": \"Chats from 2024-09-28T00:41:31.923Z\", \"title_blocks\": [], \"artifacts\": []}, \"ts\": \"1727484091.821349\"}, \"previous_message\": {\"text\": \"Chats from 2024-09-28T00:41:31.923Z\", \"subtype\": \"assistant_app_thread\", \"user\": \"U123456ABCD\", \"type\": \"message\", \"ts\": \"1727484091.821349\", \"team\": \"T123456ABCD\", \"thread_ts\": \"1727484091.821349\", \"reply_count\": 1, \"reply_users_count\": 1, \"latest_reply\": \"1727484101.719749\", \"reply_users\": [\"U123456ABCD\"], \"is_locked\": false, \"blocks\": [], \"assistant_app_thread\": {\"title\": \"Chats from 2024-09-28T00:41:31.923Z\", \"title_blocks\": [], \"artifacts\": []}}, \"channel\": \"D987654ABCD\", \"hidden\": true, \"ts\": \"1727484103.018100\", \"event_ts\": \"1727484103.018100\", \"channel_type\": \"im\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123456ABCD\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.MessageChanged(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/bot_message.md example 0
pub fn message_bot_message_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"bot_message\", \"ts\": \"1358877455.000010\", \"text\": \"Pushing is the answer\", \"bot_id\": \"BB12033\", \"username\": \"github\", \"icons\": {}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.BotMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/channel_archive.md example 0
pub fn message_channel_archive_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"channel_archive\", \"ts\": \"1361482916.000003\", \"text\": \"<U1234|@cal> archived the channel\", \"user\": \"U1234\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.ChannelArchiveMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/channel_convert_to_private.md example 0
pub fn message_channel_convert_to_private_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"subtype\": \"channel_convert_to_private\", \"user\": \"U1234ABCD\", \"text\": \"made this channel *private*. Now, it can only be viewed or joined by invitation.\", \"type\": \"message\", \"ts\": \"1730984822.596869\", \"channel\": \"C1234ABCD\", \"event_ts\": \"1730984822.596869\", \"channel_type\": \"group\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U1234ABCD\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.ChannelConvertToPrivateMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/channel_convert_to_public.md example 0
pub fn message_channel_convert_to_public_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"channel_convert_to_public\", \"ts\": \"1723680078.026719\", \"text\": \"made this channel *public*. Any member in this workspace can see and join it.\", \"user\": \"U123ABC456\", \"channel\": \"C123ABC456\", \"event_ts\": \"1614215651.001300\", \"channel_type\": \"channel\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.ChannelConvertToPublicMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/channel_join.md example 0
pub fn message_channel_join_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"channel_join\", \"ts\": \"1358877458.000011\", \"user\": \"U2147483828\", \"text\": \"<@U2147483828|cal> has joined the channel\", \"inviter\": \"U123456789\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.ChannelJoinMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/channel_leave.md example 0
pub fn message_channel_leave_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"channel_leave\", \"ts\": \"1358877455.000010\", \"user\": \"U2147483828\", \"text\": \"<@U2147483828|cal> has left the channel\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U2147483828\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.ChannelLeaveMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/channel_name.md example 0
pub fn message_channel_name_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"channel_name\", \"ts\": \"1358877455.000010\", \"user\": \"U2147483828\", \"old_name\": \"random\", \"name\": \"watercooler\", \"text\": \"<@U2147483828|cal> has renamed the channek from \\\"random\\\" to \\\"watercooler\\\"\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U2147483828\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.ChannelNameMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/channel_posting_permissions.md example 0
pub fn message_channel_posting_permissions_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"channel_posting_permissions\", \"ts\": \"1614215651.001300\", \"user\": \"U123ABC456\", \"text\": \"changed channel posting permissions.\", \"channel\": \"C123ABC456\", \"event_ts\": \"1614215651.001300\", \"channel_type\": \"channel\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.ChannelPostingPermissionsMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/channel_purpose.md example 0
pub fn message_channel_purpose_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"channel_purpose\", \"ts\": \"1358877455.000010\", \"user\": \"U123ABC456\", \"purpose\": \"whatever\", \"text\": \"<@U2147483828|cal> set the channel purpose: whatever\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.ChannelPurposeMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/channel_topic.md example 0
pub fn message_channel_topic_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"channel_topic\", \"ts\": \"1358877455.000010\", \"user\": \"U2147483828\", \"topic\": \"hello world\", \"text\": \"<@U2147483828|cal> set the channel topic: hello world\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.ChannelTopicMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/channel_unarchive.md example 0
pub fn message_channel_unarchive_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"channel_unarchive\", \"ts\": \"1361482916.000003\", \"text\": \"<U1234|@cal> un-archived the channel\", \"user\": \"U1234\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.ChannelUnarchiveMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/document_mention.md example 0
pub fn message_document_mention_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"user\": \"UA1BCD3EF\", \"subtype\": \"document_mention\", \"document_mention\": {\"file_id\": \"F123ABCDEFG\", \"section_id\": \"temp:C:GQL71204e5bd23942c79f0a22a51\", \"mentioning_user_ids\": [\"UA1BCD3EF\"]}, \"type\": \"app_mention\", \"ts\": \"1716411280.657549\", \"text\": \"<@U123456ABC7> was mentioned in a canvas\", \"team\": \"T1ABC2DE3\", \"blocks\": [{\"type\": \"section\", \"block_id\": \"gcn3v\", \"text\": {\"type\": \"mrkdwn\", \"text\": \"&gt;&gt;&gt;Hey <@U123456ABC7>\", \"verbatim\": false}}], \"channel\": \"C012ABCDEFG\", \"event_ts\": \"1716411280.657549\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"UA1BCD3EF\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.AppMention(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/ekm_access_denied.md example 0
pub fn message_ekm_access_denied_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"ekm_access_denied\", \"ts\": \"1358877455.000010\", \"text\": \"Your admins have suspended everyone's access to this content.\", \"user\": \"U123ABC456\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.EkmAccessDeniedMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/file_comment.md example 0
pub fn message_file_comment_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"file_comment\", \"ts\": \"1361482916.000003\", \"text\": \"<@cal> commented on a file: ...\", \"file\": {\"id\": \"F123ABC456\"}, \"comment\": {}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.FileCommentMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/file_mention.md example 0
pub fn message_file_mention_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"file_mention\", \"ts\": \"1358877455.000010\", \"text\": \"<@cal> mentioned a file: <https:...7.png|7.png>\", \"file\": {\"id\": \"F123ABC456\"}, \"user\": \"U123ABC456\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.FileMentionMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/file_share.md example 0
pub fn message_file_share_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"text\": \"We got one!\", \"files\": [{\"id\": \"F0RDC39U1\", \"created\": 1529342081, \"timestamp\": 1529342081, \"name\": \"ghostrap.png\", \"title\": \"ghostrap.png\", \"mimetype\": \"image/png\", \"filetype\": \"png\", \"pretty_type\": \"PNG\", \"user\": \"U061F7AUR\", \"editable\": false, \"size\": 196920, \"mode\": \"hosted\", \"is_external\": false, \"external_type\": \"\", \"is_public\": false, \"public_url_shared\": false, \"display_as_bot\": false, \"username\": \"\", \"url_private\": \"https://files.slack.com/files-pri/T061EG9R6-F0RDC39U1/ghostrap.png\", \"url_private_download\": \"https://files.slack.com/files-pri/T061EG9R6-F0RDC39U1/download/ghostrap.png\", \"thumb_64\": \"https://files.slack.com/files-tmb/T061EG9R6-F0RDC39U1-f8c7b072da/ghostrap_64.png\", \"thumb_80\": \"https://files.slack.com/files-tmb/T061EG9R6-F0RDC39U1-f8c7b072da/ghostrap_80.png\", \"thumb_360\": \"https://files.slack.com/files-tmb/T061EG9R6-F0RDC39U1-f8c7b072da/ghostrap_360.png\", \"thumb_360_w\": 360, \"thumb_360_h\": 360, \"thumb_480\": \"https://files.slack.com/files-tmb/T061EG9R6-F0RDC39U1-f8c7b072da/ghostrap_480.png\", \"thumb_480_w\": 480, \"thumb_480_h\": 480, \"thumb_160\": \"https://files.slack.com/files-tmb/T061EG9R6-F0RDC39U1-f8c7b072da/ghostrap_160.png\", \"image_exif_rotation\": 1, \"original_w\": 512, \"original_h\": 512, \"pjpeg\": \"https://files.slack.com/files-tmb/T061EG9R6-F0RDC39U1-f8c7b072da/ghostrap_pjpeg.jpg\", \"permalink\": \"https://episod-slackform.slack.com/files/U061F7AUR/F0RDC39U1/ghostrap.png\", \"permalink_public\": \"https://slack-files.com/T061EG9R6-F0RDC39U1-815d735817\", \"has_rich_preview\": false}], \"user\": \"U123ABC456\", \"upload\": true, \"display_as_bot\": false, \"bot_id\": null, \"ts\": \"1529342088.000086\", \"channel\": \"D0L4B9P0Q\", \"event_ts\": \"1529342088.000086\", \"channel_type\": \"im\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.PlainMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/file_share.md example 1 (files fragment)
pub fn message_file_share_1_test() {
  let decoder = {
    use files <- decode.field("files", decode.list(file.file_decoder()))
    decode.success(files)
  }
  let assert Ok([_]) =
    json.parse(
      "{\"files\": [{\"id\": \"F12345678\", \"mode\": \"file_access\", \"file_access\": \"check_file_info\", \"created\": 0, \"timestamp\": 0, \"user\": \"\"}]}",
      decoder,
    )
}

/// .docs/reference/events/message/group_archive.md example 0
pub fn message_group_archive_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"group_archive\", \"ts\": \"1361482916.000003\", \"text\": \"<U1234|@cal> archived the group\", \"user\": \"U123ABC456\", \"members\": [\"U1234\", \"U5678\"]}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.GroupArchiveMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/group_join.md example 0
pub fn message_group_join_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"group_join\", \"ts\": \"1358877458.000011\", \"user\": \"U2147483828\", \"text\": \"<@U2147483828|cal> has joined the group\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U2147483828\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.GroupJoinMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/group_leave.md example 0
pub fn message_group_leave_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"group_leave\", \"ts\": \"1358877455.000010\", \"user\": \"U2147483828\", \"text\": \"<@U2147483828|cal> has left the group\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U2147483828\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.GroupLeaveMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/group_name.md example 0
pub fn message_group_name_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"group_name\", \"ts\": \"1358877455.000010\", \"user\": \"U2147483828\", \"old_name\": \"random\", \"name\": \"watercooler\", \"text\": \"<@U21474783828|cal> has renamed the group from \\\"random\\\" to \\\"watercooler\\\"\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U2147483828\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.GroupNameMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/group_purpose.md example 0
pub fn message_group_purpose_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"group_purpose\", \"ts\": \"1358877455.000010\", \"user\": \"U2147483828\", \"purpose\": \"whatever\", \"text\": \"<@U2147483828|cal> set the group purpose: whatever\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U2147483828\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.GroupPurposeMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/group_topic.md example 0
pub fn message_group_topic_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"group_topic\", \"ts\": \"1358877455.000010\", \"user\": \"U2147483828\", \"topic\": \"hello world\", \"text\": \"<@U2147483828|cal> set the group topic: hello world\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U2147483828\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.GroupTopicMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/group_unarchive.md example 0
pub fn message_group_unarchive_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"group_unarchive\", \"ts\": \"1361482916.000003\", \"text\": \"<U1234ABC56|@cal> un-archived the group\", \"user\": \"U1234ABC56\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U1234ABC56\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.GroupUnarchiveMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/me_message.md example 0
pub fn message_me_message_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"me_message\", \"channel\": \"C123ABC456\", \"user\": \"U123ABC456\", \"text\": \"is doing that thing\", \"ts\": \"1355517523.000005\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.MeMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/message_changed.md example 0
pub fn message_message_changed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"message_changed\", \"hidden\": true, \"channel\": \"C123ABC456\", \"ts\": \"1358878755.000001\", \"message\": {\"type\": \"message\", \"user\": \"U123ABC456\", \"text\": \"Hello, world!\", \"ts\": \"1355517523.000005\", \"edited\": {\"user\": \"U123ABC456\", \"ts\": \"1358878755.000001\"}}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.MessageChanged(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/message_deleted.md example 0
pub fn message_message_deleted_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"message_deleted\", \"hidden\": true, \"channel\": \"C123ABC456\", \"ts\": \"1358878755.000001\", \"deleted_ts\": \"1358878749.000002\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.MessageDeleted(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/message_replied.md example 0
pub fn message_message_replied_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"message\": {\"type\": \"message\", \"user\": \"U123ABC456\", \"text\": \"Was there was there was there what was there was there what was there was there there was there.\", \"thread_ts\": \"1482960137.003543\", \"reply_count\": 1, \"replies\": [{\"user\": \"U2222222\", \"ts\": \"1483037603.017503\"}], \"ts\": \"1482960137.003543\"}, \"subtype\": \"message_replied\", \"hidden\": true, \"channel\": \"C123ABC456\", \"event_ts\": \"1483037604.017506\", \"ts\": \"1483037604.017506\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.MessageReplied(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/pinned_item.md example 0
pub fn message_pinned_item_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"pinned_item\", \"user\": \"U123ABC456\", \"item_type\": \"F\", \"text\": \"<@U024BE7LH|cal> pinned their Image <https:...7.png|7.png> to this channel.\", \"item\": {}, \"channel\": \"C123ABC456\", \"ts\": \"1360782804.083113\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.PinnedItemMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/reminder_add.md example 0
pub fn message_reminder_add_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"reminder_add\", \"user\": \"U12345678\", \"team\": \"T12345678\", \"ts\": \"1361482916.000003\", \"text\": \"set up a reminder to “get reminded” in this channel at 8PM every day, Pacific Standard Time.\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U12345678\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.ReminderAddMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/thread_broadcast.md example 0
pub fn message_thread_broadcast_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"thread_broadcast\", \"text\": \"broadcasting this reply\", \"user\": \"U123ABC456\", \"ts\": \"1673464745.620769\", \"thread_ts\": \"1673464730.703009\", \"root\": {\"client_msg_id\": \"123abc456-...\", \"type\": \"message\", \"text\": \"This is the original message\", \"user\": \"U123ABC456\", \"ts\": \"1673464730.703009\", \"blocks\": [{\"type\": \"rich_text\", \"block_id\": \"qTg\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"This is the original message\"}]}]}], \"team\": \"T123ABC456\", \"thread_ts\": \"1673464730.703009\", \"reply_count\": 1, \"reply_users_count\": 1, \"latest_reply\": \"1673464745.620769\", \"reply_users\": [\"U123ABC456\"], \"is_locked\": false}, \"blocks\": [{\"type\": \"rich_text\", \"block_id\": \"BVp\", \"elements\": [{\"type\": \"rich_text_section\", \"elements\": [{\"type\": \"text\", \"text\": \"broadcasting this reply\"}]}]}], \"client_msg_id\": \"123abc456-...\", \"channel\": \"C123ABC456\", \"event_ts\": \"1673464745.620769\", \"channel_type\": \"channel\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.ThreadBroadcast(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/message/unpinned_item.md example 0
pub fn message_unpinned_item_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"message\", \"subtype\": \"unpinned_item\", \"user\": \"U123ABC456\", \"item_type\": \"G\", \"text\": \"<@U024BE7LH|cal> unpinned the message you pinned to the secretplans group.\", \"item\": {}, \"channel\": \"G024BE91L\", \"ts\": \"1360782804.083113\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.MessageEvent(event.UnpinnedItemMessage(..)),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}
