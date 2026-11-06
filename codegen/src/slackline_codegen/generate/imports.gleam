//// Works out the import lines of a generated module from its rendered body.
//// A candidate module is imported when the body uses its alias as
//// `alias.name`. String literals and comments do not count.

import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/set.{type Set}
import gleam/string
import slackline_codegen/generate/names
import slackline_codegen/generate/registry

type ImportEntry {
  /// An import line kept as written.
  Verbatim
  Entry(names: Set(String), alias: Option(String))
}

/// Modules that generated code can refer to without the registry knowing.
const always_candidates = [
  "gleam/json", "gleam/dynamic/decode", "gleam/dict", "gleam/list",
  "gleam/string", "slackline", "slackline/value", "slackline/internal/codec",
]

/// The sorted import lines for the module at `path`: the hand-written
/// `extra` imports, plus every candidate module whose alias the body uses,
/// plus the `gleam/option` names the body uses. The candidates are the
/// modules in `aliases` and a fixed list.
pub fn lines(
  path: String,
  aliases: Dict(String, String),
  body: List(String),
  extra: List(String),
) -> List(String) {
  let body_text = code_only(string.join(body, "\n"))
  let uses = fn(name: String, suffix: String) {
    regexp.check(names.regex("(?<![\\w.])" <> name <> suffix), body_text)
  }
  let merged = list.fold(extra, dict.new(), merge_extra)
  let merged =
    list.append(always_candidates, dict.keys(aliases))
    |> list.unique
    |> list.filter(fn(candidate) { candidate != path })
    |> list.fold(merged, fn(merged, candidate) {
      let alias = registry.alias(aliases, candidate)
      case uses(alias, "\\.") {
        False -> merged
        True -> {
          let #(imported, existing) = case dict.get(merged, candidate) {
            Ok(Entry(names:, alias:)) -> #(names, alias)
            _ -> #(set.new(), None)
          }
          let alias = case alias == names.alias_of(candidate) {
            True -> existing
            False -> Some(alias)
          }
          dict.insert(merged, candidate, Entry(imported, alias))
        }
      }
    })
  let option_names =
    [
      #("Option", "\\(", "type Option"),
      #("None", "\\b", "None"),
      #("Some", "\\b", "Some"),
    ]
    |> list.filter(fn(entry) { uses(entry.0, entry.1) })
    |> list.map(fn(entry) { entry.2 })
  let merged = case option_names {
    [] -> merged
    _ ->
      dict.upsert(merged, "gleam/option", fn(existing) {
        case existing {
          Some(Entry(names:, alias:)) ->
            Entry(set.union(names, set.from_list(option_names)), alias)
          _ -> Entry(set.from_list(option_names), None)
        }
      })
  }
  dict.to_list(merged)
  |> list.map(fn(entry) {
    case entry {
      #(line, Verbatim) -> line
      #(module, Entry(names:, alias:)) -> {
        let names = case sort_names(set.to_list(names)) {
          [] -> ""
          names -> ".{" <> string.join(names, ", ") <> "}"
        }
        let alias =
          option.map(alias, fn(alias) { " as " <> alias }) |> option.unwrap("")
        "import " <> module <> names <> alias
      }
    }
  })
  |> list.sort(string.compare)
}

/// `text` with string literals emptied and comments removed. One scan over
/// the whole text, so a string can span lines, a comment can follow code,
/// and `//` inside a string is not a comment.
pub fn code_only(text: String) -> String {
  let pattern = names.regex("\"(?:[^\"\\\\]|\\\\.)*\"|//[^\\n]*")
  regexp.match_map(pattern, text, fn(match) {
    case string.starts_with(match.content, "\"") {
      True -> "\"\""
      False -> ""
    }
  })
}

/// Types first, then values, each in alphabetical order.
fn sort_names(names: List(String)) -> List(String) {
  let #(types, values) = list.partition(names, string.starts_with(_, "type "))
  list.append(
    list.sort(types, string.compare),
    list.sort(values, string.compare),
  )
}

fn merge_extra(
  merged: Dict(String, ImportEntry),
  line: String,
) -> Dict(String, ImportEntry) {
  let pattern =
    names.regex("^import ([\\w/]+)(?:\\.\\{(.*?)\\})?(?: as (\\w+))?\\s*$")
  case regexp.scan(pattern, string.trim(line)) {
    [regexp.Match(submatches: [Some(module), ..groups], ..)] -> {
      let #(imported, alias) = case groups {
        [names, alias, ..] -> #(names, alias)
        [names] -> #(names, None)
        [] -> #(None, None)
      }
      let imported =
        imported
        |> option.map(fn(names) {
          names
          |> string.split(",")
          |> list.map(string.trim)
          |> list.filter(fn(n) { n != "" })
        })
        |> option.unwrap([])
      let entry = case dict.get(merged, module) {
        Ok(Entry(names:, alias: existing)) ->
          Entry(
            set.union(names, set.from_list(imported)),
            option.or(alias, existing),
          )
        _ -> Entry(set.from_list(imported), alias)
      }
      dict.insert(merged, module, entry)
    }
    _ -> dict.insert(merged, line, Verbatim)
  }
}
