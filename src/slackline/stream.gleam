//// Stream a reply into Slack while an agent writes it. You say what the
//// reply should show right now, and this module works out which calls to
//// make.
////
//// ```gleam
//// import slackline/stream
//// import slackline/stream/httpc as reply
////
//// let assert Ok(r) =
////   stream.new(client, channel: "C123")
////   |> stream.in_thread("1700000000.000100")
////   |> stream.to(user: "U123", team: "T123")
////   |> reply.open
////
//// reply.text(r, "Looking at the failing test")
//// reply.task(r, stream.Task("t1", "Run the tests", stream.Running, "", ""))
//// reply.text(r, "Looking at the failing test. It races the clock.")
//// reply.task(r, stream.Task("t1", "Run the tests", stream.Done, "", "24 passed"))
//// let assert Ok(finished) = reply.finish(r, closing: "Changed 1 file")
//// ```
////
//// Pass `text` the whole reply so far, not just the new part. Slack keeps a
//// streamed message open for ten minutes and lets it hold 12,000 characters
//// and 50 tasks. When a message fills up or runs out of time, the reply
//// continues in a new message and the session stays marked as working. If
//// you rewrite text after it has streamed, the new version is posted when
//// the reply finishes. If Slack won't stream, the reply falls back to a plan
//// card and plain messages.
////
//// This module holds the code both targets share. That is the builder, the
//// rules, and the API calls the rules ask for. The rules are pure. Use
//// `stream/httpc` to run a reply on Erlang and `stream/fetch` to run one on
//// JavaScript.

import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import slackline.{type Client}
import slackline/api/chat
import slackline/api/chat/append_stream
import slackline/api/chat/post_message
import slackline/api/chat/start_stream
import slackline/api/chat/stop_stream
import slackline/api/chat/update
import slackline/block

// What a reply shows ---------------------------------------------------------

pub type Status {
  Pending
  Running
  Done
  Failed
}

/// A step of the work, shown in the reply's plan. A task with the same `id`
/// replaces an earlier one. Set `details` or `output` to "" to leave it out.
pub type Task {
  Task(
    id: String,
    title: String,
    status: Status,
    details: String,
    output: String,
  )
}

/// The full state of a reply. It holds the text so far, the tasks, and the
/// title of the plan.
pub type Shows {
  Shows(text: String, tasks: List(Task), title: String)
}

pub const nothing = Shows(text: "", tasks: [], title: "")

/// Adds `task` to `shows`. If a task with the same id is already there,
/// `task` replaces it.
pub fn with_task(shows: Shows, task: Task) -> Shows {
  case list.any(shows.tasks, fn(t) { t.id == task.id }) {
    False -> Shows(..shows, tasks: list.append(shows.tasks, [task]))
    True ->
      Shows(
        ..shows,
        tasks: list.map(shows.tasks, fn(t) {
          case t.id == task.id {
            True -> task
            False -> t
          }
        }),
      )
  }
}

/// How much a streamed message can hold and how long it stays open, in
/// milliseconds. `slack_limits` stays a little under Slack's own limits of
/// 12,000 characters, 50 tasks and ten minutes.
pub type Limits {
  Limits(text: Int, tasks: Int, life_ms: Int)
}

pub const slack_limits = Limits(text: 11_500, tasks: 50, life_ms: 540_000)

/// How many calls a driver makes in one go before it pauses and lets
/// updates collect again.
pub const calls_per_flush = 4

/// The result of a finished reply. `messages` lists the ts of every message
/// it posted, oldest first. `streamed` is False if the reply fell back to
/// plain messages, and `problem` says why.
pub type Finished {
  Finished(messages: List(String), streamed: Bool, problem: Option(String))
}

// The rules ------------------------------------------------------------------

/// Tracks what Slack has been shown of a reply. The rules are pure. Call
/// `next_step` to get the next call, make it, then pass the outcome to its
/// `answer`.
pub opaque type Rules {
  Rules(
    limits: Limits,
    /// The text all messages have shown so far, joined in order.
    streamed: String,
    /// The last version of each task that a closed message showed.
    earlier: Dict(String, Task),
    message: Message,
    mode: Mode,
    stage: Stage,
    failures: Int,
    /// The ts of every message the reply posted, in order.
    sent: List(String),
    problem: Option(String),
  )
}

type Message {
  NoMessage
  Open(Opened)
}

/// A streamed message that is still open. `room` is the number of
/// characters it holds. `full` is True when it can't take any more, either
/// because it reached the limits or because Slack refused more. A full
/// message closes next.
type Opened {
  Opened(
    ts: String,
    started_ms: Int,
    room: Int,
    tasks: Dict(String, Task),
    title: String,
    full: Bool,
  )
}

type Mode {
  Streaming
  /// `card` is the ts of the plan card once it is posted. `shown` is what
  /// the card last showed.
  Fallback(card: Option(String), shown: Option(#(String, List(Task))))
}

type Stage {
  Live
  Closing(closing: String)
  /// The messages still to post. An empty list means the reply is done.
  Posting(texts: List(String))
}

/// A call to Slack that the rules want made.
pub type Step {
  Start(chunks: List(chat.StreamChunk))
  Append(ts: String, chunks: List(chat.StreamChunk))
  /// `carry_on` is True when the reply will continue in a new message.
  /// Slack then keeps showing the session as working.
  Stop(ts: String, chunks: List(chat.StreamChunk), carry_on: Bool)
  Post(text: String)
  PostPlan(title: String, tasks: List(Task))
  UpdatePlan(ts: String, title: String, tasks: List(Task))
}

/// The result of a call. On success it holds the ts of the message the call
/// posted, or "" if it posted none.
pub type Outcome =
  Result(String, slackline.Error)

/// What to do after a call.
pub type Answer {
  Continue(Rules)
  /// Slack rate limited the call. Try again after this many milliseconds.
  RetryIn(milliseconds: Int, rules: Rules)
}

pub type Next {
  /// There is nothing to send yet.
  Wait
  /// Make `step`, then pass its outcome to `answer`.
  Do(step: Step, answer: fn(Outcome) -> Answer)
  /// The reply is done.
  Over
}

pub fn new_rules(limits: Limits) -> Rules {
  Rules(
    limits:,
    streamed: "",
    earlier: dict.new(),
    message: NoMessage,
    mode: Streaming,
    stage: Live,
    failures: 0,
    sent: [],
    problem: None,
  )
}

/// Marks the reply as finishing. `closing` is a last line to add at the
/// end, or "" for none.
pub fn closing(rules: Rules, closing: String) -> Rules {
  case rules.stage {
    Live -> Rules(..rules, stage: Closing(closing))
    _ -> rules
  }
}

pub fn finished(rules: Rules) -> Finished {
  Finished(
    messages: rules.sent,
    streamed: rules.mode == Streaming,
    problem: rules.problem,
  )
}

/// Returns the next call to make, given what the reply shows and the
/// current time in milliseconds.
pub fn next_step(rules: Rules, shows: Shows, now_ms: Int) -> Next {
  case rules.stage, rules.mode, rules.message {
    Posting([]), _, _ -> Over
    Posting([text, ..rest]), _, _ ->
      call(rules, Post(text), fn(rules, ts) {
        Rules(..posted(rules, ts), stage: Posting(rest))
      })
    // The reply fell back with a stream still open. Close it and move on,
    // whatever Slack answers.
    _, Fallback(..), Open(Opened(ts:, ..)) ->
      Do(Stop(ts, [], False), fn(_) {
        Continue(Rules(..rules, message: NoMessage))
      })
    _, Fallback(card:, shown:), NoMessage ->
      next_card(rules, shows, card, shown)
    _, Streaming, NoMessage -> next_start(rules, shows, now_ms)
    _, Streaming, Open(open) -> next_in_message(rules, shows, open, now_ms)
  }
}

fn next_start(rules: Rules, shows: Shows, now_ms: Int) -> Next {
  let d = diff(rules, shows, 0, dict.new(), "")
  case d.chunks, rules.stage {
    [], Closing(closing) -> posting_rest(rules, shows, closing)
    [], _ -> Wait
    chunks, _ ->
      call(rules, Start(chunks), fn(rules, ts) {
        Rules(
          ..posted(rules, ts),
          streamed: d.streamed,
          message: Open(Opened(ts, now_ms, d.room, d.tasks, d.title, d.full)),
        )
      })
  }
}

fn next_in_message(
  rules: Rules,
  shows: Shows,
  open: Opened,
  now_ms: Int,
) -> Next {
  let Opened(ts:, started_ms:, room:, tasks:, title:, full:) = open
  let carry_on = rules.stage == Live
  let d = diff(rules, shows, room, tasks, title)
  let expired = now_ms - started_ms > rules.limits.life_ms
  case full, d.full || expired, rules.stage, d.chunks {
    // The message is full. Close it without sending anything new.
    True, _, _, _ ->
      call(rules, Stop(ts, [], carry_on), fn(rules, _) {
        leave_behind(rules, tasks)
      })
    False, True, _, chunks ->
      call(rules, Stop(ts, chunks, carry_on), fn(rules, _) {
        leave_behind(Rules(..rules, streamed: d.streamed), d.tasks)
      })
    False, False, Closing(closing), chunks -> {
      let ending = paragraph(d.streamed, closing)
      let fits =
        leftover(d.streamed, shows) == ""
        && d.room + string.length(ending) <= rules.limits.text
      let #(chunks, rest) = case fits, closing {
        True, "" -> #(chunks, [])
        True, _ -> #(list.append(chunks, [chat.MarkdownTextChunk(ending)]), [])
        False, _ -> #(
          chunks,
          split(join([leftover(d.streamed, shows), closing]), rules.limits.text),
        )
      }
      call(rules, Stop(ts, chunks, False), fn(rules, _) {
        Rules(
          ..leave_behind(Rules(..rules, streamed: d.streamed), d.tasks),
          stage: Posting(rest),
        )
      })
    }
    False, False, _, [] -> Wait
    False, False, _, chunks ->
      call(rules, Append(ts, chunks), fn(rules, _) {
        Rules(
          ..rules,
          streamed: d.streamed,
          message: Open(
            Opened(..open, room: d.room, tasks: d.tasks, title: d.title),
          ),
        )
      })
  }
}

/// Drops the open message, which ended holding `tasks`. The next update
/// starts a new message.
fn leave_behind(rules: Rules, tasks: Dict(String, Task)) -> Rules {
  Rules(..rules, earlier: dict.merge(rules.earlier, tasks), message: NoMessage)
}

/// Posts any text no message has shown yet, then the closing line.
fn posting_rest(rules: Rules, shows: Shows, closing: String) -> Next {
  let texts =
    split(join([leftover(rules.streamed, shows), closing]), rules.limits.text)
  case texts {
    [] -> Over
    texts -> next_step(Rules(..rules, stage: Posting(texts)), shows, 0)
  }
}

fn next_card(
  rules: Rules,
  shows: Shows,
  card: Option(String),
  shown: Option(#(String, List(Task))),
) -> Next {
  let title = case shows.title {
    "" -> "Working"
    title -> title
  }
  let plan = #(title, shows.tasks)
  let wants_card = shows.tasks != [] && Some(plan) != shown
  case wants_card, card, rules.stage {
    True, None, _ ->
      call(rules, PostPlan(title, shows.tasks), fn(rules, ts) {
        Rules(..posted(rules, ts), mode: Fallback(Some(ts), Some(plan)))
      })
    True, Some(ts), _ ->
      call(rules, UpdatePlan(ts, title, shows.tasks), fn(rules, _) {
        Rules(..rules, mode: Fallback(card, Some(plan)))
      })
    False, _, Closing(closing) -> posting_rest(rules, shows, closing)
    False, _, _ -> Wait
  }
}

fn posted(rules: Rules, ts: String) -> Rules {
  case ts {
    "" -> rules
    ts -> Rules(..rules, sent: list.append(rules.sent, [ts]))
  }
}

/// Pairs `step` with its answer. `succeeded` updates the rules when the call
/// works. Rate limits and errors are handled the same way for every step.
fn call(
  rules: Rules,
  step: Step,
  succeeded: fn(Rules, String) -> Rules,
) -> Next {
  Do(step, fn(outcome) {
    case outcome {
      Ok(ts) -> Continue(succeeded(Rules(..rules, failures: 0), ts))
      Error(slackline.RateLimited(retry_after:)) ->
        RetryIn(retry_after * 1000, rules)
      Error(error) -> Continue(failed(rules, step, error))
    }
  })
}

/// Slack errors that may go away if we try again. Any other error code
/// means the call won't work, so the reply gives up on it. Errors that don't
/// come from the API, such as network failures, are always retried. Every
/// call gets at most three tries.
const transient_codes = [
  "internal_error", "fatal_error", "service_unavailable", "request_timeout",
  "messaging_processing_failed",
]

fn failed(rules: Rules, step: Step, error: slackline.Error) -> Rules {
  let code = case error {
    slackline.ApiError(error:, ..) -> error
    other -> slackline.describe_error(other)
  }
  let transient = case error {
    slackline.ApiError(..) -> list.contains(transient_codes, code)
    _ -> True
  }
  let failures = rules.failures + 1
  let given_up = failures >= 3 || !transient
  let reset = Rules(..rules, failures: 0)
  case step, rules.message, code {
    // Slack already closed this message. Keep what it showed and move on.
    Append(..), Open(open), "message_not_in_streaming_state"
    | Append(..), Open(open), "message_not_found"
    | Stop(..), Open(open), "message_not_in_streaming_state"
    | Stop(..), Open(open), "message_not_found"
    -> leave_behind(reset, open.tasks)
    // The message can't take what we sent. Close it as it is.
    Append(..), Open(open), "msg_too_long"
    | Stop(..), Open(open), "msg_too_long"
    -> Rules(..reset, message: Open(Opened(..open, full: True)))
    Start(_), _, _ | Append(..), _, _ | Stop(..), _, _ if given_up ->
      Rules(..reset, mode: Fallback(None, None), problem: Some(code))
    // Skip a message that won't post instead of trying it forever.
    Post(_), _, _ if given_up ->
      case rules.stage {
        Posting([_, ..rest]) -> Rules(..reset, stage: Posting(rest))
        _ -> Rules(..reset, stage: Posting([]))
      }
    PostPlan(title:, tasks:), _, _
    | UpdatePlan(title:, tasks:, ..), _, _
      if given_up
    ->
      case rules.mode {
        Fallback(card:, ..) ->
          Rules(..reset, mode: Fallback(card, Some(#(title, tasks))))
        Streaming -> reset
      }
    _, _, _ -> Rules(..rules, failures:)
  }
}

type Diff {
  Diff(
    chunks: List(chat.StreamChunk),
    streamed: String,
    room: Int,
    tasks: Dict(String, Task),
    title: String,
    full: Bool,
  )
}

/// Works out what to send to the open message, which already holds `room`
/// characters, `tasks` and `title`. It only sends what fits.
fn diff(
  rules: Rules,
  shows: Shows,
  room: Int,
  tasks: Dict(String, Task),
  title: String,
) -> Diff {
  let #(text_chunks, streamed, room, text_full) = case
    string.starts_with(shows.text, rules.streamed)
  {
    // The text changed after it streamed. `finish` posts the new version.
    False -> #([], rules.streamed, room, False)
    True -> {
      let delta = string.drop_start(shows.text, string.length(rules.streamed))
      let taken = string.slice(delta, 0, int.max(rules.limits.text - room, 0))
      case taken {
        "" -> #([], rules.streamed, room, delta != "")
        taken -> #(
          [chat.MarkdownTextChunk(taken)],
          rules.streamed <> taken,
          room + string.length(taken),
          taken != delta,
        )
      }
    }
  }
  let #(task_chunks, tasks, tasks_full) =
    shows.tasks
    |> list.filter(fn(task) { dict.get(rules.earlier, task.id) != Ok(task) })
    |> list.fold(#([], tasks, False), fn(acc, task) {
      let #(chunks, tasks, full) = acc
      let fits =
        dict.has_key(tasks, task.id) || dict.size(tasks) < rules.limits.tasks
      case dict.get(tasks, task.id) == Ok(task), fits {
        True, _ -> acc
        False, True -> #(
          [task_chunk(task), ..chunks],
          dict.insert(tasks, task.id, task),
          full,
        )
        False, False -> #(chunks, tasks, True)
      }
    })
  // A title belongs to a plan, and a message has no plan until it has a
  // task.
  let has_plan = dict.size(tasks) > 0
  let #(title_chunks, title) = case shows.title {
    new if new != "" && new != title && has_plan -> #(
      [chat.PlanUpdateChunk(title: new)],
      new,
    )
    _ -> #([], title)
  }
  Diff(
    chunks: list.flatten([text_chunks, list.reverse(task_chunks), title_chunks]),
    streamed:,
    room:,
    tasks:,
    title:,
    full: text_full || tasks_full,
  )
}

/// Returns the text no message has shown yet. If the text was rewritten
/// after it streamed, this starts at the last paragraph break the two
/// versions share, or at the beginning if they share none.
fn leftover(streamed: String, shows: Shows) -> String {
  let from = case string.starts_with(shows.text, streamed) {
    True -> string.length(streamed)
    False ->
      common_prefix(shows.text, streamed)
      |> last_index("\n\n")
      |> result.unwrap(0)
  }
  string.drop_start(shows.text, from) |> string.trim
}

fn common_prefix(a: String, b: String) -> String {
  common_loop(string.to_graphemes(a), string.to_graphemes(b), [])
}

fn common_loop(a: List(String), b: List(String), acc: List(String)) -> String {
  case a, b {
    [x, ..a], [y, ..b] if x == y -> common_loop(a, b, [x, ..acc])
    _, _ -> list.reverse(acc) |> string.concat
  }
}

fn last_index(haystack: String, needle: String) -> Result(Int, Nil) {
  case string.split(haystack, needle) {
    [_] | [] -> Error(Nil)
    parts ->
      Ok(
        string.length(haystack)
        - string.length(list.last(parts) |> result.unwrap("")),
      )
  }
}

/// Puts `text` in a new paragraph, unless `before` is empty.
fn paragraph(before: String, text: String) -> String {
  case before {
    "" -> text
    _ -> "\n\n" <> text
  }
}

fn join(parts: List(String)) -> String {
  parts
  |> list.map(string.trim)
  |> list.filter(fn(part) { part != "" })
  |> string.join("\n\n")
}

/// Splits `text` into messages of at most `limit` characters. It breaks
/// between paragraphs when that doesn't leave a message under half the
/// limit.
fn split(text: String, limit: Int) -> List(String) {
  case string.trim(text) {
    "" -> []
    text ->
      case string.length(text) <= limit {
        True -> [text]
        False -> {
          let cut = case last_index(string.slice(text, 0, limit), "\n\n") {
            Ok(at) if at > limit / 2 -> at
            _ -> limit
          }
          [
            string.trim(string.slice(text, 0, cut)),
            ..split(string.drop_start(text, cut), limit)
          ]
        }
      }
  }
}

// Building a reply and its calls ---------------------------------------------

/// Says where a reply goes and how often it updates. Open it with
/// `stream/httpc` on Erlang or `stream/fetch` on JavaScript.
pub opaque type Builder {
  Builder(
    client: Client,
    channel: String,
    thread_ts: Option(String),
    recipient: Option(#(String, String)),
    every_ms: Int,
    limits: Limits,
  )
}

/// Starts a reply in `channel`. For a reply in a channel thread, also call
/// `in_thread` and `to`. For a reply at the top level of a code channel or a
/// DM, call only `to`.
pub fn new(client: Client, channel channel: String) -> Builder {
  Builder(
    client:,
    channel:,
    thread_ts: None,
    recipient: None,
    every_ms: 1000,
    limits: slack_limits,
  )
}

pub fn in_thread(builder: Builder, thread_ts: String) -> Builder {
  Builder(..builder, thread_ts: Some(thread_ts))
}

/// Sets the user and team the reply is for. Slack needs this to stream in a
/// channel. If either is "", the reply has no recipient.
pub fn to(builder: Builder, user user: String, team team: String) -> Builder {
  case user, team {
    "", _ | _, "" -> builder
    user, team -> Builder(..builder, recipient: Some(#(user, team)))
  }
}

/// Sends updates at most once every `milliseconds`. The default is 1000.
pub fn every(builder: Builder, milliseconds: Int) -> Builder {
  Builder(..builder, every_ms: int.max(milliseconds, 0))
}

pub fn limits(builder: Builder, limits: Limits) -> Builder {
  Builder(..builder, limits:)
}

@internal
pub fn client(builder: Builder) -> Client {
  builder.client
}

@internal
pub fn every_ms(builder: Builder) -> Int {
  builder.every_ms
}

@internal
pub fn rules_for(builder: Builder) -> Rules {
  new_rules(builder.limits)
}

/// Builds the Web API call for `step`. It returns the ts of the message the
/// call posted, or "" if it posted none.
@internal
pub fn request(builder: Builder, step: Step) -> slackline.Call(Nil, String) {
  let Builder(channel:, thread_ts:, ..) = builder
  let posted_ts = fn(posted: chat.PostMessageResponse) { posted.ts }
  case step {
    Start(chunks) -> {
      let call =
        chat.start_stream(channel:)
        |> start_stream.chunks(chunks)
        |> start_stream.task_display_mode(chat.Plan)
        |> maybe(thread_ts, start_stream.thread_ts)
      case builder.recipient {
        Some(#(user, team)) ->
          call
          |> start_stream.recipient_user_id(user)
          |> start_stream.recipient_team_id(team)
        None -> call
      }
      |> slackline.map(fn(started) { started.ts })
      |> slackline.erase
    }
    Append(ts:, chunks:) ->
      chat.append_stream(channel:, ts:)
      |> append_stream.chunks(chunks)
      |> slackline.map(fn(_) { "" })
      |> slackline.erase
    Stop(ts:, chunks:, carry_on:) -> {
      let call = chat.stop_stream(channel:, ts:)
      let call = case chunks {
        [] -> call
        chunks -> stop_stream.chunks(call, chunks)
      }
      case carry_on {
        True -> stop_stream.session_status(call, chat.SessionProcessing)
        False -> call
      }
      |> slackline.map(fn(_) { "" })
      |> slackline.erase
    }
    Post(text) ->
      chat.post_message(channel:, text: notification(text))
      |> post_message.blocks([block.markdown(text, [])])
      |> post_message.unfurl_links(False)
      |> post_message.unfurl_media(False)
      |> maybe(thread_ts, post_message.thread_ts)
      |> slackline.map(posted_ts)
      |> slackline.erase
    PostPlan(title:, tasks:) ->
      chat.post_message(channel:, text: notification(title))
      |> post_message.blocks(plan_blocks(title, tasks))
      |> maybe(thread_ts, post_message.thread_ts)
      |> slackline.map(posted_ts)
      |> slackline.erase
    UpdatePlan(ts:, title:, tasks:) ->
      chat.update(channel:, ts:)
      |> update.text(notification(title))
      |> update.blocks(plan_blocks(title, tasks))
      |> slackline.map(fn(_) { "" })
      |> slackline.erase
  }
}

fn maybe(call: a, value: Option(b), set: fn(a, b) -> a) -> a {
  case value {
    Some(value) -> set(call, value)
    None -> call
  }
}

/// Slack shows this text in notifications, so cut it to 200 characters.
fn notification(text: String) -> String {
  let text = string.trim(text)
  case string.length(text) > 200 {
    True -> string.slice(text, 0, 199) <> "…"
    False -> text
  }
}

fn task_chunk(task: Task) -> chat.StreamChunk {
  chat.TaskUpdateChunk(
    id: task.id,
    title: task.title,
    status: status(task.status),
    hide_title: None,
    icon: None,
    details: field(task.details),
    output: field(task.output),
    sources: None,
  )
}

fn status(status: Status) -> block.TaskStatus {
  case status {
    Pending -> block.TaskPending
    Running -> block.TaskInProgress
    Done -> block.TaskComplete
    Failed -> block.TaskError
  }
}

/// Slack drops a task field longer than 12,000 characters, so cut it to
/// fit.
fn field(text: String) -> Option(String) {
  case text {
    "" -> None
    text -> Some(string.slice(text, 0, 12_000))
  }
}

fn plan_blocks(title: String, tasks: List(Task)) -> List(block.Block) {
  let tasks =
    list.map(tasks, fn(task) {
      block.PlanTask(
        task_id: task.id,
        title: task.title,
        status: status(task.status),
        details: rich(task.details),
        output: rich(task.output),
        sources: None,
        icon: None,
        hide_title: None,
      )
    })
  [block.plan(title, tasks, [])]
}

fn rich(text: String) -> Option(block.RichText) {
  case text {
    "" -> None
    text ->
      Some(block.RichText(
        elements: [block.rich_text_section([block.rich_text_run(text)])],
        block_id: None,
      ))
  }
}
