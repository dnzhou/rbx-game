local module = {}

function module:calculateSpread(direction, spread, randSpread)
	local randomX = randSpread:NextNumber() * 2 - 1  -- Random value between -1 and 1
	local randomY = randSpread:NextNumber() * 2 - 1  -- Random value between -1 and 1
	local randomZ = randSpread:NextNumber() * 2 - 1  -- Random value between -1 and 1

	-- Apply spread to the original direction
	local spreadVector = Vector3.new(
		direction.X + direction.X * randomX * spread,
		direction.Y ,
		direction.Z + direction.Z * randomZ * spread
	)

	-- Return the new direction with spread

	return spreadVector.Unit  -- Normalize the vector to keep its direction
end

return module
