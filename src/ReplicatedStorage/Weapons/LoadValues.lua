local module = {}

function module:unpackArgs(args)
	return {
		nextShotReady = true,
		reloadTask = nil,

		damage = args.damage,
		firingPattern = args.pattern,
		spread = args.spread,
		reloadTime = args.reloadTime,
		ammoCount = args.magSize,
		magazineSize = args.magSize,
		tool = args.tool,
		spreadAmmo = args.spreadAmmo,
		fireType = args.fireType,
		aimMoveSpeed = args.aimMoveSpeed,
		velocity = args.velocity,
		acceleration = args.acceleration,
		blastRadius = args.blastRadius,
		
	}
end


return module
