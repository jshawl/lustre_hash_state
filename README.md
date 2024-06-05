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
  HashChange(value: String)
}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
}

fn init(_flags) -> #(Model, effect.Effect(Msg)) {
  #(Model(), lustre_hash_state.init(HashChange))
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(msg)) {
  case msg {
    // hash change events can update the model
    HashChange(value) -> {
      #(Model(..model, value: value), effect.none())
    }
    UserUpdatedMessage(value) -> {
      #(
        Model(..model, value: value),
        // and user events can update the hash
        lustre_hash_state.update(value),
      )
    }
    // ...
  }
}
```

Further documentation can be found at <https://hexdocs.pm/lustre_hash_state>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
