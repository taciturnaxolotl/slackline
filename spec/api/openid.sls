//// Slack Web API methods for Sign in with Slack (OpenID Connect).
module slackline/api/openid

method openid.connect.token unauthenticated {
  args {
    grant_type: GrantType
  }
  response {
    /// The user token.
    access_token: String?
    /// The token type, `Bearer`.
    token_type: String?
    /// A JSON Web Token with the user's identity claims.
    id_token: String?
    /// The refresh token, when token rotation is enabled.
    refresh_token: String?
    /// Seconds until `access_token` expires, when token rotation is enabled.
    expires_in: Int?
  }
}

method openid.connect.userInfo {
  response {
    /// The subject: the user's Slack ID.
    sub: String?
    "https://slack.com/user_id" as user_id: String?
    "https://slack.com/team_id" as team_id: String?
    email: String?
    email_verified: Bool?
    /// Unix timestamp of when the email was verified.
    date_email_verified: Int?
    name: String?
    picture: String?
    given_name: String?
    family_name: String?
    locale: String?
    "https://slack.com/team_name" as team_name: String?
    "https://slack.com/team_domain" as team_domain: String?
    "https://slack.com/user_image_24" as user_image_24: String?
    "https://slack.com/user_image_32" as user_image_32: String?
    "https://slack.com/user_image_48" as user_image_48: String?
    "https://slack.com/user_image_72" as user_image_72: String?
    "https://slack.com/user_image_192" as user_image_192: String?
    "https://slack.com/user_image_512" as user_image_512: String?
    "https://slack.com/user_image_1024" as user_image_1024: String?
    "https://slack.com/team_image_34" as team_image_34: String?
    "https://slack.com/team_image_44" as team_image_44: String?
    "https://slack.com/team_image_68" as team_image_68: String?
    "https://slack.com/team_image_88" as team_image_88: String?
    "https://slack.com/team_image_102" as team_image_102: String?
    "https://slack.com/team_image_132" as team_image_132: String?
    "https://slack.com/team_image_230" as team_image_230: String?
    /// Whether the team image is a default one rather than an uploaded one.
    "https://slack.com/team_image_default" as team_image_default: Bool?
  }
}

