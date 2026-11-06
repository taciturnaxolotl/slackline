import gleam/int

/// The value of a `UsergroupCount` as an integer, or `Error(Nil)` when Slack
/// sent a string that is not a number.
pub fn usergroup_count_to_int(count: UsergroupCount) -> Result(Int, Nil) {
  case count {
    UsergroupCountInt(value) -> Ok(value)
    UsergroupCountString(value) -> int.parse(value)
  }
}
