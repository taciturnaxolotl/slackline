//// Checks that a decoded value holds no catch-all variant, so a test fails
//// when an example only decodes because it fell into `Unknown..`. The
//// checks match on constructors and walk the places where blocks, elements
//// and text objects nest.

import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import slackline/attachment.{type Attachment}
import slackline/block.{type Block}
import slackline/view.{type View}

/// Decodes `text`, then checks with `known` that nothing fell into a
/// catch-all variant.
pub fn decodes(
  text: String,
  decoder: decode.Decoder(a),
  known: fn(a) -> Bool,
) -> Nil {
  let assert Ok(value) = json.parse(text, decoder)
  assert known(value)
}

pub fn blocks(values: List(Block)) -> Bool {
  list.all(values, block)
}

pub fn block(value: Block) -> Bool {
  case value {
    block.UnknownBlock(..) -> False
    block.Actions(it) -> list.all(it.elements, element)
    block.Alert(it) -> text(it.text)
    block.Card(it) ->
      optional(it.hero_image, element)
      && optional(it.icon, element)
      && list.all([it.title, it.subtitle, it.body, it.subtext], optional(
        _,
        text,
      ))
      && optional(it.actions, list.all(_, element))
    block.Carousel(it) -> blocks(it.elements)
    block.Container(it) ->
      optional(it.rich_text_title, rich_text)
      && optional(it.subtitle, text)
      && blocks(it.child_blocks)
      && optional(it.icon, element)
    block.Context(it) -> list.all(it.elements, context_element)
    block.ContextActions(it) -> list.all(it.elements, context_actions_element)
    block.DataTable(it) -> list.all(it.rows, list.all(_, table_cell))
    block.Table(it) -> list.all(it.rows, list.all(_, table_cell))
    block.DataVisualization(it) -> chart(it.chart)
    block.Input(it) -> element(it.element)
    block.Layout(it) ->
      list.all(it.rows, fn(row) {
        list.all(row.items, fn(item) { block(item.block) })
      })
      && optional(it.fallback, blocks)
    block.Plan(it) ->
      list.all(it.tasks, fn(task) {
        optional(task.details, rich_text) && optional(task.output, rich_text)
      })
    block.RichTextBlock(it) -> rich_text(it)
    block.Section(it) ->
      optional(it.text, text)
      && optional(it.fields, list.all(_, text))
      && optional(it.accessory, element)
    block.TaskCard(it) ->
      optional(it.details, rich_text) && optional(it.output, rich_text)
    block.Divider(_)
    | block.File(_)
    | block.Header(_)
    | block.Image(_)
    | block.Markdown(_)
    | block.Video(_) -> True
  }
}

pub fn element(value: block.Element) -> Bool {
  case value {
    block.UnknownElement(..) -> False
    block.Checkboxes(it) -> options(Some(it.options))
    block.RadioButtons(it) -> options(Some(it.options))
    block.Overflow(it) -> options(Some(it.options))
    block.StaticSelect(it) ->
      options(it.options) && optional(it.option_groups, list.all(_, group))
    block.MultiStaticSelect(it) ->
      options(it.options) && optional(it.option_groups, list.all(_, group))
    block.RichTextInput(it) -> optional(it.initial_value, rich_text)
    _ -> True
  }
}

pub fn text(value: block.Text) -> Bool {
  case value {
    block.UnknownText(..) -> False
    block.PlainTextObject(_) | block.MrkdwnObject(_) -> True
  }
}

pub fn select_option(value: block.SelectOption) -> Bool {
  text(value.text) && optional(value.description, text)
}

pub fn rich_text(value: block.RichText) -> Bool {
  list.all(value.elements, rich_text_object)
}

pub fn table_cell(value: block.TableCell) -> Bool {
  case value {
    block.UnknownTableCell(..) -> False
    block.RichTextCell(it) -> rich_text(it)
    block.ActionCell(element: inner, fallback:) ->
      element(inner) && optional(fallback, table_cell)
    block.RawTextCell(..) | block.RawNumberCell(..) -> True
  }
}

pub fn view(value: View) -> Bool {
  blocks(value.blocks)
  && optional(value.state, fn(state) {
    list.all(view_state_values(state), fn(value) {
      case value {
        view.UnknownViewStateValue(..) -> False
        view.StateRichTextInput(rich_text_value:) ->
          optional(rich_text_value, rich_text)
        _ -> True
      }
    })
  })
  && case value.view_type {
    view.UnknownViewType(_) -> False
    view.Modal | view.Home -> True
  }
}

pub fn attachments(values: List(Attachment)) -> Bool {
  list.all(values, fn(it) {
    optional(it.blocks, blocks)
    && optional(it.actions, list.all(_, attachment_action))
  })
}

fn attachment_action(value: attachment.AttachmentAction) -> Bool {
  case value.action_type, value.style, value.data_source {
    attachment.UnknownAttachmentActionType(_), _, _
    | _, Some(attachment.UnknownAttachmentActionStyle(_)), _
    | _, _, Some(attachment.UnknownAttachmentDataSource(_))
    -> False
    _, _, _ -> True
  }
}

fn view_state_values(state: view.ViewState) -> List(view.ViewStateValue) {
  state.values |> dict.values |> list.flat_map(dict.values)
}

fn options(values: Option(List(block.SelectOption))) -> Bool {
  optional(values, list.all(_, select_option))
}

fn group(value: block.OptionGroup) -> Bool {
  list.all(value.options, select_option)
}

fn rich_text_object(value: block.RichTextObject) -> Bool {
  case value {
    block.UnknownRichTextObject(..) -> False
    block.RichTextList(elements:, ..) -> list.all(elements, rich_text_object)
    block.RichTextSection(elements:)
    | block.RichTextPreformatted(elements:, ..)
    | block.RichTextQuote(elements:, ..) ->
      list.all(elements, rich_text_element)
  }
}

fn rich_text_element(value: block.RichTextElement) -> Bool {
  case value {
    block.UnknownRichTextElement(..) -> False
    block.BroadcastElement(range: block.UnknownBroadcastRange(_), ..) -> False
    block.CitationElement(details: block.UnknownCitationDetails(..), ..) ->
      False
    _ -> True
  }
}

fn context_element(value: block.ContextElement) -> Bool {
  case value {
    block.UnknownContextElement(..) -> False
    _ -> True
  }
}

fn context_actions_element(value: block.ContextActionsElement) -> Bool {
  case value {
    block.UnknownContextActionsElement(..) -> False
    _ -> True
  }
}

fn chart(value: block.Chart) -> Bool {
  case value {
    block.UnknownChart(..) -> False
    _ -> True
  }
}

fn optional(value: Option(a), check: fn(a) -> Bool) -> Bool {
  case value {
    Some(inner) -> check(inner)
    None -> True
  }
}
