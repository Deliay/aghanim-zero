function GetParentAbilityManaCost(hSelfAbility)
    hSelfAbility.parent_ability = hSelfAbility:GetCaster():FindAbilityByName(hSelfAbility.parent_ability_name)
    if hSelfAbility.parent_ability ~= nil then
        return hSelfAbility.parent_ability:GetManaCost(hSelfAbility.parent_ability:GetLevel() - 1)
    else
        return hSelfAbility.BaseClass.GetManaCost(iLevel)
    end
end

function GetParentAbilityCooldown(hSelfAbility)
    hSelfAbility.parent_ability = hSelfAbility:GetCaster():FindAbilityByName(hSelfAbility.parent_ability_name)
    if hSelfAbility.parent_ability ~= nil then
        return hSelfAbility.parent_ability:GetCooldown(hSelfAbility.parent_ability:GetLevel() - 1)
    else
        return hSelfAbility.BaseClass.GetCooldown(iLevel)
    end
end

function GetParentAbility(hSelfAbility)
    if hSelfAbility.parent_ability ~= nil then
        return hSelfAbility.parent_ability
    else
        hSelfAbility.parent_ability = hSelfAbility:GetCaster():FindAbilityByName(hSelfAbility.parent_ability_name)
        return hSelfAbility.parent_ability
    end
end

-- Server only
function AddCooldown(hAbility, flSeconds)
    local cooldown = hAbility:GetCooldownTimeRemaining()
    cooldown = cooldown + flSeconds
    hAbility:EndCooldown()
    hAbility:StartCooldown(cooldown)
    return cooldown
end

function GetLongestCooldownRemainingAbility(hNPC)
    -- local n = hNPC:GetAbilityCount()
    local result = {
        ability = nil,
        cd = -1
    }
    local i = 0
    local ability = hNPC:GetAbilityByIndex(i)
    while IsValid(ability) do
        print(i)
        local cd = ability:GetCooldownTimeRemaining()
        if cd > result.cd then
            result.cd = cd
            result.ability = ability
        end
        i = i + 1
        ability = hNPC:GetAbilityByIndex(i)

    end
    return result
end

function TriggerStandardTargetSpell(hTarget, hAbility)
    hTarget:TriggerSpellReflect(hAbility)
    return hTarget:TriggerSpellAbsorb(hAbility)
end
