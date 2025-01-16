local Backpack = require(game.ReplicatedStorage.Backpack)
local PlayerID = game.Players.LocalPlayer.UserId

local Player = {
	Inventory = Backpack.new(PlayerID)
}

return Player
