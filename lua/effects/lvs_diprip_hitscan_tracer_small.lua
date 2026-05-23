EFFECT.MatBeam = Material( "effects/lvs/ballturret_projectorbeam" )

-- variables
local LifeTime = 0.5

local StartSizeOuter = 2
local StartSizeInner = 1

local EndSizeOuter = 2
local EndSizeInner = 1
local DissipateExponentScale = 8
local DissipateExponentAlpha = 8

function EFFECT:Init( data )
	local pos  = data:GetOrigin()
	local dir = data:GetNormal()

	self.StartPos = pos
	self.Dir = dir

	self.ID = data:GetMaterialIndex()

	self.LifeTime = LifeTime
	self.DieTime = CurTime() + self.LifeTime

	self:SetRenderBoundsWS( pos, pos + dir * 50000 )
end

function EFFECT:Think()
	if self.DieTime < CurTime() then return false end

	return true
end

function EFFECT:Render()

	local bullet = LVS:GetBullet( self.ID )

	if bullet then
		self.StartPos = bullet.Entity:LocalToWorld( bullet.SrcEntity )
		self.EndPos = bullet:GetPos()
		self.BulletAlive = true
		self.BulletFilter = bullet.Filter
	else
		-- fix problem in lvs bullet code not updating the target destination
		if self.BulletAlive and self.BulletFilter then
			self.BulletAlive = nil

			local trace = util.TraceLine( {
				start = self.StartPos,
				endpos = self.StartPos + self.Dir * 50000,
				mask = MASK_SHOT_HULL,
				filter = self.BulletFilter,
			} )

			self.EndPos = trace.HitPos
		end
	end

	if not self.StartPos or not self.EndPos then return end

	if bullet and bullet:GetLength() <= 0 then return end

	-- math, dont change
	local S = (self.DieTime - CurTime()) / self.LifeTime
	local invS = 1 - S

	local Alpha = 255 * (S ^ DissipateExponentAlpha)
	local Scale = S ^ DissipateExponentScale
	local invScale = invS ^ DissipateExponentScale

	render.SetMaterial( self.MatBeam )
	render.DrawBeam( self.StartPos, self.EndPos, StartSizeOuter * Scale + EndSizeOuter * invScale, 1, 0, Color( 255, 80, 0, Alpha ) )
	render.DrawBeam( self.StartPos, self.EndPos, StartSizeInner * Scale + EndSizeInner * invScale, 1, 0, Color( 255, 255, 255, Alpha ) )
end
