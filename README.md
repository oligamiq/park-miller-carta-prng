# Park-Miller-Carta PRNG

*(documentation in progress)*
This is a multi-language repository, demonstrating C-Rust-Node.js-Web interoperability/portability.

It utilizes Rust as a build system, in order to compile [the original C implemetations by Robin Whittle](http://www.firstpr.com.au/dsp/rand31/). A faithful Rust port is also included, cross-compilable to asm.js and WebAssembly via [Emscripten](https://github.com/kripken/emscripten), for use in Node.js and browsers.

## Using from browser
Add with `npm i --save --only=production park-miller-carta-prng`.

index.html:
```html
<!DOCTYPE html>
<html>
<head>
  <title>Wasm</title>
</head>
<body>

<script type="text/javascript">
  var Module = {};

  var prng = {
    seed: (i) => Module.prng_new(i),
    destroy: (ptr) => Module.prng_destroy(ptr),
    getInteger: (ptr) => Module.next_unsigned_integer(ptr),
    getFloat: (ptr) => Module.next_unsigned_float(ptr)
  };

  function fetchAndInstantiate(url, importObject) {
    return fetch(url).then(response =>
      response.arrayBuffer()
    ).then(bytes =>
      WebAssembly.instantiate(bytes, importObject)
    ).then(results =>
      results.instance
    );
  }

  fetchAndInstantiate('node_modules/park-miller-carta-prng/dist/wasm/browser-standalone.wasm', {})
  .then( mod => {
    Module.prng_new = mod.exports.prng_new;
    Module.prng_destroy = mod.exports.prng_destroy;
    Module.next_unsigned_integer = mod.exports.next_unsigned_integer;
    Module.next_unsigned_float = mod.exports.next_unsigned_float;
  })
  .then( () => {
    var ptr = prng.seed(1);
    var container = document.createElement('div');
    container.textContent = `integer: ${prng.getInteger(ptr)} float: ${prng.getFloat(ptr)}`
    document.body.appendChild(container);
    prng.destroy(ptr);
  });

</script>
</body>
</html>
```
host the html via `python2 -m SimpleHTTPServer`/`python3 -m http.server` of your preferred method.

## Using from Node.js
### WebAssembly & asm.js
Add with `npm i --save --only=production park-miller-carta-prng`.

index.js:
```js
let {prng, asmjs, wasm} = require("park-miller-carta-prng");
let assert = require('assert');

// use asm.js version
let generator = prng(asmjs)(1);

assert(generator.getInteger() === 16807);
generator.destroy();

// use wasm version
generator = prng(wasm)(1);

assert(generator.getInteger() === 16807);
generator.destroy();
```
You should always call `destroy()` when you are done using the generator.
Available methods:

* `prng`, takes either the supplied `asmjs`, or `wasm` modules, generated by `emcc`.
Then, it must be supplied with a positive seed integer.
* `getInteger`, `getFloat` and `destroy` methods, are self explanatory.

### Native Addon
Clone the repository and `npm run build:addon`.
check `src/test.coffee` for usage.
[Todo] simple API, conditional build on npm download.

## Using from Rust
Add `park-miller-carta-prng` to `[dependencies]` in `Cargo.toml`

main.rs:
```rust
extern crate prng;
use prng::PRNG;

fn main() {
    let mut prng = PRNG::new(1);
    let random_float = prng.next_unsigned_float();
    assert_eq!(0.000007826369, random_float);

    let random_int = prng.next_unsigned_integer();
    assert_eq!(282475249, random_int);
}
```

## Getting Started
1. Clone the repository:
`git clone https://github.com/kenOfYugen/park-miller-carta-prng`
2. Enter the directory:
`cd park-miller-carta-prng`
3. Build (add the `--release` flag for optimized builds)
  * Rust-C static/dynamic libraries: `cargo b`
  * asm.js library: `cargo b --target asmjs-unknown-emscripten`
  * wasm library: `cargo b --target wasm32-unknown-emscripten`
  * standalone wasm library: `cargo b --target wasm32-unknown-unknown`
  * Node.js: `npm i && npm run build:all`

### Prerequisites
* Rust, get it via [rustup](https://www.rustup.rs/).
* [Node.js](https://nodejs.org/en/) for running asm.js/wasm.
* [emsdk](https://developer.mozilla.org/en-US/docs/WebAssembly/C_to_wasm), for compilation to asm.js/wasm.

#### Checklist
- [x] Rust API
- [x] C API
- [x] Node.js asm.js/wasm via `emscripten`
- [x] Node.js native Addon
- [ ] Browser asm.js/wasm via `emscripten`
- [x] wasm via `--target wasm32-unknown-unknown`
