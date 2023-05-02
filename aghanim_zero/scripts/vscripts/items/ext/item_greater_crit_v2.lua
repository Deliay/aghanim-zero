item_greater_crit_v2 = class({})

LinkLuaModifier("modifier_item_greater_crit_v2_pa", "items/ext/item_greater_crit_v2.lua", LUA_MODIFIER_MOTION_NONE)
function item_greater_crit_v2:GetIntrinsicModifierName()
    return "modifier_item_greater_crit_v2_pa"
end

modifier_item_greater_crit_v2_pa = class({})

function modifier_item_greater_crit_v2_pa:GetTexture()
    return "item_greater_crit_v2"
end

function modifier_item_greater_crit_v2_pa:IsHidden()
    return true
end

function modifier_item_greater_crit_v2_pa:IsPurgable()
    return false
end

function modifier_item_greater_crit_v2_pa:IsPurgeException()
    return false
end

function modifier_item_greater_crit_v2_pa:AllowIllusionDuplicate()
    return false
end

function modifier_item_greater_crit_v2_pa:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_greater_crit_v2_pa:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
     MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
            MODIFIER_EVENT_ON_ATTACK_LANDED
        }
end

function modifier_item_greater_crit_v2_pa:OnCreated()
    self.parent = self:GetParent()
    if self:GetAbility() == nil then
        return
    end
    self.crit_record = {}
    self.ability = self:GetAbility()
    self.damage = self.ability:GetSpecialValueFor("bonus_damage")
    self.chance = self.ability:GetSpecialValueFor("crit_chance")
    self.multiplier = self.ability:GetSpecialValueFor("crit_multiplier")
end

function modifier_item_greater_crit_v2_pa:GetModifierPreAttack_CriticalStrike(event)
    if event.attacker == self.parent and not event.target:IsBuilding() then
        if RollPseudoRandomPercentage(self.chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_7, self.parent) then
            return self.multiplier
        end
    end
    return 0
end

function modifier_item_greater_crit_v2_pa:GetModifierPreAttack_BonusDamage()
    return self.damage
end

function modifier_item_greater_crit_v2_pa:OnAttackLanded(event)
end
