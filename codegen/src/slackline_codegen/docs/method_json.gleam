//// Reads the json that docs.slack.dev renders each method page from
//// (`/reference/methods/<method>.json`). It holds facts the markdown page
//// leaves out: argument types the page only gives as a `schema` reference,
//// configuration token scopes, rate tiers given per surface, and the
//// response schema. Shapes outside the ones below fail, so a format change
//// stops the extract instead of quietly dropping facts.

import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder}
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

pub type MethodJson {
  MethodJson(
    /// JSON Schema primitive type of each argument that has one. Arguments
    /// that only reference a shared definition have none.
    arg_types: Dict(String, String),
    /// Scopes a configuration token needs.
    configuration_scopes: List(String),
    rate_limit: Option(String),
    /// The top-level keys of the response schema, if there is one.
    response_fields: Option(List(String)),
  )
}

pub fn parse(text: String) -> Result(MethodJson, String) {
  case json.parse(text, decoder()) {
    Ok(method) -> Ok(method)
    Error(error) -> Error(string.inspect(error))
  }
}

fn decoder() -> Decoder(MethodJson) {
  use arg_types <- decode.subfield(
    ["args", "properties"],
    decode.dict(decode.string, primitive_or_none()),
  )
  use configuration_scopes <- decode.optional_field("scope", [], scopes())
  use rate_limit <- decode.optional_field("rate_limits", None, rate_limit())
  use response_fields <- decode.optional_field(
    "output",
    None,
    decode.optional(decode.optional_field(
      "properties",
      None,
      decode.optional(decode.dict(decode.string, decode.dynamic))
        |> decode.map(
          option.map(_, fn(fields) {
            list.sort(dict.keys(fields), string.compare)
          }),
        ),
      decode.success,
    ))
      |> decode.map(option.flatten),
  )
  decode.success(MethodJson(
    arg_types: dict.fold(arg_types, dict.new(), fn(acc, name, type_) {
      case type_ {
        Some(type_) -> dict.insert(acc, name, type_)
        None -> acc
      }
    }),
    configuration_scopes:,
    rate_limit:,
    response_fields:,
  ))
}

/// `{"bot": [..], "user": [..], "configuration": [..]}`, or `"none"` for
/// methods that take no token scopes.
fn scopes() -> Decoder(List(String)) {
  decode.one_of(
    decode.optional_field(
      "configuration",
      [],
      decode.list(decode.string),
      decode.success,
    ),
    [
      decode.string
      |> decode.then(fn(scope) {
        case scope {
          "none" -> decode.success([])
          _ -> decode.failure([], "scope \"none\" or an object")
        }
      }),
    ],
  )
}

/// A tier such as `"t3"`, or `{"apps_tier": "t3"}` for methods only apps
/// call. Another surface would need a decision about which tier to show.
fn rate_limit() -> Decoder(Option(String)) {
  decode.optional(
    decode.one_of(decode.string, [decode.at(["apps_tier"], decode.string)]),
  )
}

/// The primitive `type` of an argument schema: a string, the first non-null
/// entry of a list of types, or the first such `type` in `anyOf` or `oneOf`.
/// `None` for a `schema` reference.
fn primitive_or_none() -> Decoder(Option(String)) {
  use type_ <- decode.optional_field("type", None, type_name())
  use any_of <- decode.optional_field("anyOf", [], decode.list(alternative()))
  use one_of <- decode.optional_field("oneOf", [], decode.list(alternative()))
  decode.success(
    [type_, ..list.append(any_of, one_of)]
    |> list.find_map(option.to_result(_, Nil))
    |> option.from_result,
  )
}

fn alternative() -> Decoder(Option(String)) {
  decode.optional_field("type", None, type_name(), decode.success)
}

/// `"string"` or `["object", "null"]`. `None` when the only type is null.
fn type_name() -> Decoder(Option(String)) {
  let real = fn(names: List(String)) {
    list.find(names, fn(name) { name != "null" }) |> option.from_result
  }
  decode.one_of(decode.string |> decode.map(fn(name) { real([name]) }), [
    decode.list(decode.string) |> decode.map(real),
  ])
}
