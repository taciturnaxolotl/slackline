//// Split llms-full-platform.txt into one markdown file per page.

import filepath
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/string
import simplifile
import slackline_codegen/docs/text

pub const source = "https://docs.slack.dev/llms-full-platform.txt"

/// Every page in the dump as `#(relative path, markdown)`. The path comes from
/// the page's `url:` frontmatter. The function skips pages without one.
pub fn pages(dump: String) -> List(#(String, String)) {
  let assert Ok(url) =
    regexp.from_string("(?m)^url: \"https://docs.slack.dev/([^\"]*)\"")
  string.split(dump, "\n---\ntitle: ")
  |> list.drop(1)
  |> list.filter_map(fn(part) {
    case regexp.scan(url, part) {
      [regexp.Match(_, [path]), ..] -> {
        let path = text.strip(option.unwrap(path, ""), "/")
        let path = case path {
          "" -> "index"
          _ -> path
        }
        Ok(#(path <> ".md", "---\ntitle: " <> part))
      }
      _ -> Error(Nil)
    }
  })
}

/// Write the pages under `out`, returning how many were written.
pub fn write(dump: String, out: String) -> Result(Int, String) {
  let pages = pages(dump)
  use _ <- result.try(
    list.try_each(pages, fn(page) {
      let path = filepath.join(out, page.0)
      use _ <- result.try(
        simplifile.create_directory_all(filepath.directory_name(path)),
      )
      simplifile.write(path, page.1)
    })
    |> result.map_error(fn(e) {
      "write failed: " <> simplifile.describe_error(e)
    }),
  )
  Ok(list.length(pages))
}
