import gleam/dynamic/decode
import gleam/http
import gleam/int
import gleam/json.{type Json}
import gleam/list
import gleam/option.{None, Some}
import slackline
import slackline/value

/// Identifies calls that list users or groups, which take `filter`.
pub type Listing

/// The type of the other SCIM calls.
pub type ScimApi

const base = "https://api.slack.com/scim/v2/"

/// Users `count` at a time from `start_index` (1-based).
pub fn users(
  start_index start_index: Int,
  count count: Int,
) -> slackline.Call(Listing, ScimUsers) {
  page("Users", start_index, count, scim_users_decoder())
}

/// Groups `count` at a time from `start_index` (1-based).
pub fn groups(
  start_index start_index: Int,
  count count: Int,
) -> slackline.Call(Listing, ScimGroups) {
  page("Groups", start_index, count, scim_groups_decoder())
}

/// Only resources matching a SCIM filter, such as `email eq "a@b.c"`.
pub fn filter(
  call: slackline.Call(Listing, r),
  filter: String,
) -> slackline.Call(Listing, r) {
  slackline.with_param(call, "filter", filter)
}

pub fn user(id id: String) -> slackline.Call(ScimApi, ScimUser) {
  slackline.rest(http.Get, base <> "Users/" <> id, None, scim_user_decoder())
}

pub fn group(id id: String) -> slackline.Call(ScimApi, ScimGroup) {
  slackline.rest(http.Get, base <> "Groups/" <> id, None, scim_group_decoder())
}

/// Creates a user.
pub fn create_user(user: ScimUserInput) -> slackline.Call(ScimApi, ScimUser) {
  slackline.rest(
    http.Post,
    base <> "Users",
    Some(scim_user_input_to_json(user)),
    scim_user_decoder(),
  )
}

/// Creates a group.
pub fn create_group(group: ScimGroupInput) -> slackline.Call(ScimApi, ScimGroup) {
  slackline.rest(
    http.Post,
    base <> "Groups",
    Some(scim_group_input_to_json(group)),
    scim_group_decoder(),
  )
}

/// Replaces every attribute of a user.
pub fn replace_user(
  id id: String,
  user user: ScimUserInput,
) -> slackline.Call(ScimApi, ScimUser) {
  slackline.rest(
    http.Put,
    base <> "Users/" <> id,
    Some(scim_user_input_to_json(user)),
    scim_user_decoder(),
  )
}

/// Replaces a group's name and members.
pub fn replace_group(
  id id: String,
  group group: ScimGroupInput,
) -> slackline.Call(ScimApi, ScimGroup) {
  slackline.rest(
    http.Put,
    base <> "Groups/" <> id,
    Some(scim_group_input_to_json(group)),
    scim_group_decoder(),
  )
}

/// Changes some attributes of a user.
pub fn patch_user(
  id id: String,
  operations operations: List(PatchOperation),
) -> slackline.Call(ScimApi, ScimUser) {
  slackline.rest(
    http.Patch,
    base <> "Users/" <> id,
    Some(patch_body(operations)),
    scim_user_decoder(),
  )
}

/// Changes a group, such as adding or removing members. Slack answers with
/// no body.
pub fn patch_group(
  id id: String,
  operations operations: List(PatchOperation),
) -> slackline.Call(ScimApi, Nil) {
  slackline.rest(
    http.Patch,
    base <> "Groups/" <> id,
    Some(patch_body(operations)),
    decode.success(Nil),
  )
}

/// Deactivates a user.
pub fn delete_user(id id: String) -> slackline.Call(ScimApi, Nil) {
  slackline.rest(http.Delete, base <> "Users/" <> id, None, decode.success(Nil))
}

pub fn delete_group(id id: String) -> slackline.Call(ScimApi, Nil) {
  slackline.rest(http.Delete, base <> "Groups/" <> id, None, decode.success(Nil))
}

/// Slack's SCIM configuration (`ServiceProviderConfig`), as json.
pub fn service_provider_config() -> slackline.Call(ScimApi, value.Value) {
  slackline.rest(
    http.Get,
    base <> "ServiceProviderConfig",
    None,
    value.decoder(),
  )
}

/// The user and group schemas, as json.
pub fn schemas() -> slackline.Call(ScimApi, value.Value) {
  slackline.rest(http.Get, base <> "Schemas", None, value.decoder())
}

fn page(
  resource: String,
  start_index: Int,
  count: Int,
  decoder: decode.Decoder(a),
) -> slackline.Call(Listing, a) {
  slackline.rest(http.Get, base <> resource, None, decoder)
  |> slackline.with_param("startIndex", int.to_string(start_index))
  |> slackline.with_param("count", int.to_string(count))
}

fn patch_body(operations: List(PatchOperation)) -> Json {
  json.object([
    #(
      "schemas",
      json.array(["urn:ietf:params:scim:api:messages:2.0:PatchOp"], json.string),
    ),
    #("Operations", json.array(operations, patch_operation_to_json)),
  ])
}

/// A user with only the required attributes, ready for `create_user`. Set
/// the others with record update syntax.
pub fn new_user(
  user_name user_name: String,
  email email: String,
) -> ScimUserInput {
  ScimUserInput(
    schemas: [
      "urn:ietf:params:scim:schemas:core:2.0:User",
      "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User",
      "urn:ietf:params:scim:schemas:extension:slack:profile:2.0:User",
    ],
    user_name:,
    emails: [
      ScimValue(value: Some(email), primary: Some(True), value_type: None, display: None),
    ],
    nick_name: None,
    name: None,
    display_name: None,
    profile_url: None,
    title: None,
    timezone: None,
    active: None,
    external_id: None,
    photos: None,
    addresses: None,
    phone_numbers: None,
    user_type: None,
    roles: None,
    preferred_language: None,
    locale: None,
    enterprise: None,
    slack_profile: None,
  )
}

/// A group with these members (user IDs), ready for `create_group`.
pub fn new_group(
  display_name display_name: String,
  members members: List(String),
) -> ScimGroupInput {
  ScimGroupInput(
    schemas: ["urn:ietf:params:scim:schemas:core:2.0:Group"],
    display_name:,
    members: list.map(members, fn(id) {
      ScimValue(value: Some(id), primary: None, value_type: None, display: None)
    }),
  )
}
