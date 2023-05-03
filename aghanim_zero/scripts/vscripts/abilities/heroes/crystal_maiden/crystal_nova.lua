require("abilities/heroes/crystal_maiden/legends")
aghsfort_rylai_crystal_nova = {}

function aghsfort_rylai_crystal_nova:GetCooldown(iLevel)
    local cooldown = self.BaseClass.GetCooldown(self, iLevel) -
                         GetTalentValue(self:GetCaster(), "aghsfort_rylai_crystal_nova-cd")
    return math.max(cooldown, 0)
end

function aghsfort_rylai_crystal_nova:GetAOERadius()
    return self:GetSpecialValueFor("radius") + GetTalentValue(self:GetCaster(), "aghsfort_rylai_crystal_nova+radius")
end

function aghsfort_rylai_crystal_nova:OnSpellStart()
    local caster = self:GetCaster()
    local pos = self:GetCursorPosition()
    self:doAction({
        caster = caster,
        pos = pos
    })
end

function aghsfort_rylai_crystal_nova:doAction(kv)
    if not IsValidNPC(kv.caster) then
        return
    end
    if self:GetLevel() <= 0 then
        return 
    end

    local percentage = kv.percentage or 1.0
    local damage = self:getDamage() * percentage
    local radius = self:GetAOERadius() * percentage
    local vision_duration = self:GetSpecialValueFor("vision_duration")
    local duration = self:GetSpecialValueFor("duration")
    local caster = kv.caster
    local pos = kv.pos
    local team = caster:GetTeamNumber()

    local damageTable = {
        attacker = caster,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self
    }
    EmitSoundOn("Hero_Ancient_Apparition.IceVortexCast", caster)
    AddFOWViewer(team, pos, radius, vision_duration, false)
    local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_crystal_nova.vpcf",
        PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(pfx, 0, pos)
    ParticleManager:SetParticleControl(pfx, 1, Vector(radius, duration, radius))
    ParticleManager:SetParticleControl(pfx, 2, pos)
    ParticleManager:ReleaseParticleIndex(pfx)

    self:makeSnowman({
        pos = pos,
        percentage = percentage
    })

    local enemies = FindUnitsInRadius(team, pos, caster, radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    if #enemies > 0 then
        self:novaStrike({
            enemies = enemies
        })
        for _, target in pairs(enemies) do
            damageTable.victim = target
            damageTable.damage = damage
            ApplyDamage(damageTable)
            AddModifierConsiderResist(target, caster, self, "modifier_aghsfort_rylai_crystal_nova_debuff", {
                duration = duration
            })
        end
    end

    self:crystalField({
        pos = pos,
        duration = duration,
        percentage = percentage
    })

    EmitSoundOn("Hero_Crystal.CrystalNova", caster)
end

function aghsfort_rylai_crystal_nova:getDamage()
    return self:GetSpecialValueFor("nova_damage") +
               GetTalentValue(self:GetCaster(), "aghsfort_rylai_crystal_nova+damage")
end

function aghsfort_rylai_crystal_nova:makeSnowman(kv)
    if IsServer() then
        local caster = self:GetCaster()
        local shard = caster:FindAbilityByName("aghsfort_rylai_legend_snowman")
        if IsValid(shard) then
            local duration = self:GetSpecialValueFor("duration") + shard:GetSpecialValueFor("extra_duration")
            local extra_health = self:GetAOERadius() * shard:GetSpecialValueFor("health_factor")
            CreateUnitByNameAsync("npc_dota_rylai_ice_golem", kv.pos, true, caster, caster, DOTA_TEAM_GOODGUYS,
                function(yeti)
                    yeti:SetModelScale(yeti:GetModelScale() * kv.percentage)
                    yeti:SetBaseMaxHealth((yeti:GetMaxHealth() + extra_health) * kv.percentage)
                    yeti:SetControllableByPlayer(caster:GetPlayerID(), true)
                    yeti:AddNewModifier(caster, self, "modifier_rylai_yeti_init", {})
                    yeti:AddNewModifier(caster, self, "modifier_kill", {
                        duration = duration
                    })
                end)
        end
    end
end

function aghsfort_rylai_crystal_nova:novaStrike(kv)
    if IsServer() then
        local caster = self:GetCaster()
        local shard = caster:FindAbilityByName("aghsfort_rylai_legend_nova_strike")
        if IsValid(shard) and #kv.enemies > 0 then
            for _, target in pairs(kv.enemies) do
                caster:PerformAttack(target, true, true, true, false, true, false, false)
            end
        end
    end
end

function aghsfort_rylai_crystal_nova:crystalField(kv)
    if IsServer() then
        local caster = self:GetCaster()
        local shard = caster:FindAbilityByName("aghsfort_rylai_legend_crystal_field")
        if IsValid(shard) then
            CreateModifierThinker(caster, self, "modifier_rylai_crystal_field_thinker", {
                duration = kv.duration,
                percentage = kv.percentage
            }, kv.pos, caster:GetTeamNumber(), false)
        end
    end
end

LinkLuaModifier("modifier_aghsfort_rylai_crystal_nova_debuff", "abilities/heroes/crystal_maiden/crystal_nova",
    LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_rylai_crystal_nova_debuff = {}

function modifier_aghsfort_rylai_crystal_nova_debuff:IsPurgable()
    return true
end

function modifier_aghsfort_rylai_crystal_nova_debuff:OnCreated(kv)
    self.as_slow = self:GetAbility():GetSpecialValueFor("attackspeed_slow")
    self.ms_slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")
    -- print(self.ms_slow..self.as_slow)
end

function modifier_aghsfort_rylai_crystal_nova_debuff:OnRefresh(kv)
    self.as_slow = self:GetAbility():GetSpecialValueFor("attackspeed_slow")
    self.ms_slow = self:GetAbility():GetSpecialValueFor("movespeed_slow")
    -- print(self.ms_slow..self.as_slow)
end

function modifier_aghsfort_rylai_crystal_nova_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_aghsfort_rylai_crystal_nova_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.ms_slow
end

function modifier_aghsfort_rylai_crystal_nova_debuff:GetModifierAttackSpeedBonus_Constant()
    return self.as_slow
end

function modifier_aghsfort_rylai_crystal_nova_debuff:GetEffectName()
    return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

function modifier_aghsfort_rylai_crystal_nova_debuff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

modifier_rylai_yeti_init = {}

LinkLuaModifier("modifier_rylai_yeti_init", "abilities/heroes/crystal_maiden/crystal_nova", LUA_MODIFIER_MOTION_NONE)

function modifier_rylai_yeti_init:IsHidden()
    return true
end
function modifier_rylai_yeti_init:IsPurgable()
    return false
end
function modifier_rylai_yeti_init:IsPurgeException()
    return false
end

-- Table
-- ms_bonus
-- as_bonus
-- atk_bonus
function modifier_rylai_yeti_init:OnCreated(kv)
    -- print("summoned!")
    self.ms_bonus = 0
    self.as_bonus = 0
    self.atk_bonus = 0
    local ability = self:GetAbility()
    local caster = self:GetCaster()
    local shard = caster:FindAbilityByName("aghsfort_rylai_legend_snowman")
    if shard ~= nil then
        self.as_bonus = ability:GetSpecialValueFor("attackspeed_slow") * shard:GetSpecialValueFor("as_factor")
        self.ms_bonus = ability:GetSpecialValueFor("movespeed_slow") * shard:GetSpecialValueFor("ms_factor")
        self.atk_bonus = (ability:GetSpecialValueFor("nova_damage") +
                             GetTalentValue(caster, "aghsfort_rylai_crystal_nova+damage")) *
                             shard:GetSpecialValueFor("atk_factor")
    end

end

function modifier_rylai_yeti_init:DeclareFunctions()
    return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
            MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_HEALTH_BONUS}
end

function modifier_rylai_yeti_init:GetModifierPreAttack_BonusDamage()
    return self.atk_bonus
end

function modifier_rylai_yeti_init:GetModifierMoveSpeedBonus_Percentage()
    -- print(self.ms_bonus)
    return self.ms_bonus
end

function modifier_rylai_yeti_init:GetModifierAttackSpeedBonus_Constant()
    -- print(self.as_bonus)
    return self.as_bonus
end

-- Crystal Nova ground thinker
modifier_rylai_crystal_field_thinker = {}

LinkLuaModifier("modifier_rylai_crystal_field_thinker", "abilities/heroes/crystal_maiden/crystal_nova",
    LUA_MODIFIER_MOTION_NONE)

function modifier_rylai_crystal_field_thinker:IsDebuff()
    return true
end

function modifier_rylai_crystal_field_thinker:IsHidden()
    return true
end

function modifier_rylai_crystal_field_thinker:IsPurgable()
    return false
end

function modifier_rylai_crystal_field_thinker:IsAura()
    return true
end

function modifier_rylai_crystal_field_thinker:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_rylai_crystal_field_thinker:GetAuraSearchType()
    return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_rylai_crystal_field_thinker:GetAuraDuration()
    return 1.0
end

function modifier_rylai_crystal_field_thinker:GetAuraRadius()
    return self.radius
end

function modifier_rylai_crystal_field_thinker:GetModifierAura()
    return "modifier_rylai_crystal_field_debuff"
end

function modifier_rylai_crystal_field_thinker:OnCreated(kv)
    if IsServer() then
        local tick_damage = 0
        local tick_interval = 0.5

        self.ability = self:GetAbility()
        self.caster = self:GetCaster()
        self.duration = self:GetDuration()

        self.radius = self.ability:GetAOERadius() * kv.percentage
        self.team_num = self:GetParent():GetTeamNumber()

        local shard = self.caster:FindAbilityByName("aghsfort_rylai_legend_crystal_field")
        if IsValid(shard) then
            tick_interval = shard:GetSpecialValueFor("tick_interval")
            tick_damage = self.ability:getDamage() * shard:GetSpecialValueFor("damage_pct") * 0.01 * tick_interval
        end

        self.damageTable = {
            damage = tick_damage,
            attacker = self.caster,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self.ability
        }
        if not IsServer() then
            return
        end

        self.pos = self:GetParent():GetAbsOrigin()
        local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_rylai/rylai_nova_vortex.vpcf",
            PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(pfx, 0, self.pos)
        ParticleManager:SetParticleControl(pfx, 5, Vector(self.radius, self.radius, self.radius))
        self:AddParticle(pfx, false, false, 20, false, false)
        self:StartIntervalThink(tick_interval)
    end
end

function modifier_rylai_crystal_field_thinker:OnIntervalThink()
    if IsServer() then
        local enemies = FindUnitsInRadius(self.team_num, self.pos, self.ability, self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER, true)
        if #enemies > 0 then
            for _, enemy in pairs(enemies) do
                self.damageTable.victim = enemy
                ApplyDamage(self.damageTable)
                AddModifierConsiderResist(enemy, self.caster, self.ability,
                    "modifier_aghsfort_rylai_crystal_nova_debuff", {
                        duration = self.duration
                    })
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, enemy, self.damageTable.damage, nil)
            end
        end
    end
end

modifier_rylai_crystal_field_debuff = {}

LinkLuaModifier("modifier_rylai_crystal_field_debuff", "abilities/heroes/crystal_maiden/crystal_nova",
    LUA_MODIFIER_MOTION_NONE)

function modifier_rylai_crystal_field_debuff:IsPurgable()
    return true
end

function modifier_rylai_crystal_field_debuff:OnCreated(kv)
    local ability = self:GetAbility()
    self.mr_reduction = 0
    local shard = ability:GetCaster():FindAbilityByName("aghsfort_rylai_legend_crystal_field")
    if IsValid(shard) then
        self.mr_reduction =
            ability:GetSpecialValueFor("movespeed_slow") * shard:GetSpecialValueFor("magic_resist_pct") * 0.01
    end
end

function modifier_rylai_crystal_field_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_rylai_crystal_field_debuff:GetModifierMagicalResistanceBonus()
    -- print(self.mr_reduction)
    return self.mr_reduction
end
