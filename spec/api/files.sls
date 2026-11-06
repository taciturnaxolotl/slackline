//// Slack Web API methods for uploading, sharing and managing files and remote files.
module slackline/api/files

/// A file to finish uploading with `files.completeUploadExternal`.
record UploadedFile {
  /// The file ID returned by `files.getUploadURLExternal`.
  id: String
  /// The title of the file.
  title: String?
}

/// A file returned by `files.completeUploadExternal`.
record CompletedFile {
  /// The file ID.
  id: String
  /// The title of the file.
  title: String?
}

/// Page-based paging details.
record FilesPaging {
  /// The number of items returned.
  count: Int?
  /// The total number of items.
  total: Int?
  /// The page of results returned.
  page: Int?
  /// The total number of pages.
  pages: Int?
}

method files.comments.delete {
  response Nil
}

method files.completeUploadExternal {
  args {
    /// The files to complete, each with its ID and optional title.
    files: List(UploadedFile) json
    /// Comma-separated list of channel IDs or user IDs where the file will be shared.
    channels: List(String)? comma
    /// Structured blocks to use as the message introducing the file. Ignored if `initial_comment` is provided.
    blocks: List(slackline/block.Block)? json
  }
  response {
    /// The uploaded files.
    files: List(CompletedFile)?
  }
}

method files.delete {
  response Nil
}

method files.getUploadURLExternal {
  response {
    /// The URL to POST the file contents to.
    upload_url: String
    /// The ID of the file being uploaded, for `files.completeUploadExternal`.
    file_id: String
  }
}

method files.info {
  args {
    count: Int?
    page: Int?
  }
  response {
    /// The file.
    file: File?
    /// Comments on the file, oldest first.
    comments: List(FileComment)?
    /// Page-based paging for the comments.
    paging: FilesPaging?
    response_metadata: ResponseMetadata?
  }
}

method files.list {
  args {
    count: Int?
    page: Int?
    /// Filter files by type: `all` (default), `spaces`, `snippets`, `images`, `gdocs`, `zips` or `pdfs`.
    types: List(String)? comma
  }
  response {
    /// The files.
    files: List(File)?
    /// Page-based paging information.
    paging: FilesPaging?
    response_metadata: ResponseMetadata?
  }
}

/// `preview_image` and `indexable_file_contents` are binary `multipart/form-data` uploads, which
/// slackline cannot send yet, so they are left out.
method files.remote.add {
  args {
    /// A text file of search terms that improve discovery of the file.
    indexable_file_contents: Upload?
    /// A preview image of the document.
    preview_image: Upload?
  }
  response {
    /// The remote file.
    file: File?
  }
}

method files.remote.info {
  response {
    /// The remote file.
    file: File?
  }
}

method files.remote.list {
  response {
    /// The remote files.
    files: List(File)?
    response_metadata: ResponseMetadata?
  }
}

method files.remote.remove {
  response Nil
}

method files.remote.share {
  args {
    /// Channel IDs where the file will be shared.
    channels: List(String) comma
  }
  response {
    /// The shared remote file.
    file: File?
  }
}

/// `preview_image` and `indexable_file_contents` are binary `multipart/form-data` uploads, which
/// slackline cannot send yet, so they are left out.
method files.remote.update {
  args {
    /// A text file of search terms that improve discovery of the file.
    indexable_file_contents: Upload?
    /// A preview image of the document.
    preview_image: Upload?
  }
  response {
    /// The updated remote file.
    file: File?
  }
}

method files.revokePublicURL {
  response Nil
}

method files.sharedPublicURL {
  response {
    /// The file, including its `permalink_public` URL.
    file: File?
    /// Comments on the file, oldest first.
    comments: List(FileComment)?
    /// Page-based paging for the comments.
    paging: FilesPaging?
  }
}

/// slackline supports only the `content` form of this method. The `file` argument is a binary
/// `multipart/form-data` upload, which slackline cannot send. Prefer
/// `get_upload_url_external` and `complete_upload_external`.
method files.upload {
  args {
    /// The file contents. Send this or `content`.
    file: Upload?
    /// Channel names or IDs where the file will be shared.
    channels: List(String)? comma
  }
  response {
    /// The uploaded file.
    file: File?
  }
}
