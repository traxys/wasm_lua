local input_file = "wasm_examples/guessing_game.wasm"
local file = io.open(input_file, 'rb')
local input = {}
repeat
   local str = file:read(4*1024)
   for c in (str or ''):gmatch'.' do
      input[#input+1] = c:byte()
   end
until not str
file:close()

local wasm = require("wasm.wasm")

local function main()
	local bytes = wasm.iterator(input)
	local program = wasm.Program.parse(bytes)
	program:print()
	local instance = wasm.WasmInstance.load(program)
	instance:executeInit(4)
end

main()
