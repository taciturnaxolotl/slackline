//// Lustre-style builders for a union whose variants wrap records, such as
//// `Block`: one function per variant that takes the required fields and a
//// list of attributes for the optional ones.
////
//// An attribute is an `Attr(record)` that updates the record a builder
//// makes. The union module declares `Attr` once, for all of its builders.
//// Each variant has a module of its own attributes, next to the builder
//// module (`slackline/block/section`). The record type is the type
//// parameter, so an attribute of another variant is a compile error.

import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/set
import gleam/string
import slackline_codegen/generate/fields
import slackline_codegen/generate/ir
import slackline_codegen/generate/names
import slackline_codegen/generate/registry.{type Registry}
import slackline_codegen/generate/types.{type Output, type Resolved, type Scope}

/// One variant of the union, with the record it wraps.
type Variant {
  Variant(
    tag: String,
    ctor: String,
    record: String,
    record_path: String,
    docs: String,
    args: List(Field),
    attrs: List(Field),
    /// The stored fields of the record, in declaration order.
    order: List(String),
  )
}

/// A stored field of a wrapped record.
type Field {
  Field(name: String, type_: Resolved, optional: Bool, docs: String)
}

/// The builder module and the attribute modules of a union declared with
/// `builders`. `scope` is the union module's. The builder module has no
/// docs when it is the union module.
pub fn render(
  union: ir.Union,
  scope: Scope,
  registry: Registry,
) -> Result(List(Output), String) {
  let union_path = scope.module_path
  use variants <- result.try(
    list.try_map(union.variants, prepare(_, union, union_path, registry)),
  )
  let builder_path = case union.builders {
    None | Some("") -> union_path
    Some(target) -> target
  }
  let functions = list.map(variants, fn(v) { names.snake(v.tag) })
  let functions = case builder_path == union_path {
    True -> list.append(attr_functions, functions)
    False -> functions
  }
  use Nil <- result.try(unique(functions, union.file <> ": " <> union.name))
  let scope = case builder_path == union_path {
    True -> scope
    False -> {
      let paths =
        list.flat_map(variants, fn(v) {
          [
            v.record_path,
            ..list.flat_map(v.args, fn(f) { types.paths(f.type_) })
          ]
        })
      let aliases = registry.allocate_aliases([union_path, ..paths], set.new())
      types.Scope(builder_path, registry, aliases)
    }
  }
  let union_type = constructor(union_path, union.name, scope)
  let docs = case builder_path == union_path {
    True -> ""
    False ->
      "Builders for `"
      <> union_path
      <> "."
      <> union.name
      <> "`. Each function builds one variant from its required fields and"
      <> " a list of attributes for the optional ones. An attribute is a `"
      <> union_path
      <> ".Attr`. The attributes of a variant are in the module named after"
      <> " it, such as `"
      <> attribute_path(builder_path, list.first(variants))
      <> "`."
  }
  let builder =
    types.Output(
      path: builder_path,
      docs:,
      chunks: list.map(variants, builder(_, union_path, union_type, scope)),
      aliases: scope.aliases,
      extra: "",
    )
  let attribute_modules =
    list.filter_map(variants, fn(v) {
      case v.attrs {
        [] -> Error(Nil)
        _ -> Ok(attribute_module(v, union_path, builder_path, registry))
      }
    })
  Ok([builder, ..attribute_modules])
}

fn prepare(
  variant: ir.Variant,
  union: ir.Union,
  union_path: String,
  registry: Registry,
) -> Result(Variant, String) {
  let context = union.file <> ": " <> union.name <> "." <> variant.name
  let not_wrapping = context <> ": builders need every variant to wrap a record"
  case variant {
    ir.FieldsVariant(..) -> Error(not_wrapping)
    ir.WrapVariant(tag:, name: ctor, wraps:, builder:, docs:) -> {
      use #(path, item) <- result.try(registry.lookup(
        registry,
        wraps,
        context,
        union_path,
      ))
      use record <- result.try(case item {
        ir.RecordItem(record) -> Ok(record)
        _ -> Error(not_wrapping)
      })
      let scope = types.Scope(path, registry, dict.new())
      use prepared <- result.try(fields.prepare(
        record.fields,
        context,
        None,
        scope,
      ))
      let stored =
        list.filter_map(prepared, fn(field) {
          case field {
            fields.PField(gleam:, type_:, optional:, docs:, ..) ->
              Ok(Field(gleam, type_, optional, docs))
            fields.PConst(..) -> Error(Nil)
          }
        })
      let required =
        list.filter_map(stored, fn(f) {
          case f.optional {
            True -> Error(Nil)
            False -> Ok(f.name)
          }
        })
      let arg_names = option.unwrap(builder, required)
      use args <- result.try(
        list.try_map(arg_names, fn(arg) {
          list.find(stored, fn(f) { f.name == arg })
          |> result.replace_error(
            context <> ": builder argument " <> arg <> " is not a field",
          )
        }),
      )
      use Nil <- result.try(
        list.try_each(required, fn(field) {
          case list.contains(arg_names, field) {
            True -> Ok(Nil)
            False ->
              Error(
                context
                <> ": the builder must take the required field "
                <> field,
              )
          }
        }),
      )
      Ok(Variant(
        tag:,
        ctor:,
        record: names.bare(wraps),
        record_path: path,
        docs: case docs {
          "" -> record.docs
          _ -> docs
        },
        args:,
        attrs: list.filter(stored, fn(f) { !list.contains(arg_names, f.name) }),
        order: list.map(stored, fn(f) { f.name }),
      ))
    }
  }
}

fn unique(names: List(String), context: String) -> Result(Nil, String) {
  list.try_fold(names, set.new(), fn(seen, name) {
    case set.contains(seen, name) {
      True -> Error(context <> ": builders would define " <> name <> " twice")
      False -> Ok(set.insert(seen, name))
    }
  })
  |> result.replace(Nil)
}

fn qualified_function(path: String, name: String, scope: Scope) -> String {
  case path == scope.module_path {
    True -> name
    False -> types.alias(scope, path) <> "." <> name
  }
}

/// A value constructor of a declared type, qualified for `scope`.
fn constructor(path: String, name: String, scope: Scope) -> String {
  case path == scope.module_path {
    True -> name
    False -> types.alias(scope, path) <> "." <> name
  }
}

/// The parameter type for a field, and the expression that turns the
/// parameter into the value of the field. `PlainText` fields take a `String`.
fn convert(field: Field, scope: Scope) -> #(String, String) {
  case field.type_ {
    types.RNamed(path:, name: "PlainText", ..) -> #(
      "String",
      constructor(path, "PlainText", scope)
        <> "(text: "
        <> field.name
        <> ", emoji: None)",
    )
    _ -> #(types.gleam_type(field.type_, scope), field.name)
  }
}

/// The `Attr` type of a module with unions that have builders, and the
/// functions that make and apply attributes. Builders in other modules use
/// these too.
pub fn attr_lines() -> List(String) {
  [
    "/// An optional field for a builder. `record` is the record the builder",
    "/// makes, so each builder only takes its own attributes.",
    "pub opaque type Attr(record) {",
    "Attr(fn(record) -> record)",
    "}",
    "",
    "/// An attribute that updates the record with `set`. The attribute",
    "/// modules use it, and you can use it for a change that they do not cover.",
    "pub fn attr(set: fn(record) -> record) -> Attr(record) {",
    "Attr(set)",
    "}",
    "",
    "@internal",
    "pub fn apply(record: record, attrs: List(Attr(record))) -> record {",
    "list.fold(attrs, record, fn(record, attr) {",
    "let Attr(set) = attr",
    "set(record)",
    "})",
    "}",
  ]
}

/// The names `attr_lines` defines.
pub const attr_functions = ["attr", "apply"]

fn builder(
  v: Variant,
  union_path: String,
  union_type: String,
  scope: Scope,
) -> List(String) {
  let record = constructor(v.record_path, v.record, scope)
  let params =
    list.map(v.args, fn(f) {
      f.name <> " " <> f.name <> ": " <> convert(f, scope).0
    })
  let attrs_param =
    "with attrs: List("
    <> constructor(union_path, "Attr", scope)
    <> "("
    <> types.gleam_type(record_type(v), scope)
    <> "))"
  // Record fields in declaration order: arguments or `None`.
  let values =
    list.map(v.order, fn(name) {
      case list.find(v.args, fn(arg) { arg.name == name }) {
        Ok(arg) if arg.optional ->
          name <> ": Some(" <> convert(arg, scope).1 <> ")"
        Ok(arg) -> name <> ": " <> convert(arg, scope).1
        Error(Nil) -> name <> ": None"
      }
    })
  let base = case values {
    [] -> record
    _ -> record <> "(" <> string.join(values, ", ") <> ")"
  }
  let attribute_docs = case v.attrs {
    [] -> ""
    attrs ->
      "\n\nAttributes: "
      <> string.join(
        list.map(attrs, fn(a) {
          "`" <> names.snake(v.tag) <> "." <> a.name <> "`"
        }),
        ", ",
      )
      <> "."
  }
  list.flatten([
    names.doc_lines(v.docs <> attribute_docs, 0),
    [
      "pub fn "
        <> names.snake(v.tag)
        <> "("
        <> string.join(list.append(params, [attrs_param]), ", ")
        <> ") -> "
        <> union_type
        <> " {",
      constructor(union_path, v.ctor, scope)
        <> "("
        <> qualified_function(union_path, "apply", scope)
        <> "("
        <> base
        <> ", attrs))",
      "}",
    ],
  ])
}

fn record_type(v: Variant) -> Resolved {
  types.RNamed(v.record_path, v.record, types.RecordKind)
}

/// The module of the attributes of a variant: `builder_path/tag`.
fn attribute_path(builder_path: String, v: Result(Variant, Nil)) -> String {
  case v {
    Ok(v) -> builder_path <> "/" <> names.snake(v.tag)
    Error(Nil) -> builder_path
  }
}

fn attribute_module(
  v: Variant,
  union_path: String,
  builder_path: String,
  registry: Registry,
) -> Output {
  let path = attribute_path(builder_path, Ok(v))
  let reserved = set.from_list(list.map(v.attrs, fn(a) { a.name }))
  let aliases =
    registry.allocate_aliases(
      [
        union_path,
        v.record_path,
        ..list.flat_map(v.attrs, fn(a) { types.paths(a.type_) })
      ],
      reserved,
    )
  let scope = types.Scope(path, registry, aliases)
  let union_alias = registry.alias(aliases, union_path)
  let record = constructor(v.record_path, v.record, scope)
  let attr_type =
    union_alias <> ".Attr(" <> types.gleam_type(record_type(v), scope) <> ")"
  let chunks =
    list.map(v.attrs, fn(a) {
      let #(param_type, value) = convert(a, scope)
      // A record update that names every field is a warning.
      let update = case v.order {
        [_] ->
          "fn(_) { " <> record <> "(" <> a.name <> ": Some(" <> value <> ")) }"
        _ ->
          "fn(it) { "
          <> record
          <> "(..it, "
          <> a.name
          <> ": Some("
          <> value
          <> ")) }"
      }
      let docs = case a.docs {
        "" -> "Sets `" <> a.name <> "`."
        docs -> docs
      }
      list.append(names.doc_lines(docs, 0), [
        "pub fn "
          <> a.name
          <> "("
          <> a.name
          <> ": "
          <> param_type
          <> ") -> "
          <> attr_type
          <> " {",
        union_alias <> ".attr(" <> update <> ")",
        "}",
      ])
    })
  types.Output(
    path:,
    docs: "Attributes for `"
      <> names.alias_of(builder_path)
      <> "."
      <> names.snake(v.tag)
      <> "`.",
    chunks:,
    aliases:,
    extra: "",
  )
}
