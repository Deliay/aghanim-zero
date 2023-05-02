LinkLuaModifier("modifier_item_majo_thorn", "items/ext/item_majo_thorn.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_majo_thorn_debuff", "items/ext/item_majo_thorn.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_majo_thorn_slow", "items/ext/item_majo_thorn.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_majo_thorn_touch_cd", "items/ext/item_majo_thorn.lua", LUA_MODIFIER_MOTION_NONE)
-- Abilities
if item_majo_thorn == nil then
    item_majo_thorn = class({})
end
function item_majo_thorn:GetIntrinsicModifierName()
    return "modifier_item_majo_thorn"
end

function item_majo_thorn:OnSpellStart()
    local hTarget = self:GetCursorTarget()
    if IsValid(hTarget) then
        if TriggerStandardTargetSpell(hTarget, self) then
            return
        end
        local caster = self:GetCaster()
        AddModifierConsiderResist(hTarget, caster, self, "modifier_bloodthorn_debuff", {
            duration = self:GetSpecialValueFor("silence_duration")
        })
        AddModifierConsiderResist(hTarget, caster, self, "modifier_item_majo_thorn_debuff", {
            duration = self:GetSpecialValueFor("silence_duration")
        })
        hTarget:EmitSound("DOTA_Item.Bloodthorn.Activate")
    end
end
---------------------------------------------------------------------
-- Modifiers
if modifier_item_majo_thorn == nil then
    modifier_item_majo_thorn = class({})
end
function modifier_item_majo_thorn:IsHidden()
    return true
end
-- 
function modifier_item_majo_thorn:CheckState()
    return {
        [MODIFIER_STATE_CANNOT_MISS] = self.cannot_miss
    }
end
-- 
function modifier_item_majo_thorn:OnCreated(params)
    if IsServer() then
        self.parent = self:GetParent()
        self.ability = self:GetAbility()
        self.poison_cd = self.ability:GetSpecialValueFor("poision_cooldown")
    end
    self.cannot_miss = false
end
function modifier_item_majo_thorn:OnRefresh(params)
    if IsServer() then
    end
end
function modifier_item_majo_thorn:OnDestroy()
    if IsServer() then
    end
end
function modifier_item_majo_thorn:DeclareFunctions()
    return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
            MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
            MODIFIER_EVENT_ON_ATTACK_LANDED}
end
-- 
function modifier_item_majo_thorn:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end
-- 
function modifier_item_majo_thorn:GetModifierPreAttack_BonusDamage()
    return self:GetAbility():GetSpecialValueFor("bonus_damage")
end
-- 
function modifier_item_majo_thorn:GetModifierAttackSpeedBonus_Constant()
    return self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end
-- 
function modifier_item_majo_thorn:GetModifierProjectileSpeedBonus()
    return self:GetAbility():GetSpecialValueFor("projectile_speed")
end
-- 
function modifier_item_majo_thorn:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end
-- 
function modifier_item_majo_thorn:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end
-- 
function modifier_item_majo_thorn:OnAttackLanded(event)
    if IsServer() then
        if event.attacker == self.parent and not self.parent:HasModifier("modifier_item_majo_thorn_touch_cd") then
            local filter_result = UnitFilter(event.target, DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, self.parent:GetTeamNumber())
            if filter_result == UF_SUCCESS then
                self.cannot_miss = true
                -- print(self.parent:GetCooldownReduction())
                -- print(self.poison_cd)
                self.parent:AddNewModifier(self.parent, self.ability, "modifier_item_majo_thorn_touch_cd", {
                    duration = self.poison_cd * self.parent:GetCooldownReduction()
                })
                event.target:AddNewModifier(self.parent, self.ability, "modifier_item_witch_blade_slow", {
                    duration = self.ability:GetSpecialValueFor("slow_duration")
                })
            end
        else

            self.cannot_miss = false
        end
    end
end
-- 
modifier_item_majo_thorn_debuff = {}
-- 
function modifier_item_majo_thorn_debuff:IsPurgable()
    return true
end
-- 
function modifier_item_majo_thorn_debuff:IsHidden()
    return true
end
-- 
function modifier_item_majo_thorn_debuff:OnCreated(kv)
    if IsServer() then
        self.parent = self:GetParent()
        self.ability = self:GetAbility()
        self.int_pct = self:GetAbility():GetSpecialValueFor("target_int_as_dmg") * 0.01
    end
end
-- 
function modifier_item_majo_thorn_debuff:CheckState()
    return {
        -- [MODIFIER_STATE_SILENCED] = true,
    }
end
-- 
function modifier_item_majo_thorn_debuff:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
-- 
function modifier_item_majo_thorn_debuff:OnAttackLanded(event)
    if IsServer() then
        if event.target == self.parent and IsValid(event.attacker) and event.attacker:IsHero() then
            local damage_table = {
                victim = self.parent,
                attacker = event.attacker,
                damage = event.attacker:GetIntellect() * self.int_pct,
                damage_type = DAMAGE_TYPE_MAGICAL,
                ability = self.ability -- Optional.
            }
            ApplyDamage(damage_table)
            SendOverheadEventMessage(event.target, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, event.target, damage_table.damage,
                nil)
        end
    end
end
-- 
modifier_item_majo_thorn_slow = {}
-- 
function modifier_item_majo_thorn_slow:IsPurgable()
    return true
end
-- 
modifier_item_majo_thorn_touch_cd = {}
-- 
function modifier_item_majo_thorn_touch_cd:IsHidden()
    return true
end
-- 
function modifier_item_majo_thorn_touch_cd:IsPurgable()
    return false
end
-- 
