local utils = require("wasm.utils")
local BytesIterator = utils.BytesIterator

local enum ValType 
	"i32"
	"i64"
	"f32"
	"f64"
end

local record WasmValue
	type: ValType
	value: number
end

local record FuncType 
	inputs: {ValType}
	outputs: {ValType}

	parse: function(BytesIterator): FuncType
end

function FuncType:tostring(): string
	return "f(" .. table.concat(self.inputs, ",") .. ") -> (" .. table.concat(self.outputs, ",") .. ")"
end

local record Limit
	min: number
	max: number

	parse: function(BytesIterator): Limit
end

function Limit:tostring(): string
	return "{min: " .. self.min .. ", max: " .. (tostring(self.max) or "nil") .. "}"
end

local record Table
	limit: Limit

	parse: function(BytesIterator): Table
end

function Table:tostring(): string
	return "funcref(limit: " .. tostring(self.limit) .. ")" 
end

local record Mem
	limit: Limit

	parse: function(BytesIterator): Mem
end

function Mem:tostring(): string
	return "memlimit: " .. tostring(self.limit)
end

local enum Mut
	"var"
	"const"
end

local record GlobalType 
	type: ValType
	mut: Mut

	parse: function(BytesIterator): GlobalType
end

function GlobalType:tostring(): string
	return self.mut .. " " .. self.type
end

local enum ImportDescription 
	"funcref" -- ref: int
	"table"   -- table: Table
	"memory"  -- mem: MemImport
	"global"  -- global: GlobalImport
end

local record Import
	mod: string
	name: string
	desc: utils.Sum<ImportDescription>

	parse: function(BytesIterator): Import
end

function Import:tostring(): string
	return self.mod .. "." .. self.name .. " := " .. self.desc.tag .. "(" .. tostring(self.desc.value) .. ")"
end

local enum ExportDescription
	"func"
	"table"
	"mem"
	"global"
end

local record Export
	name: string
	desc: ExportDescription
	ref: number

	parse: function(BytesIterator): Export
end

function Export:tostring(): string
	return "export " .. self.name .. " := " .. self.desc .. ":" .. self.ref
end

local record Locals
	n: number
	type: ValType

	parse: function(BytesIterator): Locals
end

function Locals:tostring(): string
	return "(" .. self.type .. ")^" .. self.n
end

local type InstructionErasedAction = function(any)

local enum InstructionName
	"block_end"
	"else_start"
	"unreachable"
	"nop"
	"branch"
	"branch_if"
	"branch_table"
	"return"
	"call"
	"call_indirect"
	"drop"
	"select"
	"local.get"
	"local.set"
	"local.tee"
	"global.get"
	"global.set"
	"const"
	"clz"
	"ctz"
	"popcnt"
	"add"
	"sub"
	"mul"
	"div"
	"rem"
	"and"
	"or"
	"xor"
	"shl"
	"shr"
	"rotl"
	"rotr"
	"abs"
	"neg"
	"sqrt"
	"ceil"
	"floor"
	"trunc"
	"nearest"
	"min"
	"max"
	"copysign"
	"eqz"
	"eq"
	"ne"
	"lt"
	"gt"
	"le"
	"ge"
	"extend"
	"wrap"
	"trunc"
	"demote"
	"promote"
	"convert"
	"reinterpret"
	"load"
	"store"
	"memory.grow"
	"memory.size"
	"block"
end

local record Instruction
	name: InstructionName
	action: InstructionErasedAction

	parse: function(BytesIterator): Instruction
end

function Instruction:tostring(): string
	return self.name
end

local enum BlockType
	"epsilon" -- nil
	"valtype" -- ValType
	"indexed" -- number
end

local enum BlockKind 
	"loop"
	"block"
	"if"
	"bare"
end

local record Block
	blocktype: utils.Sum<BlockType>
	kind: BlockKind
	main: {Instruction}
	else_expr: {Instruction}

	parse: function(BytesIterator, opcode: number): Block
end

function Block:tostring(): string
	return "TODO"
end

local record MemArg
	align: number
	offset: number

	parse: function(BytesIterator): MemArg
end

function MemArg:tostring(): string
	return "{a: " .. self.align .. ", o: " .. self.offset .. "}"
end

local record Code
	locals: {Locals}
	expr: {Instruction}

	parse: function(BytesIterator): Code
end

function Code:tostring(): string
	return table.concat(utils.stringArray(self.locals), ";") .. " -> <...>"
end

local enum FunctionKind
	"local"
	"import"
end

local record Global
	type: GlobalType
	init: {Instruction}

	parse: function(BytesIterator): Global
end

function Global:tostring(): string
	return tostring(self.type) .. " := " .. table.concat(utils.mapArray(self.init, function(instr: Instruction): string return instr.name end), ";")
end


return {
	ValType = ValType,
	FuncType = FuncType,
	Limit = Limit,
	Table = Table,
	Mem = Mem,
	Mut = Mut,
	GlobalType = GlobalType,
	ImportDescription = ImportDescription,
	Import = Import,
	ExportDescription = ExportDescription,
	Export = Export,
	Locals = Locals,
	InstructionErasedAction = InstructionErasedAction,
	InstructionName = InstructionName,
	Instruction = Instruction,
	BlockType = BlockType,
	BlockKind = BlockKind,
	Block = Block,
	MemArg = MemArg,
	Code = Code,
	FunctionKind = FunctionKind,
	Global = Global,
	WasmValue = WasmValue,
}
