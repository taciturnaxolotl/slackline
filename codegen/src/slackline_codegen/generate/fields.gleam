//// Fields after name checks and type resolution, and the Gleam snippets
//// shared by records, union variants, method arguments and responses.

import gleam/bool
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set
import gleam/string
import slackline_codegen/generate/ir.{type Encoding, type Field}
import slackline_codegen/generate/names
import slackline_codegen/generate/types.{type Resolved, type Scope}

pub type PField {
  PField(
    key: String,
    docs: String,
    gleam: String,
    type_: Resolved,
    optional: Bool,
    encoding: Option(Encoding),
  )
  /// A constant: always encoded, never stored.
  PConst(key: String, docs: String, value: String)
}

/// Checks field names, then resolves field types. `tag` is the union tag a
/// variant's fields may not use. Errors mention `context`.
pub fn prepare(
  fields: List(Field),
  context: String,
  tag: Option(String),
  scope: Scope,
) -> Result(List(PField), String) {
  use prepared <- result.try(prepare_any(fields, context, tag, scope))
  case list.find(prepared, holds_file) {
    Ok(field) ->
      Error(
        context
        <> "."
        <> field.key
        <> ": Upload is only for method arguments",
      )
    Error(Nil) -> Ok(prepared)
  }
}

/// Like `prepare`, for method arguments, which may be `Upload` but not hold
/// one inside a list or dict.
pub fn prepare_args(
  fields: List(Field),
  context: String,
  scope: Scope,
) -> Result(List(PField), String) {
  use prepared <- result.try(prepare_any(fields, context, None, scope))
  let nested =
    list.find(prepared, fn(field) {
      case field {
        PField(type_: types.RFile, ..) -> False
        _ -> holds_file(field)
      }
    })
  case nested {
    Ok(field) ->
      Error(context <> "." <> field.key <> ": Upload cannot be inside a type")
    Error(Nil) -> Ok(prepared)
  }
}

fn holds_file(field: PField) -> Bool {
  case field {
    PField(type_:, ..) -> types.contains_file(type_)
    PConst(..) -> False
  }
}

fn prepare_any(
  fields: List(Field),
  context: String,
  tag: Option(String),
  scope: Scope,
) -> Result(List(PField), String) {
  use named <- result.try(check_names(fields, context))
  list.try_map(named, fn(entry) {
    case entry {
      #(ir.Field(key:, type_:, modifier:, encoding:, docs:, ..), gleam) -> {
        use <- bool.guard(
          tag == Some(key),
          Error(context <> ": field " <> key <> " is the union tag"),
        )
        use resolved <- result.map(types.resolve(
          type_,
          scope,
          context <> "." <> key,
        ))
        PField(
          key:,
          docs:,
          gleam:,
          type_: resolved,
          optional: modifier == ir.Optional,
          encoding:,
        )
      }
      #(ir.Const(key:, value:, docs:), _) -> Ok(PConst(key:, docs:, value:))
      #(ir.Drop(key), _) -> Error(context <> ": cannot drop " <> key <> " here")
    }
  })
}

fn check_names(
  fields: List(Field),
  context: String,
) -> Result(List(#(Field, String)), String) {
  let named =
    list.map(fields, fn(field) {
      case field {
        ir.Field(key:, name:, ..) -> #(
          field,
          option.lazy_unwrap(name, fn() { names.snake(key) }),
        )
        _ -> #(field, "")
      }
    })
  use _ <- result.map(
    list.try_fold(named, set.new(), fn(seen, entry) {
      case entry {
        #(ir.Field(name:, ..), gleam) -> {
          let invalid =
            name != None
            && { !names.is_lower_name(gleam) || names.is_reserved(gleam) }
          use <- bool.guard(
            invalid,
            Error(context <> ": invalid field name " <> gleam),
          )
          use <- bool.guard(
            set.contains(seen, gleam),
            Error(context <> ": duplicate field " <> gleam),
          )
          Ok(set.insert(seen, gleam))
        }
        _ -> Ok(seen)
      }
    }),
  )
  named
}

/// The fields that are stored, leaving out constants.
pub fn stored(fields: List(PField)) -> List(PField) {
  list.filter(fields, fn(field) {
    case field {
      PField(..) -> True
      PConst(..) -> False
    }
  })
}

pub fn gleam_name(field: PField) -> String {
  case field {
    PField(gleam:, ..) -> gleam
    PConst(key:, ..) -> key
  }
}

pub fn field_type(field: PField, scope: Scope) -> String {
  case field {
    PField(type_:, optional: True, ..) ->
      "Option(" <> types.gleam_type(type_, scope) <> ")"
    PField(type_:, ..) -> types.gleam_type(type_, scope)
    PConst(..) -> "String"
  }
}

/// `name: Type,` lines for a constructor, with the field docs.
pub fn constructor_fields(fields: List(PField), scope: Scope) -> List(String) {
  list.flat_map(stored(fields), fn(field) {
    list.append(names.doc_lines(field.docs, 4), [
      gleam_name(field) <> ": " <> field_type(field, scope) <> ",",
    ])
  })
}

/// `use v_name <- decode.field(..)` lines, then `finish`. A constant is only
/// checked when present: Slack often leaves it out, but a different value
/// means the json is something else.
pub fn decode_fields(
  fields: List(PField),
  scope: Scope,
  finish: String,
) -> List(String) {
  let codec = types.alias(scope, types.codec_module)
  list.map(fields, fn(field) {
    case field {
      PField(key:, gleam:, type_:, optional: True, ..) ->
        "use v_"
        <> gleam
        <> " <- "
        <> codec
        <> ".optional_field("
        <> names.gleam_string(key)
        <> ", "
        <> types.decoder(type_, scope)
        <> ")"
      PField(key:, gleam:, type_:, ..) ->
        "use v_"
        <> gleam
        <> " <- decode.field("
        <> names.gleam_string(key)
        <> ", "
        <> types.decoder(type_, scope)
        <> ")"
      PConst(key:, value:, ..) ->
        "use _ <- decode.optional_field("
        <> names.gleam_string(key)
        <> ", "
        <> names.gleam_string(value)
        <> ", "
        <> codec
        <> ".constant("
        <> names.gleam_string(value)
        <> "))"
    }
  })
  |> list.append([finish])
}

/// `Ctor(a: v_a, b: v_b)`, or only `Ctor` without stored fields.
pub fn constructor_call(ctor: String, fields: List(PField)) -> String {
  case stored(fields) {
    [] -> ctor
    real -> ctor <> "(" <> bindings(real) <> ")"
  }
}

/// `a: v_a, b: v_b`
pub fn bindings(fields: List(PField)) -> String {
  fields
  |> list.map(fn(field) { gleam_name(field) <> ": v_" <> gleam_name(field) })
  |> string.join(", ")
}

/// `codec.field(..)` entries for an object. `access` gives the expression
/// that holds the value of a stored field.
pub fn encode_entries(
  fields: List(PField),
  scope: Scope,
  access: fn(String) -> String,
) -> List(String) {
  let codec = types.alias(scope, types.codec_module)
  list.map(fields, fn(field) {
    case field {
      PConst(key:, value:, ..) ->
        codec
        <> ".field("
        <> names.gleam_string(key)
        <> ", json.string("
        <> names.gleam_string(value)
        <> "))"
      PField(key:, gleam:, type_:, optional: True, ..) ->
        codec
        <> ".optional("
        <> names.gleam_string(key)
        <> ", "
        <> access(gleam)
        <> ", "
        <> types.encoder(type_, scope)
        <> ")"
      PField(key:, gleam:, type_:, ..) ->
        codec
        <> ".field("
        <> names.gleam_string(key)
        <> ", "
        <> types.to_json(type_, access(gleam), scope)
        <> ")"
    }
  })
}

/// A list literal. The trailing comma keeps one entry per line after
/// formatting.
pub fn render_list(entries: List(String)) -> String {
  case entries {
    [] -> "[]"
    _ -> "[" <> string.join(entries, ", ") <> ",]"
  }
}
