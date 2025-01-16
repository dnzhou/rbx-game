-----------------
--| Constants |--
-----------------

local GRAVITY_ACCELERATION = workspace.Gravity

local RELOAD_TIME = 3 -- Seconds until tool can be used again
local ROCKET_SPEED = 60 -- Speed of the projectile

local MISSILE_MESH_ID = 'http://www.roblox.com/asset/?id=2251534'
local MISSILE_MESH_SCALE = Vector3.new(0.35, 0.35, 0.25)
local ROCKET_PART_SIZE = Vector3.new(1.2, 1.2, 3.27)

-----------------
--| Variables |--
-----------------

local DebrisService = game:GetService('Debris')
local PlayersService = game:GetService('Players')

local MyPlayer

local Tool = script.Parent
local ToolHandle = Tool:WaitForChild("Handle")

local MouseLoc = Tool:WaitForChild("MouseLoc",10)

local RocketScript = script:WaitForChild('Rocket')
local SwooshSound = script:WaitForChild('Swoosh')
local BoomSound = script:WaitForChild('Boom')

--NOTE: We create the rocket once and then clone it when the player fires
local Rocket = Instance.new('Part') do
	-- Set up the rocket part
	Rocket.Name = 'Rocket'
	Rocket.FormFactor = Enum.FormFactor.Custom --NOTE: This must be done before changing Size
	Rocket.Size = ROCKET_PART_SIZE
	Rocket.CanCollide = false

	-- Add the mesh
	local mesh = Instance.new('SpecialMesh', Rocket)
	mesh.MeshId = MISSILE_MESH_ID
	mesh.Scale = MISSILE_MESH_SCALE

	-- Add fire
	local fire = Instance.new('Fire', Rocket)
	fire.Heat = 5
	fire.Size = 2

	-- Add a force to counteract gravity
	local bodyForce = Instance.new('BodyForce', Rocket)
	bodyForce.Name = 'Antigravity'
	bodyForce.Force = Vector3.new(0, Rocket:GetMass() * GRAVITY_ACCELERATION, 0)

	-- Clone the sounds and set Boom to PlayOnRemove
	local swooshSoundClone = SwooshSound:Clone()
	swooshSoundClone.Parent = Rocket
	local boomSoundClone = BoomSound:Clone()
	boomSoundClone.PlayOnRemove = true
	boomSoundClone.Parent = Rocket

	-- Attach creator tags to the rocket early on
	local creatorTag = Instance.new('ObjectValue', Rocket)
	creatorTag.Value = MyPlayer
	creatorTag.Name = 'creator' --NOTE: Must be called 'creator' for website stats
	local iconTag = Instance.new('StringValue', creatorTag)
	iconTag.Value = Tool.TextureId
	iconTag.Name = 'icon'

	-- Finally, clone the rocket script and enable it
	local rocketScriptClone = RocketScript:Clone()
	rocketScriptClone.Parent = Rocket
	rocketScriptClone.Disabled = false
end

-----------------
--| Functions |--
-----------------

local function OnActivated()
	local myModel = MyPlayer.Character
	if Tool.Enabled and myModel and myModel:FindFirstChildOfClass("Humanoid") and myModel.Humanoid.Health > 0 then
		Tool.Enabled = false
		local Pos = MouseLoc:InvokeClient(MyPlayer)
		-- Create a clone of Rocket and set its color
		local rocketClone = Rocket:Clone()
		DebrisService:AddItem(rocketClone, 30)
		rocketClone.BrickColor = MyPlayer.TeamColor

		-- Position the rocket clone and launch!
		local spawnPosition = (ToolHandle.CFrame * CFrame.new(5, 0, 0)).p
		rocketClone.CFrame = CFrame.new(spawnPosition, Pos) --NOTE: This must be done before assigning Parent
		rocketClone.Velocity = rocketClone.CFrame.lookVector * ROCKET_SPEED --NOTE: This should be done before assigning Parent
		rocketClone.Parent = workspace
		rocketClone:SetNetworkOwner(nil)

		wait(RELOAD_TIME)

		Tool.Enabled = true
	end
end

function OnEquipped()
	MyPlayer = PlayersService:GetPlayerFromCharacter(Tool.Parent)
end

--------------------
--| Script Logic |--
--------------------

Tool.Equipped:Connect(OnEquipped)
Tool.Activated:Connect(OnActivated)
