asmjs = require "#{__dirname}/../dist/asmjs/emscripten.js"
wasm = require "#{__dirname}/../dist/wasm/emscripten.js"

prng = (lib) -> 
  prng_new = lib.cwrap('prng_new', 'number', ['number']);
  prng_destroy = lib.cwrap('prng_destroy', '', ['number']);
  next_unsigned_integer = lib.cwrap('next_unsigned_integer', 'number', ['number']);
  next_unsigned_float = lib.cwrap('next_unsigned_float', 'number', ['number']);
  (seed) ->
    ptr = prng_new seed
    getInteger = -> next_unsigned_integer ptr
    getFloat = -> next_unsigned_float ptr
    destroy = -> prng_destroy ptr

    {
      getInteger
      getFloat
      destroy
    }

module.exports = {
  prng
  asmjs
  wasm
}