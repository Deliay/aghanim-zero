LinkLuaModifier( "modifier_item_ollie_guard", "items/ext/item_ollie_guard.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_ollie_guard == nil then
	item_ollie_guard = class({})
end
function item_ollie_guard:GetIntrinsicModifierName()
	return "modifier_item_ollie_guard"
end
function item_ollie_guard:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local blast_radius = self:GetSpecialValueFor("blast_radius")
	local blast_speed = self:GetSpecialValueFor("blast_speed")
	local debuff_duration = self:GetSpecialValueFor("blast_debuff_duration")
	local buff_duration = self:GetSpecialValueFor("barrier_duration")

	if IsValid(target) and IsEnemy(target, caster) then
		if TriggerStandardTargetSpell(target, self) then
			return
		end
	end

	target:AddNewModifier(caster, self, "modifier_item_forcestaff_active", {duration = 0.5})
	EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "DOTA_Item.ForceStaff.Activate", caster)
	
	local blast = target:AddNewModifier(caster, self, "modifier_generic_ring_lua", 
	{
		end_radius = blast_radius,
		speed = blast_speed,
		-- width = 255,
		target_team = DOTA_UNIT_TARGET_TEAM_BOTH,
		target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		target_flag = DOTA_UNIT_TARGET_FLAG_NONE,
		IsCircle = 0,
		bVision = 1,
		fVisionDuration = 2.0,
		duration = 10.0
	})
	if IsValid(blast) then
		blast.damage_table = {
			victim = nil,
			attacker = caster,
			damage = self:GetSpecialValueFor("blast_damage"),
			damage_type = self:GetAbilityDamageType(),
			ability = self,
		}
		blast:SetCallback( function( hUnit )
			-- add modifier
			local hit_pfx = ParticleManager:CreateParticle("particles/econ/events/ti9/shivas_guard_ti9_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, hUnit)
			ParticleManager:SetParticleControl(hit_pfx, 1, blast:GetParent():GetAbsOrigin())
			if IsEnemy(caster, hUnit) and not hUnit:IsMagicImmune() then
				blast.damage_table.victim = hUnit
				ApplyDamage(blast.damage_table)
				if IsValid(hUnit) then
					hUnit:AddNewModifier(caster, self, "modifier_item_shivas_guard_blast", {duration = debuff_duration})
				end
			else
				hUnit:EmitSound("DOTA_Item.Pipe.Activate")
				hUnit:AddNewModifier(caster, self, "modifier_item_eternal_shroud_barrier", {duration = buff_duration})
			end
		end)
		local pfx = ParticleManager:CreateParticle( "particles/econ/events/ti9/shivas_guard_ti9_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, target )
		ParticleManager:SetParticleControl( pfx, 1, Vector( blast_radius, debuff_duration, blast_speed ) )
		ParticleManager:ReleaseParticleIndex( pfx )
		target:EmitSound("DOTA_Item.ShivasGuard.Activate")
	end
end
---------------------------------------------------------------------
--Modifiers
modifier_item_ollie_guard = class({})
function modifier_item_ollie_guard:IsHidden()
	return true
end
function modifier_item_ollie_guard:IsAura()
	return true
end
function modifier_item_ollie_guard:GetModifierAura()
	return "modifier_item_shivas_guard_aura"
end
function modifier_item_ollie_guard:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_item_ollie_guard:GetAuraSearchType()
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end
function modifier_item_ollie_guard:GetAuraRadius()
	return self.aura_radius
end
function modifier_item_ollie_guard:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end
function modifier_item_ollie_guard:OnCreated(kv)
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.intellect = self.ability:GetSpecialValueFor("bonus_intellect")
	self.hp = self.ability:GetSpecialValueFor("bonus_health")
	self.regen = self.ability:GetSpecialValueFor("bonus_health_regen")
	self.armor = self.ability:GetSpecialValueFor("bonus_armor")
	self.mr = self.ability:GetSpecialValueFor("bonus_spell_resist")
	self.aura_radius = self.ability:GetSpecialValueFor("aura_radius")
	self.spell_lifesteal = self.ability:GetSpecialValueFor("spell_lifesteal") * 0.01
	if IsServer() then
	end
end
function modifier_item_ollie_guard:OnRefresh(kv)
	if IsServer() then
	end
end
function modifier_item_ollie_guard:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_ollie_guard:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
function modifier_item_ollie_guard:GetModifierBonusStats_Intellect()
	return self.intellect
end
function modifier_item_ollie_guard:GetModifierPhysicalArmorBonus()
	return self.armor
end
function modifier_item_ollie_guard:GetModifierHealthBonus()
	return self.hp
end
function modifier_item_ollie_guard:GetModifierMagicalResistanceBonus()
	return self.mr
end
function modifier_item_ollie_guard:GetModifierConstantHealthRegen()
	return self.regen
end
function modifier_item_ollie_guard:OnTakeDamage( event )
	if IsServer() then
		local Attacker = event.attacker
		local Target = event.unit
		local Ability = event.inflictor
		local flDamage = event.damage

		if Attacker ~= self.parent or Ability == nil or Target == nil then
			return 0
		end

		if bit.band( event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) == DOTA_DAMAGE_FLAG_REFLECTION then
			return 0
		end
		if bit.band( event.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL ) == DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
			return 0
		end

		local pfx = ParticleManager:CreateParticle( "particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, Attacker )
		ParticleManager:ReleaseParticleIndex( pfx )

		local flLifesteal = flDamage * self.spell_lifesteal
		Attacker:HealWithParams( flLifesteal, self.ability, false, true, self.parent, true )
	end
	return 0
end

-- 
