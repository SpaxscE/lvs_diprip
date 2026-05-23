
local matHeatWave = Material( "sprites/heatwave" )
local matFire = Material( "effects/fire_cloud1" )
local matSmoke = {
	"particle/smokesprites_0001",
	"particle/smokesprites_0002",
	"particle/smokesprites_0003",
	"particle/smokesprites_0004",
	"particle/smokesprites_0005",
	"particle/smokesprites_0006",
	"particle/smokesprites_0007",
	"particle/smokesprites_0008",
	"particle/smokesprites_0009",
	"particle/smokesprites_0010",
	"particle/smokesprites_0011",
	"particle/smokesprites_0012",
	"particle/smokesprites_0013",
	"particle/smokesprites_0014",
	"particle/smokesprites_0015",
	"particle/smokesprites_0016"
}

local att = {
	[1] = "thruster_visual_fr",
	[2] = "thruster_visual_fl",
	[3] = "thruster_visual_rr",
	[4] = "thruster_visual_rl",
}

function EFFECT:Init( data )
	local Pos = data:GetOrigin()
	local Ent = data:GetEntity()
	local ID = data:GetFlags()

	if not IsValid( Ent ) or not att[ ID ] then return end

	self.Entity = Ent
	self.ID = Ent:LookupAttachment( att[ ID ] )

	self.LifeTime = 2
	self.DieTime = CurTime() + self.LifeTime
end

function EFFECT:DoEffect( Ent )
	local Thruster = Ent:GetAttachment( self.ID )

	if not Thruster then return false end

	local emitter = Ent:GetParticleEmitter( Thruster.Pos )

	if not self._HasPlayedSound then
		self._HasPlayedSound = true

		sound.Play( "lvs/diprip_thrusters1.wav", Thruster.Pos, 75, 100, 0.5 )
	end

	local Scale = ((self.DieTime - CurTime()) / self.LifeTime) ^ 2

	local particle = emitter:Add( matSmoke[ math.random(1, #matSmoke ) ], Thruster.Pos )
	if particle then
		particle:SetVelocity( Thruster.Ang:Up() * 2000 * Scale + VectorRand() * 50 )
		particle:SetGravity( Vector(0,0,0) ) 
		particle:SetAirResistance( 800 ) 
		particle:SetDieTime( math.Rand(0.8,1) * Scale )
		particle:SetStartAlpha( 160 * Scale )
		particle:SetStartSize( 10 * Scale )
		particle:SetEndSize( 60 * Scale )
		particle:SetRoll( 1 )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetColor(40,40,40)
		particle:SetCollide( false )
	end
end

function EFFECT:Think()
	if not self.DieTime then return false end

	local T = CurTime()

	if self.DieTime < T then return false end

	if IsValid( self.Entity ) and isfunction( self.Entity.GetParticleEmitter ) then

		self.nextDFX = self.nextDFX or 0

		if self.nextDFX < T then
			self.nextDFX = T + 0.02

			self:DoEffect( self.Entity )
		end

		return true
	end

	return false
end

function EFFECT:Render()
	if not IsValid( self.Entity ) or not self.ID or not self.DieTime or not self.LifeTime then return end

	local Thruster = self.Entity:GetAttachment( self.ID )

	if not Thruster then return end

	local vOffset = Thruster.Pos
	local vNormal = Thruster.Ang:Up()

	local T = CurTime()

	local scroll = T * -15
	local size = 10

	local Scale = ((self.DieTime - T) / self.LifeTime) ^ 2

	render.SetMaterial( matFire )

	render.StartBeam( 3 )
		render.AddBeam( vOffset, size * Scale, scroll, Color( 0, 0, 255, 128 ) )
		render.AddBeam( vOffset + vNormal * 60 * Scale, 32 * Scale, scroll + 1, Color( 255,100,200, 128 ) )
		render.AddBeam( vOffset + vNormal * 148 * Scale, 32 * Scale, scroll + 3, Color( 255,100,200, 0 ) )
	render.EndBeam()

	scroll = scroll * 0.5

	render.UpdateRefractTexture()
	render.SetMaterial( matHeatWave )
	render.StartBeam( 3 )
		render.AddBeam( vOffset, size * Scale, scroll, Color( 0, 0, 255, 128 ) )
		render.AddBeam( vOffset + vNormal * 32 * Scale, 32 * Scale, scroll + 2, color_white )
		render.AddBeam( vOffset + vNormal * 128 * Scale, 48 * Scale, scroll + 5, Color( 0, 0, 0, 0 ) )
	render.EndBeam()


	scroll = scroll * 1.3
	render.SetMaterial( matFire )
	render.StartBeam( 3 )
		render.AddBeam( vOffset, size * Scale, scroll, Color( 0, 0, 255, 128 ) )
		render.AddBeam( vOffset + vNormal * 60 * Scale, 16 * Scale, scroll + 1, Color( 255,100,200, 128 ) )
		render.AddBeam( vOffset + vNormal * 148 * Scale, 16 * Scale, scroll + 3, Color( 255,100,200, 0 ) )
	render.EndBeam()
end
