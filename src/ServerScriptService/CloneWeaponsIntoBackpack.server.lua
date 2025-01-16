local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlayerStats = require(game.ServerScriptService.Weapons.WeaponClass.ServerWeapon)




-- Function to give a player a tool from ReplicatedStorage
local function givePlayerTool(player, weaponName)
	-- Find the tool in ReplicatedStorage
	local tool = ReplicatedStorage.Weapons:FindFirstChild(weaponName)

	-- Check if the tool exists
	if tool then
		-- Clone the tool
		local clonedTool = tool:Clone()
		
		-- Place the cloned tool into the player's Backpack
		clonedTool.Parent = player:FindFirstChild("Backpack")

		PlayerStats:addWeaponToInventory(player, clonedTool)

		print(player.Name .. " has received the tool: " .. weaponName)
	else
		warn("Tool " .. weaponName .. " not found in ReplicatedStorage.")
	end
end

-- Example: Give a specific player a tool when they join
Players.PlayerAdded:Connect(function(player)
	-- Wait until the player's character is loaded
	player.CharacterAdded:Wait()
	
	-- Give the player the tool (replace "Rifle" with your tool's name)
	givePlayerTool(player, "BasicShotgun")
	givePlayerTool(player, "BasicPistol")
	givePlayerTool(player, "BurstRifle")
	givePlayerTool(player, "BasicRifle")
	givePlayerTool(player, "SingleShotLauncher")
	givePlayerTool(player, "AutoGrenadeLauncher")
	
end)