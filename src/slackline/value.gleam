//// Free-form json values.
////
//// Slack sends free-form json in many places: message metadata, workflow
//// step outputs, datastore items, and any event or block that slackline does
//// not know yet. `Value` holds that data. You can pattern match on it, encode
//// it again, or run your own decoders on it.
////
//// ```gleam
//// let payload =
////   value.Object([
////     #("id", value.String("11223")),
////     #("title", value.String("Redesign Homepage")),
////   ])
//// ```

import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/list
import gleam/result

pub type Value {
  Null
  Bool(Bool)
  Int(Int)
  Float(Float)
  String(String)
  Array(List(Value))
  Object(List(#(String, Value)))
}

/// Decodes any json into a `Value`.
pub fn decoder() -> Decoder(Value) {
  decode.one_of(decode.map(decode.string, String), [
    decode.map(decode.bool, Bool),
    decode.map(decode.int, Int),
    decode.map(decode.float, Float),
    decode.map(decode.list(decode.recursive(decoder)), Array),
    decode.map(
      decode.dict(decode.string, decode.recursive(decoder)),
      fn(entries) { Object(dict.to_list(entries)) },
    ),
    null_decoder(),
  ])
}

fn null_decoder() -> Decoder(Value) {
  decode.new_primitive_decoder("Null", fn(data) {
    case dynamic.classify(data) {
      "Nil" -> Ok(Null)
      _ -> Error(Null)
    }
  })
}

/// Encodes a `Value` as json.
pub fn to_json(value: Value) -> Json {
  case value {
    Null -> json.null()
    Bool(inner) -> json.bool(inner)
    Int(inner) -> json.int(inner)
    Float(inner) -> json.float(inner)
    String(inner) -> json.string(inner)
    Array(items) -> json.array(items, to_json)
    Object(entries) ->
      json.object(list.map(entries, fn(entry) { #(entry.0, to_json(entry.1)) }))
  }
}

/// Parses a json string into a `Value`.
pub fn parse(text: String) -> Result(Value, json.DecodeError) {
  json.parse(text, decoder())
}

/// Renders a `Value` as a json string.
pub fn to_string(value: Value) -> String {
  value |> to_json |> json.to_string
}

/// Converts a `Value` to `Dynamic` so it can be fed to a decoder.
pub fn to_dynamic(value: Value) -> Dynamic {
  case value {
    Null -> dynamic.nil()
    Bool(inner) -> dynamic.bool(inner)
    Int(inner) -> dynamic.int(inner)
    Float(inner) -> dynamic.float(inner)
    String(inner) -> dynamic.string(inner)
    Array(items) -> dynamic.list(list.map(items, to_dynamic))
    Object(entries) ->
      dynamic.properties(
        list.map(entries, fn(entry) {
          #(dynamic.string(entry.0), to_dynamic(entry.1))
        }),
      )
  }
}

/// Runs a decoder on a `Value`, for example on an unknown event or block:
///
/// ```gleam
/// case event {
///   event.UnknownEvent(type_: "my_custom_event", raw:) ->
///     value.decode(raw, my_event_decoder())
///   _ -> todo
/// }
/// ```
pub fn decode(
  value: Value,
  decoder: Decoder(a),
) -> Result(a, List(decode.DecodeError)) {
  decode.run(to_dynamic(value), decoder)
}

/// Looks up a key in an object.
pub fn field(value: Value, key: String) -> Result(Value, Nil) {
  case value {
    Object(entries) -> list.key_find(entries, key)
    _ -> Error(Nil)
  }
}

/// Follows a path of object keys.
pub fn at(value: Value, path: List(String)) -> Result(Value, Nil) {
  list.try_fold(path, value, field)
}

/// Looks up a string in an object.
pub fn string_field(value: Value, key: String) -> Result(String, Nil) {
  use found <- result.try(field(value, key))
  case found {
    String(inner) -> Ok(inner)
    _ -> Error(Nil)
  }
}
