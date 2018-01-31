asmjs = require "#{__dirname}/../dist/asmjs/emscripten.js"

prng_new = asmjs.cwrap('prng_new', 'number', ['number']);
prng_destroy = asmjs.cwrap('prng_destroy', '', ['number']);
next_unsigned_integer = asmjs.cwrap('next_unsigned_integer', 'number', ['number']);
next_unsigned_float = asmjs.cwrap('next_unsigned_float', 'number', ['number']);

prng = (seed) ->
  ptr = prng_new seed
  getInteger = -> next_unsigned_integer ptr
  getFloat = -> next_unsigned_float ptr
  destroyPtr = -> prng_destroy ptr

  {
    getInteger
    getFloat
    destroy
  }

module.exports = prng