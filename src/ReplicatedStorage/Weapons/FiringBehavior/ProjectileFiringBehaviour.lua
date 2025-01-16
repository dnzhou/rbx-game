local RunService = game:GetService("RunService")

local fastCast = require(game.ReplicatedStorage.Weapons.FastCastRedux)


local module = {
	caster = fastCast.new(),
	castBehaviour = fastCast.newBehavior()
}

local castParams = RaycastParams.new()
castParams.FilterType = Enum.RaycastFilterType.Exclude
castParams.CollisionGroup = "Projectiles"

local castBehaviour = fastCast.newBehavior()
castBehaviour.RaycastParams = castParams
castBehaviour.AutoIgnoreContainer = true
castBehaviour.CosmeticBulletContainer = workspace.Projectiles

local function onLengthChanged(cast, lastPoint, direction, length, velocity, bullet)
	-- This function will be connected to the Caster's "LengthChanged" event.
	bullet.Position = lastPoint + (direction * length)
	

end


function module:FireProjectile(spread, startPos, targetPos, randSpread, projectileArgs, projectileModel)
	--local startPos = player.Character.HumanoidRootPart.Position
	local direction = (targetPos - startPos).unit

	if RunService:IsClient() then
		castBehaviour.CosmeticBulletTemplate = projectileModel
	end

	
	local fired = {
		player = projectileArgs.player,
		weapon = projectileArgs.toolName,
		blastRadius = projectileArgs.blastRadius
	}
	module.caster.UserData = fired
	module.caster:Fire(startPos, direction, projectileArgs.velocity, castBehaviour)
end

if RunService:IsClient() then
	module.caster.LengthChanged:Connect(onLengthChanged)
end


return module
