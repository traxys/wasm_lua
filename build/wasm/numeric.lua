local VmState = require("wasm.runtime").VmState

return {
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
