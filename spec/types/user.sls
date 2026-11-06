//// Users and their profiles.
//// See <https://docs.slack.dev/reference/objects/user-object>.
////
//// The composition of user objects varies a lot between APIs and
//// workspaces: data that has not been supplied may be absent, `null` or an
//// empty string. Everything except `id` is optional.
module slackline/user

/// A Slack workspace user.
record User {
  /// Identifier for this workspace user, unique to the workspace. Use it
  /// together with `team_id` as a unique key.
  id: String
  /// Workspace ID the user belongs to.
  team_id: String?
  /// Do not use this. It once held the preferred username.
  name: String?
  /// `true` if the user has been deactivated. May be absent otherwise.
  deleted: Bool?
  /// Used in some clients to display a special username color.
  color: String?
  /// User's full real name (top-level copy from profile).
  real_name: String?
  /// Human-readable geographic timezone region, such as `Europe/London`.
  tz: String?
  /// The commonly used name of the `tz` timezone.
  tz_label: String?
  /// Seconds to offset UTC time by for this user's `tz`.
  tz_offset: Int?
  /// The user's workspace profile.
  profile: UserProfile?
  /// Whether the user is an Admin of the current workspace.
  is_admin: Bool?
  /// Whether the user is an Owner of the current workspace.
  is_owner: Bool?
  /// Whether the user is the Primary Owner of the current workspace.
  is_primary_owner: Bool?
  /// Whether the user is a guest user.
  is_restricted: Bool?
  /// Whether the user is a single-channel guest.
  is_ultra_restricted: Bool?
  /// Whether the user is a bot user. `false` for Slackbot.
  is_bot: Bool?
  /// Whether the user is an authorized user of the calling app.
  is_app_user: Bool?
  /// Whether this is a workflow bot user.
  is_workflow_bot: Bool?
  /// Whether this is an Agentforce bot user.
  is_agentforce_bot: Bool?
  /// Unix timestamp of when the user object was last updated.
  updated: Int?
  /// Whether the user's email address has been confirmed.
  is_email_confirmed: Bool?
  /// Contact card sharing permission setting, such as `EVERYONE`.
  who_can_share_contact_card: String?
  /// Enterprise org identity of the user.
  enterprise_user: EnterpriseUser?
  /// Enterprise org ID (enterprise variant).
  enterprise_id: String?
  /// Enterprise org name (enterprise variant).
  enterprise_name: String?
  /// Whether two-factor authentication is enabled. Only visible to admins.
  has_2fa: Bool?
  /// `app` or `sms`. Only present if `has_2fa` is `true`.
  two_factor_type: String?
  /// IETF language code of the user's chosen display language.
  locale: String?
  /// Whether a bot user is set to be constantly active.
  always_active: Bool?
  /// Unix timestamp of the user's first login.
  first_login: Int?
  /// Whether the user is external to the workspace.
  is_external: Bool?
  /// Whether the user has been GDPR-forgotten.
  is_forgotten: Bool?
  /// Only present (and `true`) when the user was invited but has not signed in.
  is_invited_user: Bool?
  /// Whether this is a profile-only user (enterprise variant).
  is_profile_only_user: Bool?
  /// `true` if the user belongs to a different workspace and is not in any
  /// shared channel visible to the app.
  is_stranger: Bool?
  /// User's manually-set presence value.
  manual_presence: String?
  /// User's current presence, such as `active` or `away`.
  presence: String?
  /// Numeric type classification for restricted/guest users.
  restricted_user_type: Int?
  /// Whether the user account is suspended (non-enterprise variant).
  suspended: Bool?
  /// Workspace ID (non-enterprise variant).
  team: String?
  /// Team profile fields and sections definitions.
  team_profile: Value?
  /// Workspace IDs the user belongs to (enterprise variant).
  teams: List(String)?
}

/// The Enterprise org identity of a user.
record EnterpriseUser {
  /// The org-wide user ID. Prefer it over the root `id` when present.
  id: String?
  /// The Enterprise organization ID.
  enterprise_id: String?
  /// A display name for the Enterprise organization.
  enterprise_name: String?
  is_admin: Bool?
  is_owner: Bool?
  is_primary_owner: Bool?
  /// Workspace IDs in the Enterprise organization.
  teams: List(String)?
}

/// A user's workspace profile. Also used when setting a profile with
/// `users.profile.set`.
record UserProfile {
  /// The user's title.
  title: String?
  /// The user's phone number, in any format.
  phone: String?
  /// Always an empty string.
  skype: String?
  /// The user's first and last name.
  real_name: String?
  /// `real_name` with non-Latin characters filtered out.
  real_name_normalized: String?
  /// The display name the user has chosen. Not a unique identifier.
  display_name: String?
  /// `display_name` with non-Latin characters filtered out.
  display_name_normalized: String?
  /// Custom profile fields, keyed by field ID.
  fields: Dict(UserProfileField)?
  /// The displayed status text, up to 100 characters.
  status_text: String?
  /// The displayed status emoji, such as `:train:`.
  status_emoji: String?
  /// Rich emoji display info for the status emoji.
  status_emoji_display_info: List(StatusEmojiDisplayInfo)?
  /// Unix timestamp of when the status expires. `0` means never.
  status_expiration: Int?
  status_text_canonical: String?
  status_clear_on_focus_end: Bool?
  /// Hash of the user's profile image.
  avatar_hash: String?
  last_avatar_image_hash: String?
  /// The date the person joined the organization (Slack Atlas only).
  start_date: String?
  /// A valid email address. Requires the `users:read.email` scope.
  email: String?
  /// The pronouns the user prefers.
  pronouns: String?
  /// `default_unset`, `in_a_huddle` or `available_for_huddle`.
  huddle_state: HuddleState?
  huddle_state_call_id: String?
  huddle_state_channel_id: String?
  huddle_state_expiration_ts: Int?
  /// The user's first name.
  first_name: String?
  /// The user's last name.
  last_name: String?
  image_24: String?
  image_32: String?
  image_48: String?
  image_72: String?
  image_192: String?
  image_512: String?
  image_1024: String?
  image_original: String?
  /// Whether the user uploaded a custom profile image.
  is_custom_image: Bool?
  /// The ID of the team the user is on.
  team: String?
  /// Whether a bot user is set to be constantly active.
  always_active: Bool?
  /// App ID associated with this bot/app user.
  api_app_id: String?
  /// Bot ID if this is a bot user profile.
  bot_id: String?
  /// Unix timestamp when the guest account expires.
  guest_expiration_ts: Int?
  /// User ID of who invited this guest.
  guest_invited_by: String?
  is_agentforce_bot: Bool?
  is_app_user: Bool?
  is_restricted: Bool?
  is_sidekick_bot: Bool?
  is_ultra_restricted: Bool?
  memberships_count: Int?
  name: String?
  restricted_user_type: Int?
  updated: Int?
  user_id: String?
  username: String?
  who_can_share_contact_card: String?
}

/// The value of a custom profile field.
record UserProfileField {
  value: String?
  alt: String?
  label: String?
}

/// Display information for a status emoji.
record StatusEmojiDisplayInfo {
  emoji_name: String?
  display_alias: String?
  display_url: String?
  unicode: String?
}

/// A user's huddle status.
enum HuddleState {
  default_unset
  in_a_huddle
  available_for_huddle
  .. UnknownHuddleState
}
