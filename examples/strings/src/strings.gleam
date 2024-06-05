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
  Model(value: String)
}

fn init(_flags) -> #(Model, effect.Effect(Msg)) {
  #(Model(value: ""), lustre_hash_state.init(HashChange))
}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {
  UserUpdatedMessage(value: String)
  UserResetMessage
  HashChange(key: String, value: String)
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(msg)) {
  case msg {
    HashChange(_key, value) -> {
      #(Model(..model, value: value), effect.none())
    }
    UserUpdatedMessage(value) -> {
      #(
        Model(..model, value: value),
        lustre_hash_state.update("message", value),
      )
    }
    UserResetMessage -> #(
      Model(..model, value: ""),
      lustre_hash_state.update("message", ""),
    )
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  ui.field(
    [],
    [element.text("Write a message:")],
    ui.input([attribute.value(model.value), event.on_input(UserUpdatedMessage)]),
    [],
  )
}
