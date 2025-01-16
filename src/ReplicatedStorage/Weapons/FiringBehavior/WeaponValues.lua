--[[
This module stores weapon values

]]
local patternPath = game.ReplicatedStorage.Weapons.FiringBehavior.Patterns
local shotgunPattern = require(patternPath.Spread)
local basicPattern = require(patternPath.Basic) 
local burstPattern = require(patternPath.Burst)
local patternValues = require(game.ReplicatedStorage.Weapons.FiringBehavior.Patterns.WeaponPatternValues)
local toolPath = game.ReplicatedStorage.Weapons
local RunService = game:GetService("RunService")


local module = {

	["HitscanWeapons"] = {
		-- [1] damage | [2] pattern | [3] spread | [4] magSize | [5] reloadTime | [6] tool | [7] spreadAmmo | [8] fireType 
		-- [9] aimMoveSpeed
		["BasicShotgun"] = {
			damage = 15,
			pattern = nil,
			spread = 0.15,
			magSize = 8,
			reloadTime = 3,
			spreadAmmo = true,
			fireType = "hitscan",
			aimMoveSpeed = 0.6
		},
		["BasicPistol"] = {
			damage = 25,
			pattern = nil,
			spread = 0.1,
			magSize = 12,
			reloadTime = 2,
			spreadAmmo = false,
			fireType = "hitscan",
			aimMoveSpeed = 0.7
		},

		["BasicRifle"] = {
			damage = 20,
			pattern = nil,
			spread = 0.1,
			magSize = 30,
			reloadTime = 2.5,
			spreadAmmo = false,
			fireType = "hitscan",
			aimMoveSpeed = 0.6
		},
		["BurstRifle"] = {
			damage = 25,
			pattern = nil,
			spread = 0.05,
			magSize = 24,
			reloadTime = 2,
			spreadAmmo = false,
			fireType = "hitscan",
			aimMoveSpeed = 0.7

		}
	},
	["ProjectileWeapons"] = {
		-- [1] damage | [2] Fire Pattern | [3] spread | [4] magSize | [5] reloadTime | [6] tool | [7] Spread Ammo | [8] Fire Type 
		-- [9] aimMoveSpeed | [10]Velocity | [11] Acceleration [12] Blast Radius 
		["HEGrenade"] = {
			damage = 100,
			pattern = nil,
			spread = 0,
			magSize = 1,
			reloadTime = 10,
			spreadAmmo = false,
			fireType = "projectile",
			aimMoveSpeed = 1,
			velocity = 10,
			acceleration = Vector3.new(0,-0.1,0),
			blastRadius = 10,

			
		},
		["SingleShotLauncher"] = {
			damage = 150,
			pattern = nil,
			spread = 0,
			magSize = 1,
			reloadTime = 2,
			spreadAmmo = false,
			fireType = "projectile",
			aimMoveSpeed = 0.4,
			velocity = 100,
			acceleration = Vector3.new(0,0,0),
			blastRadius = 25,

			
		},
		["AutoGrenadeLauncher"] = {
			damage = 60,
			pattern = nil,
			spread = 0,
			magSize = 6,
			reloadTime = 3,
			spreadAmmo = false,
			fireType = "projectile",
			aimMoveSpeed = 0.6,
			velocity = 100,
			acceleration = Vector3.new(0,-1,0),
			blastRadius = 15,

		}
	}

}
-- Load firing patterns
------------------- SPREAD -------------------------
module["HitscanWeapons"]["BasicShotgun"].pattern = shotgunPattern:New(table.unpack(patternValues["BasicShotgun"]))



------------------- BASIC -------------------------
module["HitscanWeapons"]["BasicPistol"].pattern = basicPattern:New(table.unpack(patternValues["BasicPistol"]))
module["HitscanWeapons"]["BasicRifle"].pattern = burstPattern:New(table.unpack(patternValues["BasicRifle"]))

module["ProjectileWeapons"]["SingleShotLauncher"].pattern = basicPattern:New(table.unpack(patternValues["SingleShotLauncher"]))
module["ProjectileWeapons"]["AutoGrenadeLauncher"].pattern = basicPattern:New(table.unpack(patternValues["AutoGrenadeLauncher"]))

------------------- BURST -------------------------
module["HitscanWeapons"]["BurstRifle"].pattern = basicPattern:New(table.unpack(patternValues["BurstRifle"]))




--------------------------

local function checkWeaponPatterns(weaponModule)

	for weaponName, weaponDetails in pairs(weaponModule["HitscanWeapons"]) do
		
		if not weaponDetails.pattern then
			warn("Error: " .. weaponName .. " has no pattern defined.")
		end
	end
	for weaponName, weaponDetails in pairs(weaponModule["ProjectileWeapons"]) do

		if not weaponDetails.pattern then
			warn("Error: " .. weaponName .. " has no pattern defined.")
		end
	end

end


if RunService:IsServer() then
	checkWeaponPatterns(module)

end



return module
