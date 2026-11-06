//// Renders records, unions, enums and oneofs: the custom type, its json
//// decoder and its json encoder.

import gleam/bool
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import slackline_codegen/generate/fields.{type PField}
import slackline_codegen/generate/ir.{type Item}
import slackline_codegen/generate/names
import slackline_codegen/generate/registry
import slackline_codegen/generate/types.{type Scope}

pub fn render(item: Item, scope: Scope) -> Result(List(String), String) {
  case item {
    ir.RecordItem(record) -> record_lines(record, scope)
    ir.UnionItem(union) -> union_lines(union, scope)
    ir.EnumItem(enum) -> enum_lines(enum)
    ir.OneofItem(oneof) -> oneof_lines(oneof, scope)
  }
}

/// A constructor, with its fields when it has any.
fn constructor(
  ctor: String,
  fields: List(PField),
  scope: Scope,
) -> List(String) {
  case fields.constructor_fields(fields, scope) {
    [] -> [ctor]
    body -> list.flatten([[ctor <> "("], body, [")"]])
  }
}

fn record_lines(
  record: ir.Record,
  scope: Scope,
) -> Result(List(String), String) {
  let ir.Record(name:, docs:, fields:, file:) = record
  use fields <- result.map(fields.prepare(
    fields,
    file <> ": " <> name,
    None,
    scope,
  ))
  let function = names.snake(name)
  let codec = types.alias(scope, types.codec_module)
  let entries =
    fields.encode_entries(fields, scope, fn(gleam) { "it." <> gleam })
  let param = case fields.stored(fields) {
    [] -> "_it"
    _ -> "it"
  }
  list.flatten([
    names.doc_lines(docs, 0),
    ["pub type " <> name <> " {"],
    constructor(name, fields, scope),
    ["}"],
    [
      "",
      "/// Decodes `" <> name <> "` from json.",
      "pub fn " <> function <> "_decoder() -> decode.Decoder(" <> name <> ") {",
    ],
    fields.decode_fields(
      fields,
      scope,
      "decode.success(" <> fields.constructor_call(name, fields) <> ")",
    ),
    [
      "}",
      "",
      "/// Encodes `" <> name <> "` as json.",
      "pub fn "
        <> function
        <> "_to_json("
        <> param
        <> ": "
        <> name
        <> ") -> json.Json {",
      codec <> ".object(" <> fields.render_list(entries) <> ")",
      "}",
    ],
  ])
}

type Prepared {
  Wrapped(tag: String, name: String, type_: types.Resolved)
  WithFields(tag: String, name: String, fields: List(PField))
}

fn prepare_variant(
  variant: ir.Variant,
  union: ir.Union,
  scope: Scope,
) -> Result(#(Prepared, List(String)), String) {
  let context = union.file <> ": " <> union.name <> "." <> variant.name
  use <- bool.guard(
    variant.tag == "" && !union.optional_tag,
    Error(
      context
      <> ": only a union declared with `tag "
      <> names.gleam_string(union.tag)
      <> " optional` can have a \"\" variant",
    ),
  )
  case variant {
    ir.WrapVariant(tag: value, name:, wraps:, docs:, ..) -> {
      use #(path, wrapped) <- result.try(registry.lookup(
        scope.registry,
        wraps,
        context,
        scope.module_path,
      ))
      let kind = types.kind_of(wrapped)
      use <- bool.guard(
        kind == types.EnumKind,
        Error(context <> ": cannot wrap an enum"),
      )
      use Nil <- result.try(check_wrapped_tag(wrapped, union, value, context))
      let resolved = types.RNamed(path, names.bare(wraps), kind)
      let lines =
        list.append(names.doc_lines(docs, 2), [
          name <> "(" <> types.gleam_type(resolved, scope) <> ")",
        ])
      Ok(#(Wrapped(value, name, resolved), lines))
    }
    ir.FieldsVariant(tag: value, name:, fields:, docs:) -> {
      use fields <- result.map(fields.prepare(
        fields,
        context,
        Some(union.tag),
        scope,
      ))
      let lines =
        list.append(names.doc_lines(docs, 2), constructor(name, fields, scope))
      #(WithFields(value, name, fields), lines)
    }
  }
}

/// A record that a union variant wraps encodes itself, so it must declare
/// the variant's tag as a constant field (`type = "section"`). The `""`
/// variant of an optional tag is the one that has no tag at all.
fn check_wrapped_tag(
  wrapped: Item,
  union: ir.Union,
  value: String,
  context: String,
) -> Result(Nil, String) {
  let tag = union.tag
  case wrapped {
    ir.RecordItem(ir.Record(name:, fields:, ..)) -> {
      let declared =
        list.find_map(fields, fn(field) {
          case field {
            ir.Const(key:, value:, ..) if key == tag -> Ok(value)
            _ -> Error(Nil)
          }
        })
      case value == "" && union.optional_tag, declared {
        True, Error(Nil) -> Ok(Nil)
        True, Ok(_) ->
          Error(
            context
            <> ": "
            <> name
            <> " must not declare the tag "
            <> tag
            <> ", the variant has no tag",
          )
        False, Ok(found) if found == value -> Ok(Nil)
        False, _ ->
          Error(
            context
            <> ": "
            <> name
            <> " must declare the tag as a constant field, `"
            <> tag
            <> " = "
            <> names.gleam_string(value)
            <> "`",
          )
      }
    }
    _ -> Ok(Nil)
  }
}

fn union_lines(union: ir.Union, scope: Scope) -> Result(List(String), String) {
  let ir.Union(name:, tag:, optional_tag:, docs:, variants:, unknown:, ..) =
    union
  let codec = types.alias(scope, types.codec_module)
  let value = types.alias(scope, types.value_module)
  use prepared <- result.map(
    list.try_map(variants, prepare_variant(_, union, scope)),
  )
  let tag_field = names.snake(tag)
  let unknown_docs = case unknown.docs {
    "" ->
      "A `"
      <> tag
      <> "` that this version of slackline does not know. `raw` holds the full json."
    docs -> docs
  }
  let function = names.snake(name)
  let tag_entry = fn(tag_value: String) {
    case tag_value == "" && optional_tag {
      True -> []
      False -> [
        codec
        <> ".field("
        <> names.gleam_string(tag)
        <> ", json.string("
        <> names.gleam_string(tag_value)
        <> "))",
      ]
    }
  }
  let decode_cases =
    list.flat_map(prepared, fn(entry) {
      case entry.0 {
        Wrapped(tag: value, name: ctor, type_:) -> [
          names.gleam_string(value)
          <> " -> decode.map("
          <> types.decoder(type_, scope)
          <> ", "
          <> ctor
          <> ")",
        ]
        WithFields(tag: value, name: ctor, fields: []) -> [
          names.gleam_string(value) <> " -> decode.success(" <> ctor <> ")",
        ]
        WithFields(tag: value, name: ctor, fields:) ->
          list.flatten([
            [names.gleam_string(value) <> " -> {"],
            fields.decode_fields(
              fields,
              scope,
              "decode.success(" <> fields.constructor_call(ctor, fields) <> ")",
            ),
            ["}"],
          ])
      }
    })
  let encode_cases =
    list.map(prepared, fn(entry) {
      case entry.0 {
        Wrapped(name: ctor, type_:, ..) ->
          ctor <> "(inner) -> " <> types.to_json(type_, "inner", scope)
        WithFields(tag: value, name: ctor, fields:) -> {
          let pattern = case fields.stored(fields) {
            [] -> ctor
            real -> ctor <> "(" <> fields.bindings(real) <> ")"
          }
          let entries =
            list.append(
              tag_entry(value),
              fields.encode_entries(fields, scope, fn(gleam) { "v_" <> gleam }),
            )
          pattern
          <> " -> "
          <> codec
          <> ".object("
          <> fields.render_list(entries)
          <> ")"
        }
      }
    })
  // A missing tag reads as "": the "" variant of an optional tag, else the
  // catch-all (Slack examples contain `"blocks": [{}]`).
  list.flatten([
    names.doc_lines(docs, 0),
    ["pub type " <> name <> " {"],
    list.flat_map(prepared, fn(entry) { entry.1 }),
    names.doc_lines(unknown_docs, 2),
    [
      unknown.name
        <> "("
        <> tag_field
        <> ": String, raw: "
        <> value
        <> ".Value)",
      "}",
      "",
      "/// Decodes `"
        <> name
        <> "` from json. The `"
        <> tag
        <> "` field selects the variant.",
      "pub fn " <> function <> "_decoder() -> decode.Decoder(" <> name <> ") {",
      "use tag <- decode.optional_field("
        <> names.gleam_string(tag)
        <> ", \"\", decode.string)",
      "case tag {",
    ],
    decode_cases,
    [
      "_ -> decode.map("
        <> value
        <> ".decoder(), "
        <> unknown.name
        <> "("
        <> tag_field
        <> ": tag, raw: _))",
      "}",
      "}",
      "",
      "/// Encodes `" <> name <> "` as json.",
      "pub fn " <> function <> "_to_json(it: " <> name <> ") -> json.Json {",
      "case it {",
    ],
    encode_cases,
    [
      unknown.name <> "(raw:, ..) -> " <> value <> ".to_json(raw)",
      "}",
      "}",
    ],
  ])
}

fn enum_lines(enum: ir.Enum) -> Result(List(String), String) {
  let ir.Enum(name:, docs:, values:, unknown:, file:) = enum
  use <- bool.guard(
    values == [] && unknown == None,
    Error(file <> ": enum " <> name <> " has no values"),
  )
  let values =
    list.map(values, fn(value) {
      #(
        value,
        option.lazy_unwrap(value.name, fn() { names.pascal(value.value) }),
      )
    })
  let function = names.snake(name)
  let first = case values {
    [#(_, ctor), ..] -> ctor
    [] -> name
  }
  let ctors =
    list.flat_map(values, fn(entry) {
      let #(value, ctor) = entry
      let docs = case value.docs {
        "" -> "`" <> value.value <> "`"
        docs -> docs
      }
      list.append(names.doc_lines(docs, 2), [ctor])
    })
  let to_string =
    list.map(values, fn(e) {
      e.1 <> " -> " <> names.gleam_string({ e.0 }.value)
    })
  let from_string = fn(wrap: fn(String) -> String) {
    list.map(values, fn(e) {
      names.gleam_string({ e.0 }.value) <> " -> " <> wrap(e.1)
    })
  }
  let #(unknown_ctor, unknown_to, from, fallback, result_type, decoder) = case
    unknown
  {
    Some(unknown) -> {
      let docs = case unknown.docs {
        "" -> "A value that this version of slackline does not know."
        docs -> docs
      }
      #(
        list.append(names.doc_lines(docs, 2), [unknown.name <> "(String)"]),
        [unknown.name <> "(other) -> other"],
        from_string(fn(ctor) { ctor }),
        "other -> " <> unknown.name <> "(other)",
        name,
        ["decode.map(decode.string, " <> function <> "_from_string)"],
      )
    }
    None -> #(
      [],
      [],
      from_string(fn(ctor) { "Ok(" <> ctor <> ")" }),
      "_ -> Error(Nil)",
      "Result(" <> name <> ", Nil)",
      [
        "use string <- decode.then(decode.string)",
        "case " <> function <> "_from_string(string) {",
        "Ok(parsed) -> decode.success(parsed)",
        "Error(Nil) -> decode.failure("
          <> first
          <> ", "
          <> names.gleam_string(name)
          <> ")",
        "}",
      ],
    )
  }
  Ok(
    list.flatten([
      names.doc_lines(docs, 0),
      ["pub type " <> name <> " {"],
      ctors,
      unknown_ctor,
      [
        "}",
        "",
        "/// The json string of `" <> name <> "`.",
        "pub fn " <> function <> "_to_string(it: " <> name <> ") -> String {",
        "case it {",
      ],
      to_string,
      unknown_to,
      [
        "}",
        "}",
        "",
        "/// Parses `" <> name <> "` from its json string.",
        "pub fn "
          <> function
          <> "_from_string(string: String) -> "
          <> result_type
          <> " {",
        "case string {",
      ],
      from,
      [
        fallback,
        "}",
        "}",
        "",
        "/// Decodes `" <> name <> "` from a json string.",
        "pub fn "
          <> function
          <> "_decoder() -> decode.Decoder("
          <> name
          <> ") {",
      ],
      decoder,
      [
        "}",
        "",
        "/// Encodes `" <> name <> "` as a json string.",
        "pub fn " <> function <> "_to_json(it: " <> name <> ") -> json.Json {",
        "json.string(" <> function <> "_to_string(it))",
        "}",
      ],
    ]),
  )
}

/// The decoder tries alternatives in order, so a record without required
/// fields (which decodes any object) can only come last.
fn check_shadowing(
  resolved: List(#(ir.OneofVariant, types.Resolved)),
  oneof: ir.Oneof,
  scope: Scope,
) -> Result(Nil, String) {
  let earlier = list.take(resolved, list.length(resolved) - 1)
  list.try_each(earlier, fn(entry) {
    case entry.1 {
      types.RNamed(path:, name: record, kind: types.RecordKind) ->
        case registry.find(scope.registry, path, record) {
          Some(ir.RecordItem(ir.Record(fields:, ..))) ->
            case list.any(fields, is_required) {
              True -> Ok(Nil)
              False ->
                Error(
                  oneof.file
                  <> ": "
                  <> oneof.name
                  <> "."
                  <> { entry.0 }.name
                  <> ": "
                  <> record
                  <> " has no required fields, so it decodes any object and the"
                  <> " alternatives after it are never tried. Put it last.",
                )
            }
          _ -> Ok(Nil)
        }
      _ -> Ok(Nil)
    }
  })
}

fn is_required(field: ir.Field) -> Bool {
  case field {
    ir.Field(modifier:, ..) -> modifier != ir.Optional
    _ -> False
  }
}

fn oneof_lines(oneof: ir.Oneof, scope: Scope) -> Result(List(String), String) {
  let ir.Oneof(name:, docs:, variants:, file:) = oneof
  use resolved <- result.try(
    list.try_map(variants, fn(variant) {
      let context = file <> ": " <> name <> "." <> variant.name
      use type_ <- result.map(types.resolve(variant.type_, scope, context))
      #(variant, type_)
    }),
  )
  use Nil <- result.try(check_shadowing(resolved, oneof, scope))
  let function = names.snake(name)
  let decoders =
    list.map(resolved, fn(e) {
      "decode.map(" <> types.decoder(e.1, scope) <> ", " <> { e.0 }.name <> ")"
    })
  use #(first, rest) <- result.map(case decoders {
    [first, ..rest] -> Ok(#(first, rest))
    [] -> Error(file <> ": oneof " <> name <> " has no alternatives")
  })
  list.flatten([
    names.doc_lines(docs, 0),
    ["pub type " <> name <> " {"],
    list.flat_map(resolved, fn(e) {
      list.append(names.doc_lines({ e.0 }.docs, 2), [
        { e.0 }.name <> "(" <> types.gleam_type(e.1, scope) <> ")",
      ])
    }),
    [
      "}",
      "",
      "/// Decodes `"
        <> name
        <> "` from json. It tries each alternative in order.",
      "pub fn " <> function <> "_decoder() -> decode.Decoder(" <> name <> ") {",
      "decode.one_of(" <> first <> ", " <> fields.render_list(rest) <> ")",
      "}",
      "",
      "/// Encodes `" <> name <> "` as json.",
      "pub fn " <> function <> "_to_json(it: " <> name <> ") -> json.Json {",
      "case it {",
    ],
    list.map(resolved, fn(e) {
      { e.0 }.name <> "(inner) -> " <> types.encoder(e.1, scope) <> "(inner)"
    }),
    ["}", "}"],
  ])
}
