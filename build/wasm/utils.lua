local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local table = _tl_compat and _tl_compat.table or table; local function mapArray(array, f)
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

function signNumber(number, bandwith)
   if number < 2 ^ (bandwith - 1) then
      return number
   else
      return number - 2 ^ bandwith
   end
end

return {
   mapArray = mapArray,
   stringArray = stringArray,
   arrayEqual = arrayEqual,
   mod_pow2 = mod_pow2,
   Sum = Sum,
   BytesIterator = BytesIterator,
   iterator = iterator,
   prepend = prepend,
   signNumber = signNumber,
}
