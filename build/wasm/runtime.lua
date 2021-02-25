local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local pcall = _tl_compat and _tl_compat.pcall or pcall; local table = _tl_compat and _tl_compat.table or table; local types = require("wasm.types")
local utils = require("wasm.utils")
local Stack = require("wasm.stack")
local WasmValue = types.WasmValue
local WasmValueStack = require("wasm.wasm_value_stack")

function locals_init(self)
   local locals = {}

   for _ = 1, self.n do
      table.insert(locals, { type = self.type, value = 0 })
   end

   return locals
end

function locals_array(self)
   local array = {}

   for _, loc in ipairs(self.locals) do
      local init = locals_init(loc)
      for _, val in ipairs(init) do
         table.insert(array, val)
      end
   end

   return array
end

local Label = {}






local Frame = {}






function Frame.create(locals, code, arity, func)
   local self = setmetatable({}, { __index = Frame })

   self.locals = locals
   self.arity = arity
   self.funcId = func
   self.labels = Stack.create()
   self.labels:push({ code = code, current = 1, kind = "bare", arity = arity })

   return self
end

function Frame:current_label()
   return self.labels:top()
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




local VmState = {}














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
      self.bytes[idx] = utils.mod_pow2(val, 8)
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
   print("   f[" .. first.funcId .. "]")
   local first_label = first.labels:pop()
   print("      lbl[" .. first_label.kind .. "] @ " .. first_label.current .. " := " .. first_label.code[first_label.current].name)

   while not first.labels:empty() do
      local label = first.labels:pop()
      print("      lbl[" .. label.kind .. "] @ " .. label.current - 1 .. " := " .. label.code[label.current - 1].name)
   end

   while not self.frames:empty() do
      local top = self.frames:pop()
      if top.funcId == -1 then
         print("   --- END ---")
      else
         print("   f[" .. top.funcId .. "]")
         while not top.labels:empty() do
            local label = top.labels:pop()
            print("      lbl[" .. label.kind .. "] @ " .. label.current - 1 .. " := " .. label.code[label.current - 1].name)
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
   initial_frame,
   resolve_func_type,
   func_body,
   globals,
   signature_fetch,
   memory)

   local self = setmetatable({}, { __index = VmState })

   self.stack = WasmValueStack.create()
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

function VmState:current_frame()
   return self.frames:top()
end

function VmState:call(fn, args, arity)
   if self.resolve_func_type(fn) == "local" then
      local body = self.func_body(fn)
      local locals = locals_array(body)
      for _, l in ipairs(locals) do
         table.insert(args, l)
      end
      self.frames:push(Frame.create(args, body.expr, arity, fn))
   else
      error("imported functions are not available")
   end
end

function VmState:block(block)
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
      current_frame.labels:push({ code = block.main, current = 1, kind = block.kind, arity = arity })
   elseif block.kind == "if" then
      self:trap("VmState:if not implemented")
   elseif block.kind == "loop" then
      self:trap("VmState:loop not implemented")
   end
end

function VmState:branch(label)
   local current_frame = self:current_frame()
   local lbl
   for _ = 0, label do
      lbl = current_frame.labels:pop()
   end

   if lbl.kind == "loop" then
      self:trap("looping label not implemented")
   end
end

function VmState:step()
   local frame = self:current_frame()





   local label = frame:current_label()

   if label.current > #label.code then
      self:trap("Tried to execute code after the end")
   end

   local instr = label.code[label.current]

   print(instr.name)


   instr.action(self)
   label.current = label.current + 1

   return true
end

function VmState:run()
   while (true) do
      local status, value = pcall(function() self:step() end)

      if not status then

         error("WASM error: " .. tostring(value))
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
      vmaction(erased)
   end
end

local function unimpInstr(name)
   return castErased(function(v) v:trap("instruction is not implemented: " .. name) end)
end

function resolve_ea(v, memarg)
   local i_val = v.stack:pop()
   if i_val.type ~= "i32" then
      v:trap("Invalid index type in memory store: " .. i_val.type)
   end
   local i = i_val.value

   local ea = i + memarg.offset

   return ea
end

function loadInstrAction(signed, result, bandwith, memarg)
   return function(v)
      local ea = resolve_ea(v, memarg)
      v.memory:assert_index(ea, bandwith, v)

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
      local ea = resolve_ea(v, memarg)

      if type == "i32" or type == "i64" then
         v.memory:store_int(ea, bandwith, c)
      else
         v:trap("float store instr not implemented")
      end
   end
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
         a = utils.signNumber(a, bandwith)
         b = utils.signNumber(b, bandwith)
      end

      return op(a, b, v)
   end,
   bandwith)
end


local UnopAction = {}

function unop(type, action)
   return castErased(function(v)
      local a = v:pop_type(type)
      local result = action(a, v)
      v.stack:push({ type = type, value = result })
   end)
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
