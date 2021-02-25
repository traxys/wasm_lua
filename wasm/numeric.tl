local VmState = require("wasm.runtime").VmState

return {
	eq = function(a: number, b: number, _: VmState): number 
		if a == b then
			return 1
		else 
			return 0
		end
	end,
	eqz = function(a: number, _: VmState): number 
		if a == 0 then
			return 1
		else 
			return 0
		end
	end,
	ne = function(a: number, b: number, _: VmState): number 
		if a ~= b then
			return 1
		else 
			return 0
		end
	end,
	lt = function(a: number, b: number, _: VmState): number
		if a < b then
			return 1
		else 
			return 0
		end
	end,
	gt = function(a: number, b: number, _: VmState): number
		if a > b then
			return 1
		else 
			return 0
		end
	end,
	le = function(a: number, b: number, _: VmState): number
		if a <= b then
			return 1
		else 
			return 0
		end
	end,
	ge = function(a: number, b: number, _: VmState): number
		if a <= b then
			return 1
		else 
			return 0
		end
	end,
	clz = function(_a: number, v: VmState): number
		v:trap("clz not implemented")
	end,
	ctz = function(_a: number, v: VmState): number
		v:trap("ctz not implemented")
	end,
	popcnt = function(_a: number, v: VmState): number
		v:trap("popcnt not implemented")
	end,
	add = function(a: number, b: number, _: VmState): number
		return a + b
	end,
	sub = function(a: number, b: number, _: VmState): number
		return a - b
	end,
	mul = function(a: number, b: number, _: VmState): number
		return a * b
	end,
	div = function(a: number, b: number, _: VmState): number
		return a / b
	end,
	rem = function(a: number, b: number, _: VmState): number
		return a % b
	end,
	i_and = function(a: number, b: number, _: VmState): number
		return a & b
	end,
	i_or = function(a: number, b: number, _: VmState): number
		return a | b
	end,
	xor = function(a: number, b: number, _: VmState): number
		return a ~ b
	end,
	shl = function(a: number, b: number, _: VmState): number
		return a << b
	end,
	shr = function(a: number, b: number, _: VmState): number
		return a >> b
	end,
	rotl = function(_a: number, _b: number, v: VmState): number
		v:trap("rotl not implemented")
	end,
	rotr = function(_a: number, _b: number, v: VmState): number
		v:trap("rotr not implemented")
	end
}
