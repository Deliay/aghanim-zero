
ogreseal_flop_diretide = class({})
LinkLuaModifier( "modifier_ogreseal_flop_diretide", "modifiers/creatures/modifier_ogreseal_flop_diretide", LUA_MODIFIER_MOTION_BOTH )

----------------------------------------------------------------------------------------

function ogreseal_flop_diretide:Precache( context )

	PrecacheResource( "particle", "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/ogre/ogre_melee_smash.vpcf", context )
	PrecacheResource( "particle", "particles/creatures/ogre_seal/ogre_seal_warcry.vpcf", context )

end

--------------------------------------------------------------------------------

function ogreseal_flop_diretide:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function ogreseal_flop_diretide:OnAbilityPhaseStart()
	if IsServer() then
		self:GetCaster():StartGesture( ACT_DOTA_CAST_ABILITY_2 )
	end

	return true
end

--------------------------------------------------------------------------------

function ogreseal_flop_diretide:OnAbilityPhaseInterrupted()
	if IsServer() then
		self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_2 )
		self:GetCaster():RemoveModifierByName( "modifier_techies_suicide_leap_animation" )
	end
end

--------------------------------------------------------------------------------

function ogreseal_flop_diretide:OnSpellStart()
	if IsServer() then
		self.stun_duration = self:GetSpecialValueFor("stun_duration")

		local vToTarget = self:GetCursorPosition() - self:GetCaster():GetOrigin()
		vToTarget = vToTarget:Normalized()
		local vLocation = self:GetCaster():GetOrigin() + vToTarget * 25
		local kv =
		{
			vLocX = vLocation.x,
			vLocY = vLocation.y,
			vLocZ = vLocation.z
		}
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_ogreseal_flop_diretide", kv )
		EmitSoundOn( "OgreTank.Grunt", self:GetCaster() )
	end
end

--------------------------------------------------------------------------------

function ogreseal_flop_diretide:TryToDamage()
	if IsServer() then
		local radius = self:GetSpecialValueFor( "radius" )
		local damage = self:GetSpecialValueFor( "damage" )
		local silence_duration = self:GetSpecialValueFor( "silence_duration" )
		local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, 0, false )
		if #enemies > 0 then
			for _,enemy in pairs(enemies) do
				if enemy ~= nil and enemy:IsNull() == false and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
					local DamageInfo =
					{
						victim = enemy,
						attacker = self:GetCaster(),
						ability = self,
						damage = damage,
						damage_type = self:GetAbilityDamageType(),
					}
					ApplyDamage( DamageInfo )
					-- For some reason we have to recheck here, I guess because the enemy entity might be cleaned up super fast on death?
					if enemy ~= nil and enemy:IsNull() == false then
						if enemy:IsAlive() == false then
							local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
							ParticleManager:SetParticleControlEnt( nFXIndex, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetOrigin(), true )
							ParticleManager:SetParticleControl( nFXIndex, 1, enemy:GetOrigin() )
							ParticleManager:SetParticleControlForward( nFXIndex, 1, -self:GetCaster():GetForwardVector() )
							ParticleManager:SetParticleControlEnt( nFXIndex, 10, enemy, PATTACH_ABSORIGIN_FOLLOW, nil, enemy:GetOrigin(), true )
							ParticleManager:ReleaseParticleIndex( nFXIndex )

							EmitSoundOn( "Dungeon.BloodSplatterImpact", enemy )
						else
							enemy:AddNewModifier( self:GetCaster(), self, "modifier_stunned", { duration = self.stun_duration } )
						end
					end
				end
			end
		end

		EmitSoundOnLocationWithCaster( self:GetCaster():GetOrigin(), "OgreTank.GroundSmash", self:GetCaster() )
		local nFXIndex = ParticleManager:CreateParticle( "particles/creatures/ogre/ogre_melee_smash.vpcf", PATTACH_WORLDORIGIN,  self:GetCaster()  )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, self.radius, self.radius ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		GridNav:DestroyTreesAroundPoint( self:GetCaster():GetOrigin(), radius, false )
	end
end

--------------------------------------------------------------------------------
