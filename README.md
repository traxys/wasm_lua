# wasm_lua

To make the `.lua` files you can do `make`.

To use either the `teal` module or the `lua` module you can do `require("wasm.wasm")`. An example use is provided in `wasm_test.tl`


## Why would you do that ?

Well, a lot of programs (like games) only run `lua` as addons/plugins/mods, but I really like writing Rust that is able to run in WASM. So I asked myself if I could not make a WASM VM in lua so that I could target those games with Rust mods.
