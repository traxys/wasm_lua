local input_file = "wasm_examples/simple.wasm"
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
local VmState = wasm.VmState
local WasmValue = wasm.WasmValue

local imports = 
{
	["env"] = {
		["putchar"] = function(v: VmState, args: {WasmValue})
			io.write(string.char(args[1].value))
		end
	}
}

local function main()
	local bytes = wasm.iterator(input)
	local program = wasm.Program.parse(bytes)
	program:print()
	local instance = wasm.WasmInstance.load(program, imports)
	instance:executeInit(2)
end

main()
