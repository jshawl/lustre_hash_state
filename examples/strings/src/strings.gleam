import gleam/int
import gleam/string
import lustre
import lustre/attribute
import lustre/effect
import lustre/element.{type Element}
import lustre/event
import lustre/ui
import lustre/ui/layout/aside
import lustre_hash_state

// MAIN ------------------------------------------------------------------------

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

// MODEL -----------------------------------------------------------------------

type Model {
  Model(value: String, length: Int, max: Int)
}

fn init(_flags) -> #(Model, effect.Effect(Msg)) {
  #(Model(value: "", length: 0, max: 10), lustre_hash_state.init(HashChange))
}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {
  UserUpdatedMessage(value: String)
  UserResetMessage
  HashChange(value: String)
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(msg)) {
  case msg {
    HashChange(value) -> {
      #(Model(..model, value: string.drop_left(value, 1)), effect.none())
    }
    UserUpdatedMessage(value) -> {
      let length = string.length(value)
      #(
        case length <= model.max {
          True -> Model(..model, value: value, length: length)
          False -> model
        },
        lustre_hash_state.update(value),
      )
    }
    UserResetMessage -> #(
      Model(..model, value: "", length: 0),
      lustre_hash_state.update(""),
    )
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  let styles = [#("width", "100vw"), #("height", "100vh"), #("padding", "1rem")]
  let length = int.to_string(model.length)
  let max = int.to_string(model.max)

  ui.centre(
    [attribute.style(styles)],
    ui.aside(
      [aside.content_first(), aside.align_centre()],
      ui.field(
        [],
        [element.text("Write a message:")],
        ui.input([
          attribute.value(model.value),
          event.on_input(UserUpdatedMessage),
        ]),
        [element.text(length <> "/" <> max)],
      ),
      ui.button([event.on_click(UserResetMessage)], [element.text("Reset")]),
    ),
  )
}
