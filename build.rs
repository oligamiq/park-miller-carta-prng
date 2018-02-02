extern crate bindgen;
extern crate cbindgen;
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

fn build_c_header(header_out: &str) {
    cbindgen::Builder::new()
        .with_crate("./")
        .generate()
        .expect("Unable to generate header")
        .write_to_file(header_out.to_owned() + "bindings.h");
}

fn build(sources_dir: &str, bindings_out_dir: &str, header_out_dir: &str) {
    /*
    // weird wasm32-unknown-emscripten failure
    // without this cfg :/
    // the expected not() doesn't solve it
     */
    #[cfg(target_os = "emscripten")]
    build_bindings(sources_dir, bindings_out_dir);
    build_c(sources_dir);
    build_c_header(header_out_dir);
}

fn main() {
    let sources_dir = "./archive/rand31-park-miller-carta/";
    let bindings_out_dir = "./src/archive/";
    let header_out_dir = "./src/";

    build(sources_dir, bindings_out_dir, header_out_dir);
}
