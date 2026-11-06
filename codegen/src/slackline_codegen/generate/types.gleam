//// Spec types resolved against the registry, and the Gleam expressions for
//// their type, json decoder, json encoder and form encoder.

import gleam/dict.{type Dict}
import gleam/option.{type Option, None, Some}
import gleam/result
import slackline_codegen/generate/ir.{type Encoding, type TypeExpr}
import slackline_codegen/generate/names
import slackline_codegen/generate/registry.{type Registry}

pub type Kind {
  RecordKind
  UnionKind
  EnumKind
  OneofKind
}

/// A type whose names have been looked up.
pub type Resolved {
  RString
  RInt
  RFloat
  RBool
  RValue
  RList(Resolved)
  RDict(Resolved)
  /// `T?` inside `List(..)` or `Dict(..)`: json `null` is `None`.
  RNullable(Resolved)
  /// A declared type: the module it lives in and its bare name.
  RNamed(path: String, name: String, kind: Kind)
}

/// What renderers need to know about where they are rendering.
pub type Scope {
  Scope(module_path: String, registry: Registry, aliases: Dict(String, String))
}

/// One generated module, before assembly: its path, module docs (markdown
/// text), the chunks of its body, the import aliases its chunks use and the
/// hand-written code to append.
pub type Output {
  Output(
    path: String,
    docs: String,
    chunks: List(List(String)),
    aliases: Dict(String, String),
    extra: String,
  )
}

pub const value_module = "slackline/value"

pub const codec_module = "slackline/internal/codec"

pub fn kind_of(item: ir.Item) -> Kind {
  case item {
    ir.RecordItem(..) -> RecordKind
    ir.UnionItem(..) -> UnionKind
    ir.EnumItem(..) -> EnumKind
    ir.OneofItem(..) -> OneofKind
  }
}

/// Looks up every name in `type_`, checking type arguments.
pub fn resolve(
  type_: TypeExpr,
  scope: Scope,
  context: String,
) -> Result(Resolved, String) {
  let ir.TypeExpr(name, args) = type_
  case name, args {
    "List", [inner] -> result.map(resolve_item(inner, scope, context), RList)
    "Dict", [inner] -> result.map(resolve_item(inner, scope, context), RDict)
    "?", _ ->
      Error(
        context
        <> ": `?` on a type argument only works inside List(..) and Dict(..)",
      )
    "List", _ | "Dict", _ ->
      Error(context <> ": " <> name <> " takes exactly one type argument")
    "String", [] -> Ok(RString)
    "Int", [] -> Ok(RInt)
    "Float", [] -> Ok(RFloat)
    "Bool", [] -> Ok(RBool)
    "Value", [] -> Ok(RValue)
    "String", _ | "Int", _ | "Float", _ | "Bool", _ | "Value", _ ->
      Error(context <> ": " <> name <> " takes no type arguments")
    _, _ -> {
      use #(path, item) <- result.map(registry.lookup(
        scope.registry,
        name,
        context,
        scope.module_path,
      ))
      RNamed(path, names.bare(name), kind_of(item))
    }
  }
}

fn resolve_item(
  type_: TypeExpr,
  scope: Scope,
  context: String,
) -> Result(Resolved, String) {
  case type_ {
    ir.TypeExpr("?", [inner]) ->
      result.map(resolve(inner, scope, context), RNullable)
    _ -> resolve(type_, scope, context)
  }
}

pub fn alias(scope: Scope, path: String) -> String {
  registry.alias(scope.aliases, path)
}

fn codec(scope: Scope) -> String {
  alias(scope, codec_module)
}

fn value(scope: Scope) -> String {
  alias(scope, value_module)
}

/// The Gleam type.
pub fn gleam_type(type_: Resolved, scope: Scope) -> String {
  case type_ {
    RList(inner) -> "List(" <> gleam_type(inner, scope) <> ")"
    RDict(inner) -> "dict.Dict(String, " <> gleam_type(inner, scope) <> ")"
    RNullable(inner) -> "Option(" <> gleam_type(inner, scope) <> ")"
    RValue -> value(scope) <> ".Value"
    RString -> "String"
    RInt -> "Int"
    RFloat -> "Float"
    RBool -> "Bool"
    RNamed(path, name, _) if path == scope.module_path -> name
    RNamed(path, name, _) -> alias(scope, path) <> "." <> name
  }
}

/// A function of a declared type, such as `block_decoder`, qualified when it
/// lives in another module.
pub fn qualified(
  path: String,
  name: String,
  suffix: String,
  scope: Scope,
) -> String {
  let function = names.snake(name) <> suffix
  case path == scope.module_path {
    True -> function
    False -> alias(scope, path) <> "." <> function
  }
}

/// An expression of type `decode.Decoder(a)`.
pub fn decoder(type_: Resolved, scope: Scope) -> String {
  case type_ {
    RString -> "decode.string"
    RInt -> "decode.int"
    RBool -> "decode.bool"
    RFloat -> codec(scope) <> ".float_decoder()"
    RValue -> value(scope) <> ".decoder()"
    RList(inner) -> "decode.list(" <> decoder(inner, scope) <> ")"
    RDict(inner) ->
      "decode.dict(decode.string, " <> decoder(inner, scope) <> ")"
    RNullable(inner) -> "decode.optional(" <> decoder(inner, scope) <> ")"
    // A type of the same module can refer back to the one being decoded.
    // `decode.recursive` defers building its decoder, so cycles terminate.
    RNamed(path, name, RecordKind)
      | RNamed(path, name, UnionKind)
      if path == scope.module_path
    -> "decode.recursive(" <> names.snake(name) <> "_decoder)"
    RNamed(path, name, _) -> qualified(path, name, "_decoder", scope) <> "()"
  }
}

/// An expression of type `fn(a) -> json.Json`.
pub fn encoder(type_: Resolved, scope: Scope) -> String {
  case type_ {
    RString -> "json.string"
    RInt -> "json.int"
    RBool -> "json.bool"
    RFloat -> "json.float"
    RValue -> value(scope) <> ".to_json"
    RList(inner) -> codec(scope) <> ".list(" <> encoder(inner, scope) <> ")"
    RDict(inner) -> codec(scope) <> ".dict(" <> encoder(inner, scope) <> ")"
    RNullable(inner) ->
      codec(scope) <> ".nullable(" <> encoder(inner, scope) <> ")"
    RNamed(path, name, _) -> qualified(path, name, "_to_json", scope)
  }
}

/// An expression of type `json.Json` that encodes `variable`.
pub fn to_json(type_: Resolved, variable: String, scope: Scope) -> String {
  case type_ {
    RString | RInt | RBool | RFloat | RValue | RNamed(..) ->
      encoder(type_, scope) <> "(" <> variable <> ")"
    RList(inner) ->
      "json.array(" <> variable <> ", " <> encoder(inner, scope) <> ")"
    RDict(inner) ->
      "json.dict("
      <> variable
      <> ", fn(key) { key }, "
      <> encoder(inner, scope)
      <> ")"
    RNullable(inner) ->
      "json.nullable(" <> variable <> ", " <> encoder(inner, scope) <> ")"
  }
}

/// How a method argument becomes a form value.
pub type FormEncoder {
  /// A `String` is the value itself.
  Identity
  /// The value is `function(variable)`.
  Call(function: String)
  /// The value is the json text of the argument.
  JsonText(Resolved)
  /// A list joined with commas. Items are strings, or `item` encodes them.
  Comma(item: Option(String))
}

/// How to form encode an argument of type `type_`.
pub fn form_encoder(
  type_: Resolved,
  encoding: Option(Encoding),
  scope: Scope,
) -> Result(FormEncoder, String) {
  let codec = codec(scope)
  let json = encoding == Some(ir.JsonEncoding)
  let comma = encoding == Some(ir.CommaEncoding)
  case type_, json {
    RString, False -> Ok(Identity)
    RInt, False -> Ok(Call(codec <> ".form_int"))
    RFloat, False -> Ok(Call(codec <> ".form_float"))
    RBool, False -> Ok(Call(codec <> ".form_bool"))
    RList(inner), False ->
      case inner {
        RString -> Ok(Comma(None))
        RInt -> Ok(Comma(Some(codec <> ".form_int")))
        RFloat -> Ok(Comma(Some(codec <> ".form_float")))
        RBool -> Ok(Comma(Some(codec <> ".form_bool")))
        _ if comma -> comma_error(scope)
        RNamed(path, name, EnumKind) ->
          Ok(Comma(Some(qualified(path, name, "_to_string", scope))))
        _ -> Ok(JsonText(type_))
      }
    _, False if comma -> comma_error(scope)
    RNamed(path, name, EnumKind), False ->
      Ok(Call(qualified(path, name, "_to_string", scope)))
    _, _ -> Ok(JsonText(type_))
  }
}

/// The form value of `variable` with `encoder`.
pub fn form_value(
  encoder: FormEncoder,
  variable: String,
  scope: Scope,
) -> String {
  case encoder {
    Identity -> variable
    Call(function) -> function <> "(" <> variable <> ")"
    JsonText(type_) ->
      "json.to_string(" <> to_json(type_, variable, scope) <> ")"
    Comma(None) -> "string.join(" <> variable <> ", \",\")"
    Comma(Some(function)) ->
      codec(scope) <> ".form_comma(" <> variable <> ", " <> function <> ")"
  }
}

fn comma_error(scope: Scope) -> Result(a, String) {
  Error(scope.module_path <> ": comma encoding only works for lists of scalars")
}

/// The modules of the declared types a resolved type mentions.
pub fn paths(type_: Resolved) -> List(String) {
  case type_ {
    RList(inner) | RDict(inner) | RNullable(inner) -> paths(inner)
    RNamed(path:, ..) -> [path]
    _ -> []
  }
}
