AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

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

	self:SetMissileNoTarget( 2 )

	local Launcher = self:GetAttachment( self:LookupAttachment( "countermeasure" ) )

	if Launcher then
		self:CreateFlare( Launcher.Pos, Launcher.Ang:Forward(), 1200 )
	end

	self:EmitSound("lvs/diprip_countermeasure.wav",85,100,0.25)

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
	projectile:SetDamage( 3500 )
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
