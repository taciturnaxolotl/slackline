//// Calls to Slack's other HTTP APIs (SCIM, Audit Logs, Status) build REST
//// requests and decode plain json answers.

import gleam/bit_array
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/option
import slackline
import slackline/audit_logs
import slackline/scim
import slackline/status

fn answer(status: Int, body: String) -> response.Response(BitArray) {
  response.new(status) |> response.set_body(bit_array.from_string(body))
}

pub fn get_with_query_and_token_test() {
  let req =
    audit_logs.logs()
    |> audit_logs.limit(5)
    |> audit_logs.action(["user_login", "file_downloaded"])
    |> slackline.request(slackline.new("xoxp-1"))
  assert req.method == http.Get
  assert req.host == "api.slack.com"
  assert req.path == "/audit/v1/logs"
  assert req.query == option.Some("limit=5&action=user_login%2Cfile_downloaded")
  assert request.get_header(req, "authorization") == Ok("Bearer xoxp-1")
}

pub fn new_user_sets_schemas_and_email_test() {
  let req =
    scim.create_user(scim.new_user(user_name: "pam", email: "pam@d.co"))
    |> slackline.request(slackline.new("xoxp-1"))
  let assert Ok(body) = bit_array.to_string(req.body)
  assert body
    == "{\"schemas\":[\"urn:ietf:params:scim:schemas:core:2.0:User\",\"urn:ietf:params:scim:schemas:extension:enterprise:2.0:User\",\"urn:ietf:params:scim:schemas:extension:slack:profile:2.0:User\"],\"userName\":\"pam\",\"emails\":[{\"value\":\"pam@d.co\",\"primary\":true}]}"
}

pub fn json_body_test() {
  let req =
    scim.patch_user(id: "U1", operations: [
      scim.PatchOperation(
        op: "remove",
        path: option.Some("title"),
        value: option.None,
      ),
    ])
    |> slackline.request(slackline.new("xoxp-1"))
  assert req.method == http.Patch
  assert req.path == "/scim/v2/Users/U1"
  assert request.get_header(req, "content-type") == Ok("application/json")
  let assert Ok(body) = bit_array.to_string(req.body)
  assert body
    == "{\"schemas\":[\"urn:ietf:params:scim:api:messages:2.0:PatchOp\"],\"Operations\":[{\"op\":\"remove\",\"path\":\"title\"}]}"
}

pub fn unauthenticated_calls_send_no_token_test() {
  let req = status.current() |> slackline.request(slackline.new("xoxp-1"))
  assert req.host == "slack-status.com"
  assert request.get_header(req, "authorization") == Error(Nil)
}

pub fn plain_json_decodes_test() {
  let assert Ok(current) =
    slackline.response_bits(
      status.current(),
      answer(200, "{\"status\":\"ok\",\"active_incidents\":[]}"),
    )
  assert current.status == status.AllOk
}

pub fn empty_success_body_test() {
  assert slackline.response_bits(scim.delete_user(id: "U1"), answer(204, ""))
    == Ok(Nil)
}

pub fn scim_errors_become_api_errors_test() {
  let assert Error(slackline.ApiError(error: "plus_teams_only", ..)) =
    slackline.response_bits(
      scim.users(start_index: 1, count: 1),
      answer(
        403,
        "{\"Errors\":{\"description\":\"plus_teams_only\",\"code\":403}}",
      ),
    )
}

pub fn error_field_becomes_api_error_test() {
  let assert Error(slackline.ApiError(error: "invalid_cursor", ..)) =
    slackline.response_bits(
      audit_logs.logs(),
      answer(400, "{\"ok\":false,\"error\":\"invalid_cursor\"}"),
    )
}

pub fn empty_error_body_is_unexpected_test() {
  assert slackline.response_bits(audit_logs.logs(), answer(401, ""))
    == Error(slackline.UnexpectedResponse(401, ""))
}

pub fn rest_rate_limit_test() {
  let assert Error(slackline.RateLimited(3)) =
    slackline.response_bits(
      audit_logs.logs(),
      answer(429, "") |> response.set_header("retry-after", "3"),
    )
}

pub fn method_names_the_route_test() {
  assert slackline.method(scim.user(id: "U1")) == "GET /scim/v2/Users/U1"
  assert slackline.method(audit_logs.logs()) == "GET /audit/v1/logs"
}

pub fn other_apis_url_rehosts_rest_calls_only_test() {
  let assert Ok(client) =
    slackline.new("xoxp-1")
    |> slackline.with_other_apis_url("http://localhost:9000")
  let req = status.history() |> slackline.request(client)
  assert req.scheme == http.Http
  assert req.host == "localhost"
  assert req.port == option.Some(9000)
  assert req.path == "/api/v2.0.0/history"
  let web = slackline.raw("auth.test", []) |> slackline.request(client)
  assert web.host == "slack.com"
}

pub fn typed_scim_bodies_carry_schemas_test() {
  let req =
    scim.create_group(scim.new_group(display_name: "Ops", members: []))
    |> slackline.request(slackline.new("xoxp-1"))
  assert req.method == http.Post
  let assert Ok(body) = bit_array.to_string(req.body)
  assert body
    == "{\"schemas\":[\"urn:ietf:params:scim:schemas:core:2.0:Group\"],\"displayName\":\"Ops\",\"members\":[]}"
}
