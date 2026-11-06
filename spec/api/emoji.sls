//// Custom emoji (`emoji.*`).
module slackline/api/emoji

method emoji.list {
  response {
    /// Custom emoji names mapped to image URLs. Aliases have values of the
    /// form `alias:<other emoji name>`.
    emoji: Dict(String)?
    /// Unicode emoji categories, when `include_categories` is `true`. The
    /// docs do not describe its shape.
    categories: Value?
  }
}
