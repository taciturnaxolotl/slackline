//// Tokenizer and parser for the slackline schema language (`.sls` files).
//// See `spec/README.md` for the language itself.

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import slackline_codegen/generate/ir.{
  type Catchall, type EnumValue, type Field, type Item, type Method, type Module,
  type OneofVariant, type Response, type TypeExpr, type Variant,
}

// ---- tokens ----------------------------------------------------------------

pub type Kind {
  ModDoc
  Doc
  Str
  Dots
  Ident
  Sym
  Eof
}

pub type Token {
  Token(kind: Kind, value: String, line: Int)
}

/// A parse error: the line it is on and what is wrong.
type Failure =
  #(Int, String)

fn kind_name(kind: Kind) -> String {
  case kind {
    ModDoc -> "moddoc"
    Doc -> "doc"
    Str -> "string"
    Dots -> "dots"
    Ident -> "ident"
    Sym -> "sym"
    Eof -> "eof"
  }
}

const symbols = "{}()[]:?!,=-"

fn scan(
  text: String,
  line: Int,
  acc: List(Token),
) -> Result(List(Token), Failure) {
  case text {
    "////" <> rest -> {
      let #(body, rest) = until_newline(rest)
      scan(rest, line, [Token(ModDoc, doc_text(body), line), ..acc])
    }
    "///" <> rest -> {
      let #(body, rest) = until_newline(rest)
      scan(rest, line, [Token(Doc, doc_text(body), line), ..acc])
    }
    "#" <> rest -> scan(until_newline(rest).1, line, acc)
    "\n" <> rest -> scan(rest, line + 1, acc)
    " " <> rest | "\t" <> rest | "\r" <> rest -> scan(rest, line, acc)
    ".." <> rest -> scan(rest, line, [Token(Dots, "..", line), ..acc])
    "\"" <> rest -> {
      use #(value, rest) <- result.try(string_literal(rest, "", line))
      scan(rest, line, [Token(Str, value, line), ..acc])
    }
    _ ->
      case string.pop_grapheme(text) {
        Error(Nil) -> Ok(list.reverse([Token(Eof, "", line), ..acc]))
        Ok(#(char, rest)) ->
          case is_ident_start(char), string.contains(symbols, char) {
            True, _ -> {
              let #(ident, rest) = identifier(text, "")
              scan(rest, line, [Token(Ident, ident, line), ..acc])
            }
            _, True -> scan(rest, line, [Token(Sym, char, line), ..acc])
            _, _ ->
              Error(#(line, "unexpected character " <> string.inspect(char)))
          }
      }
  }
}

/// The text up to the next newline, and the rest starting at that newline.
fn until_newline(text: String) -> #(String, String) {
  case string.split_once(text, "\n") {
    Ok(#(body, rest)) -> #(body, "\n" <> rest)
    Error(Nil) -> #(text, "")
  }
}

/// The text of a doc comment after its slashes, minus one leading space.
fn doc_text(body: String) -> String {
  case body {
    " " <> rest -> rest
    _ -> body
  }
}

const letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"

fn is_ident_start(char: String) -> Bool {
  string.length(char) == 1 && string.contains(letters, char)
}

fn is_ident_char(char: String) -> Bool {
  is_ident_start(char)
  || { string.length(char) == 1 && string.contains("0123456789", char) }
}

/// `[A-Za-z_][A-Za-z0-9_]*` segments joined by `.` or `/`.
fn identifier(text: String, acc: String) -> #(String, String) {
  case string.pop_grapheme(text) {
    Error(Nil) -> #(acc, text)
    Ok(#(char, rest)) ->
      case is_ident_char(char), char == "." || char == "/" {
        True, _ -> identifier(rest, acc <> char)
        _, True ->
          case string.pop_grapheme(rest) {
            Ok(#(next, _)) ->
              case is_ident_start(next) {
                True -> identifier(rest, acc <> char)
                False -> #(acc, text)
              }
            Error(Nil) -> #(acc, text)
          }
        _, _ -> #(acc, text)
      }
  }
}

/// The value of a string literal up to its closing quote. The only escapes
/// are `\"` and `\\`.
fn string_literal(
  text: String,
  acc: String,
  line: Int,
) -> Result(#(String, String), Failure) {
  case text {
    "\"" <> rest -> Ok(#(acc, rest))
    "\\\"" <> rest -> string_literal(rest, acc <> "\"", line)
    "\\\\" <> rest -> string_literal(rest, acc <> "\\", line)
    "\\" <> _ -> Error(#(line, "invalid escape in string"))
    "\n" <> _ -> Error(#(line, "unterminated string"))
    _ ->
      case string.pop_grapheme(text) {
        Ok(#(char, rest)) -> string_literal(rest, acc <> char, line)
        Error(Nil) -> Error(#(line, "unterminated string"))
      }
  }
}

// ---- parser ----------------------------------------------------------------

type Tokens =
  List(Token)

type Parsed(a) =
  Result(#(a, Tokens), Failure)

pub fn parse(text: String, path: String) -> Result(Module, String) {
  let parsed =
    scan(text, 1, [])
    |> result.try(declarations(_, ir.Module("", [], [], [], path)))
    |> result.map_error(fn(failure) {
      path <> ":" <> int.to_string(failure.0) <> ": " <> failure.1
    })
  use module <- result.try(parsed)
  case module.path {
    "" -> Error(path <> ": missing `module` declaration")
    _ ->
      Ok(
        ir.Module(
          ..module,
          docs: list.reverse(module.docs),
          items: list.reverse(module.items),
          methods: list.reverse(module.methods),
        ),
      )
  }
}

fn peek(tokens: Tokens) -> Token {
  case tokens {
    [token, ..] -> token
    [] -> Token(Eof, "", 0)
  }
}

fn advance(tokens: Tokens) -> #(Token, Tokens) {
  case tokens {
    [Token(Eof, ..)] | [] -> #(peek(tokens), tokens)
    [token, ..rest] -> #(token, rest)
  }
}

fn fail(tokens: Tokens, message: String) -> Result(a, Failure) {
  let token = peek(tokens)
  let found = case token.kind {
    Eof -> "the end of the file"
    _ -> string.inspect(token.value)
  }
  Error(#(token.line, message <> " (found " <> found <> ")"))
}

/// Consumes the next token if it is `kind` (with `value`, unless that is "").
fn accept(
  tokens: Tokens,
  kind: Kind,
  value: String,
) -> Result(#(Token, Tokens), Nil) {
  let token = peek(tokens)
  case token.kind == kind && { value == "" || token.value == value } {
    True -> Ok(advance(tokens))
    False -> Error(Nil)
  }
}

fn expect(tokens: Tokens, kind: Kind, value: String) -> Parsed(String) {
  case accept(tokens, kind, value) {
    Ok(#(token, rest)) -> Ok(#(token.value, rest))
    Error(Nil) ->
      fail(tokens, case value {
        "" -> "expected " <> kind_name(kind)
        _ -> "expected " <> value
      })
  }
}

/// `as name`, if that is what comes next.
fn rename(tokens: Tokens) -> Parsed(Option(String)) {
  case accept(tokens, Ident, "as") {
    Ok(#(_, rest)) -> {
      use #(name, rest) <- result.map(expect(rest, Ident, ""))
      #(Some(name), rest)
    }
    Error(Nil) -> Ok(#(None, tokens))
  }
}

fn skip_commas(tokens: Tokens) -> Tokens {
  case accept(tokens, Sym, ",") {
    Ok(#(_, rest)) -> skip_commas(rest)
    Error(Nil) -> tokens
  }
}

/// Consecutive `///` lines, joined with newlines.
fn docs(tokens: Tokens) -> #(String, Tokens) {
  let #(lines, rest) = list.split_while(tokens, fn(token) { token.kind == Doc })
  #(lines |> list.map(fn(token) { token.value }) |> string.join("\n"), rest)
}

/// What an entry parser of `braced` found.
type Entry(a) {
  Entry(a)
  /// `.. [Name]`
  CatchallEntry(Catchall)
}

/// `open entry, entry close`. Each entry can have `///` docs before it and
/// commas after it. Returns the entries and the last catch-all.
fn braced(
  tokens: Tokens,
  open: String,
  close: String,
  entry: fn(Tokens, String) -> Parsed(Entry(a)),
) -> Parsed(#(List(a), Option(Catchall))) {
  use #(_, rest) <- result.try(expect(tokens, Sym, open))
  braced_loop(rest, close, entry, [], None)
}

fn braced_loop(
  tokens: Tokens,
  close: String,
  entry: fn(Tokens, String) -> Parsed(Entry(a)),
  acc: List(a),
  unknown: Option(Catchall),
) -> Parsed(#(List(a), Option(Catchall))) {
  let #(docs, tokens) = docs(tokens)
  case accept(tokens, Sym, close) {
    Ok(#(_, rest)) -> Ok(#(#(list.reverse(acc), unknown), rest))
    Error(Nil) -> {
      use #(found, rest) <- result.try(entry(tokens, docs))
      let rest = skip_commas(rest)
      case found {
        Entry(item) -> braced_loop(rest, close, entry, [item, ..acc], unknown)
        CatchallEntry(catchall) ->
          braced_loop(rest, close, entry, acc, Some(catchall))
      }
    }
  }
}

/// `.. [Name]`, if that is what comes next, else `entry`.
fn or_catchall(
  tokens: Tokens,
  docs: String,
  type_name: String,
  entry: fn(Tokens, String) -> Parsed(Entry(a)),
) -> Parsed(Entry(a)) {
  case accept(tokens, Dots, "") {
    Error(Nil) -> entry(tokens, docs)
    Ok(#(_, rest)) ->
      case accept(rest, Ident, "") {
        Ok(#(token, rest)) ->
          Ok(#(CatchallEntry(ir.Catchall(token.value, docs)), rest))
        Error(Nil) ->
          Ok(#(CatchallEntry(ir.Catchall("Unknown" <> type_name, docs)), rest))
      }
  }
}

fn declarations(tokens: Tokens, module: Module) -> Result(Module, Failure) {
  case peek(tokens) {
    Token(Eof, ..) -> Ok(module)
    Token(ModDoc, value, _) ->
      declarations(
        advance(tokens).1,
        ir.Module(..module, docs: [value, ..module.docs]),
      )
    _ -> {
      let #(docs, tokens) = docs(tokens)
      use #(keyword, after) <- result.try(expect(tokens, Ident, ""))
      let item = fn(parsed: Parsed(Item)) {
        use #(item, rest) <- result.try(parsed)
        declarations(rest, ir.Module(..module, items: [item, ..module.items]))
      }
      case keyword {
        "module" -> {
          use #(path, rest) <- result.try(expect(after, Ident, ""))
          declarations(rest, ir.Module(..module, path:))
        }
        "record" -> item(record(after, docs, module.file))
        "union" -> item(union(after, docs, module.file))
        "enum" -> item(enum(after, docs, module.file))
        "oneof" -> item(oneof(after, docs, module.file))
        "method" -> {
          use #(method, rest) <- result.try(method(after, docs, module.file))
          declarations(
            rest,
            ir.Module(..module, methods: [method, ..module.methods]),
          )
        }
        _ -> fail(tokens, "expected a declaration")
      }
    }
  }
}

fn type_expr(tokens: Tokens) -> Parsed(TypeExpr) {
  use #(name, rest) <- result.try(expect(tokens, Ident, ""))
  case accept(rest, Sym, "(") {
    Error(Nil) -> Ok(#(ir.TypeExpr(name, []), rest))
    Ok(#(_, rest)) -> {
      use #(args, rest) <- result.try(type_args(rest, []))
      use #(_, rest) <- result.try(expect(rest, Sym, ")"))
      Ok(#(ir.TypeExpr(name, args), rest))
    }
  }
}

fn type_args(tokens: Tokens, acc: List(TypeExpr)) -> Parsed(List(TypeExpr)) {
  use #(arg, rest) <- result.try(type_expr(tokens))
  // `List(T?)`: items that can be json `null`.
  let #(arg, rest) = case accept(rest, Sym, "?") {
    Ok(#(_, rest)) -> #(ir.TypeExpr(ir.nullable, [arg]), rest)
    Error(Nil) -> #(arg, rest)
  }
  case accept(rest, Sym, ",") {
    Ok(#(_, rest)) -> type_args(rest, [arg, ..acc])
    Error(Nil) -> Ok(#(list.reverse([arg, ..acc]), rest))
  }
}

/// An identifier or a string literal.
fn name_token(tokens: Tokens, message: String) -> Parsed(String) {
  case advance(tokens) {
    #(Token(Ident, value, _), rest) | #(Token(Str, value, _), rest) ->
      Ok(#(value, rest))
    _ -> fail(tokens, message)
  }
}

/// The fields in `{ .. }`. `overrides` allows `-key` (in method `args`).
fn fields(tokens: Tokens, overrides: Bool) -> Parsed(List(Field)) {
  use #(#(fields, _), rest) <- result.map(
    braced(tokens, "{", "}", fn(tokens, docs) {
      use #(field, rest) <- result.map(field(tokens, docs, overrides))
      #(Entry(field), rest)
    }),
  )
  #(fields, rest)
}

/// `key [as name]: Type [?|!] [json|comma]`, `key = "constant"` or `-key`.
fn field(tokens: Tokens, docs: String, overrides: Bool) -> Parsed(Field) {
  case overrides, accept(tokens, Sym, "-") {
    True, Ok(#(_, rest)) -> {
      use #(key, rest) <- result.map(name_token(rest, "expected a field name"))
      #(ir.Drop(key), rest)
    }
    _, _ -> {
      use #(key, rest) <- result.try(name_token(tokens, "expected a field name"))
      case accept(rest, Sym, "=") {
        Ok(#(_, rest)) -> {
          use #(value, rest) <- result.map(expect(rest, Str, ""))
          #(ir.Const(key, value, docs), rest)
        }
        Error(Nil) -> typed_field(rest, key, docs)
      }
    }
  }
}

fn typed_field(tokens: Tokens, key: String, docs: String) -> Parsed(Field) {
  use #(name, rest) <- result.try(rename(tokens))
  use #(_, rest) <- result.try(expect(rest, Sym, ":"))
  use #(type_, rest) <- result.try(type_expr(rest))
  let #(modifier, rest) = case advance(rest) {
    #(Token(Sym, "?", _), after) -> #(ir.Optional, after)
    #(Token(Sym, "!", _), after) -> #(ir.Required, after)
    _ -> #(ir.NoModifier, rest)
  }
  let #(encoding, rest) = case advance(rest) {
    #(Token(Ident, "json", _), after) -> #(Some(ir.JsonEncoding), after)
    #(Token(Ident, "comma", _), after) -> #(Some(ir.CommaEncoding), after)
    _ -> #(None, rest)
  }
  Ok(#(ir.Field(key, name, type_, modifier, encoding, docs), rest))
}

fn record(tokens: Tokens, docs: String, file: String) -> Parsed(Item) {
  use #(name, rest) <- result.try(expect(tokens, Ident, ""))
  use #(fields, rest) <- result.map(fields(rest, False))
  #(ir.RecordItem(ir.Record(name:, docs:, file:, fields:)), rest)
}

fn union(tokens: Tokens, docs: String, file: String) -> Parsed(Item) {
  use #(name, rest) <- result.try(expect(tokens, Ident, ""))
  use #(#(tag, optional_tag), rest) <- result.try(
    case accept(rest, Ident, "tag") {
      Ok(#(_, rest)) -> {
        use #(tag, rest) <- result.map(expect(rest, Str, ""))
        case accept(rest, Ident, "optional") {
          Ok(#(_, rest)) -> #(#(tag, True), rest)
          Error(Nil) -> #(#(tag, False), rest)
        }
      }
      Error(Nil) -> Ok(#(#("type", False), rest))
    },
  )
  let #(builders, rest) = case accept(rest, Ident, "builders") {
    Ok(#(_, rest)) ->
      case accept(rest, Str, "") {
        Ok(#(token, rest)) -> #(Some(token.value), rest)
        Error(Nil) -> #(Some(""), rest)
      }
    Error(Nil) -> #(None, rest)
  }
  use #(#(variants, unknown), rest) <- result.map(
    braced(rest, "{", "}", fn(tokens, docs) {
      or_catchall(tokens, docs, name, variant)
    }),
  )
  let unknown = option.unwrap(unknown, ir.Catchall("Unknown" <> name, ""))
  let union =
    ir.Union(
      name:,
      docs:,
      file:,
      tag:,
      optional_tag:,
      variants:,
      unknown:,
      builders:,
    )
  #(ir.UnionItem(union), rest)
}

/// `tag Name { fields }`, `tag Name` or `tag Name(Record) [builder(..)]`.
fn variant(tokens: Tokens, docs: String) -> Parsed(Entry(Variant)) {
  use #(tag, rest) <- result.try(name_token(tokens, "expected a tag value"))
  use #(ctor, rest) <- result.try(expect(rest, Ident, ""))
  use #(variant, rest) <- result.map(case accept(rest, Sym, "(") {
    Ok(#(_, rest)) -> {
      use #(wraps, rest) <- result.try(expect(rest, Ident, ""))
      use #(_, rest) <- result.try(expect(rest, Sym, ")"))
      use #(builder, rest) <- result.map(builder_args(rest))
      #(ir.WrapVariant(tag, ctor, wraps, docs, builder), rest)
    }
    Error(Nil) ->
      case peek(rest) {
        Token(Sym, "{", _) -> {
          use #(fields, rest) <- result.map(fields(rest, False))
          #(ir.FieldsVariant(tag, ctor, fields, docs), rest)
        }
        _ -> Ok(#(ir.FieldsVariant(tag, ctor, [], docs), rest))
      }
  })
  #(Entry(variant), rest)
}

/// `builder(field, ..)` after a wrapping variant.
fn builder_args(tokens: Tokens) -> Parsed(Option(List(String))) {
  case accept(tokens, Ident, "builder") {
    Error(Nil) -> Ok(#(None, tokens))
    Ok(#(_, rest)) -> {
      use #(#(names, _), rest) <- result.map(
        braced(rest, "(", ")", fn(tokens, _docs) {
          use #(name, rest) <- result.map(expect(tokens, Ident, ""))
          #(Entry(name), rest)
        }),
      )
      #(Some(names), rest)
    }
  }
}

fn enum(tokens: Tokens, docs: String, file: String) -> Parsed(Item) {
  use #(name, rest) <- result.try(expect(tokens, Ident, ""))
  use #(#(values, unknown), rest) <- result.map(
    braced(rest, "{", "}", fn(tokens, docs) {
      or_catchall(tokens, docs, name, enum_value)
    }),
  )
  #(ir.EnumItem(ir.Enum(name:, docs:, file:, values:, unknown:)), rest)
}

fn enum_value(tokens: Tokens, docs: String) -> Parsed(Entry(EnumValue)) {
  use #(value, rest) <- result.try(name_token(tokens, "expected an enum value"))
  use #(ctor, rest) <- result.map(rename(rest))
  #(Entry(ir.EnumValue(value, ctor, docs)), rest)
}

fn oneof(tokens: Tokens, docs: String, file: String) -> Parsed(Item) {
  use #(name, rest) <- result.try(expect(tokens, Ident, ""))
  use #(#(variants, _), rest) <- result.map(braced(
    rest,
    "{",
    "}",
    oneof_variant,
  ))
  #(ir.OneofItem(ir.Oneof(name:, docs:, file:, variants:)), rest)
}

fn oneof_variant(tokens: Tokens, docs: String) -> Parsed(Entry(OneofVariant)) {
  use #(ctor, rest) <- result.try(expect(tokens, Ident, ""))
  use #(_, rest) <- result.try(expect(rest, Sym, "("))
  use #(type_, rest) <- result.try(type_expr(rest))
  use #(_, rest) <- result.map(expect(rest, Sym, ")"))
  #(Entry(ir.OneofVariant(ctor, type_, docs)), rest)
}

/// `method name [as function] [unauthenticated] { args {..} response .. deprecated ".." }`
fn method(tokens: Tokens, docs: String, file: String) -> Parsed(Method) {
  use #(name, rest) <- result.try(expect(tokens, Ident, ""))
  use #(function, rest) <- result.try(rename(rest))
  let #(unauthenticated, rest) = case accept(rest, Ident, "unauthenticated") {
    Ok(#(_, rest)) -> #(True, rest)
    Error(Nil) -> #(False, rest)
  }
  use #(_, rest) <- result.try(expect(rest, Sym, "{"))
  let method =
    ir.Method(
      name:,
      docs:,
      file:,
      function:,
      unauthenticated:,
      args: [],
      response: None,
      deprecated: None,
    )
  method_sections(rest, method)
}

fn method_sections(tokens: Tokens, method: Method) -> Parsed(Method) {
  case advance(tokens) {
    #(Token(Sym, "}", _), rest) -> Ok(#(method, rest))
    #(Token(Ident, "args", _), rest) -> {
      use #(args, rest) <- result.try(fields(rest, True))
      method_sections(rest, ir.Method(..method, args:))
    }
    #(Token(Ident, "response", _), rest) -> {
      use #(response, rest) <- result.try(response(rest))
      method_sections(rest, ir.Method(..method, response: Some(response)))
    }
    #(Token(Ident, "deprecated", _), rest) -> {
      use #(reason, rest) <- result.try(expect(rest, Str, ""))
      method_sections(rest, ir.Method(..method, deprecated: Some(reason)))
    }
    _ -> fail(tokens, "expected `args`, `response`, `deprecated` or `}`")
  }
}

fn response(tokens: Tokens) -> Parsed(Response) {
  case peek(tokens) {
    Token(Sym, "{", _) -> {
      use #(fields, rest) <- result.map(fields(tokens, False))
      #(ir.ResponseFields(fields), rest)
    }
    _ -> {
      use #(type_, rest) <- result.map(type_expr(tokens))
      #(ir.ResponseType(type_), rest)
    }
  }
}
