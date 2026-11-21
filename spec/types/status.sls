//// Slack's own status, from the unauthenticated
//// [Status API](https://docs.slack.dev/reference/slack-status-api) at
//// `slack-status.com`. Use `current()` and `history()`.
module slackline/status

/// The kind of issue.
enum IncidentType {
  incident as IncidentKind
  notice as NoticeKind
  outage as OutageKind
  .. UnknownIncidentType
}

/// Where an issue stands. `ok` only appears on the overall status.
enum IncidentStatus {
  ok as AllOk
  active as ActiveIssue
  resolved as ResolvedIssue
  scheduled as ScheduledMaintenance
  completed as CompletedMaintenance
  cancelled as CancelledMaintenance
  .. UnknownIncidentStatus
}

/// An update on an issue.
record IncidentNote {
  /// When the note was posted, as an ISO 8601 timestamp.
  date_created: String?
  /// The note, as HTML.
  body: String?
}

/// An incident, outage, notice or planned maintenance.
record Incident {
  # The docs show `id` as a string; the live API sends a number.
  id: Int
  title: String?
  "type" as incident_type: IncidentType?
  status: IncidentStatus?
  /// A page tracking the issue.
  url: String?
  /// When response or maintenance began, as an ISO 8601 timestamp.
  date_created: String?
  date_updated: String?
  /// The affected services, such as `Messaging` or `Apps/Integrations/APIs`.
  services: List(String)?
  notes: List(IncidentNote)?
}

/// Slack's current status.
record CurrentStatus {
  /// `ok` when all is well, `active` during an issue.
  status: IncidentStatus
  active_incidents: List(Incident)?
  date_created: String?
  date_updated: String?
}
