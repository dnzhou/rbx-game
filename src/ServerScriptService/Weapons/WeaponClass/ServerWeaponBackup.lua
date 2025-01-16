
local players = nil --require(script.Parent.Parent.Parent.Handlers.WeaponHandler)
local cleanup = require(game.ReplicatedStorage.Weapons.FiringBehavior.RaycastIgnore)

-- Part that will be the source of the beam (e.g., the gun or player's hand)

local player = game.Players.LocalPlayer

local range = 1000
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AimingEvent = ReplicatedStorage:WaitForChild("AimEvent")
local ShootEvent = ReplicatedStorage:WaitForChild("ShootEvent")
local EquipEvent = ReplicatedStorage:WaitForChild("EquipEvent")
local ReloadEvent = ReplicatedStorage:WaitForChild("ReloadEvent")

local weaponValues = require(game.ReplicatedStorage.Weapons.FiringBehavior.WeaponValues)

local weaponTemplate = nil




local module = {
	
}
module.__index = module
function module:New(newDamage, newFiringPattern, newSpread, newMagazineSize, newReloadTime, toolName, spreadAmmo)
	self.rand = Random.new(1)
	self = setmetatable({}, module)
	self.damage = newDamage
	self.firingPattern = newFiringPattern
	self.spread = newSpread
	self.equipped = false
	self.toolName = toolName
	self.reloadTime = newReloadTime
	self.isReloading = false
	self.magazineSize = newMagazineSize
	self.ammoCount = newMagazineSize
	self.nextShotReady = true
	self.reloadTask = nil
	self.spreadAmmo = spreadAmmo
	self.burstFiring = false

	
	return self
end
function module:calculateSpread(direction, spread)
	local randomX = self.rand:NextNumber() * 2 - 1  -- Random value between -1 and 1
	local randomY = self.rand:NextNumber() * 2 - 1  -- Random value between -1 and 1
	local randomZ = self.rand:NextNumber() * 2 - 1  -- Random value between -1 and 1

	-- Apply spread to the original direction
	local spreadVector = Vector3.new(
		direction.X + direction.X * randomX * spread,
		direction.Y + direction.Y * randomY * spread / 2,
		direction.Z + direction.Z * randomZ * spread
	)
	
	-- Return the new direction with spread

	return spreadVector.Unit  -- Normalize the vector to keep its direction
end
local function createMuzzleFlash(position)
	-- Create the part for the muzzle flash
	local muzzleEffect = script.Parent:FindFirstChild("MuzzleEffect")

	if muzzleEffect then
		-- Assuming MuzzleEffect is a ParticleEmitter
		muzzleEffect:Emit(20)  -- Emit 20 particles for a quick burst
	else
		warn("MuzzleEffect not found in script.Parent")
	end
end
local function drawLine(startPos, endPos)
	-- Create the attachment points
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
	beam.Width0 = 0.2
	beam.Width1 = 0.2
	--beam.Color = ColorSequence.new(Color3.fromRGB(255, 246, 123))  -- Yellow color
	beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))  -- Yellow color
	beam.LightEmission = 1
	beam.Parent = rayPart

	-- Clean up the beam after a short delay
	game.Debris:AddItem(rayPart, 0.5)

end
-- Draw Raycast and returns humanoid if hit humanoid
local function drawRaycast(startPos, direction, spread)

	local raycastParams = RaycastParams.new()

	raycastParams.FilterDescendantsInstances = cleanup.ignoreList  -- Ignore the player character
	
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	--print(cleanup.ignoreList)
	local spreadDirection = module:calculateSpread(direction, spread)
	local finalDirection = spreadDirection 
	local raycastResult = workspace:Raycast(startPos, finalDirection * range, raycastParams)
	
	if raycastResult then
		drawLine(startPos, raycastResult.Position)
		--createMuzzleFlash(startPos)
		--print("server: ",raycastResult.Position)
		local hitPart = raycastResult.Instance
		local hitHumanoid = hitPart.Parent:FindFirstChild("Humanoid")
		-- Check if the hit part is part of a character with a humanoid
		if not hitHumanoid then
			hitHumanoid = hitPart.Parent.Parent:FindFirstChild("Humanoid")
		end

		if hitHumanoid then
			-- Apply damage
			-- hitHumanoid:TakeDamage(10)  -- Adjust the damage value as needed
			print("hit")
			
			return hitHumanoid
		else
			return nil
		end
	end
end

function module:FireRayCast(spread, player, targetPos)
	--print("firing")
	-- TODO: get client mouse pos

	-- QOL lets player shoot just in front of where they are aiming on ground level
	local startPos = player.Character.HumanoidRootPart.Position
	if targetPos.Y < startPos.Y then
		targetPos = Vector3.new(targetPos.X, targetPos.Y + 0.3, targetPos.Z)
	else
		targetPos = Vector3.new(targetPos.X, targetPos.Y - 0.2, targetPos.Z)
	end
	-- Calculate the direction from the player to the target position
	local direction = (targetPos - startPos).unit

	-- Extend the targetw position
	--targetPos = targetPos + direction

	--targetPos = Vector3.new(targetPos.X, startPos.Y, targetPos.Z)

	-- Add a cooldown to prevent firing again immediately

	return drawRaycast(startPos, direction, spread)
	


end

function module:dealDamage(object, damage)
	if object then
		if object:IsA("Humanoid") and object.Health > 0 then
			object:TakeDamage(damage)
			if object.Health <= 0 then
				cleanup:onHumanoidDied(object)
			end
		elseif object:IsA("BasePart") then
			-- If the object is a part, you can apply damage based on its size or health
			-- For example, you can reduce its size or destroy it if it's below a certain size:
			if object.Size.Magnitude <= 10 then
				object:Destroy()
			else
				object.Size = object.Size - Vector3.new(1, 1, 1)
			end
		end
	end

end

function module:equip()
	self.equipped = true

end
function module:unequip()
	self.isReloading = false
	self.equipped = false
	
end
function module:Reload(player, amount)

	-- Prevent reload if already reloading or the magazine is full
	if not self.equipped or self.ammoCount == self.magazineSize or self.isReloading then
		return
	end
	
	-- Start reloading
	local reloadAmount = tonumber(amount) or self.magazineSize
	--print("Reloading...")
	
	self.isReloading = true  -- Set the reloading flag

	-- Cancel any previous reload task if it exists
	if self.reloadTask then
		task.cancel(self.reloadTask)
	end

	-- Simulate a reload with a progress bar update
	self.reloadTask = task.spawn(function()
		
		local elapsedTime = 0
		local totalReloadTime = self.reloadTime
		local reloadStep = 0.1  -- Check every 0.1 seconds

		-- Loop to simulate the reload process in small steps
		while elapsedTime < totalReloadTime do
			-- If reloading was cancelled (e.g., weapon unequipped), exit immediately
			if not self.isReloading then
				--print("Reload cancelled.")
				--self:UpdateReloadProgress(0)  -- Reset the progress on GUI
				return  -- Exit the reload immediately
			end

			-- Wait for the next step and update the elapsed time
			task.wait(reloadStep)
			elapsedTime = elapsedTime + reloadStep

			-- Update the GUI with the reload progress
			local progress = elapsedTime / totalReloadTime
			--self:UpdateReloadProgress(progress)  -- Update progress bar on GUI
		end

		-- Complete the reload
		
		self.ammoCount = self.magazineSize
		self.isReloading = false  -- Reset the reloading flag


		--print("Reloaded.")
	end)
end
-- Function to draw the line (using Beam)
function module:Fire(player)

	-- Capture `self` inside the Heartbeat function using an anonymous function
	game:GetService("RunService").Stepped:Connect(function()
		local playerInstance = module[player.UserId]
		local weapon = playerInstance["AvailableWeapons"][self.toolName]
		
		if self.ammoCount <= 0 and playerInstance["equipped"] == self.toolName then
			self:Reload(player)
		elseif playerInstance["isShooting"] and weapon.firingPattern:nextShotReady() and playerInstance["equipped"] == self.toolName and not self.isReloading then
			--print("Server: ", playerInstance["equipped"])
			print(self.toolName, self.ammoCount)
			for i = 1,  weapon.firingPattern.burstSize do
				self.burstFiring = true
				local obj = self:FireRayCast(self.spread, player, playerInstance["mousePos"])  -- Call the fire method with `self`
				if obj then
					module:dealDamage(obj, self.damage)
				end
				if weapon.firingPattern.burstDelay > 0 then
					
					wait(weapon.firingPattern.burstDelay)
				end
				if not self.spreadAmmo then
					module:reduceAmmoCount(weapon, 1)
				end
			end
			if self.spreadAmmo then
				module:reduceAmmoCount(weapon, 1)
			end
			self.burstFiring = false
			
			-- print("ammo remaining:", self.ammoCount)
		end
		
		
	end)
end
function module:reduceAmmoCount(weapon, number)
	weapon.ammoCount -= number

end

--------------------------------------------- Event handlers -----------------------------------------------


local function checkPlayerExists(player)

	if module[player.UserId] == nil then
		-- Create a new table for this player if it doesn't exist
		module[player.UserId] = {}
	end
end
-- Function to handle when a player sends their aiming status to the server
AimingEvent.OnServerEvent:Connect(function(player, mousePos)
	-- Update the player's aiming status on the server
	checkPlayerExists(player)
	module[player.UserId]["mousePos"] = mousePos


end)
ShootEvent.OnServerEvent:Connect(function(player, isShooting, mousePos)
	-- Update the player's aiming status on the server
	checkPlayerExists(player)
	module[player.UserId]["isShooting"] = isShooting

	local equippedWeapon = module[player.UserId]["equipped"]
	if equippedWeapon and isShooting then
		

		module[player.UserId]["AvailableWeapons"][equippedWeapon]:Fire(player, mousePos)
	end

end)

ReloadEvent.OnServerEvent:Connect(function(player)
	checkPlayerExists(player)
	local equippedWeapon = module[player.UserId]["equipped"]
	module[player.UserId]["AvailableWeapons"][equippedWeapon]:Reload(player)
end)


EquipEvent.OnServerEvent:Connect(function(player, weaponName)
	checkPlayerExists(player)
	local equippedWeapon = module[player.UserId]["equipped"]
	if not weaponName then -- Unequip here

		if equippedWeapon then
			while equippedWeapon.burstFiring do
				task.wait()
				module[player.UserId]["AvailableWeapons"][equippedWeapon]:unequip()
				module[player.UserId]["equipped"] = nil
			end
		end
		
		return
	elseif weaponName and not module[player.UserId]["AvailableWeapons"][weaponName] then
		warn(weaponName, " is not valid")
		return
	end
	-- Equip
	while equippedWeapon and equippedWeapon.burstFiring do
		task.wait()
	end
	
	module[player.UserId]["equipped"] = weaponName
	
	module[player.UserId]["AvailableWeapons"][weaponName]:equip()

end)

--------------------------------------------------------



function module:createWeapon(weaponName)
	if weaponValues["Weapons"][weaponName] then
		local args = table.clone(weaponValues["Weapons"][weaponName])
		return module:New(table.unpack(args))
	end

end

function module:addWeaponToInventory(player, weaponName)
	checkPlayerExists(player)
	if not module[player.UserId]["AvailableWeapons"] then
		module[player.UserId]["AvailableWeapons"] = {}
	end

	module[player.UserId]["AvailableWeapons"][weaponName] = module:createWeapon(weaponName)

end



return module
