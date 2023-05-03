require("modifiers/ext/modifier_legend_base")
require("abilities/ext/ability_legend_base")

--------------------------------------------------------------------------------
aghsfort_antimage_legend_blink_fragment = class(ability_legend_base)

modifier_aghsfort_antimage_legend_blink_fragment = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_antimage_legend_blink_fragment", "abilities/heroes/antimage/legends",
    LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_antimage_legend_blink_fragment:OnCreated(kv)
    if IsServer() then
        local caster = self:GetAbility():GetCaster()
        local ability = caster:FindAbilityByName("aghsfort_antimage_blink_fragment")
        if ability ~= nil then
            print("grant abilitiy!")
            ability:SetLevel(1)
            ability:SetHidden(false)
        end
    end
end

--------------------------------------------------------------------------------
aghsfort_antimage_legend_mana_transfer = class(ability_legend_base)

modifier_aghsfort_antimage_legend_mana_transfer = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_antimage_legend_mana_transfer", "abilities/heroes/antimage/legends",
    LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
aghsfort_antimage_legend_mana_explosion = class(ability_legend_base)

modifier_aghsfort_antimage_legend_mana_explosion = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_antimage_legend_mana_explosion", "abilities/heroes/antimage/legends",
    LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
aghsfort_antimage_legend_imagine_breaker = class(ability_legend_base)

modifier_aghsfort_antimage_legend_imagine_breaker = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_antimage_legend_imagine_breaker", "abilities/heroes/antimage/legends",
    LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
aghsfort_antimage_legend_comprehensive_counter = class(ability_legend_base)

modifier_aghsfort_antimage_legend_comprehensive_counter = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_antimage_legend_comprehensive_counter", "abilities/heroes/antimage/legends",
    LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_antimage_legend_comprehensive_counter:IsAura()
    return true
end

function modifier_aghsfort_antimage_legend_comprehensive_counter:GetModifierAura()
    return "modifier_aghsfort_antimage_comprehensive_counter"
end

function modifier_aghsfort_antimage_legend_comprehensive_counter:GetAuraEntityReject(npc)
    return npc:HasModifier(self:GetName())
end

function modifier_aghsfort_antimage_legend_comprehensive_counter:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_aghsfort_antimage_legend_comprehensive_counter:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end

function modifier_aghsfort_antimage_legend_comprehensive_counter:GetAuraDuration()
    return 0.1
end

function modifier_aghsfort_antimage_legend_comprehensive_counter:GetAuraRadius()
    return self:GetAbility():GetSpecialValueFor("aura_radius") or 1200
end
--------------------------------------------------------------------------------

aghsfort_antimage_legend_turstarkuri_guardiance = class(ability_legend_base)

modifier_aghsfort_antimage_legend_turstarkuri_guardiance = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_antimage_legend_turstarkuri_guardiance", "abilities/heroes/antimage/legends",
    LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------

aghsfort_antimage_legend_arcande_discipliner = class(ability_legend_base)

modifier_aghsfort_antimage_legend_arcande_discipliner = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_antimage_legend_arcande_discipliner", "abilities/heroes/antimage/legends",
    LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_antimage_legend_arcande_discipliner:IsAura()
    return true
end

function modifier_aghsfort_antimage_legend_arcande_discipliner:GetAuraSearchTeam()
  return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_aghsfort_antimage_legend_arcande_discipliner:GetAuraSearchType()
  return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end

function modifier_aghsfort_antimage_legend_arcande_discipliner:GetModifierAura()
  return "modifier_aghsfort_antimage_arcande_discipliner"
end

function modifier_aghsfort_antimage_legend_arcande_discipliner:GetAuraDuration()
  return 0.1
end

function modifier_aghsfort_antimage_legend_arcande_discipliner:GetAuraRadius()
  return self:GetAbility():GetSpecialValueFor("aura_radius") or 1200
end

--------------------------------------------------------------------------------

aghsfort_antimage_legend_secondary_void = class(ability_legend_base)

modifier_aghsfort_antimage_legend_secondary_void=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_antimage_legend_secondary_void", "abilities/heroes/antimage/legends",LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

aghsfort_antimage_legend_mana_release = class(ability_legend_base)

modifier_aghsfort_antimage_legend_mana_release=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_antimage_legend_mana_release", "abilities/heroes/antimage/legends",LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

aghsfort_antimage_legend_ability_ban = class(ability_legend_base)

modifier_aghsfort_antimage_legend_ability_ban=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_antimage_legend_ability_ban", "abilities/heroes/antimage/legends",LUA_MODIFIER_MOTION_NONE)
