import gleam/io
import lustre/effect
import gleam/string

pub fn noop() {
  effect.none()
}

@external(javascript, "./ffi.mjs", "getHash")
pub fn get_hash() -> msg

@external(javascript, "./ffi.mjs", "setHash")
pub fn set_hash(s: String) -> msg

@external(javascript, "./ffi.mjs", "listen")
pub fn listen(_handler: fn(String) -> Nil) -> Nil {
  Nil
}

pub fn set(s) -> effect.Effect(msg) {
  effect.from(fn(_) { s |> set_hash() })
}

pub fn init(msg: fn(String) -> msg) -> effect.Effect(msg) {
  use dispatch <- effect.from
  use hash <- listen

  hash |> msg |> dispatch
}
