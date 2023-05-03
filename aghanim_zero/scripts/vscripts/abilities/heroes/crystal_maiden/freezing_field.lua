require("abilities/heroes/crystal_maiden/legends")
aghsfort_rylai_freezing_field = {}

LinkLuaModifier("modifier_aghsfort_rylai_freezing_field", "abilities/heroes/crystal_maiden/freezing_field",
    LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghsfort_rylai_freezing_field_debuff", "abilities/heroes/crystal_maiden/freezing_field",
    LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
function aghsfort_rylai_freezing_field:GetBehavior()
    if self:GetCaster():HasModifier("modifier_aghsfort_rylai_legend_letgo") then
        -- if self:GetToggleState() then
        --     return DOTA_ABILITY_BEHAVIOR_AUTOCAST + DOTA_ABILITY_BEHAVIOR_NO_TARGET +
        --                 DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
        -- end
        return DOTA_ABILITY_BEHAVIOR_AUTOCAST + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET +
                   DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_CAN_SELF_CAST
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
end

function aghsfort_rylai_freezing_field:CastFilterResultTarget(hTarget)
    local team_num = self:GetCaster():GetTeamNumber()
    if hTarget:GetTeamNumber() ~= team_num then
        return UF_FAIL_ENEMY
    end
end

function aghsfort_rylai_freezing_field:GetCastRange()
    if self:GetCaster():HasModifier("modifier_aghsfort_rylai_legend_letgo") then
        return self:GetSpecialValueFor("radius") + self:GetCaster():GetCastRangeBonus()
    end
    return self:GetSpecialValueFor("radius")
end

function aghsfort_rylai_freezing_field:GetChannelTime()
    if self:GetCaster():HasModifier("modifier_aghsfort_rylai_legend_letgo") then
        return 0
    end
    return self:GetSpecialValueFor("channel_time")
end

-- Ability Start
function aghsfort_rylai_freezing_field:OnSpellStart()
    -- unit identifier
    local caster = self:GetCaster()

    if self:GetCaster():HasModifier("modifier_aghsfort_rylai_legend_letgo") then
        print("let it go!")
        local target = self:GetCursorTarget()
        if IsValidNPC(target) then
            if self:GetAutoCastState() then
                target:AddNewModifier(caster, self, "modifier_rylai_let_it_go", {
                    duration = self:GetSpecialValueFor("channel_time")
                })
            end
            self:doAction({
                target = target,
                duration = self:GetSpecialValueFor("channel_time")
            })
        end
    else
        if IsValid(self.ability_modifier) then
            self.ability_modifier:Destroy()
        end

        local result = self:doAction({
            target = caster,
            duration = self:GetChannelTime()
        })
        self.ability_modifier = result.hModifier
    end
end

--------------------------------------------------------------------------------
-- Ability Channeling

function aghsfort_rylai_freezing_field:OnChannelFinish(bInterrupted)
    if IsServer() and IsValid(self.ability_modifier) then
        -- self:GetCaster():RemoveModifierByName("modifier_aghsfort_rylai_freezing_field")
        self.ability_modifier:Destroy()
    end
end

-- Ability Start
function aghsfort_rylai_freezing_field:doAction(kv)
    if self:GetLevel() <= 0 then
        return 
    end
    -- unit identifier
    local caster = self:GetCaster()
    local target = kv.target
    local duration = kv.duration
    local result = {}

    print("start freezing:" .. duration)
    if IsServer() and kv.duration > 0.1 and IsValidNPC(target) then
        -- Add modifier
        result.hModifier = target:AddNewModifier(caster, -- player source
        self, -- ability source
        "modifier_aghsfort_rylai_freezing_field", -- modifier name
        {
            duration = duration
        } -- kv
        )
    end
    return result
end

modifier_aghsfort_rylai_freezing_field = {}

--------------------------------------------------------------------------------
-- Classifications
function modifier_aghsfort_rylai_freezing_field:IsHidden()
    return false
end

function modifier_aghsfort_rylai_freezing_field:IsDebuff()
    return false
end

function modifier_aghsfort_rylai_freezing_field:IsPurgable()
    return false
end

-- function modifier_aghsfort_rylai_freezing_field:GetAttributes()
--     return MODIFIER_ATTRIBUTE_MULTIPLE
-- end

--------------------------------------------------------------------------------
-- Aura
function modifier_aghsfort_rylai_freezing_field:IsAura()
    return true
end

function modifier_aghsfort_rylai_freezing_field:GetModifierAura()
    return "modifier_aghsfort_rylai_freezing_field_debuff"
end

function modifier_aghsfort_rylai_freezing_field:GetAuraRadius()
    return self.slow_radius
end

function modifier_aghsfort_rylai_freezing_field:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_aghsfort_rylai_freezing_field:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_aghsfort_rylai_freezing_field:GetAuraDuration()
    return self.slow_duration
end
--------------------------------------------------------------------------------
-- Initializations
function modifier_aghsfort_rylai_freezing_field:OnCreated(kv)
    -- references
    if IsServer() then
        local ability = self:GetAbility()
        self.slow_radius = ability:GetSpecialValueFor("radius")
        self.explosion_radius = ability:GetSpecialValueFor("explosion_radius")
        self.explosion_interval = ability:GetSpecialValueFor("explosion_interval")
        self.explosion_min_dist = ability:GetSpecialValueFor("explosion_min_dist")
        self.explosion_max_dist = ability:GetSpecialValueFor("explosion_max_dist")
        local explosion_damage = ability:GetSpecialValueFor("damage") +
                                     GetTalentValue(ability:GetCaster(), "aghsfort_rylai_freezing_field+damage")

        self.caster = self:GetCaster()
        self.nova_chance = 0
        local shard = self.caster:FindAbilityByName("aghsfort_rylai_legend_nova_storm")
        if IsValid(shard) then
            self.nova_chance = shard:GetSpecialValueFor("chance")
            self.nova = self.caster:FindAbilityByName("aghsfort_rylai_crystal_nova")
            print("nova storm comming.." .. self.nova_chance)
        end
        -- generate data
        self.quartal = RandomInt(0, 3)

        -- precache damage
        self.damageTable = {
            -- victim = target,
            attacker = self:GetCaster(),
            damage = explosion_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = ability,
			damage_category = DOTA_DAMAGE_CATEGORY_SPELL
        }

        -- Start interval
        self:StartIntervalThink(self.explosion_interval)
        self:OnIntervalThink()

        -- Play Effects
        self:PlayEffects1()
    end
end

function modifier_aghsfort_rylai_freezing_field:OnDestroy(kv)
    if IsServer() then
        self:StartIntervalThink(-1)
        self:StopEffects1()
    end
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_aghsfort_rylai_freezing_field:OnIntervalThink()
    -- Set explosion quartal
    self.quartal = self.quartal + 1
    if self.quartal > 3 then
        self.quartal = 0
    end

    -- determine explosion relative position
    local a = RandomInt(0, 90) + self.quartal * 90
    local r = RandomInt(self.explosion_min_dist, self.explosion_max_dist)
    local point = Vector(math.cos(a), math.sin(a), 0):Normalized() * r

    -- actual position
    point = self:GetParent():GetOrigin() + point

    self:novaStorm()

    -- Explode at point
    local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), -- int, your team number
    point, -- point, center point
    nil, -- handle, cacheUnit. (not known)
    self.explosion_radius, -- float, radius. or use FIND_UNITS_EVERYWHERE
    DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
    0, -- int, flag filter
    0, -- int, order filter
    false -- bool, can grow cache
    )

    -- damage units
    for _, enemy in pairs(enemies) do
        self.damageTable.victim = enemy
        -- print(self.damageTable.attacker:GetName())
        ApplyDamage(self.damageTable)
    end

    -- Play effects
    self:PlayEffects2({
        pos = point
    })
end

function modifier_aghsfort_rylai_freezing_field:novaStorm(kv)
    if self.nova_chance ~= 0 and IsValid(self.nova) then
        if RollPseudoRandomPercentage(self.nova_chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_4, self.caster) == true then
            -- determine explosion relative position
            local a = RandomInt(0, 90) + self.quartal * 90
            local r = RandomInt(self.explosion_min_dist, self.explosion_max_dist)
            local point = Vector(math.cos(a), math.sin(a), 0):Normalized() * r

            -- actual position
            point = self:GetParent():GetOrigin() + point
            point = GetGroundPosition(point,nil)
            self.nova:doAction({
                caster = self.caster,
                pos = point
            })
        end

    end
end

function modifier_aghsfort_rylai_freezing_field:DeclareFunctions()
    return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_aghsfort_rylai_freezing_field:GetModifierPhysicalArmorBonus()
    return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

--------------------------------------------------------------------------------
-- Effects
function modifier_aghsfort_rylai_freezing_field:PlayEffects1()
    local pfx_name = "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_snow.vpcf"
    self.sound_cast = "hero_Crystal.freezingField.wind"

    -- Create Particle
    self.pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    -- self.pfx = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, pfx_name, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
    ParticleManager:SetParticleControl(self.pfx, 1, Vector(self.slow_radius, self.slow_radius, 1))
    self:AddParticle(self.pfx, false, false, -1, false, false)

    -- Play sound
    EmitSoundOn(self.sound_cast, self:GetParent())
end

function modifier_aghsfort_rylai_freezing_field:PlayEffects2(kv)
    -- Play particles
    local pfx_name = "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf"

    local position = GetGroundPosition(kv.pos, nil)

    -- Create particle
    local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_WORLDORIGIN, nil)
    -- local pfx = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, pfx_name, PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl(pfx, 0, position)

    -- Play sound
    local sfx = "hero_Crystal.freezingField.explosion"
    EmitSoundOnLocationWithCaster(position, sfx, self:GetParent())
end

function modifier_aghsfort_rylai_freezing_field:StopEffects1()
    StopSoundOn(self.sound_cast, self:GetParent())
end

modifier_aghsfort_rylai_freezing_field_debuff = {}

--------------------------------------------------------------------------------
-- Classifications
function modifier_aghsfort_rylai_freezing_field_debuff:IsPurgable()
    return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_aghsfort_rylai_freezing_field_debuff:OnCreated(kv)
    -- references
    self.ms_slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")
    self.as_slow = self:GetAbility():GetSpecialValueFor("attack_slow")

    if IsServer() then
        self.caster = self:GetCaster()
        local shard = self.caster:FindAbilityByName("aghsfort_rylai_legend_absolute_zero")
        self.frost = self.caster:FindAbilityByName("aghsfort_rylai_frostbite")
        if IsValid(shard) and IsValid(self.frost) then
            print("absolute zero!")
            self.delay = shard:GetSpecialValueFor("delay")
            self:StartIntervalThink(shard:GetSpecialValueFor("interval"))
            self:OnIntervalThink()
        end
    end
end

function modifier_aghsfort_rylai_freezing_field_debuff:OnRefresh(kv)
    -- references
    self.ms_slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")
    self.as_slow = self:GetAbility():GetSpecialValueFor("attack_slow")
end

function modifier_aghsfort_rylai_freezing_field_debuff:OnIntervalThink()
    if IsServer() then
        print(self:GetParent():GetName().."!")
        if self.frost:GetLevel() > 0 then
            self:GetParent():AddNewModifier(self:GetCaster(), self.frost, "modifier_rylai_absolute_zero", {
                duration = self.delay
            })
        end
    end
end

function modifier_aghsfort_rylai_freezing_field_debuff:OnDestroy(kv)
    if IsServer() then
        absolute_zero_mod = self:GetParent():FindModifierByName("modifier_rylai_absolute_zero")
        if IsValid(absolute_zero_mod) then
            absolute_zero_mod:Destroy()
        end
    end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_aghsfort_rylai_freezing_field_debuff:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}

    return funcs
end

function modifier_aghsfort_rylai_freezing_field_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.ms_slow
end

function modifier_aghsfort_rylai_freezing_field_debuff:GetModifierAttackSpeedBonus_Constant()
    return self.as_slow
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_aghsfort_rylai_freezing_field_debuff:GetEffectName()
    return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_aghsfort_rylai_freezing_field_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
