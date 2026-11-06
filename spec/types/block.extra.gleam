import gleam/option.{None, Some}

// ---------------------------------------------------------------- text

/// A `plain_text` object for fields that only accept plain text, with
/// `emoji` unset.
pub fn plain_text(text: String) -> PlainText {
  PlainText(text: text, emoji: None)
}

/// A `mrkdwn` text object.
pub fn mrkdwn(text: String) -> Text {
  MrkdwnObject(Mrkdwn(text: text, verbatim: None))
}

/// A `plain_text` text object, for fields that accept either kind of text.
/// Use `plain_text` for fields that only accept plain text.
pub fn text(text: String) -> Text {
  PlainTextObject(plain_text(text))
}

// ---------------------------------------------------------------- composition objects

/// An option with plain text and a value.
pub fn option(label: String, value: String) -> SelectOption {
  SelectOption(text: text(label), value: value, description: None, url: None)
}

/// A labelled group of options.
pub fn option_group(label: String, options: List(SelectOption)) -> OptionGroup {
  OptionGroup(label: plain_text(label), options: options)
}

/// A confirmation dialog with the default style.
pub fn confirmation_dialog(
  title title: String,
  text text: Text,
  confirm confirm: String,
  deny deny: String,
) -> ConfirmationDialog {
  ConfirmationDialog(
    title: plain_text(title),
    text: text,
    confirm: plain_text(confirm),
    deny: plain_text(deny),
    style: None,
  )
}

// ---------------------------------------------------------------- context elements

/// `mrkdwn` text as a context block element.
pub fn context_mrkdwn(text: String) -> ContextElement {
  ContextMrkdwn(Mrkdwn(text: text, verbatim: None))
}

/// Plain text as a context block element.
pub fn context_plain(text: String) -> ContextElement {
  ContextPlainText(plain_text(text))
}

/// An image from a public URL as a context block element.
pub fn context_image(
  image_url image_url: String,
  alt_text alt_text: String,
) -> ContextElement {
  ContextImage(ImageElement(
    alt_text: alt_text,
    image_url: Some(image_url),
    slack_file: None,
  ))
}

// ---------------------------------------------------------------- rich text

/// A rich text object, for example the `initial_value` of a rich text input.
/// `rich_text` builds the block.
pub fn rich_text_value(elements: List(RichTextObject)) -> RichText {
  RichText(elements: elements, block_id: None)
}

/// A rich text section (paragraph).
pub fn rich_text_section(elements: List(RichTextElement)) -> RichTextObject {
  RichTextSection(elements: elements)
}

/// An unstyled rich text run.
pub fn rich_text_run(text: String) -> RichTextElement {
  TextElement(text: text, style: None)
}

/// A rich text style with every property unset.
pub fn no_style() -> RichTextStyle {
  RichTextStyle(
    bold: None,
    italic: None,
    strike: None,
    code: None,
    highlight: None,
    client_highlight: None,
    underline: None,
    unlink: None,
  )
}
