//// Slack Web API methods for the OAuth installation flow and token rotation.
module slackline/api/oauth

/// The workspace an app was installed on. `null` for org-level installations.
record OAuthTeam {
  /// The workspace ID.
  id: String
  /// The workspace name.
  name: String?
}

/// The Enterprise organization an app was installed on, if any.
record OAuthEnterprise {
  /// The Enterprise organization ID.
  id: String
  /// The Enterprise organization name.
  name: String?
}

/// The user who authorized the app, with their user token when user scopes were granted.
record OAuthAuthedUser {
  /// The user ID.
  id: String
  /// Comma-separated user scopes granted.
  scope: String?
  /// The user token.
  access_token: String?
  /// The token type, `user`.
  token_type: String?
  /// Seconds until `access_token` expires, when token rotation is enabled.
  expires_in: Int?
  /// The refresh token for `access_token`, when token rotation is enabled.
  refresh_token: String?
}

/// An incoming webhook created during installation with the `incoming-webhook` scope.
record OAuthIncomingWebhook {
  /// The name of the channel the user selected for messages.
  channel: String?
  /// The ID of the same channel.
  channel_id: String?
  /// A link to the webhook's configuration page.
  configuration_url: String?
  /// The incoming webhook URL.
  url: String?
}

/// A token response from `oauth.v2.access`, `oauth.v2.exchange` and `oauth.v2.user.access`.
record OAuthV2AccessResponse {
  /// The bot token (or the user token, for `oauth.v2.user.access`).
  access_token: String?
  /// The type of `access_token`: `bot` or `user`.
  token_type: String?
  /// Comma-separated scopes granted to `access_token`.
  scope: String?
  /// The bot user ID.
  bot_user_id: String?
  /// The app ID.
  app_id: String?
  /// Seconds until `access_token` expires, when token rotation is enabled.
  expires_in: Int?
  /// The refresh token for `access_token`, when token rotation is enabled.
  refresh_token: String?
  /// The workspace. `null` for org-level installations.
  team: OAuthTeam?
  /// The Enterprise organization, or `null`.
  enterprise: OAuthEnterprise?
  /// Whether the app was installed on an entire organization.
  is_enterprise_install: Bool?
  /// The installing user and their user token.
  authed_user: OAuthAuthedUser?
  /// The incoming webhook, when the `incoming-webhook` scope was granted.
  incoming_webhook: OAuthIncomingWebhook?
  /// An OpenID Connect ID token, from `oauth.v2.user.access` with the `openid` scope.
  id_token: String?
  /// A warning such as `slackbot_mcp_unavailable`. Installation still succeeded.
  warning: String?
  response_metadata: ResponseMetadata?
}

/// The bot user and token from a legacy `oauth.access` request for the `bot` scope.
record OAuthLegacyBot {
  /// The bot user ID.
  bot_user_id: String?
  /// The bot token.
  bot_access_token: String?
}

/// A user from a legacy workspace app `oauth.access` response.
record OAuthWorkspaceAppUser {
  /// The user ID.
  user_id: String?
  /// The ID of the user's App Home conversation.
  app_home: String?
}

method oauth.access unauthenticated {
  response {
    /// The access token.
    access_token: String?
    /// The token type. `app` for legacy workspace apps.
    token_type: String?
    /// Comma-separated scopes granted.
    scope: String?
    /// The ID of the authorizing user.
    user_id: String?
    /// The workspace name.
    team_name: String?
    /// The workspace ID.
    team_id: String?
    /// The Enterprise organization ID, or `null`.
    enterprise_id: String?
    /// The incoming webhook, when the `incoming-webhook` scope was granted.
    incoming_webhook: OAuthIncomingWebhook?
    /// The bot user and token, when the `bot` scope was granted.
    bot: OAuthLegacyBot?
    /// The app ID, for legacy workspace apps.
    app_id: String?
    /// The app's user ID, for legacy workspace apps.
    app_user_id: String?
    /// The authorizing user, for legacy workspace apps.
    authorizing_user: OAuthWorkspaceAppUser?
    /// The installing user, for legacy workspace apps.
    installer_user: OAuthWorkspaceAppUser?
    /// Granted scopes by context (`app_home`, `team`, `channel`, ...), for legacy workspace apps.
    scopes: Dict(List(String))?
  }
}

method oauth.v2.access unauthenticated {
  args {
    grant_type: GrantType
  }
  response OAuthV2AccessResponse
}

method oauth.v2.beginShortTokenRotation {
  response {
    /// The new token. It is not active until the rotation is completed.
    new_token: String
  }
}

method oauth.v2.completeShortTokenRotation {
  response {
    /// The now active token. The original token is invalidated.
    token: String
  }
}

method oauth.v2.exchange {
  response OAuthV2AccessResponse
}

method oauth.v2.user.access unauthenticated {
  args {
    grant_type: GrantType
  }
  response OAuthV2AccessResponse
}

