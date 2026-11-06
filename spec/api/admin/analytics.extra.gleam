import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/string

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
