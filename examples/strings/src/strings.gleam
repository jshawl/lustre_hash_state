import lustre
import lustre/attribute
import lustre/effect
import lustre/element.{type Element}
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
  Model(value: String)
}

fn init(_flags) -> #(Model, effect.Effect(Msg)) {
  #(Model(value: ""), lustre_hash_state.init(HashChange))
}

// UPDATE ----------------------------------------------------------------------

pub opaque type Msg {
  UserUpdatedMessage(key: String, value: String)
  HashChange(key: String, value: String)
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(msg)) {
  case msg {
    HashChange(_key, value) -> {
      #(Model(..model, value: value), effect.none())
    }
    UserUpdatedMessage(key, value) -> {
      #(Model(..model, value: value), lustre_hash_state.update(key, value))
    }
  }
}

// VIEW ------------------------------------------------------------------------

fn view(model: Model) -> Element(Msg) {
  ui.field(
    [],
    [element.text("Write a message:")],
    ui.input([
      attribute.value(model.value),
      event.on_input(fn(value) { UserUpdatedMessage("message", value) }),
    ]),
    [],
  )
}
