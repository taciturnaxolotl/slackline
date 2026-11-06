import slackline_codegen/generate/names

pub fn snake_keeps_oauth_as_one_word_test() {
  let assert "oauth_v2_access_response" = names.snake("OAuthV2AccessResponse")
  let assert "oauth_team" = names.snake("OAuthTeam")
  let assert "scheduled_messages" = names.snake("scheduledMessages")
  let assert "url_text_input" = names.snake("URLTextInput")
}
