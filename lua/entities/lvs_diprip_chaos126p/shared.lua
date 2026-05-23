
ENT.Base = "lvs_wheeldrive_diprip"

ENT.PrintName = "Chaos126p"
ENT.Author = "Luna"
ENT.Information = "Luna's Vehicle Script"
ENT.Category = "[LVS] - D.I.P.R.I.P"

ENT.VehicleCategory = "Cars"
ENT.VehicleSubCategory = "Armored"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/chaos126p/chaos126p.mdl"
ENT.MDL_DESTROYED = "models/chaos126p/carpart16.mdl"

ENT.MassCenterOverride = Vector(8,0,20)

ENT.lvsShowInSpawner = true

ENT.GibModels = {
	"models/chaos126p/carpart01.mdl",
	"models/chaos126p/carpart02.mdl",
	"models/chaos126p/carpart03.mdl",
	"models/chaos126p/carpart04.mdl",
	"models/chaos126p/carpart05.mdl",
	"models/chaos126p/carpart06.mdl",
	"models/chaos126p/carpart07.mdl",
	"models/chaos126p/carpart08.mdl",
	"models/chaos126p/carpart09.mdl",
	"models/chaos126p/carpart10.mdl",
	"models/chaos126p/carpart11.mdl",
	"models/chaos126p/carpart12.mdl",
	"models/chaos126p/carpart13.mdl",
	"models/chaos126p/carpart14.mdl",
	"models/chaos126p/carpart15.mdl",
}

ENT.EngineSounds = {
	{
		sound = "lvs/chaos126p/engine_idle.wav",
		Volume = 0.5,
		Pitch = 100,
		PitchMul = 25,
		SoundLevel = 75,
		SoundType = LVS.SOUNDTYPE_IDLE_ONLY,
	},
	{
		sound = "lvs/chaos126p/engine_loop.wav",
		Volume = 1,
		Pitch = 60,
		PitchMul = 55,
		SoundLevel = 85,
		UseDoppler = true,
	},
}

ENT.ExhaustPositions = {
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-73.69,21.88,21.45),
		ang = Angle(0,0,0)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-77.48,23.3,16.93),
		ang = Angle(0,0,0)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-81.22,23.87,12.01),
		ang = Angle(0,0,0)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-75.21,6.14,-13.95),
		ang = Angle(-90,0,0)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-73.69,-21.88,21.45),
		ang = Angle(0,0,0)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-77.48,-23.3,16.93),
		ang = Angle(0,0,0)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-81.22,-23.87,12.01),
		ang = Angle(0,0,0)
	},
	{
		effect = "lvs_diprip_exhaust",
		pos = Vector(-75.21,-6.14,-13.95),
		ang = Angle(-90,0,0)
	},
}

-- this model has an inverted pose parameter...
ENT.MinigunPitchMul = -1
