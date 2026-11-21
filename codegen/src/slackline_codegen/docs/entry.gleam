//// One method's entry in `spec/methods.json`. Every docs page parser builds
//// one of these, so the file's shape is written down in a single place.

import gleam/json.{type Json}
import gleam/option.{type Option}
import slackline_codegen/docs/args.{type Arg}

pub type MethodEntry {
  MethodEntry(
    name: String,
    summary: String,
    deprecated: Bool,
    url: String,
    http_method: String,
    rate_limit: Option(String),
    bot_scopes: List(String),
    user_scopes: List(String),
    configuration_scopes: List(String),
    content_types: List(String),
    args: List(Arg),
    /// `{"code", "description"}` objects.
    errors: List(Json),
    /// `{"title", "body"}` objects.
    response_examples: List(Json),
    /// Top-level keys of the response schema, when one is published.
    response_fields: Option(List(String)),
  )
}

pub fn to_json(entry: MethodEntry) -> Json {
  let strings = json.array(_, json.string)
  json.object([
    #("name", json.string(entry.name)),
    #("summary", json.string(entry.summary)),
    #("deprecated", json.bool(entry.deprecated)),
    #("url", json.string(entry.url)),
    #("http_method", json.string(entry.http_method)),
    #("rate_limit", json.nullable(entry.rate_limit, json.string)),
    #(
      "scopes",
      json.object([
        #("bot", strings(entry.bot_scopes)),
        #("user", strings(entry.user_scopes)),
        #("configuration", strings(entry.configuration_scopes)),
      ]),
    ),
    #("content_types", strings(entry.content_types)),
    #("args", json.array(entry.args, args.to_json)),
    #("errors", json.preprocessed_array(entry.errors)),
    #("response_examples", json.preprocessed_array(entry.response_examples)),
    #("response_fields", json.nullable(entry.response_fields, strings)),
  ])
}
