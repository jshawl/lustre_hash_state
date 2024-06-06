# lustre_hash_state

[![Package Version](https://img.shields.io/hexpm/v/lustre_hash_state)](https://hex.pm/packages/lustre_hash_state)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/lustre_hash_state/)

```sh
gleam add lustre_hash_state
```

```gleam
import lustre_hash_state

pub opaque type Msg {
  // ...
  HashChange(key: String, value: String)
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

fn init(_flags) -> #(Model, effect.Effect(Msg)) {
  #(Model(dict.new()), lustre_hash_state.init(HashChange))
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(msg)) {
  case msg {
    // hash change events can update the model
    HashChange(key, value) -> {
      #(Model(dict.update(dct, key, fn(_x) { value })), effect.none())
    }
    UserUpdatedMessage(key, value) -> {
      #(
        Model(dict.update(dct, key, fn(_x) { value })),
        // and user events can update the hash
        lustre_hash_state.update(key, value),
      )
    }
    // ...
  }
}

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
  ])
}
```

Further documentation can be found at <https://hexdocs.pm/lustre_hash_state>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
