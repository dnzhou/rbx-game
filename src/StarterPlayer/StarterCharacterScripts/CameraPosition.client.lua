local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")

local cameraHeight = 50  -- Height above the player
local cameraDistance = 30 -- Distance behind the player (to create an angle)
local cameraAngle = 60    -- Angle of the camera in degrees

camera.CameraType = "Scriptable"

runService.RenderStepped:Connect(function()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local rootPart = player.Character.HumanoidRootPart

		-- Calculate the angled offset
		local angleRad = math.rad(cameraAngle)
		local cameraOffset = Vector3.new(cameraDistance * math.sin(angleRad), cameraHeight, cameraDistance * math.cos(angleRad))

		-- Set the camera's position and orientation
		camera.CFrame = CFrame.new(rootPart.Position + cameraOffset, rootPart.Position)
	end
end)