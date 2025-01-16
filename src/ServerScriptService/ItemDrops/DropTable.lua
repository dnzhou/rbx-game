local Items = require(script.Parent.ItemList)
local PickupableItem = require(script.Parent.PickupableItem)

local module = {
	["Rig"] = {
		{["BasicMaterial"] = {['Quantity'] = 1, ["Rate"] = 0.6, }},
		{["BasicMaterial"] = {['Quantity'] = 1, ["Rate"] = 0.3, }},
		{["EngineeredMaterial"] = {['Quantity'] = 1, ["Rate"] = 0.2, }},
	},
	["RareRig"] = {
		{["ClassifiedMaterial"] = {['Quantity'] = 1, ["Rate"] = 0.5, }},
		{["PrototypeMaterial"] = {['Quantity'] = 1, ["Rate"] = 0.5, }},
		{["AnomalousMaterial"] = {['Quantity'] = 1, ["Rate"] = 0.5, }},
	},
}


function module:spawnDrops(entity)
	local entityName = tostring(entity)
	if not module[entityName] then
		warn("Entity not found: " .. entityName)
		return
	end
	
	local drops = {}
	for _, item in pairs(module[entityName]) do
		local name, value = next(item, nil)
		local rate = value["Rate"]
		local quantity = value["Quantity"]

		
		
		for i = 1, quantity do
			local chance = math.random(0, 1)
			if chance <= rate then
				local newItem = PickupableItem:New(name, entity.PrimaryPart.Position)
				table.insert(drops, newItem)
				print("created object")
			end

		end
		
	end
	--[[ not client then
		print("fire all clients to see interactable item")
	end]]
	return drops
end




return module
