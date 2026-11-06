//// Pull pieces out of a method page's markdown body.

import gleam/option.{type Option, None, Some}
import gleam/regexp
import gleam/string

/// The text under `## Heading {#anchor}`, up to the next `## ` heading.
/// `heading` must be plain words (it is spliced into a regexp).
pub fn find(body: String, heading: String) -> String {
  capture("(?sm)^## " <> heading <> " \\{#[^}]*\\}\\n(.*?)(?=^## |\\z)", body)
  |> option.unwrap("")
}

/// Group 1 of the first match of `pattern` in `text`. `regexp.scan` reports an
/// empty group as `None`. Here a match with an empty group is `Some("")`.
pub fn capture(pattern: String, text: String) -> Option(String) {
  let assert Ok(re) = regexp.from_string(pattern)
  case regexp.scan(re, text) {
    [regexp.Match(_, [group]), ..] -> Some(option.unwrap(group, ""))
    _ -> None
  }
}

/// Everything before the first line that starts with `prefix`.
pub fn before_line(text: String, prefix: String) -> String {
  case string.starts_with(text, prefix) {
    True -> ""
    False ->
      case string.split_once(text, "\n" <> prefix) {
        Ok(#(before, _)) -> before <> "\n"
        Error(_) -> text
      }
  }
}
