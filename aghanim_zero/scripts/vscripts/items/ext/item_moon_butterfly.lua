LinkLuaModifier( "modifier_item_moon_butterfly", "items/ext/item_moon_butterfly.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_moon_butterfly_night", "items/ext/item_moon_butterfly.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_moon_butterfly_fly", "items/ext/item_moon_butterfly.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_moon_butterfly == nil then
	item_moon_butterfly = class({})
end
function item_moon_butterfly:GetIntrinsicModifierName()
	return "modifier_item_moon_butterfly"
end
function item_moon_butterfly:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("night_duration")
	GameRules:BeginTemporaryNight(duration)
	caster:AddNewModifier(caster, self, "modifier_item_moon_butterfly_fly", {duration = duration})
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_moon_butterfly == nil then
	modifier_item_moon_butterfly = class({})
end
function modifier_item_moon_butterfly:OnCreated(params)
	self.ability = self:GetAbility()
	if not IsValid(self.ability) then
		self:Destroy()
		return
	end
	self.agi = self.ability:GetSpecialValueFor("bonus_agility")
	self.evasion = self.ability:GetSpecialValueFor("bonus_evasion")
	self.agi_pct = self.ability:GetSpecialValueFor("bonus_agi_night_pct") * 0.01
	if IsServer() then
		self:StartIntervalThink(1)
	end
end
-- 
function modifier_item_moon_butterfly:IsHidden()
	return true
end
-- 
function modifier_item_moon_butterfly:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_item_moon_butterfly:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_moon_butterfly:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
-- 
function modifier_item_moon_butterfly:GetModifierEvasion_Constant()
	if self:GetParent():HasModifier("modifier_item_moon_butterfly_night") then
		return self:GetAbility():GetSpecialValueFor("bonus_evasion") + self:GetAbility():GetSpecialValueFor("bonus_evasion_night")
	else
		return self:GetAbility():GetSpecialValueFor("bonus_evasion")
	end
end
-- 
function modifier_item_moon_butterfly:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end
-- 
function modifier_item_moon_butterfly:GetModifierBonusStats_Agility()
	if self:GetParent():HasModifier("modifier_item_moon_butterfly_night") then
		return self.agi + self:GetParent():GetBaseAgility() * self.agi_pct
	else
		return self.agi
	end
end
-- 
function modifier_item_moon_butterfly:GetModifierBonusStats_Agility_Percentage()
	-- Not working?!
	-- if self:GetParent():HasModifier("modifier_item_moon_butterfly_night") then
	-- 	return self:GetAbility():GetSpecialValueFor("bonus_agi_night_pct")
	-- end
	-- return 0
	return 0
end
-- 
function modifier_item_moon_butterfly:GetModifierAttackSpeedBonus_Constant()
	return self.ability:GetSpecialValueFor("bonus_attack_speed")
end
-- 
function modifier_item_moon_butterfly:GetModifierMoveSpeedBonus_Percentage()
	if self:GetParent():HasModifier("modifier_item_moon_butterfly_night") then
		return self:GetAbility():GetSpecialValueFor("bonus_ms_night_pct")
	end
	return 0
end
-- 
function modifier_item_moon_butterfly:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("bonus_night_vision")
end
-- 
function modifier_item_moon_butterfly:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		if IsValid(parent) then
			if GameRules:IsDaytime() then
				parent:RemoveModifierByName("modifier_item_moon_butterfly_night")
			else
				if not parent:HasModifier("modifier_item_moon_butterfly_night") then
					parent:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_item_moon_butterfly_night", {})
				end
			end
		end
	end
end
-- 
modifier_item_moon_butterfly_night = {}
-- 
function modifier_item_moon_butterfly_night:RemoveOnDeath()
	return false
end
-- 
function modifier_item_moon_butterfly_night:IsPurgable()
	return false
end
-- 

modifier_item_moon_butterfly_fly = {}

function modifier_item_moon_butterfly_fly:IsHidden()
	return true
end

function modifier_item_moon_butterfly_fly:CheckState()
	return {
		[MODIFIER_STATE_FLYING] = true
	}
end
