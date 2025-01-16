local player = game.Players.LocalPlayer
local aim = require(script.Parent.Parent.AimCrosshair)
local ammoGui = player:WaitForChild("PlayerGui"):WaitForChild("AmmoGui") -- Reference to the Ammo GUI
local ammoLabel = ammoGui:WaitForChild("TextLabel")  -- Reference to the TextLabel
local MouseUpdate = game.ReplicatedStorage.Weapons.Events:WaitForChild("MouseUpdateEvent")
local HitscanFiringBehaviour = require(game.ReplicatedStorage.Weapons.FiringBehavior.HitscanFiringBehaviour)
local ProjectileFiringBehaviour = require(game.ReplicatedStorage.Weapons.FiringBehavior.ProjectileFiringBehaviour)
local ClientAimEvent = script.Parent.Parent.ClientEvents.AimEvent
local LookupTable = require(game.ReplicatedStorage.Weapons.WeaponLookupTable)


local IgnoreEvent = game.ReplicatedStorage.Weapons.Events:WaitForChild("UpdateIgnoreTable")
local rand = Random.new(1)



ammoGui.Enabled = false




local module = {
	equipped = nil,
	shooting = false,
	reloading = false,
	burstFiring = false,
	tool = nil
}


local animator = player.Character.Humanoid:FindFirstChildOfClass("Animator")

local aimAnimation = nil
local idleAnimation = nil
local fireAnimation = nil
local reloadAnimation = nil

--local muzzleFlash = script.Parent.Effects:WaitForChild("MuzzleEffect")
local Debris = game:GetService("Debris")

function module:Equip(weapon)
	ammoGui.Enabled = true
	module.equipped = weapon
	module:updateAmmoDisplay()
	local weaponName = weapon.tool.Name
	aimAnimation = animator:LoadAnimation(LookupTable[weaponName].animations.Aim)
	idleAnimation = animator:LoadAnimation(LookupTable[weaponName].animations.Idle)
	fireAnimation = animator:LoadAnimation(LookupTable[weaponName].animations.Fire)
	reloadAnimation = animator:LoadAnimation(LookupTable[weaponName].animations.Reload)
	
	idleAnimation:Play()
end

function module:Unequip()
	ammoGui.Enabled = false
	module.isReloading = false
	module.shooting = false
	module.equipped = nil

	aimAnimation:Stop()
	idleAnimation:Stop()
end

function module:Reload(amount)
	-- Prevent reload if already reloading or the magazine is full

	if not self.equipped or self.equipped.ammoCount == self.equipped.magazineSize or self.isReloading then
		return
	end
	-- Start reloading
	local reloadAmount = tonumber(amount) or self.equipped.magazineSize
	--print("Reloading...")

	self.isReloading = true  -- Set the reloading flag
	reloadAnimation:Play()
	-- Cancel any previous reload task if it exists
	if self.equipped.reloadTask then
		task.cancel(self.equipped.reloadTask)
	end

	-- Simulate a reload with a progress bar update
	self.equipped.reloadTask = task.spawn(function()

		local elapsedTime = 0
		local totalReloadTime = self.equipped.reloadTime
		local reloadStep = 0.1  -- Check every 0.1 seconds

		-- Loop to simulate the reload process in small steps
		while elapsedTime < totalReloadTime do
			-- If reloading was cancelled (e.g., weapon unequipped), exit immediately
			if not self.isReloading then
				print("Reload cancelled.")
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
		
		self.equipped.ammoCount = self.equipped.magazineSize
		self:updateAmmoDisplay()
		self.isReloading = false  -- Reset the reloading flag

		--self:UpdateReloadProgress(1)  -- Set the progress to 100% on GUI
		--print("Reloaded.")
	end)
end

function module:createMuzzleFlash()

	local flash = module.equipped.tool.Handle.Shot:FindFirstChild("MuzzleEffect")
	if not flash then return end
	flash.Enabled = true
	task.delay(0.05, function()
		flash.Enabled = false
	end)
	--TODO: add flash to correct position


	
end

ProjectileFiringBehaviour.caster.RayHit:Connect(function(cast, result, velocity)
	local hitPart = result.Instance

	-- Trigger an explosion on impact
	local explosion = Instance.new("Explosion")
	explosion.Position = result.Position
	explosion.DestroyJointRadiusPercent = 0
	explosion.BlastPressure = 0
	explosion.Parent = workspace
	if cast.RayInfo.CosmeticBulletObject then
		cast.RayInfo.CosmeticBulletObject:Destroy()
	end
	


end)

function module:Fire()
	local tracerColour = ColorSequence.new(Color3.fromRGB(255, 246, 123))
	

	-- Capture `self` inside the Heartbeat function using an anonymous function
	game:GetService("RunService").Stepped:Connect(function()
		local weapon = module.equipped
		
		if weapon and weapon.ammoCount <= 0 then
			self:Reload()
		
		elseif weapon and module.shooting and weapon.firingPattern:nextShotReady() and not module.isReloading and aim.isAiming then

			--print("Client: ", weapon.tool.Name)
			for i = 1,  weapon.firingPattern.burstSize do
				module.burstFiring = true
				--print(weapon.tool.Name)
				if weapon and not weapon.spreadAmmo then
					module:reduceAmmoCount(1)
					module:createMuzzleFlash()
				end
				MouseUpdate:FireServer(aim.mousePos)

				
				fireAnimation:Play()
				local fireOrigin = module.equipped.tool.Handle.Shot.Position
				if module.equipped.fireType == "hitscan" then
					HitscanFiringBehaviour:FireRayCast(weapon.spread, fireOrigin, aim.mousePos, rand, tracerColour, 0.05)
				elseif module.equipped.fireType == "projectile" then
					local args = {
						velocity =  weapon.velocity,
						acceleration = weapon.acceleration
					}
					ProjectileFiringBehaviour:FireProjectile(weapon.spread, fireOrigin, aim.mousePos, rand, args, LookupTable[weapon.tool.Name].model)
				end

				
				if weapon.firingPattern.burstDelay > 0 then
					
					task.wait(weapon.firingPattern.burstDelay)
				end						
			end
			
			if weapon and weapon.spreadAmmo then
				module:createMuzzleFlash()
				module:reduceAmmoCount(1)
			end
			module.burstFiring = false
			aimAnimation:Play()
			--print("ammo remaining:", self.equipped.ammoCount)
		end


	end)

	
end
function module:updateAmmoDisplay()
	
	ammoLabel.Text = "Ammo: " .. module.equipped.ammoCount .. "/" .. module.equipped.magazineSize
end
function module:reduceAmmoCount(number)
	
	self.equipped.ammoCount -= number
	module:updateAmmoDisplay()
end

IgnoreEvent.OnClientEvent:Connect(function(updatedHitscanTable)
	HitscanFiringBehaviour.RaycastIgnoreList.ignoreList = updatedHitscanTable
	
end)

ClientAimEvent.Event:Connect(function() 
	if not module.equipped then
		return
	end
	if not LookupTable[module.equipped.tool.Name] or not LookupTable[module.equipped.tool.Name].animations then
		warn("animation not defined yet")
		return
	end

	
	if aim.isAiming then
		
		aimAnimation:Play()
		
		
	else
		aimAnimation:Stop()
		idleAnimation:Play()
	end

	
end)

return module
