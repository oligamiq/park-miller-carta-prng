assert = require 'assert'
asmjs = require "#{__dirname}/../dist/asmjs/emscripten.js"
wasm = require "#{__dirname}/../dist/wasm/emscripten.js"
prng = require "./index"

expectedInts = [16807, 282475249, 1622650073, 984943658, 1144108930, 470211272, 101027544, 1457850878, 1458777923, 2007237709]

# PRNG asm.js test
try
  asmPRNG = prng asmjs
  genAsm = asmPRNG 1  
  for i in [0..9]
    current = genAsm.getInteger()
    expected = expectedInts[i]
    assert current is expected
catch error then console.log current, expected; throw error
finally genAsm.destroy()

#PRNG wasm test
try
  wasmPRNG = prng wasm
  genWasm =  wasmPRNG 1  
  for i in [0..9]
    current = genWasm.getInteger()
    expected = expectedInts[i]
    assert current is expected
catch error then console.log current, expected; throw error
finally genWasm.destroy()

console.log "Tests pass!"