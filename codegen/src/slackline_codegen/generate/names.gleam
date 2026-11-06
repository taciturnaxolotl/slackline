//// Naming and text helpers: Gleam identifiers from Slack names, Gleam string
//// literals, and doc comments.

import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/string

pub const reserved = [
  "as", "assert", "auto", "case", "const", "delegate", "derive", "echo", "else",
  "fn", "if", "implement", "import", "let", "macro", "opaque", "panic", "pub",
  "test", "todo", "type", "use",
]

pub fn is_reserved(name: String) -> Bool {
  list.contains(reserved, name)
}

// ---- identifiers ---------------------------------------------------------

/// Compiles a pattern that is known to be valid.
pub fn regex(pattern: String) -> regexp.Regexp {
  let assert Ok(compiled) = regexp.from_string(pattern)
  compiled
}

/// Puts `_` between the two groups of every match of `pattern`.
fn split_groups(text: String, pattern: String) -> String {
  regexp.match_map(regex(pattern), text, fn(match) {
    case match.submatches {
      [Some(first), Some(second)] -> first <> "_" <> second
      _ -> match.content
    }
  })
}

/// A snake_case Gleam name for any Slack name: `scheduledMessages` becomes
/// `scheduled_messages`. `OAuth` is one word, so `OAuthTeam` becomes
/// `oauth_team`. Reserved words get a trailing `_`.
pub fn snake(name: String) -> String {
  let name =
    name
    |> regexp.replace(regex("[^A-Za-z0-9]+"), _, "_")
    |> string.replace("OAuth", "Oauth")
    |> split_groups("([a-z0-9])([A-Z])")
    |> split_groups("([A-Z]+)([A-Z][a-z])")
    |> string.lowercase
    |> regexp.replace(regex("^_+|_+$"), _, "")
    |> regexp.replace(regex("__+"), _, "_")
  let name = case name {
    "" -> "field"
    _ ->
      case regexp.check(regex("^[0-9]"), name) {
        True -> "n" <> name
        False -> name
      }
  }
  case is_reserved(name) {
    True -> name <> "_"
    False -> name
  }
}

/// A PascalCase constructor name: `foo-bar` and `fooBar` become `FooBar`.
pub fn pascal(name: String) -> String {
  let result =
    name
    |> split_groups("([a-z0-9])([A-Z])")
    |> regexp.split(regex("[^A-Za-z0-9]+"), _)
    |> list.map(fn(part) {
      string.uppercase(string.slice(part, 0, 1))
      <> string.lowercase(string.drop_start(part, 1))
    })
    |> string.concat
  case result {
    "" -> "Value"
    _ ->
      case regexp.check(regex("^[0-9]"), result) {
        True -> "N" <> result
        False -> result
      }
  }
}

/// Whether `name` is a valid Gleam field or module segment: `[a-z][a-z0-9_]*`.
pub fn is_lower_name(name: String) -> Bool {
  regexp.check(regex("^[a-z][a-z0-9_]*$"), name)
}

/// The last segment of a module path, its default import alias.
pub fn alias_of(path: String) -> String {
  case list.last(string.split(path, "/")) {
    Ok(last) -> last
    Error(Nil) -> path
  }
}

/// The part of `Qualified.Name` after the last dot.
pub fn bare(name: String) -> String {
  case list.last(string.split(name, ".")) {
    Ok(last) -> last
    Error(Nil) -> name
  }
}

// ---- literals and docs -------------------------------------------------

/// A Gleam string literal.
pub fn gleam_string(text: String) -> String {
  let body =
    text
    |> string.to_utf_codepoints
    |> list.map(fn(codepoint) {
      case string.utf_codepoint_to_int(codepoint) {
        0x5C -> "\\\\"
        0x22 -> "\\\""
        0x0A -> "\\n"
        0x09 -> "\\t"
        0x0D -> "\\r"
        c if c < 0x20 -> "\\u{" <> string.lowercase(int.to_base16(c)) <> "}"
        _ -> string.from_utf_codepoints([codepoint])
      }
    })
    |> string.concat
  "\"" <> body <> "\""
}

/// Generated doc comments wrap at this many columns.
pub const doc_width = 80

/// `///` doc comment lines for `text`, or nothing when it is empty. `depth`
/// is the column the comment starts at after formatting. Long lines wrap on
/// spaces at `doc_width` columns, except inside fenced code blocks. A word
/// wider than that stays on one line.
pub fn doc_lines(text: String, depth: Int) -> List(String) {
  comment_lines(text, "/// ", doc_width - depth)
}

/// `////` module doc lines for `text`, wrapped like `doc_lines`.
pub fn module_doc_lines(text: String) -> List(String) {
  comment_lines(text, "//// ", doc_width)
}

fn comment_lines(text: String, prefix: String, width: Int) -> List(String) {
  let width = width - string.length(prefix)
  let lines = case string.trim(text) {
    "" -> []
    text -> string.split(text, "\n") |> list.map(string.trim_end)
  }
  // The state is whether the line is inside a fenced code block.
  let #(_, wrapped) =
    list.map_fold(lines, False, fn(in_fence, line) {
      let fence = string.starts_with(string.trim(line), "```")
      let wrapped = case in_fence || fence || keep_as_is(line) {
        True -> [line]
        False -> wrap(line, width)
      }
      #(in_fence != fence, wrapped)
    })
  list.flat_map(
    wrapped,
    list.map(_, fn(line) { string.trim_end(prefix <> line) }),
  )
}

/// Indented code, tables and headings break when wrapped.
fn keep_as_is(line: String) -> Bool {
  string.starts_with(line, "    ")
  || string.starts_with(line, "\t")
  || string.starts_with(line, "|")
  || string.starts_with(line, "#")
}

fn wrap(line: String, width: Int) -> List(String) {
  case string.length(line) <= width {
    True -> [line]
    False -> {
      let leading = string.length(line) - string.length(string.trim_start(line))
      let atoms =
        string.trim_start(line)
        |> string.split(" ")
        |> list.filter(fn(atom) { atom != "" })
      // Continuation lines of a list item stay inside the item.
      let hanging = case atoms {
        [marker, ..] ->
          case is_list_marker(marker) {
            True -> leading + string.length(marker) + 1
            False -> leading
          }
        [] -> leading
      }
      fill(
        atoms,
        width,
        string.repeat(" ", leading),
        string.repeat(" ", hanging),
      )
    }
  }
}

/// Greedy fill. A word that would start a line and read as markdown syntax
/// there (`- `, `1.`, `#`) takes the previous word down with it.
fn fill(
  atoms: List(String),
  width: Int,
  first: String,
  rest: String,
) -> List(String) {
  let #(lines, current) =
    list.fold(atoms, #([], []), fn(acc, atom) {
      let #(lines, current) = acc
      let indent = case lines {
        [] -> first
        _ -> rest
      }
      let candidate = [atom, ..current]
      case current {
        [] -> #(lines, candidate)
        _ ->
          case string.length(indent <> join_atoms(candidate)) <= width {
            True -> #(lines, candidate)
            False ->
              case is_markdown_start(atom), current {
                True, [last, _, ..] -> #(
                  [indent <> join_atoms(list.drop(current, 1)), ..lines],
                  [atom, last],
                )
                True, _ -> #(lines, candidate)
                False, _ -> #([indent <> join_atoms(current), ..lines], [atom])
              }
          }
      }
    })
  let indent = case lines {
    [] -> first
    _ -> rest
  }
  list.reverse([indent <> join_atoms(current), ..lines])
}

fn join_atoms(reversed: List(String)) -> String {
  reversed |> list.reverse |> string.join(" ")
}

fn is_list_marker(atom: String) -> Bool {
  atom == "-" || atom == "*" || atom == "+" || is_ordered_marker(atom)
}

fn is_ordered_marker(atom: String) -> Bool {
  case string.ends_with(atom, ".") || string.ends_with(atom, ")") {
    False -> False
    True -> regexp.check(regex("^[0-9]+$"), string.drop_end(atom, 1))
  }
}

fn is_markdown_start(atom: String) -> Bool {
  is_list_marker(atom)
  || list.any(["#", ">", "|", "=", "```", "~~~"], string.starts_with(atom, _))
}
