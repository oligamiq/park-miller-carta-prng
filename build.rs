extern crate bindgen;
extern crate cc;

use std::path::PathBuf;
use cc::Build;

fn build_c(sources_dir: &str, out_dir: &str){
    Build::new()
        .file(sources_dir.to_owned() + "rand31-park-miller-carta-int.c")
        .out_dir(out_dir)
        .compile("prng");
}

fn build_bindings(sources_dir: &str, out_dir: &str) {
    let out_path = PathBuf::from(out_dir);

    bindgen::Builder::default()
        .header(sources_dir.to_owned() + "rand31-park-miller-carta-int.h")
        .generate()
        .expect("Unable to generate bindings")
        .write_to_file(out_path.join("bindings.rs"))
        .expect("Couldn't write bindings!");
}

fn build(sources_dir: &str, bindings_out_dir: &str, clib_out_dir: &str) {
    build_c(sources_dir, clib_out_dir);
    build_bindings(sources_dir, bindings_out_dir);
}

fn main() {
    let sources_dir = "./archive/rand31-park-miller-carta/"; 
    let clib_out_dir = "./target/";
    let bindings_out_dir = "./src/archive";

    build(sources_dir, bindings_out_dir, clib_out_dir);   
}
