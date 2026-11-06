//// Builds `spec/methods.json` from the method pages in a docs directory.

import filepath
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import simplifile
import slackline_codegen/docs/args
import slackline_codegen/docs/frontmatter.{type Meta}
import slackline_codegen/docs/page

pub const output = "spec/methods.json"

/// Extract every method page under `<docs>/reference/methods` and write the
/// index to `output`. Returns the number of methods.
pub fn extract(docs: String) -> Result(Int, String) {
  let directory = filepath.join(docs, "reference/methods")
  use files <- result.try(
    simplifile.read_directory(directory) |> result.map_error(describe),
  )
  use methods <- result.try(
    files
    |> list.filter(string.ends_with(_, ".md"))
    |> list.sort(string.compare)
    |> list.try_map(fn(file) {
      simplifile.read(filepath.join(directory, file))
      |> result.map(method(file, _))
      |> result.map_error(describe)
    }),
  )
  use _ <- result.try(
    simplifile.create_directory_all(filepath.directory_name(output))
    |> result.map_error(describe),
  )
  use _ <- result.try(
    simplifile.write(output, render(methods))
    |> result.map_error(describe),
  )
  Ok(list.length(methods))
}

/// A json array with one method per line, so a change to one method is a
/// change to one line.
fn render(methods: List(Json)) -> String {
  "[\n" <> string.join(list.map(methods, json.to_string), ",\n") <> "\n]\n"
}

fn describe(error: simplifile.FileError) -> String {
  simplifile.describe_error(error)
}

fn method(file: String, text: String) -> Json {
  let #(meta, body) = frontmatter.parse(text)
  let summary = get(meta, "summary", "")
  let name = case get(meta, "method_name", "") {
    "" -> string.remove_suffix(file, ".md")
    name -> name
  }
  json.object([
    #("name", json.string(name)),
    #("summary", json.string(summary)),
    #(
      "deprecated",
      json.bool(
        string.starts_with(string.lowercase(summary), "deprecated")
        || string.contains(
          string.lowercase(get(meta, "title", "")),
          "deprecated",
        ),
      ),
    ),
    #("url", json.string(get(meta, "url", ""))),
    #("http_method", json.string(get(meta, "http_method", "POST"))),
    #("rate_limit", nullable(frontmatter.get(meta, "rate_limit"))),
    #(
      "scopes",
      json.object([
        #("bot", json.preprocessed_array(list.map(meta.bot, json.string))),
        #("user", json.preprocessed_array(list.map(meta.user, json.string))),
      ]),
    ),
    #("content_types", json.preprocessed_array(page.content_types(body))),
    #("args", json.preprocessed_array(args.parse(body))),
    #("errors", json.preprocessed_array(page.errors(body))),
    #("response_examples", json.preprocessed_array(page.responses(body))),
  ])
}

/// A frontmatter value, falling back to `default` when missing or empty.
fn get(meta: Meta, key: String, default: String) -> String {
  case frontmatter.get(meta, key) {
    Some("") | None -> default
    Some(value) -> value
  }
}

/// An optional string: `None` becomes `null`.
fn nullable(value: Option(String)) -> Json {
  json.nullable(value, json.string)
}
