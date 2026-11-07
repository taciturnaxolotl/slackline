//// Tests for the streaming rules, run against a fake Slack.

import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import slackline
import slackline/api/chat
import slackline/stream.{
  type Rules, type Shows, type Step, Append, Continue, Do, Over, Post, PostPlan,
  RetryIn, Start, Stop, UpdatePlan, Wait,
}
import slackline/value

type Answered =
  Result(String, slackline.Error)

/// Makes every call `next_step` asks for and answers each one with `slack`.
/// Stops when there is nothing left to do or Slack rate limits a call, and
/// returns the final rules and the calls made.
fn play(
  rules: Rules,
  shows: Shows,
  now: Int,
  slack: fn(Step) -> Answered,
) -> #(Rules, List(Step)) {
  play_loop(rules, shows, now, slack, [], 50)
}

fn play_loop(rules, shows, now, slack, made, left) {
  case left, stream.next_step(rules, shows, now) {
    0, _ -> panic as "too many calls"
    _, Wait | _, Over -> #(rules, list.reverse(made))
    _, Do(step:, answer:) ->
      case answer(slack(step)) {
        Continue(rules) ->
          play_loop(rules, shows, now, slack, [step, ..made], left - 1)
        RetryIn(..) -> #(rules, list.reverse([step, ..made]))
      }
  }
}

fn api(code: String) -> Answered {
  Error(slackline.ApiError(code, value.Null))
}

fn slack(step: Step) -> Answered {
  case step {
    Start(_) -> Ok("m1")
    Post(_) | PostPlan(..) -> Ok("p1")
    _ -> Ok("")
  }
}

/// Works like `slack`, but the calls `failing` picks fail with `code`.
fn failing(failing: fn(Step) -> Bool, code: String) -> fn(Step) -> Answered {
  fn(step) {
    case failing(step) {
      True -> api(code)
      False -> slack(step)
    }
  }
}

fn texts(chunks: List(chat.StreamChunk)) -> List(String) {
  list.filter_map(chunks, fn(chunk) {
    case chunk {
      chat.MarkdownTextChunk(text) -> Ok(text)
      _ -> Error(Nil)
    }
  })
}

fn task_ids(chunks: List(chat.StreamChunk)) -> List(String) {
  list.filter_map(chunks, fn(chunk) {
    case chunk {
      chat.TaskUpdateChunk(id:, ..) -> Ok(id)
      _ -> Error(Nil)
    }
  })
}

fn small() {
  stream.new_rules(stream.Limits(text: 20, tasks: 3, life_ms: 1000))
}

fn big() {
  stream.new_rules(stream.slack_limits)
}

fn says(text: String) -> Shows {
  stream.Shows(..stream.nothing, text:)
}

fn running(id: String) {
  stream.Task(id, "step " <> id, stream.Running, "", "")
}

fn finished(id: String) {
  stream.Task(id, "step " <> id, stream.Done, "", "")
}

fn is_start(step: Step) -> Bool {
  case step {
    Start(_) -> True
    _ -> False
  }
}

fn is_append(step: Step) -> Bool {
  case step {
    Append(..) -> True
    _ -> False
  }
}

pub fn text_is_sent_as_it_grows_test() {
  let assert #(rules, [Start(first)]) = play(big(), says("Looking"), 0, slack)
  let assert ["Looking"] = texts(first)
  let assert #(rules, [Append("m1", next)]) =
    play(rules, says("Looking at it."), 10, slack)
  let assert [" at it."] = texts(next)
  // The text hasn't changed, so nothing is sent.
  let assert #(rules, []) = play(rules, says("Looking at it."), 20, slack)
  let assert #(rules, [Stop("m1", [], False)]) =
    play(stream.closing(rules, ""), says("Looking at it."), 30, slack)
  let assert stream.Finished(["m1"], True, None) = stream.finished(rules)
  let assert Over = stream.next_step(rules, says("Looking at it."), 40)
}

pub fn a_full_message_carries_on_in_a_new_one_test() {
  let text = says(string.repeat("a", 30))
  let assert #(rules, [Start(first), Stop("m1", [], True), Start(second)]) =
    play(small(), text, 0, slack)
  let assert [twenty] = texts(first)
  let assert 20 = string.length(twenty)
  let assert [ten] = texts(second)
  let assert 10 = string.length(ten)
  let assert #(_, [Stop(_, [], False)]) =
    play(stream.closing(rules, ""), text, 1, slack)
}

pub fn a_stream_ends_before_slack_ends_it_test() {
  let assert #(rules, [Start(_)]) = play(small(), says("one"), 0, slack)
  // The message is too old, so it closes with the new text...
  let assert #(rules, [Stop("m1", closing, True)]) =
    play(rules, says("one two"), 2000, slack)
  let assert [" two"] = texts(closing)
  // ...and the next message starts with the text after that.
  let assert #(_, [Start(next)]) =
    play(rules, says("one two three"), 2001, slack)
  let assert [" three"] = texts(next)
}

pub fn tasks_past_the_limit_go_in_the_next_message_test() {
  let shows =
    ["a", "b", "c", "d", "e"]
    |> list.fold(stream.nothing, fn(shows, id) {
      stream.with_task(shows, running(id))
    })
  let assert #(rules, [Start(first), Stop(_, [], True), Start(second)]) =
    play(small(), shows, 0, slack)
  let assert ["a", "b", "c"] = task_ids(first)
  let assert ["d", "e"] = task_ids(second)
  // Updating a task from the first message sends it to the open one.
  let assert #(_, [Append(_, update)]) =
    play(rules, stream.with_task(shows, finished("a")), 1, slack)
  let assert ["a"] = task_ids(update)
}

pub fn the_title_waits_for_a_task_test() {
  let shows = stream.Shows(..says("hi"), title: "Fixing")
  let assert #(rules, [Start(first)]) = play(small(), shows, 0, slack)
  let assert False = list.contains(first, chat.PlanUpdateChunk("Fixing"))
  let assert #(_, [Append(_, next)]) =
    play(rules, stream.with_task(shows, running("a")), 1, slack)
  let assert True = list.contains(next, chat.PlanUpdateChunk("Fixing"))
}

pub fn the_closing_line_ends_the_stream_test() {
  let assert #(rules, [Start(_)]) = play(big(), says("Done."), 0, slack)
  let assert #(rules, [Stop("m1", ending, False)]) =
    play(stream.closing(rules, "Changed 1 file"), says("Done."), 1, slack)
  let assert ["\n\nChanged 1 file"] = texts(ending)
  let assert stream.Finished(["m1"], True, None) = stream.finished(rules)
}

pub fn rewritten_text_is_posted_after_test() {
  let assert #(rules, [Start(_)]) =
    play(big(), says("First part.\n\nA draft"), 0, slack)
  let rewritten = says("First part.\n\nA better second part.")
  let assert #(rules, [Stop("m1", [], False), Post(posted)]) =
    play(stream.closing(rules, "Bye"), rewritten, 1, slack)
  // The post starts at the last paragraph both versions share, so nothing
  // is repeated.
  let assert "A better second part.\n\nBye" = posted
  let assert stream.Finished(["m1", "p1"], True, None) = stream.finished(rules)
}

pub fn without_a_recipient_a_plan_card_and_messages_test() {
  let refuse = fn(step) {
    case step {
      Start(_) -> api("missing_recipient_user_id")
      Post(_) -> Ok("p2")
      PostPlan(..) -> Ok("card")
      _ -> Ok("")
    }
  }
  let shows = stream.with_task(says("Working on it"), running("a"))
  let assert #(rules, [Start(_), PostPlan(_, [_])]) =
    play(big(), shows, 0, refuse)
  let done = stream.with_task(shows, finished("a"))
  let assert #(rules, [UpdatePlan("card", _, _), Post(answer)]) =
    play(stream.closing(rules, "Done"), done, 1, refuse)
  let assert "Working on it\n\nDone" = answer
  let assert stream.Finished(
    ["card", "p2"],
    False,
    Some("missing_recipient_user_id"),
  ) = stream.finished(rules)
}

pub fn a_passing_start_error_is_tried_again_test() {
  let flaky = failing(is_start, "internal_error")
  // It tries three times, then gives up and reports the error.
  let assert #(rules, [Start(_), Start(_), Start(_)]) =
    play(big(), says("hi"), 0, flaky)
  let assert stream.Finished([], False, Some("internal_error")) =
    stream.finished(rules)
}

pub fn a_recovered_error_is_not_reported_test() {
  let assert #(rules, [Start(_)]) = play(big(), says("one"), 0, slack)
  // One append fails, and the next one goes through.
  let assert Do(step: Append(..), answer:) =
    stream.next_step(rules, says("one two"), 1)
  let assert Continue(rules) =
    answer(Error(slackline.ApiError("service_unavailable", value.Null)))
  let assert #(rules, [Append(..)]) = play(rules, says("one two"), 2, slack)
  let assert #(rules, [Stop(..)]) =
    play(stream.closing(rules, ""), says("one two"), 3, slack)
  let assert stream.Finished(["m1"], True, None) = stream.finished(rules)
}

pub fn falling_back_closes_the_open_stream_test() {
  let assert #(rules, [Start(_)]) = play(big(), says("one"), 0, slack)
  let broken = failing(is_append, "internal_error")
  // After three failures, it closes the stream before anything else.
  let assert #(
    rules,
    [Append(..), Append(..), Append(..), Stop("m1", [], False)],
  ) = play(rules, says("one two"), 1, broken)
  let assert stream.Finished(_, False, Some("internal_error")) =
    stream.finished(rules)
  // The text the stream never showed is posted once.
  let assert #(_, [Post("two")]) =
    play(stream.closing(rules, ""), says("one two"), 2, broken)
}

pub fn a_message_slack_already_finished_is_left_behind_test() {
  let assert #(rules, [Start(_)]) = play(big(), says("one"), 0, slack)
  let expired = failing(is_append, "message_not_in_streaming_state")
  // The text the old message missed goes in the new one.
  let assert #(_, [Append("m1", _), Start(next)]) =
    play(rules, says("one two"), 1, expired)
  let assert [" two"] = texts(next)
}

pub fn too_long_rolls_over_test() {
  let assert #(rules, [Start(_)]) = play(big(), says("one"), 0, slack)
  let too_long = failing(is_append, "msg_too_long")
  let assert #(_, [Append("m1", _), Stop("m1", [], True), Start(next)]) =
    play(rules, says("one two"), 1, too_long)
  let assert [" two"] = texts(next)
}

pub fn too_long_at_the_end_carries_on_in_a_new_message_test() {
  let assert #(rules, [Start(_)]) = play(big(), says("one"), 0, slack)
  // Slack refuses the last chunks for the first message...
  let stuck =
    failing(
      fn(step) {
        case step {
          Stop(chunks: [_, _], ..) -> True
          _ -> False
        }
      },
      "msg_too_long",
    )
  // ...so it closes as it was, and the rest goes in a new message.
  let assert #(
    rules,
    [
      Stop(_, [_, _], False),
      Stop(_, [], False),
      Start(rest),
      Stop(_, ending, False),
    ],
  ) = play(stream.closing(rules, "Bye"), says("one two"), 1, stuck)
  let assert [" two"] = texts(rest)
  let assert ["\n\nBye"] = texts(ending)
  let assert stream.Finished(["m1", "m1"], True, None) = stream.finished(rules)
}

pub fn a_rate_limit_keeps_the_rules_test() {
  let assert #(rules, [Start(_)]) = play(big(), says("one"), 0, slack)
  let assert Do(step: Append(..), answer:) =
    stream.next_step(rules, says("one two"), 1)
  let assert RetryIn(30_000, same) = answer(Error(slackline.RateLimited(30)))
  let assert True = same == rules
}

pub fn a_card_that_will_not_post_is_given_up_on_test() {
  let refuse = fn(step) {
    case step {
      Start(_) -> api("not_allowed")
      PostPlan(..) -> api("internal_error")
      Post(_) -> Ok("p1")
      _ -> Ok("")
    }
  }
  let shows = stream.with_task(says("hi"), running("a"))
  let assert #(rules, [Start(_), PostPlan(..), PostPlan(..), PostPlan(..)]) =
    play(big(), shows, 0, refuse)
  let assert #(_, [Post("hi")]) =
    play(stream.closing(rules, ""), shows, 1, refuse)
}

pub fn long_leftovers_are_split_test() {
  let text =
    int.range(from: 0, to: 6, with: [], run: fn(acc, n) {
      [string.repeat(int.to_string(n), 8), ..acc]
    })
    |> list.reverse
    |> string.join("\n\n")
  let refuse = failing(is_start, "not_allowed")
  let assert #(_, [Start(_), ..posts]) =
    play(stream.closing(small(), ""), says(text), 0, refuse)
  let posted =
    list.map(posts, fn(step) {
      let assert Post(text) = step
      text
    })
  let assert True = list.all(posted, fn(text) { string.length(text) <= 20 })
  let squash = fn(text) { string.replace(text, "\n", "") }
  let assert True = squash(string.concat(posted)) == squash(text)
}

pub fn closing_with_nothing_said_is_over_test() {
  let assert Over =
    stream.next_step(stream.closing(big(), ""), stream.nothing, 0)
}
