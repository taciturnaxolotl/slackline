//// Validate Block Kit payloads (`blocks.*`).
module slackline/api/blocks

/// A message payload to validate.
record ValidatedMessage {
  /// The message text.
  text: String?
  /// The message blocks.
  blocks: List(Block)?
  /// The message attachments.
  attachments: List(Attachment)?
}

method blocks.validate {
  args {
    /// A list of blocks to validate. Provide exactly one of `blocks`, `view`,
    /// or `message`.
    blocks: List(Block)
    /// A message payload to validate. Provide exactly one of `blocks`,
    /// `view`, or `message`.
    message: ValidatedMessage
    /// A view payload to validate. Provide exactly one of `blocks`, `view`,
    /// or `message`.
    view: View
  }
  response Nil
}
