//// Admin functions: list functions and manage who can use them.
module slackline/api/admin/functions

/// An input or output parameter of a function.
record AdminFunctionParameter {
  /// The parameter type, such as `string` or `slack#/types/user_id`.
  type: String?
  name: String
  description: String?
  title: String?
  is_required: Bool?
}

/// A function from `admin.functions.list`.
record AdminFunction {
  id: String
  callback_id: String?
  title: String?
  description: String?
  /// Such as `app`.
  type: String?
  input_parameters: List(AdminFunctionParameter)?
  output_parameters: List(AdminFunctionParameter)?
  app_id: String?
  date_created: Int?
  date_updated: Int?
  /// `0` when the function has not been deleted.
  date_deleted: Int?
}

method admin.functions.list {
  response {
    functions: List(AdminFunction)?
    response_metadata: ResponseMetadata?
  }
}

method admin.functions.permissions.lookup {
  response {
    # The docs do not show the shape of a permissions object.
    /// Permissions, keyed by function ID.
    permissions: Dict(Value)?
    /// Errors found during the lookup, keyed by function ID.
    errors: Dict(Value)?
  }
}

method admin.functions.permissions.set {
  args {
    # The docs do not describe the shape of an item.
    /// The permissions for the function.
    permissions: List(Value)? json
    visibility: FunctionVisibility
  }
  response Nil
}

/// Who can see and run a function.
enum FunctionVisibility {
  everyone as VisibleToEveryone
  app_collaborators as VisibleToAppCollaborators
  named_entities as VisibleToNamedEntities
  no_one as VisibleToNoOne
}
