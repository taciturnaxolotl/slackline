//// Decodes the json examples on the Events API reference pages, from
//// `pin_added` to `user_status_changed`.

import gleam/json
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

/// .docs/reference/events/pin_added.md example 0
pub fn pin_added_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"pin_added\", \"user\": \"U123ABC456\", \"channel_id\": \"C02ELGNBH\", \"item\": {}, \"event_ts\": \"1360782804.083113\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.PinAdded(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/pin_removed.md example 0
pub fn pin_removed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"pin_removed\", \"user\": \"U123ABC456\", \"channel_id\": \"C02ELGNBH\", \"item\": {}, \"has_pins\": false, \"event_ts\": \"1360782804.083113\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.PinRemoved(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/reaction_added.md example 0
pub fn reaction_added_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"reaction_added\", \"user\": \"U123ABC456\", \"reaction\": \"thumbsup\", \"item_user\": \"U222222222\", \"item\": {\"type\": \"message\", \"channel\": \"C123ABC456\", \"ts\": \"1360782400.498405\", \"channel_type\": \"channel\"}, \"event_ts\": \"1360782804.083113\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.ReactionAdded(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/reaction_added.md example 1 (embedded item)
pub fn reaction_added_1_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"message\", \"channel\": \"C123ABC456\", \"ts\": \"1360782400.498405\"}",
      event.reaction_item_decoder(),
    )
  let assert False = case decoded {
    event.UnknownReactionItem(..) -> True
    _ -> False
  }
}

/// .docs/reference/events/reaction_added.md example 2 (embedded item)
pub fn reaction_added_2_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"file\", \"file\": \"F123ABC456\"}",
      event.reaction_item_decoder(),
    )
  let assert False = case decoded {
    event.UnknownReactionItem(..) -> True
    _ -> False
  }
}

/// .docs/reference/events/reaction_added.md example 3 (embedded item)
pub fn reaction_added_3_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"file_comment\", \"file_comment\": \"Fc123ABC456\", \"file\": \"F123ABC456\"}",
      event.reaction_item_decoder(),
    )
  let assert False = case decoded {
    event.UnknownReactionItem(..) -> True
    _ -> False
  }
}

/// .docs/reference/events/reaction_removed.md example 0
pub fn reaction_removed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"reaction_removed\", \"user\": \"U123ABC456\", \"reaction\": \"thumbsup\", \"item_user\": \"U222222222\", \"item\": {\"type\": \"message\", \"channel\": \"C123ABC456\", \"ts\": \"1360782400.498405\", \"channel_type\": \"channel\"}, \"event_ts\": \"1360782804.083113\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.ReactionRemoved(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/reaction_removed.md example 1 (embedded item)
pub fn reaction_removed_1_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"message\", \"channel\": \"C123ABC456\", \"ts\": \"1360782400.498405\"}",
      event.reaction_item_decoder(),
    )
  let assert False = case decoded {
    event.UnknownReactionItem(..) -> True
    _ -> False
  }
}

/// .docs/reference/events/reaction_removed.md example 2 (embedded item)
pub fn reaction_removed_2_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"file\", \"file\": \"F123ABC456\"}",
      event.reaction_item_decoder(),
    )
  let assert False = case decoded {
    event.UnknownReactionItem(..) -> True
    _ -> False
  }
}

/// .docs/reference/events/reaction_removed.md example 3 (embedded item)
pub fn reaction_removed_3_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"type\": \"file_comment\", \"file_comment\": \"Fc123ABC456\", \"file\": \"F123ABC456\"}",
      event.reaction_item_decoder(),
    )
  let assert False = case decoded {
    event.UnknownReactionItem(..) -> True
    _ -> False
  }
}

/// .docs/reference/events/shared_channel_invite_accepted.md example 0
pub fn shared_channel_invite_accepted_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"shared_channel_invite_accepted\", \"approval_required\": false, \"invite\": {\"id\": \"I028YDERZSQ\", \"date_created\": 1626876000, \"date_invalid\": 1628085600, \"inviting_team\": {\"id\": \"T12345678\", \"name\": \"Corgis\", \"icon\": {}, \"is_verified\": false, \"domain\": \"corgis\", \"date_created\": 1480946400}, \"inviting_user\": {\"id\": \"U12345678\", \"team_id\": \"T12345678\", \"name\": \"crus\", \"updated\": 1608081902, \"profile\": {\"real_name\": \"Corgis Rus\", \"display_name\": \"Corgis Rus\", \"real_name_normalized\": \"Corgis Rus\", \"display_name_normalized\": \"Corgis Rus\", \"team\": \"T12345678\", \"avatar_hash\": \"gcfh83a4c72k\", \"email\": \"corgisrus@slack-corp.com\", \"image_24\": \"https://placekitten.com/24/24\", \"image_32\": \"https://placekitten.com/32/32\", \"image_48\": \"https://placekitten.com/48/48\", \"image_72\": \"https://placekitten.com/72/72\", \"image_192\": \"https://placekitten.com/192/192\", \"image_512\": \"https://placekitten.com/512/512\"}}, \"recipient_email\": \"golden@doodle.com\", \"recipient_user_id\": \"U87654321\"}, \"channel\": {\"id\": \"C12345678\", \"is_private\": false, \"is_im\": false, \"name\": \"test-slack-connect\"}, \"teams_in_channel\": [{\"id\": \"T12345678\", \"name\": \"Corgis\", \"icon\": {}, \"is_verified\": false, \"domain\": \"corgis\", \"date_created\": 1626789600}], \"accepting_user\": {\"id\": \"U87654321\", \"team_id\": \"T87654321\", \"name\": \"golden\", \"updated\": 1624406113, \"profile\": {\"real_name\": \"Golden Doodle\", \"display_name\": \"Golden\", \"real_name_normalized\": \"Golden Doodle\", \"display_name_normalized\": \"Golden\", \"team\": \"T87654321\", \"avatar_hash\": \"g717728b118x\", \"email\": \"golden@doodle.com\", \"image_24\": \"https://placekitten.com/24/24\", \"image_32\": \"https://placekitten.com/32/32\", \"image_48\": \"https://placekitten.com/48/48\", \"image_72\": \"https://placekitten.com/72/72\", \"image_192\": \"https://placekitten.com/192/192\", \"image_512\": \"https://placekitten.com/512/512\"}}, \"event_ts\": \"1626877800.000000\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U12345678\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.SharedChannelInviteAccepted(..),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/shared_channel_invite_approved.md example 0
pub fn shared_channel_invite_approved_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"shared_channel_invite_approved\", \"invite\": {\"id\": \"I01354X80CA\", \"date_created\": 1626876000, \"date_invalid\": 1628085600, \"inviting_team\": {\"id\": \"T12345678\", \"name\": \"Corgis\", \"icon\": {}, \"is_verified\": false, \"domain\": \"corgis\", \"date_created\": 1480946400}, \"inviting_user\": {\"id\": \"U12345678\", \"team_id\": \"T12345678\", \"name\": \"crus\", \"updated\": 1608081902, \"profile\": {\"real_name\": \"Corgis Rus\", \"display_name\": \"Corgis Rus\", \"real_name_normalized\": \"Corgis Rus\", \"display_name_normalized\": \"Corgis Rus\", \"team\": \"T12345678\", \"avatar_hash\": \"gcfh83a4c72k\", \"email\": \"corgisrus@slack-corp.com\", \"image_24\": \"https://placekitten.com/24/24\", \"image_32\": \"https://placekitten.com/32/32\", \"image_48\": \"https://placekitten.com/48/48\", \"image_72\": \"https://placekitten.com/72/72\", \"image_192\": \"https://placekitten.com/192/192\", \"image_512\": \"https://placekitten.com/512/512\"}}, \"recipient_email\": \"golden@doodle.com\", \"recipient_user_id\": \"U87654321\"}, \"channel\": {\"id\": \"C12345678\", \"is_private\": false, \"is_im\": false, \"name\": \"test-slack-connect\"}, \"approving_team_id\": \"T87654321\", \"teams_in_channel\": [{\"id\": \"T12345678\", \"name\": \"Corgis\", \"icon\": {}, \"is_verified\": false, \"domain\": \"corgis\", \"date_created\": 1626789600}], \"approving_user\": {\"id\": \"U012A3CDE\", \"team_id\": \"T87654321\", \"name\": \"spengler\", \"updated\": 1624406532, \"profile\": {\"real_name\": \"Egon Spengler\", \"display_name\": \"Egon\", \"real_name_normalized\": \"Egon Spengler\", \"display_name_normalized\": \"Egon\", \"team\": \"T87654321\", \"avatar_hash\": \"g216425b1681\", \"email\": \"spengler@ghostbusters.example.com\", \"image_24\": \"https://placekitten.com/24/24\", \"image_32\": \"https://placekitten.com/32/32\", \"image_48\": \"https://placekitten.com/48/48\", \"image_72\": \"https://placekitten.com/72/72\", \"image_192\": \"https://placekitten.com/192/192\", \"image_512\": \"https://placekitten.com/512/512\"}}, \"event_ts\": \"1626881400.000000\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U012A3CDE\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.SharedChannelInviteApproved(..),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/shared_channel_invite_declined.md example 0
pub fn shared_channel_invite_declined_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"shared_channel_invite_declined\", \"invite\": {\"id\": \"I01354X80CA\", \"date_created\": 1626876000, \"date_invalid\": 1628085600, \"inviting_team\": {\"id\": \"T12345678\", \"name\": \"Corgis\", \"icon\": {}, \"is_verified\": false, \"domain\": \"corgis\", \"date_created\": 1480946400}, \"inviting_user\": {\"id\": \"U12345678\", \"team_id\": \"T12345678\", \"name\": \"crus\", \"updated\": 1608081902, \"profile\": {\"real_name\": \"Corgis Rus\", \"display_name\": \"Corgis Rus\", \"real_name_normalized\": \"Corgis Rus\", \"display_name_normalized\": \"Corgis Rus\", \"team\": \"T12345678\", \"avatar_hash\": \"gcfh83a4c72k\", \"email\": \"corgisrus@slack-corp.com\", \"image_24\": \"https://placekitten.com/24/24\", \"image_32\": \"https://placekitten.com/32/32\", \"image_48\": \"https://placekitten.com/48/48\", \"image_72\": \"https://placekitten.com/72/72\", \"image_192\": \"https://placekitten.com/192/192\", \"image_512\": \"https://placekitten.com/512/512\"}}, \"recipient_email\": \"golden@doodle.com\"}, \"channel\": {\"id\": \"C12345678\", \"is_private\": false, \"is_im\": false, \"name\": \"test-slack-connect\"}, \"declining_team_id\": \"T87654321\", \"teams_in_channel\": [{\"id\": \"T12345678\", \"name\": \"Corgis\", \"icon\": {}, \"is_verified\": false, \"domain\": \"corgis\", \"date_created\": 1626789600}], \"declining_user\": {\"id\": \"U012A3CDE\", \"team_id\": \"T87654321\", \"name\": \"spengler\", \"updated\": 1624406532, \"profile\": {\"real_name\": \"Egon Spengler\", \"display_name\": \"Egon\", \"real_name_normalized\": \"Egon Spengler\", \"display_name_normalized\": \"Egon\", \"team\": \"T87654321\", \"avatar_hash\": \"g216425b1681\", \"email\": \"spengler@ghostbusters.example.com\", \"image_24\": \"https://placekitten.com/24/24\", \"image_32\": \"https://placekitten.com/32/32\", \"image_48\": \"https://placekitten.com/48/48\", \"image_72\": \"https://placekitten.com/72/72\", \"image_192\": \"https://placekitten.com/192/192\", \"image_512\": \"https://placekitten.com/512/512\"}}, \"event_ts\": \"1626881400.000000\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U012A3CDE\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.SharedChannelInviteDeclined(..),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/shared_channel_invite_received.md example 0
pub fn shared_channel_invite_received_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"shared_channel_invite_received\", \"invite\": {\"id\": \"I028YDERZSQ\", \"date_created\": 1626876000, \"date_invalid\": 1628085600, \"inviting_team\": {\"id\": \"T12345678\", \"name\": \"Corgis\", \"icon\": {}, \"is_verified\": false, \"domain\": \"corgis\", \"date_created\": 1480946400}, \"inviting_user\": {\"id\": \"U12345678\", \"team_id\": \"T12345678\", \"name\": \"crus\", \"updated\": 1608081902, \"profile\": {\"real_name\": \"Corgis Rus\", \"display_name\": \"Corgis Rus\", \"real_name_normalized\": \"Corgis Rus\", \"display_name_normalized\": \"Corgis Rus\", \"team\": \"T12345678\", \"avatar_hash\": \"gcfh83a4c72k\", \"email\": \"corgisrus@slack-corp.com\", \"image_24\": \"https://placekitten.com/24/24\", \"image_32\": \"https://placekitten.com/32/32\", \"image_48\": \"https://placekitten.com/48/48\", \"image_72\": \"https://placekitten.com/72/72\", \"image_192\": \"https://placekitten.com/192/192\", \"image_512\": \"https://placekitten.com/512/512\"}}, \"recipient_user_id\": \"U87654321\"}, \"channel\": {\"id\": \"C12345678\", \"is_private\": false, \"is_im\": false, \"name\": \"test-slack-connect\"}, \"event_ts\": \"1626876010.000100\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U12345678\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.SharedChannelInviteReceived(..),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/shared_channel_invite_requested.md example 1
pub fn shared_channel_invite_requested_1_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"shared_channel_invite_requested\", \"channel\": {\"id\": \"C0123ABCDEF\", \"is_im\": false, \"is_private\": false, \"date_created\": 1564642828, \"message_latest_counted_timestamp\": 1564642836000009, \"name\": \"host-team12345678999\"}, \"actor\": {\"id\": \"U012345ABCD\", \"team_id\": \"E01234ABC\", \"name\": \"username-012345ABCD\", \"updated\": 1564642800, \"who_can_share_contact_card\": \"EVERYONE\", \"profile\": {\"real_name\": \"User Name\", \"display_name\": \"Username\", \"real_name_normalized\": \"User Name\", \"display_name_normalized\": \"Username\", \"team\": \"E01234ABC\", \"avatar_hash\": \"g12345678910\", \"email\": \"mock-user@some-corp.com\", \"image_24\": \"https://secure.gravatar.com/avatar/5efa915c16f10de52e23f4a8b8da612e.jpg?s=24&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1718734113%2Fimg%2Favatars%2Fuser_shapes%2Fava_0010-24.png\"}}, \"is_external_limited\": true, \"target_users\": [{\"invite_id\": \"I01234ABC\", \"email\": \"mock-user@some-corp.com\"}], \"teams_in_channel\": [{\"id\": \"E01234ABC\", \"name\": \"Team Name\", \"icon\": {\"image_34\": \"https://some-corp.com/v123/img/avatars-teams/ava_123.png\", \"image_default\": true}, \"avatar_base_url\": \"https://some-corp.com\", \"is_verified\": false, \"domain\": \"domain-10000000000\", \"date_created\": 1564642800, \"requires_sponsorship\": false}, {\"id\": \"E56789DEF\", \"name\": \"Team Name\", \"icon\": {\"image_34\": \"https://some-corp.com/v456/img/avatars-teams/ava_456.png\", \"image_default\": true}, \"avatar_base_url\": \"https://some-corp.com\", \"is_verified\": false, \"domain\": \"domain-10000000123\", \"date_created\": 1564642800, \"requires_sponsorship\": false}]}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(
    event: event.SharedChannelInviteRequested(..),
    ..,
  ) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/star_added.md example 0
pub fn star_added_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"star_added\", \"user\": \"U123ABC456\", \"item\": {}, \"event_ts\": \"1360782804.083113\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.StarAdded(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/star_removed.md example 0
pub fn star_removed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"star_removed\", \"user\": \"U123ABC456\", \"item\": {}, \"event_ts\": \"1360782804.083113\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.StarRemoved(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/subteam_created.md example 0
pub fn subteam_created_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"subteam_created\", \"subteam\": {\"id\": \"S0615G0KT\", \"team_id\": \"T060RNRCH\", \"is_usergroup\": true, \"name\": \"Marketing Team\", \"description\": \"Marketing gurus, PR experts and product advocates.\", \"handle\": \"marketing-team\", \"is_external\": false, \"date_create\": 1446746793, \"date_update\": 1446746793, \"date_delete\": 0, \"auto_type\": null, \"created_by\": \"U060RNRCZ\", \"updated_by\": \"U060RNRCZ\", \"deleted_by\": null, \"prefs\": {\"channels\": [], \"groups\": []}, \"user_count\": \"0\"}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.SubteamCreated(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/subteam_members_changed.md example 0
pub fn subteam_members_changed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"subteam_members_changed\", \"subteam_id\": \"S123ABC456\", \"team_id\": \"T060RNRCH\", \"date_previous_update\": 1446670362, \"date_update\": 1492906952, \"added_users\": [\"U060RNRCZ\", \"U060ULRC0\", \"U061309JM\"], \"added_users_count\": \"3\", \"removed_users\": [\"U06129G2V\"], \"removed_users_count\": \"1\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.SubteamMembersChanged(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/subteam_self_added.md example 0
pub fn subteam_self_added_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"subteam_self_added\", \"subteam_id\": \"S0615G0KT\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.SubteamSelfAdded(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/subteam_self_removed.md example 0
pub fn subteam_self_removed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"subteam_self_removed\", \"subteam_id\": \"S0615G0KT\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.SubteamSelfRemoved(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/subteam_updated.md example 0
pub fn subteam_updated_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"subteam_updated\", \"subteam\": {\"id\": \"S516MPG9X\", \"team_id\": \"T0GMXV71T\", \"is_usergroup\": true, \"is_subteam\": true, \"name\": \"My User Group Test\", \"description\": \"User Group Test\", \"handle\": \"user-group-test\", \"is_external\": false, \"date_create\": 1492655498, \"date_update\": 1595814882, \"date_delete\": 0, \"auto_type\": null, \"auto_provision\": false, \"enterprise_subteam_id\": \"\", \"created_by\": \"U0GN26UBG\", \"updated_by\": \"U0GN26UBG\", \"deleted_by\": null, \"prefs\": {\"channels\": [\"CJG07GZDK\"], \"groups\": []}, \"users\": [\"U123ABC456\", \"U0GNBSG1G\", \"U0K0XMM2R\", \"U1FLR7FB8\", \"U3S7347ED\", \"U5ZR5M0FM\", \"U600XRXS9\"], \"user_count\": 7, \"channel_count\": 0}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.SubteamUpdated(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/team_access_granted.md example 0
pub fn team_access_granted_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": null, \"api_app_id\": \"AXXXX\", \"type\": \"event_callback\", \"authorizations\": [{\"enterprise_id\": \"EXXXXX\", \"team_id\": \"T123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789, \"enterprise_id\": \"EXXXXX\", \"event\": {\"type\": \"team_access_granted\", \"team_ids\": [\"T1XX3\", \"TXX34\"]}}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.TeamAccessGranted(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/team_access_revoked.md example 0
pub fn team_access_revoked_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": null, \"api_app_id\": \"AXXXX\", \"type\": \"event_callback\", \"authorizations\": [{\"enterprise_id\": \"EXXXXX\", \"team_id\": \"T123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789, \"enterprise_id\": \"EXXXXX\", \"event\": {\"type\": \"team_access_revoked\", \"team_ids\": [\"T1XX3\", \"TXX34\"]}}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.TeamAccessRevoked(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/team_domain_change.md example 0
pub fn team_domain_change_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"team_domain_change\", \"url\": \"https://my.slack.com\", \"domain\": \"my\", \"team_id\": \"T1234\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.TeamDomainChange(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/team_join.md example 0
pub fn team_join_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"team_join\", \"user\": {\"id\": \"U123ABC456\"}}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.TeamJoin(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/team_rename.md example 0
pub fn team_rename_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"team_rename\", \"name\": \"New Team Name Inc.\", \"team_id\": \"T1234\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.TeamRename(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/tokens_revoked.md example 0
pub fn tokens_revoked_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"TXXXXXXXX\", \"api_app_id\": \"AXXXXXXXXX\", \"event\": {\"type\": \"tokens_revoked\", \"tokens\": {\"oauth\": [\"UXXXXXXXX\"], \"bot\": [\"UXXXXXXXX\"]}}, \"type\": \"event_callback\", \"event_id\": \"EvXXXXXXXX\", \"event_time\": 1234567890}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.TokensRevoked(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/url_verification.md example 0
pub fn url_verification_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"Jhj5dZrVaK7ZwHHjRyZWjbDl\", \"challenge\": \"3eZbrw1aBm2rZgRNFdxV2595E9CY3gmdALWMmHkvFXO7tYXAYM8P\", \"type\": \"url_verification\"}",
      event.envelope_decoder(),
    )
  let assert event.UrlVerification(..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/user_change.md example 0
pub fn user_change_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"user\": {\"id\": \"U1234567\", \"team_id\": \"T1234567\", \"name\": \"some-user\", \"deleted\": false, \"color\": \"4bbe2e\", \"real_name\": \"Some User\", \"tz\": \"America/Los_Angeles\", \"tz_label\": \"Pacific Daylight Time\", \"tz_offset\": -25200, \"profile\": {\"title\": \"\", \"phone\": \"\", \"skype\": \"\", \"real_name\": \"Some User\", \"real_name_normalized\": \"Some User\", \"display_name\": \"\", \"display_name_normalized\": \"\", \"fields\": {}, \"status_text\": \"riding a train\", \"status_emoji\": \":mountain_railway:\", \"status_emoji_display_info\": [], \"status_expiration\": 0, \"avatar_hash\": \"g12345678910\", \"first_name\": \"Some\", \"last_name\": \"User\", \"image_24\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=24&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-24.png\", \"image_32\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=32&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-32.png\", \"image_48\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=48&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-48.png\", \"image_72\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=72&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-72.png\", \"image_192\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=192&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-192.png\", \"image_512\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=512&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-512.png\", \"status_text_canonical\": \"\", \"team\": \"T1234567\"}, \"is_admin\": false, \"is_owner\": false, \"is_primary_owner\": false, \"is_restricted\": false, \"is_ultra_restricted\": false, \"is_bot\": false, \"is_app_user\": false, \"updated\": 1648596421, \"is_email_confirmed\": true, \"who_can_share_contact_card\": \"EVERYONE\", \"locale\": \"en-US\"}, \"cache_ts\": 1648596421, \"type\": \"user_change\", \"event_ts\": \"1648596712.000001\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U1234567\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.UserChange(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/user_connection.md example 0
pub fn user_connection_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"P1GEyKehpM8yI998PLwq0P66\", \"team_id\": \"E012A3BC4DE\", \"api_app_id\": \"A012ABC34DE\", \"event\": {\"type\": \"user_connection\", \"subtype\": \"connect\", \"user\": \"U012A3BC4DE\", \"trigger_id\": \"1293638028594.1249184885746.0d121a0e01d2e7a795ecc7a62880a406\", \"event_ts\": \"1764264284.841251\"}, \"type\": \"event_callback\", \"event_id\": \"Ev012A3BCDEF\", \"event_time\": 1764264284}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.UserConnection(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/user_connection.md example 1
pub fn user_connection_1_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"P1GEyKehpM8yI998PLwq0P66\", \"team_id\": \"E012A3BC4DE\", \"api_app_id\": \"A012ABC34DE\", \"event\": {\"type\": \"user_connection\", \"subtype\": \"disconnect\", \"enterprise_id\": \"E012A3BC4DE\", \"user\": \"U012A3BC4DE\", \"event_ts\": \"1764264317.061589\"}, \"type\": \"event_callback\", \"event_id\": \"Ev012A3BCDEF\", \"event_time\": 1764264317}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.UserConnection(..), ..) = decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/user_guest_status_changed.md example 0
pub fn user_guest_status_changed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"user_guest_status_changed\", \"user\": {\"id\": \"U1234567\", \"team_id\": \"T1234567\", \"name\": \"sandraslacksalot\", \"deleted\": false, \"color\": \"4bbe2e\", \"real_name\": \"Sandra Slacksalot\", \"tz\": \"America/Los_Angeles\", \"tz_label\": \"Pacific Daylight Time\", \"tz_offset\": -25200, \"profile\": {\"title\": \"\", \"phone\": \"\", \"skype\": \"\", \"real_name\": \"Sandra Slacksalot\", \"real_name_normalized\": \"Sandra Slacksalot\", \"display_name\": \"sandraslacksalot\", \"display_name_normalized\": \"sandraslacksalot\", \"fields\": {}, \"status_text\": \"\", \"status_emoji\": \"\", \"status_emoji_display_info\": [], \"status_expiration\": 0, \"avatar_hash\": \"g12345678910\", \"first_name\": \"Sandra\", \"last_name\": \"Slacksalot\", \"image_24\": \"https://a.slack-edge.com/.../img_24.jpg\", \"image_32\": \"https://a.slack-edge.com/.../img_32.jpg\", \"image_48\": \"https://a.slack-edge.com/.../img_48.jpg\", \"image_72\": \"https://a.slack-edge.com/.../img_72.jpg\", \"image_192\": \"https://a.slack-edge.com/.../img_192.jpg\", \"image_512\": \"https://a.slack-edge.com/.../img_512.jpg\", \"status_text_canonical\": \"\", \"team\": \"T1234567\"}, \"is_admin\": false, \"is_owner\": false, \"is_primary_owner\": false, \"is_restricted\": true, \"is_ultra_restricted\": false, \"is_bot\": false, \"is_app_user\": false, \"updated\": 1758000000, \"is_email_confirmed\": true, \"who_can_share_contact_card\": \"EVERYONE\", \"locale\": \"en-US\"}, \"cache_ts\": 1758000000, \"event_ts\": \"1758000000.000100\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U1234567\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 1758000000}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.UserGuestStatusChanged(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/user_huddle_changed.md example 0
pub fn user_huddle_changed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"user_huddle_changed\", \"user\": {\"id\": \"U1234567\", \"team_id\": \"T1234567\", \"name\": \"some-user\", \"deleted\": false, \"color\": \"4bbe2e\", \"real_name\": \"Some User\", \"tz\": \"America/Los_Angeles\", \"tz_label\": \"Pacific Daylight Time\", \"tz_offset\": -25200, \"profile\": {\"title\": \"\", \"phone\": \"\", \"skype\": \"\", \"real_name\": \"Some User\", \"real_name_normalized\": \"Some User\", \"display_name\": \"\", \"display_name_normalized\": \"\", \"fields\": {}, \"status_text\": \"riding a train\", \"status_emoji\": \":mountain_railway:\", \"status_emoji_display_info\": [], \"status_expiration\": 0, \"avatar_hash\": \"g12345678910\", \"huddle_state\": \"in_a_huddle\", \"huddle_state_expiration_ts\": 1746217265, \"huddle_state_call_id\": \"R017QJ4PEN7\", \"first_name\": \"Some\", \"last_name\": \"User\", \"image_24\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=24&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-24.png\", \"image_32\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=32&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-32.png\", \"image_48\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=48&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-48.png\", \"image_72\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=72&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-72.png\", \"image_192\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=192&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-192.png\", \"image_512\": \"https://secure.gravatar.com/avatar/cb0c2b2ca5e8de16be31a55a734d0f31.jpg?s=512&d=https%3A%2F%2Fdev.slack.com%2Fdev-cdn%2Fv1648136338%2Fimg%2Favatars%2Fuser_shapes%2Fava_0001-512.png\", \"status_text_canonical\": \"\", \"team\": \"T1234567\"}, \"is_admin\": false, \"is_owner\": false, \"is_primary_owner\": false, \"is_restricted\": false, \"is_ultra_restricted\": false, \"is_bot\": false, \"is_app_user\": false, \"updated\": 1648596421, \"is_email_confirmed\": true, \"who_can_share_contact_card\": \"EVERYONE\", \"locale\": \"en-US\"}, \"cache_ts\": 1648596421, \"event_ts\": \"1648596712.000001\"}, \"type\": \"event_callback\", \"authorizations\": [{\"team_id\": \"T123ABC456\", \"user_id\": \"U1234567\", \"is_bot\": false, \"is_enterprise_install\": false}], \"event_id\": \"Ev123ABC456\", \"event_time\": 123456789}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.UserHuddleChanged(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/user_profile_changed.md example 0
pub fn user_profile_changed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"user_profile_changed\", \"user\": {\"id\": \"U123ABC456\", \"team_id\": \"T123ABC456\", \"name\": \"sandraslacksalot\", \"profile\": {\"avatar_hash\": \"gexxxyyyzzz\", \"first_name\": \"Sandra\", \"last_name\": \"Slacksalot\", \"real_name\": \"Sandra Slacksalot\", \"display_name\": \"sandraslacksalot\", \"real_name_normalized\": \"Sandra Slacksalot\", \"display_name_normalized\": \"sandraslacksalot\", \"image_72\": \"https://example.com/img/72.png\"}, \"updated\": 1734567890}, \"cache_ts\": 1734567890, \"event_ts\": \"1734567890.000001\"}, \"type\": \"event_callback\", \"event_id\": \"Ev0123ABC456\", \"event_time\": 1734567890}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.UserProfileChanged(..), ..) =
    decoded
  round_trip_envelope(decoded)
}

/// .docs/reference/events/user_status_changed.md example 0
pub fn user_status_changed_0_test() {
  let assert Ok(decoded) =
    json.parse(
      "{\"token\": \"XXYYZZ\", \"team_id\": \"T123ABC456\", \"api_app_id\": \"A123ABC456\", \"event\": {\"type\": \"user_status_changed\", \"user\": {\"id\": \"U123ABC456\", \"team_id\": \"T123ABC456\", \"name\": \"sandraslacksalot\", \"profile\": {\"avatar_hash\": \"gexxxyyyzzz\", \"status_text\": \"Commuting to office!\", \"status_emoji\": \":docs-team-in-transit:\", \"status_expiration\": 0, \"real_name\": \"Sandra Slacksalot\", \"display_name\": \"sandraslacksalot\", \"real_name_normalized\": \"Sandra Slacksalot\", \"display_name_normalized\": \"sandraslacksalot\", \"image_72\": \"https://example.com/img/we-miss-sandra.png\"}, \"updated\": 1734567890}, \"cache_ts\": 1734567890, \"event_ts\": \"1734567890.000001\"}, \"type\": \"event_callback\", \"event_id\": \"Ev0123ABC456\", \"event_time\": 1734567890}",
      event.envelope_decoder(),
    )
  let assert event.EventCallback(event: event.UserStatusChanged(..), ..) =
    decoded
  round_trip_envelope(decoded)
}
