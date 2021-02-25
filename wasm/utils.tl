local function mapArray<T, U>(array: {T}, f: function(T): U): {U}
	local out = {}
	for _,v in ipairs(array) do
		table.insert(out, f(v))
	end
	return out
end

local function stringArray<T>(array: {T}): {string}
	return mapArray(array, function(v: T): string return tostring(v) end)
end

local function arrayEqual<T>(lhs: {T}, rhs: {T}): boolean
	if #lhs ~= #rhs then
		return false
	end

	for i=1,#lhs do
		if lhs[i] ~= rhs[i] then
			return false
		end
	end

	return true
end

local function mod_pow2(x: number, power: number): number
	return x & ((2^power) - 1)
end

local record Sum<T>
	tag: T
	value: any
end

local type BytesIterator = function(): number

local function iterator(bytes: {number}): BytesIterator
	local index = 0
	local len = #bytes

	return function(): number
		index = index + 1
		if index <= len then
			--print(index, bytes[index])
			return bytes[index]
		end
	end
end

local function prepend(n: number, bytes: BytesIterator): BytesIterator
	local yielded = false
	
	return function(): number
		if yielded then
			return bytes()
		else
			yielded = true
			return n
		end
	end
end

function signNumber(number: number, bandwith: number): number
	if number < 2^(bandwith-1) then
		return number
	else 
		return number - 2^bandwith
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
