local WasmValue = require("wasm.types").WasmValue

local record Stack
	_et: {WasmValue}
end

function Stack.create(): Stack
	local self = setmetatable({} as Stack, { __index = Stack})
	
	self._et = {}
	
	return self
end

function Stack:push(...: WasmValue) 
	if ... then
		local targs = {...}
		for _,v in ipairs(targs) do
			table.insert(self._et, v)
		end
	end
end

function Stack:pop_many(amount: number): WasmValue...
	local entries = {}

	for _ = 1, amount do
      -- get last entry
      if #self._et ~= 0 then
        table.insert(entries, self._et[#self._et])
        -- remove last value
        table.remove(self._et)
      else
        break
      end
    end

    -- return unpacked entries
    return table.unpack(entries)
end

function Stack:pop(): WasmValue
	local a = self:pop_many(1)
	return a
end

function Stack:top(): WasmValue
	return self._et[#self._et]
end

function Stack:empty(): boolean
	return #self._et == 0
end

return Stack
