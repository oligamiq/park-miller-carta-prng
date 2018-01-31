assert = require 'assert'
asmjs = require "#{__dirname}/../dist/asmjs/emscripten.js"
wasm = require "#{__dirname}/../dist/wasm/emscripten.js"
prng = require "./index"

expectedInts = [16807, 282475249, 1622650073, 984943658, 1144108930, 470211272, 101027544, 1457850878, 1458777923, 2007237709]


# PRNG asm.js test
do ->
  try
    asmPRNG = prng asmjs
    gen = asmPRNG 1  
    for i in [0..9]
      current = gen.getInteger()
      expected = expectedInts[i]
      assert current is expected
  catch error then console.log current, expected; throw error
  finally gen.destroy(); asmPRNG = undefined

#PRNG wasm test
do -> 
  try
    wasmPRNG = prng wasm
    gen =  wasmPRNG 1  
    for i in [0..9]
      current = gen.getInteger()
      expected = expectedInts[i]
      assert current is expected
  catch error then console.log current, expected; throw error
  finally gen.destroy(); wasmPRNG = undefined

console.log "Tests pass!"