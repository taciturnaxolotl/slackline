//// Docs tooling for slackline's code generator.
////
////     gleam run -m slackline_codegen/docs fetch [out-dir]
////     gleam run -m slackline_codegen/docs split <llms-full-platform.txt> [out-dir]
////     gleam run -m slackline_codegen/docs extract [docs-dir]
////
//// `fetch` downloads the Slack docs and splits them into one markdown page per
//// file (default `.docs`), `split` does the same from a local copy, and
//// `extract` turns the method pages into `spec/methods.json`.

import argv
import gleam/http/request
import gleam/httpc
import gleam/int
import gleam/io
import gleam/result
import gleam/string
import simplifile
import slackline_codegen/docs/methods
import slackline_codegen/docs/split
import slackline_codegen/root

const default_dir = ".docs"

pub fn main() -> Nil {
  root.enter()
  let result = case argv.load().arguments {
    ["fetch"] -> fetch(default_dir)
    ["fetch", out] -> fetch(out)
    ["split", file] -> split(file, default_dir)
    ["split", file, out] -> split(file, out)
    ["extract"] -> extract(default_dir)
    ["extract", dir] -> extract(dir)
    _ -> Error(usage)
  }
  case result {
    Ok(_) -> Nil
    Error(message) -> {
      io.println_error(message)
      halt(1)
    }
  }
}

const usage =
  "usage: gleam run -m slackline_codegen/docs <command>

  fetch [out-dir]                       download the Slack docs (default .docs)
  split <llms-full-platform.txt> [out]  split a local copy of the docs
  extract [docs-dir]                    write spec/methods.json from the docs"

fn fetch(out: String) -> Result(Nil, String) {
  io.println("fetching " <> split.source)
  let assert Ok(request) = request.to(split.source)
  use response <- result.try(
    httpc.configure()
    |> httpc.follow_redirects(True)
    |> httpc.timeout(120_000)
    |> httpc.dispatch(request)
    |> result.map_error(fn(error) {
      "could not download " <> split.source <> ": " <> string.inspect(error)
    }),
  )
  case response.status {
    200 -> write_pages(response.body, out)
    status -> Error("unexpected HTTP status " <> int.to_string(status))
  }
}

fn split(file: String, out: String) -> Result(Nil, String) {
  use dump <- result.try(
    simplifile.read(file)
    |> result.map_error(fn(error) {
      "could not read " <> file <> ": " <> simplifile.describe_error(error)
    }),
  )
  write_pages(dump, out)
}

fn write_pages(dump: String, out: String) -> Result(Nil, String) {
  use count <- result.map(split.write(dump, out))
  io.println("wrote " <> int.to_string(count) <> " pages to " <> out)
}

fn extract(dir: String) -> Result(Nil, String) {
  use count <- result.map(methods.extract(dir))
  io.println(
    "wrote " <> int.to_string(count) <> " methods to " <> methods.output,
  )
}

@external(erlang, "slackline_codegen_ffi", "halt")
fn halt(code: Int) -> Nil
