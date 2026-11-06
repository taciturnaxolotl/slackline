//// Generates the Gleam modules under `src/` and the example test from the
//// specs in `spec/`. Run it from `codegen/` or from the project root:
////
//// ```sh
//// gleam run -m slackline_codegen/generate             # write src/**/*.gleam
//// gleam run -m slackline_codegen/generate -- --check  # fail if anything is stale
//// gleam run -m slackline_codegen/generate -- --report # methods still returning raw json
//// ```
////
//// Every generated file starts with the generated marker. The generator
//// deletes files with the marker that it no longer writes, so a rename
//// leaves no old files behind. It formats all output with one `gleam format`
//// run on a temporary directory.

import argv
import filepath
import gleam/dict
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/string
import simplifile
import slackline_codegen/generate/ir
import slackline_codegen/generate/methods_json
import slackline_codegen/generate/module
import slackline_codegen/root

pub fn main() -> Nil {
  root.enter()
  let args = argv.load().arguments
  case run(list.contains(args, "--check"), list.contains(args, "--report")) {
    Ok(Nil) -> Nil
    Error(message) -> {
      io.println_error(message)
      halt(1)
    }
  }
}

fn run(check: Bool, report: Bool) -> Result(Nil, String) {
  use inputs <- result.try(read_inputs())
  use built <- result.try(
    module.build(inputs) |> result.map_error(fn(e) { "error: " <> e }),
  )
  case report {
    True -> Ok(print_report(inputs.methods, built))
    False -> {
      use files <- result.try(format(built.files))
      write_outputs(files, check)
    }
  }
}

fn print_report(methods: List(ir.DocsMethod), built: module.Built) -> Nil {
  let raw =
    list.filter(methods, fn(method) {
      case dict.get(built.placement, method.name) {
        Ok(ir.Method(response: Some(_), ..)) -> False
        _ -> True
      }
    })
  let total = list.length(methods)
  io.println(
    int.to_string(total - list.length(raw))
    <> "/"
    <> int.to_string(total)
    <> " methods have typed responses",
  )
  list.each(raw, fn(method) { io.println("  " <> method.name) })
}

fn describe(
  action: String,
  path: String,
) -> fn(simplifile.FileError) -> String {
  fn(error) {
    "error: cannot "
    <> action
    <> " "
    <> path
    <> ": "
    <> simplifile.describe_error(error)
  }
}

fn read(path: String) -> Result(String, String) {
  simplifile.read(path) |> result.map_error(describe("read", path))
}

fn gleam_files(directory: String, suffix: String) -> List(String) {
  simplifile.get_files(directory)
  |> result.unwrap([])
  |> list.filter(fn(path) {
    string.ends_with(path, suffix)
    && !list.any(string.split(path, "/"), string.starts_with(_, "."))
  })
  |> list.sort(string.compare)
}

fn read_inputs() -> Result(module.Inputs, String) {
  let spec_files = gleam_files("spec", ".sls")
  use specs <- result.try(
    list.try_map(spec_files, fn(path) {
      read(path) |> result.map(fn(text) { #(path, text) })
    }),
  )
  let extras =
    spec_files
    |> list.filter_map(fn(path) {
      let extra = module.extra_path(path)
      simplifile.read(extra)
      |> result.map(fn(text) { #(extra, text) })
      |> result.replace_error(Nil)
    })
    |> dict.from_list
  use text <- result.try(read("spec/methods.json"))
  use methods <- result.map(
    json.parse(text, methods_json.decoder())
    |> result.map_error(fn(e) {
      "error: spec/methods.json: " <> string.inspect(e)
    }),
  )
  module.Inputs(specs:, extras:, methods:)
}

/// Formats every file with one `gleam format` run on a temporary copy, so
/// `--check` compares exactly what a write would produce.
fn format(
  files: List(#(String, String)),
) -> Result(List(#(String, String)), String) {
  let directory =
    filepath.join(temporary_directory(), "slackline_codegen_" <> unique_name())
  let in_directory = fn(path) { filepath.join(directory, path) }
  use _ <- result.try(
    list.try_each(files, fn(file) {
      let path = in_directory(file.0)
      let _ = simplifile.create_directory_all(filepath.directory_name(path))
      simplifile.write(path, file.1)
      |> result.map_error(describe("write", path))
    }),
  )
  case format_directory(directory) {
    Ok(Nil) -> Nil
    Error(reason) ->
      io.println_error("warning: gleam format failed:\n" <> reason)
  }
  let formatted =
    list.try_map(files, fn(file) {
      read(in_directory(file.0)) |> result.map(fn(text) { #(file.0, text) })
    })
  let _ = simplifile.delete(directory)
  formatted
}

fn temporary_directory() -> String {
  case simplifile.is_directory("/tmp") {
    Ok(True) -> "/tmp"
    _ -> "."
  }
}

fn write_outputs(
  expected: List(#(String, String)),
  check: Bool,
) -> Result(Nil, String) {
  let expected_paths = list.map(expected, fn(entry) { entry.0 })
  let stale =
    list.append(gleam_files("src", ".gleam"), gleam_files("test", ".gleam"))
    |> list.filter(fn(path) {
      !list.contains(expected_paths, path)
      && {
        simplifile.read(path)
        |> result.map(string.starts_with(_, module.marker <> "\n"))
        |> result.unwrap(False)
      }
    })
  let changed =
    list.filter(expected, fn(entry) { simplifile.read(entry.0) != Ok(entry.1) })
  case check {
    True ->
      case changed, stale {
        [], [] -> Ok(Nil)
        _, _ -> {
          list.each(
            list.append(list.map(changed, fn(e) { e.0 }), stale),
            fn(path) { io.println("stale: " <> path) },
          )
          halt(1)
          Ok(Nil)
        }
      }
    False -> {
      use _ <- result.try(
        list.try_each(stale, fn(path) {
          simplifile.delete(path) |> result.map_error(describe("delete", path))
        }),
      )
      use _ <- result.map(
        list.try_each(changed, fn(entry) {
          let #(path, text) = entry
          let _ = simplifile.create_directory_all(filepath.directory_name(path))
          simplifile.write(path, text)
          |> result.map_error(describe("write", path))
        }),
      )
      io.println(
        "generated "
        <> int.to_string(list.length(expected))
        <> " modules ("
        <> int.to_string(list.length(changed))
        <> " changed, "
        <> int.to_string(list.length(stale))
        <> " removed)",
      )
    }
  }
}

fn unique_name() -> String {
  int.to_string(int.random(1_000_000_000))
}

@external(erlang, "slackline_codegen_ffi", "format_directory")
fn format_directory(directory: String) -> Result(Nil, String)

@external(erlang, "slackline_codegen_ffi", "halt")
fn halt(code: Int) -> Nil
