//// Parse the `## Arguments` section of a method page.

import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/string
import slackline_codegen/docs/section

pub type Arg {
  Arg(
    name: String,
    /// `None` when the page shows the argument without a type.
    type_: Option(String),
    required: Bool,
    description: String,
    default: Option(String),
    example: Option(String),
  )
}

pub fn parse(body: String) -> List(Arg) {
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

fn entries(pieces: List(String)) -> List(Arg) {
  case pieces {
    [name, type_, required, chunk, ..rest] -> [
      entry(name, type_, required, chunk),
      ..entries(rest)
    ]
    _ -> []
  }
}

fn entry(name: String, type_: String, required: String, chunk: String) -> Arg {
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
  Arg(
    name:,
    type_: case type_ {
      "" -> None
      _ -> Some(type_)
    },
    required: required == "Required",
    description:,
    default: section.capture("(?m)^_Default:_ `(.*?)`", chunk),
    example: section.capture("(?m)^_Example:_ `(.*?)`\\s*$", chunk),
  )
}

pub fn to_json(arg: Arg) -> Json {
  json.object([
    #("name", json.string(arg.name)),
    #("type", nullable(arg.type_)),
    #("required", json.bool(arg.required)),
    #("description", json.string(arg.description)),
    #("default", nullable(arg.default)),
    #("example", nullable(arg.example)),
  ])
}

/// An optional string: `None` becomes `null`.
fn nullable(value: Option(String)) -> Json {
  json.nullable(value, json.string)
}
