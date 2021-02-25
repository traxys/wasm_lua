local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local table = _tl_compat and _tl_compat.table or table; local _tl_table_unpack = unpack or table.unpack; local Stack = {}



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

return Stack
