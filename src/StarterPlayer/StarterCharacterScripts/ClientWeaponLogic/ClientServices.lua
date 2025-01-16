local module = {
	equipped = nil,
}



function module:createMuzzleFlash(muzzlePosition)

	local flash = nil
	--TODO: add flash to correct position
	flash.Parent = module.equipped.Parent
	flash:Emit(10)
	game.Debris:AddItem(flash, 0.5)
end



local function drawLine(startPos, endPos)
	-- Create the attachment points
	local startAttachment = Instance.new("Attachment")
	local endAttachment = Instance.new("Attachment")

	-- Create a part to hold the attachments (invisible part)
	local rayPart = Instance.new("Part")
	rayPart.Anchored = true
	rayPart.CanCollide = false
	rayPart.Transparency = 1  -- Make the part invisible
	rayPart.Size = Vector3.new(0.1, 0.1, 0.1)
	rayPart.CFrame = CFrame.new(startPos)  -- Position the part at startPos
	rayPart.Parent = workspace

	-- Set up the attachments' positions
	startAttachment.Position = Vector3.new(0, 0, 0)
	startAttachment.Parent = rayPart
	endAttachment.Position = (endPos - startPos)  -- Relative to the start
	endAttachment.Parent = rayPart

	-- Create the beam
	local beam = Instance.new("Beam")
	beam.Attachment0 = startAttachment
	beam.Attachment1 = endAttachment
	beam.FaceCamera = true
	beam.Width0 = 0.2
	beam.Width1 = 0.2
	beam.Color = ColorSequence.new(Color3.fromRGB(255, 246, 123))  -- Yellow color
	beam.LightEmission = 1
	beam.Parent = rayPart

	-- Clean up the beam after a short delay
	game.Debris:AddItem(rayPart, 0.015)

end
return module
