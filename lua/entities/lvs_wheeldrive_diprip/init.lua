AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:UpdateSkin()
	timer.Simple(0, function()
		if not IsValid( self ) then return end

		local TEAM = self:GetAITEAM()

		if TEAM == 1 then
			self:SetSkin( 1 )
		end
		if TEAM == 2 then
			self:SetSkin( 2 )
		end
		if TEAM == 3 then
			self:SetSkin( 0 )
		end
	end)
end

function ENT:AlignView( ply )
	if not IsValid( ply ) then return end

	timer.Simple( 0, function()
		if not IsValid( ply ) or not IsValid( self ) then return end

		local Ang = Angle(0,90,0)

		local pod = ply:GetVehicle()

		if self:GetDriver() == ply and IsValid( pod ) then
			Ang = pod:LocalToWorldAngles( Angle(0,90,0) )
			Ang.r = 0
		end

		ply:SetEyeAngles( Ang )
	end)
end

function ENT:DoMissileDistraction()
	if not self:CanDoMissileDistraction() then return end

	self:SetMissileNoTarget( 0.5 )

	local Launcher = self:GetAttachment( self:LookupAttachment( "countermeasure" ) )

	if Launcher then
		self:CreateFlare( Launcher.Pos, Launcher.Ang:Forward(), 1200 )
	end

	self:EmitSound("lvs/diprip_countermeasure.wav",85,100,0.25)

	if self:GetAI() then
		self:SetNextMissileDistraction( math.random(3,13) )

		return
	end

	self:SetNextMissileDistraction( 3 )
end

function ENT:OnTick()
	if self:GetUp().z > 0 then return end -- we are upside down...
	if self:GetVelocity():LengthSqr() > 50000 then return end -- we are somewhat stationary
	if self:WheelsOnGround() then return end -- wheels are on ground... are we in a looping upside down?

	local ThrusterFR = self:GetAttachment( self:LookupAttachment( "thruster_physics_fr" ) )
	local ThrusterFL = self:GetAttachment( self:LookupAttachment( "thruster_physics_fl" ) )
	local ThrusterRR = self:GetAttachment( self:LookupAttachment( "thruster_physics_rr" ) )
	local ThrusterRL = self:GetAttachment( self:LookupAttachment( "thruster_physics_rl" ) )

	if not ThrusterFR or not ThrusterFL or not ThrusterRR or not ThrusterRL then return end

	local PhysObj = self:GetPhysicsObject()
	local ply = self:GetDriver()

	if not IsValid( PhysObj ) or not IsValid( ply ) then return end

	local ForceFront = ply:lvsKeyDown( "CAR_THROTTLE" ) and 1 or 0
	local ForceRear = ply:lvsKeyDown( "CAR_BRAKE" ) and 1 or 0
	local ForceLeft = ply:lvsKeyDown( "CAR_STEER_LEFT" ) and 1 or 0
	local ForceRight = ply:lvsKeyDown( "CAR_STEER_RIGHT" ) and 1 or 0

	local Force = PhysObj:GetMass() * FrameTime() * 1000

	local ThrustFR = (ForceFront + ForceRight) * Force
	local ThrustFL = (ForceFront + ForceLeft) * Force
	local ThrustRR = (ForceRear + ForceRight) * Force
	local ThrustRL = (ForceRear + ForceLeft) * Force

	PhysObj:ApplyForceOffset( -ThrusterFR.Ang:Up() * ThrustFR, ThrusterFR.Pos )
	PhysObj:ApplyForceOffset( -ThrusterFL.Ang:Up() * ThrustFL, ThrusterFL.Pos )
	PhysObj:ApplyForceOffset( -ThrusterRR.Ang:Up() * ThrustRR, ThrusterRR.Pos )
	PhysObj:ApplyForceOffset( -ThrusterRL.Ang:Up() * ThrustRL, ThrusterRL.Pos )

	local T = CurTime()

	if (self._NextThrustEffect or 0) > T then return end

	local Flags = {
		[1] = ThrustFR ~= 0,
		[2] = ThrustFL ~= 0,
		[3] = ThrustRR ~= 0,
		[4] = ThrustRL ~= 0,
	}

	for flag, active in pairs( Flags ) do
		if not active then continue end

		local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetEntity( self )
		effectdata:SetFlags( flag )
		util.Effect( "lvs_diprip_thruster", effectdata, true, true )

		self._NextThrustEffect = T + 1.5
	end
end

function ENT:MakeProjectile()
	local ID = self:LookupAttachment( "mortar" )
	local Muzzle = self:GetAttachment( ID )

	if not Muzzle then return end

	local Driver = self:GetDriver()

	local projectile = ents.Create( "lvs_bomb" )
	projectile:SetPos( Muzzle.Pos + Muzzle.Ang:Forward() * 15 )
	projectile:SetAngles( Muzzle.Ang )
	projectile:SetParent( self, ID )
	projectile:Spawn()
	projectile:Activate()
	projectile:SetModel("models/misc/88mm_projectile.mdl")
	projectile:SetAttacker( IsValid( Driver ) and Driver or self )
	projectile:SetEntityFilter( self:GetCrosshairFilterEnts() )
	projectile:SetSpeed( Muzzle.Ang:Forward() * (1000 + self:GetVelocity():Length()) )
	projectile:SetDamage( 4000 )
	projectile:SetRadius( 250 )
	projectile.UpdateTrajectory = function( bomb )
		bomb:SetSpeed( bomb:GetForward() * (1000 + self:GetVelocity():Length()) )
	end

	if projectile.SetMaskSolid then
		projectile:SetMaskSolid( true )
	end

	projectile.ExplosionEffect = "lvs_diprip_explosion"

	self._ProjectileEntity = projectile
end

function ENT:FireProjectile()
	local ID = self:LookupAttachment( "mortar" )
	local Muzzle = self:GetAttachment( ID )

	if not Muzzle or not IsValid( self._ProjectileEntity ) then return end

	self._ProjectileEntity:Enable()
	self._ProjectileEntity:SetCollisionGroup( COLLISION_GROUP_NONE )
	self._ProjectileEntity:EmitSound( "lvs/diprip_mortar.wav", 125 )

	local effectdata = EffectData()
		effectdata:SetOrigin( self._ProjectileEntity:GetPos() )
		effectdata:SetEntity( self._ProjectileEntity )
	util.Effect( "lvs_concussion_trail", effectdata )

	self:TakeAmmo()
	self:SetHeat( 1 )
	self:SetOverheated( true )

	self._ProjectileEntity = nil
end

function ENT:RunAI()
	local Pod = self:GetDriverSeat()

	if not IsValid( Pod ) then self:SetAI( false ) return end

	local RangerLength = 25000

	local Target = self:AIGetTarget( 180 )

	local StartPos = Pod:LocalToWorld( Pod:OBBCenter() )

	local GotoPos, GotoDist = self:AIGetMovementTarget()

	local TargetPos = GotoPos

	local T = CurTime()

	local IsTargetValid = IsValid( Target )

	local TraceFilter = self:GetCrosshairFilterEnts()

	local Front = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos + Pod:GetForward() * RangerLength } )
	local FrontLeft = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos - Pod:LocalToWorldAngles( Angle(0,15,0) ):Right() * RangerLength } )
	local FrontRight = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos - Pod:LocalToWorldAngles( Angle(0,-15,0) ):Right() * RangerLength } )
	local FrontLeft1 = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos - Pod:LocalToWorldAngles( Angle(0,60,0) ):Right() * RangerLength } )
	local FrontRight1 = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos - Pod:LocalToWorldAngles( Angle(0,-60,0) ):Right() * RangerLength } )
	local FrontLeft2 = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos - Pod:LocalToWorldAngles( Angle(0,85,0) ):Right() * RangerLength } )
	local FrontRight2 = util.TraceLine( { start = StartPos, filter = TraceFilter, endpos = StartPos - Pod:LocalToWorldAngles( Angle(0,-85,0) ):Right() * RangerLength } )

	local traceWater = util.TraceLine( {
		start = Front.HitPos,
		endpos = Front.HitPos - Vector(0,0,50000),
		filter = self:GetCrosshairFilterEnts(),
		mask = MASK_WATER
	} )

	if traceWater.Hit then
		Front.HitPos = StartPos
	end

	GotoPos = (Front.HitPos + FrontLeft.HitPos + FrontRight.HitPos + FrontLeft1.HitPos + FrontRight1.HitPos + FrontLeft2.HitPos + FrontRight2.HitPos) / 7

	if IsTargetValid then
		GotoPos = (GotoPos + Target:GetPos()) * 0.5
	end

	if not self:GetEngineActive() then
		local Engine = self:GetEngine()

		if IsValid( Engine ) then
			if not Engine:GetDestroyed() then
				self:StartEngine()
			end
		else
			self:StartEngine()
		end
	end

	if self:GetReverse() then
		if Front.Fraction < 0.03 then
			GotoPos = StartPos - Pod:GetForward() * 1000
		end
	else
		if Front.Fraction < 0.01 then
			GotoPos = StartPos - Pod:GetForward() * 1000
		end
	end

	local TargetPosLocal = Pod:WorldToLocal( GotoPos )
	local Throttle = math.min( math.max( TargetPosLocal:Length() - GotoDist, 0 ) / 10, 1 )

	self:PhysWake()

	self:SetPivotSteer( 0 )

	if self:IsLegalInput() then
		self:LerpThrottle( Throttle )

		if Throttle == 0 then
			self:LerpBrake( 1 )
		else
			self:LerpBrake( 0 )
		end
	else
		self:LerpThrottle( 0 )
		self:LerpBrake( Throttle )
	end

	self:SetReverse( TargetPosLocal.y < 0 )

	self:ApproachTargetAngle( Pod:LocalToWorldAngles( (GotoPos - self:GetPos()):Angle() ) )

	self:ReleaseHandbrake()

	self._AIFireInput = false

	if IsValid( self:GetHardLockTarget() ) then
		Target = self:GetHardLockTarget()

		TargetPos = Target:LocalToWorld( Target:OBBCenter() )

		self._AIFireInput = true
	else
		if IsValid( Target ) then
			local PhysObj = Target:GetPhysicsObject()
			if IsValid( PhysObj ) then
				TargetPos = Target:LocalToWorld( PhysObj:GetMassCenter() )
			else
				TargetPos = Target:LocalToWorld( Target:OBBCenter() )
			end

			self._AIFireInput = math.cos( CurTime() * 2 + self:EntIndex() * 1.337 ) > -0.5

			local CurHeat = self:GetNWHeat()
			local CurWeapon = self:GetSelectedWeapon()

			if CurWeapon > 2 then
				self:AISelectWeapon( 1 )
			else
				if CurHeat < 0.9 then
					if CurWeapon == 1 then
						self:AISelectWeapon( math.random(2,3) )

					else
						self:AISelectWeapon( 1 )
					end
				else
					if CurHeat == 0 and math.cos( CurTime() ) > 0 then
						self:AISelectWeapon( 1 )
					end
				end
			end
		end
	end

	T = T + self:EntIndex() * 1.337

	self:SetAIAimVector( (TargetPos + Vector(0,math.sin( T * 0.5 ) * 30,math.cos( T * 2 ) * 30) - StartPos):GetNormalized() )
end
