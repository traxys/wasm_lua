local utils = require("wasm.utils")

local parser = require("wasm.parser")
local types = require("wasm.types")
local runtime = require("wasm.runtime")

local record WasmInstance
	program: parser.Program
	globals: {runtime.GlobalValue}
	memory: runtime.LinearMemory
end

function WasmInstance.load(p: parser.Program): WasmInstance
	local self = setmetatable({} as WasmInstance, { __index = WasmInstance})

	self.program = p
	self.globals = utils.mapArray(p.global, function(g: types.Global): runtime.GlobalValue
		return runtime.GlobalValue.load(g)
	end)
	self.memory = p:createMemory()

	return self
end

function WasmInstance:executeInit(fn: number)
	if not self.program:is_init_fn(fn) then
		error("An init function is of signature () -> ()")
	end

	local vm = runtime.VmState.create(
		runtime.Frame.create(nil, nil, 0, -1),
		function(fn: number): types.FunctionKind return self.program:resolve(fn) end,
		function(fn: number): types.Code return self.program:func_body(fn) end,
		self.globals,
		function(fn: number): types.FuncType return self.program:signature(fn) end,
		self.memory
	)
	vm:call(fn, {}, 0)
	vm.stacktrace = true
	vm:run()
end

return {
	iterator = utils.iterator,
	Program = parser.Program, 
	WasmInstance = WasmInstance
}
