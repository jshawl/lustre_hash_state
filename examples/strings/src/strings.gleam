import gleam/dict
import gleam/result
import lustre
import lustre/attribute
import lustre/effect
import lustre/element.{type Element}
import lustre/event
import lustre/ui
import lustre_hash_state
import gleam/io

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
  #(Model(dict.new()), lustre_hash_state.init(
    HashChange |> lustre_hash_state.with_decoder
  ))
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
        lustre_hash_state.update(key, value |> lustre_hash_state.with_encoder),
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
      [element.text("Write a message:")],
      ui.input([
        attribute.value(result.unwrap(dict.get(dct, "message"), "")),
        event.on_input(fn(value) { UserUpdatedMessage("message", value) }),
      ]),
      [],
    ),
    ui.field(
      [],
      [element.text("Write another message:")],
      ui.input([
        attribute.value(result.unwrap(dict.get(dct, "message2"), "")),
        event.on_input(fn(value) { UserUpdatedMessage("message2", value) }),
      ]),
      [],
    ),
  ])
}
