local GenericToolHandler = require(game.StarterPlayer.StarterCharacterScripts.ClientWeaponLogic.ToolHandler)

local localWeapon = require(game.StarterPlayer.StarterCharacterScripts.ClientWeaponLogic.LocalWeapon)

-- Initialize the tool handler for this specific tool
local tool = script.Parent
local toolHandler = GenericToolHandler.new(tool, localWeapon)
