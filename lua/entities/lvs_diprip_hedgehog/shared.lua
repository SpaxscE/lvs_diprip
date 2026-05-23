
ENT.Base = "lvs_wheeldrive_diprip"

ENT.PrintName = "Hedgehog"
ENT.Author = "Luna"
ENT.Information = "Luna's Vehicle Script"
ENT.Category = "[LVS] - D.I.P.R.I.P."

ENT.VehicleCategory = "Cars"
ENT.VehicleSubCategory = "Armored"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/hedgehog/hedgehog.mdl"
ENT.MDL_DESTROYED = "models/hedgehog/carpart16.mdl"

ENT.MassCenterOverride = Vector(0,0,15)

ENT.lvsShowInSpawner = true

ENT.GibModels = {
	"models/hedgehog/carpart01.mdl",
	"models/hedgehog/carpart02.mdl",
	"models/hedgehog/carpart03.mdl",
	"models/hedgehog/carpart04.mdl",
	"models/hedgehog/carpart05.mdl",
	"models/hedgehog/carpart06.mdl",
	"models/hedgehog/carpart07.mdl",
	"models/hedgehog/carpart08.mdl",
	"models/hedgehog/carpart09.mdl",
	"models/hedgehog/carpart10.mdl",
	"models/hedgehog/carpart11.mdl",
	"models/hedgehog/carpart12.mdl",
	"models/hedgehog/carpart13.mdl",
	"models/hedgehog/carpart14.mdl",
	"models/hedgehog/carpart15.mdl",
}

ENT.EngineSounds = {
	{
		sound = "lvs/hedgehog/engine_idle.wav",
		Volume = 0.5,
		Pitch = 100,
		PitchMul = 25,
		SoundLevel = 75,
		SoundType = LVS.SOUNDTYPE_IDLE_ONLY,
	},
	{
		sound = "lvs/hedgehog/engine_loop.wav",
		Volume = 1,
		Pitch = 60,
		PitchMul = 50,
		SoundLevel = 85,
		UseDoppler = true,
	},
}

ENT.ExhaustPositions = {
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-77.06,11.36,43.69),
		ang = Angle(0,0,15)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-82.32,11.36,43.69),
		ang = Angle(0,0,15)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-87.7,11.36,43.69),
		ang = Angle(0,0,15)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-103.14,16.92,-6),
		ang = Angle(-90,0,0)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-77.06,-11.36,43.69),
		ang = Angle(0,0,-15)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-82.32,-11.36,43.69),
		ang = Angle(0,0,-15)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-87.7,-11.36,43.69),
		ang = Angle(0,0,-15)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-103.14,-16.92,-6),
		ang = Angle(-90,0,0)
	},
}

-- this model has an inverted pose parameter...
ENT.MinigunPitchMul = -1