local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local pairs = _tl_compat and _tl_compat.pairs or pairs; local utils = require("wasm.utils")

local parser = require("wasm.parser")
local types = require("wasm.types")
local runtime = require("wasm.runtime")

local WasmInstance = {}






function WasmInstance.load(p, function_imports)
   local self = setmetatable({}, { __index = WasmInstance })

   self.program = p
   self.globals = utils.mapArray(p.global, function(g)
      return runtime.GlobalValue.load(g)
   end)
   self.memory = p:createMemory()
   for _, v in ipairs(p.data) do
      local vm = runtime.VmState.constant(v.init, self.memory, self.globals)
      vm:run()

      local offset = vm.stack:pop()
      if offset.type ~= "i32" then
         error("Invalid offset in data: expected i32, got " .. offset.type)
      end
      local offset_value = offset.value - 1
      for i, v in ipairs(v.data) do
         self.memory.bytes[offset_value + i] = v
      end
   end

   self.imports = {}
   for i, import_name in pairs(p:imported_functions()) do
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

function WasmInstance:executeInit(fn)
   if not self.program:is_init_fn(fn) then
      error("An init function is of signature () -> ()")
   end

   local vm = runtime.VmState.create(
   runtime.Frame.create(nil, nil, 0, -1),
   function(fn) return self.program:resolve(fn) end,
   function(fn) return self.program:func_body(fn) end,
   self.globals,
   function(fn) return self.program:signature(fn) end,
   self.memory,
   self.imports)

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
