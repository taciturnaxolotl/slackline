//// App manifests: the json configuration sent to `apps.manifest.create`
//// and `apps.manifest.update`, and returned by `apps.manifest.export`.
////
//// See <https://docs.slack.dev/reference/app-manifest>. Use `new(name:)`
//// for a minimal manifest and fill in the rest with record updates.
module slackline/manifest

/// An app manifest.
record Manifest {
  /// Settings that describe the manifest itself.
  "_metadata" as metadata: ManifestMetadata?
  /// Settings that describe parts of the app's appearance within Slack.
  display_information: DisplayInformation
  /// Information listed in the Slack Marketplace.
  app_directory: AppDirectory?
  /// The **Settings** section of the app's configuration pages.
  settings: Settings?
  /// The **Features** section of the app's configuration pages.
  features: Features?
  /// OAuth configuration.
  oauth_config: OauthConfig?
  /// Functions (workflow steps) keyed by `callback_id`.
  functions: Dict(ManifestFunction)?
  /// Workflows keyed by `callback_id`.
  workflows: Dict(ManifestWorkflow)?
  /// Datastores keyed by name.
  datastores: Dict(Datastore)?
  /// Accepted egress domains for an app with `function_runtime` = `slack`. Max 10.
  outgoing_domains: List(String)?
  /// Custom types keyed by name. Max 50.
  types: Dict(CustomType)?
  /// Message metadata events the app can send, keyed by `event_type`. Max 50.
  events: Dict(MetadataEventSchema)?
  /// OAuth providers used by the app. The reference lists the fields of one
  /// provider (see `ExternalAuthProvider`) without saying how providers are
  /// keyed, so the whole group is kept as json.
  external_auth_providers: Value?
  /// Compliance certifications for GovSlack.
  compliance: Compliance?
  /// MCP servers used by the app, keyed by server key. Max 20.
  mcp_servers: Dict(McpServer)?
}

/// `_metadata`: the manifest schema version to target.
record ManifestMetadata {
  /// The major version of the manifest schema.
  major_version: Int?
  /// The minor version of the manifest schema.
  minor_version: Int?
}

/// `display_information`.
record DisplayInformation {
  /// The name of the app. Maximum length is 35 characters.
  name: String
  /// A short description of the app. Maximum length is 140 characters.
  description: String?
  /// A longer description of the app, 175 to 4000 characters.
  long_description: String?
  /// A hex color value (including `#`), 3 or 6 digits.
  background_color: String?
}

/// `app_directory`: Slack Marketplace listing information.
record AppDirectory {
  /// Marketplace categories. At most 3, each up to 255 characters.
  app_directory_categories: List(String)?
  /// Whether the app should use direct install.
  use_direct_install: Bool?
  /// The URL of the install page. Up to 255 characters.
  direct_install_url: String?
  /// The URL of the installation landing page. Up to 255 characters.
  installation_landing_page: String
  /// A link to the app's privacy policy. Up to 500 characters.
  privacy_policy_url: String
  /// A link to the app's support page. Up to 350 characters.
  support_url: String
  /// An email address to contact the app's support. Up to 100 characters.
  support_email: String
  /// The languages supported by the app.
  supported_languages: List(String)
  /// Pricing information. Up to 30 characters.
  pricing: String
}

# ---------------------------------------------------------------- settings

/// `settings`.
record Settings {
  /// IP addresses allowed to call the API with the app's tokens. Max 10.
  allowed_ip_address_ranges: List(String)?
  /// Whether app-level token rotation is enabled.
  app_level_token_rotation_enabled: Bool?
  /// Events API configuration.
  event_subscriptions: EventSubscriptions?
  /// Incoming webhooks configuration.
  incoming_webhooks: IncomingWebhooks?
  /// Interactivity configuration.
  interactivity: InteractivitySettings?
  /// Whether organization-wide deployment is enabled. Must be `true` when the
  /// manifest includes functions, workflows, datastores, types, outgoing
  /// domains or events.
  org_deploy_enabled: Bool?
  /// Whether Socket Mode is enabled.
  socket_mode_enabled: Bool?
  /// Whether token rotation is enabled.
  token_rotation_enabled: Bool?
  /// Whether the app is hosted by Slack.
  is_hosted: Bool?
  /// Whether MCP is enabled for the app.
  is_mcp_enabled: Bool?
  /// SIWS links configuration.
  siws_links: SiwsLinks?
  /// The runtime of the app's functions. Required when using `functions`.
  function_runtime: FunctionRuntime?
}

/// `settings.event_subscriptions`.
record EventSubscriptions {
  /// The Events API request URL.
  request_url: String?
  /// Event types the app subscribes to. Max 100.
  bot_events: List(String)?
  /// Event types the app subscribes to on behalf of authorized users. Max 100.
  user_events: List(String)?
  /// Message metadata subscriptions.
  metadata_subscriptions: List(MetadataSubscription)?
}

/// A message metadata subscription.
record MetadataSubscription {
  /// The app whose metadata to receive, or `*` for every app.
  app_id: String
  /// The metadata `event_type`.
  event_type: String
}

/// `settings.incoming_webhooks`.
record IncomingWebhooks {
  incoming_webhooks_enabled: Bool
}

/// `settings.interactivity`.
record InteractivitySettings {
  /// Whether interactivity features are enabled.
  is_enabled: Bool
  /// The interactive Request URL.
  request_url: String?
  /// The interactive Options Load URL.
  message_menu_options_url: String?
}

/// `settings.siws_links`.
record SiwsLinks {
  /// An `https://` URI.
  initiate_uri: String?
}

/// `settings.function_runtime`.
enum FunctionRuntime {
  /// A self-hosted app.
  remote as RemoteRuntime
  /// An app built with the Deno Slack SDK, hosted by Slack.
  slack as SlackRuntime
  .. UnknownFunctionRuntime
}

# ---------------------------------------------------------------- features

/// `features`.
record Features {
  /// App Home configuration.
  app_home: AppHome?
  /// The Agent messaging experience. New apps can only use this one.
  agent_view: AgentView?
  /// The older Assistant messaging experience. Slack plans to deprecate it.
  assistant_view: AssistantView?
  /// Bot user configuration.
  bot_user: BotUser?
  /// Code channels configuration.
  code_channels: CodeChannels?
  /// Rich previews (Work Objects) configuration.
  rich_previews: RichPreviews?
  /// Enterprise search configuration.
  search: SearchSettings?
  /// Shortcuts. Max 10.
  shortcuts: List(ManifestShortcut)?
  /// Slash commands. Max 50.
  slash_commands: List(ManifestSlashCommand)?
  /// Unfurl domains. Max 5.
  unfurl_domains: List(String)?
  /// Legacy, deprecated: workflow steps from apps. Max 10.
  workflow_steps: List(LegacyWorkflowStep)?
}

/// `features.app_home`.
record AppHome {
  /// Whether the Home tab is enabled.
  home_tab_enabled: Bool?
  /// Whether the Messages tab is enabled.
  messages_tab_enabled: Bool?
  /// Whether users can only read (not send) messages in the Messages tab.
  messages_tab_read_only_enabled: Bool?
}

/// `features.agent_view`.
record AgentView {
  /// A description of the agent. Maximum length is 300 characters.
  agent_description: String
  /// Actions available in the agent container.
  actions: List(ViewAction)?
  /// Hard-coded prompts for the agent container.
  suggested_prompts: List(SuggestedPrompt)?
}

/// `features.assistant_view`.
record AssistantView {
  /// A description of the app assistant.
  assistant_description: String
  /// Actions available in the assistant container.
  actions: List(ViewAction)?
  /// Hard-coded prompts for the assistant container.
  suggested_prompts: List(SuggestedPrompt)?
}

/// An action in an agent or assistant container.
record ViewAction {
  name: String
  description: String
}

/// A suggested prompt in an agent or assistant container.
record SuggestedPrompt {
  /// A short label shown for the prompt.
  title: String
  /// The message sent when the user picks the prompt.
  message: String
}

/// `features.bot_user`.
record BotUser {
  /// The bot's display name. Max 80 characters of `a-z`, `0-9`, `-`, `_` and `.`.
  display_name: String
  /// Whether the bot user always appears online.
  always_online: Bool?
}

/// `features.code_channels`.
record CodeChannels {
  /// Whether code channels are enabled.
  enabled: Bool?
  /// Where Slack delivers runtime-registered slash commands.
  slash_command_url: String?
  /// Skip the ephemeral prompt when users mention the app. Defaults to `true`.
  suppress_mention_ephemeral: Bool?
}

/// `features.rich_previews`.
record RichPreviews {
  /// Whether Work Object embeds render with the allow-same-origin sandbox token.
  allow_same_origin: Bool?
  /// Domains allowed for Work Object embeds.
  domain_allowlist: List(String)?
  /// Entity types for rich previews.
  entity_types: List(String)?
  /// Whether rich previews are enabled.
  is_active: Bool?
  /// Slug settings.
  slug: RichPreviewSlug?
}

/// `features.rich_previews.slug`.
record RichPreviewSlug {
  /// Whether a task's slug leaves out its display ID.
  hide_display_id: Bool?
}

/// `features.search`.
record SearchSettings {
  /// The `callback_id` of the function used to search for items.
  search_function_callback_id: String
  /// The `callback_id` of the function used to provide search filters.
  search_filters_function_callback_id: String?
  /// How AI interacts with the search connector.
  slackbot_metadata: SlackbotMetadata?
}

/// `features.search.slackbot_metadata`.
record SlackbotMetadata {
  description: String?
  /// Up to 5 examples.
  examples: List(String)?
  example_query: String?
}

/// A shortcut in `features.shortcuts`.
record ManifestShortcut {
  /// The name of the shortcut.
  name: String
  /// The `callback_id` of the shortcut. Max 255 characters.
  callback_id: String
  /// A short description. Max 150 characters.
  description: String
  /// `message` or `global`.
  "type" as shortcut_type: ShortcutType
}

/// The kind of shortcut.
enum ShortcutType {
  message as MessageShortcut
  global as GlobalShortcut
  .. UnknownShortcutType
}

/// A slash command in `features.slash_commands`.
record ManifestSlashCommand {
  /// The command, including the leading `/`. Max 32 characters.
  command: String
  /// A description displayed to users. Max 2000 characters.
  description: String
  /// Whether channels, users and links typed with the command are escaped. Defaults to `false`.
  should_escape: Bool?
  /// The command's Request URL.
  url: String?
  /// A usage hint. Max 1000 characters.
  usage_hint: String?
}

/// Legacy, deprecated: a workflow step from apps.
record LegacyWorkflowStep {
  /// Max 50 characters.
  name: String
  /// Max 50 characters.
  callback_id: String
}

# ---------------------------------------------------------------- oauth

/// `oauth_config`.
record OauthConfig {
  /// Whether the app supports enterprise-managed authorization.
  is_enterprise_managed_auth_supported: Bool?
  /// Whether PKCE is enabled for the OAuth flow.
  pkce_enabled: Bool?
  /// OAuth redirect URLs. Max 1000.
  redirect_urls: List(String)?
  /// Permission scopes.
  scopes: OauthScopes?
  /// Whether token management is enabled.
  token_management_enabled: Bool?
}

/// `oauth_config.scopes`.
record OauthScopes {
  /// Bot scopes requested on install. Max 255.
  bot: List(String)?
  /// Optional bot scopes. `bot` must also list them.
  bot_optional: List(String)?
  /// User scopes requested on install. Max 255.
  user: List(String)?
  /// Optional user scopes. `user` must also list them.
  user_optional: List(String)?
}

# ---------------------------------------------------------------- functions & workflows

/// A function in `functions`.
record ManifestFunction {
  /// Identifies the step. Max 255 characters.
  title: String
  /// A succinct summary of what the step does.
  description: String
  /// The step's input parameters.
  input_parameters: ParameterSchema
  /// The step's output parameters.
  output_parameters: ParameterSchema
}

/// Function or workflow parameters. Manifest v2 uses `{properties, required}`.
/// v1 uses a map of parameters, each with `is_required`.
oneof ParameterSchema {
  ParametersV2(ParameterProperties)
  ParametersV1(Dict(Parameter))
}

/// Manifest v2 parameters.
record ParameterProperties {
  /// Parameters keyed by name.
  properties: Dict(Parameter)
  /// Names of required parameters.
  required: List(String)?
}

/// One function, workflow or type parameter.
record Parameter {
  /// A Slack type (`slack#/types/...`), a custom type, or a primitive like `string`.
  "type" as param_type: String
  title: String?
  description: String?
  /// v1 only: whether the parameter is required.
  is_required: Bool?
  hint: String?
  name: String?
  is_hidden: Bool?
  default: Value?
  examples: List(Value)?
  nullable: Bool?
  /// Item schema for `array` parameters.
  items: Value?
  /// Property schemas for `object` parameters.
  properties: Value?
  /// Required property names for `object` parameters.
  required: List(String)?
  /// Allowed values.
  choices: List(Value)?
}

/// A workflow in `workflows`.
record ManifestWorkflow {
  /// The workflow title.
  title: String
  /// The workflow description.
  description: String
  /// Workflow inputs.
  input_parameters: ParameterSchema?
  /// Workflow outputs.
  output_parameters: ParameterSchema?
  /// The steps of the workflow.
  steps: List(WorkflowStep)
  # The reference says an array. Its example is an object keyed by trigger name.
  /// Suggested triggers.
  suggested_triggers: SuggestedTriggers?
}

/// A step in a workflow.
record WorkflowStep {
  id: String
  /// The function to run, for example `slack#/functions/send_message`.
  function_id: String
  /// Inputs for the function, often with `{{...}}` template expressions.
  inputs: Dict(Value)
  /// v2 manifests only: `function`, `switch` or `conditional`.
  "type" as step_type: WorkflowStepType?
}

/// The kind of workflow step.
enum WorkflowStepType {
  function as FunctionStep
  switch as SwitchStep
  conditional as ConditionalStep
  .. UnknownWorkflowStepType
}

/// `workflows.suggested_triggers`, as an object keyed by trigger name or as a list.
oneof SuggestedTriggers {
  TriggersByName(Dict(SuggestedTrigger))
  TriggerList(List(SuggestedTrigger))
}

/// A suggested trigger for a workflow.
record SuggestedTrigger {
  name: String
  description: String?
  "type" as trigger_type: String
  /// Trigger inputs keyed by workflow input name, each a `{"value": ...}` object.
  inputs: Dict(Value)?
}

# ---------------------------------------------------------------- datastores & types

/// A datastore in `datastores`.
record Datastore {
  /// The attribute used as the primary key.
  primary_key: String
  /// The datastore's attributes, keyed by name.
  attributes: Dict(DatastoreAttribute)
  /// The attribute holding the time-to-live of an item.
  time_to_live_attribute: String?
}

/// A datastore attribute.
record DatastoreAttribute {
  /// The object type of the attribute.
  "type" as attribute_type: String
  /// For arrays: a `type` and `properties`.
  items: Value?
  /// For objects: the properties.
  properties: Value?
}

/// A custom type in `types`.
record CustomType {
  "type" as base_type: String
  title: String?
  description: String?
  is_required: Bool?
  is_hidden: Bool?
  hint: String?
  /// For `object` types: property schemas.
  properties: Value?
  /// For `object` types: required property names.
  required: List(String)?
}

# ---------------------------------------------------------------- metadata events

/// A message metadata event declaration: either an `object` schema or a `reference`.
record MetadataEventSchema {
  object: EventObjectSchema?
  reference: EventReferenceSchema?
}

/// `events.<event_type>.object`.
record EventObjectSchema {
  /// The reference says "Object containing three properties: string type,
  /// object enum, and string title", so this is kept as json.
  "type" as object_type: Value
  title: String?
  description: String?
  default: Value?
  examples: List(Value)?
  required: List(String)?
  "additionalProperties" as additional_properties: Bool?
  nullable: Bool?
  /// Property schemas, max 50.
  properties: Dict(Value)?
  is_required: Bool?
  is_hidden: Bool?
  hint: String?
  choices: List(EventChoice)?
  render_condition: RenderCondition?
}

/// An enum choice in an event schema.
record EventChoice {
  /// A string, number or object.
  value: Value
  title: String
  description: String?
  is_hidden: Bool?
  hint: String?
}

/// When a field should be rendered.
record RenderCondition {
  /// A logical operator acting on the conditions.
  operator: String
  is_required: Bool?
  conditions: List(Value)
}

/// `events.<event_type>.reference`.
record EventReferenceSchema {
  /// A user-defined type reference, `^(?!slack)(\w*#)/(\w+)/(\w+)$`.
  "type" as reference_type: String
  title: String?
  description: String?
  default: Value?
  examples: List(Value)?
  nullable: Bool?
  is_required: Bool?
  is_hidden: Bool?
  hint: String?
}

# ---------------------------------------------------------------- external auth, compliance, mcp

/// One external OAuth provider.
record ExternalAuthProvider {
  /// `CUSTOM` or `SLACK_PROVIDED`.
  provider_type: ProviderType
  options: ExternalAuthOptions
}

/// The kind of external auth provider.
enum ProviderType {
  "CUSTOM" as CustomProvider
  "SLACK_PROVIDED" as SlackProvidedProvider
  .. UnknownProviderType
}

/// External auth provider options. `SLACK_PROVIDED` only uses `client_id` and `scope`.
record ExternalAuthOptions {
  /// Max 1024 characters.
  client_id: String
  /// Scopes to request.
  scope: List(String)
  /// Required for `CUSTOM`. Max 255 characters.
  provider_name: String?
  /// Required for `CUSTOM`. An `https://` URL.
  authorization_url: String?
  /// Required for `CUSTOM`. An `https://` URL.
  token_url: String?
  /// Extra query parameters for the authorization URL.
  authorization_url_extras: Dict(String)?
  /// Required for `CUSTOM`.
  identity_config: IdentityConfig?
  /// Whether this provider uses PKCE.
  use_pkce: Bool?
  token_url_config: TokenUrlConfig?
}

/// How to identify the account behind an external token.
record IdentityConfig {
  /// An `https://` URL, 5 to 255 characters.
  url: String
  /// The account identifier, 1 to 255 characters.
  account_identifier: String
  headers: Dict(String)?
  body: Dict(Value)?
  /// `GET` or `POST`.
  http_method_type: String?
}

/// `token_url_config`.
record TokenUrlConfig {
  use_basic_auth_scheme: Bool?
}

/// `compliance`: GovSlack certifications.
record Compliance {
  fedramp_authorization: String?
  dod_srg_ilx: String?
  itar_compliant: String?
}

/// An MCP server in `mcp_servers`.
record McpServer {
  /// The server URL. Max 500 characters.
  url: String
  /// The key of an external auth provider to authenticate with.
  auth_provider_key: String?
  auth_type: McpAuthType?
  /// HTTP headers to send to the server.
  headers: Dict(String)?
  /// An emoji such as `:robot_face:`.
  icon_emoji: String?
}

/// How the app authenticates to an MCP server.
enum McpAuthType {
  dynamic_client_registration
  no_auth
  manual_auth
  slack_identity_auth
  .. UnknownMcpAuthType
}
