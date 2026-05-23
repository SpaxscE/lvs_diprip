
ENT.Base = "lvs_wheeldrive_diprip"

ENT.PrintName = "Ratmobile"
ENT.Author = "Luna"
ENT.Information = "Luna's Vehicle Script"
ENT.Category = "[LVS] - D.I.P.R.I.P"

ENT.VehicleCategory = "Cars"
ENT.VehicleSubCategory = "Armored"

ENT.Spawnable			= true
ENT.AdminSpawnable		= false

ENT.MDL = "models/ratmobile/ratmobile.mdl"
ENT.MDL_DESTROYED = "models/ratmobile/carpart14.mdl"

ENT.MassCenterOverride = Vector(0,0,20)

ENT.lvsShowInSpawner = true

ENT.GibModels = {
	"models/ratmobile/carpart01.mdl",
	"models/ratmobile/carpart02.mdl",
	"models/ratmobile/carpart03.mdl",
	"models/ratmobile/carpart04.mdl",
	"models/ratmobile/carpart05.mdl",
	"models/ratmobile/carpart06.mdl",
	"models/ratmobile/carpart07.mdl",
	"models/ratmobile/carpart08.mdl",
	"models/ratmobile/carpart09.mdl",
	"models/ratmobile/carpart10.mdl",
	"models/ratmobile/carpart11.mdl",
	"models/ratmobile/carpart12.mdl",
	"models/ratmobile/carpart13.mdl",
}

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
		SoundLevel = 85,
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
