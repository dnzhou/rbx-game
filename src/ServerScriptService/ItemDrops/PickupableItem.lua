local itemCircle = game.ReplicatedStorage.ItemDrops.ItemCircle
local Items = require(script.Parent.ItemList)
local rarityColors = require(script.Parent.RarityColors)
local Players = game:GetService("Players")
local spawnDistanceVariation = 3
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local module = {
	groundLoot = {}
}

module.__index = module
local function getGroundPosition(position)
	local rayOrigin = position  -- Start the ray from the HumanoidRootPart
	local rayDirection = Vector3.new(0, -100, 0)  -- Cast the ray downward, assuming a max range of 100 studs

	-- Set up raycast parameters
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {workspace.EnemyNPC}  -- Ignore the character itself in the raycast
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude  -- Exclude the character from being hit

	-- Perform the raycast
	local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

	if raycastResult then
		local groundPosition = raycastResult.Position  -- This is the position of the ground below the humanoid
		return groundPosition
	else
		-- No ground detected within the ray's range
		return position
	end
end

local function onTouch(circle, itemName)
	return function(hit)
		local character = hit.Parent
		local player = Players:GetPlayerFromCharacter(character)

		if player and module.groundLoot[circle.ID] then
			if not circle.debounce then
				circle.debounce = true
				print(player, " picked up: ", itemName)
				table.remove(module.groundLoot,circle.ID)
				circle.circle:Destroy()
			end
			-- Add the item to the player's inventory
			--addToInventory(player, itemName)

			-- Destroy the circle after the player picks it up
			
		end
	end
end

local function destroyItem(circle)
	return function(child, parent)
		if not parent then  -- When parent is nil, it means the part has been removed from the hierarchy
			table.remove(module.groundLoot,circle.ID)
			circle.circle:Destroy()
		end
	end
end

local function createItemID()
	local ID = math.random()

	while module.groundLoot[ID] do
		ID = math.random()
	end
	return ID
end


function module:New(itemName, position)
	local self = setmetatable({}, module)
	local item = Items:GetItem(itemName)
	
	if not item then
		return
	end
	self.debrisTime = 3
	self.Name = "PickupableItem"
	self.PickupDistance = 10
	self.circle = itemCircle:Clone()
	self.ID = createItemID()
	self.debounce = false
	-- Set the properties of the cloned circle
	self.circle.Color = rarityColors[item.Rarity]
	self.circle.Beam.Color = ColorSequence.new(rarityColors[item.Rarity])

	-- Parent the circle to the workspace
	self.circle.Parent = workspace

	-- Generate a random offset for the position
	local randomXDist = math.random(-spawnDistanceVariation, spawnDistanceVariation)
	local randomZDist = math.random(-spawnDistanceVariation, spawnDistanceVariation)
	local newPos = Vector3.new(position.X + randomXDist, position.Y, position.Z + randomZDist)

	-- Perform a raycast from the original position to the new random position
	local rayDirection = (newPos - position).unit * (newPos - position).magnitude  -- Direction of the raycast
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {self.circle}  -- Exclude the item itself from the raycast
	
	-- Fire the raycast
	local rayResult = Workspace:Raycast(position, rayDirection, rayParams)

	-- If the ray hits something, move the item to the hit position
	if rayResult then
		newPos = rayResult.Position  -- Move the item to the point where the ray hits
	end
	newPos = getGroundPosition(newPos)
	-- Set the position of the circle
	self.circle.Position = newPos
	self.circle.Hitbox.Position = newPos
	module.groundLoot[self.ID] = self
	-- Schedule cleanup of the item after 90 seconds
	Debris:AddItem(self.circle, self.debrisTime)

	-- Connect the Touched event to detect when the player touches the circle
	self.circle.Hitbox.Touched:Connect(onTouch(self, itemName))
	self.circle.AncestryChanged:Connect(destroyItem(self))

	return self
end




return module
