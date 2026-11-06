//// The smaller sections of a method page: content types, errors and
//// response examples.

import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/string
import slackline_codegen/docs/section

pub fn content_types(body: String) -> List(Json) {
  let facts = section.find(body, "Facts")
  case
    section.capture("(?s)\\*\\*Content types\\*\\*(.*?)(?=\\*\\*|\\z)", facts)
  {
    None -> []
    Some(found) -> {
      let assert Ok(type_) = regexp.from_string("`([a-z/+-]+)`")
      regexp.scan(type_, found)
      |> list.filter_map(fn(match) {
        case match {
          regexp.Match(_, [Some(name)]) -> Ok(json.string(name))
          _ -> Error(Nil)
        }
      })
    }
  }
}

/// Rows of the errors table: a `code` line, optionally followed by its
/// description line.
pub fn errors(body: String) -> List(Json) {
  let lines =
    section.find(body, "Errors")
    |> string.split("\n")
    |> list.map(string.trim)
    |> list.filter(fn(line) { line != "" })
    |> list.drop_while(fn(line) { line != "Description" })
  case lines {
    [_, ..rows] -> error_rows(rows)
    [] -> []
  }
}

fn error_rows(lines: List(String)) -> List(Json) {
  case lines {
    [] -> []
    [line, ..rest] ->
      case code(line) {
        None -> error_rows(rest)
        Some(code) ->
          case rest {
            [next, ..after] ->
              case is_code(next) {
                True -> [error(code, ""), ..error_rows(rest)]
                False -> [error(code, next), ..error_rows(after)]
              }
            [] -> [error(code, "")]
          }
      }
  }
}

fn is_code(line: String) -> Bool {
  option.is_some(code(line))
}

fn code(line: String) -> Option(String) {
  section.capture("^`([a-z0-9_]+)`$", line)
}

fn error(code: String, description: String) -> Json {
  json.object([
    #("code", json.string(code)),
    #("description", json.string(description)),
  ])
}

pub fn responses(body: String) -> List(Json) {
  let assert Ok(example) =
    regexp.from_string("(?sm)^#### (.*?)\\n\\n```\\n(.*?)\\n```")
  regexp.scan(example, section.find(body, "Response"))
  |> list.filter_map(fn(match) {
    case match {
      regexp.Match(_, [title, body]) ->
        Ok(
          json.object([
            #("title", json.string(string.trim(option.unwrap(title, "")))),
            #("body", json.string(string.trim(option.unwrap(body, "")))),
          ]),
        )
      _ -> Error(Nil)
    }
  })
}
