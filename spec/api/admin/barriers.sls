//// Admin barriers: information barriers between IDP groups.
module slackline/api/admin/barriers

/// An IDP group referenced by an information barrier.
record BarrierUsergroup {
  id: String
  name: String?
}

/// An information barrier.
record Barrier {
  /// The barrier ID.
  id: String
  enterprise_id: String?
  /// The IDP group the barrier applies to.
  primary_usergroup: BarrierUsergroup?
  /// The IDP groups the primary group is barriered from.
  barriered_from_usergroups: List(BarrierUsergroup)?
  /// Blocked interaction kinds: `im`, `mpim` and `call`.
  restricted_subjects: List(String)?
  /// When the barrier was last updated (Unix time).
  date_update: Int?
  # One docs example nests the pagination cursor inside the barrier.
  response_metadata: ResponseMetadata?
}

method admin.barriers.create {
  response {
    barrier: Barrier?
  }
}

method admin.barriers.delete {
  response Nil
}

method admin.barriers.list {
  args {
    /// Only return barriers whose name matches. Mentioned in the usage info, not in the arguments list.
    filter_by_usergroup_name: String?
  }
  response {
    barriers: List(Barrier)?
    response_metadata: ResponseMetadata?
  }
}

method admin.barriers.update {
  response {
    barrier: Barrier?
  }
}
