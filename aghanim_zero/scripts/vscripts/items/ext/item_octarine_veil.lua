LinkLuaModifier( "modifier_item_octarine_veil", "items/ext/item_octarine_veil.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_octarine_veil_buff", "items/ext/item_octarine_veil.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_octarine_veil == nil then
	item_octarine_veil = class({})
end
function item_octarine_veil:GetIntrinsicModifierName()
	return "modifier_item_octarine_veil"
end

function item_octarine_veil:GetAOERadius()
	return self:GetSpecialValueFor("debuff_radius")
end

function item_octarine_veil:OnSpellStart()
	local pos = self:GetCursorPosition()
	if pos then
		self:doAction({
			pos = pos,
			pct = 1.0
		})
	end
end

function item_octarine_veil:doAction(kv)
	local pos = kv.pos
	local pct = kv.pct or 1.0
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("debuff_radius") * pct
	local duration = self:GetSpecialValueFor("resist_debuff_duration") * pct
	
	local pfx = ParticleManager:CreateParticle("particles/items2_fx/veil_of_discord.vpcf",
	PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, pos)
	ParticleManager:SetParticleControl(pfx, 1, Vector(radius, 0, 0))
	ParticleManager:ReleaseParticleIndex(pfx)

	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
	
	for _, enemy in pairs(enemies) do
		enemy:AddNewModifier(caster, self, "modifier_item_veil_of_discord_debuff", {duration = duration})
	end

	EmitSoundOnLocationWithCaster(pos, "DOTA_Item.VeilofDiscord.Activate", caster)
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_octarine_veil == nil then
	modifier_item_octarine_veil = class({})
end
function modifier_item_octarine_veil:IsHidden()
	return true
end
function modifier_item_octarine_veil:AllowIllusionDuplicate()
	return true
end
function modifier_item_octarine_veil:IsAura()
	return true
end
function modifier_item_octarine_veil:IsAuraActiveOnDeath()
	return false
end
function modifier_item_octarine_veil:GetModifierAura()
	return "modifier_item_octarine_veil_buff"
end
function modifier_item_octarine_veil:GetAuraRadius()
	return self.aura_radius
end
function modifier_item_octarine_veil:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_octarine_veil:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_item_octarine_veil:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_item_octarine_veil:OnCreated(kv)
	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	self.team = self.caster:GetTeamNumber()
	if IsServer() then
	end
	self:updateData(kv)
end
function modifier_item_octarine_veil:OnRefresh(kv)
	if IsServer() then
	end
	self:updateData(kv)
end
function modifier_item_octarine_veil:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_octarine_veil:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,

		MODIFIER_EVENT_ON_ABILITY_START,
	}
end
function modifier_item_octarine_veil:GetModifierBonusStats_Strength()
	return self.all_stats
end
function modifier_item_octarine_veil:GetModifierBonusStats_Agility()
	return self.all_stats
end
function modifier_item_octarine_veil:GetModifierBonusStats_Strength()
	return self.all_stats
end
function modifier_item_octarine_veil:GetModifierHealthBonus()
	return self.health
end
function modifier_item_octarine_veil:GetModifierManaBonus()
	return self.mana
end
function modifier_item_octarine_veil:GetModifierCastRangeBonus( params )
	if IsValid(params.ability)then
		local behavior = params.ability:GetBehavior()
		if bitand( behavior, DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_OPTIONAL_POINT) ~= 0 then
			return self.cast_range
		end
	end
	return self.cast_range
end

function modifier_item_octarine_veil:GetModifierPercentageCooldown()
	if self:GetParent():HasModifier("modifier_item_octarine_core") then
		return 0
	end
	return self.cd_reduction
end

function modifier_item_octarine_veil:OnAbilityStart(event)
	if IsServer() then
		if event.ability:GetCaster() == self.caster then
			local target = event.ability:GetCursorTarget()
			if IsValid(target) and target:GetTeamNumber()~=self.team then
				self.ability:doAction({
					pos = target:GetAbsOrigin(),
					pct = self.radius_pct
				})
			end
		end
	end
end

function modifier_item_octarine_veil:updateData(kv)
	if IsServer() then
		self.radius_pct = self.ability:GetSpecialValueFor("passive_radius_mul")
	end
	self.all_stats = self.ability:GetSpecialValueFor("bonus_all_stats")
	self.health = self.ability:GetSpecialValueFor("bonus_health")
	self.mana = self.ability:GetSpecialValueFor("bonus_mana")
	self.cast_range = self.ability:GetSpecialValueFor("cast_range_bonus")
	self.cd_reduction = self.ability:GetSpecialValueFor("bonus_cooldown")
	self.aura_radius = self.ability:GetSpecialValueFor("aura_radius")
end

modifier_item_octarine_veil_buff={}
function modifier_item_octarine_veil_buff:OnCreated(kv)
	self.ability = self:GetAbility()
	self:updateData(kv)
end
function modifier_item_octarine_veil_buff:OnRefresh(kv)
	self:updateData(kv)
end

function modifier_item_octarine_veil_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		-- MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}
end

function modifier_item_octarine_veil_buff:GetModifierConstantManaRegen()
	return self.mana_regen
end
-- 7.31 CDR stacking now
-- function modifier_item_octarine_veil_buff:GetModifierPercentageCooldownStacking()
function modifier_item_octarine_veil_buff:GetModifierPercentageCooldown()
	return self.cd_stack
end

function modifier_item_octarine_veil_buff:updateData(kv)
	self.cd_stack = self.ability:GetSpecialValueFor("aura_cd_reduction")
	self.mana_regen = self.ability:GetSpecialValueFor("aura_mana_regen")
end