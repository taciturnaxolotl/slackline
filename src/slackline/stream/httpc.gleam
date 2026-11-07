//// Runs a streamed reply on Erlang. Each reply gets its own process. See
//// `slackline/stream` for how a reply behaves.
////
//// ```gleam
//// let assert Ok(r) =
////   stream.new(client, channel: "C123")
////   |> stream.in_thread(thread_ts)
////   |> stream.to(user: "U123", team: "T123")
////   |> httpc.open
//// httpc.text(r, "Looking at it")
//// let assert Ok(finished) = httpc.finish(r, closing: "")
//// ```

import gleam/erlang/process.{type Subject}
import gleam/option.{type Option, None, Some}
import gleam/otp/actor
import gleam/result
import slackline/httpc as send
import slackline/stream.{
  type Builder, type Finished, type Outcome, type Rules, type Shows, type Step,
  type Task,
}

pub opaque type Reply {
  Reply(subject: Subject(Command))
}

type Command {
  Show(fn(Shows) -> Shows)
  Flush
  Finish(closing: String, reply: Subject(Finished))
}

type State {
  State(
    every_ms: Int,
    perform: fn(Step) -> Outcome,
    self: Subject(Command),
    shows: Shows,
    rules: Rules,
    scheduled: Bool,
  )
}

@external(erlang, "erlang", "monotonic_time")
@external(javascript, "../../slackline_ffi.mjs", "erlang_only")
fn monotonic_time(unit: TimeUnit) -> Int

type TimeUnit {
  Millisecond
}

/// Starts the reply. Nothing is posted until the reply has something to
/// show.
@external(javascript, "../../slackline_ffi.mjs", "erlang_only")
pub fn open(builder: Builder) -> Result(Reply, actor.StartError) {
  let client = stream.client(builder)
  open_with(builder, fn(step) {
    stream.request(builder, step) |> send.send(client)
  })
}

/// Works like `open`, but makes calls with `perform`. Tests use this.
@external(javascript, "../../slackline_ffi.mjs", "erlang_only")
@internal
pub fn open_with(
  builder: Builder,
  perform: fn(Step) -> Outcome,
) -> Result(Reply, actor.StartError) {
  actor.new_with_initialiser(1000, fn(self) {
    State(
      every_ms: stream.every_ms(builder),
      perform:,
      self:,
      shows: stream.nothing,
      rules: stream.rules_for(builder),
      scheduled: False,
    )
    |> actor.initialised
    |> actor.returning(self)
    |> Ok
  })
  |> actor.on_message(handle)
  |> actor.start
  |> result.map(fn(started) { Reply(started.data) })
}

/// Sets the reply's text. Pass the whole text so far, not just the new
/// part.
@external(javascript, "../../slackline_ffi.mjs", "erlang_only")
pub fn text(reply: Reply, text: String) -> Nil {
  process.send(reply.subject, Show(fn(shows) { stream.Shows(..shows, text:) }))
}

/// Adds a task to the reply's plan, or updates the task with the same id.
@external(javascript, "../../slackline_ffi.mjs", "erlang_only")
pub fn task(reply: Reply, task: Task) -> Nil {
  process.send(reply.subject, Show(stream.with_task(_, task)))
}

/// Sets the plan's title. It shows up once the reply has a task.
@external(javascript, "../../slackline_ffi.mjs", "erlang_only")
pub fn title(reply: Reply, title: String) -> Nil {
  process.send(reply.subject, Show(fn(shows) { stream.Shows(..shows, title:) }))
}

/// Finishes the reply and waits until every call is done. `closing` is a
/// last line to add, or "" for none. Returns an error if the reply was
/// already finished.
@external(javascript, "../../slackline_ffi.mjs", "erlang_only")
pub fn finish(reply: Reply, closing closing: String) -> Result(Finished, Nil) {
  case process.subject_owner(reply.subject) {
    Error(Nil) -> Error(Nil)
    Ok(pid) -> {
      let monitor = process.monitor(pid)
      let done = process.new_subject()
      process.send(reply.subject, Finish(closing, done))
      let result =
        process.new_selector()
        |> process.select_map(done, Ok)
        |> process.select_specific_monitor(monitor, fn(_) { Error(Nil) })
        |> process.selector_receive_forever
      let _ = process.demonitor_process(monitor)
      result
    }
  }
}

@external(javascript, "../../slackline_ffi.mjs", "erlang_only")
fn handle(state: State, command: Command) -> actor.Next(State, Command) {
  case command {
    Show(change) ->
      State(..state, shows: change(state.shows))
      |> schedule(state.every_ms)
      |> actor.continue
    Flush ->
      State(..state, scheduled: False)
      |> run(Some(stream.calls_per_flush))
      |> actor.continue
    Finish(closing:, reply: done) -> {
      let state =
        run(State(..state, rules: stream.closing(state.rules, closing)), None)
      process.send(done, stream.finished(state.rules))
      actor.stop()
    }
  }
}

@external(javascript, "../../slackline_ffi.mjs", "erlang_only")
fn schedule(state: State, delay: Int) -> State {
  case state.scheduled {
    True -> state
    False -> {
      let _ = process.send_after(state.self, delay, Flush)
      State(..state, scheduled: True)
    }
  }
}

/// Makes the calls the reply needs. With a budget, it makes at most that
/// many and leaves the rest for the next flush. With no budget, it keeps
/// going until the reply is done.
@external(javascript, "../../slackline_ffi.mjs", "erlang_only")
fn run(state: State, budget: Option(Int)) -> State {
  let next =
    stream.next_step(state.rules, state.shows, monotonic_time(Millisecond))
  case next, budget {
    stream.Wait, _ | stream.Over, _ -> state
    stream.Do(..), Some(0) -> schedule(state, state.every_ms)
    stream.Do(step:, answer:), _ ->
      case answer(state.perform(step)), budget {
        stream.Continue(rules), _ ->
          run(State(..state, rules:), option.map(budget, fn(n) { n - 1 }))
        stream.RetryIn(milliseconds:, rules:), Some(_) ->
          schedule(State(..state, rules:), milliseconds)
        stream.RetryIn(milliseconds:, rules:), None -> {
          let _ = process.sleep(milliseconds)
          run(State(..state, rules:), None)
        }
      }
  }
}
