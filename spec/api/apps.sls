//// Apps: activity logs, external auth, datastores, manifests, Socket Mode and installation management.
module slackline/api/apps

/// Credentials for an app created from a manifest.
record AppCredentials {
  client_id: String?
  client_secret: String?
  verification_token: String?
  signing_secret: String?
}

/// A problem found in a manifest.
record ManifestError {
  /// Description of the problem.
  message: String?
  /// JSON pointer to the problem's location in the manifest.
  pointer: String?
}

/// An installation of the app an event is visible to.
record EventAuthorization {
  enterprise_id: String?
  team_id: String?
  user_id: String?
  # The docs example shows a placeholder string here, so the type is `Value`.
  /// Whether the installation is a bot.
  is_bot: Value?
}

method apps.activities.list {
  args {
    sort_direction: SortDirection
  }
  response {
    /// Log events, newest first unless `sort_direction` says otherwise.
    activities: List(AppActivity)?
    response_metadata: ResponseMetadata?
  }
}

method apps.auth.external.delete {
  response Nil
}

method apps.auth.external.get {
  response {
    /// The external access token.
    external_token: String
  }
}

method apps.connections.open {
  response {
    /// WebSocket URL to connect to for Socket Mode.
    url: String
  }
}

method apps.datastore.bulkDelete {
  args {
    ids: List(String) json
  }
  response {
    /// Items that could not be deleted.
    failed_items: List(Value)?
  }
}

method apps.datastore.bulkGet {
  args {
    ids: List(String) json
  }
  response {
    datastore: String?
    /// The items found, as attribute maps.
    items: List(Dict(Value))?
    /// Items that could not be fetched.
    failed_items: List(Value)?
  }
}

method apps.datastore.bulkPut {
  args {
    /// Attribute names and values of the items. Maximum 25.
    items: List(Dict(Value)) json
  }
  response {
    datastore: String?
    /// Items that could not be written.
    failed_items: List(Value)?
  }
}

method apps.datastore.count {
  args {
    /// A map of attributes referenced in `expression`.
    expression_attributes: Dict(String)?
    /// A map of values referenced in `expression`.
    expression_values: Dict(Value)?
  }
  response {
    datastore: String?
    /// Number of items matching the expression.
    count: Int?
  }
}

method apps.datastore.delete {
  response Nil
}

method apps.datastore.get {
  response {
    datastore: String?
    /// The item's attribute names and values.
    item: Dict(Value)?
  }
}

method apps.datastore.put {
  args {
    /// Attribute names and values of the item.
    item: Dict(Value)
  }
  response {
    datastore: String?
    /// The stored item.
    item: Dict(Value)?
  }
}

method apps.datastore.query {
  args {
    /// A map of attributes referenced in `expression`.
    expression_attributes: Dict(String)?
    /// A map of values referenced in `expression`.
    expression_values: Dict(Value)?
  }
  response {
    datastore: String?
    /// Items matching the expression.
    items: List(Dict(Value))?
    response_metadata: ResponseMetadata?
  }
}

method apps.datastore.update {
  args {
    /// Attribute names and values to be updated.
    item: Dict(Value)
  }
  response {
    datastore: String?
    /// The complete item including any updated fields.
    item: Dict(Value)?
  }
}

method apps.event.authorizations.list {
  response {
    /// Installations of the app the event is visible to.
    authorizations: List(EventAuthorization)?
    response_metadata: ResponseMetadata?
  }
}

method apps.icon.set {
  args {
    /// The new app icon.
    file: Upload?
  }
  response Nil
}

method apps.managed.permissions.set {
  response Nil
}

method apps.manifest.create {
  args {
    /// The app manifest, sent as a JSON-encoded string.
    manifest: Value json
  }
  response {
    app_id: String
    /// Credentials of the new app.
    credentials: AppCredentials?
    /// URL to install the app.
    oauth_authorize_url: String?
  }
}

method apps.manifest.delete {
  response Nil
}

method apps.manifest.export {
  response {
    /// The app's configuration as a manifest.
    manifest: Value
  }
}

method apps.manifest.update {
  args {
    /// The app manifest, sent as a JSON-encoded string.
    manifest: Value json
  }
  response {
    app_id: String
    /// Whether the update changed the app's permissions (requiring reinstallation).
    permissions_updated: Bool?
  }
}

method apps.manifest.validate {
  args {
    /// The manifest to validate, sent as a JSON-encoded string.
    manifest: Value json
  }
  response {
    /// Problems found in the manifest. Empty when the manifest is valid.
    errors: List(ManifestError)?
  }
}

method apps.uninstall {
  response Nil
}

method apps.user.connection.update {
  args {
    status: UserConnectionStatus
  }
  response Nil
}

/// Whether a user is connected to the app.
enum UserConnectionStatus {
  connected
  disconnected
}
