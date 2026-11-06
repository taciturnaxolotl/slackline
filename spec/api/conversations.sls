//// Channels, DMs and Slack Connect invitations (`conversations.*`).
module slackline/api/conversations

# ------------------------------------------------------------ helper records

/// Why one user could not be invited by `conversations.invite`.
record ConversationInviteError {
  /// The user that could not be invited.
  user: String?
  /// Always `false`.
  ok: Bool?
  /// The error code, such as `user_not_found` or `cant_invite_self`.
  error: String?
}

/// A message sent along with an approved Slack Connect invitation request.
record SharedInviteMessage {
  /// The text of the message. With `is_override` false, the combined length
  /// with the original message must stay under 560 characters.
  text: String
  /// When `true`, `text` replaces the original invitation message. Otherwise
  /// Slack adds `text` to the end of it.
  is_override: Bool
}

/// The channel a pending Slack Connect invite is for.
record ConnectInviteChannel {
  /// The channel ID.
  id: String
  /// The channel name.
  name: String?
  /// Whether the channel is private.
  is_private: Bool?
  /// Whether the conversation is a DM.
  is_im: Bool?
}

/// The invite part of a pending Slack Connect invite.
record ConnectInviteDetails {
  /// The invite ID.
  id: String
  /// Unix timestamp of when the invite was created.
  date_created: Int?
  /// Unix timestamp of when the invite stops being valid.
  date_invalid: Int?
  /// The workspace or organization that sent the invite.
  inviting_team: Team?
  /// The user who sent the invite.
  inviting_user: User?
  /// The email address the invite was sent to.
  recipient_email: String?
  /// The user the invite was sent to.
  recipient_user_id: String?
  /// The invite link.
  link: String?
}

/// A review (approval or denial) of an accepted Slack Connect invite.
record ConnectInviteReview {
  /// The kind of review, such as `approval`.
  "type" as review_type: String?
  /// Unix timestamp of the review.
  date_review: Int?
  /// The workspace or organization that reviewed the invite.
  reviewing_team: Team?
}

/// One acceptance of a Slack Connect invite.
record ConnectInviteAcceptance {
  /// The approval state, such as `pending_approval`.
  approval_status: String?
  /// Unix timestamp of when the invite was accepted.
  date_accepted: Int?
  /// Unix timestamp of when the acceptance stops being valid.
  date_invalid: Int?
  /// Unix timestamp of the last update.
  date_last_updated: Int?
  /// The workspace or organization that accepted the invite.
  accepting_team: Team?
  /// The user who accepted the invite.
  accepting_user: User?
  /// Reviews of this acceptance.
  reviews: List(ConnectInviteReview)?
}

/// A pending shared channel invite, sent or received by the workspace.
record ConnectInvite {
  /// `outgoing` or `incoming`.
  direction: String?
  /// The state of the invite, such as `sent`.
  status: String?
  /// Unix timestamp of the last update.
  date_last_updated: Int?
  /// The kind of invite, such as `channel`.
  invite_type: String?
  /// The invite itself.
  invite: ConnectInviteDetails?
  /// The channel being shared.
  channel: ConnectInviteChannel?
  /// Acceptances of the invite.
  acceptances: List(ConnectInviteAcceptance)?
}

/// The recipient of a requested Slack Connect invitation.
record SharedInviteTargetUser {
  /// The recipient's email address.
  recipient_email: String?
  /// The recipient's user ID.
  recipient_user_id: String?
}

/// A team connected to a shared channel.
record SharedInviteConnection {
  /// The connected workspace or organization.
  team: Team?
  /// Whether the channel is private for this team.
  is_private: Bool?
}

/// The channel of a requested Slack Connect invitation.
record SharedInviteChannel {
  /// The channel ID.
  id: String
  /// The channel name.
  name: String?
  /// Whether the conversation is a DM.
  is_im: Bool?
  /// Whether the channel is private.
  is_private: Bool?
  /// Unix timestamp of when the channel was created.
  date_created: Int?
  /// Teams connected to the channel.
  connections: List(SharedInviteConnection)?
  /// Teams with pending connections to the channel.
  pending_connections: List(SharedInviteConnection)?
  /// Teams previously connected to the channel.
  previous_connections: List(SharedInviteConnection)?
}

/// A requested Slack Connect invitation.
record SharedInviteRequest {
  /// The invitation request ID.
  id: String
  /// Unix timestamp of when the request was created.
  date_created: Int?
  /// Unix timestamp of the last update.
  date_last_updated: Int?
  /// Unix timestamp of when the request expires.
  expires_at: Int?
  /// Unix timestamp of when the request was denied.
  date_denied: Int?
  /// The workspace or organization of the requesting user.
  inviting_team: Team?
  /// The user who requested the invitation.
  inviting_user: User?
  /// The user who reviewed the request.
  reviewing_user: User?
  /// Whether the invited party has post-only permissions.
  is_external_limited: Bool?
  /// Whether the invitation is sponsored.
  is_sponsored: Bool?
  /// The email address of the invited user.
  recipient_email: String?
  /// The invited user.
  target_user: SharedInviteTargetUser?
  /// The channel the user is invited to.
  channel: SharedInviteChannel?
}

# ------------------------------------------------------------ methods

method conversations.acceptSharedInvite {
  response {
    /// Whether the channel was approved without needing an admin.
    implicit_approval: Bool?
    /// The ID of the Slack Connect channel.
    channel_id: String?
    /// The ID of the accepted invite.
    invite_id: String?
  }
}

method conversations.approveSharedInvite {
  response Nil
}

method conversations.archive {
  response Nil
}

method conversations.canvases.create {
  args {
    /// The type and value of the content to create.
    document_content: CanvasDocumentContent
  }
  response {
    /// The ID of the new channel canvas.
    canvas_id: String
  }
}

method conversations.close {
  response {
    /// `true` when nothing happened, for example because the conversation was
    /// already closed.
    no_op: Bool?
    /// `true` when the conversation was already closed.
    already_closed: Bool?
  }
}

method conversations.create {
  response {
    /// The new conversation.
    channel: Conversation
  }
}

method conversations.declineSharedInvite {
  response Nil
}

method conversations.externalInvitePermissions.set {
  args {
    action: ExternalInviteAction
  }
  response Nil
}

method conversations.history {
  response {
    /// The messages, most recent first.
    messages: List(Message)?
    /// `true` when more messages exist in the requested time range.
    has_more: Bool?
    /// The number of pinned items in the conversation.
    pin_count: Int?
    /// The `latest` timestamp of the request, echoed back.
    latest: String?
    /// Only for free teams past the message limit: `true` when older
    /// messages exist beyond the limit.
    is_limited: Bool?
    response_metadata: ResponseMetadata?
  }
}

method conversations.info {
  response {
    /// The conversation.
    channel: Conversation
  }
}

method conversations.invite {
  args {
    /// User IDs to invite. Up to 1000.
    users: List(String) comma
  }
  response {
    /// The conversation the users were invited to.
    channel: Conversation
    /// Users that could not be invited, when `force` is used.
    errors: List(ConversationInviteError)?
  }
}

method conversations.inviteShared {
  response {
    /// The ID of the invite.
    invite_id: String
    /// Whether the channel is a legacy shared channel.
    is_legacy_shared_channel: Bool?
    /// The invite confirmation code. Omitted for targeted invites and when
    /// `external_limited` is `true`.
    conf_code: String?
    /// The invite URL. Omitted for targeted invites and when
    /// `external_limited` is `true`.
    url: String?
  }
}

method conversations.join {
  response {
    /// The joined conversation.
    channel: Conversation
    /// A warning, such as `already_in_channel`.
    warning: String?
    response_metadata: ResponseMetadata?
  }
}

method conversations.kick {
  response {
    /// Per-user errors. Empty on success.
    errors: Value?
  }
}

method conversations.leave {
  response {
    /// `true` when the user was not in the conversation.
    not_in_channel: Bool?
  }
}

method conversations.list {
  args {
    /// Conversation types to include: any combination of `public_channel`,
    /// `private_channel`, `mpim` and `im`.
    types: List(String) comma
  }
  response {
    /// The conversations. These are limited conversation objects. Use
    /// `conversations.info` for the full object.
    channels: List(Conversation)?
    response_metadata: ResponseMetadata?
  }
}

method conversations.listConnectInvites {
  response {
    /// Pending shared channel invites.
    invites: List(ConnectInvite)?
    response_metadata: ResponseMetadata?
  }
}

method conversations.mark {
  response Nil
}

method conversations.members {
  response {
    /// User IDs of the members.
    members: List(String)?
    response_metadata: ResponseMetadata?
  }
}

method conversations.open {
  args {
    /// 1 to 8 user IDs. One ID opens a DM. More IDs open a multi-person DM.
    /// Do not include the calling user.
    users: List(String) comma
  }
  response {
    /// The conversation. Only `id` is set unless `return_im` is `true`.
    channel: Conversation
    /// `true` when the conversation already existed.
    no_op: Bool?
    /// `true` when the conversation was already open.
    already_open: Bool?
  }
}

method conversations.rename {
  response {
    /// The renamed conversation.
    channel: Conversation
  }
}

method conversations.replies {
  response {
    /// The parent message followed by its replies, earliest first.
    messages: List(Message)?
    /// `true` when more messages exist in the requested time range.
    has_more: Bool?
    response_metadata: ResponseMetadata?
  }
}

method conversations.requestSharedInvite.approve {
  args {
    /// Text to send along with the invite.
    message: SharedInviteMessage
  }
  response {
    /// The ID of the approved invitation request.
    invite_id: String
  }
}

method conversations.requestSharedInvite.deny {
  response {
    /// The ID of the denied invitation request.
    invite_id: String
  }
}

method conversations.requestSharedInvite.list {
  response {
    /// Requested invitations, ordered by ID.
    invite_requests: List(SharedInviteRequest)?
    response_metadata: ResponseMetadata?
  }
}

method conversations.setPurpose {
  response {
    /// The new purpose.
    purpose: String?
  }
}

method conversations.setTopic {
  response {
    /// The conversation with its new topic.
    channel: Conversation
  }
}

method conversations.unarchive {
  response Nil
}

/// Whether to upgrade or downgrade an external invite.
enum ExternalInviteAction {
  upgrade
  downgrade
}
