assert = require 'assert'
{prng, asmjs, wasm} = require "./index"
addon = require('bindings')('addon')

genAsm = prng(asmjs)(1)
genWasm = prng(wasm)(1)
genAddon = new addon.PrngObject(1)

Benchmark = require 'benchmark'

for i in [1..1e8]
  genWasm.getInteger()
  genAsm.getInteger()
  genAddon.getInteger()

suite = new Benchmark.Suite
console.log "Benchmarking"
suite
  .add 'wasm',
    defer: false
    fn: -> genWasm.getInteger()

  .add 'asm',
    defer: false
    fn: -> genAsm.getInteger()

  .add 'addon',
    defer: false
    fn: -> genAddon.getInteger()

  .on 'cycle', (e) -> console.log String e.target
  .on 'complete', -> console.log 'Fastest is ' + @filter('fastest').map('name')
  .on 'error', (e) -> throw e
  .run({async: false})

