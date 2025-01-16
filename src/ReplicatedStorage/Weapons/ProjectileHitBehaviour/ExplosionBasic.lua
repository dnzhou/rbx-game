local module = {}

module.__index = module

function module:new(warhead, trail)
	local self = setmetatable({}, module)
	self.warhead = warhead
	self.trail = trail
	
	
	
	
	
	return self

end

return module
