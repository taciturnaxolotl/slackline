//// The generated test that decodes every successful response example from
//// the docs. The test holds each example as compact json with sorted keys,
//// so the test file only changes when an example changes.

import gleam/bool
import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/json.{type Json}
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/set
import gleam/string
import slackline_codegen/generate/ir.{type ExampleCase}
import slackline_codegen/generate/names
import slackline_codegen/generate/registry.{type Registry}
import slackline_codegen/generate/types.{type Output}

pub const test_path = "test/slackline_examples_test.gleam"

/// A test to write: the example and the decoder to use.
type Test {
  Test(
    case_: ExampleCase,
    index: Int,
    title: String,
    body: String,
    decoder_path: String,
    decoder: String,
  )
}

pub fn render(cases: List(ExampleCase), registry: Registry) -> Output {
  let tests = list.flat_map(cases, tests(_, registry))
  let order =
    list.flat_map(tests, fn(test_) {
      [test_.case_.module_path, test_.decoder_path]
    })
  let aliases = registry.allocate_aliases(order, set.new())
  let chunks =
    list.map(tests, fn(test_) {
      let name =
        names.snake(
          string.replace(test_.case_.module_path, "slackline/api/", "")
          <> "_"
          <> test_.case_.function
          <> "_"
          <> int.to_string(test_.index),
        )
      [
        "/// "
          <> test_.case_.method
          <> ": "
          <> string.replace(test_.title, "\n", " "),
        "pub fn " <> name <> "_test() {",
        "let assert Ok(_) = json.parse("
          <> names.gleam_string(test_.body)
          <> ", "
          <> registry.alias(aliases, test_.decoder_path)
          <> "."
          <> test_.decoder
          <> ")",
        "}",
      ]
    })
  types.Output(
    path: "slackline_examples_test",
    docs: "Decodes every successful response example from the Slack docs with"
      <> " the matching slackline decoder.",
    chunks: case chunks {
      [] -> [["pub fn no_examples_test() {", "Nil", "}"]]
      _ -> chunks
    },
    aliases:,
    extra: "",
  )
}

/// The tests for the examples of one method that parse and succeed.
fn tests(case_: ExampleCase, registry: Registry) -> List(Test) {
  let decoder = case case_.decoder {
    ir.LocalDecoder(function) -> Ok(#(case_.module_path, function))
    ir.TypeDecoder(ir.TypeExpr(name, _)) -> {
      let builtin = ["String", "Int", "Float", "Bool", "Value", "List", "Dict"]
      use <- bool.guard(list.contains(builtin, name), Error(Nil))
      use #(path, _) <- result.map(
        registry.lookup(registry, name, case_.module_path, case_.module_path)
        |> result.replace_error(Nil),
      )
      #(path, names.snake(names.bare(name)) <> "_decoder()")
    }
  }
  case decoder {
    Error(Nil) -> []
    Ok(#(decoder_path, decoder)) ->
      list.index_map(case_.examples, fn(example, index) {
        use body <- result.map(normalize(example.body))
        Test(case_, index, example.title, body, decoder_path, decoder)
      })
      |> result.values
  }
}

// ---- json values -------------------------------------------------------

type Value {
  JNull
  JBool(Bool)
  JInt(Int)
  JFloat(Float)
  JString(String)
  JArray(List(Value))
  JObject(List(#(String, Value)))
}

fn value_decoder() -> decode.Decoder(Value) {
  use <- decode.recursive
  decode.one_of(decode.map(decode.string, JString), [
    decode.map(decode.bool, JBool),
    decode.map(decode.int, JInt),
    decode.map(decode.float, JFloat),
    decode.map(decode.list(value_decoder()), JArray),
    decode.map(decode.dict(decode.string, value_decoder()), fn(entries) {
      JObject(
        dict.to_list(entries)
        |> list.sort(fn(a, b) { string.compare(a.0, b.0) }),
      )
    }),
    decode.map(decode.optional(decode.failure(JNull, "null")), fn(_) { JNull }),
  ])
}

fn to_json(value: Value) -> Json {
  case value {
    JNull -> json.null()
    JBool(bool) -> json.bool(bool)
    JInt(int) -> json.int(int)
    JFloat(float) -> json.float(float)
    JString(string) -> json.string(string)
    JArray(items) -> json.preprocessed_array(list.map(items, to_json))
    JObject(entries) ->
      json.object(list.map(entries, fn(entry) { #(entry.0, to_json(entry.1)) }))
  }
}

/// Drops trailing commas, parses and re-encodes an example body. Fails when
/// it is not json or not a successful (`"ok": true`) response.
pub fn normalize(body: String) -> Result(String, Nil) {
  let body =
    regexp.match_map(names.regex(",\\s*([}\\]])"), body, fn(match) {
      case match.submatches {
        [Some(close)] -> close
        _ -> match.content
      }
    })
  case json.parse(body, value_decoder()) {
    Ok(JObject(entries) as value) ->
      case list.key_find(entries, "ok") {
        Ok(JBool(True)) -> Ok(json.to_string(to_json(value)))
        _ -> Error(Nil)
      }
    _ -> Error(Nil)
  }
}
