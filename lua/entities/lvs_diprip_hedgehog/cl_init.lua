include("shared.lua")

function ENT:OnEngineActiveChanged( Active )
	if Active then
		self:EmitSound( "lvs/hedgehog/engine_start.wav", 75, 100, LVS.EngineVolume )
	else
		self:EmitSound( "lvs/hedgehog/engine_stop.wav", 75, 100, LVS.EngineVolume )
	end
end
