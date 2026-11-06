import gleam/dict
import gleam/json
import gleam/option.{None, Some}
import slackline/manifest

/// The full JSON example from the app manifest reference.
pub fn reference_example_test() {
  let assert Ok(m) =
    json.parse(
      "{\"_metadata\": {\"major_version\": 2, \"minor_version\": 1}, \"display_information\": {\"name\": \"The Very Fantastic Name of Your App\", \"long_description\": \"A very long description. The minimum length is 174 characters and the maximum length is 4,000 characters. The app manifest in App Settings throws an error if it is less than 174 characters.\", \"description\": \"A shorter description.\", \"background_color\": \"#0000AA\"}, \"settings\": {\"allowed_ip_address_ranges\": [\"123.123.123.123\", \"124.124.124.124\"], \"org_deploy_enabled\": false, \"socket_mode_enabled\": false, \"token_rotation_enabled\": false, \"event_subscriptions\": {\"request_url\": \"https://example.com/slack/the_Events_API_request_URL\", \"bot_events\": [\"app_home_opened\", \"message_metadata_deleted\", \"link_shared\", \"assistant_thread_started\", \"message.im\", \"function_executed\"], \"user_events\": [\"reaction_added\"], \"metadata_subscriptions\": [{\"app_id\": \"A123ABC456\", \"event_type\": \"star_added\"}, {\"app_id\": \"A123ABC456\", \"event_type\": \"star_removed\"}, {\"app_id\": \"*\", \"event_type\": \"task_added\"}]}, \"incoming_webhooks\": {\"incoming_webhooks_enabled\": false}, \"interactivity\": {\"is_enabled\": true, \"request_url\": \"https://example.com/slack/message_action\", \"message_menu_options_url\": \"https://example.com/slack/message_menu_options\"}, \"is_hosted\": false, \"function_runtime\": \"remote\"}, \"features\": {\"app_home\": {\"home_tab_enabled\": false, \"messages_tab_enabled\": false, \"messages_tab_read_only_enabled\": false}, \"assistant_view\": {\"assistant_description\": \"this is a string description of the app assistant. What does your assistant do?\", \"suggested_prompts\": [{\"title\": \"User help\", \"message\": \"How do I use this awesome app?\"}]}, \"bot_user\": {\"display_name\": \"Your Amazingly Helpful Bot\", \"always_online\": false}, \"shortcuts\": [{\"name\": \"Use your app\", \"callback_id\": \"a-really-cool-callback_id\", \"description\": \"Awesome and Helpful App\", \"type\": \"message\"}], \"slash_commands\": [{\"command\": \"/z\", \"description\": \"You see a mailbox in the field.\", \"should_escape\": false, \"usage_hint\": \"/zork open mailbox\", \"url\": \"https://example.com/slack/slash/please\"}], \"unfurl_domains\": [\"example.com\"]}, \"oauth_config\": {\"scopes\": {\"bot\": [\"commands\", \"chat:write\", \"chat:write.public\", \"metadata.message:read\", \"links:read\", \"assistant:write\", \"im:history\", \"reactions:write\"], \"user\": [\"channels:history\", \"reactions:read\", \"reactions:write\"]}, \"redirect_urls\": [\"https://example.com/slack/auth\"], \"token_management_enabled\": true}, \"functions\": {\"a_callback_id\": {\"title\": \"A Callback ID\", \"description\": \"This is an example callback id! Huzzah!\", \"input_parameters\": {\"properties\": {\"user_id\": {\"type\": \"string\", \"title\": \"User\", \"description\": \"Message recipient\", \"is_required\": true, \"hint\": \"Select a user in the workspace\", \"name\": \"user_id\"}}, \"required\": [\"user_id\"]}, \"output_parameters\": {\"properties\": {\"user_id\": {\"type\": \"string\", \"title\": \"User\", \"description\": \"User that completed the function\", \"is_required\": true, \"name\": \"user_id\"}}, \"required\": [\"user_id\"]}}}, \"workflows\": {\"cool_name_for_a_workflow\": {\"title\": \"Name your workflow\", \"description\": \"Describe your workflow here\", \"input_parameters\": {\"properties\": {\"channel_id_for_workflow\": {\"type\": \"slack#/types/channel_id\"}, \"first_property\": {\"type\": \"string\"}, \"second_property\": {\"type\": \"string\"}, \"third_property\": {\"type\": \"string\"}}, \"required\": [\"channel_id_for_workflow\", \"first_property\", \"second_property\", \"third_property\"]}, \"steps\": [{\"id\": \"0\", \"function_id\": \"slack#/functions/send_message\", \"inputs\": {\"channel_id\": \"{{inputs.channel_id_for_workflow}}\", \"message\": \"This is the message you'll send to your users :yay: You can put your {{inputs.first_property}} {{inputs.second_property}}, {{inputs.third_property}} here!\", \"interactive_blocks\": [{\"type\": \"actions\", \"elements\": [{\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Share\"}, \"action_id\": \"share\"}]}]}}, {\"id\": \"1\", \"function_id\": \"slack#/functions/open_form\", \"inputs\": {\"title\": \"Title for your 2nd step\", \"interactivity\": \"{{steps.0.interactivity}}\", \"submit_label\": \"Share\", \"fields\": {\"elements\": [{\"name\": \"announcement_channel\", \"title\": \"Select an announcements channel\", \"type\": \"slack#/types/channel_id\"}], \"required\": [\"announcement_channel\"]}}}, {\"id\": \"2\", \"function_id\": \"slack#/functions/send_message\", \"inputs\": {\"channel_id\": \"{{steps.1.fields.announcement_channel}}\", \"message\": \"The properties you defined in your inputs section can also be used in the steps {{inputs.second_property}}  :rocket:\\n```{{inputs.channel_id_for_workflow}}```\"}}, {\"id\": \"3\", \"function_id\": \"slack#/functions/add_reaction\", \"inputs\": {\"message_context\": \"{{steps.2.message_context}}\", \"emoji\": \"tada\"}}], \"suggested_triggers\": {\"send_a_message\": {\"name\": \"Send a message\", \"description\": \"Sends a message for you\", \"type\": \"string\", \"inputs\": {\"channel_id\": {\"value\": \"channel_id_for_workflow\"}, \"other_customizable_param\": {\"value\": \"this is cool right?\"}}}}}}, \"outgoing_domains\": [\"anoutgoing.domain\", \"anotheroutgoing.domain\"], \"types\": {\"your_shiny_custom_type\": {\"title\": \"your_shiny_custom_type\", \"type\": \"object\", \"description\": \"Describe what very cool stuff this type does in your app\", \"is_required\": false, \"is_hidden\": false, \"hint\": \"give a hint for the future folks who use this\"}}}",
      manifest.manifest_decoder(),
    )
  let assert "The Very Fantastic Name of Your App" = m.display_information.name
  let assert Some(manifest.ManifestMetadata(
    major_version: Some(2),
    minor_version: Some(1),
  )) = m.metadata
  let assert Some(manifest.Settings(
    function_runtime: Some(manifest.RemoteRuntime),
    ..,
  )) = m.settings
  let assert Some(manifest.Features(
    shortcuts: Some([
      manifest.ManifestShortcut(shortcut_type: manifest.MessageShortcut, ..),
    ]),
    ..,
  )) = m.features
  let assert Some(functions) = m.functions
  let assert Ok(manifest.ManifestFunction(
    input_parameters: manifest.ParametersV2(manifest.ParameterProperties(
      required: Some(["user_id"]),
      ..,
    )),
    ..,
  )) = dict.get(functions, "a_callback_id")
  let assert Some(workflows) = m.workflows
  let assert Ok(manifest.ManifestWorkflow(
    steps: [_, _, _, _],
    suggested_triggers: Some(manifest.TriggersByName(_)),
    ..,
  )) = dict.get(workflows, "cool_name_for_a_workflow")
  // Round trip through the encoder.
  let assert Ok(again) =
    json.parse(
      json.to_string(manifest.manifest_to_json(m)),
      manifest.manifest_decoder(),
    )
  let assert True = again == m
}

/// The v1 parameter shape (a map of parameters with `is_required`).
pub fn v1_parameters_test() {
  let assert Ok(manifest.ParametersV1(params)) =
    json.parse(
      "{\"user_id\": {\"type\": \"slack#/reference/objects/user-object_id\", \"title\": \"User\", \"is_required\": true, \"name\": \"user_id\"}}",
      manifest.parameter_schema_decoder(),
    )
  let assert Ok(manifest.Parameter(is_required: Some(True), ..)) =
    dict.get(params, "user_id")
}

pub fn new_test() {
  let m =
    manifest.Manifest(
      ..manifest.new(name: "My app"),
      features: Some(
        manifest.Features(
          ..manifest.features(),
          bot_user: Some(manifest.bot_user("my-bot")),
          slash_commands: Some([
            manifest.slash_command(command: "/hi", description: "Say hi"),
          ]),
        ),
      ),
      oauth_config: Some(manifest.bot_scopes(["commands"])),
    )
  let assert "{\"display_information\":{\"name\":\"My app\"},\"features\":{\"bot_user\":{\"display_name\":\"my-bot\"},\"slash_commands\":[{\"command\":\"/hi\",\"description\":\"Say hi\"}]},\"oauth_config\":{\"scopes\":{\"bot\":[\"commands\"]}}}" =
    json.to_string(manifest.manifest_to_json(m))
  let assert None = m.settings
}
