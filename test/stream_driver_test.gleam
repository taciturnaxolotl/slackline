//// Tests for the two drivers, `stream/httpc` and `stream/fetch`, run
//// against a fake Slack. They check that a reply streams, finishes and
//// reports what it posted. They also check that the drivers wait out rate
//// limits and don't lose updates made during a call.

import gleam/list
import gleam/option.{None}
import gleam/string
import slackline
import slackline/api/chat
import slackline/stream

fn describe(step: stream.Step) -> String {
  case step {
    stream.Start(chunks) -> "start " <> texts(chunks)
    stream.Append(chunks:, ..) -> "append " <> texts(chunks)
    stream.Stop(chunks:, ..) -> "stop " <> texts(chunks)
    stream.Post(text) -> "post " <> text
    stream.PostPlan(..) -> "plan"
    stream.UpdatePlan(..) -> "update plan"
  }
}

fn texts(chunks: List(chat.StreamChunk)) -> String {
  list.filter_map(chunks, fn(chunk) {
    case chunk {
      chat.MarkdownTextChunk(text) -> Ok(text)
      _ -> Error(Nil)
    }
  })
  |> string.concat
}

fn answer(step: stream.Step) -> Result(String, slackline.Error) {
  case step {
    stream.Start(_) -> Ok("m1")
    stream.Post(_) | stream.PostPlan(..) -> Ok("p1")
    _ -> Ok("")
  }
}

fn builder() {
  let assert Ok(client) =
    slackline.new("xoxb-test")
    |> slackline.with_base_url("http://127.0.0.1:1/api")
  stream.new(client, channel: "C1")
  |> stream.in_thread("1.0")
  |> stream.every(10)
}

@target(erlang)
import gleam/erlang/process

@target(erlang)
import slackline/stream/httpc

@target(erlang)
/// A fake Slack that records each call and answers with `answer`.
fn recording(
  seen: process.Subject(String),
  answer: fn(stream.Step) -> Result(String, slackline.Error),
) {
  fn(step) {
    process.send(seen, describe(step))
    answer(step)
  }
}

@target(erlang)
/// Returns True the first time the calling process asks about `key`.
@external(erlang, "slackline_test_ffi", "first_time")
fn first_time(key: String) -> Bool

@target(erlang)
fn made(seen: process.Subject(String)) -> List(String) {
  case process.receive(seen, 0) {
    Ok(call) -> [call, ..made(seen)]
    Error(Nil) -> []
  }
}

@target(erlang)
pub fn httpc_reply_streams_and_settles_test() {
  let seen = process.new_subject()
  let assert Ok(reply) = httpc.open_with(builder(), recording(seen, answer))
  httpc.text(reply, "Looking")
  httpc.task(reply, stream.Task("a", "Run tests", stream.Running, "", ""))
  // Updates that arrive close together go out as one call.
  httpc.text(reply, "Looking at it.")
  process.sleep(50)
  // Text added just before finishing goes out with the closing line.
  httpc.text(reply, "Looking at it. Found it.")
  let assert Ok(finished) = httpc.finish(reply, closing: "Done")
  assert made(seen) == ["start Looking at it.", "stop  Found it.\n\nDone"]
  assert finished == stream.Finished(["m1"], True, None)
}

@target(erlang)
pub fn httpc_finish_without_updates_posts_the_closing_test() {
  let seen = process.new_subject()
  let assert Ok(reply) = httpc.open_with(builder(), recording(seen, answer))
  let assert Ok(finished) = httpc.finish(reply, closing: "Nothing to do")
  assert made(seen) == ["post Nothing to do"]
  assert finished.messages == ["p1"]
  // Finishing a reply twice returns an error.
  assert httpc.finish(reply, closing: "") == Error(Nil)
}

@target(erlang)
pub fn httpc_waits_out_a_rate_limit_test() {
  let seen = process.new_subject()
  let slack = fn(step) {
    case step {
      stream.Start(_) ->
        case first_time("start") {
          True -> Error(slackline.RateLimited(0))
          False -> answer(step)
        }
      _ -> answer(step)
    }
  }
  let assert Ok(reply) = httpc.open_with(builder(), recording(seen, slack))
  httpc.text(reply, "hello")
  process.sleep(50)
  let assert Ok(finished) = httpc.finish(reply, closing: "")
  assert made(seen) == ["start hello", "start hello", "stop "]
  assert finished.streamed
}

@target(javascript)
import gleam/javascript/promise

@target(javascript)
import slackline/stream/fetch

@target(javascript)
type Log

@target(javascript)
@external(javascript, "./slackline_test_ffi.mjs", "new_log")
fn new_log() -> Log

@target(javascript)
@external(javascript, "./slackline_test_ffi.mjs", "push")
fn push(log: Log, entry: String) -> Nil

@target(javascript)
@external(javascript, "./slackline_test_ffi.mjs", "entries")
fn entries(log: Log) -> List(String)

@target(javascript)
/// A fake Slack that records each call into `calls` and answers after
/// `delay` milliseconds.
fn slow_slack(
  calls: Log,
  delay: Int,
  answer: fn(stream.Step) -> Result(String, slackline.Error),
) {
  fn(step) {
    push(calls, describe(step))
    use _ <- promise.map(promise.wait(delay))
    answer(step)
  }
}

@target(javascript)
pub fn fetch_reply_streams_and_settles_test() {
  let calls = new_log()
  let reply = fetch.open_with(builder(), slow_slack(calls, 0, answer))
  fetch.text(reply, "Looking")
  fetch.task(reply, stream.Task("a", "Run tests", stream.Running, "", ""))
  fetch.text(reply, "Looking at it.")
  use _ <- promise.await(promise.wait(50))
  fetch.text(reply, "Looking at it. Found it.")
  use finished <- promise.map(fetch.finish(reply, closing: "Done"))
  assert entries(calls) == ["start Looking at it.", "stop  Found it.\n\nDone"]
  assert finished == stream.Finished(["m1"], True, None)
}

@target(javascript)
pub fn fetch_keeps_updates_made_during_a_call_test() {
  let calls = new_log()
  let reply = fetch.open_with(builder(), slow_slack(calls, 40, answer))
  fetch.text(reply, "one")
  // This update arrives while the start call is still running.
  use _ <- promise.await(promise.wait(25))
  fetch.text(reply, "one two")
  use _ <- promise.await(promise.wait(100))
  use _ <- promise.map(fetch.finish(reply, closing: ""))
  assert entries(calls) == ["start one", "append  two", "stop "]
}

@target(javascript)
pub fn fetch_waits_as_long_as_slack_asks_test() {
  let calls = new_log()
  let limited = new_log()
  let slack = fn(step) {
    case step, entries(limited) {
      stream.Append(..), [] -> {
        push(limited, "once")
        Error(slackline.RateLimited(1))
      }
      _, _ -> answer(step)
    }
  }
  let reply = fetch.open_with(builder(), slow_slack(calls, 0, slack))
  fetch.text(reply, "one")
  use _ <- promise.await(promise.wait(40))
  fetch.text(reply, "one two")
  use _ <- promise.await(promise.wait(40))
  // An update during the wait doesn't end the wait early.
  fetch.text(reply, "one two three")
  use _ <- promise.await(promise.wait(300))
  assert entries(calls) == ["start one", "append  two"]
  use _ <- promise.await(promise.wait(900))
  assert entries(calls) == ["start one", "append  two", "append  two three"]
  use _ <- promise.map(fetch.finish(reply, closing: ""))
  Nil
}
