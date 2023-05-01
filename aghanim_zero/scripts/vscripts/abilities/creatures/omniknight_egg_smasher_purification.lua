
omniknight_egg_smasher_purification = class({})



----------------------------------------------------------------------------------------

function omniknight_egg_smasher_purification:Precache( context )
	PrecacheResource( "particle", "particles/test_particle/generic_attack_charge.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_omniknight/omniknight_purification_cast.vpcf", context )
	PrecacheResource( "particle", "particles/units/heroes/hero_omniknight/omniknight_purification_hit.vpcf", context )
	PrecacheResource( "particle", "particles/dark_moon/darkmoon_calldown_marker_ring.vpcf", context )
end

--------------------------------------------------------------------------------

function omniknight_egg_smasher_purification:OnAbilityPhaseStart()
	self.playback_rate = self:GetSpecialValueFor( "playback_rate" )

	if IsServer() then
		self.nPreviewFX = ParticleManager:CreateParticle( "particles/test_particle/generic_attack_charge.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( self.nPreviewFX, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetOrigin(), true )
		ParticleManager:SetParticleControl( self.nPreviewFX, 15, Vector( 255, 215, 0 ) )
		ParticleManager:SetParticleControl( self.nPreviewFX, 16, Vector( 1, 0, 0 ) )
		ParticleManager:ReleaseParticleIndex( self.nPreviewFX )

		local hTarget = self:GetCursorTarget()
		if hTarget ~= nil then
			local radius = self:GetSpecialValueFor( "radius" )
			local duration = 2 -- Ballpark cast time seems good visually

			self.nRadiusPreviewFX = ParticleManager:CreateParticle( "particles/dark_moon/darkmoon_calldown_marker_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
			ParticleManager:SetParticleControlEnt( self.nRadiusPreviewFX, 0, hTarget, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true )
			ParticleManager:SetParticleControl( self.nRadiusPreviewFX, 1, Vector( radius, radius, radius ) )
			ParticleManager:SetParticleControl( self.nRadiusPreviewFX, 2, Vector( duration, duration, duration ) )
			ParticleManager:ReleaseParticleIndex( self.nRadiusPreviewFX )
		end
	end

	return true
end

--------------------------------------------------------------------------------

function omniknight_egg_smasher_purification:OnAbilityPhaseInterrupted()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
		ParticleManager:DestroyParticle( self.nRadiusPreviewFX, false )
	end 
end

--------------------------------------------------------------------------------

function omniknight_egg_smasher_purification:GetPlaybackRateOverride()
	return self.playback_rate
end

--------------------------------------------------------------------------------
function omniknight_egg_smasher_purification:OnSpellStart()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nPreviewFX, true )
		ParticleManager:DestroyParticle( self.nRadiusPreviewFX, false )

		local hTarget = self:GetCursorTarget()
		if hTarget == nil or hTarget:IsInvulnerable() or hTarget:IsMagicImmune() then
			return
		end

		local radius = self:GetSpecialValueFor( "radius" )
		local heal = self:GetSpecialValueFor( "heal" )

		hTarget:Heal( heal, self )

		local nFXIndex1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( nFXIndex1, 0, hTarget, PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetOrigin(), true  );
		ParticleManager:SetParticleControl( nFXIndex1, 1, Vector( radius, radius, radius ) );
		ParticleManager:ReleaseParticleIndex( nFXIndex1 );

		local nFXIndex2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_omniknight/omniknight_purification_cast.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( nFXIndex2, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetOrigin(), true );
		ParticleManager:SetParticleControlEnt( nFXIndex2, 1, hTarget, PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetOrigin(), true );
		ParticleManager:ReleaseParticleIndex( nFXIndex2 );
	
		EmitSoundOn( "Hero_Omniknight.Purification", hTarget )
		local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), hTarget:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
		for _,enemy in pairs( enemies ) do
			if enemy ~= nil and enemy:IsInvulnerable() == false and enemy:IsMagicImmune() == false then
				local damageInfo =
				{
					victim = enemy,
					attacker = self:GetCaster(),
					damage = heal,
					damage_type = DAMAGE_TYPE_PURE,
					ability = self,
				}
				ApplyDamage( damageInfo )

				local nFXIndex3 = ParticleManager:CreateParticle( "particles/units/heroes/hero_omniknight/omniknight_purification_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy );
				ParticleManager:SetParticleControlEnt( nFXIndex3, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetOrigin(), true );
				ParticleManager:ReleaseParticleIndex( nFXIndex3 );
			end
		end
	end
end

-----------------------------------------------------------------------------