//// `retrying` runs a call again while Slack rate limits it.

import gleam/list
import log
import slackline

fn attempt(name: String, results: List(Result(Int, slackline.Error))) {
  fn() {
    log.record(name)
    let tried = list.count(log.recorded(), fn(entry) { entry == name })
    case list.drop(results, tried - 1) {
      [result, ..] -> result
      [] -> Ok(0)
    }
  }
}

fn tries(name: String) -> Int {
  list.count(log.recorded(), fn(entry) { entry == name })
}

@target(erlang)
import slackline/httpc

@target(erlang)
pub fn retries_rate_limited_test() {
  let run =
    attempt("retry-1", [
      Error(slackline.RateLimited(0)),
      Error(slackline.RateLimited(0)),
      Ok(3),
    ])
  assert httpc.retrying(attempts: 5, run:) == Ok(3)
  assert tries("retry-1") == 3
}

@target(erlang)
pub fn gives_up_after_attempts_test() {
  let run = attempt("retry-2", list.repeat(Error(slackline.RateLimited(0)), 9))
  assert httpc.retrying(attempts: 2, run:) == Error(slackline.RateLimited(0))
  assert tries("retry-2") == 2
}

@target(erlang)
pub fn other_errors_return_at_once_test() {
  let failure = slackline.TransportError("down")
  let run = attempt("retry-3", [Error(failure), Ok(1)])
  assert httpc.retrying(attempts: 5, run:) == Error(failure)
  assert tries("retry-3") == 1
}

@target(javascript)
import gleam/javascript/promise

@target(javascript)
import slackline/fetch

@target(javascript)
pub fn fetch_retries_rate_limited_test() {
  let run = attempt("retry-js", [Error(slackline.RateLimited(0)), Ok(7)])
  let run = fn() { promise.resolve(run()) }
  use result <- promise.map(fetch.retrying(attempts: 3, run:))
  assert result == Ok(7)
  assert tries("retry-js") == 2
}
