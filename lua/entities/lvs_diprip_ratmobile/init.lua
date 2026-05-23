AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat( Vector(-40,0,0), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true

	self:AddFuelTank( Vector(-75,0,-5), Angle(0,0,0), 3600, LVS.FUELTYPE_PETROL )

	local Engine = self:AddEngine( Vector(25,0,0) )
	Engine:SetMaxHP( 200 )
	Engine:SetHP( 200 )

	local ID = self:LookupAttachment( "machinegun_ref" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/diprip_machinegun_loop.wav", "lvs/diprip_machinegun_loop.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID )

	self.SNDTurretRAC = self:AddSoundEmitter( Vector(50,0,3), "lvs/diprip_minigun_loop.wav", "lvs/diprip_minigun_loop.wav" )
	self.SNDTurretRAC:SetSoundLevel( 95 )

	self:AddRacingTires()

	local FrontRadius = 20
	local RearRadius = 20
	local FL, FR, RL, RR, ForwardAngle = self:AddWheelsUsingRig( FrontRadius, RearRadius )
	FL:SetWidth( 7 )
	FL:SetWheelChainMode( true )
	FR:SetWidth( 7 )
	FR:SetWheelChainMode( true )
	RL:SetWidth( 7 )
	RL:SetWheelChainMode( true )
	RR:SetWidth( 7 )
	RR:SetWheelChainMode( true )

	local FrontAxle = self:DefineAxle( {
		Axle = {
			ForwardAngle = ForwardAngle,
			SteerType = LVS.WHEEL_STEER_FRONT,
			SteerAngle = 40,
			TorqueFactor = 0.4,
			BrakeFactor = 1,
		},
		Wheels = {FL,FR},
		Suspension = {
			Height = 10,
			MaxTravel = 40,
			ControlArmLength = 250,
			SpringConstant = 50000,
			SpringDamping = 1800,
			SpringRelativeDamping = 1800,
		},
	} )

	local RearAxle = self:DefineAxle( {
		Axle = {
			ForwardAngle = ForwardAngle,
			SteerType = LVS.WHEEL_STEER_NONE,
			TorqueFactor = 0.6,
			BrakeFactor = 1,
			UseHandbrake = true,
		},
		Wheels = {RL,RR},
		Suspension = {
			Height = 10,
			MaxTravel = 40,
			ControlArmLength = 250,
			SpringConstant = 50000,
			SpringDamping = 1800,
			SpringRelativeDamping = 1800,
		},
	} )
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

	self:SetMissileNoTarget( 2 )

	self:CreateFlare( self:LocalToWorld( Vector(-92.31,-31.81,25.15) ), self:LocalToWorldAngles( Angle(-15,0,0) ):Up(), 1200 )

	self:EmitSound("lvs/diprip_countermeasure.wav",85,100,0.25)

	self:SetNextMissileDistraction( 3 )
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
