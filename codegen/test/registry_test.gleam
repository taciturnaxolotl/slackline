//// Each type name may only be declared once across all specs.

import gleam/string
import slackline_codegen/generate/module
import slackline_codegen/generate/registry

pub fn same_name_in_two_modules_is_an_error_test() {
  let specs = [
    #("spec/a.sls", "module slackline/a\nrecord Thing { id: String }\n"),
    #("spec/b.sls", "module slackline/b\nenum Thing { one }\n"),
  ]
  let assert Ok(modules) = module.load(specs)
  let assert Error(message) = registry.from_modules(modules)
  assert string.contains(message, "spec/b.sls: type Thing is already declared")
}
