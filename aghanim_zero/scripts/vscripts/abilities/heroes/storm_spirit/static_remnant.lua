aghsfort_storm_spirit_static_remnant = {}

-- 这是一个假的thinker，实际上是绑在npc_dota_stormspirit_remnant，而不是npc_modifier_thinker
LinkLuaModifier("modifier_aghsfort_storm_spirit_static_remnant_thinker", "abilities/heroes/storm_spirit/static_remnant",
    LUA_MODIFIER_MOTION_NONE)

function aghsfort_storm_spirit_static_remnant:GetBehavior()
    if IsValid(self.shard_taunt) then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_AUTOCAST
    end
    return DOTA_ABILITY_BEHAVIOR_NO_TARGET
end

function aghsfort_storm_spirit_static_remnant:GetCooldown(iLevel)
    local cooldown = self.BaseClass.GetCooldown(self, iLevel) - GetTalentValue(self:GetCaster(),"storm_spirit_static_remnant-cd")
    return math.max(cooldown, 0)
end

function aghsfort_storm_spirit_static_remnant:OnSpellStart()
    local caster = self:GetCaster()
    local pos = caster:GetAbsOrigin()
    self:doAction({
        caster = caster,
        pos = pos,
    })
end

function aghsfort_storm_spirit_static_remnant:doAction(kv)
    if self:GetLevel() < 1 then
        return
    end
    local caster = kv.caster
    local pos = kv.pos
    local scale = 1.0
    local duration = self:GetSpecialValueFor("duration")
    local model_scale = caster:GetModelScale()
    local vision_range = self:GetSpecialValueFor("vision_range")
    local damage = self:GetSpecialValueFor("static_remnant_damage") + GetTalentValue(caster, "storm_spirit_static_remnant+dmg")

    if IsValid(self.shard_giant) then
        if self.shard_giant:updateCounter() then
            scale = self.shard_giant:GetSpecialValueFor("scale")
        end
    end

    local finale_delay = 0
    if IsValid(self.shard_taunt)  then
        if self:GetAutoCastState() then
            finale_delay = self.shard_taunt:GetSpecialValueFor("finale_delay")
        end
    end

    caster:EmitSound("Hero_StormSpirit.StaticRemnantPlant")

    CreateUnitByNameAsync("npc_dota_stormspirit_remnant", pos, true, caster, caster, caster:GetTeamNumber(),
    function(remnant)
        remnant:SetModelScale(model_scale * scale)
        remnant:SetDayTimeVisionRange(vision_range * scale)
        remnant:SetNightTimeVisionRange(vision_range * scale)
        remnant:AddNewModifier(remnant, nil, "modifier_invulnerable", {})
        remnant:AddNewModifier(remnant, nil, "modifier_no_healthbar", {})
        remnant:AddNewModifier(remnant, nil, "modifier_kill", {
            duration = duration
        })
        remnant:AddNewModifier(caster, self, "modifier_aghsfort_storm_spirit_static_remnant_thinker",
            {
                duration = duration,
                model_scale = model_scale,
                damage = damage,
                scale = scale,
                finale_delay = finale_delay
            })
    end)
end

modifier_aghsfort_storm_spirit_static_remnant_thinker = {}

function modifier_aghsfort_storm_spirit_static_remnant_thinker:CheckState()
    return {
        [MODIFIER_STATE_FORCED_FLYING_VISION] = true
    }
end

function modifier_aghsfort_storm_spirit_static_remnant_thinker:OnCreated(kv)
    if IsServer() then
        local model_scale = kv.model_scale
        local scale = kv.scale or 1.0

        self.damage = kv.damage
        self.finale_delay = kv.finale_delay

        self.parent = self:GetParent()
        self.ability = self:GetAbility()
        self.caster = self:GetCaster()
        self.team = self.caster:GetTeamNumber()
        self.pos = self.parent:GetAbsOrigin()
        self.trigger_radius = self.ability:GetSpecialValueFor("static_remnant_radius")
        self.radius = self.ability:GetSpecialValueFor("static_remnant_damage_radius")

        model_scale = model_scale * scale
        self.damage = self.damage * scale
        self.radius = self.radius * scale
        self.trigger_radius = self.trigger_radius * scale

        local pfx = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_ss/stormspirit_static_remnant.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(pfx, 0, self.pos)
        ParticleManager:SetParticleControlForward(pfx, 0, self.caster:GetForwardVector())
        ParticleManager:SetParticleControlEnt(pfx, 1, self.caster, PATTACH_CUSTOMORIGIN, "attach_hitloc", self.pos, true)
        ParticleManager:SetParticleControl(pfx, 4, Vector(self.radius/300,0,0))

        local gesture = math.random(84, 96)
        local steal_gesture = {53, 59, 65, 66, 70, 77, 88, 101, 114, 121}
        if self.ability:IsStolen() then
            gesture = RandomFromTable(steal_gesture)
        end
        ParticleManager:SetParticleControl(pfx, 2, Vector(gesture, model_scale, 0))
        self:AddParticle(pfx, false, false, 15, false, false)

        if IsValid(self.ability.shard_taunt) then 
            if self.finale_delay > 0 then
                self.ability.shard_taunt:doAction({
                    remnant = self.parent,
                    radius = self.trigger_radius
                })
            end
        end


        self:StartIntervalThink(self.ability:GetSpecialValueFor("static_remnant_delay"))
    end
end

function modifier_aghsfort_storm_spirit_static_remnant_thinker:OnIntervalThink()
    if IsServer() then
        local enemies = FindUnitsInRadius(self.team, self.pos, self.parent, self.trigger_radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, true)
        if #enemies > 0 then
            if self.finale_delay > 0 then
                self:StartIntervalThink(-1)
                Timers:CreateTimer(self.finale_delay, function()
                    if IsValid(self) then
                        self:Destroy()
                    end
                    return nil
                end)
            else
                self:Destroy()
            end
            return
        end
        self:StartIntervalThink(0.1)
    end
end



function modifier_aghsfort_storm_spirit_static_remnant_thinker:OnDestroy()
    if IsValid(self.parent) then
        local enemies = FindUnitsInRadius(self.team, self.pos, nil, self.radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
           DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        local damage_table = {
            victim = nil,
            attacker = self.caster,
            damage = self.damage,
            damage_type = self.ability:GetAbilityDamageType(),
            ability = self.ability,
            damage_category = DOTA_DAMAGE_CATEGORY_SPELL
        }
        for _, enemy in pairs(enemies) do
            damage_table.victim = enemy
            ApplyDamage(damage_table)
        end

        EmitSoundOn("Hero_StormSpirit.StaticRemnantExplode", self.parent)

        if IsValid(self.ability.shard_vortex) then
            local bTriggered = false
            for _, enemy in pairs(enemies) do
                if IsValid(enemy) and enemy:IsAlive() then
                    self.ability.shard_vortex:doAction({
                        caster = self.caster,
                        pos = self.parent:GetAbsOrigin(),
                        target = enemy
                    })
                    bTriggered = true
                    break
                end
            end
            if not bTriggered then
                self.ability.shard_vortex:doAction({
                    caster = self.caster,
                    pos = self.parent:GetAbsOrigin(),
                    target = nil
                })
            end
        end

        if IsValid(self.parent) then
            self.parent:ForceKill(false)
        end
    end
end
