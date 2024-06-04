import gleam/io
import gleam/int
import lustre/effect

pub fn main() {
  io.println("Hello from hash_state!")
}

pub fn noop(){
  effect.none()
}

@external(javascript, "./ffi.mjs", "setHash")
pub fn set_hash(s: String) -> Nil

pub fn set(s){
  io.debug("idk man")
  io.debug(s)
  effect.from(fn(_){
    s |> set_hash()
  })
}