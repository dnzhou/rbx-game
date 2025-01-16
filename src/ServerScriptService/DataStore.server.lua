local DataStoreService = game:GetService("DataStoreService")
local dataStore = DataStoreService:GetDataStore("Players")

game.Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Wait()

end)