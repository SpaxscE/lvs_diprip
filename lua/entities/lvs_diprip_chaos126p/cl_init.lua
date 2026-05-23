include("shared.lua")

function ENT:OnEngineActiveChanged( Active )
	if Active then
		self:EmitSound( "lvs/chaos126p/engine_start.wav", 75, 100, LVS.EngineVolume )
	else
		self:EmitSound( "lvs/chaos126p/engine_stop.wav", 75, 100, LVS.EngineVolume )
	end
end
