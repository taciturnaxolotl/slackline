//// `Upload` is file contents sent as a multipart part. Only a method
//// argument can have it, and only directly.

import gleam/dict
import gleam/option.{None}
import gleam/string
import slackline_codegen/generate/fields
import slackline_codegen/generate/ir
import slackline_codegen/generate/registry
import slackline_codegen/generate/types

fn scope() -> types.Scope {
  types.Scope(
    module_path: "slackline/api/users",
    registry: registry.new(),
    aliases: dict.new(),
  )
}

fn field(type_: ir.TypeExpr) -> ir.Field {
  ir.Field(
    key: "image",
    name: None,
    type_:,
    modifier: ir.Optional,
    encoding: None,
    docs: "",
  )
}

const upload = ir.TypeExpr("Upload", [])

pub fn upload_argument_is_allowed_test() {
  let assert Ok([fields.PField(type_: types.RFile, ..)]) =
    fields.prepare_args([field(upload)], "users.setPhoto", scope())
}

pub fn upload_in_a_record_is_an_error_test() {
  let assert Error(message) =
    fields.prepare([field(upload)], "Profile", None, scope())
  assert string.contains(message, "Upload is only for method arguments")
}

pub fn upload_inside_a_list_is_an_error_test() {
  let assert Error(message) =
    fields.prepare_args(
      [field(ir.TypeExpr("List", [upload]))],
      "users.setPhoto",
      scope(),
    )
  assert string.contains(message, "Upload cannot be inside a type")
}

pub fn required_upload_cannot_be_form_encoded_test() {
  let assert Error(message) = types.form_encoder(types.RFile, None, scope())
  assert string.contains(message, "must be optional")
}
