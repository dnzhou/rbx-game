

local module = {
	["BasicMaterial"] = {
		["Name"] = "Basic Material",
		["Rarity"] = "Common",
		["Value"] = 2,
		["Description"] = "Placeholder text",
	},
	["EngineeredMaterial"] = {
		["Name"] = "Engineered Material",
		["Rarity"] = "Engineered",
		["Value"] = 4,
		["Description"] = "Placeholder text",
	},
	["ClassifiedMaterial"] = {
		["Name"] = "Classified Material",
		["Rarity"] = "Classified",
		["Value"] = 7,
		["Description"] = "Placeholder text",
	},
	["PrototypeMaterial"] = {
		["Name"] = "Prototype Material",
		["Rarity"] = "Prototype",
		["Value"] = 11,
		["Description"] = "Placeholder text",
	},
	["AnomalousMaterial"] = {
		["Name"] = "Anomalous Material",
		["Rarity"] = "Anomalous",
		["Value"] = 16,
		["Description"] = "Placeholder text",
	},
}

function module:GetItem(name)
	if not module[name] then
		warn("This item does not exist")
		return
	end
	return module[name]
end

return module
