modifier_hero_immortal = class({})

function modifier_hero_immortal:IsHidden()
    return false
end

function modifier_hero_immortal:IsDebuff()
    return false
end

function modifier_hero_immortal:IsPurgable()
    return false
end

function modifier_hero_immortal:RemoveOnDeath()
    return false
end

return modifier_hero_immortal
