//// Slackbot skills: create, update, share and toggle skills for Slackbot.
module slackline/api/slackbot

/// An app (MCP server) a skill needs.
record SkillMcpServer {
  /// Kind of server, such as `app`.
  service_type: String?
  /// ID of the app providing the server.
  app_id: String?
  /// ID of the MCP server.
  server_id: String?
  /// Name of the app.
  display_name: String?
  /// Whether the server is available to the caller.
  is_available: Bool?
}

/// A Slackbot skill.
record Skill {
  /// A canvas file ID, or a `builtin:` reference for built-in skills.
  id: String
  /// Kind of skill, such as `canvas`.
  type: String?
  /// Human-readable label.
  display_name: String?
  # `null` for canvas skills in the docs examples.
  /// Name of the skill.
  name: String?
  /// When Slackbot should use the skill.
  description: String?
  /// One of the skill categories, such as `productivity`.
  category: String?
  /// Example prompt. `{skill}` becomes the skill mention.
  example_prompt: String?
  /// Markdown body of the skill. Only returned by `slackbot.skills.info`.
  instructions: String?
  /// Who can see the skill, such as `invite_only` or `anyone_can_view`.
  visibility: String?
  /// Whether the skill is one of the organization's official skills.
  is_official: Bool?
  /// The caller's effective access to the skill canvas: `read`, `comment`, `write` or `owner`.
  access: String?
  /// Apps the skill needs.
  mcp_servers: List(SkillMcpServer)?
  /// How many times the skill was used.
  usage_count: Int?
  /// How many libraries the skill is in.
  library_count: Int?
  /// User who created the skill.
  creator_id: String?
  date_created: Int?
  date_updated: Int?
  /// Permalink to the skill's canvas.
  permalink: String?
}

method slackbot.skills.create {
  args {
    # The docs do not describe the shape of an item.
    /// Apps the skill needs.
    mcp_servers: List(Value)? json
    category: SkillCategory
  }
  response {
    /// The created skill.
    skill: Skill
  }
}

method slackbot.skills.delete {
  response Nil
}

method slackbot.skills.info {
  response {
    /// The skill, including its instructions.
    skill: Skill
  }
}

method slackbot.skills.library.add {
  response Nil
}

method slackbot.skills.library.remove {
  response Nil
}

method slackbot.skills.list {
  args {
    filter: SkillFilter
  }
  response {
    /// Skills, without instructions.
    skills: List(Skill)?
    response_metadata: ResponseMetadata?
  }
}

method slackbot.skills.update {
  args {
    # The docs do not describe the shape of an item.
    /// Apps the skill needs. Replaces the whole list. Send an empty list to clear it.
    mcp_servers: List(Value)? json
    category: SkillCategory
  }
  response {
    /// The updated skill.
    skill: Skill
  }
}

/// Which skills to list.
enum SkillFilter {
  library
  owned
  catalog
}
