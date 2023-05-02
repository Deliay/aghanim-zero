LinkLuaModifier( "modifier_item_tarrasque_halberd", "items/ext/item_tarrasque_halberd.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_tarrasque_halberd == nil then
	item_tarrasque_halberd = class({})
end
function item_tarrasque_halberd:GetIntrinsicModifierName()
	return "modifier_item_tarrasque_halberd"
end

function item_tarrasque_halberd:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()

	if IsValid(target) then
		if TriggerStandardTargetSpell(target, self) then
			return
		end
	end

	self:doAction({
		caster = caster,
		target = target,
	})
end

function item_tarrasque_halberd:doAction(kv)
	local caster = kv.caster
	local target = kv.target
	if IsValid(target) and not target:IsMagicImmune() then
		local duration = 0
		if target:IsRangedAttacker() then
			duration = self:GetSpecialValueFor("disarm_range")
		else
			duration = self:GetSpecialValueFor("disarm_melee")
		end
		AddModifierConsiderResist(target, caster, self,"modifier_heavens_halberd_debuff",{duration = duration})
		EmitSoundOn("DOTA_Item.HeavensHalberd.Activate", target)
	end
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_tarrasque_halberd == nil then
	modifier_item_tarrasque_halberd = class({})
end
function modifier_item_tarrasque_halberd:IsHidden()
	return true
end
function modifier_item_tarrasque_halberd:OnCreated(kv)
	self.ability = self:GetAbility()
	self.evasion = self.ability:GetSpecialValueFor("bonus_evasion")
	self.agi = self.ability:GetSpecialValueFor("bonus_agility")
	self.str = self.ability:GetSpecialValueFor("bonus_strength")
	self.hp = self.ability:GetSpecialValueFor("bonus_health")
	self.hp_pct = self.ability:GetSpecialValueFor("health_regen_pct")
	self.status_resistance = self.ability:GetSpecialValueFor("status_resistance")
	self.hp_regen_amp = self.ability:GetSpecialValueFor("hp_regen_amp")
	self.range_range = self.ability:GetSpecialValueFor("base_attack_range")
	self.range_mele = self.ability:GetSpecialValueFor("base_attack_mele")
	self.parent = self:GetParent()

	if IsServer() then
	end
end
function modifier_item_tarrasque_halberd:OnRefresh(kv)
	if IsServer() then
	end
end
function modifier_item_tarrasque_halberd:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_tarrasque_halberd:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,

		MODIFIER_EVENT_ON_ATTACK_FAIL,
	}
end
function modifier_item_tarrasque_halberd:GetModifierEvasion_Constant()
	return self.evasion
end
function modifier_item_tarrasque_halberd:GetModifierBonusStats_Agility()
	return self.agi
end
function modifier_item_tarrasque_halberd:GetModifierBonusStats_Strength()
	return self.str
end
function modifier_item_tarrasque_halberd:GetModifierHealthBonus()
	return self.hp
end
function modifier_item_tarrasque_halberd:GetModifierHealthRegenPercentage()
	return self.hp_pct
end
function modifier_item_tarrasque_halberd:GetModifierHPRegenAmplify_Percentage()
	return self.hp_regen_amp
end
function modifier_item_tarrasque_halberd:GetModifierLifestealRegenAmplify_Percentage()
	return self.hp_regen_amp
end
function modifier_item_tarrasque_halberd:GetModifierAttackRangeBonus()
	if self.parent:IsRangedAttacker() then
		return self.range_range
	end
	return self.range_mele
end
function modifier_item_tarrasque_halberd:GetModifierStatusResistance()
	return self.status_resistance
end
function modifier_item_tarrasque_halberd:OnAttackFail(event)
	if IsServer() then
		if event.target == self.parent and event.fail_type == DOTA_ATTACK_RECORD_FAIL_TARGET_EVADED then
			if IsValid(event.attacker) and (event.attacker:IsHero() or event.attacker:IsIllusion()) then
				return
			end
			self.ability:doAction({
				caster = self.parent,
				target = event.attacker,
			})
		end
	end
end
