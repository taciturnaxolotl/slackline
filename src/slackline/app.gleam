//// A router for Slack apps. Register handlers for slash commands, events,
//// block actions, shortcuts, view submissions and options, then pass it HTTP
//// requests or Socket Mode frames.
////
//// ```gleam
//// let app =
////   app.new(signing_secret)
////   |> app.command("/feedback", fn(command) {
////     use <- app.ack_then
////     views.open(view: feedback_modal())
////     |> open.trigger_id(command.trigger_id)
////     |> httpc.send(client)
////   })
////   |> app.view_submission("feedback", fn(submission) {
////     let text =
////       view.input_text(submission.view, block_id: "thoughts", action_id: "thoughts")
////     case text {
////       Some("") | None -> app.errors([#("thoughts", "say something!")])
////       Some(_) -> app.ack()
////     }
////   })
////   |> app.action("preview", fn(_action, _payload) {
////     app.reply(interaction.ephemeral("Previewing"))
////   })
////   |> app.on_event(fn(event, _delivery) {
////     case event {
////       event.AppMention(..) -> todo
////       _ -> Nil
////     }
////   })
////
//// // in your HTTP server, with the raw body:
//// let handled = app.handle(app, request)
//// // send handled.response, then call handled.after()
//// ```
////
//// Slack expects an acknowledgement within three seconds. Handlers return an
//// `Ack` at once. Put slow work, such as API calls, in a continuation with
//// `app.ack_then` or `app.then`. `handle` and `handle_socket` return it as
//// `after`, and the server runs it once the acknowledgement is sent. Event
//// handlers always run in `after`, so a server that skips `after` never runs
//// them.
////
//// Everything here is synchronous and does no IO of its own, so it works on
//// both targets and with any HTTP server or WebSocket client.

import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/uri
import slackline/block
import slackline/command.{type SlashCommand}
import slackline/event.{type Envelope, type Event}
import slackline/interaction.{
  type BlockAction, type BlockActionsPayload, type BlockSuggestionPayload,
  type GlobalShortcutPayload, type Interaction, type MessageShortcutPayload,
  type ViewClosedPayload, type ViewSubmissionPayload,
}
import slackline/socket_mode
import slackline/verify
import slackline/view.{type View}

/// How an app acknowledges a request: an optional body, and work to run
/// after the acknowledgement is sent.
pub opaque type Ack {
  Ack(body: Option(json.Json), after: fn() -> Nil)
}

/// Acknowledge with an empty body. Right for events and for most
/// interactions.
pub fn ack() -> Ack {
  Ack(body: None, after: fn() { Nil })
}

/// Acknowledge with an empty body, then run `after` once the
/// acknowledgement is sent. Made for `use`:
///
/// ```gleam
/// app.command("/deploy", fn(command) {
///   use <- app.ack_then
///   deploy(command.text)
/// })
/// ```
pub fn ack_then(after: fn() -> a) -> Ack {
  then(ack(), after)
}

/// Runs `after` once this acknowledgement is sent, after any work it
/// already had.
pub fn then(ack: Ack, after: fn() -> a) -> Ack {
  Ack(..ack, after: fn() {
    ack.after()
    let _ = after()
    Nil
  })
}

/// Acknowledge a slash command, shortcut or block action with a message, as
/// if posted to its `response_url`.
pub fn reply(message: interaction.ResponseMessage) -> Ack {
  ack_json(interaction.response_message_to_json(message))
}

/// Acknowledge a `view_submission` with a `response_action`: show errors,
/// update or push a view, or clear the stack.
pub fn view_response(response: interaction.ViewSubmissionResponse) -> Ack {
  ack_json(interaction.view_submission_response_to_json(response))
}

/// Acknowledge a `view_submission` by showing errors on its input blocks,
/// given as `#(block_id, message)` pairs.
pub fn errors(errors: List(#(String, String))) -> Ack {
  view_response(interaction.errors(errors))
}

/// Acknowledge a `view_submission` by replacing the submitted view.
pub fn update(view: View) -> Ack {
  view_response(interaction.update(view))
}

/// Acknowledge a `view_submission` by pushing a view onto the stack.
pub fn push(view: View) -> Ack {
  view_response(interaction.push(view))
}

/// Acknowledge a `view_submission` by closing every view in the stack.
pub fn clear() -> Ack {
  view_response(interaction.clear())
}

/// Acknowledge a `block_suggestion` with the options to show.
pub fn options(options: List(block.SelectOption)) -> Ack {
  ack_json(interaction.options_response_to_json(interaction.options(options)))
}

/// Acknowledge a `block_suggestion` with groups of options to show.
pub fn option_groups(groups: List(block.OptionGroup)) -> Ack {
  ack_json(
    interaction.options_response_to_json(interaction.option_groups(groups)),
  )
}

/// Acknowledge with any json body.
pub fn ack_json(body: json.Json) -> Ack {
  Ack(body: Some(body), after: fn() { Nil })
}

/// Slack sends an event again when your app did not acknowledge it in time.
/// `num` counts the retries and `reason` says why, such as `http_timeout`.
pub type Retry {
  Retry(num: Int, reason: String)
}

/// Where an event came from. `retry` is set when Slack sends the event again.
/// Use `event_id` to skip events you already handled.
pub type Delivery {
  Delivery(
    team_id: Option(String),
    enterprise_id: Option(String),
    api_app_id: Option(String),
    event_id: Option(String),
    event_time: Option(Int),
    authorizations: List(event.EnvelopeAuthorization),
    is_ext_shared_channel: Option(Bool),
    retry: Option(Retry),
  )
}

type Routes(a) =
  List(#(String, fn(a) -> Ack))

pub opaque type App {
  App(
    signing_secret: Option(String),
    commands: Routes(SlashCommand),
    events: List(fn(Event, Delivery) -> Nil),
    actions: List(#(String, fn(BlockAction, BlockActionsPayload) -> Ack)),
    view_submissions: Routes(ViewSubmissionPayload),
    view_closed: Routes(ViewClosedPayload),
    global_shortcuts: Routes(GlobalShortcutPayload),
    message_shortcuts: Routes(MessageShortcutPayload),
    block_suggestions: Routes(BlockSuggestionPayload),
    fallback: Option(fn(Interaction) -> Ack),
  )
}

/// An app that verifies every HTTP request with your signing secret.
pub fn new(signing_secret: String) -> App {
  App(..unverified(), signing_secret: Some(signing_secret))
}

/// An app that does not verify HTTP requests. Use it for Socket Mode, where
/// the connection itself is authenticated, and in tests.
pub fn unverified() -> App {
  App(
    signing_secret: None,
    commands: [],
    events: [],
    actions: [],
    view_submissions: [],
    view_closed: [],
    global_shortcuts: [],
    message_shortcuts: [],
    block_suggestions: [],
    fallback: None,
  )
}

/// Handles a slash command, such as `"/hello"`.
pub fn command(
  app: App,
  name: String,
  handler: fn(SlashCommand) -> Ack,
) -> App {
  App(..app, commands: [#(name, handler), ..app.commands])
}

/// Handles every Events API event. You can add several handlers. They run in
/// the order you added them, after the event is acknowledged.
pub fn on_event(app: App, handler: fn(Event, Delivery) -> a) -> App {
  let handler = fn(event, delivery) {
    let _ = handler(event, delivery)
    Nil
  }
  App(..app, events: list.append(app.events, [handler]))
}

/// Handles `block_actions` for elements with this `action_id`. The handler
/// gets the action that matched and the whole payload.
pub fn action(
  app: App,
  action_id: String,
  handler: fn(BlockAction, BlockActionsPayload) -> Ack,
) -> App {
  App(..app, actions: [#(action_id, handler), ..app.actions])
}

/// Handles `view_submission` for views with this `callback_id`. Answer with
/// `ack`, `errors`, `update`, `push` or `clear`.
pub fn view_submission(
  app: App,
  callback_id: String,
  handler: fn(ViewSubmissionPayload) -> Ack,
) -> App {
  App(..app, view_submissions: [#(callback_id, handler), ..app.view_submissions])
}

/// Handles `view_closed` for views with this `callback_id` (sent when the
/// view set `notify_on_close`).
pub fn view_closed(
  app: App,
  callback_id: String,
  handler: fn(ViewClosedPayload) -> Ack,
) -> App {
  App(..app, view_closed: [#(callback_id, handler), ..app.view_closed])
}

/// Handles global shortcuts with this `callback_id`.
pub fn global_shortcut(
  app: App,
  callback_id: String,
  handler: fn(GlobalShortcutPayload) -> Ack,
) -> App {
  App(..app, global_shortcuts: [#(callback_id, handler), ..app.global_shortcuts])
}

/// Handles message shortcuts with this `callback_id`.
pub fn message_shortcut(
  app: App,
  callback_id: String,
  handler: fn(MessageShortcutPayload) -> Ack,
) -> App {
  App(..app, message_shortcuts: [
    #(callback_id, handler),
    ..app.message_shortcuts
  ])
}

/// Handles `block_suggestion` requests for external selects with this
/// `action_id`.
pub fn block_suggestion(
  app: App,
  action_id: String,
  handler: fn(BlockSuggestionPayload) -> Ack,
) -> App {
  App(..app, block_suggestions: [#(action_id, handler), ..app.block_suggestions])
}

/// Handles any interaction that no other handler matched, such as a legacy
/// dialog or interactive message. A second call replaces the first handler.
pub fn on_interaction(app: App, handler: fn(Interaction) -> Ack) -> App {
  App(..app, fallback: Some(handler))
}

// ---- what arrives ----------------------------------------------------------

/// A request from Slack, decoded.
pub type Incoming {
  /// An Events API delivery, or a `url_verification` challenge.
  Events(Envelope)
  /// An interactivity payload.
  Interactive(Interaction)
  /// A slash command.
  Command(SlashCommand)
  /// One of Slack's periodic certificate checks for slash commands.
  SslCheck
}

/// Why a request could not be handled.
pub type RequestError {
  NotVerified(verify.VerifyError)
  /// The body was not something Slack sends.
  Malformed(String)
}

/// Decodes an HTTP request body from Slack. It does not check the signature.
/// `handle` does.
pub fn parse_request(
  request: Request(String),
) -> Result(Incoming, RequestError) {
  let content_type =
    request.get_header(request, "content-type") |> result.unwrap("")
  case string.starts_with(content_type, "application/json") {
    True ->
      json.parse(request.body, event.envelope_decoder())
      |> result.map(Events)
      |> result.map_error(fn(error) { Malformed(string.inspect(error)) })
    False -> parse_form(request.body)
  }
}

fn parse_form(body: String) -> Result(Incoming, RequestError) {
  use fields <- result.try(
    uri.parse_query(body)
    |> result.replace_error(Malformed("invalid form body")),
  )
  case list.key_find(fields, "payload"), list.key_find(fields, "ssl_check") {
    Ok(payload), _ -> parse_interaction(payload)
    _, Ok("1") -> Ok(SslCheck)
    _, _ ->
      command.parse(fields)
      |> result.map(Command)
      |> result.map_error(fn(errors) { Malformed(string.inspect(errors)) })
  }
}

fn parse_interaction(payload: String) -> Result(Incoming, RequestError) {
  json.parse(payload, interaction.interaction_decoder())
  |> result.map(Interactive)
  |> result.map_error(fn(error) { Malformed(string.inspect(error)) })
}

// ---- handling --------------------------------------------------------------

/// The response to send back to Slack, and the work to run once it is sent.
/// `after` does nothing when no handler asked for follow-up work.
pub type Handled {
  Handled(response: Response(String), after: fn() -> Nil)
}

/// Verifies, decodes and dispatches an HTTP request, and builds the response
/// to send back to Slack. Send `response`, then run `after`.
pub fn handle(app: App, request: Request(String)) -> Handled {
  let verified = case app.signing_secret {
    Some(secret) ->
      verify.request(request, secret) |> result.map_error(NotVerified)
    None -> Ok(Nil)
  }
  let outcome = {
    use Nil <- result.try(verified)
    use incoming <- result.map(parse_request(request))
    dispatch(app, incoming, http_retry(request))
  }
  case outcome {
    Ok(Ack(body: None, after:)) ->
      Handled(response.new(200) |> response.set_body(""), after)
    Ok(Ack(body: Some(body), after:)) ->
      Handled(
        response.new(200)
          |> response.set_header("content-type", "application/json")
          |> response.set_body(json.to_string(body)),
        after,
      )
    Error(NotVerified(_)) ->
      Handled(response.new(401) |> response.set_body(""), fn() { Nil })
    Error(Malformed(_)) ->
      Handled(response.new(400) |> response.set_body(""), fn() { Nil })
  }
}

fn http_retry(request: Request(String)) -> Option(Retry) {
  let num = request.get_header(request, "x-slack-retry-num")
  let reason = request.get_header(request, "x-slack-retry-reason")
  case result.try(num, int.parse), reason {
    Ok(num), Ok(reason) -> Some(Retry(num:, reason:))
    Ok(num), Error(Nil) -> Some(Retry(num:, reason: ""))
    Error(Nil), _ -> None
  }
}

/// What to do after a Socket Mode frame.
pub type SocketOutcome {
  /// Send this text frame back to acknowledge the message, then run `after`.
  Send(frame: String, after: fn() -> Nil)
  /// Slack is closing this connection: open a new one with
  /// `apps.connections.open`.
  Reconnect(socket_mode.DisconnectReason)
  /// Nothing to send, as after a `hello`.
  Ignore
}

/// Decodes and dispatches one Socket Mode text frame.
pub fn handle_socket(app: App, frame: String) -> SocketOutcome {
  case socket_mode.parse(frame) {
    Error(_) -> Ignore
    Ok(socket_mode.Disconnect(reason:, ..)) -> Reconnect(reason)
    Ok(socket_mode.EventsApi(
      envelope_id:,
      payload:,
      retry_attempt:,
      retry_reason:,
      ..,
    )) ->
      acknowledge(
        envelope_id,
        dispatch(
          app,
          Events(payload),
          socket_retry(retry_attempt, retry_reason),
        ),
      )
    Ok(socket_mode.SlashCommands(envelope_id:, payload:, ..)) ->
      acknowledge(envelope_id, dispatch(app, Command(payload), None))
    Ok(socket_mode.Interactive(envelope_id:, payload:, ..)) ->
      acknowledge(envelope_id, dispatch(app, Interactive(payload), None))
    Ok(_) -> Ignore
  }
}

fn socket_retry(num: Option(Int), reason: Option(String)) -> Option(Retry) {
  case num {
    Some(num) if num > 0 -> Some(Retry(num:, reason: option.unwrap(reason, "")))
    _ -> None
  }
}

fn acknowledge(envelope_id: String, ack: Ack) -> SocketOutcome {
  case ack.body {
    None -> Send(socket_mode.ack(envelope_id), ack.after)
    Some(body) -> Send(socket_mode.ack_with(envelope_id, body), ack.after)
  }
}

/// Runs the handlers for something that already arrived.
pub fn dispatch(app: App, incoming: Incoming, retry: Option(Retry)) -> Ack {
  case incoming {
    SslCheck -> ack()
    Command(command) ->
      case list.key_find(app.commands, command.command) {
        Ok(handler) -> handler(command)
        Error(Nil) -> ack()
      }
    Events(event.UrlVerification(challenge:, ..)) ->
      ack_json(json.object([#("challenge", json.string(challenge))]))
    Events(event.EventCallback(
      team_id:,
      enterprise_id:,
      api_app_id:,
      event: inner,
      event_id:,
      event_time:,
      authorizations:,
      is_ext_shared_channel:,
      ..,
    )) -> {
      let delivery =
        Delivery(
          team_id:,
          enterprise_id:,
          api_app_id:,
          event_id:,
          event_time:,
          authorizations: option.unwrap(authorizations, []),
          is_ext_shared_channel:,
          retry:,
        )
      case app.events {
        [] -> ack()
        handlers ->
          ack_then(fn() {
            list.each(handlers, fn(handler) { handler(inner, delivery) })
          })
      }
    }
    Events(_) -> ack()
    Interactive(payload) -> dispatch_interaction(app, payload)
  }
}

fn dispatch_interaction(app: App, payload: Interaction) -> Ack {
  let matched = case payload {
    interaction.BlockActions(
      interaction.BlockActionsPayload(actions: Some(actions), ..) as inner,
    ) ->
      list.find_map(actions, fn(action) {
        use id <- result.try(option.to_result(
          interaction.action_id(action),
          Nil,
        ))
        use handler <- result.map(list.key_find(app.actions, id))
        handler(action, inner)
      })
    interaction.BlockSuggestion(inner) ->
      run(app.block_suggestions, Some(inner.action_id), inner)
    interaction.ViewSubmission(inner) ->
      run(app.view_submissions, inner.view.callback_id, inner)
    interaction.ViewClosed(inner) ->
      run(app.view_closed, inner.view.callback_id, inner)
    interaction.GlobalShortcut(inner) ->
      run(app.global_shortcuts, Some(inner.callback_id), inner)
    interaction.MessageShortcut(inner) ->
      run(app.message_shortcuts, Some(inner.callback_id), inner)
    _ -> Error(Nil)
  }
  case matched {
    Ok(ack) -> ack
    Error(Nil) ->
      case app.fallback {
        Some(handler) -> handler(payload)
        None -> ack()
      }
  }
}

fn run(
  handlers: Routes(a),
  key: Option(String),
  payload: a,
) -> Result(Ack, Nil) {
  use key <- result.try(option.to_result(key, Nil))
  use handler <- result.map(list.key_find(handlers, key))
  handler(payload)
}
