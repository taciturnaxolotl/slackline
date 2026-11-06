//// Runs the live test app over Socket Mode, with the same router as `bot`.
////
//// ```sh
//// source ~/.local/state/slackline-live/env   # sets SLACK_APP_TOKEN
//// gleam run -m slackline_live/socket
//// SLACKLINE_DEBUG_RECONNECTS=1 gleam run -m slackline_live/socket  # disconnect in ~6 min
//// ```
////
//// Every frame is saved to `build/live/socket/`, and every frame that
//// `socket_mode.parse` cannot decode is reported.

import gleam/erlang/process
import gleam/http/request
import gleam/int
import gleam/io
import gleam/option.{type Option, None, Some}
import gleam/string
import slackline
import slackline/api/apps
import slackline/app
import slackline/httpc
import slackline/socket_mode
import slackline_live/bot
import slackline_live/env
import stratus

pub fn main() -> Nil {
  let assert Ok(app_token) = env.getenv("SLACK_APP_TOKEN")
  let assert Ok(info) = env.load_app()
  connect(app_token, bot.router(info))
}

fn connect(app_token: String, router: app.App) -> Nil {
  case apps.connections_open() |> httpc.send(slackline.new(app_token)) {
    Error(error) -> {
      io.println("connections.open: " <> slackline.describe_error(error))
      process.sleep(5000)
      connect(app_token, router)
    }
    Ok(opened) -> {
      let done = process.new_subject()
      let opened_url = case env.getenv("SLACKLINE_DEBUG_RECONNECTS") {
        Ok(_) -> opened.url <> "&debug_reconnects=true"
        Error(Nil) -> opened.url
      }
      let url = case opened_url {
        "wss://" <> rest -> "https://" <> rest
        "ws://" <> rest -> "http://" <> rest
        url -> url
      }
      let assert Ok(request) = request.to(url)
      let started =
        stratus.new(request:, state: Nil)
        |> stratus.on_message(fn(state, message, connection) {
          case message {
            stratus.Text(frame) -> {
              case handle(router, frame) {
                Ok(Some(reply)) -> {
                  let _ = stratus.send_text_message(connection, reply)
                  stratus.continue(state)
                }
                Ok(None) -> stratus.continue(state)
                Error(Nil) -> {
                  process.send(done, Nil)
                  stratus.stop()
                }
              }
            }
            _ -> stratus.continue(state)
          }
        })
        |> stratus.on_close(fn(_, reason) {
          io.println("closed: " <> string.inspect(reason))
          process.send(done, Nil)
        })
        |> stratus.start
      case started {
        Error(error) -> io.println("connect: " <> string.inspect(error))
        Ok(_) -> {
          io.println("connected")
          let _ = process.receive_forever(done)
          Nil
        }
      }
      process.sleep(1000)
      connect(app_token, router)
    }
  }
}

/// The reply frame to send, if any, or `Error(Nil)` to reconnect.
fn handle(router: app.App, frame: String) -> Result(Option(String), Nil) {
  let n = env.unique()
  let kind = case socket_mode.parse(frame) {
    Ok(socket_mode.Hello(..)) -> "hello"
    Ok(socket_mode.Disconnect(..)) -> "disconnect"
    Ok(socket_mode.EventsApi(..)) -> "events_api"
    Ok(socket_mode.Interactive(..)) -> "interactive"
    Ok(socket_mode.SlashCommands(..)) -> "slash_commands"
    Ok(socket_mode.UnknownSocketMessage(type_:, ..)) -> "unknown-" <> type_
    Error(error) -> {
      io.println(
        "UNDECODED frame " <> int.to_string(n) <> ": " <> string.inspect(error),
      )
      "undecoded"
    }
  }
  let _ =
    env.write_file(
      "build/live/socket/"
        <> string.pad_start(int.to_string(n), 4, "0")
        <> "-"
        <> kind
        <> ".json",
      frame,
    )
  io.println("frame " <> int.to_string(n) <> ": " <> kind)
  case app.handle_socket(router, frame) {
    app.Send(frame: reply, after:) -> {
      process.spawn(after)
      Ok(Some(reply))
    }
    app.Reconnect(reason) -> {
      io.println("reconnect: " <> string.inspect(reason))
      Error(Nil)
    }
    app.Ignore -> Ok(None)
  }
}
