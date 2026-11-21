import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/string
import slackline

/// Decodes a decompressed `admin.analytics.getFile` body, which holds one json
/// object per line, using a row decoder such as `member_analytics_decoder()`.
/// Blank lines are skipped.
pub fn decode_lines(
  text: String,
  row: decode.Decoder(a),
) -> Result(List(a), json.DecodeError) {
  text
  |> string.split("\n")
  |> list.map(string.trim)
  |> list.filter(fn(line) { line != "" })
  |> list.try_map(fn(line) { json.parse(line, row) })
}

/// `admin.analytics.getFile` for member analytics on `date`
/// (`YYYY-MM-DD`, UTC), one row per member.
pub fn get_member_file(
  date date: String,
) -> slackline.Call(GetFile, List(MemberAnalytics)) {
  get_file(type_: Member)
  |> slackline.with_param("date", date)
  |> slackline.decode_with(decode.list(member_analytics_decoder()))
}

/// `admin.analytics.getFile` for public channel analytics on `date`
/// (`YYYY-MM-DD`, UTC), one row per channel.
pub fn get_public_channel_file(
  date date: String,
) -> slackline.Call(GetFile, List(PublicChannelAnalytics)) {
  get_file(type_: PublicChannel)
  |> slackline.with_param("date", date)
  |> slackline.decode_with(decode.list(public_channel_analytics_decoder()))
}

/// `admin.analytics.getFile` with `metadata_only`: the current name, topic
/// and description of each public channel.
pub fn get_public_channel_metadata_file() -> slackline.Call(
  GetFile,
  List(PublicChannelMetadata),
) {
  get_file(type_: PublicChannel)
  |> slackline.with_param("metadata_only", "true")
  |> slackline.decode_with(decode.list(public_channel_metadata_decoder()))
}
