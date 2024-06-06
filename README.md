# lustre_hash_state

[![Package Version](https://img.shields.io/hexpm/v/lustre_hash_state)](https://hex.pm/packages/lustre_hash_state)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/lustre_hash_state/)

---

`lustre_hash_state` provides `Effect`s to store a model's state in the
hash fragment:

```
type Model {
  Model(dict.from_list([#("example_key", "example_value")]))
}
```

```txt
https://example.com/#example_key=example_value
```

When the model changes, the hash changes! When the hash changes, the model changes, too!

## Usage

```sh
gleam add lustre_hash_state
```

```gleam
import lustre_hash_state

pub opaque type Msg {
  // ...
  // Bring your own key value Msg type
  HashChange(key: String, value: String)
}

fn init(_flags) -> #(Model, effect.Effect(Msg)) {
  // dispatch a HashChange Msg when the "hashchange" event is
  // dispatched from the browser
  #(Model(dict.new()), lustre_hash_state.init(HashChange))
}

fn update(model: Model, msg: Msg) -> #(Model, effect.Effect(msg)) {
  let Model(dct) = model
  case msg {
    // update the model on hashchange events
    HashChange(key, value) -> {
      #(Model(dict.update(dct, key, fn(_x) { value })), effect.none())
    }
    UserUpdatedMessage(key, value) -> {
      #(
        Model(dict.update(dct, key, fn(_x) { value })),
        // update the hash with the new key value pair
        lustre_hash_state.update(key, value),
      )
    }
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

## Encoding

Need to work with data types more complex than strings? No problem!

Within lustre's init fn, decode the data:

```gleam
fn init(_flags) -> #(Model, effect.Effect(Msg)) {
  #(
    Model(dict.new()),
    lustre_hash_state.init(fn(key: String, value: String) {
      // decoded using the `from_base64` convenience method
      HashChange(key, value |> lustre_hash_state.from_base64)
    }),
  )
}
```

Within lustre's update fn, encode the data:

```gleam
UserUpdatedMessage(key, value) -> {
  #(
    Model(...),
    lustre_hash_state.update(key, value |> lustre_hash_state.to_base64),
  )
}
```

Further documentation can be found at <https://hexdocs.pm/lustre_hash_state>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
