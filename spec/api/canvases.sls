//// Slack Web API methods for creating, editing and sharing canvases.
module slackline/api/canvases

/// One edit to apply to a canvas, chosen by `operation`.
union CanvasChange tag "operation" {
  /// Insert content after the section `section_id`.
  insert_after InsertAfterChange {
    section_id: String
    document_content: CanvasDocumentContent
  }
  /// Insert content before the section `section_id`.
  insert_before InsertBeforeChange {
    section_id: String
    document_content: CanvasDocumentContent
  }
  /// Insert content at the beginning of the canvas.
  insert_at_start InsertAtStartChange {
    document_content: CanvasDocumentContent
  }
  /// Insert content at the end of the canvas.
  insert_at_end InsertAtEndChange {
    document_content: CanvasDocumentContent
  }
  /// Replace the section `section_id`, or the whole canvas when it is omitted.
  replace ReplaceChange {
    section_id: String?
    document_content: CanvasDocumentContent
  }
  /// Delete the section `section_id`.
  delete DeleteChange {
    section_id: String
  }
  /// Rename the canvas. Markdown, including emoji, is supported.
  rename RenameChange {
    title_content: CanvasDocumentContent
  }
  .. UnknownCanvasChange
}

/// Section types that can be used to filter `canvases.sections.lookup`.
enum CanvasSectionType {
  any_header
  blockquote
  callout
  canvas_unfurl
  chart
  citation
  file_unfurl
  flexbox
  h1
  h2
  h3
  horizontal_line
  "list" as ListSection
  message_unfurl
  sfdc_record_mention
  sfdc_record_unfurl
  table
  user_mention
  user_unfurl
}

/// Criteria for finding sections in a canvas. Criteria combine to narrow the result.
record CanvasSectionCriteria {
  /// Match sections of these types.
  section_types: List(CanvasSectionType)?
  /// Match sections containing this text.
  contains_text: String?
}

/// A canvas section returned by `canvases.sections.lookup`.
record CanvasSection {
  /// The section ID, for use with `canvases.edit`.
  id: String
}

method canvases.access.delete {
  args {
    canvas_id: String
    /// List of channels to remove access for.
    channel_ids: List(String) comma
    /// List of users to remove access for.
    user_ids: List(String) comma
  }
  response Nil
}

method canvases.access.set {
  args {
    canvas_id: String
    /// Desired level of access: `read`, `write` or `owner`.
    access_level: CanvasAccessLevel!
    /// List of channels to update access for. Can only be used if `user_ids` is not provided.
    channel_ids: List(String) comma
    /// List of users to update access for. Can only be used if `channel_ids` is not provided.
    user_ids: List(String) comma
  }
  response Nil
}

method canvases.create {
  args {
    /// The initial content of the canvas.
    document_content: CanvasDocumentContent? json
  }
  response {
    /// The ID of the new canvas.
    canvas_id: String
  }
}

method canvases.delete {
  args {
    canvas_id: String
  }
  response Nil
}

method canvases.edit {
  args {
    canvas_id: String
    /// The changes to apply. Only one change per call is currently supported.
    changes: List(CanvasChange) json
  }
  response Nil
}

method canvases.getContent {
  args {
    canvas_id: String
    /// Format in which to return the canvas content: `html` or `markdown` (the default).
    content_type: CanvasContentType?
  }
  response {
    /// The entire canvas content, in the requested format.
    content: String?
  }
}

method canvases.sections.lookup {
  args {
    canvas_id: String
    /// Filtering criteria.
    criteria: CanvasSectionCriteria json
  }
  response {
    /// The matching sections.
    sections: List(CanvasSection)?
  }
}

/// The access level granted to a canvas.
enum CanvasAccessLevel {
  read as ReadAccess
  write as WriteAccess
  owner as OwnerAccess
}

/// The format of returned canvas content.
enum CanvasContentType {
  html as Html
  markdown as Markdown
}
