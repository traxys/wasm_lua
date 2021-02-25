local utils = require("wasm.utils")
local types = require("wasm.types")
local runtime = require("wasm.runtime")
local BytesIterator = utils.BytesIterator
local NumericImpls = require("wasm.numeric")

local type Parser = function<T>(BytesIterator): T

local function readU(bytes: BytesIterator, N:number): number
	local n = bytes();
	if n < 128 and n < 2^N then
		return n 
	else 
		local m = readU(bytes, N-7)
		return 128 * m + (n - 128)
	end
end

local function readS(bytes: BytesIterator, N: number): number
	local n = bytes()
	if n < 64 and n < 2^(N-1) then
		return n
	elseif 64 <= n and n < 128 and n > 128 - 2^(N-1) then
		return n - 128
	else
		local m = readS(bytes, N-7)
		return 128 * m + (n - 128)
	end
end

local function readArray(bytes: BytesIterator, amount: number): {number}
	local array = {}
	for _=1,amount do 
		table.insert(array, bytes())
	end
	return array
end

local function readVec<T>(bytes: BytesIterator, parser: Parser<T>): {T}
	local size = readU(bytes, 32)
	local vec = {}
	for _=1,size do
		table.insert(vec, parser(bytes))
	end
	return vec
end

local function readName(bytes: BytesIterator): string
	local byte_string = readVec(bytes, function(b: BytesIterator): number return b() end)
	return table.concat(utils.mapArray(byte_string, function(n: number): string return string.char(n) end))
end

local function readVecSection<T>(bytes: BytesIterator, parser: Parser<T>): {T}
	local _size = readU(bytes, 32)
	return readVec(bytes, parser)
end

local function advance(bytes: BytesIterator, amount: number)
	for _=1,amount do
		bytes()
	end
end

local function discardSection(bytes: BytesIterator)
	local size = readU(bytes, 32)
	advance(bytes, size)
end

function readValType(bytes: BytesIterator): types.ValType
	local ty = bytes()

	if ty == 0x7f then
		return "i32"
	elseif ty == 0x7e then
		return "i64"
	elseif ty == 0x7d then
		return "f32"
	elseif ty == 0x7c then
		return "f64"
	else
		error("Invalid valtype: " .. tostring(ty))
	end
end

function types.FuncType.parse(bytes: BytesIterator): types.FuncType
	local ty = bytes()
	assert(ty == 0x60, "Unknown functype, expected 0x60, got " .. tostring(ty))

	local self = setmetatable({} as types.FuncType, { __index = types.FuncType, __tostring = function(s: types.FuncType): string return s:tostring() end})
	self.inputs = readVec(bytes, readValType)
	self.outputs = readVec(bytes, readValType)

	return self
end

function types.Limit.parse(bytes: BytesIterator): types.Limit
	local self = setmetatable({} as types.Limit, { __index = types.Limit, __tostring = function(s: types.Limit): string return s:tostring() end})

	local kind = bytes()
	self.min = readU(bytes, 32)

	if kind == 0x01 then
		self.max = readU(bytes, 32)
	elseif kind ~= 0x00 then
		error("unknown limit kind: " .. tostring(kind))
	end

	return self
end

function types.Table.parse(bytes: BytesIterator): types.Table
	local self = setmetatable({} as types.Table, { __index = types.Table, __tostring = function(s: types.Table): string return s:tostring() end})
	
	local kind = bytes()
	assert(kind == 0x70, "table only allows funcref, got " .. kind)

	self.limit = types.Limit.parse(bytes)

	return self
end

function types.Mem.parse(bytes: BytesIterator): types.Mem
	local self = setmetatable({} as types.Mem, { __index = types.Mem, __tostring = function(s: types.Mem): string return s:tostring() end})
	
	self.limit = types.Limit.parse(bytes)

	return self
end

function readMut(bytes: BytesIterator): types.Mut
	local kind = bytes()
	if kind == 0x00 then
		return "const"
	elseif kind == 0x01 then
		return "var"
	else
		error("invalid mut kind")
	end
end

function types.GlobalType.parse(bytes: BytesIterator): types.GlobalType
	local self = setmetatable({} as types.GlobalType, { __index = types.GlobalType, __tostring = function(s: types.GlobalType): string return s:tostring() end})
	
	self.type = readValType(bytes)
	self.mut = readMut(bytes)

	return self
end

function types.Import.parse(bytes: BytesIterator): types.Import
	local self = setmetatable({} as types.Import, { __index = types.Import, __tostring = function(s: types.Import): string return s:tostring() end})
	self.mod = readName(bytes)
	self.name = readName(bytes)

	local desc_type = bytes()
	if desc_type == 0x00 then
		self.desc = {tag = "funcref", value = readU(bytes, 32)}
	elseif desc_type == 0x01 then
		self.desc = {tag = "table", value = types.Table.parse(bytes)}
	elseif desc_type == 0x02 then
		self.desc = {tag = "memory", value = types.Mem.parse(bytes)}
	elseif desc_type == 0x03 then
		self.desc = {tag = "global", value = types.GlobalType.parse(bytes)}
	else
		error("invalid desc_type: " .. tostring(desc_type))
	end

	return self
end

function types.Export.parse(bytes: BytesIterator): types.Export
	local self = setmetatable({} as types.Export, { __index = types.Export, __tostring = function(s: types.Export): string return s:tostring() end})
	
	self.name = readName(bytes)
	local kind = bytes()

	if kind == 0x00 then
		self.desc = "func"
	elseif kind == 0x01 then
		self.desc = "table"
	elseif kind == 0x02 then
		self.desc = "mem"
	elseif kind == 0x03 then
		self.desc = "global"
	else
		error("Invalid kind in export: " .. kind)
	end
	
	self.ref = readU(bytes, 32)

	return self
end

function types.Locals.parse(bytes: BytesIterator): types.Locals
	local self = setmetatable({} as types.Locals, { __index = types.Locals, __tostring = function(s: types.Locals): string return s:tostring() end})

	self.n = readU(bytes, 32)
	self.type = readValType(bytes)

	return self
end

function types.MemArg.parse(bytes: BytesIterator): types.MemArg
	local self = setmetatable({} as types.MemArg, { __index = types.MemArg, __tostring = function(s: types.MemArg): string return s:tostring() end})

	self.align = readU(bytes, 32)
	self.offset = readU(bytes, 32)

	return self
end
local function memInstr(self: types.Instruction, bytes: BytesIterator, opcode: number)
	if opcode >= 0x28 and opcode <= 0x35 then
		local ty: types.ValType
		if opcode == 0x28 or opcode == 0x2C or opcode == 0x2D or opcode == 0x2E or opcode == 0x2F then
			ty = "i32"
		elseif opcode == 0x29 or opcode == 0x30 or opcode == 0x31 or opcode == 0x32 or opcode == 0x33 or opcode == 0x34 or opcode == 0x35 then
			ty = "i64"
		 elseif opcode == 0x2A then
			ty = "f32"
		elseif opcode == 0x2b then
			ty = "f64"
		end
		
		local signed: boolean
		if opcode == 0x2C or opcode == 0x2E or opcode == 0x30 or opcode == 0x32 or opcode == 0x34 then
			signed = true
		elseif opcode == 0x2D or opcode ==  0x2F or opcode ==  0x31 or opcode ==  0x33 or opcode ==  0x35 then
			signed = false
		end

		local bandwith: number
		if opcode == 0x2C or opcode == 0x2D or opcode == 0x30 or opcode == 0x31 then
			bandwith = 8
		elseif opcode == 0x2E or opcode ==  0x2F or opcode ==  0x32 or opcode ==  0x33 then
			bandwith = 16
		elseif opcode == 0x34 or opcode == 0x35 or opcode == 0x28 then
			bandwith = 32
		elseif opcode == 0x29 then
			bandwith = 64
		end

		self.name = "load"
		self.action = runtime.castErased(loadInstrAction(signed, ty, bandwith, types.MemArg.parse(bytes)))
	elseif opcode >= 0x36 and opcode <= 0x3E then
		local ty: types.ValType
		if opcode == 0x36 or opcode == 0x3A or opcode == 0x3B then
			ty = "i32"
		elseif opcode == 0x37 or opcode == 0x3C or opcode == 0x3D or opcode == 0x3E then
			ty = "i64"
		elseif opcode == 0x38 then
			ty = "f32"
		elseif opcode == 0x39 then
			ty = "f64"
		end

		local bandwith: number = nil
		if opcode == 0x3A or opcode == 0x3C then
			bandwith = 8
		elseif opcode == 0x3D or opcode == 0x3B then
			bandwith = 16
		elseif opcode == 0x36 or opcode == 0x3E then
			bandwith = 32
		elseif opcode == 0x37 then
			bandwith = 64
		end

		self.name = "store"
		self.action = runtime.castErased(storeInstrAction(ty, bandwith, types.MemArg.parse(bytes)))
	elseif opcode == 0x3F then
		assert(bytes() == 0x00, "memory.size requires a following 0 byte")
		self.name = "memory.size"
		self.action = runtime.unimpInstr("size not implemented")
	elseif opcode == 0x3E then 
		assert(bytes() == 0x00, "memory.grow requires a following 0 byte")
		self.name = "memory.grow"
		self.action = runtime.unimpInstr("grow not implemented")
	end
end

local function varInstr(self: types.Instruction, bytes: BytesIterator, opcode: number)
	local enum VarAction
		"get"
		"set"
		"tee"
	end

	local function varInstruction(global: boolean, action: VarAction, index: number, v: runtime.VmState) 
		if global then
			local global_value = v.globals[index + 1]
			if action == "get" then
				local val = global_value:read()
				v.stack:push(val)
			else -- can't be tee, can only be "set"
				local val = v.stack:pop()
				
				global_value:write(val.type, val.value, v)
			end
		else 
			local local_value = v:current_frame().locals[index + 1]
			if action == "get" then
				v.stack:push({type = local_value.type, value = local_value.value})
			elseif action == "set" then
				local val = v.stack:pop()

				if val.type ~= local_value.type then
					v:trap("Invalid local.set write, expected type " .. local_value.type .. " got " .. val.type)
				end

				local_value.value = val.value
			else -- action is "tee"
				local val = v.stack:top()

				if val.type ~= local_value.type then
					v:trap("Invalid local.tee write, expected type " .. local_value.type .. " got " .. val.type)
				end

				local_value.value = val.value
			end
		end
	end

	local index = readU(bytes, 32)

	if opcode == 0x20 then
		self.name = "local.get"
		self.action = runtime.castErased(function(v: runtime.VmState) varInstruction(false, "get", index, v) end)
	elseif opcode == 0x21 then
		self.name = "local.set"
		self.action = runtime.castErased(function(v: runtime.VmState) varInstruction(false, "set", index, v) end)
	elseif opcode == 0x22 then
		self.name = "local.tee"
		self.action = runtime.castErased(function(v: runtime.VmState) varInstruction(false, "tee", index, v) end)
	elseif opcode == 0x23 then
		self.name = "global.get"
		self.action = runtime.castErased(function(v: runtime.VmState) varInstruction(true, "get", index, v) end)
	elseif opcode == 0x24 then
		self.name = "global.get"
		self.action = runtime.castErased(function(v: runtime.VmState) varInstruction(true, "set", index, v) end)
	else 
		error("Invalid var instr: " .. opcode)
	end
end

local function numericInstr(self: types.Instruction, opcode: number)
	if opcode == 0x45 then
		self.name = "eqz"
		self.action = unop("i32", NumericImpls.eqz)
	elseif opcode == 0x46 then
		self.name = "eq"
		self.action = binop("i32", NumericImpls.eq)
	elseif opcode == 0x47 then
		self.name = "ne"
		self.action = binop("i32", NumericImpls.ne)
	elseif opcode == 0x48 then
		self.name = "lt"
		self.action = binop("i32", signBinOp(true, 32, NumericImpls.lt))
	elseif opcode == 0x49 then
		self.name = "lt"
		self.action = binop("i32", signBinOp(false, 32, NumericImpls.lt))
	elseif opcode == 0x4a then
		self.name = "gt"
		self.action = binop("i32", signBinOp(true, 32, NumericImpls.gt))
	elseif opcode == 0x4b then
		self.name = "gt"
		self.action = binop("i32", signBinOp(false, 32, NumericImpls.gt))
	elseif opcode == 0x4c then
		self.name = "le"
		self.action = binop("i32", signBinOp(true, 32, NumericImpls.le))
	elseif opcode == 0x4d then
		self.name = "le"
		self.action = binop("i32", signBinOp(false, 32, NumericImpls.le))
	elseif opcode == 0x4e then
		self.name = "ge"
		self.action = binop("i32", signBinOp(true, 32, NumericImpls.ge))
	elseif opcode == 0x4f then
		self.name = "ge"
		self.action = binop("i32", signBinOp(false, 32, NumericImpls.ge))
	elseif opcode == 0x50 then
		self.name = "eqz"
		self.action = unop("i64", NumericImpls.eqz)
	elseif opcode == 0x51 then
		self.name = "eq"
		self.action = binop("i64", NumericImpls.eq)
	elseif opcode == 0x52 then
		self.name = "ne"
		self.action = binop("i64", NumericImpls.ne)
	elseif opcode == 0x53 then
		self.name = "lt"
		self.action = binop("i64", signBinOp(true, 64, NumericImpls.lt))
	elseif opcode == 0x54 then
		self.name = "lt"
		self.action = binop("i64", signBinOp(false, 64, NumericImpls.lt))
	elseif opcode == 0x55 then
		self.name = "gt"
		self.action = binop("i64", signBinOp(true, 64, NumericImpls.gt))
	elseif opcode == 0x56 then
		self.name = "gt"
		self.action = binop("i64", signBinOp(false, 64, NumericImpls.gt))
	elseif opcode == 0x57 then
		self.name = "le"
		self.action = binop("i64", signBinOp(true, 64, NumericImpls.le))
	elseif opcode == 0x58 then
		self.name = "le"
		self.action = binop("i64", signBinOp(false, 64, NumericImpls.le))
	elseif opcode == 0x59 then
		self.name = "ge"
		self.action = binop("i64", signBinOp(true, 64, NumericImpls.ge))
	elseif opcode == 0x5a then
		self.name = "ge"
		self.action = binop("i64", signBinOp(false, 64, NumericImpls.ge))
	elseif opcode == 0x5b then
		self.name = "eq"
		self.action = binop("f32", NumericImpls.eq)
	elseif opcode == 0x5c then
		self.name = "ne"
		self.action = binop("f32", NumericImpls.ne)
	elseif opcode == 0x5d then
		self.name = "lt"
		self.action = binop("f32", NumericImpls.lt)
	elseif opcode == 0x5e then
		self.name = "gt"
		self.action = binop("f32", NumericImpls.gt)
	elseif opcode == 0x5f then
		self.name = "le"
		self.action = binop("f32", NumericImpls.le)
	elseif opcode == 0x60 then
		self.name = "ge"
		self.action = binop("f32", NumericImpls.ge)
	elseif opcode == 0x61 then
		self.name = "eq"
		self.action = binop("f64", NumericImpls.eq)
	elseif opcode == 0x62 then
		self.name = "ne"
		self.action = binop("f64", NumericImpls.ne)
	elseif opcode == 0x63 then
		self.name = "lt"
		self.action = binop("f64", NumericImpls.lt)
	elseif opcode == 0x64 then
		self.name = "gt"
		self.action = binop("f64", NumericImpls.gt)
	elseif opcode == 0x65 then
		self.name = "le"
		self.action = binop("f64", NumericImpls.le)
	elseif opcode == 0x66 then
		self.name = "ge"
		self.action = binop("f64", NumericImpls.ge)
	elseif opcode == 0x67 then
		self.name = "clz"
		self.action = unop("i32", NumericImpls.clz)
	elseif opcode == 0x68 then
		self.name = "ctz"
		self.action = unop("i32", NumericImpls.ctz)
	elseif opcode == 0x69 then
		self.name = "popcnt"
		self.action = unop("i32", NumericImpls.popcnt)
	elseif opcode == 0x6a then
		self.name = "add"
		self.action = binop("i32", NumericImpls.add)
	elseif opcode == 0x6b then
		self.name = "sub"
		self.action = binop("i32", wrapBinOp(NumericImpls.sub, 32))
	elseif opcode == 0x6c then
		self.name = "mul"
		self.action = binop("i32", NumericImpls.mul)
	elseif opcode == 0x6d then
		self.name = "div"
		self.action = binop("i32", signBinOp(true, 32, NumericImpls.div))
	elseif opcode == 0x6e then
		self.name = "div"
		self.action = binop("i32", signBinOp(false, 32, NumericImpls.div))
	elseif opcode == 0x6f then
		self.name = "rem"
		self.action = binop("i32", signBinOp(true, 32, NumericImpls.rem))
	elseif opcode == 0x70 then
		self.name = "rem"
		self.action = binop("i32", signBinOp(false, 32, NumericImpls.rem))
	elseif opcode == 0x71 then
		self.name = "and"
		self.action = binop("i32", NumericImpls.i_and)
	elseif opcode == 0x72 then
		self.name = "or"
		self.action = binop("i32", NumericImpls.i_or)
	elseif opcode == 0x73 then
		self.name = "xor"
		self.action = binop("i32", NumericImpls.xor)
	elseif opcode == 0x74 then
		self.name = "shl"
		self.action = binop("i32", NumericImpls.shl)
	elseif opcode == 0x75 then
		self.name = "shr"
		self.action = binop("i32", signBinOp(true, 32, NumericImpls.shr))
	elseif opcode == 0x76 then
		self.name = "shr"
		self.action = binop("i32", signBinOp(false, 32, NumericImpls.shr))
	elseif opcode == 0x77 then
		self.name = "rotl"
		self.action = binop("i32", NumericImpls.rotl)
	elseif opcode == 0x78 then
		self.name = "rotr"
		self.action = binop("i32", NumericImpls.rotr)
	elseif opcode == 0x79 then
		self.name = "clz"
		self.action = unop("i64", NumericImpls.clz)
	elseif opcode == 0x7a then
		self.name = "ctz"
		self.action = unop("i64", NumericImpls.ctz)
	elseif opcode == 0x7b then
		self.name = "popcnt"
		self.action = unop("i64", NumericImpls.popcnt)
	elseif opcode == 0x7c then
		self.name = "add"
		self.action = binop("i64", NumericImpls.add)
	elseif opcode == 0x7d then
		self.name = "sub"
		self.action = binop("i64", wrapBinOp(NumericImpls.sub, 64))
	elseif opcode == 0x7e then
		self.name = "mul"
		self.action = binop("i64", NumericImpls.mul)
	elseif opcode == 0x7f then
		self.name = "div"
		self.action = binop("i64", signBinOp(true, 64, NumericImpls.div))
	elseif opcode == 0x80 then
		self.name = "div"
		self.action = binop("i64", signBinOp(false, 64, NumericImpls.div))
	elseif opcode == 0x81 then
		self.name = "rem"
		self.action = binop("i64", signBinOp(true, 64, NumericImpls.rem))
	elseif opcode == 0x82 then
		self.name = "rem"
		self.action = binop("i64", signBinOp(false, 64, NumericImpls.rem))
	elseif opcode == 0x83 then
		self.name = "and"
		self.action = binop("i64", NumericImpls.i_and)
	elseif opcode == 0x84 then
		self.name = "or"
		self.action = binop("i64", NumericImpls.i_or)
	elseif opcode == 0x85 then
		self.name = "xor"
		self.action = binop("i64", NumericImpls.xor)
	elseif opcode == 0x86 then
		self.name = "shl"
		self.action = binop("i64", NumericImpls.shl)
	elseif opcode == 0x87 then
		self.name = "shr"
		self.action = binop("i64", signBinOp(true, 64, NumericImpls.shr))
	elseif opcode == 0x88 then
		self.name = "shr"
		self.action = binop("i64", signBinOp(false, 64, NumericImpls.shr))
	elseif opcode == 0x89 then
		self.name = "rotl"
		self.action = binop("i64", NumericImpls.rotl)
	elseif opcode == 0x8a then
		self.name = "rotr"
		self.action = binop("i64", NumericImpls.rotr)
	else
		error("numeric instruction not implemented: " .. opcode)
	end
end

local function blockInstr(self: types.Instruction, block: types.Block)
	self.name = "block"
	self.action = function(v: runtime.VmState) v:block(block) end
end

function types.Instruction.parse(bytes: BytesIterator): types.Instruction
	local self = setmetatable({} as types.Instruction, { __index = types.Instruction, __tostring = function(s: types.Instruction): string return s:tostring() end})

	local opcode = bytes()
	if opcode == 0x05 then
		self.name = "else_start"
	elseif opcode == 0x0B then
		self.name = "block_end"
	elseif opcode == 0x00 then
		self.name = "unreachable"
		self.action = runtime.castErased(function(s: runtime.VmState) s:trap("unreachable reached") end)
	elseif opcode == 0x01 then
		self.name = "nop"
		self.action = function(_: any) end
	elseif opcode >= 0x02 and opcode <= 0x04 then
		local block = types.Block.parse(bytes, opcode)
		blockInstr(self, block)
	elseif opcode == 0x0C then
		local _label = readU(bytes, 32)
		self.name = "branch"
		self.action = runtime.unimpInstr("branch")
	elseif opcode == 0x0d then
		local label = readU(bytes, 32)
		self.name = "branch_if"
		self.action = runtime.castErased(function(v: runtime.VmState)
			local bool = v:pop_type("i32")
			if bool ~= 0 then
				v:branch(label)
			end
		end)
	elseif opcode == 0x0e then
		local _labels = readVec(bytes, function(b: BytesIterator): number return readU(b, 32) end)
		local _l = readU(bytes, 32)
		self.name = "branch_table"
		self.action = runtime.unimpInstr("branch_table")
	elseif opcode == 0x0F then
		self.name = "return"
		self.action = runtime.unimpInstr("return")
	elseif opcode == 0x10 then
		local func_id = readU(bytes, 32)
		self.name = "call"
		self.action = function(v: runtime.VmState) v:doCall(false, func_id) end
	elseif opcode == 0x11 then
		local func_id = readU(bytes, 32)
		assert(bytes() == 0x00, "no 0 byte after call indirect")
		self.name = "call_indirect"
		self.action = function(v: runtime.VmState) v:doCall(true, func_id) end
	elseif opcode == 0x1a then
		self.name = "drop"
		self.action = runtime.unimpInstr("drop")
	elseif opcode == 0x1B then
		self.name = "select"
		self.action = runtime.unimpInstr("select")
	elseif opcode >= 0x20 and opcode <= 0x24 then
		varInstr(self, bytes, opcode)
	elseif opcode >= 0x28 and opcode <= 0x40 then
		memInstr(self, bytes, opcode)
	elseif opcode == 0x41 then
		self.name = "const"
		local val = readS(bytes, 32)
		self.action = runtime.constInstr(val, "i32")
	elseif opcode == 0x42 then
		self.name = "const"
		local val = readS(bytes, 64)
		self.action = runtime.constInstr(val, "i64")
	elseif opcode == 0x43 or opcode == 0x44 then
		error("float litteral not implemented")
	elseif opcode >=0x45 and opcode <= 0x8a then
		numericInstr(self, opcode)
	else
		error("instruction not implemented: " .. opcode)
	end

	return self
end

function types.Block.parse(bytes: BytesIterator, opcode: number): types.Block
	local self = setmetatable({} as types.Block, { __index = types.Block, __tostring = function(s: types.Block): string return s:tostring() end})

	if opcode == nil then
		self.kind = "bare"
		self.blocktype = nil
	else 
		local start = bytes()
		if start == 0x40 then
			self.blocktype = {tag = "epsilon", value = nil}
		elseif start == 0x7F then
			self.blocktype = {tag = "valtype", value = "i32"}
		elseif start == 0x7e then 
			self.blocktype = {tag = "valtype", value = "i64"}
		elseif start == 0x7d then
			self.blocktype = {tag = "valtype", value = "f32"}
		elseif start == 0x7c then
			self.blocktype = {tag = "valtype", value = "f64"}
		else
			self.blocktype = {tag = "indexed", value = readS(utils.prepend(start, bytes), 33)}
		end

		if opcode == 0x02 then
			self.kind = "block"
		elseif opcode == 0x03 then
			self.kind = "loop"
		elseif opcode == 0x04 then
			self.kind = "if"
		else 
			error("Invalid block kind: " .. opcode)
		end
	end
	
	local has_else = false
	self.main = {}
	while(true) do
		local i = types.Instruction.parse(bytes)
		if i.name == "block_end" then
			break
		elseif i.name == "else_start" then
			has_else = true
			break
		else 
			table.insert(self.main, i)
		end
	end

	self.else_expr = nil
	if has_else then
		self.else_expr = {}
		while(true) do
			local i = types.Instruction.parse(bytes)
			if i.name == "block_end" then
				break
			elseif i.name == "else_start" then
				error("Did not expect start of else in else")
			else
				table.insert(self.else_expr, i)
			end
		end
	end
	
	return self
end

function types.Code.parse(bytes: BytesIterator): types.Code
	local self = setmetatable({} as types.Code, { __index = types.Code, __tostring = function(s: types.Code): string return s:tostring() end})
	
	local _size = readU(bytes, 32)
	self.locals = readVec(bytes, function(b: BytesIterator): types.Locals return types.Locals.parse(b) end)
	self.expr = types.Block.parse(bytes, nil).main

	return self
end

function types.Global.parse(bytes: BytesIterator): types.Global
	local self = setmetatable({} as types.Global, { __index = types.Global, __tostring = function(s: types.Global): string return s:tostring() end})

	self.type = types.GlobalType.parse(bytes)
	self.init = types.Block.parse(bytes, nil).main

	return self
end

local record Program 
	type: {types.FuncType}
	import: {types.Import}
	functions: {number} -- those are references
	table: {types.Table}
	memory: {types.Mem}
	export: {types.Export}
	code: {types.Code}
	global: {types.Global}

	max_import: number
	func_import: {number:number}
end

function Program:createMemory(): runtime.LinearMemory
	if #self.memory ~= 1 then
		error("Only programs with exactly one memory are supported")
	end

	local limit = self.memory[1].limit
	return runtime.LinearMemory.create(limit.min, limit.max)
end

function Program:resolve(fn: number): types.FunctionKind 
	if fn > self.max_import then
		return "local"
	else 
		return "import"
	end
end

function Program:signature(fn: number): types.FuncType
	local type_idx: number
	if self:resolve(fn) == "local" then
		type_idx = self.functions[fn - self.max_import]
	else
		type_idx = self.func_import[fn]
	end

	return self.type[type_idx + 1]
end

function Program:func_body(fn: number): types.Code
	local index = fn - self.max_import
	return self.code[index]
end

function Program:is_init_fn(fn: number): boolean
	local sig_id = self.functions[fn] + 1
	local sig = self.type[sig_id]
	return #sig.inputs == 0 and #sig.outputs == 0
end

function Program.parse(bytes: BytesIterator): Program
	local self = setmetatable({} as Program, { __index = Program})

	local magic = readArray(bytes, 4)
	assert(utils.arrayEqual(magic,{0x00, 0x61, 0x73, 0x6d}), "magic number is not valid, got {" .. table.concat(utils.stringArray(magic), ",") .. "}")

	local version = readArray(bytes, 4)
	assert(utils.arrayEqual(version,{0x01, 0x00, 0x00, 0x00}), "only version 1 is supported, got {" .. table.concat(utils.stringArray(version), ",") .. "}")
	
	while(true) do
		local section_id = bytes()
		if section_id == nil then
			break
		end

		if section_id == 0 then
			discardSection(bytes)
		elseif section_id == 1 then
			local parserFn: Parser<types.FuncType> = function(bytes: BytesIterator): types.FuncType 
				return types.FuncType.parse(bytes)
			end
			self.type = readVecSection(bytes, parserFn)
		elseif section_id == 2 then
			local parserFn: Parser<types.Import> = function(bytes: BytesIterator): types.Import 
				return types.Import.parse(bytes)
			end
			self.import = readVecSection(bytes, parserFn)
		elseif section_id == 3 then
			self.functions = readVecSection(bytes, function(bytes: BytesIterator): number return readU(bytes, 32) end)
		elseif section_id == 4 then
			self.table = readVecSection(bytes, function(bytes: BytesIterator): types.Table return types.Table.parse(bytes) end)
		elseif section_id == 5 then
			self.memory = readVecSection(bytes, function(bytes: BytesIterator): types.Mem return types.Mem.parse(bytes) end)
		elseif section_id == 6 then
			self.global = readVecSection(bytes, function(bytes: BytesIterator): types.Global return types.Global.parse(bytes) end)
		elseif section_id == 7 then
			self.export = readVecSection(bytes, function(bytes: BytesIterator): types.Export return types.Export.parse(bytes) end)
		elseif section_id == 8 then
			print("Todo: start")
			discardSection(bytes)
		elseif section_id == 9 then
			print("Todo: element")
			discardSection(bytes)
		elseif section_id == 10 then
			self.code = readVecSection(bytes, function(bytes: BytesIterator): types.Code return types.Code.parse(bytes) end)
		elseif section_id == 11 then
			print("Todo: data")
			discardSection(bytes)
		else
			error("section id " .. tostring(section_id) .. " is invalid")
		end
	end

	self.max_import = -1
	self.func_import = {}

	for i,v in ipairs(self.import) do
		if v.desc.tag == "funcref" then
			self.max_import = self.max_import + 1
			self.func_import[i] = v.desc.value as number
		end
	end

	return self
end

function Program:print() 
	print("Types:")
	for _,v in ipairs(self.type) do
		print("    " .. tostring(v))
	end
	print("Import:")
	for _,v in ipairs(self.import) do
		print("    " .. tostring(v))
	end
	print("Functions:")
	for i,v in ipairs(self.functions) do
		print("    f[" .. i .. "] := " .. v) 
	end
	print("Tables:")
	for _,v in ipairs(self.table) do
		print("    " .. tostring(v))
	end
	print("Mem:")
	for _,v in ipairs(self.memory) do
		print("    " .. tostring(v))
	end
	print("Export:")
	for _,v in ipairs(self.export) do
		print("    " .. tostring(v))
	end
	print("Global:")
	for _,v in ipairs(self.global) do
		print("    " .. tostring(v))
	end
	print("Code:")
	for _,v in ipairs(self.code) do
		print("    " .. tostring(v))
	end
end

return {
	Parser = Parser,
	readU = readU,
	readS = readS,
	readArray = readArray,
	readVec = readVec,
	readName = readName,
	readVecSection = readVecSection,
	advance = advance,
	discardSection = discardSection,
	readValType = readValType,
	Program = Program,
}
