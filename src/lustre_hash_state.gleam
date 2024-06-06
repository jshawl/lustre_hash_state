import gleam/dict
import gleam/list
import gleam/string
import lustre/effect

/// A convenience method identical to effect.none()
pub fn noop() {
  effect.none()
}

/// Returns the current window.location.hash value, including the octothorpe.
/// It's unlikely you'd call this directly, but public for convenience.
@external(javascript, "./ffi.mjs", "getHash")
pub fn get_hash() -> String

@external(javascript, "./ffi.mjs", "setHash")
fn set_hash(s: String) -> msg

@external(javascript, "./ffi.mjs", "listen")
fn listen(_handler: fn(String) -> Nil) -> Nil

/// Updates the hash value.
pub fn update(key: String, value: String) -> effect.Effect(msg) {
  let current_hash = get_hash() |> string.drop_left(1)

  let dct = parse_hash(current_hash)
  let nextdct = dict.update(dct, key, fn(_) { value })
  let str = stringify_hash(nextdct)
  effect.from(fn(_) { set_hash(str) })
}

pub fn parse_hash(query: String) -> dict.Dict(String, String) {
  string.split(query, "&")
  |> list.map(fn(part) {
    case string.split(part, "=") {
      [key, value] -> #(key, value)
      [] | [_] | _ -> #("", "")
    }
  })
  |> dict.from_list
}

pub fn stringify_hash(dct: dict.Dict(String, String)) -> String {
  dict.to_list(dct)
  |> list.map(fn(x) {
    let #(key, value) = x
    key <> "=" <> value
  })
  |> string.join("&")
}

/// The effect to be returned in your init method. Sets up hashchange event
/// listener and sends messages to update.
pub fn init(msg: fn(String, String) -> msg) -> effect.Effect(msg) {
  use dispatch <- effect.from
  use hash <- listen
  parse_hash(hash |> string.drop_left(1))
  |> dict.map_values(fn(key, value) { dispatch(msg(key, value)) })
  Nil
}
