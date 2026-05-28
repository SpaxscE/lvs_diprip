
ENT.Base = "lvs_wheeldrive_truckbase"

ENT.Spawnable			= false
ENT.AdminSpawnable		= false

ENT.AITEAM = 3

ENT.MaxHealth = 2000
ENT.MaxHealthEngine = 1500
ENT.MaxHealthFuelTank = 750

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

ENT.MinigunPitchMul = 1
ENT.MinigunYawMul = 1

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

function ENT:MinigunInRange( AimPos )
	local Pos, _ = self:GetMinigunPosition()

	local Angles = self:WorldToLocalAngles( (AimPos - Pos):Angle() )
	Angles:Normalize()

	return math.abs( Angles.y ) <= 22 and math.abs( Angles.p ) < 22
end

function ENT:MissileInRange( AimPos )
	local Pos, _ = self:GetMinigunPosition()

	local Angles = self:WorldToLocalAngles( (AimPos - Pos):Angle() )
	Angles:Normalize()

	return math.abs( Angles.y ) <= 45 and math.abs( Angles.p ) < 45
end

local MinigunAttachments = {
	[1] = {
		Muzzle = "minigun_barell_left",
		Shells = "minigun_shells_left",
	},
	[2] = {
		Muzzle = "minigun_barell_right",
		Shells = "minigun_shells_right",
	},
}

function ENT:GetMinigunPosition()
	local Pos = Vector(0,0,0)
	local Dir = Vector(0,0,0)

	for id, data in ipairs( MinigunAttachments ) do
		local Muzzle = self:GetAttachment( self:LookupAttachment( data.Muzzle ) )

		if not Muzzle then continue end

		Pos:Add( Muzzle.Pos )
		Dir:Add( Muzzle.Ang:Forward() )
	end

	Pos:Mul( 0.5 )
	Dir:Normalize()

	return Pos, Dir
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

			return true
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

		if not IsValid( base ) or base:GetSelectedWeapon() ~= 1 then return end

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
		local AimAng = Dir:Angle()

		local Pos, Ang = WorldToLocal( MuzzlePos, AimAng, MuzzlePos, MuzzleAng )

		local Rate = math.min( FrameTime() * 60, 0.99 )

		local CurYaw = base:GetPoseParameter("vehicle_weapon_yaw" )
		local DesYaw = base:WorldToLocalAngles( AimAng ).y

		local SwapSides = (CurYaw > 0 and DesYaw < -90) or (CurYaw < 0 and DesYaw > 90)

		if SwapSides then
			base:SetPoseParameter("vehicle_weapon_yaw", CurYaw - CurYaw * Rate )
		else
			base:SetPoseParameter("vehicle_weapon_yaw", CurYaw + Ang.y * Rate )
		end

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
		ent:EmitSound("lvs/overheat.wav")
	end
	self:AddWeapon( weapon )


	local weapon = {}
	weapon.Icon = Material("lvs/weapons/hmg.png")
	weapon.Ammo = 2200
	weapon.Delay = 0.05
	weapon.HeatRateUp = 0.25
	weapon.HeatRateDown = 1
	weapon.Attack = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( base ) or not IsValid( base.SNDTurretRAC ) then return end

		local AimPos = ent:GetEyeTrace().HitPos

		--fake windup
		if ent:GetHeat() < 0.05 then
			base.SNDTurretRAC:Stop()
			return
		end

		local InRange = base:MinigunInRange( AimPos )

		for id, data in ipairs( MinigunAttachments ) do
			local Muzzle = base:GetAttachment( base:LookupAttachment( data.Muzzle ) )
			local Shells = base:GetAttachment( base:LookupAttachment( data.Shells ) )

			if not Muzzle or not Shells then continue end

			local effectdata = EffectData()
			effectdata:SetOrigin( Shells.Pos )
			effectdata:SetAngles( Shells.Ang )
			util.Effect( "RifleShellEject", effectdata, true, true )

			local bullet = {}
			bullet.Src 	= Muzzle.Pos
			bullet.Dir 	= InRange and (AimPos - bullet.Src):GetNormalized() or Muzzle.Ang:Forward()
			bullet.Spread = Vector(0.06,0.06,0.06)
			bullet.TracerName = "lvs_diprip_hitscan_tracer_small"
			bullet.Force	= 4000
			bullet.Force1km	= 500
			bullet.HullSize 	= 15
			bullet.Damage	= 20
			bullet.Velocity = 60000
			bullet.Attacker 	= ent:GetDriver()
			ent:LVSFireBullet( bullet )

			local effectdata = EffectData()
			effectdata:SetOrigin( Muzzle.Pos )
			effectdata:SetNormal( Muzzle.Ang:Forward() )
			effectdata:SetEntity( ent )
			util.Effect( "lvs_muzzle", effectdata )
		end

		ent:TakeAmmo( 2 )

		base.SNDTurretRAC:Play()
	end
	weapon.StartAttack = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( base ) or not IsValid( base.SNDTurretRAC ) then return end

		base.SNDTurretRAC:Play()
	end
	weapon.FinishAttack = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( base ) or not IsValid( base.SNDTurretRAC ) then return end

		base.SNDTurretRAC:Stop()
	end
	weapon.OnThink = function( ent, active )
		local base = ent:GetVehicle()

		if not IsValid( base ) or base:GetSelectedWeapon() ~= 2 then return end

		base:SetPoseParameter("vehicle_minigun_spin", base:GetPoseParameter("vehicle_minigun_spin" ) + math.min( ent:GetHeat() * 10000, 2000 ) * FrameTime() )

		local Muzzle1 = base:GetAttachment( base:LookupAttachment( "minigun_barell_right" ) )
		local Muzzle2 = base:GetAttachment( base:LookupAttachment( "minigun_barell_left" ) )

		if not Muzzle1 or not Muzzle2 then return end

		local MuzzlePos = (Muzzle1.Pos + Muzzle2.Pos) * 0.5
		local MuzzleDir = (Muzzle1.Ang:Forward() + Muzzle2.Ang:Forward()):GetNormalized()
		local MuzzleAng = MuzzleDir:Angle()

		local AimPos = ent:GetEyeTrace().HitPos

		local StartPos = MuzzlePos

		local EndPos = AimPos

		local Dir = (EndPos - StartPos):GetNormalized()
		local AimAng = Dir:Angle()

		local Pos, Ang = WorldToLocal( MuzzlePos, AimAng, MuzzlePos, MuzzleAng )

		local Rate = math.min( FrameTime() * 60, 0.99 )

		base:SetPoseParameter("vehicle_minigun_yaw", base:GetPoseParameter("vehicle_minigun_yaw" ) + Ang.y * Rate * base.MinigunYawMul  )
		base:SetPoseParameter("vehicle_minigun_pitch", base:GetPoseParameter("vehicle_minigun_pitch" ) + Ang.p * Rate * base.MinigunPitchMul )
	end
	weapon.HudPaint = function( ent, X, Y, ply )
		local base = ent:GetVehicle()

		if not IsValid( base ) then return end

		local AimPos = ent:GetEyeTrace().HitPos

		local Col = base:MinigunInRange( AimPos ) and COLOR_WHITE or COLOR_RED

		local Pos2D = AimPos:ToScreen()

		base:PaintCrosshairOuter( Pos2D, Col )
		base:LVSPaintHitMarker( Pos2D )
	end
	weapon.OnOverheat = function( ent )
		ent:EmitSound("lvs/vehicles/222/cannon_overheat.wav")
	end
	self:AddWeapon( weapon )


	local weapon = {}
	weapon.Icon = Material("lvs/weapons/missile.png")
	weapon.Ammo = 16
	weapon.Delay = 0 -- this will turn weapon.Attack to a somewhat think function
	weapon.HeatRateUp = -0.5 -- cool down when attack key is held. This system fires on key-release.
	weapon.HeatRateDown = 0.25
	weapon.Attack = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( base ) then return end

		local T = CurTime()

		if IsValid( ent._Missile ) then
			if (ent._nextMissleTracking or 0) > T then return end

			ent._nextMissleTracking = T + 0.1 -- 0.1 second interval because those find functions can be expensive

			if base:MissileInRange( ent:GetEyeTrace().HitPos ) then
				ent._Missile:FindTarget( ent:GetPos(), ent:GetAimVector(), 30, 7500 )
			else
				ent._Missile:FindTarget( ent:GetPos(), ent:GetForward(), 30, 7500 )
			end

			return
		end

		local T = CurTime()

		if (ent._nextMissle or 0) > T then return end

		ent._nextMissle = T + 0.5

		ent._swapMissile = not ent._swapMissile

		local Rocket = base:GetAttachment( base:LookupAttachment( ent._swapMissile and "rocket_barell_left" or "rocket_barell_right" ) )

		if not Rocket then return end

		local Driver = self:GetDriver()

		local projectile = ents.Create( "lvs_missile" )
		projectile:SetPos( Rocket.Pos )
		projectile:SetAngles( Rocket.Ang )
		projectile:SetParent( ent )
		projectile:Spawn()
		projectile:Activate()
		projectile:SetSpeed( 1000 + self:GetVelocity():Length() )
		projectile:SetDamage( 2000 )
		projectile:SetAttacker( IsValid( Driver ) and Driver or self )
		projectile:SetEntityFilter( ent:GetCrosshairFilterEnts() )

		ent._Missile = projectile

		ent:SetNextAttack( CurTime() + 0.1 ) -- wait 0.1 second before starting to track
	end
	weapon.FinishAttack = function( ent )
		local base = ent:GetVehicle()

		if not IsValid( ent._Missile ) or not IsValid( base ) then return end

		local projectile = ent._Missile

		if not IsValid( projectile:GetTarget() ) then
			local Target = ent:GetEyeTrace().HitPos

			if base:MissileInRange( Target ) then
				projectile.GetTarget = function( missile ) return missile end
				projectile.GetTargetPos = function( missile )
					if missile.HasReachedTarget then
						return missile:LocalToWorld( Vector(100,0,0) )
					end

					if (missile:GetPos() - Target):Length() < 100 then
						missile.HasReachedTarget = true
					end
					return Target
				end
			end
		end
		projectile:Enable()
		projectile:EmitSound( "lvs/diprip_rocket.wav", 125 )

		ent:TakeAmmo()

		ent._Missile = nil

		local NewHeat = ent:GetHeat() + 0.25

		ent:SetHeat( NewHeat )
		if NewHeat >= 1 then
			ent:SetOverheated( true )
		end
	end
	weapon.HudPaint = function( ent, X, Y, ply )
		local base = ent:GetVehicle()

		if not IsValid( base ) then return end

		local AimPos = ent:GetEyeTrace().HitPos

		local Col = base:MissileInRange( AimPos ) and COLOR_WHITE or COLOR_RED

		local Pos2D = AimPos:ToScreen()

		base:PaintCrosshairSquare( Pos2D, Col )
		base:LVSPaintHitMarker( Pos2D )
	end
	self:AddWeapon( weapon )




	local weapon = {}
	weapon.Icon = Material("lvs/weapons/bomb.png")
	weapon.Ammo = 32
	weapon.Delay = 2
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 1
	weapon.StartAttack = function( ent )
	
		if self:GetAI() then return end

		self:MakeProjectile()
	end
	weapon.FinishAttack = function( ent )
		if self:GetAI() then return end

		self:FireProjectile()
	end
	weapon.Attack = function( ent )
		if not self:GetAI() then return end

		self:MakeProjectile()
		self:FireProjectile()
	end
	weapon.HudPaint = function( ent, X, Y, ply )
		local Pos2D = ent:GetEyeTrace().HitPos:ToScreen()

		ent:LVSPaintHitMarker( Pos2D )
	end
	weapon.OnThink = function( ent, active )
		local base = ent:GetVehicle()

		if not IsValid( base ) or base:GetSelectedWeapon() ~= 4 then return end

		local Attachment = base:GetAttachment( base:LookupAttachment( "mortar_ref" ) )

		if not Attachment then return end

		local Dir = (ent:GetEyeTrace().HitPos - Attachment.Pos):GetNormalized()
		local Ang = self:WorldToLocalAngles( Dir:Angle() )

		base:SetPoseParameter("vehicle_mortar_yaw", Ang.y )
		base:SetPoseParameter("vehicle_mortar_pitch", -Ang.p + 15 )
	end
	self:AddWeapon( weapon )
end
