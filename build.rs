extern crate bindgen;
extern crate cc;

use std::path::PathBuf;
use std::env;
use cc::Build;

fn build_c(sources_dir: &str) {
    Build::new()
        .file(sources_dir.to_owned() + "rand31-park-miller-carta-int.c")
        .out_dir(env::var("OUT_DIR").unwrap())
        .compile("prng");
}

fn build_bindings(sources_dir: &str, out_dir: &str) {
    let out_path = PathBuf::from(out_dir);

    bindgen::Builder::default()
        .rustfmt_bindings(true)
        .header(sources_dir.to_owned() + "rand31-park-miller-carta-int.h")
        .generate()
        .expect("Unable to generate bindings")
        .write_to_file(out_path.join("bindings.rs"))
        .expect("Couldn't write bindings!");
}

fn build(sources_dir: &str, bindings_out_dir: &str) {
    #[cfg(target_os = "emscripten")] // weird wasm32-unknown-emscripten failure
    build_bindings(sources_dir, bindings_out_dir);
    build_c(sources_dir);
}

fn main() {
    let sources_dir = "./archive/rand31-park-miller-carta/";
    let bindings_out_dir = "./src/archive";

    build(sources_dir, bindings_out_dir);
}
