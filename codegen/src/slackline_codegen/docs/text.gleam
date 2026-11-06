//// Small string helpers shared by the docs tooling.

import gleam/string

/// Removes every leading and trailing `char` from `text`.
pub fn strip(text: String, char: String) -> String {
  text |> drop_start(char) |> drop_end(char)
}

fn drop_start(text: String, char: String) -> String {
  case string.starts_with(text, char) {
    True -> drop_start(string.remove_prefix(text, char), char)
    False -> text
  }
}

fn drop_end(text: String, char: String) -> String {
  case string.ends_with(text, char) {
    True -> drop_end(string.remove_suffix(text, char), char)
    False -> text
  }
}
