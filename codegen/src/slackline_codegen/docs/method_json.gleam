//// Reads the json that docs.slack.dev renders each method page from
//// (`/reference/methods/<method>.json`). It holds facts the markdown page
//// leaves out: argument types the page only gives as a `schema` reference,
//// configuration token scopes, rate tiers given per surface, and the
//// response schema.

import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

pub type MethodJson {
  MethodJson(
    /// JSON Schema primitive type of each argument, when it has one.
    arg_types: Dict(String, String),
    /// Scopes a configuration token needs.
    configuration_scopes: List(String),
    rate_limit: Option(String),
    /// The top-level keys of the response schema, if there is one.
    response_fields: Option(List(String)),
  )
}

pub fn parse(text: String) -> Result(MethodJson, Nil) {
  json.parse(text, decoder()) |> result.replace_error(Nil)
}

fn decoder() -> decode.Decoder(MethodJson) {
  use arg_types <- decode.optional_field(
    "args",
    dict.new(),
    decode.one_of(
      decode.at(
        ["properties"],
        decode.dict(
          decode.string,
          decode.one_of(primitive() |> decode.map(Some), [decode.success(None)]),
        ),
      )
        |> decode.map(drop_none),
      [decode.success(dict.new())],
    ),
  )
  use configuration_scopes <- decode.optional_field(
    "scope",
    [],
    decode.one_of(
      decode.optional_field(
        "configuration",
        [],
        decode.list(decode.string),
        decode.success,
      ),
      [decode.success([])],
    ),
  )
  use rate_limit <- decode.optional_field(
    "rate_limits",
    None,
    decode.one_of(decode.string |> decode.map(Some), [
      decode.dict(decode.string, decode.string)
        |> decode.map(fn(tiers) { list.first(dict.values(tiers)) })
        |> decode.map(option.from_result),
      decode.success(None),
    ]),
  )
  use response_fields <- decode.optional_field(
    "output",
    None,
    decode.one_of(
      decode.at(["properties"], decode.dict(decode.string, decode.dynamic))
        |> decode.map(fn(fields) {
          Some(list.sort(dict.keys(fields), string.compare))
        }),
      [decode.success(None)],
    ),
  )
  decode.success(MethodJson(
    arg_types:,
    configuration_scopes:,
    rate_limit:,
    response_fields:,
  ))
}

/// The `type` of a schema, or the first non-null `type` in its `anyOf` or
/// `oneOf`. A `schema` reference names a shared definition that is not
/// published, so it has no primitive type.
fn primitive() -> decode.Decoder(String) {
  let alternatives = fn(key) {
    decode.at(
      [key],
      decode.list(decode.optional_field(
        "type",
        "",
        decode.one_of(decode.string, [decode.success("")]),
        decode.success,
      )),
    )
    |> decode.then(fn(types) {
      case list.find(types, fn(t) { t != "" && t != "null" }) {
        Ok(found) -> decode.success(found)
        Error(Nil) -> decode.failure("", "type")
      }
    })
  }
  decode.one_of(decode.at(["type"], decode.string), [
    alternatives("anyOf"),
    alternatives("oneOf"),
  ])
}

fn drop_none(entries: Dict(String, Option(String))) -> Dict(String, String) {
  dict.fold(entries, dict.new(), fn(acc, key, value) {
    case value {
      Some(value) -> dict.insert(acc, key, value)
      None -> acc
    }
  })
}
