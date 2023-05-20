require("abilities/heroes/antimage/legends")
aghsfort_antimage_illusion = {}

-- function aghsfort_antimage_illusion:GetIntrinsicModifierName()
--     return nil
-- end
aghsfort_antimage_illusion.illusions = {}
function aghsfort_antimage_illusion:doAction(kv)
    local caster = self:GetCaster()
    local modifier = {
        outgoing_damage = self:GetSpecialValueFor("outgoing_damage"),
        incoming_damage = self:GetSpecialValueFor("incoming_damage"),
        bounty_base = 0,
        bounty_growth = 0,
        outgoing_damage_structure = self:GetSpecialValueFor("outgoing_damage"),
        outgoing_damage_roshan = self:GetSpecialValueFor("outgoing_damage")
    }
    local new_illusions = CreateIllusions(caster, caster, modifier, 1, 0, false, false)

    for i = 1, #new_illusions do
        new_illusions[i]:AddNewModifier(caster, self, "modifier_kill", {
            duration = self:GetSpecialValueFor("duration")
        })
        new_illusions[i]:AddNewModifier(caster, nil, "modifier_phased", {})
        new_illusions[i]:AddNewModifier(caster, nil, "modifier_aghsfort_antimage_illusion", {})
        new_illusions[i]:SetControllableByPlayer(-1, true)
        FindClearSpaceForUnit(new_illusions[i], kv.position, false)
    end

    if #self.illusions >= self:GetSpecialValueFor("max_illusions") then
        if not self.illusions[1]:IsNull() then 
            self.illusions[1]:Kill( nil, nil )
        end
        table.remove(self.illusions,1)
    end

    self.illusions[#self.illusions + 1] = new_illusions[1]

    return {
        new_illusion = new_illusions[1]
    }
end

function aghsfort_antimage_illusion:replicateCast(szAbilityName, kv)
    if szAbilityName ~= nil then
        for i = 1, #self.illusions do
            if IsValidNPC(self.illusions[i]) then
                local ability  = self.illusions[i]:FindAbilityByName(szAbilityName)
                if ability ~= nil then
                    self.illusions[i]:CastAbilityNoTarget(ability, -1)
                end
            end
        end
    end
end

function aghsfort_antimage_illusion:replicateAction(szAbilityName, kv)
    if szAbilityName ~= nil then
        for i = 1, #self.illusions do
            if IsValidNPC(self.illusions[i]) then
                local ability  = self.illusions[i]:FindAbilityByName(szAbilityName)
                if ability ~= nil then
                    ability:doAction(kv)
                end
            end
        end
    end
end

modifier_aghsfort_antimage_illusion = {}
LinkLuaModifier("modifier_aghsfort_antimage_illusion", "abilities/heroes/antimage/illusion",
    LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_antimage_illusion:IsHidden()
    return true
end
