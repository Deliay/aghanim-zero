
amoeba_boss_death_explosion_thinker = class({})
LinkLuaModifier( "modifier_amoeba_boss_acid_spray_thinker", "modifiers/creatures/modifier_amoeba_boss_acid_spray_thinker", LUA_MODIFIER_MOTION_NONE )

-----------------------------------------------------------------------------------------

function amoeba_boss_death_explosion_thinker:Precache( context )
	PrecacheResource( "particle", "particles/creatures/slime_acid_spray.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_alchemist.vsndevts", context )
end

-----------------------------------------------------------------------------------------

function amoeba_boss_death_explosion_thinker:GetIntrinsicModifierName()
	return "modifier_amoeba_boss_acid_spray_thinker"
end

-----------------------------------------------------------------------------------------
