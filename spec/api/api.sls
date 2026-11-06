//// Slack Web API methods for testing API calling code.
module slackline/api/api

method api.test {
  response {
    /// Every argument passed to the call, echoed back.
    args: Dict(Value)?
  }
}
