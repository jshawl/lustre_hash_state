import gleam/bool
import gleam/dict
import gleam/dynamic
import gleam/io
import gleam/result
import lustre
import lustre/attribute
import lustre/effect
import lustre/element.{type Element}
import lustre/element/html
import lustre/event
import lustre/ui
import lustre_hash_state

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(dict.Dict(String, String))
}

fn init(_flags) -> #(Model, effect.Effect(Msg)) {
  #(
    Model(dict.new()),
    lustre_hash_state.init(fn(key: String, value: String) {
      HashChange(key, value)
    }),
  )
}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {
  UserUpdatedMessage(key: String, value: String)
  HashChange(key: String, value: String)
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(msg)) {
  let Model(dct) = model
  case msg {
    HashChange(key, value) -> {
      #(Model(dict.update(dct, key, fn(_x) { value })), effect.none())
    }
    UserUpdatedMessage(key, value) -> {
      #(
        Model(dict.update(dct, key, fn(_x) { value })),
        lustre_hash_state.update(key, value),
      )
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  let Model(dct) = model

  ui.group([], [
    ui.field(
      [],
      [element.text("checkbox:")],
      ui.input([
        attribute.attribute("type", "checkbox"),
        attribute.value(result.unwrap(dict.get(dct, "checkbox"), "")),
        attribute.checked(
          result.unwrap(dict.get(dct, "checkbox"), "") == "True",
        ),
        event.on_check(fn(value) {
          UserUpdatedMessage("checkbox", value |> bool.to_string)
        }),
      ]),
      [],
    ),
    html.label([], [element.text("radio button:")]),
    ui.field(
      [],
      [element.text("option a")],
      ui.input([
        attribute.attribute("type", "radio"),
        attribute.name("radio"),
        attribute.checked(result.unwrap(dict.get(dct, "radio"), "") == "a"),
        attribute.value(result.unwrap(dict.get(dct, "radio"), "")),
        event.on_check(fn(_value) { UserUpdatedMessage("radio", "a") }),
      ]),
      [],
    ),
    ui.field(
      [],
      [element.text("option b")],
      ui.input([
        attribute.attribute("type", "radio"),
        attribute.name("radio"),
        attribute.checked(result.unwrap(dict.get(dct, "radio"), "") == "b"),
        attribute.value(result.unwrap(dict.get(dct, "radio"), "")),
        event.on_check(fn(_value) { UserUpdatedMessage("radio", "b") }),
      ]),
      [],
    ),
    ui.field(
      [],
      [element.text("Text input:")],
      ui.input([
        attribute.value(result.unwrap(dict.get(dct, "textinput"), "")),
        event.on_input(fn(value) { UserUpdatedMessage("textinput", value) }),
      ]),
      [],
    ),
    ui.field(
      [],
      [element.text("range:")],
      ui.input([
        attribute.value(result.unwrap(dict.get(dct, "range"), "")),
        attribute.attribute("type", "range"),
        attribute.attribute("step", "10"),
        event.on_input(fn(value) { UserUpdatedMessage("range", value) }),
      ]),
      [],
    ),
    ui.field(
      [],
      [element.text("textarea:")],
      html.textarea(
        [
          attribute.value(result.unwrap(dict.get(dct, "textarea"), "")),
          event.on_input(fn(value) { UserUpdatedMessage("textarea", value) }),
        ],
        "",
      ),
      [],
    ),
    ui.field(
      [],
      [element.text("date:")],
      ui.input([
        attribute.attribute("type", "date"),
        attribute.value(result.unwrap(dict.get(dct, "date"), "")),
        event.on_input(fn(value) { UserUpdatedMessage("date", value) }),
      ]),
      [],
    ),
    ui.field(
      [],
      [element.text("color:")],
      ui.input([
        attribute.attribute("type", "color"),
        attribute.value(result.unwrap(dict.get(dct, "color"), "#bada55")),
        event.on_input(fn(value) { UserUpdatedMessage("color", value) }),
      ]),
      [],
    ),
  ])
}
