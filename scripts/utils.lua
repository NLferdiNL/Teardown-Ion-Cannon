function tableToText(inputTable, loopThroughTables, useIPairs, addIndex, addNewLine)
	loopThroughTables = loopThroughTables or true
	useIPairs = useIPairs or false
	addIndex = addIndex or true
	addNewLine = addNewLine or false
	
	local returnString = "{ "
	
	if useIPairs then
		for key, value in ipairs(inputTable) do
			if type(value) == "string" or type(value) == "number" then
				returnString = returnString .. (not addIndex and key .. " = " or " ") .. value .. (addNewLine and ",\n" or ", ")
			elseif type(value) == "table" and loopThroughTables then
				returnString = returnString .. (not addIndex and key .. " = " or " ") .. tableToText(value, loopThroughTables, useIPairs, addIndex, addNewLine) .. (addNewLine and ",\n" or ", ")
			else
				returnString = returnString .. (not addIndex and key .. " = " or " ") .. tostring(value) .. (addNewLine and ",\n" or ", ")
			end
		end
	else
		for key, value in pairs(inputTable) do
			if type(value) == "string" or type(value) == "number" then
				returnString = returnString .. (not addIndex and key .. " = " or " ") .. value .. (addNewLine and ",\n" or ", ")
			elseif type(value) == "table" and loopThroughTables then
				returnString = returnString .. (not addIndex and key .. " = " or "") .. tableToText(value, loopThroughTables, useIPairs, addIndex, addNewLine) .. (addNewLine and ",\n" or ", ")
			else
				returnString = returnString .. (not addIndex and key .. " = " or " ") .. tostring(value) .. (addNewLine and ",\n" or ", ")
			end
		end
	end
	returnString = returnString .. "}"
	
	return returnString
end

function roundToTwoDecimals(a) -- To support older mods incase I update the utils.lua
	--return math.floor(a * 100)/100
	return roundToDecimal(a, 2)
end

function posAroundCircle(i, points, originPos, radius)
	local x = originPos[1] + radius * math.cos(2 * i * math.pi / points)
	local z = originPos[3] - radius * math.sin(2 * i * math.pi / points)
	
	return {x, originPos[2], z}
end

function rndVec(length)
	local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
	return VecScale(v, length)	
end

function Lerp(a, b, t)
    return a + (b - a) * t
end

function VecDir(a, b)
	return VecNormalize(VecSub(b, a))
end

function roundToDecimal(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function VecRound(vec, numDecimalPlaces)
	return Vec(round(vec[1], numDecimalPlaces), round(vec[2], numDecimalPlaces), round(vec[3], numDecimalPlaces))
end

function round(num)
  return num + (2^52 + 2^51) - (2^52 + 2^51)
end

function VecAngle(a, b)
	local magA = VecMag(a)
	local magB = VecMag(b)
	
	local dotP = VecDot(a, b)
	
	local angle = math.deg(math.acos(dotP / (magA * magB)))
	
	return angle
end

function VecDist(a, b)
	local directionVector = VecSub(b, a)
	
	local distance = VecMag(directionVector)
	
	return distance
end

function VecMag(a)
	return math.sqrt(a[1]^2 + a[2]^2 + a[3]^2)
end

function VecToString(vec)
	return vec[1] .. ", " .. vec[2] .. ", " .. vec[3]
end

function VecInvert(vec)
	return Vec(-vec[1], -vec[2], -vec[3])
end

function raycast(origin, direction, maxDistance, radius, rejectTransparant)
	maxDistance = maxDistance or 500 -- Make this arguement optional, it is usually not required to raycast further than this.
	local hit, distance, normal, shape = QueryRaycast(origin, direction, maxDistance, radius, rejectTransparant)
	
	if hit then
		local hitPoint = VecAdd(origin, VecScale(direction, distance))
		return hit, hitPoint, distance, normal, shape
	end
	
	return false, nil, nil, nil, nil
end

function getMaxTextSize(text, fontSize, maxSize, minFontSize)
	minFontSize = minFontSize or 1
	UiPush()
		UiFont("regular.ttf", fontSize)
		
		local currentSize = UiGetTextSize(text)
		
		while currentSize > maxSize and fontSize > minFontSize do
			fontSize = fontSize - 0.1
			UiFont("regular.ttf", fontSize)
			currentSize = UiGetTextSize(text)
		end
	UiPop()
	return fontSize, fontSize > minFontSize
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end
