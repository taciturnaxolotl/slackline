//// Encoding helpers that the generated modules share. This module is not
//// part of the public API. It can change in any release.

import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder}
import gleam/float
import gleam/int
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

// ---- json objects --------------------------------------------------------

/// A json object from its entries. `None` entries are left out.
pub fn object(entries: List(Option(#(String, Json)))) -> Json {
  entries |> option.values |> json.object
}

/// An object entry that is always present.
pub fn field(key: String, value: Json) -> Option(#(String, Json)) {
  Some(#(key, value))
}

/// An object entry that is only present when `value` is `Some`.
pub fn optional(
  key: String,
  value: Option(a),
  encode: fn(a) -> Json,
) -> Option(#(String, Json)) {
  case value {
    Some(inner) -> Some(#(key, encode(inner)))
    None -> None
  }
}

/// Encodes a list, for optional fields that take an encoder function.
pub fn list(encode: fn(a) -> Json) -> fn(List(a)) -> Json {
  fn(items) { json.array(items, encode) }
}

/// Encodes `None` as `null`, for list items that can be `null`.
pub fn nullable(encode: fn(a) -> Json) -> fn(Option(a)) -> Json {
  fn(item) { json.nullable(item, encode) }
}

/// Encodes a dict with string keys as an object.
pub fn dict(encode: fn(a) -> Json) -> fn(Dict(String, a)) -> Json {
  fn(entries) { json.dict(entries, fn(key) { key }, encode) }
}

/// Decodes an optional field with `use`. A missing key and json `null` both
/// decode as `None`.
pub fn optional_field(
  key: String,
  decoder: Decoder(a),
  next: fn(Option(a)) -> Decoder(b),
) -> Decoder(b) {
  decode.optional_field(key, None, decode.optional(decoder), next)
}

/// Decodes a string that must equal `expected`, for constant fields such as
/// `"type": "section"`.
pub fn constant(expected: String) -> Decoder(String) {
  use found <- decode.then(decode.string)
  case found == expected {
    True -> decode.success(found)
    False -> decode.failure(found, json.to_string(json.string(expected)))
  }
}

/// Slack is not always consistent about whether a number has a fractional
/// part, so floats accept integers too.
pub fn float_decoder() -> Decoder(Float) {
  decode.one_of(decode.float, [decode.map(decode.int, int.to_float)])
}

/// Slack sends some counts as numbers in one payload and as strings in
/// another (`subteam_members_changed` documents `"3"` but sends `3`), so
/// integers accept numeric strings too.
pub fn int_decoder() -> Decoder(Int) {
  decode.one_of(decode.int, [
    {
      use text <- decode.then(decode.string)
      case int.parse(text) {
        Ok(n) -> decode.success(n)
        Error(Nil) -> decode.failure(0, "Int")
      }
    },
  ])
}

// ---- form parameters -----------------------------------------------------

pub fn form_int(value: Int) -> String {
  int.to_string(value)
}

pub fn form_float(value: Float) -> String {
  float.to_string(value)
}

pub fn form_bool(value: Bool) -> String {
  case value {
    True -> "true"
    False -> "false"
  }
}

/// Joins a list with commas, for arguments such as `types=public_channel,im`.
pub fn form_comma(items: List(a), encode: fn(a) -> String) -> String {
  items |> list.map(encode) |> string.join(",")
}
