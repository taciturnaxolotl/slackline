//// Decodes every request body and Socket Mode frame the live harness has
//// saved, with the current decoders. Run it after changing a spec to check
//// that old traffic still decodes, and that no catch-all variant remains.
////
//// ```sh
//// gleam run -m slackline_live/replay [dir ...]   # default build/live
//// ```

import argv
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleam/uri
import slackline/event
import slackline/interaction
import slackline/socket_mode
import slackline_live/env
import slackline_live/live

pub fn main() -> Nil {
  let dirs = case argv.load().arguments {
    [] -> ["build/live"]
    dirs -> dirs
  }
  let files =
    list.flat_map(dirs, fn(dir) {
      list.append(list_files(dir <> "/http"), list_files(dir <> "/socket"))
    })
  let results = list.map(files, replay)
  let bad = list.filter(results, fn(result) { result.1 != "" })
  list.each(bad, fn(result) { io.println(result.0 <> ": " <> result.1) })
  io.println(
    int.to_string(list.length(files))
    <> " saved bodies, "
    <> int.to_string(list.length(bad))
    <> " with problems.",
  )
}

fn replay(path: String) -> #(String, String) {
  let assert Ok(text) = env.read_file(path)
  let outcome = case string.ends_with(path, ".json") {
    True -> socket_mode.parse(text) |> inspect
    False -> {
      let body = case string.split_once(text, "\n\n") {
        Ok(#(_, body)) -> body
        Error(Nil) -> text
      }
      case string.starts_with(string.trim_start(body), "{") {
        True -> event.parse(body) |> inspect
        False ->
          case uri.parse_query(body) {
            Ok(fields) ->
              case list.key_find(fields, "payload") {
                Ok(payload) -> interaction.parse(payload) |> inspect
                // Slash commands are form fields with no payload.
                Error(Nil) -> Ok("")
              }
            Error(Nil) -> Error("not a form body")
          }
      }
    }
  }
  case outcome {
    Ok(found) -> #(path, found)
    Error(reason) -> #(path, "UNDECODED " <> string.slice(reason, 0, 300))
  }
}

fn inspect(result: Result(a, e)) -> Result(String, String) {
  case result {
    Ok(value) ->
      case live.unknowns(string.inspect(value)) {
        [] -> Ok("")
        found -> Ok("unknown " <> string.join(found, ", "))
      }
    Error(error) -> Error(string.inspect(error))
  }
}

@external(erlang, "slackline_live_ffi", "list_files")
fn list_files(dir: String) -> List(String)
