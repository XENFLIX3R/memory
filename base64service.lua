local module = {}

local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local padding = "="

local charToIndex = {}
for i = 1, #chars do
	charToIndex[chars:sub(i,i)] = i-1
end

function module.encode(data)
	local result = {}
	local i = 1
	while i <= #data do
		local a = data:byte(i) or 0
		local b = data:byte(i+1) or 0
		local c = data:byte(i+2) or 0
		local n = a*65536 + b*256 + c
		result[#result+1] = chars:sub(math.floor(n/262144)%64+1, math.floor(n/262144)%64+1)
		result[#result+1] = chars:sub(math.floor(n/4096)%64+1, math.floor(n/4096)%64+1)
		result[#result+1] = chars:sub(math.floor(n/64)%64+1, math.floor(n/64)%64+1)
		result[#result+1] = chars:sub(n%64+1, n%64+1)
		i = i + 3
	end
	local rem = #data % 3
	if rem == 1 then
		result[#result] = padding
		result[#result-1] = padding
	elseif rem == 2 then
		result[#result] = padding
	end
	return table.concat(result)
end

function module.decode(data)
	local result = {}
	local i = 1
	while i <= #data do
		local a = charToIndex[data:sub(i,i)] or 0
		local b = charToIndex[data:sub(i+1,i+1)] or 0
		local c = charToIndex[data:sub(i+2,i+2)] or 0
		local d = charToIndex[data:sub(i+3,i+3)] or 0
		local n = a*262144 + b*4096 + c*64 + d
		result[#result+1] = string.char(math.floor(n/65536)%256)
		result[#result+1] = string.char(math.floor(n/256)%256)
		result[#result+1] = string.char(n%256)
		i = i + 4
	end
	local pad = 0
	if data:sub(-1) == padding then pad = pad + 1 end
	if data:sub(-2,-2) == padding then pad = pad + 1 end
	if pad > 0 then
		return table.concat(result, ""):sub(1, -(pad+1))
	end
	return table.concat(result)
end

return module
