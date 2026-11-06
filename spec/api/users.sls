//// Slack Web API methods for users, their profiles and presence.
module slackline/api/users

/// A user's presence.
enum Presence {
  active
  away
  .. UnknownPresence
}

/// The user returned by `users.identity`. Fields beyond `id` and `name` depend on the
/// `identity.*` scopes granted.
record IdentityUser {
  /// The user ID.
  id: String
  /// The user's name.
  name: String?
  /// The user's email address, with the `identity.email` scope.
  email: String?
  /// Avatar URLs, with the `identity.avatar` scope.
  image_24: String?
  image_32: String?
  image_48: String?
  image_72: String?
  image_192: String?
}

/// The workspace returned by `users.identity`.
record IdentityTeam {
  /// The workspace ID.
  id: String
  /// The workspace name, with the `identity.team` scope.
  name: String?
}

/// The value of a custom profile field: text for most field types, a list for `tags` fields.
oneof ProfileFieldValue {
  ProfileFieldText(String)
  ProfileFieldTags(List(String))
}

/// A custom profile field value to set, keyed by field ID in `ProfileUpdate.fields`.
record ProfileFieldUpdate {
  /// The value of the field.
  value: ProfileFieldValue
  /// Text displayed instead of `value` when set. Up to 256 characters.
  alt: String?
}

/// Profile fields to set with `users.profile.set`. Unset fields are left unchanged.
record ProfileUpdate {
  /// The display name. Maximum of 80 characters.
  display_name: String?
  /// A valid email address. Only admins can change it, for users on paid teams.
  email: String?
  /// The user's first name. Updates the first name within `real_name`.
  first_name: String?
  /// The user's last name. Updates the second name within `real_name`.
  last_name: String?
  /// The user's phone number, in any format.
  phone: String?
  /// The user's pronouns.
  pronouns: String?
  /// The user's first and last name. Maximum of 50 characters.
  real_name: String?
  /// The date the person joined the organization, such as `2022-10-22`.
  start_date: String?
  /// The user's title.
  title: String?
  /// The status emoji, such as `:train:`. Set it and `status_text` to `""` to clear the status.
  status_emoji: String?
  /// Unix timestamp of when the status expires. `0` means it never expires.
  status_expiration: Int?
  /// The status text, up to 100 characters.
  status_text: String?
  /// Custom profile fields by field ID. Use `team.profile.get` to find the IDs.
  fields: Dict(ProfileFieldUpdate)?
}

method users.conversations {
  args {
    /// Channel types to include: any combination of `public_channel`, `private_channel`, `mpim` and `im`.
    types: List(String)? comma
  }
  response {
    /// The conversations. `is_member` and `num_members` are omitted.
    channels: List(Conversation)?
    response_metadata: ResponseMetadata?
  }
}

method users.deletePhoto {
  response Nil
}

method users.discoverableContacts.lookup {
  response {
    /// Whether there is a discoverable Slack user with this email address.
    is_discoverable: Bool
  }
}

method users.getPresence {
  response {
    /// The user's overall presence.
    presence: Presence
    /// Whether the user has a client connected to Slack. Only for the authed user.
    online: Bool?
    /// Whether no activity was detected in the last 10 minutes. Only for the authed user.
    auto_away: Bool?
    /// Whether the user manually set their presence to `away`. Only for the authed user.
    manual_away: Bool?
    /// The total number of connections. Only for the authed user.
    connection_count: Int?
    /// Unix timestamp of the last activity. Absent when the user has no connected clients.
    last_activity: Int?
  }
}

method users.identity {
  response {
    /// The signed-in user.
    user: IdentityUser?
    /// The user's workspace.
    team: IdentityTeam?
  }
}

method users.info {
  response {
    /// The user.
    user: User?
  }
}

method users.list {
  response {
    /// The users, including invited and deactivated users.
    members: List(User)?
    /// Unix timestamp of when the list was generated.
    cache_ts: Int?
    response_metadata: ResponseMetadata?
  }
}

method users.lookupByEmail {
  response {
    /// The user.
    user: User?
  }
}

method users.profile.get {
  response {
    /// The user's profile.
    profile: UserProfile?
  }
}

method users.profile.set {
  args {
    /// The profile fields to set, at most 50. Use instead of `name` and `value`.
    profile: ProfileUpdate? json
  }
  response {
    /// The user's complete profile.
    profile: UserProfile?
  }
}

method users.setActive {
  response Nil
}

/// The `image` argument is a binary `multipart/form-data` upload, which slackline cannot
/// send yet, so it is left out.
method users.setPhoto {
  args {
    -image
    /// Width and height of the square crop box.
    crop_w: Int?
    /// X coordinate of the top-left corner of the crop box.
    crop_x: Int?
    /// Y coordinate of the top-left corner of the crop box.
    crop_y: Int?
  }
  response Nil
}

method users.setPresence {
  args {
    /// Either `auto` or `away`.
    presence: SetPresence
  }
  response Nil
}

/// The presence a user can set: `auto` lets Slack decide.
enum SetPresence {
  auto
  away as SetAway
}
