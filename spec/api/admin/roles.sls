//// Admin API methods for assigning admin roles to users.
module slackline/api/admin/roles

/// A role granted to a user for an org, workspace or channel.
record RoleAssignment {
  /// The role ID, such as `Rl0A`.
  role_id: String?
  /// The org, workspace or channel the role applies to.
  entity_id: String?
  /// The user holding the role.
  user_id: String?
  /// When the role was assigned, in Unix seconds.
  date_create: Int?
}

method admin.roles.addAssignments {
  response Nil
}

method admin.roles.removeAssignments {
  response Nil
}

method admin.roles.listAssignments {
  args {
    sort_dir: SortDirection
  }
  response {
    role_assignments: List(RoleAssignment)?
    response_metadata: ResponseMetadata?
  }
}
