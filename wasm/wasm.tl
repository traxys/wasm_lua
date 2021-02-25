local utils = require("wasm.utils")

local parser = require("wasm.parser")
local types = require("wasm.types")
local runtime = require("wasm.runtime")

local record WasmInstance
	program: parser.Program
	globals: {runtime.GlobalValue}
	memory: runtime.LinearMemory
	imports: {number: runtime.ImportedFunction}
end

function WasmInstance.load(p: parser.Program, function_imports: {string:{string:function(runtime.VmState, {types.WasmValue})}}): WasmInstance
	local self = setmetatable({} as WasmInstance, { __index = WasmInstance})

	self.program = p
	self.globals = utils.mapArray(p.global, function(g: types.Global): runtime.GlobalValue
		return runtime.GlobalValue.load(g)
	end)
	self.memory = p:createMemory()
	for _,v in ipairs(p.data) do
		local vm = runtime.VmState.constant(v.init, self.memory, self.globals)
		vm:run()

		local offset = vm.stack:pop()
		if offset.type ~= "i32" then
			error("Invalid offset in data: expected i32, got " .. offset.type)
		end
		local offset_value = offset.value - 1
		for i,v in ipairs(v.data) do
			self.memory.bytes[offset_value + i] = v
		end
	end
	
	self.imports = {}
	for i,import_name in pairs(p:imported_functions()) do
		local mod = function_imports[import_name[1]]
		if mod == nil then
			error("Missing mod " .. import_name[1] .. " in imports")
		end
		local fn = mod[import_name[2]]
		if fn == nil then
			error("Missing fn " .. import_name[1] .. "." .. import_name[2] .. " in imports")
		end

		self.imports[i] = {
			body = fn,
			name = import_name[1] .. "." .. import_name[2], 
			signature = p:signature(i),
		}
	end

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
		self.memory,
		self.imports
	)
	vm:call(fn, {}, 0)
	vm.stacktrace = true
	vm:run()
end

return {
	iterator = utils.iterator,
	Program = parser.Program, 
	VmState = runtime.VmState,
	WasmInstance = WasmInstance,
	WasmValue = types.WasmValue,
}
