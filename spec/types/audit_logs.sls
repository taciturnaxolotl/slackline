//// The [Audit Logs API](https://docs.slack.dev/admins/audit-logs-api) at
//// `api.slack.com/audit/v1`, for Enterprise organizations. `logs()` needs an
//// organization owner's token with `auditlogs:read`; `schemas()` and
//// `actions()` need no token.
module slackline/audit_logs

/// A user in an audit event.
record AuditUser {
  /// `USLACKSECURITY` when Slack Security reset credentials, `USLACKUSER`
  /// when an event fired without an actor.
  id: String
  name: String?
  email: String?
  team: String?
}

/// Who did something. Always a user.
record AuditActor {
  "type" as actor_type: String?
  user: AuditUser?
}

/// The workspace or organization an event happened in.
record AuditLocation {
  /// `workspace` or `enterprise`.
  "type" as location_type: String?
  id: String?
  name: String?
  domain: String?
}

/// Where an event came from.
record AuditContext {
  location: AuditLocation?
  /// The user agent.
  ua: String?
  ip_address: String?
  session_id: String?
}

/// One audit event.
record AuditEntry {
  id: String
  /// Unix time.
  date_create: Int?
  /// Such as `user_login` or `file_downloaded`. `actions()` lists them.
  action: String
  actor: AuditActor?
  # The entity is keyed by its type, such as `user`, `channel` or `file`, and
  # `schemas()` lists the shapes, so it stays json.
  /// What the action was done to: `type` names a key that holds the object.
  entity: Value?
  context: AuditContext?
  /// Extra details for some actions.
  details: Value?
}

/// A page of audit events, newest first.
record AuditLogs {
  entries: List(AuditEntry)
  response_metadata: ResponseMetadata?
}
