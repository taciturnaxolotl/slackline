//// Both tools run from the slackline project root.

/// Moves to the slackline project root when run from `codegen/`.
@external(erlang, "slackline_codegen_ffi", "enter_project_root")
pub fn enter() -> Nil
