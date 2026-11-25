//// Encodes `multipart/form-data` bodies the way browsers do, so Slack reads
//// them as it reads a form upload.

import gleam/bit_array
import gleam/list

pub type Part {
  Field(name: String, value: String)
  File(name: String, filename: String, content_type: String, body: BitArray)
}

/// The body for `parts`, delimited by `boundary`.
pub fn encode(boundary: String, parts: List(Part)) -> BitArray {
  let delimiter = <<"--":utf8, boundary:utf8, "\r\n":utf8>>
  list.map(parts, encode_part(delimiter, _))
  |> list.append([<<"--":utf8, boundary:utf8, "--\r\n":utf8>>])
  |> bit_array.concat
}

fn encode_part(delimiter: BitArray, part: Part) -> BitArray {
  let #(headers, body) = case part {
    Field(name:, value:) -> #(disposition(name), <<value:utf8>>)
    File(name:, filename:, content_type:, body:) -> #(
      <<
        disposition(name):bits,
        "; filename=":utf8,
        quoted(filename):bits,
        "\r\nContent-Type: ":utf8,
        escape(<<content_type:utf8>>, False, <<>>):bits,
      >>,
      body,
    )
  }
  <<delimiter:bits, headers:bits, "\r\n\r\n":utf8, body:bits, "\r\n":utf8>>
}

fn disposition(name: String) -> BitArray {
  <<"Content-Disposition: form-data; name=":utf8, quoted(name):bits>>
}

fn quoted(value: String) -> BitArray {
  <<"\"":utf8, escape(<<value:utf8>>, True, <<>>):bits, "\"":utf8>>
}

/// Percent-encodes CR, LF, NUL and, when `quoted`, `"`. Like browsers, it
/// leaves `\` alone. Works on bytes, so no grapheme can hide them.
fn escape(value: BitArray, quoted: Bool, acc: BitArray) -> BitArray {
  case value {
    <<13, rest:bytes>> -> escape(rest, quoted, <<acc:bits, "%0D":utf8>>)
    <<10, rest:bytes>> -> escape(rest, quoted, <<acc:bits, "%0A":utf8>>)
    <<0, rest:bytes>> -> escape(rest, quoted, <<acc:bits, "%00":utf8>>)
    <<34, rest:bytes>> if quoted ->
      escape(rest, quoted, <<acc:bits, "%22":utf8>>)
    <<byte, rest:bytes>> -> escape(rest, quoted, <<acc:bits, byte>>)
    _ -> acc
  }
}
