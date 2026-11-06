//// Renders one Web API method: its phantom method type, its response type
//// and decoder, the function taking the required arguments and returning a
//// `slackline.Call`, and the setters for its optional arguments (which go in
//// a module of their own).

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/result
import gleam/set.{type Set}
import gleam/string
import slackline_codegen/generate/fields.{type PField}
import slackline_codegen/generate/ir.{
  type DocsArg, type DocsMethod, type ExampleCase, type Field, type Method,
}
import slackline_codegen/generate/names
import slackline_codegen/generate/types.{type Scope}

pub type Rendered {
  Rendered(
    lines: List(String),
    example: Option(ExampleCase),
    /// The optional arguments, which become setters.
    optional: List(PField),
    /// The required arguments, in order.
    required: List(PField),
  )
}

/// `chat.scheduledMessages.list` in `slackline/api/chat` is
/// `scheduled_messages_list`.
pub fn function_name(name: String, module_path: String) -> String {
  let parts = string.split(name, ".")
  let prefix =
    string.split(string.replace(module_path, "slackline/api/", ""), "/")
  let count = list.length(prefix)
  let rest = case list.map(list.take(parts, count), names.snake) == prefix {
    True -> list.drop(parts, count)
    False -> parts
  }
  case rest |> list.map(names.snake) |> string.join("_") {
    "" -> names.snake(list.last(parts) |> result.unwrap(name))
    joined -> names.snake(joined)
  }
}

/// The module a method without a spec goes in.
pub fn default_module(name: String) -> String {
  case string.split(name, ".") {
    ["admin", second, _, ..] -> "slackline/api/admin/" <> names.snake(second)
    [first, ..] -> "slackline/api/" <> names.snake(first)
    [] -> "slackline/api/" <> names.snake(name)
  }
}

fn doc_arg_type(arg: DocsArg) -> #(ir.TypeExpr, Option(ir.Encoding)) {
  let example = string.trim(option.unwrap(arg.example, ""))
  case arg.type_ {
    Some("boolean") -> #(ir.TypeExpr("Bool", []), None)
    Some("integer") | Some("number") -> #(ir.TypeExpr("Int", []), None)
    Some("array") ->
      case string.starts_with(example, "[") {
        True -> #(list_of_strings(), Some(ir.JsonEncoding))
        False -> #(list_of_strings(), Some(ir.CommaEncoding))
      }
    Some("object") -> #(ir.TypeExpr("Value", []), Some(ir.JsonEncoding))
    _ -> #(ir.TypeExpr("String", []), None)
  }
}

fn list_of_strings() -> ir.TypeExpr {
  ir.TypeExpr("List", [ir.TypeExpr("String", [])])
}

/// A docs description on one line, with page-local links made absolute.
pub fn clean_description(text: String, url: String) -> String {
  let text =
    regexp.replace(names.regex("\\s+"), text, " ")
    |> string.trim
    |> string.replace("](#", "](" <> url <> "#")
  case string.ends_with(text, " 0") {
    True -> string.trim(string.drop_end(text, 1))
    False -> text
  }
}

/// The documented arguments with the spec's overrides applied, then any
/// extra arguments the spec adds.
fn merge_args(
  docs: DocsMethod,
  spec_args: List(Field),
  context: String,
) -> Result(List(Field), String) {
  let overrides =
    list.fold(spec_args, [], fn(acc, field) {
      let key = field_key(field)
      case list.key_find(acc, key) {
        Ok(_) -> list.key_set(acc, key, field)
        Error(Nil) -> list.append(acc, [#(key, field)])
      }
    })
  let #(args, overrides, _) =
    list.fold(docs.args, #([], overrides, set.new()), fn(acc, arg) {
      let #(args, overrides, seen) = acc
      case arg.name == "token" || set.contains(seen, arg.name) {
        True -> acc
        False -> {
          let seen = set.insert(seen, arg.name)
          let #(override, overrides) = case list.key_pop(overrides, arg.name) {
            Ok(#(found, rest)) -> #(Some(found), rest)
            Error(Nil) -> #(None, overrides)
          }
          case override {
            Some(ir.Drop(..)) -> #(args, overrides, seen)
            _ -> #(
              [documented_arg(docs, arg, override), ..args],
              overrides,
              seen,
            )
          }
        }
      }
    })
  use extra <- result.map(
    list.try_map(overrides, fn(entry) {
      case entry.1 {
        ir.Drop(..) -> Ok([])
        ir.Field(modifier:, ..) as field -> {
          let modifier = case modifier {
            ir.Required -> ir.NoModifier
            _ -> ir.Optional
          }
          Ok([ir.Field(..field, modifier:)])
        }
        ir.Const(key:, ..) ->
          Error(context <> ": argument " <> key <> " cannot be a constant")
      }
    }),
  )
  list.append(list.reverse(args), list.flatten(extra))
}

fn field_key(field: Field) -> String {
  case field {
    ir.Field(key:, ..) | ir.Const(key:, ..) | ir.Drop(key:) -> key
  }
}

fn documented_arg(
  docs: DocsMethod,
  arg: DocsArg,
  override: Option(Field),
) -> Field {
  let #(type_, encoding) = doc_arg_type(arg)
  let description = clean_description(arg.description, docs.url)
  let description = case arg.default {
    Some("") | None -> description
    Some(default) -> description <> " Defaults to `" <> default <> "`."
  }
  let #(name, type_, encoding, required, description) = case override {
    Some(ir.Field(
      name:,
      type_: override_type,
      modifier:,
      encoding: override_encoding,
      docs: override_docs,
      ..,
    )) -> {
      let encoding = case
        override_encoding,
        override_type == list_of_strings()
      {
        Some(_), _ -> override_encoding
        None, True -> encoding
        None, False -> None
      }
      let required = case modifier {
        ir.Optional -> False
        ir.Required -> True
        ir.NoModifier -> arg.required
      }
      let docs = case override_docs {
        "" -> description
        _ -> override_docs
      }
      #(name, override_type, encoding, required, docs)
    }
    _ -> #(None, type_, encoding, arg.required, description)
  }
  let modifier = case required {
    True -> ir.NoModifier
    False -> ir.Optional
  }
  ir.Field(arg.name, name, type_, modifier, encoding, description)
}

type ResponseShape {
  RawResponse
  NilResponse
  TypeResponse(types.Resolved, ir.TypeExpr)
  FieldsResponse(List(PField))
}

pub fn render(
  docs: DocsMethod,
  spec: Option(Method),
  function: String,
  phantom: String,
  scope: Scope,
  generic_errors: Set(String),
) -> Result(Rendered, String) {
  let name = docs.name
  let module_path = scope.module_path
  let response_type = names.pascal(function) <> "Response"
  let context = module_path <> ": " <> name
  let #(spec_args, spec_response, spec_docs) = case spec {
    Some(ir.Method(args:, response:, docs:, ..)) -> #(args, response, docs)
    None -> #([], None, "")
  }
  use merged <- result.try(merge_args(docs, spec_args, context))
  use args <- result.try(fields.prepare_args(merged, context, scope))
  use response <- result.try(case spec_response {
    None -> Ok(RawResponse)
    Some(ir.ResponseType(ir.TypeExpr("Nil", _))) -> Ok(NilResponse)
    Some(ir.ResponseType(type_)) ->
      types.resolve(type_, scope, context) |> result.map(TypeResponse(_, type_))
    Some(ir.ResponseFields(fields)) ->
      fields.prepare(fields, context <> " response", None, scope)
      |> result.map(FieldsResponse)
  })
  let slackline = types.alias(scope, "slackline")
  let value = types.alias(scope, types.value_module)
  let #(response_gleam, response_decoder) = case response {
    RawResponse -> #(value <> ".Value", value <> ".decoder()")
    NilResponse -> #("Nil", "decode.success(Nil)")
    TypeResponse(type_, _) -> #(
      types.gleam_type(type_, scope),
      types.decoder(type_, scope),
    )
    FieldsResponse(_) -> #(
      response_type,
      names.snake(response_type) <> "_decoder()",
    )
  }
  let #(optional, required) = list.partition(args, is_optional)
  use entries <- result.map(
    list.try_map(required, fn(arg) {
      use #(key, value) <- result.map(form_entry(
        arg,
        fields.gleam_name(arg),
        scope,
      ))
      "#(" <> names.gleam_string(key) <> ", " <> value <> ")"
    }),
  )
  let summary = case string.trim(docs.summary) {
    "" -> name
    summary -> summary
  }
  // `unauthenticated` methods take client credentials or a refresh token in
  // the body. An unrelated bearer token can make Slack reject them.
  let authenticated = case spec {
    Some(ir.Method(unauthenticated: True, ..)) -> False
    _ -> True
  }
  let params =
    required
    |> list.map(fn(arg) {
      let gleam = fields.gleam_name(arg)
      gleam <> " " <> gleam <> ": " <> fields.field_type(arg, scope)
    })
    |> string.join(", ")
  let setters = case optional {
    [] -> ""
    _ -> setter_path(module_path, function)
  }
  let lines =
    list.flatten([
      names.doc_lines(
        "Identifies `"
          <> name
          <> "` in the `slackline.Call` that `"
          <> function
          <> "` returns.",
        0,
      ),
      ["pub type " <> phantom, ""],
      response_lines(name, response_type, response, scope),
      names.doc_lines(
        method_docs(
          docs,
          summary,
          names.alias_of(module_path) <> "." <> phantom,
          spec_docs,
          setters,
          generic_errors,
        ),
        0,
      ),
      case spec, docs.deprecated {
        Some(ir.Method(deprecated: Some(reason), ..)), _ -> [
          "@deprecated(" <> names.gleam_string(reason) <> ")",
        ]
        _, True -> ["@deprecated(" <> names.gleam_string(summary) <> ")"]
        _, False -> []
      },
      [
        "pub fn "
          <> function
          <> "("
          <> params
          <> ") -> "
          <> slackline
          <> ".Call("
          <> phantom
          <> ", "
          <> response_gleam
          <> ") {",
        slackline
          <> ".call("
          <> names.gleam_string(name)
          <> ", "
          <> fields.render_list(entries)
          <> ", "
          <> response_decoder
          <> ",)",
      ],
      case authenticated {
        True -> []
        False -> ["|> " <> slackline <> ".without_token"]
      },
      ["}"],
    ])
  let example = case response {
    RawResponse | NilResponse -> None
    FieldsResponse(_) ->
      Some(ir.ExampleCase(
        module_path,
        name,
        function,
        ir.LocalDecoder(names.snake(response_type) <> "_decoder()"),
        docs.examples,
      ))
    TypeResponse(_, type_) ->
      Some(ir.ExampleCase(
        module_path,
        name,
        function,
        ir.TypeDecoder(type_),
        docs.examples,
      ))
  }
  Rendered(lines, example, optional, required)
}

/// The module holding the setters for a method's optional arguments.
pub fn setter_path(family: String, function: String) -> String {
  family <> "/" <> function
}

/// The key and the form value of an argument whose value is in `variable`.
fn form_entry(
  arg: PField,
  variable: String,
  scope: Scope,
) -> Result(#(String, String), String) {
  case arg {
    fields.PField(key:, type_:, encoding:, ..) -> {
      use encoder <- result.map(types.form_encoder(type_, encoding, scope))
      #(key, types.form_value(encoder, variable, scope))
    }
    fields.PConst(key:, value:, ..) -> Ok(#(key, names.gleam_string(value)))
  }
}

/// A setter's value parameter. `call` is the name of the call parameter.
fn setter_variable(gleam: String) -> String {
  case gleam {
    "call" -> "value"
    _ -> gleam
  }
}

/// The body of a method's setter module: one function per optional
/// argument. `phantom` is the method type, qualified for `scope`.
pub fn setter_lines(
  optional: List(PField),
  phantom: String,
  scope: Scope,
) -> Result(List(String), String) {
  let slackline = types.alias(scope, "slackline")
  let call_type = slackline <> ".Call(" <> phantom <> ", r)"
  list.try_map(optional, fn(arg) {
    let gleam = fields.gleam_name(arg)
    let #(add, entry) = case arg {
      fields.PField(key:, type_: types.RFile, ..) -> #(
        "with_file",
        Ok(#(key, setter_variable(gleam))),
      )
      _ -> #("with_param", form_entry(arg, setter_variable(gleam), scope))
    }
    use #(key, value) <- result.map(entry)
    let type_ = case arg {
      fields.PField(type_:, ..) -> types.gleam_type(type_, scope)
      fields.PConst(..) -> "String"
    }
    list.flatten([
      names.doc_lines(arg.docs, 0),
      [
        "pub fn "
          <> gleam
          <> "(call: "
          <> call_type
          <> ", "
          <> setter_variable(gleam)
          <> ": "
          <> type_
          <> ") -> "
          <> call_type
          <> " {",
        slackline
          <> "."
          <> add
          <> "(call, "
          <> names.gleam_string(key)
          <> ", "
          <> value
          <> ")",
        "}",
        "",
      ],
    ])
  })
  |> result.map(list.flatten)
}

fn is_optional(field: PField) -> Bool {
  case field {
    fields.PField(optional:, ..) -> optional
    fields.PConst(..) -> False
  }
}

fn response_lines(
  name: String,
  response_type: String,
  response: ResponseShape,
  scope: Scope,
) -> List(String) {
  case response {
    FieldsResponse(response_fields) ->
      list.flatten([
        names.doc_lines("A successful response from `" <> name <> "`.", 0),
        ["pub type " <> response_type <> " {"],
        case fields.constructor_fields(response_fields, scope) {
          [] -> [response_type]
          body -> list.flatten([[response_type <> "("], body, [")"]])
        },
        ["}", ""],
        names.doc_lines("Decodes the response from `" <> name <> "`.", 0),
        [
          "pub fn "
          <> names.snake(response_type)
          <> "_decoder() -> decode.Decoder("
          <> response_type
          <> ") {",
        ],
        fields.decode_fields(
          response_fields,
          scope,
          "decode.success("
            <> fields.constructor_call(response_type, response_fields)
            <> ")",
        ),
        ["}", ""],
      ])
    _ -> []
  }
}

fn method_docs(
  docs: DocsMethod,
  summary: String,
  marker: String,
  spec_docs: String,
  setters: String,
  generic_errors: Set(String),
) -> String {
  let header = "[`" <> docs.name <> "`](" <> docs.url <> "): " <> summary
  let marker = [
    "",
    "`" <> marker <> "` identifies this method in `slackline.Call`.",
  ]
  let spec_docs = case spec_docs {
    "" -> []
    _ -> ["", spec_docs]
  }
  let spec_docs = case setters {
    "" -> spec_docs
    _ ->
      list.append(spec_docs, [
        "",
        "Set optional arguments with the functions in `" <> setters <> "`.",
      ])
  }
  let scopes =
    [#("Bot", docs.bot_scopes), #("User", docs.user_scopes)]
    |> list.filter_map(fn(entry) {
      case entry.1 {
        [] -> Error(Nil)
        scopes ->
          Ok(entry.0 <> " token scopes: " <> code_list(scopes, ", ") <> ".")
      }
    })
  let scopes = case scopes {
    [] -> []
    _ -> ["", string.join(scopes, "\n")]
  }
  let rate_limit = case docs.rate_limit {
    Some("") | None -> []
    Some(tier) -> ["", "Rate limit tier: `" <> tier <> "`."]
  }
  let errors = case
    list.filter(docs.errors, fn(code) { !set.contains(generic_errors, code) })
  {
    [] -> []
    errors -> ["", "Documented errors: " <> code_list(errors, ", ") <> "."]
  }
  list.flatten([[header], marker, spec_docs, scopes, rate_limit, errors])
  |> string.join("\n")
}

fn code_list(items: List(String), separator: String) -> String {
  items |> list.map(fn(item) { "`" <> item <> "`" }) |> string.join(separator)
}
