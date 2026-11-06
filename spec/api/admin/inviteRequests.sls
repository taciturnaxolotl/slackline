//// Admin API methods for reviewing requests to invite people to a workspace.
module slackline/api/admin/invite_requests

/// Who approved or denied an invite request.
record InviteRequestActor {
  /// ID of the user or app that acted.
  actor_id: String?
  /// Whether a `user` or an `app` acted.
  actor_type: InviteRequestActorType?
}

/// The kind of actor that approved or denied an invite request.
enum InviteRequestActorType {
  user
  app
  .. UnknownInviteRequestActorType
}

/// Preferences of an invite sent after a request was approved.
record InvitePreferences {
  is_restricted: Bool?
  is_ultra_restricted: Bool?
  /// When a guest account expires, in Unix seconds.
  date_expire: Int?
  /// Channels the invited person joins.
  channel_ids: List(String)?
  is_domain_matched: Bool?
  real_name: String?
}

/// The invite sent after an invite request was approved.
record ApprovedInvite {
  /// The invite ID.
  id: String
  /// ID of the user credited as the inviter.
  inviter_id: String?
  email: String?
  /// When the invite was sent, in Unix seconds.
  date_created: Int?
  /// When the invite was last resent, in Unix seconds.
  date_resent: Int?
  /// Whether email to the invited address is bouncing.
  is_bouncing: Bool?
  invite_preferences: InvitePreferences?
}

/// An approved invite request.
record ApprovedInviteRequest {
  invite_request: InviteRequest?
  approved_by: InviteRequestActor?
  invite: ApprovedInvite?
}

/// A denied invite request.
record DeniedInviteRequest {
  invite_request: InviteRequest?
  denied_by: InviteRequestActor?
}

method admin.inviteRequests.approve {
  response Nil
}

method admin.inviteRequests.deny {
  response Nil
}

method admin.inviteRequests.list {
  response {
    /// Pending invite requests.
    invite_requests: List(InviteRequest)?
    response_metadata: ResponseMetadata?
  }
}

method admin.inviteRequests.approved.list {
  response {
    /// Approved invite requests.
    approved_requests: List(ApprovedInviteRequest)?
    response_metadata: ResponseMetadata?
  }
}

method admin.inviteRequests.denied.list {
  response {
    /// Denied invite requests.
    denied_requests: List(DeniedInviteRequest)?
    response_metadata: ResponseMetadata?
  }
}
