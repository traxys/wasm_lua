local utils = require("wasm.utils")

local parser = require("wasm.parser")
local types = require("wasm.types")
local runtime = require("wasm.runtime")

local WasmInstance = {}





function WasmInstance.load(p)
   local self = setmetatable({}, { __index = WasmInstance })

   self.program = p
   self.globals = utils.mapArray(p.global, function(g)
      return runtime.GlobalValue.load(g)
   end)
   self.memory = p:createMemory()

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
   self.memory)

   vm:call(fn, {}, 0)
   vm.stacktrace = true
   vm:run()
end

return {
   iterator = utils.iterator,
   Program = parser.Program,
   WasmInstance = WasmInstance,
}
