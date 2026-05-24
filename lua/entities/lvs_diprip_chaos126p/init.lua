AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")

function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat( Vector(-25,0,17), Angle(0,-90,0) )
	DriverSeat.HidePlayer = true
	DriverSeat:SetCameraDistance( 0.3 )

	self:AddEngine( Vector(40,0,0) )
	self:AddFuelTank( Vector(-60,0,-15), Angle(0,0,0), 3600, LVS.FUELTYPE_PETROL )

	local ID = self:LookupAttachment( "machinegun_ref" )
	local Muzzle = self:GetAttachment( ID )
	self.SNDTurretMG = self:AddSoundEmitter( self:WorldToLocal( Muzzle.Pos ), "lvs/diprip_machinegun_loop.wav", "lvs/diprip_machinegun_loop.wav" )
	self.SNDTurretMG:SetSoundLevel( 95 )
	self.SNDTurretMG:SetParent( self, ID )

	self.SNDTurretRAC = self:AddSoundEmitter( Vector(65,0,15), "lvs/diprip_minigun_loop.wav", "lvs/diprip_minigun_loop.wav" )
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

	self:UpdateSkin()
end
