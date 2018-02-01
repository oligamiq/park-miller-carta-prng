//! # emscripten
//!
//! The `emscripten` crate exists because `asmjs/wasm32-unknown-emscripten` targets, require a `main` function to be present.

extern crate prng;
pub use prng::c_api;

fn main() {}