local replicatedStorage = game:GetService("ReplicatedStorage")

-- Check if the RemoteEvent already exists
if not game:GetService("ReplicatedStorage"):FindFirstChild("ShootEvent") then
	-- Create the RemoteEvent for shooting
	local shootEvent = Instance.new("RemoteEvent")
	shootEvent.Name = "ShootEvent"
	shootEvent.Parent = replicatedStorage
end