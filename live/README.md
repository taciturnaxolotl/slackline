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
gleam run -m slackline_live/lifecycle C0123  # channel lifecycle, user groups, profiles, webhooks
cd js && gleam run -- C0123                  # the fetch client on the JavaScript target
gleam run -m slackline_live/probe C0123 [ratelimit]  # newer families; ratelimit waits out real limits
gleam run -m slackline_live/setup -- rotate  # renew the configuration token (it lasts 12 hours)
gleam run -m slackline_live/setup -- throwaway  # create, export and delete a second app
gleam run -m slackline_live/setup -- update socket
gleam run -m slackline_live/socket           # the same router over Socket Mode
```

| Module | What it checks |
| --- | --- |
| `live` | Calls read-only methods and decodes each response. It reports decode failures and every `Unknown*` catch-all variant, which mark values the docs do not list. |
| `writes` | Posts one message per Block Kit block, then edits, threads, reacts, pins, bookmarks, schedules, uploads and deletes. Pass a channel ID, `dm`, or nothing to create a channel. |
| `extras` | Canvases, `chat.startStream`/`appendStream`/`stopStream`, Calls with a `call` block, remote files, presence, stars and Do Not Disturb. Pass `reminders` to also run `reminders.*`; Slack files new reminders under To-dos where the other reminder methods cannot see them, so each run leaves one behind. |
| `lifecycle` | Creates, renames, archives and unarchives a channel, kicks and leaves; a channel canvas and its access; a user group through create, update, members, disable and enable; profile and status updates; public file links; remote files with a multipart preview image and search terms; an incoming webhook (saved by `bot` during an install with the `incoming-webhook` scope), including a refused one; and `api.test`, `blocks.validate`, `dnd.teamInfo`, `team.preferences.list`. |
| `probe` | Calls the newer families once with each token (Slackbot skills, assistant search, featured workflows, billing, `apps.icon.set` as multipart) and reports how Slack answers. It also runs every `slackLists.*` method against a new List (items with cells, info, update, delete, deleteMultiple, sharing to the channel and back, export), then removes the List with `files.delete`. `ratelimit` calls `users.list` 150 times through `httpc.retrying`, which waits out Slack's limits. In patchworklabs, all 150 calls succeeded after Slack limited the run eight times, each time with `Retry-After: 30`. |
| `js/` | A separate JavaScript-target project that sends calls with `slackline/fetch`: a read, a three-page `fold_pages`, a post and delete, a file upload and an incoming webhook. |
| `bot` | Serves the OAuth install, the Events API, slash commands, interactivity and external options through `slackline/app`. `/slackline blocks` and `/slackline modal` drive the interactive paths, including `views.push`, `views.update`, the push/update/clear response actions, both shortcuts and `link_shared` unfurls. An `assistant_thread_started` event sets the thread title, suggested prompts and status. |
| `socket` | Runs the `bot` router over Socket Mode. With `SLACKLINE_DEBUG_RECONNECTS` set, Slack disconnects after about six minutes, which exercises the `disconnect` frame and reconnect. |
| `setup` | Creates, updates and deletes the test app with `apps.manifest.*`, exchanges OAuth codes, renews the configuration token with `tooling.tokens.rotate`, and runs a throwaway app through create, export and delete. |

Some calls cannot pass with this app. Slack rejects a manifest for a distributed app that asks for `app_configurations:read` or `app_configurations:write`, so `apps.icon.set` and `functions.distributions.permissions.*` stay `missing_scope`. `hosting:read` is not a user scope, and `apps.activities.list` refuses bot tokens. On a Pro (`std`) workspace with AI search off, `slackbot.skills.*` answers `restricted_action` and `assistant.search.context` answers `feature_not_enabled`.

Raw bodies are saved under `build/live/` for inspection.
