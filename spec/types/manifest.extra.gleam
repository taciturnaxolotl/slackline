/// A minimal manifest with only a display name.
pub fn new(name name: String) -> Manifest {
  Manifest(
    metadata: None,
    display_information: DisplayInformation(
      name:,
      description: None,
      long_description: None,
      background_color: None,
    ),
    app_directory: None,
    settings: None,
    features: None,
    oauth_config: None,
    functions: None,
    workflows: None,
    datastores: None,
    outgoing_domains: None,
    types: None,
    events: None,
    external_auth_providers: None,
    compliance: None,
    mcp_servers: None,
  )
}

/// A slash command entry for `features.slash_commands`.
pub fn slash_command(
  command command: String,
  description description: String,
) -> ManifestSlashCommand {
  ManifestSlashCommand(
    command:,
    description:,
    should_escape: None,
    url: None,
    usage_hint: None,
  )
}

/// A bot user entry for `features.bot_user`.
pub fn bot_user(display_name: String) -> BotUser {
  BotUser(display_name:, always_online: None)
}

/// An empty `features` group.
pub fn features() -> Features {
  Features(
    app_home: None,
    agent_view: None,
    assistant_view: None,
    bot_user: None,
    code_channels: None,
    rich_previews: None,
    search: None,
    shortcuts: None,
    slash_commands: None,
    unfurl_domains: None,
    workflow_steps: None,
  )
}

/// An `oauth_config` that requests the given bot scopes.
pub fn bot_scopes(scopes: List(String)) -> OauthConfig {
  OauthConfig(
    is_enterprise_managed_auth_supported: None,
    pkce_enabled: None,
    redirect_urls: None,
    scopes: Some(OauthScopes(
      bot: Some(scopes),
      bot_optional: None,
      user: None,
      user_optional: None,
    )),
    token_management_enabled: None,
  )
}
