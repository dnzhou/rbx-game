local aim = require(script.Parent:WaitForChild("AimCrosshair"))
local player = game.Players.LocalPlayer

local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Disable humanoid's AutoRotate while aiming
humanoid.AutoRotate = true

-- Function to make the player face the direction they are aiming
local function faceAimDirection()
	if aim.isAiming then
		-- Disable AutoRotate to prevent movement from affecting rotation
		humanoid.AutoRotate = false

		-- Get the mouse's 3D position (ignoring Y for top-down view)
		local lookDirection = Vector3.new(aim.mousePos.X - humanoidRootPart.Position.X, 0, aim.mousePos.Z - humanoidRootPart.Position.Z).unit

		-- Smoothly rotate the player towards the aim direction
		local targetCFrame = CFrame.new(humanoidRootPart.Position, humanoidRootPart.Position + lookDirection)

		-- Lerp (linear interpolation) to smooth the rotation and prevent abrupt changes
		humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(targetCFrame, 0.2)  -- Adjust 0.1 for speed of turning
	else
		-- Re-enable AutoRotate when not aiming to restore normal movement-based rotation
		humanoid.AutoRotate = true
	end
end

-- Continuously update the player's facing direction while aiming
game:GetService("RunService").RenderStepped:Connect(faceAimDirection)