import gleam/dict
import gleam/list
import gleam/result
import gleam/string
import gleam/uri
import lustre/effect
import gleam/io
import gleam/bit_array

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
  effect.from(fn(_) {
    get_hash()
    |> string.drop_left(1)
    |> parse_hash()
    |> dict.update(key, fn(_) { value })
    |> stringify_hash
    |> set_hash
  })
}

/// Parses a query string into a dict
pub fn parse_hash(query: String) -> dict.Dict(String, String) {
  string.split(query, "&")
  |> list.fold(dict.new(), fn(accumulator, element) {
    case string.split(element, "=") {
      [key, value] ->
        dict.update(accumulator, key, fn(_) {
          value |> uri.percent_decode |> result.unwrap(value)
        })
      [] | [_] | _ -> accumulator
    }
  })
}

/// Converts a dict to a query string
pub fn stringify_hash(dct: dict.Dict(String, String)) -> String {
  dict.to_list(dct)
  |> list.map(fn(x) {
    let #(key, value) = x
    key <> "=" <> value |> uri.percent_encode
  })
  |> string.join("&")
}

/// The effect to be returned in your init method. Sets up hashchange event
/// listener and sends messages to update.
pub fn init(msg: fn(String, String) -> msg) -> effect.Effect(msg) {
  io.debug("the msg is:")
  io.debug(msg)
  use dispatch <- effect.from
  use hash <- listen
  parse_hash(hash |> string.drop_left(1))
  |> dict.map_values(fn(key, value) { dispatch(msg(key, value)) })
  Nil
}

pub fn with_decoder(f: fn(String, String) -> msg) {
  fn(key: String, value: String){
    io.debug("value is" <> value)
    let decoded = case bit_array.base64_url_decode(value) {
      Error(Nil) -> value
      Ok(r) -> case bit_array.to_string(r) {
        Error(Nil) -> value
        Ok(r) -> r
      }
    }

    f(key, decoded)
  }
}

pub fn with_encoder(s: String) {
  s
  |> bit_array.from_string
  |> bit_array.base64_url_encode(True) 
}