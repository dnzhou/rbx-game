
local module = {}
module.__index = module

function module:New(delayTime, burstSize, burstDelay)
	self = setmetatable({}, module)
	
	self.delayTime = delayTime
	self.lastShot = 0
	self.burstSize = burstSize
	self.burstDelay = burstDelay
	return self
end


function module:nextShotReady()
	local now = tick()
	if now - self.lastShot >= self.delayTime then
		self.lastShot = now
		return true
	end
	return false
end


return module
