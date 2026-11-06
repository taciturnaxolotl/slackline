//// Admin auth: assign users to authentication policies.
module slackline/api/admin/auth

/// A kind of entity that can be assigned to an authentication policy.
enum PolicyEntityType {
  "USER" as PolicyEntityUser
  .. UnknownPolicyEntityType
}

/// An entity assigned to an authentication policy.
record PolicyEntity {
  /// The type of entity, such as `USER`.
  entity_type: PolicyEntityType?
  /// The ID of the entity.
  entity_id: String
  /// When the entity was added to the policy (Unix time).
  date_added: Int?
}

method admin.auth.policy.assignEntities {
  response Nil
}

method admin.auth.policy.getEntities {
  response {
    entities: List(PolicyEntity)?
    /// Total number of entities assigned to the policy.
    entity_total_count: Int?
    response_metadata: ResponseMetadata?
  }
}

method admin.auth.policy.removeEntities {
  response Nil
}
