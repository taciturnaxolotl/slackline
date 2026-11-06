//// Admin API methods for managing workflows and trigger permissions across an org.
module slackline/api/admin/workflows

/// Who has access to a trigger type.
enum PermissionVisibility {
  everyone
  named_entities
  no_one
  .. UnknownPermissionVisibility
}

/// The kind of access a trigger type permission controls.
enum TriggerPermissionKind {
  /// Trigger access permission.
  trigger_type
  /// Access to private channels.
  private_channel_access
  /// Access to text from messages in private channels.
  private_channel_message_access
  .. UnknownTriggerPermissionKind
}

/// One permission to set on a trigger type with
/// `admin.workflows.triggers.types.permissions.set`.
record TriggerPermissionInput {
  /// The type of permission.
  type: TriggerPermissionKind
  /// Who has access. `named_entities` needs at least one ID list.
  visibility: PermissionVisibility
  /// User IDs to allow (max 50).
  user_ids: List(String)?
  /// Workspace IDs to allow (max 50).
  team_ids: List(String)?
  /// Enterprise IDs to allow.
  org_ids: List(String)?
}

/// One granular permission of a trigger type.
record TriggerTypePermission {
  type: TriggerPermissionKind?
  permission: PermissionVisibility?
  user_ids: List(String)?
  team_ids: List(String)?
  org_ids: List(String)?
}

/// The permissions of a trigger type. Legacy responses carry `permission`
/// and ID lists. Granular responses carry the `permissions` array instead.
record TriggerTypePermissions {
  permission: PermissionVisibility?
  user_ids: List(String)?
  team_ids: List(String)?
  org_ids: List(String)?
  /// Present when granular permissions are enabled.
  permissions: List(TriggerTypePermission)?
}

/// Where a workflow was created.
enum WorkflowSource {
  app
  code
  workflow_builder
  sales_home
  agent
  .. UnknownWorkflowSource
}

/// An input parameter of a workflow.
record WorkflowInputParameter {
  /// The parameter type, such as `slack#/types/interactivity`.
  type: String?
  name: String?
  title: String?
  description: String?
  is_required: Bool?
}

/// A configured input of a workflow step.
record WorkflowStepInput {
  /// The input value: any json, often a string with `{{...}}` references.
  value: Value?
  /// Whether the input is locked.
  locked: Bool?
}

/// A step of a workflow, as returned by `admin.workflows.search`.
record AdminWorkflowStep {
  id: String
  /// The function the step runs.
  function_id: String?
  inputs: Dict(WorkflowStepInput)?
}

/// Icons of a workflow.
record WorkflowIcons {
  image_96: String?
  image_192: String?
}

/// A trigger type used by a workflow.
record WorkflowTriggerType {
  id: String?
  /// Such as `event` or `shortcut`.
  type: String?
  /// For event triggers, the event, such as `slack#/events/reaction_added`.
  subtype: String?
}

/// A workflow, as returned by `admin.workflows.search`.
record AdminWorkflow {
  id: String
  workflow_function_id: String?
  callback_id: String?
  title: String?
  description: String?
  input_parameters: Dict(WorkflowInputParameter)?
  steps: List(AdminWorkflowStep)?
  /// IDs of the workflow's collaborators.
  collaborators: List(String)?
  icons: WorkflowIcons?
  is_published: Bool?
  last_updated_by: String?
  unpublished_change_count: Int?
  app_id: String?
  source: WorkflowSource?
  /// Such as `simple` or `complex`.
  billing_type: String?
  date_updated: Int?
  is_billable: Bool?
  creation_source_type: Int?
  creation_source_id: String?
  last_published_version_id: String?
  /// When the workflow was last published, in Unix seconds as a string.
  last_published_date: String?
  /// A subset of the workflow's triggers, limited by `num_trigger_ids`.
  trigger_ids: List(String)?
  is_sales_home_workflow: Bool?
  is_sales_elevate: Bool?
  trigger_types: List(WorkflowTriggerType)?
}

method admin.workflows.collaborators.add {
  response Nil
}

method admin.workflows.collaborators.remove {
  response Nil
}

method admin.workflows.permissions.lookup {
  response {
    # The docs do not describe the shape of this field.
    /// Run permissions per workflow ID.
    permissions: Value?
    /// `false` when only a subset of triggers was checked
    /// (see `max_workflow_triggers`).
    complete: Bool?
  }
}

method admin.workflows.search {
  args {
    source: WorkflowSource
    sort: WorkflowSort
    sort_dir: SortDirection
    publish_status: WorkflowPublishStatus
  }
  response {
    total_found: Int?
    workflows: List(AdminWorkflow)?
    response_metadata: ResponseMetadata?
  }
}

method admin.workflows.triggers.types.permissions.lookup {
  response {
    /// Permissions keyed by trigger type ID.
    permissions: Dict(TriggerTypePermissions)?
    # The docs do not describe this field.
    metadata: Value?
  }
}

method admin.workflows.triggers.types.permissions.set {
  args {
    /// The trigger type ID for which to set the permissions.
    id: String
    /// Top-level visibility: `everyone`, `named_entities` or `no_one`. Do not
    /// combine with `permissions`.
    visibility: PermissionVisibility?
    user_ids: List(String)? json
    /// Workspace IDs to allow for `named_entities` visibility (max 50).
    team_ids: List(String)? json
    /// Enterprise IDs to allow for `named_entities` visibility.
    org_ids: List(String)? json
    /// Granular permissions. Do not combine with `visibility`.
    permissions: List(TriggerPermissionInput)? json
  }
  response Nil
}

method admin.workflows.unpublish {
  response Nil
}

/// How to sort workflows.
enum WorkflowSort {
  name as SortByName
}

/// Filter workflows by whether they are published.
enum WorkflowPublishStatus {
  all as AnyPublishStatus
  published
  unpublished
}
