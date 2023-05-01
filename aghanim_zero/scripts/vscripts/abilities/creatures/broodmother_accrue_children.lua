
broodmother_accrue_children = class({})
LinkLuaModifier( "modifier_broodmother_accrue_children", "modifiers/creatures/modifier_broodmother_accrue_children", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_broodmother_generate_children", "modifiers/creatures/modifier_broodmother_generate_children", LUA_MODIFIER_MOTION_NONE )

----------------------------------------------------------------------------------------

function broodmother_accrue_children:Precache( context )

	PrecacheUnitByNameSync( "npc_dota_dummy_caster", context, -1 )
	PrecacheResource( "particle", "particles/baby_brood_venom_pool.vpcf", context )
	PrecacheUnitByNameSync( "npc_dota_creature_broodmother_baby_c", context, -1 )

end

--------------------------------------------------------------------------------

function broodmother_accrue_children:GetIntrinsicModifierName()
	return "modifier_broodmother_accrue_children"
end

--------------------------------------------------------------------------------
