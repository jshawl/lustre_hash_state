import gleam/dict
import gleeunit
import gleeunit/should
import lustre_hash_state

pub fn main() {
  gleeunit.main()
}

pub fn parse_hash_test() {
  lustre_hash_state.parse_hash("one=1&two=2")
  |> should.equal(dict.from_list([#("one", "1"), #("two", "2")]))
}

pub fn encoded_parse_hash_test() {
  lustre_hash_state.parse_hash("key=value%20with%20spaces")
  |> should.equal(dict.from_list([#("key", "value with spaces")]))
}

pub fn parse_empty_hash_test() {
  lustre_hash_state.parse_hash("")
  |> should.equal(dict.from_list([]))
}

pub fn stringify_hash_test() {
  dict.from_list([#("one", "1"), #("two", "2")])
  |> lustre_hash_state.stringify_hash
  |> should.equal("one=1&two=2")
}

pub fn encoded_stringify_hash_test() {
  dict.from_list([#("key", "'%' rocks;")])
  |> lustre_hash_state.stringify_hash
  |> should.equal("key='%25'%20rocks%3B")
}

pub fn from_base64_test() {
  "eWF5IQ=="
  |> lustre_hash_state.from_base64
  |> should.equal("yay!")
}

pub fn to_base64_test() {
  "yay!"
  |> lustre_hash_state.to_base64
  |> should.equal("eWF5IQ==")
}
