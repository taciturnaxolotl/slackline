//// Custom functions: complete function executions, manage distribution permissions and inspect workflow steps.
module slackline/api/functions

/// Who can use a custom function in their workflows.
enum FunctionPermissionType {
  everyone
  app_collaborators
  named_entities
  system
  .. UnknownFunctionPermissionType
}

/// A user granted access to a custom function.
record FunctionPermissionUser {
  user_id: String
  username: String?
  email: String?
}

/// A workflow step that uses a function.
record WorkflowStepVersion {
  /// Title of the step.
  title: String?
  workflow_id: String?
  /// ID of the step within the workflow.
  step_id: String
  /// Whether the step has been deleted.
  is_deleted: Bool?
  /// When the workflow version containing the step was created.
  workflow_version_created: String?
}

/// The permission type of a function and, if applicable, the users with access.
record FunctionDistributionPermissions {
  /// How the function can be distributed.
  permission_type: FunctionPermissionType?
  /// Users with access, for `named_entities` (and `app_collaborators`).
  users: List(FunctionPermissionUser)?
}

method functions.completeError {
  response Nil
}

method functions.completeSuccess {
  args {
    /// Outputs conforming to the function's output parameters, such as `{"customer_id": "U0BPQUNTA"}`.
    outputs: Dict(Value)
  }
  response Nil
}

method functions.distributions.permissions.add {
  response FunctionDistributionPermissions
}

method functions.distributions.permissions.list {
  response FunctionDistributionPermissions
}

method functions.distributions.permissions.remove {
  response FunctionDistributionPermissions
}

method functions.distributions.permissions.set {
  args {
    permission_type: FunctionPermissionType
  }
  response FunctionDistributionPermissions
}

method functions.workflows.steps.list {
  response {
    /// Steps that use the function, across workflow versions.
    steps_versions: List(WorkflowStepVersion)?
  }
}

method functions.workflows.steps.responses.export {
  response Nil
}
