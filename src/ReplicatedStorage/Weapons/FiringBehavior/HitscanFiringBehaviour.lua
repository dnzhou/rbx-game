
local WeaponServices = require(script.Parent.WeaponServices)
local RANGE = 1000


local module = {RaycastIgnoreList = require(game.ReplicatedStorage.Weapons.FiringBehavior.RaycastIgnore)}


local function drawLine(startPos, endPos, colour, duration)
	-- Create the attachment points
	if not colour then return end
	local startAttachment = Instance.new("Attachment")
	local endAttachment = Instance.new("Attachment")

	-- Create a part to hold the attachments (invisible part)
	local rayPart = Instance.new("Part")
	rayPart.Anchored = true
	rayPart.CanCollide = false
	rayPart.Transparency = 1  -- Make the part invisible
	rayPart.Size = Vector3.new(0.1, 0.1, 0.1)
	rayPart.CFrame = CFrame.new(startPos)  -- Position the part at startPos
	rayPart.Parent = workspace

	-- Set up the attachments' positions
	startAttachment.Position = Vector3.new(0, 0, 0)
	startAttachment.Parent = rayPart
	endAttachment.Position = (endPos - startPos)  -- Relative to the start
	endAttachment.Parent = rayPart

	-- Create the beam
	local beam = Instance.new("Beam")
	beam.Attachment0 = startAttachment
	beam.Attachment1 = endAttachment
	beam.FaceCamera = true
	beam.FaceCamera = true
	beam.Width0 = 0.4
	beam.Width1 = 0.5
	beam.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	beam.TextureSpeed = 10
	beam.TextureMode = "Stretch"
	beam.Transparency = NumberSequence.new(0)
	--beam.Color = ColorSequence.new(Color3.fromRGB(255, 246, 123))  -- Yellow color
	--beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))  -- Yellow color
	beam.Color = colour or ColorSequence.new(Color3.fromRGB(255, 246, 123))  -- Yellow color
	beam.LightEmission = 1
	beam.Parent = rayPart

	-- Clean up the beam after a short delay
	game.Debris:AddItem(rayPart, duration)

end
-- Draw Raycast and returns humanoid if hit humanoid
local function drawRaycast(startPos, direction, spread, randSpread, colour, duration)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = module.RaycastIgnoreList.ignoreList  -- Ignore the player character

	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	--print(cleanup.ignoreList)

	local spreadDirection = WeaponServices:calculateSpread(direction, spread, randSpread)
	local finalDirection = spreadDirection 
	local raycastResult = workspace:Raycast(startPos, finalDirection * RANGE, raycastParams)

	if raycastResult then
		drawLine(startPos, raycastResult.Position, colour, duration)

		--print("server: ",raycastResult.Position)
		local hitPart = raycastResult.Instance
		local hitHumanoid = hitPart.Parent:FindFirstChild("Humanoid")
		-- Check if the hit part is part of a character with a humanoid
		if not hitHumanoid then
			hitHumanoid = hitPart.Parent.Parent:FindFirstChild("Humanoid")
		end

		if hitHumanoid then
			return hitHumanoid
		else
			return nil
		end
		
	else
		drawLine(startPos, finalDirection * RANGE, colour, duration)
	end
end

function module:FireRayCast(spread, startPos, targetPos, randSpread, colour, duration)
	--print("firing")
	-- TODO: get client mouse pos
	
	-- QOL lets player shoot just in front of where they are aiming on ground level
	-- local startPos = player.Character.HumanoidRootPart.Position
	if targetPos.Y < startPos.Y then
		targetPos = Vector3.new(targetPos.X, targetPos.Y + 0.2, targetPos.Z)
	else
		targetPos = Vector3.new(targetPos.X, targetPos.Y - 0.2, targetPos.Z)
	end
	-- Calculate the direction from the player to the target position
	local direction = (targetPos - startPos).unit

	-- Extend the targetw position
	--targetPos = targetPos + direction

	--targetPos = Vector3.new(targetPos.X, startPos.Y, targetPos.Z)

	-- Add a cooldown to prevent firing again immediately

	return drawRaycast(startPos, direction, spread, randSpread, colour, duration)



end

return module
