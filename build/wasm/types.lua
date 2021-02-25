local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local table = _tl_compat and _tl_compat.table or table; local utils = require("wasm.utils")
local BytesIterator = utils.BytesIterator

local ValType = {}






local WasmValue = {}




local FuncType = {}






function FuncType:tostring()
   return "f(" .. table.concat(self.inputs, ",") .. ") -> (" .. table.concat(self.outputs, ",") .. ")"
end

local Limit = {}






function Limit:tostring()
   return "{min: " .. self.min .. ", max: " .. (tostring(self.max) or "nil") .. "}"
end

local Table = {}





function Table:tostring()
   return "funcref(limit: " .. tostring(self.limit) .. ")"
end

local Mem = {}





function Mem:tostring()
   return "memlimit: " .. tostring(self.limit)
end

local Mut = {}




local GlobalType = {}






function GlobalType:tostring()
   return self.mut .. " " .. self.type
end

local ImportDescription = {}






local Import = {}







function Import:tostring()
   return self.mod .. "." .. self.name .. " := " .. self.desc.tag .. "(" .. tostring(self.desc.value) .. ")"
end

local ExportDescription = {}






local Export = {}







function Export:tostring()
   return "export " .. self.name .. " := " .. self.desc .. ":" .. self.ref
end

local Locals = {}






function Locals:tostring()
   return "(" .. self.type .. ")^" .. self.n
end

local InstructionErasedAction = {}

local InstructionName = {}
































































local Instruction = {}






function Instruction:tostring()
   return self.name
end

local BlockType = {}





local BlockKind = {}






local Block = {}








function Block:tostring()
   return "TODO"
end

local MemArg = {}






function MemArg:tostring()
   return "{a: " .. self.align .. ", o: " .. self.offset .. "}"
end

local Code = {}






function Code:tostring()
   return table.concat(utils.stringArray(self.locals), ";") .. " -> <...>"
end

local FunctionKind = {}




local Global = {}






function Global:tostring()
   return tostring(self.type) .. " := " .. table.concat(utils.mapArray(self.init, function(instr) return instr.name end), ";")
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
