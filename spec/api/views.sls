//// Open, push, update and publish modals and App Home views (`views.*`).
module slackline/api/views

/// The view Slack returns after a successful views call.
record ViewResponse {
  /// The view as stored by Slack, including its `id`, `hash` and `state`.
  view: View
  response_metadata: ResponseMetadata?
}

method views.open {
  args {
    /// The modal view to open.
    view: View
  }
  response ViewResponse
}

method views.push {
  args {
    /// The modal view to push onto the view stack.
    view: View
  }
  response ViewResponse
}

method views.update {
  args {
    /// The new view. Keep the same `block_id` and `action_id` values in input
    /// blocks to preserve what the user entered.
    view: View
  }
  response ViewResponse
}

method views.publish {
  args {
    /// The App Home view to publish.
    view: View
    /// Exchange an interactivity pointer to publish the view.
    interactivity_pointer: String
  }
  response ViewResponse
}
