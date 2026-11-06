//// User groups. See <https://docs.slack.dev/reference/objects/usergroup-object>.
module slackline/usergroup

/// A group of users that can be mentioned together.
record Usergroup {
  /// The ID of the usergroup.
  id: String
  /// The ID of the team.
  team_id: String?
  /// Indicates if the object is a user group.
  is_usergroup: Bool?
  /// Whether this is a subteam.
  is_subteam: Bool?
  /// The friendly name of the group.
  name: String?
  /// Explains the purpose of the group.
  description: String?
  /// The value used to mention the group, without a leading `@`.
  handle: String?
  /// Whether the user group is external.
  is_external: Bool?
  /// Unix timestamp of when the group was created.
  date_create: Int?
  /// Unix timestamp of when the group was last updated.
  date_update: Int?
  /// Non-zero for disabled groups.
  date_delete: Int?
  /// `admins` (or `admin`) for Workspace Admins, `owner` for Workspace Owners,
  /// absent or `null` for a custom group.
  auto_type: UsergroupAutoType?
  /// User ID of the member who created the group.
  created_by: String?
  /// User ID of the member who last updated the group.
  updated_by: String?
  /// User ID of the member who deleted the group.
  deleted_by: String?
  /// Default channels members are invited to on joining.
  prefs: UsergroupPrefs?
  /// IDs of the group's members, when `include_users` is set.
  users: List(String)?
  /// The total number of users in the group. Slack sends a number or a
  /// numeric string.
  user_count: UsergroupCount?
  /// Number of channels associated with the group.
  channel_count: Int?
  /// Channel IDs associated with the group.
  channels: List(String)?
  enterprise_id: String?
  enterprise_subteam_id: String?
  /// Whether members are auto-provisioned into the group.
  auto_provision: Bool?
  is_editing_restricted: Bool?
  /// Whether the group is synced from an identity provider.
  is_idp_group: Bool?
  is_membership_locked: Bool?
  /// Whether this is an org-level usergroup.
  is_org_level: Bool?
  /// Whether this usergroup represents a sidebar section.
  is_section: Bool?
  is_visible: Bool?
  /// Workspace IDs the group spans (org-level groups).
  teams: List(String)?
}

/// The kind of automatic group.
enum UsergroupAutoType {
  /// Workspace Admins, as spelled in the reference prose.
  admins
  /// Workspace Admins, as spelled in the response examples.
  admin
  /// Workspace Owners.
  owner
  .. UnknownUsergroupAutoType
}

/// Default channels for members of a group.
record UsergroupPrefs {
  /// Public channel IDs.
  channels: List(String)?
  /// Private channel IDs.
  groups: List(String)?
  file_id: String?
  additional_channels: List(String)?
}

/// A count that Slack sends either as a number or as a numeric string.
oneof UsergroupCount {
  UsergroupCountInt(Int)
  UsergroupCountString(String)
}
