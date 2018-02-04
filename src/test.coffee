assert = require 'assert'
{prng, asmjs, wasm} = require "./index"
addon = require('bindings')('addon')

expectedInts = [16807, 282475249, 1622650073, 984943658, 1144108930, 470211272, 101027544, 1457850878, 1458777923, 2007237709]

# PRNG asm.js test
try
  gen = prng(asmjs)(1) 
  for i in [0..9]
    current = gen.getInteger()
    expected = expectedInts[i]
    assert current is expected
catch error then console.log current, expected; throw error
finally gen.destroy()

# PRNG wasm test
try
  gen = prng(wasm)(1)
  for i in [0..9]
    current = gen.getInteger()
    expected = expectedInts[i]
    assert current is expected
catch error then console.log current, expected; throw error
finally gen.destroy()

# PRNG addon test
try
  gen = new addon.PrngObject(1)
  for i in [0..9]
    current = gen.getInteger()
    expected = expectedInts[i]
    assert current is expected
catch error then console.log current, expected; throw error
finally gen.destroy()

console.log "Tests pass!"