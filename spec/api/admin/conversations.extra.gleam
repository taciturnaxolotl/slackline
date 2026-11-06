import gleam/option.{type Option, None, Some}
import slackline

/// The call for the page after `response`, or `None` when it was the last
/// page. `admin.conversations.search` returns its cursor at the top level as
/// `next_cursor` rather than inside `response_metadata`, so
/// `slackline.next_page` does not apply.
pub fn search_next_page(
  call: slackline.Call(Search, SearchResponse),
  response: SearchResponse,
) -> Option(slackline.Call(Search, SearchResponse)) {
  case response.next_cursor {
    Some(cursor) if cursor != "" ->
      Some(slackline.with_param(call, "cursor", cursor))
    _ -> None
  }
}
