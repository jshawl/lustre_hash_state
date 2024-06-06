import gleam/bit_array
import gleam/dict
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import gleam/uri
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
/// 
/// ## Example
/// ```gleam
/// pub opaque type Msg {
///   HashChange(key: String, value: String)
/// }
///
/// lustre_hash_state.init(HashChange)
/// // or
/// lustre_hash_state.init(fn(key: String, value: String) {
///   HashChange(key, value)
/// })
/// ```
pub fn init(msg: fn(String, String) -> msg) -> effect.Effect(msg) {
  io.debug("the msg is:")
  io.debug(msg)
  use dispatch <- effect.from
  use hash <- listen
  parse_hash(hash |> string.drop_left(1))
  |> dict.map_values(fn(key, value) { dispatch(msg(key, value)) })
  Nil
}

/// A convenience method to base64 url decode individual values.
/// 
/// ## Example
/// ```gleam
/// lustre_hash_state.init(fn(key: String, value: String) {
///   HashChange(key, value |> lustre_hash_state.from_base64)
/// })
/// ```
/// will dipatch the HashChange msg with the decoded value.
pub fn from_base64(value: String) {
    case bit_array.base64_url_decode(value) {
      Error(Nil) -> value
      Ok(r) ->
        case bit_array.to_string(r) {
          Error(Nil) -> value
          Ok(decoded) -> decoded
        }
    }
}

/// A convenience method to base64 url encode individual values.
/// 
/// ## Example
/// ```gleam
/// lustre_hash_state.update(key, value |> lustre_hash_state.to_base64)
/// ```
/// will update the hash value as a base64 url encoded string.
pub fn to_base64(value: String) {
  value
  |> bit_array.from_string
  |> bit_array.base64_url_encode(True)
}
