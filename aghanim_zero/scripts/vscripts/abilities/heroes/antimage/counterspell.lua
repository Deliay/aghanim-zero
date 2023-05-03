require("abilities/heroes/antimage/legends")
aghsfort_antimage_counterspell = {}

LinkLuaModifier("modifier_aghsfort_antimage_spellshield", "abilities/heroes/antimage/counterspell",
    LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghsfort_antimage_counterspell", "abilities/heroes/antimage/counterspell",
    LUA_MODIFIER_MOTION_NONE)

function aghsfort_antimage_counterspell:GetIntrinsicModifierName()
    return "modifier_aghsfort_antimage_spellshield"
end

function aghsfort_antimage_counterspell:GetCooldown(iLevel)
    if self:GetCaster():IsIllusion() then
        return 0
    else
        return self.BaseClass.GetCooldown(self, iLevel)
    end
end

function aghsfort_antimage_counterspell:GetManaCost(iLevel)
    if self:GetCaster():IsIllusion() then
        return 0
    else
        return self.BaseClass.GetManaCost(self, iLevel)
    end
end

function aghsfort_antimage_counterspell:OnSpellStart()
    local caster = self:GetCaster()

    self:doAction({
        caster = caster,
        target = caster
    })

    if not caster:IsIllusion() then
        local illusion_ability = caster:FindAbilityByName("aghsfort_antimage_illusion")
        if illusion_ability ~= nil then
            illusion_ability:replicateCast("aghsfort_antimage_counterspell", {})
        end
    end
end

function aghsfort_antimage_counterspell:doAction(kv)
    if self:GetLevel() <= 0 then
        return
    end
    local modifier_table = {
        duration = self:GetSpecialValueFor("duration")
    }
    local caster = kv.caster or self:GetCaster()
    local target = kv.target or caster
    if IsValidNPC(target) and IsValidNPC(caster) then
        caster:EmitSound("Hero_Antimage.Counterspell.Cast")
        -- target:AddNewModifier(caster, self, "modifier_aghsfort_antimage_counterspell", modifier_table)
        -- self:turstarkuriGuardiance({
        --     target = caster
        -- })
        self:applyShield(caster, target, modifier_table)

        self:comprehensiveCounter({})

        if not caster:IsIllusion() and (kv.illusion_replicate or false) then
            local illusion_ability = caster:FindAbilityByName("aghsfort_antimage_illusion")
            if illusion_ability ~= nil then
                illusion_ability:replicateAction("aghsfort_antimage_counterspell", kv)
            end
        end
    end
end

function aghsfort_antimage_counterspell:applyShield(hCaster, hTarget, tModifier)
    hTarget:AddNewModifier(hCaster, self, "modifier_antimage_counterspell", tModifier)
    hTarget:AddNewModifier(hCaster, self, "modifier_lotus_orb_delay", tModifier)
    hTarget:AddNewModifier(hCaster, self, "modifier_item_lotus_orb_channel_check", tModifier)
    self:turstarkuriGuardiance({
        target = hTarget
    })
end

function aghsfort_antimage_counterspell:getMagicalResistanceBonus()
    local caster = self:GetCaster()
    return self:GetSpecialValueFor("magic_resistance") +
               GetTalentValue(caster, "aghsfort_antimage_counterspell+magical_resist")
end

function aghsfort_antimage_counterspell:comprehensiveCounter(kv)
    local caster = self:GetCaster()
    local shard_modifier = caster:FindModifierByName("modifier_aghsfort_antimage_legend_comprehensive_counter")
    if shard_modifier ~= nil then
        local shard = shard_modifier:GetAbility()
        print("comprehensive casting...")
        local radius = shard:GetSpecialValueFor("aura_radius") or 1200

        local ally_heroes = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), -- int, your team number
        caster:GetOrigin(), -- point, center point
        nil, -- handle, cacheUnit. (not known)
        radius, -- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, -- int, team filter
        DOTA_UNIT_TARGET_HERO, -- int, type filter\
        0, -- int, flag filter
        0, -- int, order filter
        false -- bool, can grow cache
        )

        local modifier_table = {
            duration = self:GetSpecialValueFor("duration")
        }

        print("comprehensive found:" .. (#ally_heroes))

        for _, ally in pairs(ally_heroes) do
            if (ally:IsIllusion() and not ally:HasModifier("modifier_aghsfort_antimage_illusion")) or
                (not ally:IsIllusion() and not ally:HasAbility("aghsfort_antimage_illusion")) then
                -- ally:AddNewModifier(caster, self, "modifier_aghsfort_antimage_counterspell", modifier_table)
                -- self:turstarkuriGuardiance({
                --     target = ally
                -- })
                self:applyShield(caster, ally, modifier_table)
            end
            -- if not ally:HasModifier("modifier_aghsfort_antimage_legend_comprehensive_counter")  then
            --     ally:AddNewModifier(caster, self, "modifier_aghsfort_antimage_counterspell", modifier_table)
            -- end
        end
    end
end

function aghsfort_antimage_counterspell:turstarkuriGuardiance(kv)
    local caster = self:GetCaster()
    local shard_modifier = caster:FindModifierByName("modifier_aghsfort_antimage_legend_turstarkuri_guardiance")
    if shard_modifier ~= nil and IsValid(kv.target) then
        local shard = shard_modifier:GetAbility()
        local duration = self:GetSpecialValueFor("duration") * (shard:GetSpecialValueFor("duration_multipiler") or 1.0)
        print("turstarkuri guardiance!")
        kv.target:AddNewModifier(caster, self, "modifier_aghsfort_antimage_turstarkuri_guardiance", {
            duration = duration
        })
    end
end

modifier_aghsfort_antimage_spellshield = {}

function modifier_aghsfort_antimage_spellshield:IsDebuff()
    return false
end
function modifier_aghsfort_antimage_spellshield:IsHidden()
    return true
end
function modifier_aghsfort_antimage_spellshield:IsPurgeable()
    return false
end
function modifier_aghsfort_antimage_spellshield:IsPurgeException()
    return false
end

function modifier_aghsfort_antimage_spellshield:OnCreated(tabel)
    self.magic_resistance = self:GetAbility():getMagicalResistanceBonus()
end

function modifier_aghsfort_antimage_spellshield:OnRefresh(table)
    self.magic_resistance = self:GetAbility():getMagicalResistanceBonus()
end

function modifier_aghsfort_antimage_spellshield:DeclareFunctions()
    return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_aghsfort_antimage_spellshield:GetModifierMagicalResistanceBonus()
    if not self:GetParent():PassivesDisabled() then
        return self.magic_resistance
    end
    return 0
end

modifier_aghsfort_antimage_counterspell = {}

function modifier_aghsfort_antimage_counterspell:IsPurgable()
    return true
end

function modifier_aghsfort_antimage_counterspell:OnCreated(table)
    if IsServer() then
        local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_counter.vpcf",
            PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        -- ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc",
            self:GetParent():GetAbsOrigin(), false)
        ParticleManager:SetParticleControl(pfx, 1, Vector(100, 0, 0))
        self:AddParticle(pfx, false, false, 20, false, false)
    end
end

function modifier_aghsfort_antimage_counterspell:DeclareFunctions()
    return {MODIFIER_PROPERTY_ABSORB_SPELL, MODIFIER_PROPERTY_REFLECT_SPELL}
end

function modifier_aghsfort_antimage_counterspell:GetAbsorbSpell(params)
    if IsServer() then
        self:playEffects(true)
        print("absorbed!")
        return 1
    end
end

modifier_aghsfort_antimage_counterspell.reflected_spell = nil
function modifier_aghsfort_antimage_counterspell:GetReflectSpell(params)
    if IsServer() then
        if params.ability == nil or self.reflect_exceptions[params.ability:GetAbilityName()] then
            return 0
        end

        -- use resources
        self.reflect = true

        -- remove previous ability
        if self.reflected_spell ~= nil then
            self:GetParent():RemoveAbilityByHandle(self.reflected_spell)
        end

        -- copy the ability
        local sourceAbility = params.ability
        local selfAbility = self:GetParent():AddAbility(sourceAbility:GetAbilityName())
        selfAbility:SetLevel(sourceAbility:GetLevel() or 1)
        selfAbility:SetStolen(true)
        selfAbility:SetHidden(true)

        -- store the ability
        self.reflected_spell = selfAbility

        -- cast the ability
        self:GetParent():SetCursorCastTarget(sourceAbility:GetCaster())
        selfAbility:CastAbility()

        -- play effects
        self:playEffects(false)
        print("reflected!")
        return 1
    end
end

function modifier_aghsfort_antimage_counterspell:playEffects(bBlock)
    -- Get Resources
    local particle_cast = ""
    local sound_cast = ""

    if bBlock then
        particle_cast = "particles/units/heroes/hero_antimage/antimage_spellshield.vpcf"
        sound_cast = "Hero_Antimage.SpellShield.Block"
    else
        particle_cast = "particles/units/heroes/hero_antimage/antimage_spellshield_reflect.vpcf"
        sound_cast = "Hero_Antimage.SpellShield.Reflect"
    end
    -- Play particles
    local pfx = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc",
        self:GetParent():GetOrigin(), -- unknown
        true -- unknown, true
    )
    ParticleManager:ReleaseParticleIndex(pfx)

    -- Play sounds
    EmitSoundOn(sound_cast, self:GetParent())
end

modifier_aghsfort_antimage_counterspell.reflect_exceptions = {
    ["rubick_spell_steal_lua"] = true
}

modifier_aghsfort_antimage_comprehensive_counter = {}

LinkLuaModifier("modifier_aghsfort_antimage_comprehensive_counter", "abilities/heroes/antimage/counterspell",
    LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_antimage_comprehensive_counter:DeclareFunctions()
    return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_aghsfort_antimage_comprehensive_counter:GetModifierMagicalResistanceBonus()
    local ability = self:GetAbility()
    local caster = ability:GetCaster()

    if not IsValidNPC(caster) or not IsValid(ability) then
        return 0
    end

    local magic_resist_ability = caster:FindAbilityByName("aghsfort_antimage_counterspell")
    if not IsValid(magic_resist_ability) then
        return 0
    end

    return magic_resist_ability:getMagicalResistanceBonus() * (ability:GetSpecialValueFor("aura_pct") or 0) * 0.01
end

modifier_aghsfort_antimage_turstarkuri_guardiance = {}

LinkLuaModifier("modifier_aghsfort_antimage_turstarkuri_guardiance", "abilities/heroes/antimage/counterspell",
    LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_antimage_turstarkuri_guardiance:IsDebuff()
    return false
end

function modifier_aghsfort_antimage_turstarkuri_guardiance:IsPurgable()
    return true
end

function modifier_aghsfort_antimage_turstarkuri_guardiance:OnCreated(kv)
    if IsServer() then
        local parent = self:GetParent()
        local pfx = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_antimage/antimage_turstarkuri_guardiance.vpcf", PATTACH_ABSORIGIN_FOLLOW,
            parent)
        -- ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControlEnt(pfx, 1, parent, PATTACH_POINT_FOLLOW, nil, parent:GetAbsOrigin(), false)
        ParticleManager:SetParticleControl(pfx, 4, Vector(0, 0, 100))
        self:AddParticle(pfx, false, false, 20, false, false)

        EmitSoundOn("Hero_TemplarAssassin.Refraction", parent)
        self:SetStackCount(1)
    end
end

function modifier_aghsfort_antimage_turstarkuri_guardiance:OnRefresh(kv)
    -- print("update stacking")
    if IsServer() then
        self:IncrementStackCount()
    end
end

function modifier_aghsfort_antimage_turstarkuri_guardiance:DeclareFunctions()
    return {MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
            MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE, MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_aghsfort_antimage_turstarkuri_guardiance:OnTakeDamage(kv)
    if not IsServer() then
        return
    end

    if kv.damage_category == DOTA_DAMAGE_CATEGORY_SPELL and kv.unit == self:GetParent() and kv.original_damage > 5 then
        self:playEffects()
        self:DecrementStackCount()
        if self:GetStackCount() <= 0 then
            self:GetParent():Purge(false, true, false, false, false)
            self:Destroy()
        end
    end
end

function modifier_aghsfort_antimage_turstarkuri_guardiance:GetAbsoluteNoDamageMagical(kv)
    if kv.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
        return 1
    end
    return 0
end
function modifier_aghsfort_antimage_turstarkuri_guardiance:GetAbsoluteNoDamagePhysical(kv)
    if kv.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
        return 1
    end
    return 0
end
function modifier_aghsfort_antimage_turstarkuri_guardiance:GetAbsoluteNoDamagePure(kv)
    if kv.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
        return 1
    end
    return 0
end

function modifier_aghsfort_antimage_turstarkuri_guardiance:playEffects()
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_templar_assassin/templar_assassin_refract_hit.vpcf"
    local sound_cast = "Hero_TemplarAssassin.Refraction.Absorb"

    -- Play particles
    local pfx = ParticleManager:CreateParticle(particle_cast, PATTACH_CUSTOMORIGIN, self:GetParent())
    ParticleManager:SetParticleControlEnt(pfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc",
        self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(pfx, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc",
        self:GetParent():GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(pfx, 2, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc",
        self:GetParent():GetAbsOrigin(), true)
    ParticleManager:ReleaseParticleIndex(pfx)

    -- Play sounds
    EmitSoundOn(sound_cast, self:GetParent())
end

modifier_aghsfort_antimage_arcande_discipliner = {}

LinkLuaModifier("modifier_aghsfort_antimage_arcande_discipliner", "abilities/heroes/antimage/counterspell",
    LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_antimage_arcande_discipliner:IsHidden()
    return true
end

function modifier_aghsfort_antimage_arcande_discipliner:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_aghsfort_antimage_arcande_discipliner:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ABILITY_START}
end

function modifier_aghsfort_antimage_arcande_discipliner:OnAbilityStart(kv)
    if IsServer() then
        local attacker = self:GetCaster()
        local target = self:GetParent()
        local caster = kv.ability:GetCaster()
        if not kv.ability:IsItem() and IsValid(attacker) and caster == target then
            local counter_ability = attacker:FindAbilityByName("aghsfort_antimage_counterspell")
            if IsValid(counter_ability) then
                local chance = counter_ability:GetSpecialValueFor("magic_resistance") or 0
                if RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_3, attacker) == true then
                    print("antimage charges you!")
                    attacker:PerformAttack(target, true, true, true, true, false, false, true)
                    if not attacker:IsIllusion() then
                        local illusion_ability = attacker:FindAbilityByName("aghsfort_antimage_illusion")
                        if IsValid(illusion_ability) then
                            local result = illusion_ability:doAction({
                                position = target:GetAbsOrigin(),
                            })
                            result.new_illusion:EmitSound("DOTA_Item.Manta.Activate")
                            result.new_illusion:MoveToTargetToAttack(target)
                        end
                    end
                end
            end
        end
    end
end
