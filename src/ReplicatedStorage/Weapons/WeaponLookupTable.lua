local projectiles = game:GetService("ReplicatedStorage").ProjectileModels
local anims = game.ReplicatedStorage.Weapons.WeaponAnims
local module = {

	["SingleShotLauncher"] = {
		model = projectiles.warhead3,
		animations = anims.Shouldered
	},
	["AutoGrenadeLauncher"] = {
		model = projectiles.Grenade,
		animations = anims.Rifle
	},
	["BurstRifle"] = {
		animations = anims.Rifle
	},
	["BasicRifle"] = {
		animations = anims.Rifle
	},
	["BasicPistol"] = {
		animations = anims.Handgun
	},
	["BasicShotgun"] = {
		animations = anims.Rifle
	},
	
}

return module
