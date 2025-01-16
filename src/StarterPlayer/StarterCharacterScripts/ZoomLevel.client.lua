local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local userInputService = game:GetService("UserInputService")

local minZoom = 10  -- Minimum distance or FieldOfView
local maxZoom = 100  -- Maximum distance or FieldOfView
local zoomStep = 5  -- How much to zoom in/out with each scroll

-- Set initial zoom level (if using FieldOfView)
camera.FieldOfView = 50  -- Adjust based on your preference

userInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseWheel then
		local newFOV = camera.FieldOfView - input.Position.Z * zoomStep
		-- Clamp the FieldOfView between minZoom and maxZoom
		camera.FieldOfView = math.clamp(newFOV, minZoom, maxZoom)
	end
end)