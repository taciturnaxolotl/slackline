//// Build text in Slack's `mrkdwn` format, as described in
//// <https://docs.slack.dev/messaging/formatting-message-text>.
////
//// ```gleam
//// mrkdwn.user("U123") <> " shipped " <> mrkdwn.link("https://example.com", "the thing")
//// // "<@U123> shipped <https://example.com|the thing>"
//// ```

import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/string

/// Escapes the three control characters (`&`, `<`, `>`) so user supplied
/// text cannot inject mentions or links.
pub fn escape(text: String) -> String {
  text
  |> string.replace("&", "&amp;")
  |> string.replace("<", "&lt;")
  |> string.replace(">", "&gt;")
}

/// Reverses `escape`, for text read back from Slack.
pub fn unescape(text: String) -> String {
  text
  |> string.replace("&lt;", "<")
  |> string.replace("&gt;", ">")
  |> string.replace("&amp;", "&")
}

/// `*bold*`
pub fn bold(text: String) -> String {
  "*" <> text <> "*"
}

/// `_italic_`
pub fn italic(text: String) -> String {
  "_" <> text <> "_"
}

/// `~strikethrough~`
pub fn strike(text: String) -> String {
  "~" <> text <> "~"
}

/// `` `inline code` ``
pub fn code(text: String) -> String {
  "`" <> text <> "`"
}

/// A multi-line code block.
pub fn code_block(text: String) -> String {
  "```" <> text <> "```"
}

/// Quotes every line of `text`.
pub fn quote(text: String) -> String {
  text
  |> string.split("\n")
  |> string.join("\n>")
  |> string.append(">", _)
}

/// A link with custom text: `<url|text>`.
pub fn link(url: String, text: String) -> String {
  "<" <> url <> "|" <> escape(text) <> ">"
}

/// A bare link: `<url>`.
pub fn url(url: String) -> String {
  "<" <> url <> ">"
}

/// An email link: `<mailto:address|text>`.
pub fn email(address: String, text: String) -> String {
  link("mailto:" <> address, text)
}

/// Mentions a user: `<@U123>`.
pub fn user(id: String) -> String {
  "<@" <> id <> ">"
}

/// Links a channel: `<#C123>`.
pub fn channel(id: String) -> String {
  "<#" <> id <> ">"
}

/// Mentions a user group: `<!subteam^S123>`.
pub fn usergroup(id: String) -> String {
  "<!subteam^" <> id <> ">"
}

/// `<!here>`: notifies the active members of a channel.
pub const here = "<!here>"

/// `<!channel>`: notifies every member of a channel.
pub const channel_mention = "<!channel>"

/// `<!everyone>`: notifies every non-guest member of the workspace.
pub const everyone = "<!everyone>"

/// Formats a unix timestamp in each reader's own timezone:
/// `<!date^timestamp^format^link|fallback>`. `format` may use the tokens
/// `{date_num}`, `{date}`, `{date_short}`, `{date_long}`, `{date_pretty}`,
/// `{date_short_pretty}`, `{date_long_pretty}`, `{time}`, `{time_secs}` and
/// `{ago}`.
pub fn date(
  timestamp timestamp: Int,
  format format: String,
  link link: Option(String),
  fallback fallback: String,
) -> String {
  let link = case link {
    Some(url) -> "^" <> url
    None -> ""
  }
  "<!date^"
  <> int.to_string(timestamp)
  <> "^"
  <> format
  <> link
  <> "|"
  <> escape(fallback)
  <> ">"
}

/// An emoji by name, without colons: `emoji("tada")` is `:tada:`.
pub fn emoji(name: String) -> String {
  ":" <> name <> ":"
}
