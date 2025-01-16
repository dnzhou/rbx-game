local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local AimEvent = game.ReplicatedStorage.Weapons.Events:WaitForChild("AimEvent")
local weaponSwitchEvent = script.Parent.ClientEvents.WeaponSwitchEvent
local UserInputService = game:GetService("UserInputService")
local playerRoll = require(script.Parent.EvadeMove)
local RollEvent = script.Parent.ClientEvents.RollEvent
local ClientAimEvent = script.Parent.ClientEvents.AimEvent
local circle = script.Parent:WaitForChild("AimingCircle")

local character = game.Players.LocalPlayer.Character

local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local module = {
	mousePos = nil,
	isAiming = false,
	aimPressed = false,
	defaultSpeed = 16,
	speedMultiplier = 1,
}

circle.Parent = workspace

-- Detect when the right mouse button is released
-- Variable to track if the player is aiming

local function faceAimDirection()
	if module.isAiming then
		-- Disable AutoRotate to prevent movement from affecting rotation
		humanoid.AutoRotate = false

		-- Get the mouse's 3D position (ignoring Y for top-down view)
		local lookDirection = Vector3.new(module.mousePos.X - humanoidRootPart.Position.X, 0, module.mousePos.Z - humanoidRootPart.Position.Z).unit

		-- Smoothly rotate the player towards the aim direction
		local targetCFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + lookDirection)

		-- Lerp (linear interpolation) to smooth the rotation and prevent abrupt changes
		humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(targetCFrame, 0.2)  -- Adjust 0.1 for speed of turning
	else
		-- Re-enable AutoRotate when not aiming to restore normal movement-based rotation
		humanoid.AutoRotate = true
	end
end


-- Function to update the circle position, always projecting onto the ground
local function updateCirclePosition()
	if module.mousePos then
		
		-- Get the mouse's 3D position (ignoring humanoids via TargetFilter)
		module.mousePos = mouse.Hit.p

		-- Always place the circle on the ground (ignoring the Y value of mouse.Hit.p)
		circle.Position = Vector3.new(module.mousePos.X, module.mousePos.Y, module.mousePos.Z)
		faceAimDirection()
	end
end

local function toggleOn()
	module.isAiming = true
	UserInputService.MouseIconEnabled = false
	module.mousePos = mouse.Hit.p
	AimEvent:FireServer(true)
	ClientAimEvent:Fire()
	circle.Transparency = 0

	player.Character:FindFirstChild("Humanoid").WalkSpeed = module.defaultSpeed * module.speedMultiplier
	
end

local function toggleOff()
	module.isAiming = false
	
	AimEvent:FireServer(false)
	UserInputService.MouseIconEnabled = true
	circle.Transparency = 1  -- Hide the circle when not aiming
	player.Character:FindFirstChild("Humanoid").WalkSpeed = module.defaultSpeed
	ClientAimEvent:Fire()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseButton2 and not playerRoll.isRolling and not gameProcessed then
		toggleOn()
		module.aimPressed = true
	end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)

	if input.UserInputType == Enum.UserInputType.MouseButton2 and not gameProcessed then
		toggleOff()
		module.aimPressed = false
	end
end)

RollEvent.Event:Connect(function(toggleAim)
	if toggleAim and module.aimPressed then
		toggleOn()
	else
		toggleOff()
	end
end)
weaponSwitchEvent.Event:Connect(function() 
	if module.isAiming then
		toggleOn()
	end
end)

-- Continuously update the circle's position as the player moves the mouse

game:GetService("RunService").RenderStepped:Connect(updateCirclePosition)
return module
