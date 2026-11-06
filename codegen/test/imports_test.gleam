//// The import lines of a generated module come from the aliases its body
//// uses. These tests cover text that mentions an alias without using it.

import gleam/dict
import slackline_codegen/generate/imports
import slackline_codegen/generate/module

fn imports_of(body: List(String)) -> List(String) {
  imports.lines("slackline/example", dict.new(), body, [])
}

pub fn comment_after_code_is_not_a_use_test() {
  assert imports_of(["let x = 1 // see list.map"]) == []
}

pub fn string_across_lines_is_not_a_use_test() {
  let body = [
    "let text = \"the first line", "dict.get(it) is text\"",
    "list.length([text])",
  ]
  assert imports_of(body) == ["import gleam/list"]
}

pub fn comment_marker_inside_string_is_not_a_comment_test() {
  assert imports_of(["let url = \"https://example.com\" |> string.trim"])
    == ["import gleam/string"]
}

pub fn import_across_lines_stays_one_import_test() {
  let extra =
    "import gleam/option.{\n  type Option,\n  None,\n}\n\npub fn f() {}"
  let #(head, body) = module.split_extra(extra)
  assert head == ["import gleam/option.{ type Option, None, }"]
  assert body == ["pub fn f() {}"]
  assert imports.lines("slackline/example", dict.new(), body, head)
    == ["import gleam/option.{type Option, None}"]
}
