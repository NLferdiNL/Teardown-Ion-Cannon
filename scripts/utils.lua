function tableToText(inputTable, loopThroughTables)
	loopThroughTables = loopThroughTables or true

	local returnString = "{ "
	for key, value in pairs(inputTable) do
		if type(value) == "string" or type(value) == "number" then
			returnString = returnString .. key .." = " .. value .. ", "
		elseif type(value) == "table" and loopThroughTables then
			returnString = returnString .. key .. " = " .. tableToText(value) .. ", "
		else
			returnString = returnString .. key .. " = " .. tostring(value) .. ", "
		end
	end
	returnString = returnString .. "}"
	
	return returnString
end

function roundToTwoDecimals(a) --TODO: Make a better, generic version with more decimal points.
	return math.floor(a * 100)/100
end

function rndVec(length)
	local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
	return VecScale(v, length)	
end

function VecDir(a, b)
	return VecNormalize(VecSub(b, a))
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

function raycast(origin, direction, maxDistance, radius, rejectTransparant)
	maxDistance = maxDistance or 500 -- Make this arguement optional, it is usually not required to raycast further than this.
	local hit, distance, normal, shape = QueryRaycast(origin, direction, maxDistance, radius, rejectTransparant)
	
	if hit then
		local hitPoint = VecAdd(origin, VecScale(direction, distance))
		return hit, hitPoint, distance, normal, shape
	end
	
	return false, nil, nil, nil, nil
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
