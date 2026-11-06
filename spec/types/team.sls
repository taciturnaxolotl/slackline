//// Workspaces (teams), Enterprise organizations and team profiles.
module slackline/team

/// A workspace or Enterprise organization.
record Team {
  /// The workspace (`T...`) or organization (`E...`) ID.
  id: String
  name: String?
  /// The workspace's Slack subdomain.
  domain: String?
  email_domain: String?
  icon: TeamIcon?
  enterprise_id: String?
  enterprise_name: String?
  /// Advisory Slackbot availability, only with `include_slackbot_availability`.
  slackbot_availability: SlackbotAvailability?
  avatar_base_url: String?
  is_verified: Bool?
  date_created: Int?
  requires_sponsorship: Bool?
  /// Whether the team is migrating between organizations.
  is_migrating: Bool?
}

/// A workspace icon in several sizes.
record TeamIcon {
  image_34: String?
  image_44: String?
  image_68: String?
  image_88: String?
  image_102: String?
  image_132: String?
  image_230: String?
  image_original: String?
  /// `true` when the workspace uses the default icon.
  image_default: Bool?
}

/// Whether Slackbot is available in a workspace. Advisory only.
enum SlackbotAvailability {
  /// The workspace or organization normally has access to Slackbot.
  available
  /// An admin has limited Slackbot access to certain people or workspaces.
  restricted
  /// Unavailable because of the plan, an admin setting or another restriction.
  unavailable
  /// Slack could not determine availability.
  unknown
  .. UnknownSlackbotAvailability
}

/// The format a custom profile field supports.
enum TeamProfileFieldType {
  "date" as DateField
  "link" as LinkField
  "long_text" as LongTextField
  "options_list" as OptionsListField
  "tags" as TagsField
  "text" as TextField
  "user" as UserField
  # Not in the docs, seen in a live `team.profile.get`.
  "file" as FileField
  .. UnknownTeamProfileFieldType
}

/// Options on a custom profile field.
record TeamProfileFieldOptions {
  /// If true, the field is updated through the SCIM API rather than `users.profile.set`.
  is_scim: Bool?
  /// Whether the field is protected.
  is_protected: Bool?
}

/// A profile field definition.
record TeamProfileField {
  /// The field ID.
  id: String
  /// The placement of the field on the profile.
  ordering: Int?
  /// The name of the field.
  field_name: String?
  /// The text shown for the field.
  label: String?
  /// Additional context to help the user fill in the field.
  hint: String?
  /// The format the field supports.
  type: TeamProfileFieldType?
  /// The values the user can choose from, for `options_list` fields.
  possible_values: List(String)?
  /// SCIM and protection options.
  options: TeamProfileFieldOptions?
  /// Whether the field is hidden.
  is_hidden: Bool?
  /// The ID of the section the field is in.
  section_id: String?
}

/// A profile section definition.
record TeamProfileSection {
  /// The section ID.
  id: String
  /// The workspace ID.
  team_id: String?
  /// The type of content in the section. Users can only create `custom` sections.
  section_type: String?
  /// The text shown for the section.
  label: String?
  /// The placement of the section on the profile.
  order: Int?
  /// Whether the section is hidden.
  is_hidden: Bool?
}

/// The profile fields and sections defined for a workspace
/// (`team.profile.get`).
record TeamProfile {
  /// The profile fields.
  fields: List(TeamProfileField)?
  /// The profile sections.
  sections: List(TeamProfileSection)?
}
