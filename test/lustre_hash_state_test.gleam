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

pub fn stringify_hash_test() {
  dict.from_list([#("one", "1"), #("two", "2")])
  |> lustre_hash_state.stringify_hash
  |> should.equal("one=1&two=2")
}
