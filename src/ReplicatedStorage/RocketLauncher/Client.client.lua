local Tool = script.Parent

local Remote = Tool:WaitForChild("MouseLoc")

local Mouse = game.Players.LocalPlayer:GetMouse()

function Remote.OnClientInvoke()
	return Mouse.Hit.p
end