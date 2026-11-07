//// Runs a streamed reply on JavaScript, using promises. See
//// `slackline/stream` for how a reply behaves.
////
//// ```gleam
//// let r =
////   stream.new(client, channel: "C123")
////   |> stream.in_thread(thread_ts)
////   |> stream.to(user: "U123", team: "T123")
////   |> fetch.open
//// fetch.text(r, "Looking at it")
//// use finished <- promise.await(fetch.finish(r, closing: ""))
//// ```
////
//// Calls go out one at a time and in order. None of them block the caller.

import gleam/int
import gleam/javascript/promise.{type Promise}
import gleam/option.{type Option, None, Some}
import slackline/fetch as send
import slackline/stream.{
  type Builder, type Finished, type Outcome, type Rules, type Shows, type Step,
  type Task,
}

type Cell(a)

@external(erlang, "slackline_ffi", "javascript_only")
@external(javascript, "../../slackline_ffi.mjs", "new_cell")
fn new_cell(value: a) -> Cell(a)

@external(erlang, "slackline_ffi", "javascript_only")
@external(javascript, "../../slackline_ffi.mjs", "cell_get")
fn get(cell: Cell(a)) -> a

@external(erlang, "slackline_ffi", "javascript_only")
@external(javascript, "../../slackline_ffi.mjs", "cell_set")
fn set(cell: Cell(a), value: a) -> Nil

@external(erlang, "slackline_ffi", "javascript_only")
@external(javascript, "../../slackline_ffi.mjs", "set_timeout")
fn set_timeout(milliseconds: Int, callback: fn() -> Nil) -> Nil

@external(erlang, "slackline_ffi", "javascript_only")
@external(javascript, "../../slackline_ffi.mjs", "now_ms")
fn now_ms() -> Int

type State {
  State(
    every_ms: Int,
    perform: fn(Step) -> Promise(Outcome),
    shows: Shows,
    rules: Rules,
    scheduled: Bool,
    /// Slack asked us not to call again before this time, in milliseconds.
    not_before: Int,
    /// Resolves when every call so far is done. The next call waits on it.
    queue: Promise(Nil),
  )
}

pub opaque type Reply {
  Reply(cell: Cell(State))
}

/// Starts the reply. Nothing is posted until the reply has something to
/// show.
@external(erlang, "slackline_ffi", "javascript_only")
pub fn open(builder: Builder) -> Reply {
  let client = stream.client(builder)
  open_with(builder, fn(step) {
    stream.request(builder, step) |> send.send(client)
  })
}

/// Works like `open`, but makes calls with `perform`. Tests use this.
@external(erlang, "slackline_ffi", "javascript_only")
@internal
pub fn open_with(
  builder: Builder,
  perform: fn(Step) -> Promise(Outcome),
) -> Reply {
  Reply(
    new_cell(State(
      every_ms: stream.every_ms(builder),
      perform:,
      shows: stream.nothing,
      rules: stream.rules_for(builder),
      scheduled: False,
      not_before: 0,
      queue: promise.resolve(Nil),
    )),
  )
}

/// Sets the reply's text. Pass the whole text so far, not just the new
/// part.
@external(erlang, "slackline_ffi", "javascript_only")
pub fn text(reply: Reply, text: String) -> Nil {
  show(reply, fn(shows) { stream.Shows(..shows, text:) })
}

/// Adds a task to the reply's plan, or updates the task with the same id.
@external(erlang, "slackline_ffi", "javascript_only")
pub fn task(reply: Reply, task: Task) -> Nil {
  show(reply, stream.with_task(_, task))
}

/// Sets the plan's title. It shows up once the reply has a task.
@external(erlang, "slackline_ffi", "javascript_only")
pub fn title(reply: Reply, title: String) -> Nil {
  show(reply, fn(shows) { stream.Shows(..shows, title:) })
}

/// Finishes the reply. `closing` is a last line to add, or "" for none. The
/// promise resolves once every call is done.
@external(erlang, "slackline_ffi", "javascript_only")
pub fn finish(reply: Reply, closing closing: String) -> Promise(Finished) {
  enqueue(reply, fn() {
    change(reply, fn(state) {
      State(..state, rules: stream.closing(state.rules, closing))
    })
    run(reply, None)
  })
  |> promise.map(fn(_) { stream.finished(get(reply.cell).rules) })
}

@external(erlang, "slackline_ffi", "javascript_only")
fn change(reply: Reply, f: fn(State) -> State) -> Nil {
  set(reply.cell, f(get(reply.cell)))
}

@external(erlang, "slackline_ffi", "javascript_only")
fn show(reply: Reply, f: fn(Shows) -> Shows) -> Nil {
  change(reply, fn(state) { State(..state, shows: f(state.shows)) })
  schedule(reply, get(reply.cell).every_ms)
}

/// Flushes after `delay`, or later if Slack asked us to wait longer.
@external(erlang, "slackline_ffi", "javascript_only")
fn schedule(reply: Reply, delay: Int) -> Nil {
  let state = get(reply.cell)
  case state.scheduled {
    True -> Nil
    False -> {
      change(reply, fn(state) { State(..state, scheduled: True) })
      let delay = int.max(delay, state.not_before - now_ms())
      set_timeout(delay, fn() {
        change(reply, fn(state) { State(..state, scheduled: False) })
        let _ = enqueue(reply, fn() { flush(reply) })
        Nil
      })
    }
  }
}

@external(erlang, "slackline_ffi", "javascript_only")
fn flush(reply: Reply) -> Promise(Nil) {
  let wait = get(reply.cell).not_before - now_ms()
  case wait > 0 {
    True -> promise.resolve(schedule(reply, wait))
    False -> run(reply, Some(stream.calls_per_flush))
  }
}

/// Runs `work` after every call queued before it has finished.
@external(erlang, "slackline_ffi", "javascript_only")
fn enqueue(reply: Reply, work: fn() -> Promise(Nil)) -> Promise(Nil) {
  let next = promise.await(get(reply.cell).queue, fn(_) { work() })
  change(reply, fn(state) { State(..state, queue: next) })
  next
}

/// Makes the calls the reply needs. With a budget, it makes at most that
/// many and leaves the rest for the next flush. With no budget, it keeps
/// going until the reply is done.
@external(erlang, "slackline_ffi", "javascript_only")
fn run(reply: Reply, budget: Option(Int)) -> Promise(Nil) {
  let state = get(reply.cell)
  case stream.next_step(state.rules, state.shows, now_ms()), budget {
    stream.Wait, _ | stream.Over, _ -> promise.resolve(Nil)
    stream.Do(..), Some(0) -> promise.resolve(schedule(reply, state.every_ms))
    stream.Do(step:, answer:), _ -> {
      use outcome <- promise.await(state.perform(step))
      case answer(outcome), budget {
        stream.Continue(rules), _ -> {
          change(reply, fn(state) { State(..state, rules:) })
          run(reply, option.map(budget, fn(n) { n - 1 }))
        }
        stream.RetryIn(milliseconds:, rules:), Some(_) -> {
          change(reply, fn(state) {
            State(..state, rules:, not_before: now_ms() + milliseconds)
          })
          promise.resolve(schedule(reply, milliseconds))
        }
        stream.RetryIn(milliseconds:, rules:), None -> {
          change(reply, fn(state) { State(..state, rules:) })
          use _ <- promise.await(promise.wait(milliseconds))
          run(reply, None)
        }
      }
    }
  }
}
