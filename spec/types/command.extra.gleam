import gleam/dynamic
import gleam/dynamic/decode
import gleam/list

/// Decodes a slash command from form fields that are already parsed, for
/// example the result of `uri.parse_query` on the request body.
pub fn parse(
  fields: List(#(String, String)),
) -> Result(SlashCommand, List(decode.DecodeError)) {
  fields
  |> list.map(fn(pair) { #(dynamic.string(pair.0), dynamic.string(pair.1)) })
  |> dynamic.properties
  |> decode.run(slash_command_decoder())
}
