local cleanup = require(game.ReplicatedStorage.Weapons.FiringBehavior.RaycastIgnore)
local ItemDrop = require(script.Parent.ItemDrops.DropTable)
local module = {
	enemies = {},
	pickupItems = {}
}



function module:dealDamage(object, damage)
	if object then
		if object:IsA("Humanoid") and object.Health > 0 then
			object:TakeDamage(damage)
			if object.Health <= 0 then
				--print(object)
				cleanup:onHumanoidDied(object)
				local drops = ItemDrop:spawnDrops(object.Parent)
				if not drops then return end
				for item in drops do

					--game.ReplicatedStorage.Remotes.PickupItem:FireAllClients(ID, item, drops[item])
				end
				
				
				
			end
		end

	end

end




return module
