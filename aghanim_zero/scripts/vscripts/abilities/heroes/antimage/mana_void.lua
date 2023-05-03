require("abilities/heroes/antimage/legends")
aghsfort_antimage_mana_void = {}

function aghsfort_antimage_mana_void:CastFilterResultTarget(target)
    if not self:GetCaster():HasModifier("modifier_aghsfort_antimage_legend_mana_release") then
        if self:GetCaster():GetTeamNumber() == target:GetTeamNumber() then
            return UF_FAIL_FRIENDLY
        end
    end
    return UF_SUCCESS
end

function aghsfort_antimage_mana_void:GetAOERadius()
    return self:GetSpecialValueFor("aoe_radius")
end

function aghsfort_antimage_mana_void:OnAbilityPhaseStart()
    local target = self:GetCursorTarget()
    self:playEffects1(true)

    return true -- if success
end

function aghsfort_antimage_mana_void:OnAbilityPhaseInterrupted()
    self:playEffects1(false)
end

function aghsfort_antimage_mana_void:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    self:doAction({
        caster = caster,
        target = target,
        percentage = 1.0
    })
end

function aghsfort_antimage_mana_void:GetCooldown(iLevel)
    local cooldown = self.BaseClass.GetCooldown(self, iLevel)
    local talent_cd = GetTalentValue(self:GetCaster(), "aghsfort_antimage_mana_void-cd")
    if talent_cd ~= nil then
        cooldown = cooldown - talent_cd
    end
    -- print(cooldown)
    return math.max(cooldown, 0)
end

function aghsfort_antimage_mana_void:doAction(kv)
    if self:GetLevel() <= 0 then
        return 
    end
    
    if not IsServer() then
        return
    end

    local target = kv.target
    local caster = kv.caster
    local percentage = kv.percentage
    local secondary = kv.secondary or false
    local caster_team = caster:GetTeamNumber()
    local target_team = target:GetTeamNumber()

    -- load data
    local base_damage = self:GetSpecialValueFor("base_damage") +
                            GetTalentValue(caster, "aghsfort_antimage_mana_void+base_damage")
    local mana_damage_pct = self:GetSpecialValueFor("damage_per_mana")
    local mini_stun = self:GetSpecialValueFor("ministun") +
                          GetTalentValue(caster, "aghsfort_antimage_mana_void+ministun")
    local radius = self:GetSpecialValueFor("aoe_radius")

    print("doing mana void")
    -- Get damage value
    local damage = (target:GetMaxMana() - target:GetMana()) * mana_damage_pct + base_damage

    -- percentage apply
    damage = damage * percentage
    radius = radius * percentage
    mini_stun = mini_stun * percentage
    print("radius:" .. radius)

    if caster_team ~= target_team then
        -- Add modifier
        AddModifierConsiderResist(target, caster, self, "modifier_stunned", {
            duration = mini_stun
        })
        damage = damage * (1 + self:abilityBan({caster = caster,target = target,is_debuff = true, percentage=percentage}))
    else
        damage = damage * (1 + self:abilityBan({caster = caster,target = target,is_debuff = false, percentage=percentage}))
        target:Heal(damage, self)
        target:SetMana(target:GetMaxMana())
    end

    -- Apply Damage	 
    local damageTable = {
        victim = target,
        attacker = caster,
        damage = damage,
        damage_type = self:GetAbilityDamageType(),
        ability = self -- Optional.
    }

    -- Find Units in Radius
    local affected_npcs = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), -- int, your team number
    target:GetOrigin(), -- point, center point
    nil, -- handle, cacheUnit. (not known)
    radius, -- float, radius. or use FIND_UNITS_EVERYWHERE
    DOTA_UNIT_TARGET_TEAM_BOTH, -- int, team filter
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
    0, -- int, flag filter
    0, -- int, order filter
    false -- bool, can grow cache
    )

    for _, npc in pairs(affected_npcs) do
        if IsValid(npc) then
            if npc:GetTeamNumber() ~= caster_team then
                damageTable.victim = npc
                ApplyDamage(damageTable)
                if not secondary then
                    self:secondaryVoid({
                        caster = caster,
                        target = npc,
                        percentage = percentage,
                    })
                end
            else
                if caster:HasModifier("modifier_aghsfort_antimage_legend_mana_release") then
                    if not secondary then
                        self:secondaryVoid({
                            caster = caster,
                            target = npc,
                            percentage = percentage,
                        })
                    end
                end
            end
        end
    end

    -- Play Effects
    self:playEffects2(target, radius)
end

function aghsfort_antimage_mana_void:secondaryVoid(kv)
    local caster = kv.caster
    local target = kv.target
    local shard_modifier = caster:FindModifierByName("modifier_aghsfort_antimage_legend_secondary_void")
    if shard_modifier ~= nil then
        local shard = shard_modifier:GetAbility()
        kv.target:AddNewModifier(caster, self, "modifier_aghsfort_antimage_secondary_void", 
        {
            percentage =shard:GetSpecialValueFor("effect_pct") * 0.01 * (kv.percentage or 0),
            duration = shard:GetSpecialValueFor("delay") or 3.0,
        })
    end
end

function aghsfort_antimage_mana_void:abilityBan(kv)
    local caster = kv.caster
    local target = kv.target

    local shard_modifier = caster:FindModifierByName("modifier_aghsfort_antimage_legend_ability_ban")
    if shard_modifier ~= nil then
        local shard = shard_modifier:GetAbility()

        local result = GetLongestCooldownRemainingAbility(target)
        local cd_change = shard:GetSpecialValueFor("cd_change") or 0
        cd_change = cd_change * (kv.percentage or 1)
        if not kv.is_debuff then
            cd_change = -cd_change
        end

        if IsValid(result.ability) then
            local cooldown = AddCooldown(result.ability, cd_change)
            return cooldown * (shard:GetSpecialValueFor("cd_damage_amp") or 0) * 0.01
        end
    end
    return 0
end

function aghsfort_antimage_mana_void:playEffects1(bStart)
    local sfx = "Hero_Antimage.ManaVoidCast"

    if bStart then
        self.target = self:GetCursorTarget()
        EmitSoundOn(sfx, self.target)
    else
        StopSoundOn(sfx, self.target)
        self.target = nil
    end
end

function aghsfort_antimage_mana_void:playEffects2(target, radius)
    -- Get Resources
    local pfx_name = "particles/units/heroes/hero_antimage/antimage_manavoid.vpcf"
    local sfx = "Hero_Antimage.ManaVoid"

    -- Create Particle
    -- local effect_target = ParticleManager:CreateParticle( pfx, PATTACH_POINT_FOLLOW, target )
    -- local effect_target = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, pfx, PATTACH_POINT_FOLLOW, target )
    -- ParticleManager:SetParticleControl( effect_target, 1, Vector( radius, 0, 0 ) )
    -- ParticleManager:ReleaseParticleIndex( effect_target )
    local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(pfx, 0,
        target:GetAttachmentOrigin(target:ScriptLookupAttachment("attach_hitloc")))
    ParticleManager:SetParticleControl(pfx, 1, Vector(radius, 0, 0))
    ParticleManager:ReleaseParticleIndex(pfx)

    -- Create Sound
    EmitSoundOn(sfx, target)
end


modifier_aghsfort_antimage_secondary_void={}

LinkLuaModifier("modifier_aghsfort_antimage_secondary_void", "abilities/heroes/antimage/mana_void",LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_antimage_secondary_void:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_aghsfort_antimage_secondary_void:OnCreated(kv)
    if IsServer() then
        self.percentage = kv.percentage
        print("create delay")
    end
end

function modifier_aghsfort_antimage_secondary_void:OnDestroy()
    if IsServer() then        
        local ability = self:GetAbility()
        if IsValid(ability) then
            print("due!")
            ability:doAction({
                caster = self:GetCaster(),
                target = self:GetParent(),
                percentage = self.percentage,
                secondary = true,
            })
        end
    end
end
