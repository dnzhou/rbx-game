-- ToolHandler.lua
local ToolHandler = {
	switching = false
}
ToolHandler.__index = ToolHandler

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShootEvent = ReplicatedStorage.Weapons.Events:WaitForChild("ShootEvent")
local EquipEvent = ReplicatedStorage.Weapons.Events:WaitForChild("EquipEvent")
local ReloadEvent = ReplicatedStorage.Weapons.Events:WaitForChild("ReloadEvent")
local FiredEvent = ReplicatedStorage.Weapons.Events:WaitForChild("FiredEvent")
local UserInputService = game:GetService("UserInputService")

local weaponSwitchEvent = script.Parent.Parent.ClientEvents.WeaponSwitchEvent

local aim = require(script.Parent.Parent.AimCrosshair)



-- Constructor function to initialize the tool handler
function ToolHandler.new(tool, localWeaponModule)
	local self = setmetatable({}, ToolHandler)


	self.weapon = require(tool.WeaponStats)
	self.weapon.tool = tool
	self.localWeapon = localWeaponModule
	
	-- Setup event handlers for the tool
	self:setupEvents()
	return self
end

-- Set up all tool events
function ToolHandler:setupEvents()
	local tool = self.weapon.tool
	local localWeapon = self.localWeapon

	-- Fire weapon when tool is activated
	tool.Activated:Connect(function()
		
		if aim.isAiming then
			local pos = aim.mousePos
			ShootEvent:FireServer(true, pos)
			localWeapon:Fire(pos)
			localWeapon.shooting = true
		end

	end)

	-- Stop firing when tool is deactivated
	tool.Deactivated:Connect(function()
		ShootEvent:FireServer(false)
		localWeapon.shooting = false
	end)

	-- Equip event
	tool.Equipped:Connect(function()
		while localWeapon.burstFiring do
			task.wait()
		end

		aim.speedMultiplier = self.weapon.aimMoveSpeed
		EquipEvent:FireServer(tool.Name)
		weaponSwitchEvent:Fire()
		localWeapon:Equip(self.weapon)
		
		-- check player is still shooting then let server know


	end)

	-- Unequip event
	tool.Unequipped:Connect(function()
		while localWeapon.burstFiring do
			task.wait()
		end
		
		EquipEvent:FireServer(nil)
		localWeapon:Unequip()
	end)
	

	-- Reload event
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.KeyCode == Enum.KeyCode.R and not gameProcessed then
			ReloadEvent:FireServer()
			localWeapon:Reload()
		end
	end)


end

return ToolHandler