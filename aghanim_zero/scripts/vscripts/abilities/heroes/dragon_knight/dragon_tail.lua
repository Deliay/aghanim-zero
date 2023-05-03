aghsfort_dk_dragon_tail = {}

-- LinkLuaModifier( "modifier_aghsfort_dk_dragon_tail", "aghsfort/dragon_knight/dragon_tail", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_dk_dragon_tail_attack", "abilities/heroes/dragon_knight/dragon_tail", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_dk_dragon_tail_passive", "abilities/heroes/dragon_knight/dragon_tail", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_dk_dragon_tail_bonus_shard_range", "abilities/heroes/dragon_knight/dragon_tail", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_dk_dragon_tail_chain", "abilities/heroes/dragon_knight/dragon_tail", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_dk_dragon_tail_chain_unkillable", "abilities/heroes/dragon_knight/dragon_tail", LUA_MODIFIER_MOTION_NONE )

function aghsfort_dk_dragon_tail:GetIntrinsicModifierName()
	return "modifier_aghsfort_dk_dragon_tail_passive"
end

function aghsfort_dk_dragon_tail:GetCastRange( vLocation, hTarget )
	if self:GetCaster():HasModifier( "modifier_aghsfort_dk_elder_dragon_form" ) then
		return self:GetSpecialValueFor("dragon_cast_range") + self:GetCaster():GetModifierStackCount("modifier_aghsfort_dk_dragon_tail_bonus_shard_range", self:GetCaster())
	else
		return self.BaseClass.GetCastRange( self, vLocation, hTarget ) + self:GetCaster():GetModifierStackCount("modifier_aghsfort_dk_dragon_tail_bonus_shard_range", self:GetCaster())
	end
end

function aghsfort_dk_dragon_tail:GetAOERadius()
	local radius = self:GetSpecialValueFor("radius")
	if self:GetCaster():HasModifier( "modifier_aghsfort_dk_elder_dragon_form" ) then
		local radius_mult = self:GetSpecialValueFor("dragon_radius_mult") / 100
		radius = radius + (radius * radius_mult)
	end

	local radius_bonus = self:GetCaster():FindAbilityByName("special_bonus_aghsfort_dk_dragon_tail+radius"):GetSpecialValueFor("value")
	if radius_bonus ~= nil then
		radius = radius + radius_bonus
	end
	-- print(radius)

	return radius
end

function aghsfort_dk_dragon_tail:Spawn()
	if not IsServer() then return end

	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_aghsfort_dk_dragon_tail_bonus_shard_range", {})
end

function aghsfort_dk_dragon_tail:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local modifier = caster:FindModifierByNameAndCaster( "modifier_aghsfort_dk_elder_dragon_form", caster )

	if not modifier and not caster:HasAbility("aghsfort_dk_dragon_tail_bounce") then
		if target:TriggerSpellAbsorb( self ) then return end

		self:Hit( target, false )

		EmitSoundOn( "Hero_DragonKnight.DragonTail.Cast", caster )

		return
	end

	local bounces = 0
	if caster:HasAbility("aghsfort_dk_dragon_tail_bounce") then
		bounces = caster:FindAbilityByName("aghsfort_dk_dragon_tail_bounce"):GetLevelSpecialValueFor("bounces",1)
	end

	local info = {
		Target = target,
		Source = caster,
		Ability = self,
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
		EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail_dragonform_proj.vpcf",
		iMoveSpeed = self:GetSpecialValueFor( "projectile_speed" ),
		bDodgeable = true,
		ExtraData = {
			bounce = bounces
		}
		}
	ProjectileManager:CreateTrackingProjectile(info)
end

function aghsfort_dk_dragon_tail:HitSingle( target )
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor( "stun_duration" )

	--instead of applying flat damage, we're making DK attack the affected unit
	caster:AddNewModifier(
		caster,
		self,
		"modifier_aghsfort_dk_dragon_tail_attack",
		{}
	)
	caster:PerformAttack(target, false, true, true, false, false, false, true)
	caster:RemoveModifierByName("modifier_aghsfort_dk_dragon_tail_attack")

	if target and not target:IsNull() then
		target:AddNewModifier(
			caster,
			self,
			"modifier_stunned",
			{ duration = duration }
		)
	end
end

function aghsfort_dk_dragon_tail:Hit( target, dragonform )
	local caster = self:GetCaster()

	if not IsValid(target) or target:TriggerSpellAbsorb( self ) then return end

	local radius = self:GetSpecialValueFor("radius")
	if dragonform then
		local radius_mult = self:GetSpecialValueFor("dragon_radius_mult") / 100
		radius = radius + (radius * radius_mult)
	end

	self:PlayEffects( target, dragonform, radius )

	local enemies = FindUnitsInRadius( caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false )
	for _,enemy in pairs(enemies) do
		self:HitSingle(enemy)
	end

	target:EmitSoundParams( "Hero_DragonKnight.DragonTail.Target", 0, 0.5, 0 )

	if caster:HasAbility("aghsfort_dk_dragon_tail_chain") and target and target:GetTeamNumber() ~= caster:GetTeamNumber() then
		local shard = caster:FindAbilityByName("aghsfort_dk_dragon_tail_chain")
		local mod_duration = shard:GetLevelSpecialValueFor("duration",1)
		target:AddNewModifier(caster, self, "modifier_aghsfort_dk_dragon_tail_chain", {duration = mod_duration})
	end
end

function aghsfort_dk_dragon_tail:OnProjectileHit_ExtraData( target, location, extraData )
	if not target then return end

	self:Hit( target, true )

	if self:GetCaster():HasAbility("aghsfort_dk_dragon_tail_bounce") then

		if target == self:GetCaster() then
			return true
		end

		local shard = self:GetCaster():FindAbilityByName("aghsfort_dk_dragon_tail_bounce")
		local range = shard:GetLevelSpecialValueFor("bonus_range", 1)

		local this = self
		local bounces = extraData.bounce - 1
		Timers(0.1, function()

			local info = {
				Target = this:GetCaster(),
				Source = target,
				Ability = self,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
				EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail_dragonform_proj.vpcf",
				iMoveSpeed = this:GetSpecialValueFor( "projectile_speed" ),
				bDodgeable = true,
				ExtraData = {
					bounce = bounces
				}
			}

			local enemies = FindUnitsInRadius( this:GetCaster():GetTeamNumber(), location, nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false )
			if bounces > 0 and (#enemies > 1 or (#enemies == 1 and enemies[1] ~= target)) then			
				local i = 1
				local new_target = enemies[i]
				while new_target == target do
					i = i+1
					new_target = enemies[i]
				end

				info.Target = new_target				
			end

			ProjectileManager:CreateTrackingProjectile(info)
		end)
	end	
	return true
end

function aghsfort_dk_dragon_tail:PlayEffects( target, dragonform, radius )
	local vec = target:GetOrigin()-self:GetCaster():GetOrigin()

	local attach = "attach_attack1"
	if dragonform then
		attach = "attach_attack2"
	end

	local effect_cast = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_dragon_knight/dragon_knight_dragon_tail.vpcf",
		PATTACH_ABSORIGIN_FOLLOW,
		target
	)
	ParticleManager:SetParticleControl( effect_cast, 3, vec )
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		2,
		self:GetCaster(),
		PATTACH_POINT_FOLLOW,
		attach,
		Vector(0,0,0),
		true 
	)
	ParticleManager:SetParticleControlEnt(
		effect_cast,
		4,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0),
		true
	)
	ParticleManager:ReleaseParticleIndex( effect_cast )

	local nFXIndex = ParticleManager:CreateParticle( "particles/creatures/ogre/ogre_melee_smash.vpcf", PATTACH_WORLDORIGIN, target )
	ParticleManager:SetParticleControl( nFXIndex, 0, target:GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( radius, radius, radius ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
end

modifier_aghsfort_dk_dragon_tail_attack	= class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,		
})

function modifier_aghsfort_dk_dragon_tail_attack:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE
	}
end

function modifier_aghsfort_dk_dragon_tail_attack:GetModifierBaseDamageOutgoing_Percentage( params )
	return self:GetAbility():GetLevelSpecialValueFor("attack_damage", self:GetAbility():GetLevel() - 1) - 100
end

----------------

modifier_aghsfort_dk_dragon_tail_passive	= class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,		
})

function modifier_aghsfort_dk_dragon_tail_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_aghsfort_dk_dragon_tail_passive:OnAttackLanded(params)
	if IsServer() and self:GetParent() == params.target and self:GetParent():HasAbility("aghsfort_dk_dragon_tail_passive") then
		local chance = self:GetParent():FindAbilityByName("aghsfort_dk_dragon_tail_passive"):GetLevelSpecialValueFor("chance",1)
		if RollPseudoRandomPercentage( chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_3, self:GetParent() ) == true then
			local old_target = self:GetParent():GetCursorCastTarget()

			self:GetParent():SetCursorCastTarget(params.attacker)
			self:GetAbility():OnSpellStart()
			self:GetParent():SetCursorCastTarget(old_target)
		end
	end
end

-------------------

modifier_aghsfort_dk_dragon_tail_bonus_shard_range	= class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,		
	RemoveOnDeath 			= function(self) return false end,		
})

function modifier_aghsfort_dk_dragon_tail_bonus_shard_range:OnCreated()
	self:SetStackCount(0)
	self:StartIntervalThink(1.5)
end

function modifier_aghsfort_dk_dragon_tail_bonus_shard_range:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		
		if caster:HasAbility("aghsfort_dk_dragon_tail_bounce") then
			self:SetStackCount(caster:FindAbilityByName("aghsfort_dk_dragon_tail_bounce"):GetLevelSpecialValueFor("bonus_range",1))
		end				
	end
end

-------------------

modifier_aghsfort_dk_dragon_tail_chain	= class({
	IsHidden				= function(self) return false end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return true end,		
})

function modifier_aghsfort_dk_dragon_tail_chain:OnCreated()
	if not IsServer() then return end

	self.particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_grimstroke/grimstroke_soulchain.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
	ParticleManager:SetParticleControlEnt( self.particle, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( self.particle, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )

	local shard = self:GetCaster():FindAbilityByName("aghsfort_dk_dragon_tail_chain")
		
	self.tick = 0.25
	-- self.heal = self:GetCaster():GetMaxHealth() / 100 * shard:GetLevelSpecialValueFor("hp_drain",1) * self.tick
	self.reflect = shard:GetLevelSpecialValueFor("reflect_percentage",1)
	self.max_dist = shard:GetLevelSpecialValueFor("max_distance",1)

	local bound = self:GetParent():entindex()
	local duration = self:GetRemainingTime()

	self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_aghsfort_dk_dragon_tail_chain_unkillable", {bound = bound, duration = duration})

	self:StartIntervalThink(self.tick)
end

function modifier_aghsfort_dk_dragon_tail_chain:OnIntervalThink()
	if not IsServer() then return end

	if (self:GetCaster():GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() > self.max_dist then
		self:Destroy()
	end
end

function modifier_aghsfort_dk_dragon_tail_chain:OnDestroy()
	if not IsServer() then return end

	self:GetCaster():RemoveModifierByName("modifier_aghsfort_dk_dragon_tail_chain_unkillable")

	if self.particle then
		ParticleManager:DestroyParticle(self.particle, false)
		ParticleManager:ReleaseParticleIndex(self.particle)
	end
end

function modifier_aghsfort_dk_dragon_tail_chain:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE 
	}
end

function modifier_aghsfort_dk_dragon_tail_chain:OnTakeDamage(params)
	if IsServer() and self:GetCaster() == params.unit and bitand(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) ~= DOTA_DAMAGE_FLAG_HPLOSS and bitand(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) ~= DOTA_DAMAGE_FLAG_REFLECTION then
		local damageTable = {
			victim = self:GetParent(),
			attacker = params.unit,
			damage = params.damage / 100 * self.reflect,
			damage_type = params.damage_type,
			damage_flag = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL,
			ability = self:GetAbility(),
		}
		ApplyDamage(damageTable)

		local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_grimstroke/grimstroke_cast_soulchain_arc.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControlEnt( particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
		ParticleManager:SetParticleControlEnt( particle, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true )
	end
end


-----

modifier_aghsfort_dk_dragon_tail_chain_unkillable	= class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,
})

function modifier_aghsfort_dk_dragon_tail_chain_unkillable:OnCreated(kv)
	if not IsServer() then return end
	
	self.bound_target = EntIndexToHScript(kv.bound)
	if not self.bound_target then
		self:Destroy()
	end
end

function modifier_aghsfort_dk_dragon_tail_chain_unkillable:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_AVOID_DAMAGE,
	}
end

function modifier_aghsfort_dk_dragon_tail_chain_unkillable:GetModifierAvoidDamage(params)
	if IsServer() and params.unit == self:GetParent() and params.damage >= self:GetParent():GetHealth() then
		return 1
	end
end
