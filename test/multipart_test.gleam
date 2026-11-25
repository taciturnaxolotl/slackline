import gleam/bit_array
import slackline/internal/multipart.{Field, File}

fn encode(parts) {
  let assert Ok(body) = multipart.encode("B", parts) |> bit_array.to_string
  body
}

pub fn encode_test() {
  assert encode([
      Field("a", "1"),
      File(name: "f", filename: "x.txt", content_type: "text/plain", body: <<
        "hi\r\n":utf8,
      >>),
    ])
    == "--B\r\n"
    <> "Content-Disposition: form-data; name=\"a\"\r\n\r\n1\r\n"
    <> "--B\r\n"
    <> "Content-Disposition: form-data; name=\"f\"; filename=\"x.txt\"\r\n"
    <> "Content-Type: text/plain\r\n\r\nhi\r\n\r\n"
    <> "--B--\r\n"
}

pub fn header_injection_test() {
  assert encode([
      Field("a\r\nb", "line\none"),
      File(
        name: "",
        filename: "evil\r\nX: \"1\"\u{0000}.txt",
        content_type: "text/plain\nX: 2",
        body: <<>>,
      ),
    ])
    == "--B\r\n"
    <> "Content-Disposition: form-data; name=\"a%0D%0Ab\"\r\n\r\nline\none\r\n"
    <> "--B\r\n"
    <> "Content-Disposition: form-data; name=\"\"; filename=\"evil%0D%0AX: %221%22%00.txt\"\r\n"
    <> "Content-Type: text/plain%0AX: 2\r\n\r\n\r\n"
    <> "--B--\r\n"
}

// Browsers send `\` as is, so Slack reads it that way; don't escape it.
pub fn backslash_test() {
  assert encode([Field("k\\", "v")])
    == "--B\r\nContent-Disposition: form-data; name=\"k\\\"\r\n\r\nv\r\n--B--\r\n"
}

// Combining marks and prepend characters next to a quote pass through unchanged.
pub fn unicode_names_test() {
  assert encode([Field("x\u{0600}", "y")])
    == "--B\r\nContent-Disposition: form-data; name=\"x\u{0600}\"\r\n\r\ny\r\n--B--\r\n"
  assert encode([
      File(
        name: "f",
        filename: "\u{0301}p.png",
        content_type: "image/png",
        body: <<>>,
      ),
    ])
    == "--B\r\nContent-Disposition: form-data; name=\"f\"; filename=\"\u{0301}p.png\"\r\n"
    <> "Content-Type: image/png\r\n\r\n\r\n--B--\r\n"
}
