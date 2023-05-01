
ogre_tank_melee_smash = class({})

----------------------------------------------------------------------------------------

function ogre_tank_melee_smash:Precache( context )
	PrecacheResource( "particle", "particles/creatures/ogre/ogre_melee_smash.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", context )
end

-----------------------------------------------------------------------------

function ogre_tank_melee_smash:ProcsMagicStick()
	return false
end

-----------------------------------------------------------------------------

function ogre_tank_melee_smash:GetCooldown( iLevel )
	return self.BaseClass.GetCooldown( self, self:GetLevel() ) / self:GetCaster():GetHasteFactor() 
end

-----------------------------------------------------------------------------

function ogre_tank_melee_smash:GetPlaybackRateOverride()
	return math.min( 2.0, math.max( self:GetCaster():GetHasteFactor(), 0.75 ) )
end

-----------------------------------------------------------------------------

function ogre_tank_melee_smash:OnSpellStart()
	if IsServer() then
		EmitSoundOn( "OgreTank.Grunt", self:GetCaster() )
		local flSpeed = self:GetSpecialValueFor( "base_swing_speed" ) / self:GetPlaybackRateOverride()
		local vToTarget = self:GetCursorPosition() - self:GetCaster():GetOrigin()
		vToTarget = vToTarget:Normalized()
		local vTarget = self:GetCaster():GetOrigin() + vToTarget * self:GetCastRange( self:GetCaster():GetOrigin(), nil )
		local hThinker = CreateModifierThinker( self:GetCaster(), self, "modifier_ogre_tank_melee_smash_thinker", { duration = flSpeed }, vTarget, self:GetCaster():GetTeamNumber(), false )
	end
end

-----------------------------------------------------------------------------

ogre_tank_farmer_melee_smash = ogre_tank_melee_smash
bonus_ogre_tank_melee_smash = ogre_tank_melee_smash
