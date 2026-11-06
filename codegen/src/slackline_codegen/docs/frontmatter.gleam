//// Parse the YAML-ish frontmatter at the top of a docs page.

import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/string
import slackline_codegen/docs/text

pub type Meta {
  Meta(fields: Dict(String, String), bot: List(String), user: List(String))
}

/// Split a page into its frontmatter and the markdown body. A page without
/// frontmatter gets empty metadata and keeps its whole text.
pub fn parse(page: String) -> #(Meta, String) {
  case page {
    "---\n" <> rest ->
      case string.split_once(rest, "\n---\n") {
        Ok(#(head, body)) -> #(meta(head), body)
        Error(_) -> #(empty(), page)
      }
    _ -> #(empty(), page)
  }
}

fn empty() -> Meta {
  Meta(dict.new(), [], [])
}

fn meta(head: String) -> Meta {
  let assert Ok(kv) = regexp.from_string("^([a-z_]+): \"?(.*?)\"?$")
  let fields =
    string.split(head, "\n")
    |> list.fold(dict.new(), fn(fields, line) {
      case regexp.scan(kv, line) {
        [regexp.Match(_, [Some(key), value]), ..] ->
          dict.insert(fields, key, option.unwrap(value, ""))
        _ -> fields
      }
    })
  Meta(fields, scopes(head, "bot"), scopes(head, "user"))
}

/// The scopes in `  bot: ["a", "b"]` (or `user`) lines, if present.
fn scopes(head: String, kind: String) -> List(String) {
  let assert Ok(re) = regexp.from_string("(?m)^  " <> kind <> ": \\[(.*?)\\]")
  case regexp.scan(re, head) {
    [regexp.Match(_, [Some(list)]), ..] ->
      string.split(list, ",")
      |> list.map(string.trim)
      |> list.filter(fn(scope) { scope != "" })
      |> list.map(text.strip(_, "\""))
    _ -> []
  }
}

pub fn get(meta: Meta, key: String) -> Option(String) {
  case dict.get(meta.fields, key) {
    Ok(value) -> Some(value)
    Error(_) -> None
  }
}
