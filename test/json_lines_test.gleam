//// Methods that answer with a gzip file of json lines, such as
//// `admin.analytics.getFile`, decode like any other call.

import gleam/http/response
import gleam/list
import gleam/option.{Some}
import slackline
import slackline/api/admin/analytics
import slackline/value

fn answer(status: Int, body: BitArray) -> response.Response(BitArray) {
  response.new(status) |> response.set_body(body)
}

const two_members = <<
  "{\"date\":\"2026-11-20\",\"user_id\":\"W1\",\"is_active\":true}\n",
  "{\"date\":\"2026-11-20\",\"user_id\":\"W2\",\"is_active\":false}\n",
>>

pub fn rows_decode_into_records_test() {
  let assert Ok(rows) =
    slackline.response_bits(
      analytics.get_member_file(date: "2026-11-20"),
      answer(200, two_members),
    )
  assert list.map(rows, fn(row) { row.user_id }) == [Some("W1"), Some("W2")]
}

pub fn generic_call_returns_json_rows_test() {
  let assert Ok([first, _]) =
    slackline.response_bits(
      analytics.get_file(type_: analytics.Member),
      answer(200, two_members),
    )
  assert value.string_field(first, "user_id") == Ok("W1")
}

pub fn one_row_file_is_not_mistaken_for_an_error_test() {
  let assert Ok([row]) =
    slackline.response_bits(
      analytics.get_member_file(date: "2026-11-20"),
      answer(200, <<"{\"user_id\":\"W1\"}">>),
    )
  assert row.user_id == Some("W1")
}

pub fn json_error_becomes_api_error_test() {
  let assert Error(slackline.ApiError(error: "not_an_admin", ..)) =
    slackline.response_bits(
      analytics.get_file(type_: analytics.Member),
      answer(200, <<"{\"ok\":false,\"error\":\"not_an_admin\"}">>),
    )
}

pub fn rate_limit_is_reported_test() {
  let assert Error(slackline.RateLimited(7)) =
    slackline.response_bits(
      analytics.get_file(type_: analytics.Member),
      answer(429, <<>>) |> response.set_header("retry-after", "7"),
    )
}

pub fn gzip_that_was_not_unpacked_is_unexpected_test() {
  let assert Error(slackline.UnexpectedResponse(status: 200, ..)) =
    slackline.response_bits(
      analytics.get_file(type_: analytics.Member),
      answer(200, <<0x1f, 0x8b, 0x08, 0xff, 0xfe>>),
    )
}

pub fn ordinary_calls_still_decode_test() {
  let assert Ok(value.Object(_)) =
    slackline.response_bits(
      slackline.raw("auth.test", []),
      answer(200, <<"{\"ok\":true,\"user_id\":\"U1\"}">>),
    )
}
