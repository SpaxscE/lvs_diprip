include("shared.lua")
include("entities/lvs_tank_wheeldrive/modules/cl_tankview.lua")

ENT.TireSoundTypes = {
	["roll"] = "lvs/vehicles/generic/wheel_roll.wav",
	["roll_racing"] = "lvs/vehicles/generic/heavywheel_roll.wav",
	["roll_dirt"] = "lvs/vehicles/generic/heavywheel_roll_dirt.wav",
	["roll_wet"] = "lvs/vehicles/generic/wheel_roll_wet.wav",
	["roll_damaged"] = "lvs/wheel_damaged_loop.wav",
	["skid"] = "lvs/vehicles/generic/wheel_skid_racing.wav", 
	["skid_racing"] = "lvs/vehicles/generic/heavywheel_skid.wav",
	["skid_dirt"] = "lvs/vehicles/generic/heavywheel_skid_dirt.wav",
	["skid_wet"] = "lvs/vehicles/generic/wheel_skid_wet.wav",
	["tire_damage_layer"] = "lvs/wheel_destroyed_loop.wav",
}

function ENT:UpdatePoseParameters( steer, speed_kmh, engine_rpm, throttle, brake, handbrake, clutch, gear, temperature, fuel, oil, ammeter )
	self:SetPoseParameter( "vehicle_steer", steer )
end

DEFINE_BASECLASS( "lvs_base_wheeldrive" )

function ENT:CalcViewDirectInput( ply, pos, angles, fov, pod )
	return self:CalcTankView( ply, pos, angles, fov, pod )
end

function ENT:CalcViewDriver( ply, pos, angles, fov, pod )

	angles = ply:EyeAngles()

	return BaseClass.CalcViewDriver( self, ply, pos, angles, fov, pod )
end

function ENT:CalcViewPunch( ply, pos, angles, fov, pod )
	angles = ply:EyeAngles()

	return BaseClass.CalcViewPunch( self, ply, pos, angles, fov, pod )
end

function ENT:CalcViewOverride( ply, pos, angles, fov, pod )

	-- fix camera clipping underground when upside down by moving it up
	pos = pos + Vector(0,0,150) * math.abs( math.min( pod:GetUp().z, 0 ) )

	return pos, angles, fov
end