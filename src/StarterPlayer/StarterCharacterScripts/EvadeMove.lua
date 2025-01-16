local RollEventServer = game.ReplicatedStorage.PlayerEvents:WaitForChild("RollEvent")
local RollTime = game.ReplicatedStorage.PlayerEvents.RollTime.Value

local module = {
	isRolling = false
}

local UserInputService = game:GetService("UserInputService")
local RollEventClient = script.Parent.ClientEvents.RollEvent
local player = game.Players.LocalPlayer
local animator = player.Character.Humanoid:FindFirstChildOfClass("Animator")
local roll = animator:LoadAnimation(player.Character.Humanoid.AnimSaves.Roll)
local humanoid = player.Character:WaitForChild("Humanoid")

local force = 10000
local function getMovementDirection()
	local velocity = humanoid.MoveDirection -- Get the velocity of the player
	local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z)  -- Ignore Y for horizontal movement

	if horizontalVelocity.Magnitude > 0 then
		local movementDirection = horizontalVelocity.Unit  -- Normalize the velocity to get direction
		return movementDirection
	else
		return Vector3.zero  -- No movement if magnitude is 0
	end
end



UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.LeftControl and not gameProcessed and not module.isRolling then
		module.isRolling = true
		RollEventClient:Fire(false)
		RollEventServer:FireServer()
		
		
		local playerChar = player.Character
		roll:Play()

		local slide = Instance.new("BodyVelocity")
		slide.MaxForce = Vector3.new(2,0,2) * force	--changes how far you will go!
		local velocity = getMovementDirection()
		
		if velocity.Magnitude ~= 0 then
			slide.Velocity = velocity * 50
		else
			
			local velocity = playerChar.HumanoidRootPart.CFrame.lookVector * 50
			local newVelocity = Vector3.new(velocity.Z, 0, velocity.X)
			slide.Velocity = velocity

		end
		slide.Parent = playerChar.HumanoidRootPart
		
		for count = 0.1, RollTime, 0.1 do
			wait(0.1)
			slide.Velocity*= 0.75
		end
		RollEventClient:Fire(true)
		slide:Destroy()
		roll:Stop()
		
		module.isRolling = false

	end
end)

return module
