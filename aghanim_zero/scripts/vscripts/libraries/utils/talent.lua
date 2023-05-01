function GetTalentValue(caster,item)
    local talent = caster:FindAbilityByName("special_bonus_unique_"..item)
    if talent ~= nil then
        return talent:GetSpecialValueFor("value")
    end
    return 0
end

-- function CDOTA_BaseNPC:GetTalentValue(item)
--     local talent = self:FindAbilityByName("special_bonus_unique_"..item)
--     if talent ~= nil then
--         return talent:GetSpecialValueFor("value")
--     end
--     return 0
-- end
