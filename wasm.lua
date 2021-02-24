local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local assert = _tl_compat and _tl_compat.assert or assert; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local pcall = _tl_compat and _tl_compat.pcall or pcall; local string = _tl_compat and _tl_compat.string or string; local table = _tl_compat and _tl_compat.table or table; local _tl_table_unpack = unpack or table.unpack; local input = { 0, 97, 115, 109, 1, 0, 0, 0, 1, 13, 3, 96, 1, 127, 1, 127, 96, 1, 127, 0, 96, 0, 0, 2, 15, 1, 3, 101, 110, 118, 7, 112, 117, 116, 99, 104, 97, 114, 0, 0, 3, 4, 3, 1, 0, 2, 4, 5, 1, 112, 1, 1, 1, 5, 3, 1, 0, 2, 6, 8, 1, 127, 1, 65, 128, 136, 4, 11, 7, 19, 2, 6, 109, 101, 109, 111, 114, 121, 2, 0, 6, 95, 115, 116, 97, 114, 116, 0, 3, 10, 244, 2, 3, 141, 1, 1, 14, 127, 35, 128, 128, 128, 128, 0, 33, 1, 65, 16, 33, 2, 32, 1, 32, 2, 107, 33, 3, 32, 3, 36, 128, 128, 128, 128, 0, 32, 3, 32, 0, 54, 2, 12, 32, 3, 40, 2, 12, 33, 4, 2, 64, 2, 64, 32, 4, 13, 0, 12, 1, 11, 32, 3, 40, 2, 12, 33, 5, 65, 10, 33, 6, 32, 5, 32, 6, 109, 33, 7, 32, 7, 16, 129, 128, 128, 128, 0, 32, 3, 40, 2, 12, 33, 8, 65, 10, 33, 9, 32, 8, 32, 9, 111, 33, 10, 65, 48, 33, 11, 32, 10, 32, 11, 106, 33, 12, 32, 12, 16, 128, 128, 128, 128, 0, 26, 11, 65, 16, 33, 13, 32, 3, 32, 13, 106, 33, 14, 32, 14, 36, 128, 128, 128, 128, 0, 15, 11, 198, 1, 1, 23, 127, 35, 128, 128, 128, 128, 0, 33, 1, 65, 16, 33, 2, 32, 1, 32, 2, 107, 33, 3, 32, 3, 36, 128, 128, 128, 128, 0, 65, 1, 33, 4, 32, 3, 32, 0, 54, 2, 8, 32, 3, 40, 2, 8, 33, 5, 32, 5, 33, 6, 32, 4, 33, 7, 32, 6, 32, 7, 76, 33, 8, 65, 1, 33, 9, 32, 8, 32, 9, 113, 33, 10, 2, 64, 2, 64, 32, 10, 69, 13, 0, 65, 1, 33, 11, 32, 3, 32, 11, 54, 2, 12, 12, 1, 11, 32, 3, 40, 2, 8, 33, 12, 65, 1, 33, 13, 32, 12, 32, 13, 107, 33, 14, 32, 14, 16, 130, 128, 128, 128, 0, 33, 15, 32, 3, 40, 2, 8, 33, 16, 65, 2, 33, 17, 32, 16, 32, 17, 107, 33, 18, 32, 18, 16, 130, 128, 128, 128, 0, 33, 19, 32, 15, 32, 19, 106, 33, 20, 32, 3, 32, 20, 54, 2, 12, 11, 32, 3, 40, 2, 12, 33, 21, 65, 16, 33, 22, 32, 3, 32, 22, 106, 33, 23, 32, 23, 36, 128, 128, 128, 128, 0, 32, 21, 15, 11, 27, 1, 2, 127, 65, 20, 33, 0, 32, 0, 16, 130, 128, 128, 128, 0, 33, 1, 32, 1, 16, 129, 128, 128, 128, 0, 15, 11, 0, 42, 4, 110, 97, 109, 101, 1, 35, 4, 0, 7, 112, 117, 116, 99, 104, 97, 114, 1, 10, 112, 114, 105, 110, 116, 95, 117, 105, 110, 116, 2, 3, 102, 105, 98, 3, 6, 95, 115, 116, 97, 114, 116, 0, 38, 9, 112, 114, 111, 100, 117, 99, 101, 114, 115, 1, 12, 112, 114, 111, 99, 101, 115, 115, 101, 100, 45, 98, 121, 1, 5, 99, 108, 97, 110, 103, 6, 49, 48, 46, 48, 46, 48 }

local function mapArray(array, f)
   local out = {}
   for _, v in ipairs(array) do
      table.insert(out, f(v))
   end
   return out
end

local function stringArray(array)
   return mapArray(array, function(v) return tostring(v) end)
end

local function arrayEqual(lhs, rhs)
   if #lhs ~= #rhs then
      return false
   end

   for i = 1, #lhs do
      if lhs[i] ~= rhs[i] then
         return false
      end
   end

   return true
end

local function mod_pow2(x, power)
   return x & ((2 ^ power) - 1)
end

local Sum = {}




local BytesIterator = {}
local Parser = {}

local function iterator(bytes)
   local index = 0
   local len = #bytes

   return function()
      index = index + 1
      if index <= len then

         return bytes[index]
      end
   end
end

local function prepend(n, bytes)
   local yielded = false

   return function()
      if yielded then
         return bytes()
      else
         yielded = true
         return n
      end
   end
end

local function readU(bytes, N)
   local n = bytes();
   if n < 128 and n < 2 ^ N then
      return n
   else
      local m = readU(bytes, N - 7)
      return 128 * m + (n - 128)
   end
end


local function readS(bytes, N)
   local n = bytes()
   if n < 64 and n < 2 ^ (N - 1) then
      return n
   elseif 64 <= n and n < 128 and n > 128 - 2 ^ (N - 1) then
      return n - 128
   else
      local m = readS(bytes, N - 7)
      return 128 * m + (n - 128)
   end
end

local function readArray(bytes, amount)
   local array = {}
   for _ = 1, amount do
      table.insert(array, bytes())
   end
   return array
end

local function readVec(bytes, parser)
   local size = readU(bytes, 32)
   local vec = {}
   for _ = 1, size do
      table.insert(vec, parser(bytes))
   end
   return vec
end

local function readName(bytes)
   local byte_string = readVec(bytes, function(b) return b() end)
   return table.concat(mapArray(byte_string, function(n) return string.char(n) end))
end

local function readVecSection(bytes, parser)
   local _size = readU(bytes, 32)
   return readVec(bytes, parser)
end

local function advance(bytes, amount)
   for _ = 1, amount do
      bytes()
   end
end

local function discardSection(bytes)
   local size = readU(bytes, 32)
   advance(bytes, size)
end

local ValType = {}






function readValType(bytes)
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

local WasmValue = {}




local FuncType = {}




function FuncType:tostring()
   return "f(" .. table.concat(self.inputs, ",") .. ") -> (" .. table.concat(self.outputs, ",") .. ")"
end

function FuncType.parse(bytes)
   local ty = bytes()
   assert(ty == 0x60, "Unknown functype, expected 0x60, got " .. tostring(ty))

   local self = setmetatable({}, { __index = FuncType, __tostring = function(s) return s:tostring() end })
   self.inputs = readVec(bytes, readValType)
   self.outputs = readVec(bytes, readValType)

   return self
end

local Limit = {}




function Limit:tostring()
   return "{min: " .. self.min .. ", max: " .. (tostring(self.max) or "nil") .. "}"
end

function Limit.parse(bytes)
   local self = setmetatable({}, { __index = Limit, __tostring = function(s) return s:tostring() end })

   local kind = bytes()
   self.min = readU(bytes, 32)

   if kind == 0x01 then
      self.max = readU(bytes, 32)
   elseif kind ~= 0x00 then
      error("unknown limit kind: " .. tostring(kind))
   end

   return self
end

local Table = {}



function Table:tostring()
   return "funcref(limit: " .. tostring(self.limit) .. ")"
end

function Table.parse(bytes)
   local self = setmetatable({}, { __index = Table, __tostring = function(s) return s:tostring() end })

   local kind = bytes()
   assert(kind == 0x70, "table only allows funcref, got " .. kind)

   self.limit = Limit.parse(bytes)

   return self
end

local Mem = {}



function Mem:tostring()
   return "memlimit: " .. tostring(self.limit)
end

function Mem.parse(bytes)
   local self = setmetatable({}, { __index = Mem, __tostring = function(s) return s:tostring() end })

   self.limit = Limit.parse(bytes)

   return self
end

local Mut = {}




function readMut(bytes)
   local kind = bytes()
   if kind == 0x00 then
      return "const"
   elseif kind == 0x01 then
      return "var"
   else
      error("invalid mut kind")
   end
end

local GlobalType = {}




function GlobalType:tostring()
   return self.mut .. " " .. self.type
end

function GlobalType.parse(bytes)
   local self = setmetatable({}, { __index = GlobalType, __tostring = function(s) return s:tostring() end })

   self.type = readValType(bytes)
   self.mut = readMut(bytes)

   return self
end

local ImportDescription = {}






local Import = {}





function Import:tostring()
   return self.mod .. "." .. self.name .. " := " .. self.desc.tag .. "(" .. tostring(self.desc.value) .. ")"
end

function Import.parse(bytes)
   local self = setmetatable({}, { __index = Import, __tostring = function(s) return s:tostring() end })
   self.mod = readName(bytes)
   self.name = readName(bytes)

   local desc_type = bytes()
   if desc_type == 0x00 then
      self.desc = { tag = "funcref", value = readU(bytes, 32) }
   elseif desc_type == 0x01 then
      self.desc = { tag = "table", value = Table.parse(bytes) }
   elseif desc_type == 0x02 then
      self.desc = { tag = "memory", value = Mem.parse(bytes) }
   elseif desc_type == 0x03 then
      self.desc = { tag = "global", value = GlobalType.parse(bytes) }
   else
      error("invalid desc_type: " .. tostring(desc_type))
   end

   return self
end

local ExportDescription = {}






local Export = {}





function Export:tostring()
   return "export " .. self.name .. " := " .. self.desc .. ":" .. self.ref
end

function Export.parse(bytes)
   local self = setmetatable({}, { __index = Export, __tostring = function(s) return s:tostring() end })

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

local Locals = {}




function Locals:tostring()
   return "(" .. self.type .. ")^" .. self.n
end

function Locals.parse(bytes)
   local self = setmetatable({}, { __index = Locals, __tostring = function(s) return s:tostring() end })

   self.n = readU(bytes, 32)
   self.type = readValType(bytes)

   return self
end

function Locals:init()
   local locals = {}

   for _ = 1, self.n do
      table.insert(locals, { type = self.type, value = 0 })
   end

   return locals
end

local Stack = {}



function Stack.create()
   local self = setmetatable({}, { __index = Stack })

   self._et = {}

   return self
end

function Stack:push(...)
   if ... then
      local targs = { ... }
      for _, v in ipairs(targs) do
         table.insert(self._et, v)
      end
   end
end

function Stack:pop_many(amount)
   local entries = {}

   for _ = 1, amount do

      if #self._et ~= 0 then
         table.insert(entries, self._et[#self._et])

         table.remove(self._et)
      else
         break
      end
   end


   return _tl_table_unpack(entries)
end

function Stack:pop()
   local a = self:pop_many(1)
   return a
end

function Stack:top()
   return self._et[#self._et]
end

function Stack:empty()
   return #self._et == 0
end

local ActionKind = {}




local InstructionErasedAction = {}

local InstructionName = {}
































































local Instruction = {}





local Frame = {}







function Frame.create(locals, code, arity, func)
   local self = setmetatable({}, { __index = Frame })

   self.locals = locals
   self.code = code
   self.current = 1
   self.arity = arity
   self.funcId = func

   return self
end

local Code = {}




function Code:tostring()
   return table.concat(stringArray(self.locals), ";") .. " -> <...>"
end

function Code:locals_array()
   local array = {}

   for _, loc in ipairs(self.locals) do
      local init = loc:init()
      for _, val in ipairs(init) do
         table.insert(array, val)
      end
   end

   return array
end

local MEM_PAGE = 65536
local LinearMemory = {}





function LinearMemory.create(min, max)
   local self = setmetatable({}, { __index = LinearMemory })

   self.max = max
   self.bytes = {}
   self.size = min * MEM_PAGE

   return self
end

local GlobalValue = {}




local FunctionKind = {}




local VmState = {}












function VmState:print_stack()
   print("Stack:")
   local i = #self.stack._et
   while i > 0 do
      local top = self.stack._et[i]
      print("    " .. top.value .. ": " .. top.type)
      i = i - 1
   end
end

function VmState:trap(message)
   print("-----------------")
   print("Trap: " .. message)
   print("backtrace:")

   local first = self.frames:pop()
   print("   f[" .. first.funcId .. "] @ " .. first.current .. " := " .. first.code[first.current].name)

   while not self.frames:empty() do
      local top = self.frames:pop()
      if top.code == nil then
         print("   --- END ---")
      else
         print("   f[" .. top.funcId .. "] @ " .. top.current .. " := " .. top.code[top.current - 1].name)
      end
   end
   if self.stacktrace then
      self:print_stack()
   end
   self.trapped = true
   error("WASM_TRAP")
end

function LinearMemory:assert_index(ea, bandwith, vm)
   if ea + bandwith // 8 > self.size then
      vm:trap("Invalid memory access: ea=" .. ea .. ", bandwith=" .. bandwith)
   end
end

function LinearMemory:store_int(ea, bandwith, value, vm)
   if value.type == "f32" or value.type == "f64" then
      vm:trap("Tried to store an float as an int")
   end

   local val = value.value

   local idx = ea
   while bandwith > 0 do
      self.bytes[idx] = mod_pow2(val, 8)
      idx = idx + 1
      val = val >> 8
      bandwith = bandwith - 8
   end
end

function LinearMemory:load_int(ea, bandwith)
   local idx = ea
   local value = 0
   local i = 0
   while bandwith > 0 do
      value = value + self.bytes[idx] << i
      idx = idx + 1
      i = i + 8
      bandwith = bandwith - 8
   end

   return value
end

function GlobalValue:write(type, value, vm)
   if self.type.mut == "const" then
      vm:trap("Tried to write to a const value")
   end

   if self.type.type ~= type then
      vm:trap("Tried to write a value of a different type, got " .. type .. ", expected " .. self.type.type)
   end

   self.value = value
end

function GlobalValue:read()
   return { type = self.type.type, value = self.value }
end

local ResolveFT = {}
local CodeFetch = {}

function VmState.create(
   initial_frame,
   resolve_func_type,
   func_body,
   globals,
   signature_fetch,
   memory)

   local self = setmetatable({}, { __index = VmState })

   self.stack = Stack.create()
   self.frames = Stack.create()
   self.frames:push(initial_frame)
   self.resolve_func_type = resolve_func_type
   self.func_body = func_body
   self.trapped = false
   self.stacktrace = false
   self.globals = globals
   self.signature_fetch = signature_fetch
   self.memory = memory

   return self
end

function VmState:call(fn, args, arity)
   if self.resolve_func_type(fn) == "local" then
      local body = self.func_body(fn)
      local locals = body:locals_array()
      for _, l in ipairs(locals) do
         table.insert(args, l)
      end
      self.frames:push(Frame.create(args, body.expr, arity, fn))
   else
      error("imported functions are not available")
   end
end

function VmState:current_frame()
   return self.frames:top()
end

function VmState:step()
   local frame = self:current_frame()

   if frame.code == nil then
      return false
   end

   if frame.current > #frame.code then
      self:trap("Tried to execute code after the end")
   end

   local instr = frame.code[frame.current]

   print(instr.name)


   local action = instr.action(self)
   if action ~= nil then
      error("non nil action not supported")
   end
   frame.current = frame.current + 1

   return true
end

function VmState:run()
   while (true) do
      local status, value = pcall(function() self:step() end)

      if not status then

         error("The wasm VM trapped: " .. tostring(value))
      elseif value == false then
         break
      end

   end
end

function VmState:doCall(indirect, fn)
   if indirect then
      self:trap("Indirect call not implemented")
   end
   local signature = self.signature_fetch(fn)
   local arg_count = #signature.inputs
   local args = { self.stack:pop_many(arg_count) }
   self:call(fn, args, #signature.outputs)
end

function VmState:pop_type(type)
   local v = self.stack:pop()

   if v.type ~= type then
      self:trap("Expected on the stack type " .. type .. " got type " .. v.type)
   end

   return v.value
end

local InstructionAction = {}

local function castErased(vmaction)
   return function(erased)
      return vmaction(erased)
   end
end

local function unimpInstr(name)
   return castErased(function(v) v:trap("instruction is not implemented: " .. name) end)
end



function Instruction:tostring()
   return self.name
end

local MemArg = {}




function MemArg:tostring()
   return "{a: " .. self.align .. ", o: " .. self.offset .. "}"
end

function MemArg.parse(bytes)
   local self = setmetatable({}, { __index = MemArg, __tostring = function(s) return s:tostring() end })

   self.align = readU(bytes, 32)
   self.offset = readU(bytes, 32)

   return self
end

function resolve_ea(v, bandwith, memarg)
   local i_val = v.stack:pop()
   if i_val.type ~= "i32" then
      v:trap("Invalid index type in memory store: " .. i_val.type)
   end
   local i = i_val.value

   local ea = i + memarg.offset
   v.memory:assert_index(ea, bandwith)

   return ea
end

function loadInstrAction(signed, result, bandwith, memarg)
   return function(v)
      local ea = resolve_ea(v, bandwith, memarg)

      local value
      if result == "i32" or result == "i64" then
         if signed then
            v:trap("signed int load not implemented")
         else
            value = v.memory:load_int(ea, bandwith)
         end
      else
         v:trap("float load instr not implemented")
      end

      v.stack:push({ type = result, value = value })
   end
end

function storeInstrAction(type, bandwith, memarg)
   return function(v)
      local c = v.stack:pop()
      local ea = resolve_ea(v, bandwith, memarg)

      if type == "i32" or type == "i64" then
         v.memory:store_int(ea, bandwith, c)
      else
         v:trap("float store instr not implemented")
      end
   end
end

function Instruction:memInstr(bytes, opcode)
   if opcode >= 0x28 and opcode <= 0x35 then
      local ty
      if opcode == 0x28 or opcode == 0x2C or opcode == 0x2D or opcode == 0x2E or opcode == 0x2F then
         ty = "i32"
      elseif opcode == 0x29 or opcode == 0x30 or opcode == 0x31 or opcode == 0x32 or opcode == 0x33 or opcode == 0x34 or opcode == 0x35 then
         ty = "i64"
      elseif opcode == 0x2A then
         ty = "f32"
      elseif opcode == 0x2b then
         ty = "f64"
      end

      local signed
      if opcode == 0x2C or opcode == 0x2E or opcode == 0x30 or opcode == 0x32 or opcode == 0x34 then
         signed = true
      elseif opcode == 0x2D or opcode == 0x2F or opcode == 0x31 or opcode == 0x33 or opcode == 0x35 then
         signed = false
      end

      local bandwith
      if opcode == 0x2C or opcode == 0x2D or opcode == 0x30 or opcode == 0x31 then
         bandwith = 8
      elseif opcode == 0x2E or opcode == 0x2F or opcode == 0x32 or opcode == 0x33 then
         bandwith = 16
      elseif opcode == 0x34 or opcode == 0x35 or opcode == 0x28 then
         bandwith = 32
      elseif opcode == 0x29 then
         bandwith = 64
      end

      self.name = "load"
      self.action = castErased(loadInstrAction(signed, ty, bandwith, MemArg.parse(bytes)))
   elseif opcode >= 0x36 and opcode <= 0x3E then
      local ty
      if opcode == 0x36 or opcode == 0x3A or opcode == 0x3B then
         ty = "i32"
      elseif opcode == 0x37 or opcode == 0x3C or opcode == 0x3D or opcode == 0x3E then
         ty = "i64"
      elseif opcode == 0x38 then
         ty = "f32"
      elseif opcode == 0x39 then
         ty = "f64"
      end

      local bandwith = nil
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
      self.action = castErased(storeInstrAction(ty, bandwith, MemArg.parse(bytes)))
   elseif opcode == 0x3F then
      assert(bytes() == 0x00, "memory.size requires a following 0 byte")
      self.name = "memory.size"
      self.action = unimpInstr("size not implemented")
   elseif opcode == 0x3E then
      assert(bytes() == 0x00, "memory.grow requires a following 0 byte")
      self.name = "memory.grow"
      self.action = unimpInstr("grow not implemented")
   end
end

function Instruction:varInstr(bytes, opcode)
   local VarAction = {}





   local function varInstruction(global, action, index, v)
      if global then
         local global_value = v.globals[index + 1]
         if action == "get" then
            local val = global_value:read()
            v.stack:push(val)
         else
            local val = v.stack:pop()

            global_value:write(val.type, val.value, v)
         end
      else
         local local_value = v:current_frame().locals[index + 1]
         if action == "get" then
            v.stack:push({ type = local_value.type, value = local_value.value })
         elseif action == "set" then
            local val = v.stack:pop()

            if val.type ~= local_value.type then
               v:trap("Invalid local.set write, expected type " .. local_value.type .. " got " .. val.type)
            end

            local_value.value = val.value
         else
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
      self.action = castErased(function(v) varInstruction(false, "get", index, v) end)
   elseif opcode == 0x21 then
      self.name = "local.set"
      self.action = castErased(function(v) varInstruction(false, "set", index, v) end)
   elseif opcode == 0x22 then
      self.name = "local.tee"
      self.action = castErased(function(v) varInstruction(false, "tee", index, v) end)
   elseif opcode == 0x23 then
      self.name = "global.get"
      self.action = castErased(function(v) varInstruction(true, "get", index, v) end)
   elseif opcode == 0x24 then
      self.name = "global.get"
      self.action = castErased(function(v) varInstruction(true, "set", index, v) end)
   else
      error("Invalid var instr: " .. opcode)
   end
end

local function actionInstr(action)
   return castErased(function(_) return action end)
end

local function constInstr(value, type)
   return castErased(function(v)
      v.stack:push({ type = type, value = value })
   end)
end

local BinopAction = {}

function binop(type, action)
   return castErased(function(v)
      local b = v:pop_type(type)
      local a = v:pop_type(type)
      local result = action(a, b, v)
      v.stack:push({ type = type, value = result })
   end)
end

local UnopAction = {}

function unop(_type, _action)
   return castErased(function(v) v:trap("unop not implemented") end)
end

local NumericImpls = {
   eq = function(a, b, _)
      if a == b then
         return 1
      else
         return 0
      end
   end,
   eqz = function(a, _)
      if a == 0 then
         return 1
      else
         return 0
      end
   end,
   ne = function(a, b, _)
      if a ~= b then
         return 1
      else
         return 0
      end
   end,
   lt = function(a, b, _)
      if a < b then
         return 1
      else
         return 0
      end
   end,
   gt = function(a, b, _)
      if a > b then
         return 1
      else
         return 0
      end
   end,
   le = function(a, b, _)
      if a <= b then
         return 1
      else
         return 0
      end
   end,
   ge = function(a, b, _)
      if a <= b then
         return 1
      else
         return 0
      end
   end,
   clz = function(_a, v)
      v:trap("clz not implemented")
   end,
   ctz = function(_a, v)
      v:trap("ctz not implemented")
   end,
   popcnt = function(_a, v)
      v:trap("popcnt not implemented")
   end,
   add = function(a, b, _)
      return a + b
   end,
   sub = function(a, b, _)
      return a - b
   end,
   mul = function(a, b, _)
      return a * b
   end,
   div = function(a, b, _)
      return a / b
   end,
   rem = function(a, b, _)
      return a % b
   end,
   i_and = function(a, b, _)
      return a & b
   end,
   i_or = function(a, b, _)
      return a | b
   end,
   xor = function(a, b, _)
      return a ~ b
   end,
   shl = function(a, b, _)
      return a << b
   end,
   shr = function(a, b, _)
      return a >> b
   end,
   rotl = function(_a, _b, v)
      v:trap("rotl not implemented")
   end,
   rotr = function(_a, _b, v)
      v:trap("rotr not implemented")
   end,
}

function signNumber(number, bandwith)
   if number < 2 ^ (bandwith - 1) then
      return number
   else
      return number - 2 ^ bandwith
   end
end

function wrapBinOp(op, bandwith)
   return function(a, b, v)
      local result = op(a, b, v)
      if result < 0 then
         result = result + 2 ^ bandwith
      end
      return result
   end
end

function signBinOp(signed, bandwith, op)
   return wrapBinOp(
   function(a, b, v)
      if signed then
         a = signNumber(a, bandwith)
         b = signNumber(b, bandwith)
      end

      return op(a, b, v)
   end,
   bandwith)
end

function Instruction:numericInstr(opcode)
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

local Block = {}






local blockParse

function Instruction:blockInstr(_block)
   self.name = "block"
   self.action = function(v) v:trap("block not implemented") end
end

function Instruction.parse(bytes)
   local self = setmetatable({}, { __index = Instruction, __tostring = function(s) return s:tostring() end })

   local opcode = bytes()
   if opcode == 0x05 then
      self.name = "else_start"
   elseif opcode == 0x0B then
      self.name = "block_end"
   elseif opcode == 0x00 then
      self.name = "unreachable"
      self.action = castErased(function(s) s:trap("unreachable reached") end)
   elseif opcode == 0x01 then
      self.name = "nop"
      self.action = function(_) end
   elseif opcode >= 0x02 and opcode <= 0x04 then
      local block = blockParse(bytes, opcode)
      self:blockInstr(block)
   elseif opcode == 0x0C then
      local label = readU(bytes, 32)
      self.name = "branch"
      self.action = function(_)
         return { tag = "branch", value = label }
      end
   elseif opcode == 0x0d then
      local _label = readU(bytes, 32)
      self.name = "branch_if"
      self.action = unimpInstr("branch_if")
   elseif opcode == 0x0e then
      local _labels = readVec(bytes, function(b) return readU(b, 32) end)
      local _l = readU(bytes, 32)
      self.name = "branch_table"
      self.action = unimpInstr("branch_table")
   elseif opcode == 0x0F then
      self.name = "return"
      self.action = actionInstr({ tag = "return", value = nil })
   elseif opcode == 0x10 then
      local func_id = readU(bytes, 32)
      self.name = "call"
      self.action = function(v) v:doCall(false, func_id) end
   elseif opcode == 0x11 then
      local func_id = readU(bytes, 32)
      assert(bytes() == 0x00, "no 0 byte after call indirect")
      self.name = "call_indirect"
      self.action = function(v) v:doCall(true, func_id) end
   elseif opcode == 0x1a then
      self.name = "drop"
      self.action = unimpInstr("drop")
   elseif opcode == 0x1B then
      self.name = "select"
      self.action = unimpInstr("select")
   elseif opcode >= 0x20 and opcode <= 0x24 then
      self:varInstr(bytes, opcode)
   elseif opcode >= 0x28 and opcode <= 0x40 then
      self:memInstr(bytes, opcode)
   elseif opcode == 0x41 then
      self.name = "const"
      local val = readS(bytes, 32)
      self.action = constInstr(val, "i32")
   elseif opcode == 0x42 then
      self.name = "const"
      local val = readS(bytes, 64)
      self.action = constInstr(val, "i64")
   elseif opcode == 0x43 or opcode == 0x44 then
      error("float litteral not implemented")
   elseif opcode >= 0x45 and opcode <= 0x8a then
      self:numericInstr(opcode)
   else
      error("instruction not implemented: " .. opcode)
   end

   return self
end

local BlockType = {}





local BlockKind = {}






function Block:tostring()
   return "TODO"
end

blockParse = function(bytes, opcode)
   local self = setmetatable({}, { __index = Block, __tostring = function(s) return s:tostring() end })

   if opcode == nil then
      self.kind = "bare"
      self.blocktype = nil
   else
      local start = bytes()
      if start == 0x40 then
         self.blocktype = { tag = "epsilon", value = nil }
      elseif start == 0x7F then
         self.blocktype = { tag = "valtype", value = "i32" }
      elseif start == 0x7e then
         self.blocktype = { tag = "valtype", value = "i64" }
      elseif start == 0x7d then
         self.blocktype = { tag = "valtype", value = "f32" }
      elseif start == 0x7c then
         self.blocktype = { tag = "valtype", value = "f64" }
      else
         self.blocktype = { tag = "indexed", value = readS(prepend(start, bytes), 33) }
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
   while (true) do
      local i = Instruction.parse(bytes)
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
      while (true) do
         local i = Instruction.parse(bytes)
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

function Code.parse(bytes)
   local self = setmetatable({}, { __index = Code, __tostring = function(s) return s:tostring() end })

   local _size = readU(bytes, 32)
   self.locals = readVec(bytes, function(b) return Locals.parse(b) end)
   self.expr = blockParse(bytes, nil).main

   return self
end

local Global = {}




function Global:tostring()
   return tostring(self.type) .. " := " .. table.concat(mapArray(self.init, function(instr) return instr.name end), ";")
end

function Global.parse(bytes)
   local self = setmetatable({}, { __index = Global, __tostring = function(s) return s:tostring() end })

   self.type = GlobalType.parse(bytes)
   self.init = blockParse(bytes, nil).main

   return self
end

local Program = {}













function Program:createMemory()
   if #self.memory ~= 1 then
      error("Only programs with exactly one memory are supported")
   end

   local limit = self.memory[1].limit
   return LinearMemory.create(limit.min, limit.max)
end

function Program:resolve(fn)
   if fn > self.max_import then
      return "local"
   else
      return "import"
   end
end

function Program:signature(fn)
   local type_idx
   if self:resolve(fn) == "local" then
      type_idx = self.functions[fn - self.max_import]
   else
      type_idx = self.func_import[fn]
   end

   return self.type[type_idx + 1]
end

function Program:func_body(fn)
   local index = fn - self.max_import
   return self.code[index]
end

function Program:is_init_fn(fn)
   local sig_id = self.functions[fn] + 1
   local sig = self.type[sig_id]
   return #sig.inputs == 0 and #sig.outputs == 0
end

function Program.parse(bytes)
   local self = setmetatable({}, { __index = Program })

   local magic = readArray(bytes, 4)
   assert(arrayEqual(magic, { 0x00, 0x61, 0x73, 0x6d }), "magic number is not valid, got {" .. table.concat(stringArray(magic), ",") .. "}")

   local version = readArray(bytes, 4)
   assert(arrayEqual(version, { 0x01, 0x00, 0x00, 0x00 }), "only version 1 is supported, got {" .. table.concat(stringArray(version), ",") .. "}")

   while (true) do
      local section_id = bytes()
      if section_id == nil then
         break
      end

      if section_id == 0 then
         discardSection(bytes)
      elseif section_id == 1 then
         local parser = function(bytes)
            return FuncType.parse(bytes)
         end
         self.type = readVecSection(bytes, parser)
      elseif section_id == 2 then
         local parser = function(bytes)
            return Import.parse(bytes)
         end
         self.import = readVecSection(bytes, parser)
      elseif section_id == 3 then
         self.functions = readVecSection(bytes, function(bytes) return readU(bytes, 32) end)
      elseif section_id == 4 then
         self.table = readVecSection(bytes, function(bytes) return Table.parse(bytes) end)
      elseif section_id == 5 then
         self.memory = readVecSection(bytes, function(bytes) return Mem.parse(bytes) end)
      elseif section_id == 6 then
         self.global = readVecSection(bytes, function(bytes) return Global.parse(bytes) end)
      elseif section_id == 7 then
         self.export = readVecSection(bytes, function(bytes) return Export.parse(bytes) end)
      elseif section_id == 8 then
         print("Todo: start")
         discardSection(bytes)
      elseif section_id == 9 then
         print("Todo: element")
         discardSection(bytes)
      elseif section_id == 10 then
         self.code = readVecSection(bytes, function(bytes) return Code.parse(bytes) end)
      elseif section_id == 11 then
         print("Todo: data")
         discardSection(bytes)
      else
         error("section id " .. tostring(section_id) .. " is invalid")
      end
   end

   self.max_import = -1
   self.func_import = {}

   for i, v in ipairs(self.import) do
      if v.desc.tag == "funcref" then
         self.max_import = self.max_import + 1
         self.func_import[i] = v.desc.value
      end
   end

   return self
end

function Program:print()
   print("Types:")
   for _, v in ipairs(self.type) do
      print("    " .. tostring(v))
   end
   print("Import:")
   for _, v in ipairs(self.import) do
      print("    " .. tostring(v))
   end
   print("Functions:")
   for i, v in ipairs(self.functions) do
      print("    f[" .. i .. "] := " .. v)
   end
   print("Tables:")
   for _, v in ipairs(self.table) do
      print("    " .. tostring(v))
   end
   print("Mem:")
   for _, v in ipairs(self.memory) do
      print("    " .. tostring(v))
   end
   print("Export:")
   for _, v in ipairs(self.export) do
      print("    " .. tostring(v))
   end
   print("Global:")
   for _, v in ipairs(self.global) do
      print("    " .. tostring(v))
   end
   print("Code:")
   for _, v in ipairs(self.code) do
      print("    " .. tostring(v))
   end
end


function GlobalValue.load(g)
   local self = setmetatable({}, { __index = GlobalValue })

   self.type = g.type
   if #g.init ~= 1 then
      error("Init must be exactly 1 instruction")
   end

   local vm = VmState.create(
   Frame.create(nil, g.init, 0, -1),
   function(_) error("can't call functions in global init") end,
   function(_) error("can't call functions in global init") end,
   nil,
   nil)

   vm:step()
   local value = vm.stack:pop()
   if value.type ~= self.type.type then
      error("Intializer is invalid: expected " .. self.type.type .. ", got: " .. value.type)
   end
   self.value = value.value

   return self
end

local WasmInstance = {}





function WasmInstance.load(p)
   local self = setmetatable({}, { __index = WasmInstance })

   self.program = p
   self.globals = mapArray(p.global, function(g)
      return GlobalValue.load(g)
   end)
   self.memory = p:createMemory()

   return self
end

function WasmInstance:executeInit(fn)
   if not self.program:is_init_fn(fn) then
      error("An init function is of signature () -> ()")
   end

   local vm = VmState.create(
   Frame.create(nil, nil, 0, -1),
   function(fn) return self.program:resolve(fn) end,
   function(fn) return self.program:func_body(fn) end,
   self.globals,
   function(fn) return self.program:signature(fn) end,
   self.memory)

   vm:call(fn, {}, 0)
   vm.stacktrace = true
   vm:run()
end

local function main()
   local bytes = iterator(input)
   local program = Program.parse(bytes)
   program:print()
   local instance = WasmInstance.load(program)
   instance:executeInit(3)
end

main()
