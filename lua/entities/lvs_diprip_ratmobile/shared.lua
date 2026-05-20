
ENT.Base = "lvs_wheeldrive_truckbase"

ENT.PrintName = "Ratmobile"
ENT.Author = "Luna"
ENT.Information = "Luna's Vehicle Script"
ENT.Category = "[LVS] - D.I.P.R.I.P"

ENT.VehicleCategory = "Cars"
ENT.VehicleSubCategory = "Armored"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/ratmobile/ratmobile.mdl"

ENT.AITEAM = 3

ENT.MaxHealth = 2000

ENT.MaxVelocity = 2250
ENT.MaxVelocityReverse = 1000

ENT.PhysicsWeightScale = 1.8

ENT.EngineTorque = 325
ENT.EngineCurve = 0.25
ENT.EngineCurveBoostLow = 1

ENT.EngineRevLimited = false
 
ENT.SteerSpeed = 1.5
ENT.SteerReturnSpeed = 8

ENT.FastSteerActiveVelocity = 650
ENT.FastSteerAngleClamp = 20
ENT.FastSteerDeactivationDriftAngle = 7

ENT.ThrottleRate = 3
ENT.BrakeRate = 10

ENT.EngineIdleRPM = 1000
ENT.EngineMaxRPM = 6000

ENT.WheelBrakeForce = 600

ENT.WheelBrakeLockupRPM = 18
ENT.WheelBrakeApplySound = "LVS.Brake.Apply"
ENT.WheelBrakeReleaseSound = "LVS.Brake.Release"

ENT.MassCenterOverride = Vector(0,0,20)

ENT.PhysicsInertia = Vector(2000,2000,1000)
ENT.PhysicsDampingSpeed = 4000
ENT.PhysicsDampingForward = true
ENT.PhysicsDampingReverse = false

ENT.WheelPhysicsMass = 100
ENT.WheelPhysicsInertia = Vector(14,10,14)
ENT.WheelPhysicsTireHeight = 10

ENT.WheelSideForce = 3000
ENT.WheelDownForce = 1000

ENT.TransGears = 4
ENT.TransGearsReverse = 1
ENT.TransShiftSpeed = 0.65
ENT.TransShiftTorqueFactor = 0.2
ENT.TransMinGearHoldTime = 1

ENT.EngineSounds = {
	{
		sound = "lvs/ratmobile/engine_idle.wav",
		Volume = 0.5,
		Pitch = 100,
		PitchMul = 25,
		SoundLevel = 75,
		SoundType = LVS.SOUNDTYPE_IDLE_ONLY,
	},
	{
		sound = "lvs/ratmobile/engine_loop.wav",
		Volume = 1,
		Pitch = 70,
		PitchMul = 60,
		SoundLevel = 75,
		UseDoppler = true,
	},
}

ENT.ExhaustPositions = {
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(6.54,44.25,13.19),
		ang = Angle(-105,0,0)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-1.85,44.15,14.79),
		ang = Angle(-105,0,0)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-9.87,44.49,16.03),
		ang = Angle(-105,0,0)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(6.54,-44.25,13.19),
		ang = Angle(-105,0,0)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-1.85,-44.15,14.79),
		ang = Angle(-105,0,0)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-9.87,-44.49,16.03),
		ang = Angle(-105,0,0)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-92.45,20.94,-6.35),
		ang = Angle(-180,0,0)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-92.45,-20.94,-6.35),
		ang = Angle(-180,0,0)
	},
}

function ENT:GetAimVector()
	if self:GetAI() then
		return self:GetAIAimVector()
	end

	local pod = self:GetDriverSeat()

	if not IsValid( pod ) then return self:GetForward() end

	local Driver = self:GetDriver()

	if not IsValid( Driver ) then return pod:GetForward() end

	if SERVER then
		return pod:WorldToLocalAngles( Driver:EyeAngles() ):Forward()
	else
		return Driver:EyeAngles():Forward()
	end
end

function ENT:MachinegunInRange( AimPos )
	local Attachment = self:GetAttachment( self:LookupAttachment( "machinegun_ref" ) )

	if not Attachment then return false end

	local Angles = self:WorldToLocalAngles( (AimPos - Attachment.Pos):Angle() )
	Angles:Normalize()

	return math.abs( Angles.y ) <= 155 and math.abs( Angles.p ) < 20
end

function ENT:InitWeapons()
	local COLOR_RED = Color(255,0,0,255)
	local COLOR_WHITE = Color(255,255,255,255)

	local weapon = {}
	weapon.Icon = Material("lvs/weapons/mg.png")
	weapon.Ammo = 9000
	weapon.Delay = 0.1
	weapon.HeatRateUp = 0.05
	weapon.HeatRateDown = 0.5
	weapon.Attack = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( base ) then return end

		local SwapMuzzle = base._SwapMuzzle and "machinegun_barell_left" or "machinegun_barell_right"

		local Muzzle = base:GetAttachment( base:LookupAttachment( SwapMuzzle ) )

		local AimPos = ent:GetEyeTrace().HitPos
	
		if not base:MachinegunInRange( AimPos ) then
			if IsValid( base.SNDTurretMG ) then
				base.SNDTurretMG:Stop()
			end

			return
		end

		if not Muzzle then return end

		local Shells = base:GetAttachment( base:LookupAttachment( "machinegun_shells" ) )

		if Shells then
			local effectdata = EffectData()
			effectdata:SetOrigin( Shells.Pos )
			effectdata:SetAngles( Shells.Ang )
			util.Effect( "RifleShellEject", effectdata, true, true )
		end

		local bullet = {}
		bullet.Src 	= Muzzle.Pos
		bullet.Dir 	= (AimPos - bullet.Src):GetNormalized()
		bullet.Spread = Vector(0.01,0.01,0.01)
		bullet.TracerName = "lvs_diprip_hitscan_tracer"
		bullet.Force	= 10
		bullet.HullSize 	= 0
		bullet.Damage	= 25
		bullet.Velocity = 60000
		bullet.Attacker 	= ent:GetDriver()
		ent:LVSFireBullet( bullet )

		local effectdata = EffectData()
		effectdata:SetOrigin( Muzzle.Pos )
		effectdata:SetNormal( Muzzle.Ang:Forward() )
		effectdata:SetEntity( ent )
		util.Effect( "lvs_muzzle", effectdata )

		ent:TakeAmmo( 1 )

		base._SwapMuzzle = not base._SwapMuzzle

		if not IsValid( base.SNDTurretMG ) then return end

		base.SNDTurretMG:Play()
	end
	weapon.StartAttack = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( base ) or not IsValid( base.SNDTurretMG ) then return end

		base.SNDTurretMG:Play()
	end
	weapon.FinishAttack = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( base ) or not IsValid( base.SNDTurretMG ) then return end

		base.SNDTurretMG:Stop()
	end
	weapon.OnThink = function( ent, active )
		local base = ent:GetVehicle()

		if not IsValid( base ) then return end

		local Muzzle1 = base:GetAttachment( base:LookupAttachment( "machinegun_barell_right" ) )
		local Muzzle2 = base:GetAttachment( base:LookupAttachment( "machinegun_barell_left" ) )

		if not Muzzle1 or not Muzzle2 then return end

		local MuzzlePos = (Muzzle1.Pos + Muzzle2.Pos) * 0.5
		local MuzzleDir = (Muzzle1.Ang:Forward() + Muzzle2.Ang:Forward()):GetNormalized()
		local MuzzleAng = MuzzleDir:Angle()

		local AimPos = ent:GetEyeTrace().HitPos
	
		local StartPos = MuzzlePos

		local EndPos = AimPos

		local Dir = (EndPos - StartPos):GetNormalized()

		local Pos, Ang = WorldToLocal( MuzzlePos, Dir:Angle(), MuzzlePos, MuzzleAng )

		local Rate = math.min( FrameTime() * 60, 0.99 )

		base:SetPoseParameter("vehicle_weapon_yaw", base:GetPoseParameter("vehicle_weapon_yaw" ) + Ang.y * Rate )
		base:SetPoseParameter("vehicle_weapon_pitch", base:GetPoseParameter("vehicle_weapon_pitch" ) - Ang.p * Rate )
	end
	weapon.HudPaint = function( ent, X, Y, ply )
		local base = ent:GetVehicle()

		if not IsValid( base ) then return end

		local AimPos = ent:GetEyeTrace().HitPos
		local Pos2D = AimPos:ToScreen()

		local Col = base:MachinegunInRange( AimPos ) and COLOR_WHITE or COLOR_RED

		base:PaintCrosshairCenter( Pos2D, Col )
		base:LVSPaintHitMarker( Pos2D )
	end
	weapon.OnOverheat = function( ent )
	end
	self:AddWeapon( weapon )
end
