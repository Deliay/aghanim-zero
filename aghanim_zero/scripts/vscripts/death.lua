
_G.HERO_DEATH_HANDLES=
{
    npc_dota_hero_nevermore = function(hHeroKilled)
        if IsServer() then
            local death_mod = hHeroKilled:FindModifierByName("modifier_aghsfort_nevermore_necromastery_collection")
            if IsValid(death_mod) then
                death_mod:DeathRattle()
            end
        end
    end
}
