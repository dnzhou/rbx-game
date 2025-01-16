local Players = game:GetService("Players")
local updateTable = game.ReplicatedStorage.Weapons.Events.UpdateIgnoreTable
local PhysicsService = game:GetService("PhysicsService")
local RunService = game:GetService("RunService")
local module = {
	-- tells raycast to ignore dead humanoid
	ignoreList = {}
}
ignoreList = game.Workspace:WaitForChild("Players")
local ttl = 3
function module:onHumanoidDied(humanoid)
	local character = humanoid.Parent

	-- Add to ignore list for raycasting (if necessary)
	table.insert(module.ignoreList, character)
	updateTable:FireAllClients(module.ignoreList)
	-- Delay destruction using task.delay (non-blocking)
	task.delay(ttl, function()
		-- Before destroying, check if the character still exists and hasn't been destroyed
		if character and character.Parent then
			-- Optionally clear any connections, animations, or custom data
			-- Clean up any lingering references to prevent memory leaks

			-- Remove the character from the ignore list to avoid keeping unnecessary references
			for i, v in ipairs(module.ignoreList) do
				if v == character then
					updateTable:FireAllClients(module.ignoreList)
					table.remove(module.ignoreList, i)
					break
				end
			end

			-- Finally, destroy the character
			character:Destroy()
			
			--print("Character destroyed")
		end
	end)
end
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		if RunService:IsServer() then
			table.insert(module.ignoreList, player.Character)  -- Add the player's character to the ignore list
			print("added ", player.Character)
			local character = player.Character or player.CharacterAdded:Wait()
			for _, part in ipairs(character:GetChildren()) do
				if part:IsA("BasePart") then
					part.CollisionGroup = "Players"
				end
			end
			
				updateTable:FireAllClients(module.ignoreList)
		end
		

	end)

end)

-- Handle when a player leaves (optional)
Players.PlayerRemoving:Connect(function(player)
	-- Optionally, remove the player's character from the ignore list if necessary
	if RunService:IsServer() then
		for i, obj in ipairs(module.ignoreList) do
			if obj == player.Character then
				table.remove(module.ignoreList, i)
				updateTable:FireAllClients(module.ignoreList)
				break
			end
		end
	end
end)



return module
