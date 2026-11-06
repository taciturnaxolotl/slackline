//// The typed intermediate representation the generator works on: what the
//// `.sls` parser produces, and the facts `spec/methods.json` holds about
//// every Web API method.

import gleam/option.{type Option}

/// A type as written in a spec: `String`, `List(Block)`,
/// `slackline/block.Block`.
pub type TypeExpr {
  TypeExpr(name: String, args: List(TypeExpr))
}

/// The name of the type `T?` stands for inside type arguments, as in
/// `List(T?)`. Not a name a spec can write.
pub const nullable = "?"

pub type Modifier {
  NoModifier
  /// `?`
  Optional
  /// `!`
  Required
}

/// How a list argument is form encoded.
pub type Encoding {
  JsonEncoding
  CommaEncoding
}

/// One line inside `{ ... }`. Docs are `""` when there are none.
pub type Field {
  /// `key [as name]: Type [?|!] [json|comma]`
  Field(
    key: String,
    name: Option(String),
    type_: TypeExpr,
    modifier: Modifier,
    encoding: Option(Encoding),
    docs: String,
  )
  /// `key = "value"`
  Const(key: String, value: String, docs: String)
  /// `-key`, only allowed in method `args`.
  Drop(key: String)
}

pub type Variant {
  /// `tag Name { fields }` (or no braces at all).
  FieldsVariant(tag: String, name: String, fields: List(Field), docs: String)
  /// `tag Name(Record)`
  WrapVariant(
    tag: String,
    name: String,
    wraps: String,
    docs: String,
    /// `builder(a, b)`: the fields the builder takes as arguments.
    builder: Option(List(String)),
  )
}

/// The `.. Name` catch-all of a union or open enum.
pub type Catchall {
  Catchall(name: String, docs: String)
}

pub type EnumValue {
  EnumValue(value: String, name: Option(String), docs: String)
}

pub type OneofVariant {
  OneofVariant(name: String, type_: TypeExpr, docs: String)
}

pub type Response {
  ResponseFields(fields: List(Field))
  ResponseType(type_: TypeExpr)
}

/// A declared type. Each variant wraps the record its renderer takes.
pub type Item {
  RecordItem(Record)
  UnionItem(Union)
  EnumItem(Enum)
  OneofItem(Oneof)
}

pub type Record {
  Record(name: String, docs: String, file: String, fields: List(Field))
}

pub type Union {
  Union(
    name: String,
    docs: String,
    file: String,
    tag: String,
    optional_tag: Bool,
    variants: List(Variant),
    unknown: Catchall,
    /// `builders [".."]`: generate builders, in this module ("" for the
    /// union's own module).
    builders: Option(String),
  )
}

pub type Enum {
  Enum(
    name: String,
    docs: String,
    file: String,
    values: List(EnumValue),
    unknown: Option(Catchall),
  )
}

pub type Oneof {
  Oneof(name: String, docs: String, file: String, variants: List(OneofVariant))
}

/// `method name [as function] [unauthenticated] { .. }`
pub type Method {
  Method(
    name: String,
    docs: String,
    file: String,
    function: Option(String),
    unauthenticated: Bool,
    args: List(Field),
    response: Option(Response),
  )
}

pub fn item_name(item: Item) -> String {
  case item {
    RecordItem(Record(name:, ..))
    | UnionItem(Union(name:, ..))
    | EnumItem(Enum(name:, ..))
    | OneofItem(Oneof(name:, ..)) -> name
  }
}

pub fn item_file(item: Item) -> String {
  case item {
    RecordItem(Record(file:, ..))
    | UnionItem(Union(file:, ..))
    | EnumItem(Enum(file:, ..))
    | OneofItem(Oneof(file:, ..)) -> file
  }
}

/// One `.sls` file.
pub type Module {
  Module(
    path: String,
    docs: List(String),
    items: List(Item),
    methods: List(Method),
    file: String,
  )
}

// ---- spec/methods.json -----------------------------------------------------

pub type DocsMethod {
  DocsMethod(
    name: String,
    summary: String,
    deprecated: Bool,
    url: String,
    rate_limit: Option(String),
    bot_scopes: List(String),
    user_scopes: List(String),
    args: List(DocsArg),
    errors: List(String),
    examples: List(Example),
  )
}

pub type DocsArg {
  DocsArg(
    name: String,
    type_: Option(String),
    required: Bool,
    description: String,
    default: Option(String),
    example: Option(String),
  )
}

pub type Example {
  Example(title: String, body: String)
}

/// A response example test to generate: which module and decoder to use.
pub type ExampleCase {
  ExampleCase(
    module_path: String,
    method: String,
    function: String,
    decoder: TestDecoder,
    examples: List(Example),
  )
}

pub type TestDecoder {
  /// A decoder function defined in the method's own module.
  LocalDecoder(function: String)
  /// The decoder of a spec type.
  TypeDecoder(type_: TypeExpr)
}
