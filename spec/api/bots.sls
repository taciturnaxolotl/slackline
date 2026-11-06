//// Slack Web API methods for bot users.
module slackline/api/bots

method bots.info {
  args {
    /// Bot user to get info on, such as the `bot_id` from a `bot_message` event.
    bot: String!
  }
  response {
    /// The bot.
    bot: Bot?
  }
}
