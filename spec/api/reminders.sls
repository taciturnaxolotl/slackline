//// Reminders (`reminders.*`). Slack began retiring these methods in March
//// 2023. Live tests show `reminders.add` still works, but the reminder it
//// creates lands in To-dos, and `info`, `list`, `complete` and `delete`
//// answer `not_found` or an empty list for it.
module slackline/api/reminders

/// How often a recurring reminder repeats.
enum ReminderFrequency {
  daily
  weekly
  monthly
  yearly
  .. UnknownReminderFrequency
}

/// A day of the week for weekly reminders.
enum ReminderWeekday {
  monday
  tuesday
  wednesday
  thursday
  friday
  saturday
  sunday
  .. UnknownReminderWeekday
}

/// The repeating behavior of a reminder.
record ReminderRecurrence {
  /// How often the reminder repeats.
  frequency: ReminderFrequency
  /// For `weekly` reminders, the days of the week.
  weekdays: List(ReminderWeekday)?
}

/// A reminder. Only non-recurring reminders have `time` and `complete_ts`.
record Reminder {
  /// The reminder ID.
  id: String
  /// The user who created the reminder.
  creator: String?
  /// The user the reminder is for.
  user: String?
  /// The content of the reminder.
  text: String?
  /// Whether the reminder repeats.
  recurring: Bool?
  /// Unix timestamp of when the reminder fires.
  time: Int?
  /// Unix timestamp of when the reminder was completed, `0` if not yet.
  complete_ts: Int?
}

method reminders.add {
  deprecated "Slack is retiring reminders. New reminders are filed under To-dos, where reminders.info, list, complete and delete cannot find them."
  args {
    /// The repeating behavior of the reminder.
    recurrence: ReminderRecurrence
  }
  response {
    /// The new reminder.
    reminder: Reminder
  }
}

method reminders.complete {
  deprecated "Slack is retiring reminders. New reminders are filed under To-dos, where reminders.info, list, complete and delete cannot find them."
  response Nil
}

method reminders.delete {
  deprecated "Slack is retiring reminders. New reminders are filed under To-dos, where reminders.info, list, complete and delete cannot find them."
  response Nil
}

method reminders.info {
  deprecated "Slack is retiring reminders. New reminders are filed under To-dos, where reminders.info, list, complete and delete cannot find them."
  response {
    # Optional because the success example in the docs leaves it out.
    /// The reminder.
    reminder: Reminder?
  }
}

method reminders.list {
  deprecated "Slack is retiring reminders. New reminders are filed under To-dos, where reminders.info, list, complete and delete cannot find them."
  response {
    /// Reminders created by or for the user.
    reminders: List(Reminder)?
  }
}
