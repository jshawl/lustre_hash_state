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
pub fn update(s) -> effect.Effect(msg) {
  effect.from(fn(_) { s |> set_hash() })
}

/// The effect to be returned in your init method. Sets up hashchange event
/// listener and sends messages to update.
pub fn init(msg: fn(String) -> msg) -> effect.Effect(msg) {
  use dispatch <- effect.from
  use hash <- listen

  hash |> msg |> dispatch
}
