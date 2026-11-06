//// Parse the `## Arguments` section of a method page.

import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option}
import gleam/regexp
import gleam/string
import slackline_codegen/docs/section

pub fn parse(body: String) -> List(Json) {
  let assert Ok(arg) =
    regexp.from_string(
      "(?m)^\\*\\*`([^`]+)`\\*\\*(?:`([^`]*)`)?(Required|Optional)\\s*$",
    )
  // Splitting on a regexp with groups interleaves the captures with the text
  // between matches: [before, name, type, required, text, name, ...].
  regexp.split(arg, section.find(body, "Arguments"))
  |> list.drop(1)
  |> entries
}

fn entries(pieces: List(String)) -> List(Json) {
  case pieces {
    [name, type_, required, chunk, ..rest] -> [
      entry(name, type_, required, chunk),
      ..entries(rest)
    ]
    _ -> []
  }
}

fn entry(name: String, type_: String, required: String, chunk: String) -> Json {
  let chunk = section.before_line(chunk, "### ")
  let description =
    string.trim(chunk)
    |> string.split("\n")
    |> list.filter(fn(line) {
      !string.starts_with(line, "_Default:_")
      && !string.starts_with(line, "_Example:_")
    })
    |> list.map(string.trim)
    |> list.filter(fn(line) { line != "" })
    |> string.join(" ")
  json.object([
    #("name", json.string(name)),
    #("type", case type_ {
      "" -> json.null()
      _ -> json.string(type_)
    }),
    #("required", json.bool(required == "Required")),
    #("description", json.string(description)),
    #("default", nullable(section.capture("(?m)^_Default:_ `(.*?)`", chunk))),
    #(
      "example",
      nullable(section.capture("(?m)^_Example:_ `(.*?)`\\s*$", chunk)),
    ),
  ])
}

/// An optional string: `None` becomes `null`.
fn nullable(value: Option(String)) -> Json {
  json.nullable(value, json.string)
}
