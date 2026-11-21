//// The [SCIM API](https://docs.slack.dev/reference/scim-api) v2 at
//// `api.slack.com/scim/v2`, for provisioning users and groups on Business+
//// and Enterprise plans. It needs an organization owner's token with the
//// `admin` scope.
module slackline/scim

/// When a resource was created and where it lives.
record ScimMeta {
  /// An ISO 8601 timestamp.
  created: String?
  location: String?
}

/// A user's name.
record ScimName {
  "givenName" as given_name: String?
  "familyName" as family_name: String?
  "honorificPrefix" as honorific_prefix: String?
}

/// One of several values, such as an email address or phone number.
record ScimValue {
  value: String?
  primary: Bool?
  "type" as value_type: String?
  display: String?
}

/// A postal address.
record ScimAddress {
  "streetAddress" as street_address: String?
  locality: String?
  region: String?
  "postalCode" as postal_code: String?
  country: String?
  primary: Bool?
}

/// A user's manager.
record ScimManager {
  "managerId" as manager_id: String?
}

/// The enterprise extension of a user.
record ScimEnterpriseUser {
  "employeeNumber" as employee_number: String?
  "costCenter" as cost_center: String?
  organization: String?
  division: String?
  department: String?
  manager: ScimManager?
}

/// Slack's profile extension of a user.
record ScimSlackProfile {
  "startDate" as start_date: String?
}

/// A Slack user.
record ScimUser {
  schemas: List(String)?
  id: String
  "externalId" as external_id: String?
  meta: ScimMeta?
  "userName" as user_name: String?
  "nickName" as nick_name: String?
  name: ScimName?
  "displayName" as display_name: String?
  "profileUrl" as profile_url: String?
  title: String?
  timezone: String?
  active: Bool?
  emails: List(ScimValue)?
  photos: List(ScimValue)?
  addresses: List(ScimAddress)?
  "phoneNumbers" as phone_numbers: List(ScimValue)?
  "userType" as user_type: String?
  roles: List(ScimValue)?
  "preferredLanguage" as preferred_language: String?
  locale: String?
  "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User" as enterprise: ScimEnterpriseUser?
  "urn:ietf:params:scim:schemas:extension:slack:profile:2.0:User" as slack_profile: ScimSlackProfile?
  /// The groups the user is in.
  groups: List(ScimValue)?
}

/// A Slack IDP group.
record ScimGroup {
  schemas: List(String)?
  id: String
  meta: ScimMeta?
  "displayName" as display_name: String?
  members: List(ScimValue)?
}

/// A page of users.
record ScimUsers {
  "Resources" as resources: List(ScimUser)
  "totalResults" as total_results: Int?
  "itemsPerPage" as items_per_page: Int?
  "startIndex" as start_index: Int?
}

/// A page of groups.
record ScimGroups {
  "Resources" as resources: List(ScimGroup)
  "totalResults" as total_results: Int?
  "itemsPerPage" as items_per_page: Int?
  "startIndex" as start_index: Int?
}

/// One change in a `PATCH` request.
record PatchOperation {
  /// `add`, `replace` or `remove`.
  op: String
  /// The attribute to change, such as `title` or
  /// `urn:ietf:params:scim:schemas:extension:enterprise:2.0:User:costCenter`.
  path: String?
  value: Value?
}

/// The attributes of a user to create or replace. Slack sets `id` and `meta`.
/// Start from `new_user`.
record ScimUserInput {
  schemas: List(String)
  "userName" as user_name: String
  emails: List(ScimValue)
  "nickName" as nick_name: String?
  name: ScimName?
  "displayName" as display_name: String?
  "profileUrl" as profile_url: String?
  title: String?
  timezone: String?
  active: Bool?
  "externalId" as external_id: String?
  photos: List(ScimValue)?
  addresses: List(ScimAddress)?
  "phoneNumbers" as phone_numbers: List(ScimValue)?
  "userType" as user_type: String?
  roles: List(ScimValue)?
  "preferredLanguage" as preferred_language: String?
  locale: String?
  "urn:ietf:params:scim:schemas:extension:enterprise:2.0:User" as enterprise: ScimEnterpriseUser?
  "urn:ietf:params:scim:schemas:extension:slack:profile:2.0:User" as slack_profile: ScimSlackProfile?
}

/// The attributes of a group to create or replace. Slack sets `id` and `meta`.
/// Start from `new_group`.
record ScimGroupInput {
  schemas: List(String)
  "displayName" as display_name: String
  /// Each member's user ID as `value`.
  members: List(ScimValue)
}
