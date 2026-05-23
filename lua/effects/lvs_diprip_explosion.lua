
function EFFECT:Init( data )
	local effectdata = EffectData()
	effectdata:SetOrigin( data:GetOrigin() )
	effectdata:SetNormal( Vector(0,0,1) )
	effectdata:SetMagnitude( 1 )
	util.Effect( "lvs_bullet_impact_explosive", effectdata )
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
