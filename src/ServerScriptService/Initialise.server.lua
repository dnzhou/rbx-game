-- local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Step 1: Create a Folder in Workspace to store player models
local playerFolder = Instance.new("Folder")
playerFolder.Name = "Players"
playerFolder.Parent = Workspace  -- Add the folder to the Workspace

require(game.ReplicatedStorage.Weapons.FiringBehavior.RaycastIgnore)
require(game.ReplicatedStorage.Weapons.FiringBehavior.WeaponValues)





-- Step 2: Listen for when a player joins
