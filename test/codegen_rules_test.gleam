//// Behaviour the generator guarantees for every generated module.

import gleam/json
import gleam/option.{None, Some}
import slackline
import slackline/api/chat
import slackline/api/conversations
import slackline/api/search
import slackline/api/search/messages
import slackline/common
import slackline/event

pub fn next_page_sets_cursor_test() {
  let call = conversations.list()
  let metadata =
    Some(slackline.ResponseMetadata(
      next_cursor: Some("dGVhbTpDMDYxRkE1UEI="),
      warnings: None,
      messages: None,
    ))
  let assert Some(next) = slackline.next_page(call, metadata)
  assert slackline.method(next) == "conversations.list"
  assert slackline.params(next) == [#("cursor", "dGVhbTpDMDYxRkE1UEI=")]
}

pub fn next_page_stops_on_empty_cursor_test() {
  let call = conversations.list()
  let empty =
    slackline.ResponseMetadata(
      next_cursor: Some(""),
      warnings: None,
      messages: None,
    )
  assert slackline.next_page(call, Some(empty)) == None
  assert slackline.next_page(call, None) == None
}

pub fn constant_field_may_be_absent_test() {
  let assert Ok(chat.TaskIcon(name: "star")) =
    json.parse("{\"name\": \"star\"}", chat.task_icon_decoder())
  let assert Ok(chat.TaskIcon(name: "star")) =
    json.parse(
      "{\"type\": \"icon\", \"name\": \"star\"}",
      chat.task_icon_decoder(),
    )
}

pub fn constant_field_must_match_test() {
  let assert Error(_) =
    json.parse(
      "{\"type\": \"url\", \"name\": \"star\"}",
      chat.task_icon_decoder(),
    )
}

pub fn missing_union_tag_is_unknown_test() {
  let assert Ok(event.UnknownEnvelope(type_: "", ..)) =
    json.parse("{}", event.envelope_decoder())
}

pub fn enum_params_are_plain_strings_test() {
  let call =
    search.messages(query: "deploy")
    |> messages.sort(common.SortByTimestamp)
    |> messages.sort_dir(common.Descending)
  assert slackline.params(call)
    == [#("query", "deploy"), #("sort", "timestamp"), #("sort_dir", "desc")]
}
