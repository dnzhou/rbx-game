
local players = nil --require(script.Parent.Parent.Parent.Handlers.WeaponHandler)
local GameManager = require(game.ServerScriptService.GameManager)
local HitscanFiringBehaviour = require(game.ReplicatedStorage.Weapons.FiringBehavior.HitscanFiringBehaviour)
local ProjectileFiringBehaviour = require(game.ReplicatedStorage.Weapons.FiringBehavior.ProjectileFiringBehaviour)
local weaponLoader = require(game.ReplicatedStorage.Weapons.LoadValues)
-- Part that will be the source of the beam (e.g., the gun or player's hand)

local player = game.Players.LocalPlayer

local range = 1000
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AimingEvent = ReplicatedStorage.Weapons.Events:WaitForChild("AimEvent")
local ShootEvent = ReplicatedStorage.Weapons.Events:WaitForChild("ShootEvent")
local EquipEvent = ReplicatedStorage.Weapons.Events:WaitForChild("EquipEvent")
local ReloadEvent = ReplicatedStorage.Weapons.Events:WaitForChild("ReloadEvent")
local MouseUpdate = ReplicatedStorage.Weapons.Events:WaitForChild("MouseUpdateEvent")
local weaponValues = require(game.ReplicatedStorage.Weapons.FiringBehavior.WeaponValues)
local RollEvent = game.ReplicatedStorage.PlayerEvents:WaitForChild("RollEvent")
local RollTime = game.ReplicatedStorage.PlayerEvents:WaitForChild("RollTime").Value
local weaponTemplate = nil




local module = {

}




function module:equip(player)
	local equipped = module[player.UserId]["equipped"]
	module[player.UserId]["AvailableWeapons"][equipped].equipped = true

end
function module:unequip(player)
	local equipped = module[player.UserId]["equipped"]
	module[player.UserId]["AvailableWeapons"][equipped].isReloading = false
	module[player.UserId]["AvailableWeapons"][equipped].equipped = false


end
function module:Reload(player, amount)
	local equipped = module[player.UserId]["equipped"]
	local weapon = module[player.UserId]["AvailableWeapons"][equipped]
	-- Prevent reload if already reloading or the magazine is full
	if not weapon.equipped or weapon.ammoCount == weapon.magazineSize or weapon.isReloading then
		return
	end

	-- Start reloading
	local reloadAmount = tonumber(amount) or weapon.magazineSize
	--print("Reloading...")

	weapon.isReloading = true  -- Set the reloading flag

	-- Cancel any previous reload task if it exists
	if weapon.reloadTask then
		task.cancel(weapon.reloadTask)
	end

	-- Simulate a reload with a progress bar update
	weapon.reloadTask = task.spawn(function()

		local elapsedTime = 0
		local totalReloadTime = weapon.reloadTime 
		local reloadStep = 0.1  -- Check every 0.1 seconds

		-- Loop to simulate the reload process in small steps
		while elapsedTime < totalReloadTime do
			-- If reloading was cancelled (e.g., weapon unequipped), exit immediately
			if not weapon.isReloading then
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

		weapon.ammoCount = weapon.magazineSize
		weapon.isReloading = false  -- Reset the reloading flag


		--print("Reloaded.")
	end)
end
-- Function to draw the line (using Beam)
function module:Fire(player, mousePos)

	local beamColour = nil

	-- Capture `self` inside the Heartbeat function using an anonymous function
	
	game:GetService("RunService").Heartbeat:Connect(function()
		local equipped = module[player.UserId]["equipped"]
		local weapon = module[player.UserId]["AvailableWeapons"][equipped]
		local playerInstance = module[player.UserId]
		if not weapon then
			return
		end

		if weapon.ammoCount <= 0 and playerInstance["equipped"] == weapon.tool.Name then
			module:Reload(player)
		elseif playerInstance["isShooting"] and weapon.firingPattern:nextShotReady() and playerInstance.equipped == weapon.tool.Name 
		and not weapon.isReloading and playerInstance.isAiming and tick() - playerInstance.lastRolled >= RollTime then
			--print("Server: ", playerInstance["equipped"])
			--print(weapon.toolName, weapon.ammoCount)
			
			
			for i = 1,  weapon.firingPattern.burstSize do
				local fireOrigin = weapon.tool.Handle.Shot.Position
				weapon.burstFiring = true
				-- Call the fire method with `weapon`
				if weapon.fireType == "hitscan" then
					
					local obj = HitscanFiringBehaviour:FireRayCast(weapon.spread, fireOrigin, playerInstance["mousePos"], playerInstance.randSpread, beamColour, 0.2)
					if obj then
						GameManager:dealDamage(obj, weapon.damage)
					end
				elseif weapon.fireType == "projectile" then
					local args = {
						velocity =  weapon.velocity,
						acceleration = weapon.acceleration,
						blastRadius = weapon.blastRadius,	
						toolName = weapon.tool.Name,
						player = player
					}
					local obj = ProjectileFiringBehaviour:FireProjectile(weapon.spread, fireOrigin, playerInstance["mousePos"], playerInstance.randSpread, args)
					
				end
				
				if weapon.firingPattern.burstDelay > 0 then

					task.wait(weapon.firingPattern.burstDelay)
				end
				if not weapon.spreadAmmo then
					module:reduceAmmoCount(weapon, 1)
				end
			end
			if weapon.spreadAmmo then
				module:reduceAmmoCount(weapon, 1)
			end
			weapon.burstFiring = false

			-- print("ammo remaining:", weapon.ammoCount)
		end


	end)
end

local function isNPC(character)
	local humanoid = character:FindFirstChild("Humanoid")

	return humanoid and not game.Players:GetPlayerFromCharacter(character)  -- Ignore players
end


local function calculateProximityDamage(player, weapon, center, partPosition, range)
	local equippedWeapon = module[player.UserId]["AvailableWeapons"][weapon]
	local dist = math.abs((center - partPosition).magnitude)
	local fallOffLimit = 0.2
	local fallOffBeginLimit = 0.7
	local percentage = 1 - dist/range
	--print(percentage, dist, range)
	--print(start, middle)
	if percentage >= fallOffBeginLimit then
		return equippedWeapon.damage
	elseif percentage >= fallOffLimit then
		return equippedWeapon.damage * percentage
	else
		return equippedWeapon.damage * fallOffLimit

	end


end
-- Function to handle explosion hits
local function onExplosionHit(player, weapon, hitPart, explosionCenter, range)
	local character = hitPart.Parent  -- The part's parent is usually a character model
	-- Apply damage only to NPCs
	if character and isNPC(character) then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid and hitPart == humanoidRootPart then

			GameManager:dealDamage(humanoid, calculateProximityDamage(player, weapon, explosionCenter, hitPart.Position, range))

		end
	end
end

ProjectileFiringBehaviour.caster.RayHit:Connect(function(cast, result, velocity)
	local hitPart = result.Instance
	-- Trigger an explosion on impact
	local explosion = Instance.new("Explosion")
	explosion.Position = result.Position
	explosion.BlastRadius = cast.Caster.UserData.blastRadius
	explosion.DestroyJointRadiusPercent = 0
	explosion.BlastPressure = 0
	explosion.Parent = workspace

	explosion.Visible = false


	local explosionCenter = result.Position
	local player = cast.Caster.UserData.player
	local weapon = cast.Caster.UserData.weapon
	-- Clean up the rocket visual
	explosion.Hit:Connect(function(hitPart)

		onExplosionHit(player, weapon, hitPart, explosionCenter, explosion.BlastRadius)
	end)


end)

function module:reduceAmmoCount(weapon, number)
	weapon.ammoCount -= number

end

--------------------------------------------- Event handlers -----------------------------------------------
local function createPlayerWeaponTable(player: Player)
	if module[player.UserId] then return end
	module[player.UserId] = {
		["equipped"] = nil,
		["isShooting"] = false,
		["isAiming"] = false,
		["mousePos"] = nil,
		["randSpread"] = Random.new(1),
		["AvailableWeapons"] = {},
		["lastRolled"] = 0


	}
end

local function checkPlayerExists(player)

	if module[player.UserId] == nil then
		-- Create a new table for this player if it doesn't exist
		createPlayerWeaponTable(player)
	end
end

MouseUpdate.OnServerEvent:Connect(function(player, mousePos)
	checkPlayerExists(player)
	module[player.UserId]["mousePos"] = mousePos
end)


-- Function to handle when a player sends their aiming status to the server


AimingEvent.OnServerEvent:Connect(function(player, isAiming)
	-- Update the player's aiming status on the server
	checkPlayerExists(player)
	
	module[player.UserId]["isAiming"] = isAiming


end)
ShootEvent.OnServerEvent:Connect(function(player, isShooting, mousePos)
	-- Update the player's aiming status on the server
	checkPlayerExists(player)
	module[player.UserId]["isShooting"] = isShooting
	local equippedWeapon = module[player.UserId]["equipped"]
	if equippedWeapon and isShooting then
		module[player.UserId]["mousePos"] = mousePos
		module:Fire(player)
		
	end

end)

ReloadEvent.OnServerEvent:Connect(function(player)
	checkPlayerExists(player)
	local equippedWeapon = module[player.UserId]["equipped"]
	module:Reload(player)
end)


EquipEvent.OnServerEvent:Connect(function(player: Player, weaponName)
	checkPlayerExists(player)

	local equippedWeapon = module[player.UserId]["equipped"]
	if not weaponName then -- Unequip here

		if equippedWeapon then
			while equippedWeapon.burstFiring do
				task.wait()
				
			end
			module:unequip(player)
			module[player.UserId]["equipped"] = nil
			module[player.UserId]["isShooting"] = false
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

	module:equip(player)

end)

RollEvent.OnServerEvent:Connect(function(player: Player, ...: any) 
	
	local now = tick()
	if now - module[player.UserId]["lastRolled"] >= RollTime then
		--print(player.Name .. " dashed")
		module[player.UserId]["lastRolled"] = now
	end
	
	
end)


--------------------------------------------------------



function module:createWeapon(tool)
	if weaponValues["HitscanWeapons"][tool.Name] then
		local args = table.clone(weaponValues["HitscanWeapons"][tool.Name])
		local newWeapon = weaponLoader:unpackArgs(args)
		newWeapon.tool = tool
		return newWeapon
	
	elseif weaponValues["ProjectileWeapons"][tool.Name] then
		local args = table.clone(weaponValues["ProjectileWeapons"][tool.Name])
		local newWeapon = weaponLoader:unpackArgs(args)
		newWeapon.tool = tool
		return newWeapon
	else
		warn("Could not create weapon: not found in table")
	end

end

function module:addWeaponToInventory(player, tool)
	checkPlayerExists(player)
	module[player.UserId]["AvailableWeapons"][tool.Name] = module:createWeapon(tool)
	

end



return module
