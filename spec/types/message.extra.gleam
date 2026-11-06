import gleam/option.{None, Some}

/// Metadata for an app event, for the `metadata` argument of
/// `chat.postMessage` and `chat.update`.
///
/// ```gleam
/// message.event_metadata("ticket_created", value.Object([
///   #("ticket_id", value.String("PROJ-1234")),
/// ]))
/// ```
pub fn event_metadata(
  event_type: String,
  event_payload: value.Value,
) -> MessageMetadata {
  MessageMetadata(
    event_type: Some(event_type),
    event_payload: Some(event_payload),
    entities: None,
    entity_type: None,
    entity_payload: None,
  )
}

/// Metadata with Work Object entities, for `chat.postMessage`,
/// `chat.postEphemeral` and `chat.unfurl`.
pub fn entities_metadata(entities: List(WorkObjectEntity)) -> MessageMetadata {
  MessageMetadata(
    event_type: None,
    event_payload: None,
    entities: Some(entities),
    entity_type: None,
    entity_payload: None,
  )
}

/// Metadata with one Work Object entity type and payload, for the flexpane
/// of `entity.presentDetails`.
pub fn entity_details_metadata(
  entity_type: String,
  entity_payload: value.Value,
) -> MessageMetadata {
  MessageMetadata(
    event_type: None,
    event_payload: None,
    entities: None,
    entity_type: Some(entity_type),
    entity_payload: Some(entity_payload),
  )
}

/// A Work Object entity from its required fields. `external_id` is the ID of
/// the resource in your system. Set the optional fields with record update
/// syntax.
pub fn work_object_entity(
  entity_type entity_type: String,
  external_id external_id: String,
  url url: String,
  entity_payload entity_payload: value.Value,
) -> WorkObjectEntity {
  WorkObjectEntity(
    entity_type:,
    external_ref: ExternalRef(id: external_id, ref_type: None),
    url:,
    entity_payload:,
    app_unfurl_url: None,
    is_refreshable: None,
    entity_comments: None,
  )
}
