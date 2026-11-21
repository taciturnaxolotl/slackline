//// Builds `spec/methods.json` entries for the Legal Holds API, whose methods
//// are documented together on `reference/legal-holds-api-reference.md`
//// instead of one page each.

import filepath
import gleam/json.{type Json}
import gleam/list
import gleam/option.{None, Some}
import gleam/regexp
import gleam/result
import gleam/string
import simplifile
import slackline_codegen/docs/args.{type Arg, Arg}
import slackline_codegen/docs/entry.{type MethodEntry, MethodEntry}
import slackline_codegen/docs/page
import slackline_codegen/docs/section

const page_path = "reference/legal-holds-api-reference.md"

const page_url = "https://docs.slack.dev/reference/legal-holds-api-reference"

/// One entry per method on the page, or none when the page is missing.
pub fn extract(docs: String) -> Result(List(MethodEntry), String) {
  case simplifile.read(filepath.join(docs, page_path)) {
    Error(simplifile.Enoent) -> Ok([])
    Error(error) -> Error(page_path <> ": " <> simplifile.describe_error(error))
    Ok(text) -> {
      let errors = page.errors(text)
      let assert Ok(heading) =
        regexp.from_string(
          "(?m)^### (admin\\.legalHold\\.[A-Za-z.]+) \\{#([a-z_]+)\\}$",
        )
      // Splitting on a regexp with groups interleaves the captures with the
      // text between matches: [before, name, anchor, body, name, ...].
      regexp.split(heading, section.find(text, "Methods"))
      |> list.drop(1)
      |> methods(errors)
      |> Ok
    }
  }
}

fn methods(pieces: List(String), errors: List(Json)) -> List(MethodEntry) {
  case pieces {
    [name, anchor, body, ..rest] -> [
      method(name, anchor, body, errors),
      ..methods(rest, errors)
    ]
    _ -> []
  }
}

fn method(
  name: String,
  anchor: String,
  body: String,
  errors: List(Json),
) -> MethodEntry {
  let field = fn(label) {
    section.capture("\\*\\*" <> label <> ":?\\*\\*:? `([^`]+)`", body)
  }
  let summary =
    string.trim(section.before_line(body, "**Method URL**"))
    |> string.replace("\n", " ")
    |> string.replace("](#", "](" <> page_url <> "#")
  MethodEntry(
    name:,
    summary:,
    deprecated: False,
    url: page_url <> "#" <> anchor,
    http_method: option.unwrap(field("HTTP Method"), "POST"),
    rate_limit: None,
    bot_scopes: [],
    user_scopes: option.to_result(field("Required scope"), Nil)
      |> result.map(fn(scope) { [scope] })
      |> result.unwrap([]),
    configuration_scopes: [],
    content_types: ["application/x-www-form-urlencoded"],
    args: arguments(body),
    errors:,
    response_examples: examples(body),
    response_fields: None,
  )
}

/// The argument table: a header row, then four lines per argument (name,
/// example, `Required` or `Optional`, description).
fn arguments(body: String) -> List(Arg) {
  let table =
    section.before_line(body, "### Example Request")
    |> string.split("\n")
    |> list.map(string.trim)
    |> list.filter(fn(line) { line != "" })
    |> list.drop_while(fn(line) { line != "Description" })
    |> list.drop(1)
  rows(table)
  |> list.filter(fn(arg) { arg.name != "token" })
}

fn rows(lines: List(String)) -> List(Arg) {
  case lines {
    [name, example, required, description, ..rest] -> [
      Arg(
        name: unquote(name),
        type_: Some(type_of(unquote(example))),
        required: required == "Required",
        description:,
        default: None,
        example: Some(unquote(example)),
      ),
      ..rows(rest)
    ]
    _ -> []
  }
}

fn unquote(text: String) -> String {
  case string.starts_with(text, "`") && string.ends_with(text, "`") {
    True -> text |> string.drop_start(1) |> string.drop_end(1)
    False -> text
  }
}

/// The page gives no types, so they come from the example value.
fn type_of(example: String) -> String {
  let assert Ok(digits) = regexp.from_string("^[0-9]+$")
  case example, regexp.check(digits, example) {
    "[" <> _, _ -> "array"
    "true", _ | "false", _ -> "boolean"
    _, True -> "integer"
    _, False -> "string"
  }
}

fn examples(body: String) -> List(Json) {
  case
    section.capture(
      "(?s)### Example Response[^\\n]*\\n\\n```json\\n(.*?)\\n```",
      body,
    )
  {
    None -> []
    Some(example) -> [
      json.object([
        #("title", json.string("Example Response")),
        #("body", json.string(string.replace(example, "\n", ""))),
      ]),
    ]
  }
}
