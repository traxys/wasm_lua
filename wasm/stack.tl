local type Stack = record<T>
	_et: {T}
end

function Stack.create<T>(): Stack<T>
	local self = setmetatable({} as Stack<T>, { __index = Stack})
	
	self._et = {}
	
	return self
end

function Stack:push<T>(...: T) 
	if ... then
		local targs = {...}
		for _,v in ipairs(targs) do
			table.insert(self._et, v)
		end
	end
end

function Stack:pop_many<T>(amount: number): T...
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

function Stack:pop<T>(): T
	local a = self:pop_many(1)
	return a
end

function Stack:top<T>(): T
	return self._et[#self._et]
end

function Stack:empty<T>(): boolean
	return #self._et == 0
end

return Stack
