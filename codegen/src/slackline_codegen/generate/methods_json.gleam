//// Decoders for `spec/methods.json`, the facts that
//// `gleam run -m slackline_codegen/docs extract` takes from the method
//// reference pages.

import gleam/dynamic/decode
import gleam/option.{None}
import slackline_codegen/generate/ir

/// Decodes the whole file: one entry per Web API method.
pub fn decoder() -> decode.Decoder(List(ir.DocsMethod)) {
  decode.list(docs_method_decoder())
}

fn docs_method_decoder() -> decode.Decoder(ir.DocsMethod) {
  use name <- decode.field("name", decode.string)
  use summary <- decode.field("summary", decode.string)
  use deprecated <- decode.field("deprecated", decode.bool)
  use url <- decode.field("url", decode.string)
  use rate_limit <- decode.optional_field(
    "rate_limit",
    None,
    decode.optional(decode.string),
  )
  use bot_scopes <- decode.subfield(
    ["scopes", "bot"],
    decode.list(decode.string),
  )
  use user_scopes <- decode.subfield(
    ["scopes", "user"],
    decode.list(decode.string),
  )
  use args <- decode.field("args", decode.list(docs_arg_decoder()))
  use errors <- decode.field(
    "errors",
    decode.list(decode.at(["code"], decode.string)),
  )
  use examples <- decode.field(
    "response_examples",
    decode.list({
      use title <- decode.field("title", decode.string)
      use body <- decode.field("body", decode.string)
      decode.success(ir.Example(title:, body:))
    }),
  )
  decode.success(ir.DocsMethod(
    name:,
    summary:,
    deprecated:,
    url:,
    rate_limit:,
    bot_scopes:,
    user_scopes:,
    args:,
    errors:,
    examples:,
  ))
}

fn docs_arg_decoder() -> decode.Decoder(ir.DocsArg) {
  use name <- decode.field("name", decode.string)
  use type_ <- decode.optional_field(
    "type",
    None,
    decode.optional(decode.string),
  )
  use required <- decode.field("required", decode.bool)
  use description <- decode.optional_field("description", "", decode.string)
  use default <- decode.optional_field(
    "default",
    None,
    decode.optional(decode.string),
  )
  use example <- decode.optional_field(
    "example",
    None,
    decode.optional(decode.string),
  )
  decode.success(ir.DocsArg(
    name:,
    type_:,
    required:,
    description:,
    default:,
    example:,
  ))
}
