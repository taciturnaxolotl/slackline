# slackline_live

Runs slackline against a real Slack workspace. It is a separate Erlang-only project, so the web server and websocket dependencies stay out of the library. Credentials live in `~/.local/state/slackline-live/`, outside the repository.

```sh
cd live
source ~/.local/state/slackline-live/env     # SLACK_CONFIG_TOKEN, SLACK_APP_TOKEN

gleam run -m slackline_live/setup -- create  # create the test app from a manifest
gleam run -m slackline_live/bot              # HTTP server on port 8000 (with: bore slackline 8000)
gleam run -m slackline_live/setup -- url     # print the install link
SLACK_TOKEN=xoxp-... gleam run -m slackline_live/live  # read-only decode checks
gleam run -m slackline_live/writes dm        # write checks in the app's DM
gleam run -m slackline_live/extras           # canvases, streaming, Calls, remote files, stars, DND
gleam run -m slackline_live/setup -- update socket
gleam run -m slackline_live/socket           # the same router over Socket Mode
```

| Module | What it checks |
| --- | --- |
| `live` | Calls read-only methods and decodes each response. It reports decode failures and every `Unknown*` catch-all variant, which mark values the docs do not list. |
| `writes` | Posts one message per Block Kit block, then edits, threads, reacts, pins, bookmarks, schedules, uploads and deletes. Pass a channel ID, `dm`, or nothing to create a channel. |
| `extras` | Canvases, `chat.startStream`/`appendStream`/`stopStream`, Calls with a `call` block, remote files, presence, stars and Do Not Disturb. Pass `reminders` to also run `reminders.*`; Slack files new reminders under To-dos where the other reminder methods cannot see them, so each run leaves one behind. |
| `bot` | Serves the OAuth install, the Events API, slash commands, interactivity and external options through `slackline/app`. `/slackline blocks` and `/slackline modal` drive the interactive paths, including `views.push`, `views.update`, the push/update/clear response actions, both shortcuts and `link_shared` unfurls. |
| `socket` | Runs the `bot` router over Socket Mode. |
| `setup` | Creates, updates and deletes the test app with `apps.manifest.*`, and exchanges OAuth codes. |

Raw bodies are saved under `build/live/` for inspection.
