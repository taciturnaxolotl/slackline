//// Slack Web API methods for app configuration tokens.
module slackline/api/tooling

method tooling.tokens.rotate unauthenticated {
  response {
    /// The new app configuration access token.
    token: String
    /// The new refresh token.
    refresh_token: String
    /// The workspace the token belongs to.
    team_id: String?
    /// The user the token belongs to.
    user_id: String?
    /// Unix timestamp of when the token was issued.
    iat: Int?
    /// Unix timestamp of when the token expires.
    exp: Int?
  }
}
