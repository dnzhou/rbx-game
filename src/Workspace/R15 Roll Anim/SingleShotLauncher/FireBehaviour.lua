local loadValues = require(game.ReplicatedStorage.Weapons.LoadValues)
local wValues = require(game.ReplicatedStorage.Weapons.FiringBehavior.WeaponValues)
local weapon = {
	
}

weapon = loadValues:unpackArgs(table.unpack(wValues["ProjectileWeapons"][script.Parent.Name]))


return weapon
