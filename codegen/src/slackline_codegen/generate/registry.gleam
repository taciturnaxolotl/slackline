//// Every declared type, how names resolve to them, and the import alias
//// each module uses for the modules it refers to.

import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import slackline_codegen/generate/ir.{type Item, type Module}
import slackline_codegen/generate/names

/// Names no spec type may take.
pub const builtin_names = [
  "List", "Option", "Result", "Nil", "Bool", "Int", "Float", "String", "Dict",
  "BitArray",
]

pub type Registry {
  Registry(
    /// In declaration order, so error messages are stable.
    entries: List(#(String, String, Item)),
    index: Dict(#(String, String), Item),
  )
}

/// Types defined by hand in the runtime rather than in a spec. Specs refer
/// to them by bare name like any other type.
pub fn builtin_types() -> List(#(String, Item)) {
  let optional = fn(key, type_) {
    ir.Field(key, None, type_, ir.Optional, None, "")
  }
  let strings = ir.TypeExpr("List", [ir.TypeExpr("String", [])])
  [
    #(
      "slackline",
      ir.RecordItem(
        ir.Record(
          name: "ResponseMetadata",
          docs: "",
          file: "src/slackline.gleam",
          fields: [
            optional("next_cursor", ir.TypeExpr("String", [])),
            optional("warnings", strings),
            optional("messages", strings),
          ],
        ),
      ),
    ),
  ]
}

pub fn new() -> Registry {
  list.fold(builtin_types(), Registry([], dict.new()), fn(registry, entry) {
    let #(path, item) = entry
    let name = ir.item_name(item)
    Registry(
      entries: [#(path, name, item), ..registry.entries],
      index: dict.insert(registry.index, #(path, name), item),
    )
  })
}

pub fn add(
  registry: Registry,
  item: Item,
  module_path: String,
) -> Result(Registry, String) {
  let name = ir.item_name(item)
  let file = ir.item_file(item)
  let key = #(module_path, name)
  case list.contains(builtin_names, name), dict.has_key(registry.index, key) {
    True, _ ->
      Error(file <> ": type name " <> name <> " shadows a Gleam builtin")
    _, True ->
      Error(file <> ": type " <> name <> " defined twice in " <> module_path)
    _, _ ->
      Ok(Registry(
        entries: [#(module_path, name, item), ..registry.entries],
        index: dict.insert(registry.index, key, item),
      ))
  }
}

/// Builds the registry from the types of every module. A type name may only
/// be declared once across all modules, so each concept has one type.
pub fn from_modules(modules: List(Module)) -> Result(Registry, String) {
  use registry <- result.try(
    list.try_fold(modules, new(), fn(registry, module) {
      list.try_fold(module.items, registry, fn(registry, item) {
        add(registry, item, module.path)
      })
    }),
  )
  let entries = list.reverse(registry.entries)
  use Nil <- result.map(check_unique_names(entries))
  Registry(..registry, entries:)
}

fn check_unique_names(
  entries: List(#(String, String, Item)),
) -> Result(Nil, String) {
  list.try_fold(entries, dict.new(), fn(seen, entry) {
    let #(path, name, item) = entry
    case dict.get(seen, name) {
      Ok(other) ->
        Error(
          ir.item_file(item)
          <> ": type "
          <> name
          <> " is already declared in "
          <> other
          <> ". Refer to that type, or give this one a name of its own",
        )
      Error(Nil) -> Ok(dict.insert(seen, name, path))
    }
  })
  |> result.replace(Nil)
}

/// Resolves `Name` (this module first, then the only shared module that
/// declares it) or `path/to/module.Name`. Errors mention `context`.
pub fn lookup(
  registry: Registry,
  name: String,
  context: String,
  module_path: String,
) -> Result(#(String, Item), String) {
  case string.contains(name, ".") {
    True -> {
      let bare = names.bare(name)
      let path = string.drop_end(name, string.length(bare) + 1)
      case dict.get(registry.index, #(path, bare)) {
        Ok(item) -> Ok(#(path, item))
        Error(Nil) -> Error(context <> ": unknown type " <> name)
      }
    }
    False ->
      case dict.get(registry.index, #(module_path, name)) {
        Ok(item) -> Ok(#(module_path, item))
        Error(Nil) -> global_lookup(registry, name, context)
      }
  }
}

/// Types declared next to methods are private to their family. Only shared
/// type modules resolve globally.
fn global_lookup(
  registry: Registry,
  name: String,
  context: String,
) -> Result(#(String, Item), String) {
  let found =
    list.filter_map(registry.entries, fn(entry) {
      let #(path, bare, item) = entry
      case bare == name && !string.starts_with(path, "slackline/api/") {
        True -> Ok(#(path, item))
        False -> Error(Nil)
      }
    })
  case found {
    [] -> Error(context <> ": unknown type " <> name)
    [single] -> Ok(single)
    _ -> {
      let options =
        found
        |> list.map(fn(found) { found.0 <> "." <> name })
        |> string.join(", ")
      Error(
        context
        <> ": type "
        <> name
        <> " is ambiguous, write one of "
        <> options,
      )
    }
  }
}

// ---- import aliases --------------------------------------------------------

/// Gives each module path an import alias, in order: its last segment, or
/// the last two joined with `_` when that is taken by an earlier alias or a
/// `reserved` function name.
pub fn allocate_aliases(
  paths: List(String),
  reserved: Set(String),
) -> Dict(String, String) {
  list.fold(paths, dict.new(), fn(aliases, path) {
    case dict.has_key(aliases, path) {
      True -> aliases
      False -> {
        let taken = set.union(set.from_list(dict.values(aliases)), reserved)
        let candidate = names.alias_of(path)
        let candidate = case set.contains(taken, candidate) {
          False -> candidate
          True ->
            case string.split(path, "/") {
              [_, _, ..] as parts ->
                parts |> list.drop(list.length(parts) - 2) |> string.join("_")
              _ -> candidate <> "_"
            }
        }
        dict.insert(aliases, path, unique(candidate, taken))
      }
    }
  })
}

fn unique(candidate: String, taken: Set(String)) -> String {
  case set.contains(taken, candidate) {
    True -> unique(candidate <> "_", taken)
    False -> candidate
  }
}

/// The alias a module uses for `path`.
pub fn alias(aliases: Dict(String, String), path: String) -> String {
  case dict.get(aliases, path) {
    Ok(alias) -> alias
    Error(Nil) -> names.alias_of(path)
  }
}

/// Every type name an item refers to, in the order it renders them.
pub fn referenced_types(item: Item) -> List(String) {
  case item {
    ir.RecordItem(ir.Record(fields:, ..)) -> fields_types(fields)
    ir.UnionItem(ir.Union(variants:, ..)) ->
      list.flat_map(variants, fn(variant) {
        case variant {
          ir.WrapVariant(wraps:, ..) -> [wraps]
          ir.FieldsVariant(fields:, ..) -> fields_types(fields)
        }
      })
    ir.EnumItem(..) -> []
    ir.OneofItem(ir.Oneof(variants:, ..)) ->
      list.flat_map(variants, fn(variant) { type_names(variant.type_) })
  }
}

/// Every type name a method spec refers to.
pub fn method_types(method: ir.Method) -> List(String) {
  let response = case method.response {
    Some(ir.ResponseFields(fields)) -> fields_types(fields)
    Some(ir.ResponseType(type_)) -> type_names(type_)
    None -> []
  }
  list.append(fields_types(method.args), response)
}

fn fields_types(fields: List(ir.Field)) -> List(String) {
  list.flat_map(fields, fn(field) {
    case field {
      ir.Field(type_:, ..) -> type_names(type_)
      _ -> []
    }
  })
}

pub fn type_names(type_: ir.TypeExpr) -> List(String) {
  [type_.name, ..list.flat_map(type_.args, type_names)]
}

/// The modules that `names` resolve to from `module_path`, skipping names
/// that do not resolve (rendering reports those).
pub fn referenced_paths(
  registry: Registry,
  type_names: List(String),
  module_path: String,
) -> List(String) {
  list.filter_map(type_names, fn(name) {
    case lookup(registry, name, "", module_path) {
      Ok(#(path, _)) if path != module_path -> Ok(path)
      _ -> Error(Nil)
    }
  })
}

pub fn find(registry: Registry, path: String, name: String) -> Option(Item) {
  option.from_result(dict.get(registry.index, #(path, name)))
}
