//// Bot users, as returned by `bots.info` and the `bot_added` and
//// `bot_changed` events.
module slackline/bot

/// A bot.
record Bot {
  /// The bot ID (`B...`).
  id: String
  /// Whether the bot has been removed.
  deleted: Bool?
  name: String?
  /// Unix timestamp of the last update.
  updated: Int?
  /// The app the bot belongs to.
  app_id: String?
  /// The bot user's user ID.
  user_id: String?
  icons: BotIcons?
}

/// A bot's icon in several sizes.
record BotIcons {
  image_36: String?
  image_48: String?
  image_72: String?
}
