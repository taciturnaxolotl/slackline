//// Admin legal holds (`admin.legalHold.*`): policies that hold message data
//// for custodians. Enterprise plans only. The methods are documented together
//// on <https://docs.slack.dev/reference/legal-holds-api-reference>.
module slackline/api/admin/legal_hold

/// Whether a policy is holding data.
enum LegalHoldStatus {
  "ACTIVE" as ActiveLegalHold
  "RELEASED" as ReleasedLegalHold
  .. UnknownLegalHoldStatus
}

/// Which conversations a policy holds.
enum LegalHoldRestriction {
  /// Hold data for all relevant conversations.
  "NO_RESTRICTION" as NoRestriction
  /// Hold data from direct messages only.
  "ONLY_DMS" as OnlyDms
  .. UnknownLegalHoldRestriction
}

/// The kind of custodian a policy holds data for.
enum LegalHoldEntityType {
  /// Messages authored by or visible to a user.
  "USER" as UserEntity
  .. UnknownLegalHoldEntityType
}

/// A Legal Hold policy.
record LegalHoldPolicy {
  id: String
  /// The organization.
  team_id: String?
  creator_id: String?
  name: String?
  description: String?
  restrictions: List(LegalHoldRestriction)?
  status: LegalHoldStatus?
  /// Unix time. `0` when unset, as for the release and policy dates below.
  date_created: Int?
  date_updated: Int?
  date_released: Int?
  date_policy_start: Int?
  date_policy_end: Int?
}

/// A custodian to add to a policy.
record LegalHoldEntityInput {
  entity_type: LegalHoldEntityType
  /// The encoded user ID.
  entity_id: String
}

/// A custodian of a policy.
record LegalHoldEntity {
  /// The ID of this custodian on the policy, for `admin.legalHold.entities.remove`.
  id: String
  team_id: String?
  policy_id: String?
  entity_type: LegalHoldEntityType?
  entity_id: String?
  /// Unix time. `0` while the custodian is on the policy.
  date_created: Int?
  date_deleted: Int?
}

method admin.legalHold.entities.add {
  args {
    entities: List(LegalHoldEntityInput) json
  }
  response {
    created_entities: List(LegalHoldEntity)?
    failed_entities: List(Value)?
  }
}

method admin.legalHold.entities.list {
  response {
    entities: List(LegalHoldEntity)?
    response_metadata: ResponseMetadata?
  }
}

method admin.legalHold.entities.remove {
  args {
    ids: List(String) json
  }
  response {
    failed_ids: List(String)?
  }
}

method admin.legalHold.policies.activate {
  response {
    policy: LegalHoldPolicy
  }
}

method admin.legalHold.policies.create {
  args {
    restrictions: List(LegalHoldRestriction)? json
  }
  response {
    policy: LegalHoldPolicy
  }
}

method admin.legalHold.policies.info {
  response {
    policy: LegalHoldPolicy
  }
}

method admin.legalHold.policies.list {
  args {
    status: LegalHoldStatus?
  }
  response {
    policies: List(LegalHoldPolicy)?
    policy_total_count: Int?
    response_metadata: ResponseMetadata?
  }
}

method admin.legalHold.policies.release {
  response {
    policy: LegalHoldPolicy
  }
}

method admin.legalHold.policies.set {
  response {
    policy: LegalHoldPolicy
  }
}
