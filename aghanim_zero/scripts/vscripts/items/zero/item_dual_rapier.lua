item_dual_rapier = class({})

LinkLuaModifier("modifier_item_dual_rapier", "items/zero/item_dual_rapier.lua", LUA_MODIFIER_MOTION_NONE)
function item_dual_rapier:GetIntrinsicModifierName()
    return "modifier_item_dual_rapier"
end

modifier_item_dual_rapier = class({})

function modifier_item_dual_rapier:GetTexture()
    return "item_rapier"
end

function modifier_item_dual_rapier:IsHidden()
    return true
end

function modifier_item_dual_rapier:IsPurgable()
    return false
end

function modifier_item_dual_rapier:IsPurgeException()
    return false
end

function modifier_item_dual_rapier:AllowIllusionDuplicate()
    return false
end

function modifier_item_dual_rapier:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_dual_rapier:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }
end

function modifier_item_dual_rapier:OnCreated()
    self.parent = self:GetParent()
    if self:GetAbility() == nil then
        return
    end
    self.crit_record = {}
    self.ability = self:GetAbility()
    self.damage = self.ability:GetSpecialValueFor("bonus_damage")
end

function modifier_item_dual_rapier:GetModifierPreAttack_BonusDamage()
    return self.damage
end

function modifier_item_dual_rapier:OnAttackLanded(event)
end
