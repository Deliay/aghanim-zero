require("abilities/heroes/crystal_maiden/legends")

aghsfort_rylai_brilliance_aura = {}

LinkLuaModifier("modifier_aghsfort_rylai_brilliance_aura", "abilities/heroes/crystal_maiden/brilliance_aura",
    LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghsfort_rylai_brilliance_aura_buff", "abilities/heroes/crystal_maiden/brilliance_aura",
    LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghsfort_rylai_brilliance_aura_fenzy", "abilities/heroes/crystal_maiden/brilliance_aura",
    LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------
-- Passive Modifier
function aghsfort_rylai_brilliance_aura:GetIntrinsicModifierName()
    return "modifier_aghsfort_rylai_brilliance_aura"
end

function aghsfort_rylai_brilliance_aura:Init()
    self.ability_exceptions = {
        ["ability_aghsfort_capture"] = true,
        ["aghsfort_aziyog_underlord_portal_warp"] = true,
        ["ability_capture"] = true
    }
end

function aghsfort_rylai_brilliance_aura:getMagicalResistanceBonus()
    -- print(GetTalentValue(self:GetCaster(),"aghsfort_rylai_brilliance_aura+mr"))
    return GetTalentValue(self:GetCaster(), "aghsfort_rylai_brilliance_aura+mr")
end

function aghsfort_rylai_brilliance_aura:getSpellAmp()
    -- print(GetTalentValue(self:GetCaster(),"aghsfort_rylai_brilliance_aura+mr"))
    local shard = self:GetCaster():FindAbilityByName("aghsfort_rylai_legend_arcane_enhance")
    if IsValid(shard) then
        return self:GetSpecialValueFor("mana_regen") * shard:GetSpecialValueFor("value")
    end
    return 0
end

function aghsfort_rylai_brilliance_aura:getCooldownReduction()
    -- print(GetTalentValue(self:GetCaster(),"aghsfort_rylai_brilliance_aura+mr"))
    local shard = self:GetCaster():FindAbilityByName("aghsfort_rylai_legend_cool_mind")
    if IsValid(shard) then
        return self:GetSpecialValueFor("mana_regen")
    end
    return 0
end


function aghsfort_rylai_brilliance_aura:arcaneField(kv)
    if IsServer() then
        local target = kv.target
        local stacks = kv.stacks
        local caster = self:GetCaster()
        local shard = caster:FindAbilityByName("aghsfort_rylai_legend_arcane_field")
        local freezing_field = caster:FindAbilityByName("aghsfort_rylai_freezing_field")

        if IsValid(shard) and IsValid(freezing_field) and IsValidNPC(target) then
            local chance = shard:GetSpecialValueFor("chance")
            print("arctic field!..chance:"..chance)
            if RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_3, caster) == true then
                print("arctic field triggered!")
                freezing_field:doAction(
                    {
                        target = target,
                        duration = stacks * shard:GetSpecialValueFor("duration_per_stack")
                    }
                )
            end
        end
    end
end

-- Aura itself(only on rylai)
modifier_aghsfort_rylai_brilliance_aura = {}

function modifier_aghsfort_rylai_brilliance_aura:IsHidden()
    return true
end

function modifier_aghsfort_rylai_brilliance_aura:IsPurgable()
    return false
end

function modifier_aghsfort_rylai_brilliance_aura:RemoveOnDeath()
    return false
end

function modifier_aghsfort_rylai_brilliance_aura:IsAura()
    return true
end

function modifier_aghsfort_rylai_brilliance_aura:GetModifierAura()
    return "modifier_aghsfort_rylai_brilliance_aura_buff"
end

function modifier_aghsfort_rylai_brilliance_aura:GetAuraRadius()
    return FIND_UNITS_EVERYWHERE
end

function modifier_aghsfort_rylai_brilliance_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_aghsfort_rylai_brilliance_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_aghsfort_rylai_brilliance_aura:OnCreated(kv)
    self.ability_exceptions = self:GetAbility().ability_exceptions or {}
end

function modifier_aghsfort_rylai_brilliance_aura:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

function modifier_aghsfort_rylai_brilliance_aura:OnAbilityExecuted(kv)
    if IsServer() then
        local caster = self:GetCaster()
        if IsValid(kv.ability) and kv.ability:GetCaster() == caster and not kv.ability:IsItem() then
            if self.ability_exceptions[kv.ability:GetName()] then
                return
            end
            local ability = self:GetAbility()
            local stack_duration = ability:GetSpecialValueFor("stack_duration")
            local heroes = HeroList:GetAllHeroes()
            local team_num = caster:GetTeamNumber()
            for i = 1, #heroes do
                if IsValid(heroes[i]) and heroes[i]:IsAlive() and heroes[i]:GetTeamNumber() == team_num then
                    local mod_fenzy = heroes[i]:FindModifierByName("modifier_aghsfort_rylai_brilliance_aura_fenzy")
                    print("add fenzy!")
                    heroes[i]:AddNewModifier(caster, ability, "modifier_aghsfort_rylai_brilliance_aura_fenzy", {
                        duration = stack_duration
                    })
                end
            end
        end
    end
end

-- Aura provided
modifier_aghsfort_rylai_brilliance_aura_buff = {}

function modifier_aghsfort_rylai_brilliance_aura_buff:IsPurgable()
    return false
end

function modifier_aghsfort_rylai_brilliance_aura_buff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
            MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_aghsfort_rylai_brilliance_aura_buff:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("mana_regen")
end

function modifier_aghsfort_rylai_brilliance_aura_buff:GetModifierPercentageCasttime()
    return 0
end

function modifier_aghsfort_rylai_brilliance_aura_buff:GetModifierMagicalResistanceBonus()
    if self:GetParent():HasModifier("modifier_aghsfort_rylai_brilliance_aura_fenzy") then
        return 0
    end
    return self:GetAbility():getMagicalResistanceBonus()
end

function modifier_aghsfort_rylai_brilliance_aura_buff:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():getSpellAmp()
end


-- Heroes only
modifier_aghsfort_rylai_brilliance_aura_fenzy = {}

function modifier_aghsfort_rylai_brilliance_aura_fenzy:IsPurgable()
    return false
end

function modifier_aghsfort_rylai_brilliance_aura_fenzy:IsPurgeException()
    return false
end

function modifier_aghsfort_rylai_brilliance_aura_fenzy:DeclareFunctions()
    return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT, MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
            MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_EVENT_ON_ABILITY_EXECUTED,
            MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE ,
            -- MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING ,
            MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        }
end

function modifier_aghsfort_rylai_brilliance_aura_fenzy:OnCreated(kv)
    if IsServer() then
        self.ability_exceptions = self:GetAbility().ability_exceptions or {}
        -- Get Resources
        -- print("fenzy on!")
        self.parent = self:GetParent()
        local pfx = "particles/units/heroes/hero_rylai/rylai_cold_soul.vpcf"

        -- Create Particle
        self.pfx = ParticleManager:CreateParticle(pfx, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())

        -- buff particle
        self:AddParticle(self.pfx, false, -- bDestroyImmediately
        false, -- bStatusEffect
        -1, -- iPriority
        false, -- bHeroEffect
        false -- bOverheadEffect
        )
        self:SetStackCount(1)
    end
end

function modifier_aghsfort_rylai_brilliance_aura_fenzy:OnRefresh(kv)
    if IsServer() then
        print("fenzy update!")
        local max_stacks = self:GetAbility():GetSpecialValueFor("max_stacks") or 0
        if max_stacks > self:GetStackCount() then
            self:IncrementStackCount()
        end
        ParticleManager:SetParticleControl(self.pfx, 1, Vector(self:GetStackCount(), 0, 0))
    end
end

function modifier_aghsfort_rylai_brilliance_aura_fenzy:GetModifierConstantManaRegen()
    return self:GetAbility():GetSpecialValueFor("mana_regen") * self:GetStackCount()
end

function modifier_aghsfort_rylai_brilliance_aura_fenzy:GetModifierPercentageCasttime()
    return self:GetAbility():GetSpecialValueFor("cast_reduce") * self:GetStackCount()
end

function modifier_aghsfort_rylai_brilliance_aura_fenzy:GetModifierMagicalResistanceBonus()
    return (self:GetAbility():getMagicalResistanceBonus() + 1) * self:GetStackCount()
end

function modifier_aghsfort_rylai_brilliance_aura_fenzy:OnAbilityExecuted(kv)
    if IsServer() then
        if IsValid(kv.ability) and kv.ability:GetCaster() == self.parent and not kv.ability:IsItem() then
            if self.ability_exceptions[kv.ability:GetName()] or not (kv.ability:GetCooldown(kv.ability:GetLevel()) > 0) then
                return
            end
            print("fenzy cast ability!"..kv.ability:GetName())
            local ability = self:GetAbility()
            ability:arcaneField({
                target = self.parent,
                stacks = self:GetStackCount()
            })
        end
    end
end

-- 7.31 CDR stacking now
-- function modifier_aghsfort_rylai_brilliance_aura_fenzy:GetModifierPercentageCooldownStacking(event)
function modifier_aghsfort_rylai_brilliance_aura_fenzy:GetModifierPercentageCooldown(event)
    -- print(event.unit:GetName())
    if IsValid(event.ability) and not event.ability:IsItem() then
        -- print(event.ability:GetName())
        return self:GetAbility():getCooldownReduction() * self:GetStackCount()
    end
    return 0
end

function modifier_aghsfort_rylai_brilliance_aura_fenzy:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():getSpellAmp() * self:GetStackCount()
end
