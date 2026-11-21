# Slack API docs errata

This doc has all of the issues I noticed with the slack docs when testing slackline. These results were tested against a Pro workspace. The docs were last checked on 2026-11-21.

## Extra returned keys

- `subteam_members_changed`: the docs show `added_users_count` as a string. Live events send a number.
- Message attachments: the docs say `ts` is an integer. That's true for attachments an app posts (Slack even converts a string `ts` to an integer). But when a message links to another Slack message, Slack adds an attachment with `is_msg_unfurl: true`, and its `ts` is the linked message's timestamp as a string, such as `"1795289155.215419"`.
- File `mode` has three values the docs don't list: `quip` (canvases), `email` and `tombstone`.
- Message `subtype` has five values the docs don't list: `slackbot_response`, `tabbed_canvas_updated`, `tombstone`, `bot_add` and `bot_remove`.
- `team.profile.get` returns profile fields of type `file`, which isn't a documented type.
- `assistant_thread_started` includes `thread_entry_point` and `force_search` on `assistant_thread`. Neither is documented.

## Where the docs come from

Each method page has a machine-readable version at `https://docs.slack.dev/reference/methods/<method>.json`. It has the arguments as JSON Schema, the scopes, the rate tier, the errors and, for 260 methods, a schema for the response. A coverage script in the docs bundle calls the source of this data "webapp hermes/types (the platform source of truth)".

The pages don't show everything in this data. The next two sections cover that gap.

## Response schemas the pages don't show

The pages show response examples, never the response schema. These keys are in the schema but appear nowhere on their page:

- `auth.test`: `app_id`, `app_name`, `expires_in`
- `conversations.history`: `channel_actions_count`, `channel_actions_ts` (also seen live)
- `emoji.list`: `cache_ts`, `categories_version` (also seen live)
- `users.list`: `offset` (also seen live)
- `files.info`: `content`, `content_html`, `content_highlight_html`
- `users.profile.set`: `username`
- `apps.manifest.create`: `team_domain`
- `conversations.acceptSharedInvite`: `can_open_scdm`
- `admin.functions.permissions.lookup`: `metadata`
- `admin.conversations.lookup`: `channel_ids`

Some responses have a full schema but nothing on the page:

- `admin.apps.mcp.servers.list` and `admin.apps.mcp.servers.permissions.list`: the Response section is empty, but the schema describes every field.
- `admin.conversations.getConversationPrefs`: `can_huddle` is an object with an `enabled` boolean.
- `admin.functions.permissions.lookup` and `admin.workflows.permissions.lookup`: the `permissions` objects are fully described.

The schema itself has at least one mistake: `bots.info` lists a `bots` array, but live responses send a single `bot` object.

## Argument types the pages don't show

200 arguments on 134 methods show no type on their page, for example `id` on `slackLists.update`. Every one of them has a type in the JSON. The page only prints `type`, and these arguments use `schema` or `subtype` instead (`id` is `schema: file_id`).

## Keys missing from both the page and the schema

`slackapi/java-slack-sdk` keeps response samples in `json-logs/samples/api`. A bot updates them from the SDK's end-to-end runs against production. These keys are in those samples but in neither the page nor the schema:

- `files.info`: `content_highlight_css`, `content_highlight_html_truncated`, `is_truncated`
- `chat.postMessage`: `deprecated_argument`
- `workflows.featured.list`: `invalid_channel_ids`
- `agents.conversations.listViews`: `session_views`

SDK maintainers added these by hand along with the method, so they may not come from a recorded response:

- `team.preferences.list`: `allow_message_deletion`
- `admin.slackbot.skills.setAutoEnabled`: `invalid_usergroup_ids`

## Undocumented methods

`apps.user.connection.bulkUpdate` (returns `changed_user_ids` and `failures`) and `apps.user.connection.requestAuth` have no docs page, no JSON and no mention anywhere on docs.slack.dev. One of the Java SDK's maintainers added both in October 2026.

The official OpenAPI spec, `slackapi/slack-api-specs`, was archived in 2021. `api.slack.com/specs/openapi/v2/slack_web.json` still serves that same 2021 spec (170 methods).

## Methods and scopes

- `reminders.*` are all marked as not deprecated (in the JSON too, where only `stars.list` has `deprecated: true`), but they no longer work properly with the migration to todos. `reminders.add` succeeds, and the new reminder shows up in To-dos. After that, `reminders.info`, `list`, `complete` and `delete` return `not_found` or an empty list.
- `reminders.info`: the success example has no `reminder`, which is the only field in the response.
- `apps.activities.list` lists `hosting:read` as its user scope. A manifest that asks for `hosting:read` as a user scope fails with `illegal_user_scopes`, and the method rejects bot tokens.
- `apps.icon.set` lists `app_configurations:write` as a user scope. A distributed app can't request that scope: the manifest fails with "Distributed apps can't add the app_configurations:* scope". The page doesn't mention this.
- `slackbot.skills.list` returns `restricted_action`, and `assistant.search.context` returns `feature_not_enabled`, on a Pro workspace with AI search off. Both errors are listed but don't mention required plan.

## Legal Holds API

The `admin.legalHold.*` methods are only on the [Legal Holds API reference](https://docs.slack.dev/reference/legal-holds-api-reference). They have no method pages and no method json, so anything built from the methods reference misses them.

- The scopes table names the methods `admin.legalHolds.*`. Those names answer `unknown_method`; the real ones are `admin.legalHold.*`.
- The errors table says a token without the scopes gets `unknown_method`, and calls the scopes `admin.legalHolds:*`. Live, a token without them gets `missing_scope` with `needed: admin.legal_holds:read`.

## Other APIs

- Audit Logs API: errors arrive as an empty body with HTTP 400 (no token) or 401 (a token that can't read logs), not as the documented codes such as `missing_authentication` or `invalid_authentication`. An unknown endpoint answers HTTP 500 with an HTML page, not `bad_endpoint`.
- Audit Logs API: `/schemas` lists the `user` and `app` types twice.
- SCIM API: with a Pro plan's token, v1 answers `plus_teams_only` as documented, but v2 answers `unsupported_version`.
- Status API: `id` is shown as a string (`"546"`); the live API sends a number.
- Status API: the `current` and `history` sections list different services. `current` has `Canvases` and `Connectivity`; `history` has `Connections`, `Posts/Files`, `Calls` and `Link Previews`. Live history uses `Connectivity` and `Canvases`.

## Arguments missing from the arguments list

These arguments only show up in prose or examples. They are missing from the JSON too:

- `chat.unfurl`: `metadata` (the alternative to `unfurls`)
- `assistant.search.context`: `keywords_clauses`
- `admin.analytics.messages.metadata`: `limit`
- `admin.barriers.list`: `filter_by_usergroup_name`
- `admin.workflows.triggers.types.permissions.set`: `team_ids` and `org_ids`

## Pages that contradict themselves

- Confirmation dialog object: `text` is documented as `plain_text`, but the example on the same page uses `mrkdwn`.
- `static_select`: `options` is marked required, but the same page says to leave it out when you set `option_groups`.
- `rich_text_list`: `style` is marked required, and one example leaves it out.
- Card block: the field table says `title`, `subtitle` and `body` are strings, but the examples use text objects. `actions` is described as an actions block, but the examples send a plain array of buttons.
- `view_submission` payload: `enterprise` is marked required, and the example leaves it out.
- Message shortcut payload: the reference says the type is `message_actions`, but the example says `message_action`.
- `document_mention` message event: the example has `type: "app_mention"`.
- `chat.scheduleMessage` and `chat.scheduledMessages.list` disagree on two types. `post_at` is a string in one and an integer in the other, and `scheduled_message_id` has the same mismatch.
- `assistant.search.context`: the `content_types` description lists `messages`, `files`, `channels` and `users`. The accepted-values list under it adds `enterprise`.
- `team.externalTeams.list`: the `slack_connect_pref_filter` description and its accepted-values list disagree. The list adds `interact_with_externally_owned_workflows` and `external_teams_interact_with_locally_owned_workflows`.
- `team.externalTeams.list`: `connected_workspaces` is a list in the field table but a single object in the example.
- `slackLists.items.*`: `checkbox` is a list of booleans in the template and a single boolean in the examples.
- App manifest: `suggested_triggers` is documented as an array, but the example is an object keyed by trigger name.

## Broken examples

- `function_executed` event: the example has a trailing comma in `authorizations`, so it isn't valid json.
- Status API: the incident example has a trailing comma after `notes`.
- `assistant.search.context`: one example spells a key `user_id:`, with the colon inside the name.
- `admin.conversations.ekm.listOriginalConnectedChannelInfo`: `internal_team_ids` is the string `"array"` instead of a list.
- `apps.event.authorizations.list`: `is_bot` is a placeholder string instead of a boolean.
- `admin.barriers.*`: one example puts `response_metadata` inside the barrier object.
- `message` event: one example has no `ts`.
- `reactions.list`: the file comment example has no `type`.

## Missing shapes

These have no type or structure on the page or in the JSON:

- `block_actions`: only `action_id`, `block_id`, `value` and `action_ts` are described for each action, not the `selected_*` fields.
- Plan block: task `icon` is described only as "Icon".
- `admin.teams.settings.info`: `icon` points to a `common_objects_schema` definition that isn't published.
- `entity.presentComments`: the `error` argument points to an `error` definition that isn't published.
- `admin.emoji.list`: `cache_ts` appears in the prose but not in the response.
- `slackbot.skills.create` and `slackbot.skills.update`: one response field each.
- `admin.apps.permissions.list`: no response schema and no example.

More generally, the JSON references about 100 shared definitions by name (`message`, `channel`, `file`, `conversation` and so on). None of them is published.

## Across the reference

Out of 359 methods:

- 44 arguments have no description, and `token` has no description on 23 methods.
- 52 methods have no response example on their page, and 25 of those have no response schema in the JSON either. Methods with no example include every `calls.*` method and every `admin.inviteRequests.*` method.
