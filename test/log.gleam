//// A log tests use to see which handlers and continuations ran.

@external(erlang, "slackline_test_ffi", "record")
@external(javascript, "./slackline_test_ffi.mjs", "record")
pub fn record(entry: String) -> Nil

@external(erlang, "slackline_test_ffi", "recorded")
@external(javascript, "./slackline_test_ffi.mjs", "recorded")
pub fn recorded() -> List(String)
