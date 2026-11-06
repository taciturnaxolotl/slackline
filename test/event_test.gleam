//// Decodes the json examples on the Events API reference pages, from
//// `agent_session_stopped` to `member_left_channel`, and tests parsing and
//// encoding.

import gleam/json
import gleam/option
import slackline/event

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

/// .docs/reference/events/agent_session_stopped.md example 0
pub fn agent_session_stopped_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"channel\": \"C0123ABC456\", \"event_ts\": \"1783536983.783769\", \"streaming_message_ts\": [\"1782234987.693923\"], \"thread_ts\": \"1782234671.392669\", \"type\": \"agent_session_stopped\", \"user\": \"U123ABC456\"}",
      event.event_decoder(),
    )
  let assert event.AgentSessionStopped(..) = decoded
  round_trip_event(decoded)
}

/// .docs/reference/events/agent_session_title_changed.md example 0
pub fn agent_session_title_changed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"channel\": \"C0123ABC456\", \"event_ts\": \"1783536983.783769\", \"previous_title\": \"Scuba diving research\", \"team_id\": \"T0123ABC456\", \"thread_ts\": \"1782234671.392669\", \"title\": \"Bora Bora trip prep\", \"type\": \"agent_session_title_changed\", \"user\": \"U123ABC456\"}",
      event.event_decoder(),
    )
  let assert event.AgentSessionTitleChanged(..) = decoded
  round_trip_event(decoded)
}

/// .docs/reference/events/app_context_changed.md example 0
pub fn app_context_changed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"app_context_changed\", \"context\": {\"entities\": [{\"type\": \"slack#/types/channel_id\", \"value\": \"C01234ABDCE\", \"team_id\": \"T0ABCDE6543\"}]}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.AppContextChanged(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/app_deleted.md example 0
pub fn app_deleted_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"app_deleted\", \"app_id\": \"A015CA1LGHG\", \"app_name\": \"my-admin-app\", \"app_owner_id\": \"U013B64J7MSZ\", \"team_id\": \"E073D7H7BBE\", \"team_domain\": \"ACME Enterprises\", \"event_ts\": \"1700001891.279278\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.AppDeleted(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/app_home_opened.md example 0
pub fn app_home_opened_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"app_home_opened\", \"user\": \"U123ABC456\", \"channel\": \"D123ABC456\", \"event_ts\": \"1515449522000016\", \"tab\": \"home\", \"view\": {\"id\": \"V123ABC456\", \"team_id\": \"T123ABC456\", \"type\": \"home\", \"blocks\": [], \"private_metadata\": \"\", \"callback_id\": \"\", \"hash\": \"1231232323.12321312\", \"clear_on_close\": false, \"notify_on_close\": false, \"root_view_id\": \"V123ABC456\", \"app_id\": \"A123ABC456\", \"external_id\": \"\", \"app_installed_team_id\": \"T123ABC456\", \"bot_id\": \"B123ABC456\"}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.AppHomeOpened(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/app_home_opened.md example 1
pub fn app_home_opened_1_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"app_home_opened\", \"user\": \"U012345ABCDE\", \"channel\": \"D0123ABCDEF\", \"context\": {\"entities\": [{\"type\": \"slack#/types/message_context\", \"value\": {\"message_ts\": \"1782919931.619439\", \"channel_id\": \"C01AB234CDE\"}, \"team_id\": \"T012345ABCDE\"}, {\"type\": \"slack#/types/channel_id\", \"value\": \"C012345ABCDE\", \"team_id\": \"T01A2B3C4D\"}]}}",
      event.event_decoder(),
    )
  let assert event.AppHomeOpened(..) = decoded
  round_trip_event(decoded)
}

/// .docs/reference/events/app_installed.md example 0
pub fn app_installed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"app_installed\", \"app_id\": \"A015CA1LGHG\", \"app_name\": \"my-admin-app\", \"app_owner_id\": \"U013B64J7MSZ\", \"user_id\": \"U013B64J7SZ\", \"team_id\": \"E073D7H7BBE\", \"team_domain\": \"ACME Enterprises\", \"event_ts\": \"1700001891.279278\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.AppInstalled(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/app_mention.md example 0
pub fn app_mention_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"app_mention\", \"user\": \"U061F7AUR\", \"text\": \"<@U0LAN0Z89> is it everything a river should be?\", \"ts\": \"1515449522.000016\", \"channel\": \"C123ABC456\", \"event_ts\": \"1515449522000016\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.AppMention(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/app_mention.md example 1
pub fn app_mention_1_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"ZZZZZZWSxiZZZ2yIvs3peJ\", \"team_id\": \"T061EG9R6\", \"api_app_id\": \"A0MDYCDME\", \"event\": {\"type\": \"app_mention\", \"user\": \"U0123ABCD\", \"text\": \"You can count on <@U0LAN0Z89> for an honorable mention.\", \"ts\": \"1515449483.000108\", \"channel\": \"C123ABC456\", \"event_ts\": \"1515449483000108\"}, \"type\": \"event_callback\", \"event_id\": \"Ev0MDYHUEL\", \"event_time\": 1515449483000108, \"authorizations\": [{\"user_id\": \"U0123ABCD\", \"is_bot\": false, \"is_enterprise_install\": false}]}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.AppMention(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/app_mention.md example 2
pub fn app_mention_2_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"ZZZZZZWSxiZZZ2yIvs3peJ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"app_mention\", \"user\": \"U123ABC456\", \"text\": \"What is the hour of the pearl, <@U0LAN0Z89>?\", \"ts\": \"1515449522.000016\", \"channel\": \"C123ABC456\", \"event_ts\": \"1515449522000016\"}, \"type\": \"event_callback\", \"event_id\": \"Ev123ABC456\", \"event_time\": 1515449522000016, \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}]}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.AppMention(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/app_rate_limited.md example 0
pub fn app_rate_limited_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"Jhj5dZrVaK7ZwHHjRyZWjbDl\", \"type\": \"app_rate_limited\", \"team_id\": \"T123456\", \"minute_rate_limited\": 1518467820, \"api_app_id\": \"A123456\"}",
      event.envelope_decoder(),
    )
  let assert event.AppRateLimited(..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/app_requested.md example 0
pub fn app_requested_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"app_requested\", \"app_request\": {\"id\": \"1234\", \"app\": {\"id\": \"A5678\", \"name\": \"Brent's app\", \"description\": \"They're good apps, Bront.\", \"help_url\": \"brontsapp.com\", \"privacy_policy_url\": \"brontsapp.com\", \"app_homepage_url\": \"brontsapp.com\", \"app_directory_url\": \"https://slack.slack.com/apps/A102ARD7Y\", \"is_granular_bot_app\": true, \"is_app_directory_approved\": true, \"is_internal\": false, \"additional_info\": \"none\"}, \"previous_resolution\": {\"status\": \"approved\", \"scopes\": [{\"name\": \"app_requested\", \"description\": \"allows this app to listen for app install requests\", \"is_sensitive\": false, \"token_type\": \"user\", \"is_optional\": true, \"is_approved\": false}]}, \"user\": {\"id\": \"U1234\", \"name\": \"Bront\", \"email\": \"bront@brent.com\"}, \"team\": {\"id\": \"T1234\", \"name\": \"Brant App Team\", \"domain\": \"brantappteam\"}, \"enterprise\": null, \"scopes\": [{\"name\": \"app_requested\", \"description\": \"allows this app to listen for app install requests\", \"is_sensitive\": false, \"token_type\": \"user\", \"is_optional\": true, \"is_approved\": false}], \"message\": \"none\", \"manager_app_id\": \"A12345678\"}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.AppRequested(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/app_uninstalled.md example 0
pub fn app_uninstalled_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"app_uninstalled\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.AppUninstalled(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/app_uninstalled_team.md example 0
pub fn app_uninstalled_team_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"app_uninstalled_team\", \"app_id\": \"A015CA1LGHG\", \"app_name\": \"my-admin-app\", \"app_owner_id\": \"U013B64J7MSZ\", \"user_id\": \"U013B64J7SZ\", \"team_id\": \"E073D7H7BBE\", \"team_domain\": \"ACME Enterprises\", \"event_ts\": \"1700001891.279278\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.AppUninstalledTeam(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/assistant_thread_context_changed.md example 0
pub fn assistant_thread_context_changed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"assistant_thread_context_changed\", \"assistant_thread\": {\"user_id\": \"U123ABC456\", \"context\": {\"channel_id\": \"C123ABC456\", \"team_id\": \"T07XY8FPJ5C\", \"enterprise_id\": \"E480293PS82\"}, \"channel_id\": \"D123ABC456\", \"thread_ts\": \"1729999327.187299\"}, \"event_ts\": \"17298244.022142\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.AssistantThreadContextChanged(..),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/assistant_thread_started.md example 0
pub fn assistant_thread_started_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"assistant_thread_started\", \"assistant_thread\": {\"user_id\": \"U123ABC456\", \"context\": {\"channel_id\": \"C123ABC456\", \"team_id\": \"T07XY8FPJ5C\", \"enterprise_id\": \"E480293PS82\"}, \"channel_id\": \"D123ABC456\", \"thread_ts\": \"1729999327.187299\"}, \"event_ts\": \"1715873754.429808\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.AssistantThreadStarted(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/call_rejected.md example 0
pub fn call_rejected_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"12345FVmRUzNDOAu12345h\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"BBBU04BB4\", \"event\": {\"type\": \"call_rejected\", \"call_id\": \"R123ABC456\", \"user_id\": \"U123ABC456\", \"channel_id\": \"D123ABC456\", \"external_unique_id\": \"123-456-7890\"}, \"type\": \"event_callback\", \"event_id\": \"Ev123ABC456\", \"event_time\": 1563448153, \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}]}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.CallRejected(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/channel_archive.md example 0
pub fn channel_archive_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"channel_archive\", \"channel\": \"C123ABC456\", \"user\": \"U123ABC456\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.ChannelArchive(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/channel_created.md example 0
pub fn channel_created_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"channel_created\", \"channel\": {\"id\": \"C024BE91L\", \"name\": \"fun\", \"created\": 1360782804, \"creator\": \"U024BE7LH\"}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.ChannelCreated(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/channel_deleted.md example 0
pub fn channel_deleted_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"channel_deleted\", \"channel\": \"C123ABC456\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.ChannelDeleted(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/channel_history_changed.md example 0
pub fn channel_history_changed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"channel_history_changed\", \"latest\": \"1358877455.000010\", \"ts\": \"1361482916.000003\", \"event_ts\": \"1361482916.000004\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.ChannelHistoryChanged(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/channel_id_changed.md example 0
pub fn channel_id_changed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"channel_id_changed\", \"old_channel_id\": \"G012Y48650T\", \"new_channel_id\": \"C012Y48650T\", \"event_ts\": \"1612206778.000000\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.ChannelIdChanged(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/channel_left.md example 0
pub fn channel_left_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"channel_left\", \"channel\": \"C123ABC456\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.ChannelLeft(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/channel_rename.md example 0
pub fn channel_rename_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"channel_rename\", \"channel\": {\"id\": \"C02ELGNBH\", \"name\": \"new_name\", \"created\": 1360782804}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.ChannelRename(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/channel_shared.md example 0
pub fn channel_shared_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"channel_shared\", \"connected_team_id\": \"E163Q94DX\", \"channel\": \"C123ABC456\", \"event_ts\": \"1561064063.001100\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.ChannelShared(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/channel_unarchive.md example 0
pub fn channel_unarchive_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"channel_unarchive\", \"channel\": \"C123ABC456\", \"user\": \"U123ABC456\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.ChannelUnarchive(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/channel_unshared.md example 0
pub fn channel_unshared_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"channel_unshared\", \"previously_connected_team_id\": \"E163Q94DX\", \"channel\": \"C123ABC456\", \"is_ext_shared\": false, \"event_ts\": \"1561064063.001100\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.ChannelUnshared(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/dnd_updated.md example 0
pub fn dnd_updated_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"dnd_updated\", \"user\": \"U1234\", \"dnd_status\": {\"dnd_enabled\": true, \"next_dnd_start_ts\": 1450387800, \"next_dnd_end_ts\": 1450423800, \"snooze_enabled\": true, \"snooze_endtime\": 1450373897}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.DndUpdated(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/dnd_updated_user.md example 0
pub fn dnd_updated_user_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"dnd_updated_user\", \"user\": \"U123ABC456\", \"dnd_status\": {\"dnd_enabled\": true, \"next_dnd_start_ts\": 1450387800, \"next_dnd_end_ts\": 1450423800}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.DndUpdatedUser(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/email_domain_changed.md example 0
pub fn email_domain_changed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"email_domain_changed\", \"email_domain\": \"example.com\", \"event_ts\": \"1360782804.083113\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.EmailDomainChanged(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/emoji_changed.md example 0
pub fn emoji_changed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"emoji_changed\", \"subtype\": \"remove\", \"names\": [\"picard_facepalm\"], \"event_ts\": \"1361482916.000004\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.EmojiChanged(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/emoji_changed.md example 1
pub fn emoji_changed_1_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"emoji_changed\", \"subtype\": \"add\", \"name\": \"picard_facepalm\", \"value\": \"https://my.slack.com/emoji/picard_facepalm/db8e287430eaa459.gif\", \"event_ts\": \"1361482916.000004\"}",
      event.event_decoder(),
    )
  let assert event.EmojiChanged(..) = decoded
  round_trip_event(decoded)
}

/// .docs/reference/events/emoji_changed.md example 2
pub fn emoji_changed_2_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"emoji_changed\", \"subtype\": \"remove\", \"names\": [\"picard_facepalm\"], \"event_ts\": \"1361482916.000004\"}",
      event.event_decoder(),
    )
  let assert event.EmojiChanged(..) = decoded
  round_trip_event(decoded)
}

/// .docs/reference/events/emoji_changed.md example 3
pub fn emoji_changed_3_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"emoji_changed\", \"subtype\": \"rename\", \"old_name\": \"grin\", \"new_name\": \"cheese-grin\", \"value\": \"https://my.slack.com/emoji/picard_facepalm/db8e287430eaa459.gif\", \"event_ts\": \"1361482916.000004\"}",
      event.event_decoder(),
    )
  let assert event.EmojiChanged(..) = decoded
  round_trip_event(decoded)
}

/// .docs/reference/events/entity_comments_requested.md example 0
pub fn entity_comments_requested_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"entity_comments_requested\", \"user\": \"U0123456\", \"external_ref\": {\"id\": \"123\", \"type\": \"my-type\"}, \"entity_url\": \"https://example.com/document/123\", \"link\": {\"url\": \"https://example.com/document/123\", \"domain\": \"example.com\"}, \"cursor\": \"your_app_sourced_pagination_cursor\", \"limit\": 100, \"thread_root_id\": \"comment-unique-identifier-001\", \"event_ts\": \"123456789.1234566\", \"trigger_id\": \"1234567890123.1234567890123.abcdef01234567890abcdef012345689\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.EntityCommentsRequested(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/entity_details_requested.md example 0
pub fn entity_details_requested_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"entity_details_requested\", \"user\": \"U0123456\", \"external_ref\": {\"id\": \"123\", \"type\": \"my-type\"}, \"entity_url\": \"https://example.com/document/123\", \"link\": {\"url\": \"https://example.com/document/123\", \"domain\": \"example.com\"}, \"app_unfurl_url\": \"https://example.com/document/123?myquery=param\", \"event_ts\": \"123456789.1234566\", \"trigger_id\": \"1234567890123.1234567890123.abcdef01234567890abcdef012345689\", \"user_locale\": \"en-US\", \"channel\": \"C123ABC456\", \"message_ts\": \"1755035323.759739\", \"thread_ts\": \"1755035323.759739\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.EntityDetailsRequested(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/file_change.md example 0
pub fn file_change_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"file_change\", \"file_id\": \"F2147483862\", \"file\": {\"id\": \"F2147483862\"}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.FileChange(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/file_comment_deleted.md example 0
pub fn file_comment_deleted_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"file_comment_deleted\", \"comment\": \"Fc67890\", \"file_id\": \"F2147483862\", \"file\": {\"id\": \"F2147483862\"}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.FileCommentDeleted(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/file_created.md example 0
pub fn file_created_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"file_created\", \"file_id\": \"F2147483862\", \"file\": {\"id\": \"F2147483862\"}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.FileCreated(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/file_deleted.md example 0
pub fn file_deleted_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"file_deleted\", \"file_id\": \"F2147483862\", \"event_ts\": \"1361482916.000004\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.FileDeleted(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/file_public.md example 0
pub fn file_public_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"file_public\", \"file_id\": \"F2147483862\", \"file\": {\"id\": \"F2147483862\"}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.FilePublic(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/file_shared.md example 0
pub fn file_shared_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"file_shared\", \"channel_id\": \"D01315BHHSN\", \"file_id\": \"F2147483862\", \"user_id\": \"U0Z7K8SRH\", \"file\": {\"id\": \"F2147483862\"}, \"event_ts\": \"1617804931.000300\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.FileShared(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/file_unshared.md example 0
pub fn file_unshared_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"file_unshared\", \"file_id\": \"F2147483862\", \"file\": {\"id\": \"F2147483862\"}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.FileUnshared(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/function_executed.md example 0
pub fn function_executed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"function_executed\", \"function\": {\"id\": \"Fn123456789O\", \"callback_id\": \"sample_function\", \"title\": \"Sample function\", \"description\": \"Runs sample function\", \"type\": \"app\", \"input_parameters\": [{\"type\": \"slack#/reference/objects/user-object_id\", \"name\": \"user_id\", \"description\": \"Message recipient\", \"title\": \"User\", \"is_required\": true}], \"output_parameters\": [{\"type\": \"slack#/reference/objects/user-object_id\", \"name\": \"user_id\", \"description\": \"User that completed the function\", \"title\": \"Greeting\", \"is_required\": true}], \"app_id\": \"AP123456789\", \"date_created\": 1694727597, \"date_updated\": 1698947481, \"date_deleted\": 0}, \"inputs\": {\"user_id\": \"USER12345678\"}, \"function_execution_id\": \"Fx1234567O9L\", \"workflow_execution_id\": \"WxABC123DEF0\", \"event_ts\": \"1698958075.998738\", \"bot_access_token\": \"abcd-1325532282098-1322446258629-6123648410839-527a1cab3979cad288c9e20330d212cf\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.FunctionExecuted(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/grid_migration_finished.md example 0
pub fn grid_migration_finished_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"TXXXXXXXX\", \"api_app_id\": \"AXXXXXXXXX\", \"event\": {\"type\": \"grid_migration_finished\", \"enterprise_id\": \"EXXXXXXXX\"}, \"type\": \"event_callback\", \"event_id\": \"EvXXXXXXXX\", \"event_time\": 1234567890}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.GridMigrationFinished(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/grid_migration_started.md example 0
pub fn grid_migration_started_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"TXXXXXXXX\", \"api_app_id\": \"AXXXXXXXXX\", \"event\": {\"type\": \"grid_migration_started\", \"enterprise_id\": \"EXXXXXXXX\"}, \"type\": \"event_callback\", \"event_id\": \"EvXXXXXXXX\", \"event_time\": 1234567890}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.GridMigrationStarted(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/group_archive.md example 0
pub fn group_archive_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"group_archive\", \"channel\": \"G024BE91L\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.GroupArchive(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/group_close.md example 0
pub fn group_close_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"group_close\", \"user\": \"U024BE7LH\", \"channel\": \"G024BE91L\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.GroupClose(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/group_deleted.md example 0
pub fn group_deleted_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"group_deleted\", \"channel\": \"G0QN9RGTT\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.GroupDeleted(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/group_history_changed.md example 0
pub fn group_history_changed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"group_history_changed\", \"latest\": \"1358877455.000010\", \"ts\": \"1361482916.000003\", \"event_ts\": \"1361482916.000004\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.GroupHistoryChanged(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/group_left.md example 0
pub fn group_left_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"group_left\", \"channel\": \"G02ELGNBH\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.GroupLeft(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/group_open.md example 0
pub fn group_open_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"group_open\", \"user\": \"U024BE7LH\", \"channel\": \"G024BE91L\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.GroupOpen(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/group_rename.md example 0
pub fn group_rename_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"group_rename\", \"channel\": {\"id\": \"G02ELGNBH\", \"name\": \"new_name\", \"created\": 1360782804}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.GroupRename(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/group_unarchive.md example 0
pub fn group_unarchive_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"group_unarchive\", \"channel\": \"G024BE91L\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.GroupUnarchive(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/im_close.md example 0
pub fn im_close_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"im_close\", \"user\": \"U024BE7LH\", \"channel\": \"D024BE91L\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.ImClose(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/im_created.md example 0
pub fn im_created_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"im_created\", \"user\": \"U024BE7LH\", \"channel\": {\"id\": \"C0123456\", \"is_im\": true, \"user\": \"U0123456\", \"created\": 1355517521, \"is_org_shared\": false}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.ImCreated(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/im_history_changed.md example 0
pub fn im_history_changed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"im_history_changed\", \"latest\": \"1358877455.000010\", \"ts\": \"1361482916.000003\", \"event_ts\": \"1361482916.000004\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.ImHistoryChanged(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/im_open.md example 0
pub fn im_open_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"im_open\", \"user\": \"U024BE7LH\", \"channel\": \"D024BE91L\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.ImOpen(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/invite_requested.md example 0
pub fn invite_requested_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"invite_requested\", \"invite_request\": {\"id\": \"12345\", \"email\": \"bront@puppies.com\", \"date_created\": 123455, \"requester_ids\": [\"U123ABC456\"], \"channel_ids\": [\"C123ABC456\"], \"invite_type\": \"full_member\", \"real_name\": \"Brent\", \"date_expire\": 123456, \"request_reason\": \"They're good dogs, Brant\", \"team\": {\"id\": \"T12345\", \"name\": \"Puppy ratings workspace incorporated\", \"domain\": \"puppiesrus\"}}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.InviteRequested(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/link_shared.md example 0
pub fn link_shared_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"link_shared\", \"channel\": \"C123ABC456\", \"is_bot_user_member\": true, \"is_unfurl_refresh\": true, \"user\": \"U123ABC456\", \"message_ts\": \"123456789.9875\", \"unfurl_id\": \"C123456.123456789.987501.1b90fa1278528ce6e2f6c5c2bfa1abc9a41d57d02b29d173f40399c9ffdecf4b\", \"thread_ts\": \"123456621.1855\", \"source\": \"conversations_history\", \"links\": [{\"domain\": \"example.com\", \"url\": \"https://example.com/12345\"}, {\"domain\": \"example.com\", \"url\": \"https://example.com/67890\"}, {\"domain\": \"another-example.com\", \"url\": \"https://yet.another-example.com/v/abcde\"}], \"user_locale\": \"en-US\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.LinkShared(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/link_shared.md example 1
pub fn link_shared_1_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"link_shared\", \"channel\": \"COMPOSER\", \"is_bot_user_member\": true, \"user\": \"U123ABC456\", \"message_ts\": \"U123ABC456-909b5454-75f8-4ac4-b325-1b40e230bbd8-gryl3kb80b3wm49ihzoo35fyqoq08n2y\", \"unfurl_id\": \"U123ABC456-909b5454-75f8-4ac4-b325-1b40e230bbd8-gryl3kb80b3wm49ihzoo35fyqoq08n2y\", \"source\": \"composer\", \"links\": [{\"domain\": \"example.com\", \"url\": \"https://example.com/12345\"}, {\"domain\": \"example.com\", \"url\": \"https://example.com/67890\"}, {\"domain\": \"another-example.com\", \"url\": \"https://yet.another-example.com/v/abcde\"}], \"user_locale\": \"en-US\"}",
      event.event_decoder(),
    )
  let assert event.LinkShared(..) = decoded
  round_trip_event(decoded)
}

/// .docs/reference/events/member_joined_channel.md example 0
pub fn member_joined_channel_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"member_joined_channel\", \"user\": \"W123ABC456\", \"channel\": \"C123ABC456\", \"channel_type\": \"C\", \"team\": \"T123ABC456\", \"inviter\": \"U123456789\", \"enterprise\": \"E123456789\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"W123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.MemberJoinedChannel(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/member_joined_channel.md example 1
pub fn member_joined_channel_1_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"member_joined_channel\", \"user\": \"W123ABC456\", \"channel\": \"G123ABC456\", \"channel_type\": \"G\", \"team\": \"T123ABC456\"}",
      event.event_decoder(),
    )
  let assert event.MemberJoinedChannel(..) = decoded
  round_trip_event(decoded)
}

/// .docs/reference/events/member_left_channel.md example 0
pub fn member_left_channel_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"member_left_channel\", \"user\": \"W123ABC456\", \"channel\": \"C123ABC456\", \"channel_type\": \"C\", \"team\": \"T123ABC456\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"W123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.MemberLeftChannel(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

pub fn parse_url_verification_test() {
  let assert Ok(event.UrlVerification(challenge: "abc", token: _)) =
    event.parse("{\"type\": \"url_verification\", \"challenge\": \"abc\"}")
}

pub fn unknown_event_keeps_raw_json_test() {
  let assert Ok(event.UnknownEvent(type_: "brand_new_event", raw: _)) =
    event.parse_inner("{\"type\": \"brand_new_event\", \"x\": 1}")
}

pub fn unknown_message_subtype_keeps_raw_json_test() {
  let assert Ok(event.MessageEvent(event.UnknownMessageEvent(
    subtype: "brand_new",
    raw: _,
  ))) = event.parse_inner("{\"type\": \"message\", \"subtype\": \"brand_new\"}")
}

pub fn plain_message_encodes_type_without_subtype_test() {
  let assert Ok(decoded) =
    event.parse_inner(
      "{\"type\": \"message\", \"channel\": \"C1\", \"ts\": \"1.2\", \"channel_type\": \"im\"}",
    )
  let assert event.MessageEvent(event.PlainMessage(
    channel_type: option.Some(event.Im),
    ..,
  )) = decoded
  assert json.to_string(event.event_to_json(decoded))
    == "{\"type\":\"message\",\"channel\":\"C1\",\"ts\":\"1.2\",\"channel_type\":\"im\"}"
}

pub fn subtype_message_encodes_type_and_subtype_test() {
  let assert Ok(decoded) =
    event.parse_inner(
      "{\"type\": \"message\", \"subtype\": \"message_deleted\", \"channel\": \"C1\", \"ts\": \"1.2\", \"deleted_ts\": \"1.1\"}",
    )
  assert json.to_string(event.event_to_json(decoded))
    == "{\"subtype\":\"message_deleted\",\"type\":\"message\",\"channel\":\"C1\",\"ts\":\"1.2\",\"deleted_ts\":\"1.1\"}"
}
