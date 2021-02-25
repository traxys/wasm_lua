local types = require("wasm.types")
local utils = require("wasm.utils")
local Stack = require("wasm.stack")
local WasmValue = types.WasmValue
local WasmValueStack = require("wasm.wasm_value_stack")

function locals_init(self: types.Locals): {WasmValue}
	local locals = {}

	for _=1,self.n do
		table.insert(locals, {type = self.type, value = 0})
	end

	return locals
end

function locals_array(self: types.Code): {WasmValue} 
	local array = {}

	for _,loc in ipairs(self.locals) do
		local init = locals_init(loc)
		for _,val in ipairs(init) do
			table.insert(array, val)
		end
	end

	return array
end

local record Label
	code: {types.Instruction}
	current: number
	kind: types.BlockKind
	arity: number
end

local record Frame
	locals: {WasmValue}
	arity: number
	funcId: number
	labels: Stack<Label>
end

function Frame.create(locals: {WasmValue}, code: {types.Instruction}, arity: number, func: number): Frame 
	local self = setmetatable({} as Frame, { __index = Frame})

	self.locals = locals
	self.arity = arity
	self.funcId = func
	self.labels = Stack.create() as Stack<Label>
	self.labels:push({code = code, current = 1, kind = "bare", arity = arity})

	return self
end

function Frame:current_label(): Label
	return self.labels:top()
end

local MEM_PAGE = 65536
local record LinearMemory
	bytes: {number}
	max: number
	size: number
end

function LinearMemory.create(min: number, max: number): LinearMemory
	local self = setmetatable({} as LinearMemory, { __index = LinearMemory})

	self.max = max
	self.bytes = {}
	self.size = min * MEM_PAGE

	return self
end

local record GlobalValue
	type: types.GlobalType
	value: number
end

local record VmState
	stack: WasmValueStack
	frames: Stack<Frame>
	trapped: boolean
	stacktrace: boolean
	globals: {GlobalValue}
	memory: LinearMemory
	imports: {any}
	cst: boolean

	resolve_func_type: function(number): types.FunctionKind
	func_body: function(number): types.Code
	signature_fetch: function(number): types.FuncType

	trap: function(VmState, string)
end

local record ImportedFunction
	signature: types.FuncType
	name: string
	body: function(VmState)
end

function LinearMemory:assert_index(ea: number, bandwith: number, vm: VmState)
	if ea + bandwith // 8 > self.size then
		vm:trap("Invalid memory access: ea=" .. ea .. ", bandwith=" .. bandwith)
	end
end

function LinearMemory:store_int(ea: number, bandwith: number, value: WasmValue, vm: VmState)
	if value.type == "f32" or value.type == "f64" then
		vm:trap("Tried to store an float as an int")
	end
	
	local val = value.value

	local idx = ea
	while bandwith > 0 do
		self.bytes[idx] = utils.mod_pow2(val, 8)
		idx = idx + 1
		val = val >> 8
		bandwith = bandwith - 8
	end
end

function LinearMemory:load_int(ea: number, bandwith: number): number
	local idx = ea
	local value = 0
	local i = 0
	while bandwith > 0 do
		value = value + (self.bytes[idx] or 0) << i
		idx = idx + 1
		i = i + 8
		bandwith = bandwith - 8
	end

	return value
end

function GlobalValue:write(type: types.ValType, value: number, vm: VmState)
	if self.type.mut == "const" then
		vm:trap("Tried to write to a const value")
	end

	if self.type.type ~= type then
		vm:trap("Tried to write a value of a different type, got " .. type .. ", expected " .. self.type.type)
	end

	self.value = value
end

function GlobalValue:read(): WasmValue
	return {type = self.type.type, value = self.value}
end

function VmState:print_stack()
	print("Stack:")
	local i = #self.stack._et
	while i > 0 do
		local top = self.stack._et[i]
		print("    " .. top.value .. ": " .. top.type)
		i = i - 1
	end
end

function VmState:trap(message: string)
	print("-----------------")
	print("Trap: " .. message)
	print("backtrace:")

	local first = self.frames:pop()
	print("   f[" .. first.funcId .. "]")
	local first_label = first.labels:pop()
	print("      lbl[" .. first_label.kind .. "] @ " .. first_label.current .. " := " .. first_label.code[first_label.current]:tostring())

	while not first.labels:empty() do
		local label = first.labels:pop()
		print("      lbl[" .. label.kind .. "] @ " .. label.current - 1 .. " := " .. label.code[label.current - 1]:tostring())
	end

	while not self.frames:empty() do
		local top = self.frames:pop()
		if top.funcId == -1 then
			print("   --- END ---")
		else
			print("   f[" .. top.funcId .. "]")
			while not top.labels:empty() do
				local label = top.labels:pop()
				print("      lbl[" .. label.kind .. "] @ " .. label.current - 1 .. " := " .. label.code[label.current - 1]:tostring())
			end
		end
	end
	if self.stacktrace then
		self:print_stack()
	end
	self.trapped = true
	error("WASM_TRAP")
end

function VmState.create(
	initial_frame: Frame,
	resolve_func_type: (function(number): types.FunctionKind),
	func_body: (function(number): types.Code), 
	globals: {GlobalValue}, 
	signature_fetch: (function(number): types.FuncType),
	memory: LinearMemory,
	imports: {ImportedFunction}
): VmState 
	local self = setmetatable({} as VmState, { __index = VmState})

	self.stack = WasmValueStack.create()
	self.frames = Stack.create() as Stack<Frame>
	self.frames:push(initial_frame)
	self.resolve_func_type = resolve_func_type
	self.func_body = func_body
	self.trapped = false
	self.stacktrace = false
	self.globals = globals
	self.signature_fetch = signature_fetch
	self.memory = memory
	self.imports = imports
	self.cst = false

	return self
end

function VmState.constant(
	init: {types.Instruction},
	memory: LinearMemory,
	globals: {GlobalValue}
): VmState
	local vm = VmState.create(
		Frame.create(nil, init, 0, -1),
		function(_: number): types.FunctionKind error("can't call functions in constant") end,
		function(_: number): types.Code error("can't call functions in constant") end,
		globals,
		function(_: number): types.FuncType error("can't call functions in constant") end,
		memory,
		nil
	)
	vm.cst = true

	return vm
end


function VmState:current_frame(): Frame
	return self.frames:top()
end

function VmState:call(fn: number, args: {WasmValue}, arity: number)
	if self.resolve_func_type(fn) == "local" then
		local body = self.func_body(fn)
		local locals = locals_array(body)
		for _,l in ipairs(locals) do
			table.insert(args, l)
		end
		self.frames:push(Frame.create(args, body.expr, arity, fn))
	else 
		self:trap("imported functions are not available")
	end
end

function VmState:block(block: types.Block)
	if block.kind == "bare" then
		self:trap("Can't create bare blocks")
	end

	local arity = 0
	if block.blocktype.tag == "indexed" then
		self:trap("VmState:block[indexed] not implemented")
	elseif block.blocktype.tag == "valtype" then
		self:trap("VmState:block[valtype] not implemented")
	end

	if block.kind == "block" then
		local current_frame = self:current_frame()
		current_frame.labels:push({code = block.main, current = 1, kind = block.kind, arity = arity})
	elseif block.kind == "if" then
		self:trap("VmState:if not implemented")
	elseif block.kind == "loop" then
		self:trap("VmState:loop not implemented")
	end
end

function VmState:branch(label: number)
	local current_frame = self:current_frame()
	local lbl: Label
	for _=0,label do
		lbl = current_frame.labels:pop()
	end

	if lbl.kind == "loop" then
		self:trap("looping label not implemented")
	end
end

function VmState:step(): boolean
	local frame = self:current_frame()
	-- Return false if we have returned from the function we called
	--if frame.funcId == -1 then
	--	return false
	--end

	local label = frame:current_label()

	if label.current > #label.code then
		if #self.frames._et == 1 then
			-- we were at the root frame, so we just have to stop executing
			return false
		else
			self:trap("Tried to execute code after the end")
		end
	end

	local instr = label.code[label.current]

	print(instr:tostring())
	--self:print_stack()

	instr.action(self)
	label.current = label.current + 1

	return true
end

function VmState:run()
	while(true) do
		local status, value = pcall(function(): boolean return self:step() end)

		if not status then
			-- Hiding the internal stack trace of the trap
			error("WASM error: " .. tostring(value))
		elseif value == false then
			break
		end

	end
end

function VmState:doCall(indirect: boolean, fn: number) 
	if indirect then
		self:trap("Indirect call not implemented")
	end
	local signature = self.signature_fetch(fn)
	local arg_count = #signature.inputs
	local args = {self.stack:pop_many(arg_count)}
	self:call(fn, args, #signature.outputs)
end

function VmState:pop_type(type: types.ValType): number
	local v = self.stack:pop()

	if v.type ~= type then
		self:trap("Expected on the stack type " .. type .. " got type " .. v.type)
	end

	return v.value
end

local type InstructionAction = function(VmState)

local function castErased(vmaction: InstructionAction): types.InstructionErasedAction
	return function(erased: any)
		vmaction(erased as VmState) 
	end
end

local function unimpInstr(name: string): types.InstructionErasedAction
	return castErased(function(v: VmState) v:trap("instruction is not implemented: " .. name) end)
end

function resolve_ea(v: VmState, memarg: types.MemArg): number
	local i_val = v.stack:pop()
	if i_val.type ~= "i32" then
		v:trap("Invalid index type in memory store: " .. i_val.type)
	end
	local i = i_val.value

	local ea = i + memarg.offset

	return ea
end

function loadInstrAction(signed: boolean, result: types.ValType, bandwith: number, memarg: types.MemArg): InstructionAction
	return function(v: VmState) 
		local ea = resolve_ea(v, memarg)
		v.memory:assert_index(ea, bandwith, v)

		local value: number
		if result == "i32" or result == "i64" then
			if signed then
				v:trap("signed int load not implemented")
			else
				value = v.memory:load_int(ea, bandwith)
			end
		else 
			v:trap("float load instr not implemented")
		end

		v.stack:push({type = result, value = value})
	end
end

function storeInstrAction(type: types.ValType, bandwith: number, memarg: types.MemArg): InstructionAction
	return function(v: VmState) 
		local c = v.stack:pop()
		local ea = resolve_ea(v, memarg)

		if type == "i32" or type == "i64" then
			v.memory:store_int(ea, bandwith, c)
		else
			v:trap("float store instr not implemented")
		end
	end
end

local function constInstr(value: number, type: types.ValType): types.InstructionErasedAction
	return castErased(function(v: VmState) 
		v.stack:push({type = type, value = value})	
	end)
end

local type BinopAction = function(number, number, VmState): number

function binop(type: types.ValType, action: BinopAction): types.InstructionErasedAction
	return castErased(function(v: VmState) 
		local b = v:pop_type(type)
		local a = v:pop_type(type)
		local result = action(a,b,v)
		v.stack:push({type = type, value = result})
	end)
end

function wrapBinOp(op: BinopAction, bandwith: number): BinopAction
	return function(a: number, b: number, v: VmState): number
		local result = op(a, b, v)
		if result < 0 then
			result = result + 2^bandwith
		end
		return result
	end
end

function signBinOp(signed: boolean, bandwith: number, op: BinopAction): BinopAction
	return wrapBinOp(
		function(a: number, b: number, v: VmState): number
			if signed then
				a = utils.signNumber(a, bandwith)
				b = utils.signNumber(b, bandwith)
			end

			return op(a, b, v)
		end, 
		bandwith)
end


local type UnopAction = function(number, VmState): number

function unop(type: types.ValType, action: UnopAction): types.InstructionErasedAction
	return castErased(function(v: VmState) 
		local a = v:pop_type(type)
		local result = action(a,v)
		v.stack:push({type = type, value = result})
	end)
end

function GlobalValue.load(g: types.Global): GlobalValue
	local self = setmetatable({} as GlobalValue, { __index = GlobalValue})

	self.type = g.type

	local vm = VmState.constant(g.init, nil, nil)
	vm:run()
	local value = vm.stack:pop()
	if value.type ~= self.type.type then
		error("Intializer is invalid: expected " .. self.type.type .. ", got: " .. value.type)
	end
	self.value = value.value

	return self
end


return {
	castErased = castErased,
	unimpInstr = unimpInstr,
	constInstr = constInstr,
	wrapBinOp = wrapBinOp,
	signBinOp = signBinOp,
	VmState = VmState,
	LinearMemory = LinearMemory,
	GlobalValue = GlobalValue,
	Frame = Frame,
}
