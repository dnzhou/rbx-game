local Inventory = {}
Inventory.__index = Inventory

-- Table to store the player's items
function Inventory.new()
	local self = setmetatable({
		items = {}
	}, Inventory)
	return self
end

-- Function to add an item to the backpack
function Inventory:AddItem(item)
	table.insert(self.items, item)
	print("Item added:", item.Name)
end

-- Function to remove an item from the backpack
function Inventory:RemoveItem(itemName)
	for i, item in ipairs(self.items) do
		if item.Name == itemName then
			table.remove(self.items, i)
			print("Item removed:", itemName)
			return
		end
	end
end

-- Function to get an item by name
function Inventory:GetItem(itemName)
	for _, item in ipairs(self.items) do
		if item.Name == itemName then
			return item
		end
	end
	return nil
end

-- Custom function example: Equip an item
function Inventory:EquipItem(itemName)
	local item = self:GetItem(itemName)
	if item then
		print("Equipping item:", item.Name)
		-- Custom logic for equipping item (e.g., parent to character)
	else
		print("Item not found:", itemName)
	end
end

-- Custom function example: Use an item
function Inventory:UseItem(itemName)
	local item = self:GetItem(itemName)
	if item then
		print("Using item:", item.Name)
		-- Custom logic for using item
	else
		print("Item not found:", itemName)
	end
end

function Inventory:GetInventory()
	return self.items
end

function Inventory:GetInventorySorted()
	
end



return Inventory