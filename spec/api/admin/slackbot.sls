//// Admin API methods for managing Slackbot skills across an org.
module slackline/api/admin/slackbot

/// Who a skill is deployed to.
enum SkillPermissionType {
  everyone
  named_entities
  no_one
  .. UnknownSkillPermissionType
}

/// How a skill is deployed across the org.
record SkillAutoEnabled {
  /// The deployment audience.
  permission_type: SkillPermissionType?
  /// User groups the skill is deployed to, for `named_entities`.
  usergroup_ids: List(String)?
}

/// A Slackbot skill (a canvas skill) in the org inventory.
record SlackbotSkill {
  /// The skill ID, which is a file ID such as `F0123ABCD`.
  id: String
  display_name: String?
  description: String?
  category: SkillCategory?
  /// ID of the user who created the skill.
  creator_id: String?
  /// When the skill was created, in Unix seconds.
  date_created: Int?
  /// When the skill was last edited, in Unix seconds.
  date_updated: Int?
  /// Who can see the skill, such as `invite_only`.
  visibility: String?
  is_official: Bool?
  usage_count: Int?
  library_count: Int?
  /// Org deployment, independent of publication.
  auto_enabled: SkillAutoEnabled?
}

method admin.slackbot.skills.list {
  args {
    category: SkillCategory
    publish_status: PublishStatus
    auto_enabled_status: AutoEnabledStatus
    sort: SkillSort
    sort_dir: SortDirection
  }
  response {
    skills: List(SlackbotSkill)?
    response_metadata: ResponseMetadata?
  }
}

method admin.slackbot.skills.publish {
  response Nil
}

method admin.slackbot.skills.unpublish {
  response Nil
}

method admin.slackbot.skills.setAutoEnabled {
  args {
    permission_type: SkillPermissionType
  }
  response {
    /// The skill that was deployed.
    skill_id: String?
    permission_type: SkillPermissionType?
    usergroup_ids: List(String)?
  }
}

/// Filter skills by whether they are published.
enum PublishStatus {
  all as AnyPublishStatus
  published
  unpublished
}

/// Filter skills by whether they are enabled automatically.
enum AutoEnabledStatus {
  all as AnyAutoEnabledStatus
  enabled
  disabled
}

/// How to sort skills.
enum SkillSort {
  name as SortByName
  usage_count
  date_updated
}
