require("abilities/heroes/spirit_breaker/legends")
aghsfort_spirit_breaker_greater_bash = {}

LinkLuaModifier("modifier_aghsfort_spirit_breaker_greater_bash", "abilities/heroes/spirit_breaker/greater_bash",
    LUA_MODIFIER_MOTION_NONE)

function aghsfort_spirit_breaker_greater_bash:GetIntrinsicModifierName()
    return "modifier_aghsfort_spirit_breaker_greater_bash"
end

function aghsfort_spirit_breaker_greater_bash:OnUpgrade()
    self.caster = self:GetCaster()
    if IsServer() then
        if not IsValid(self.bash_passive) then
            self.bash_passive = self.caster:FindModifierByName("modifier_aghsfort_spirit_breaker_greater_bash")
        end
    end
    if not IsValid(self.charge_of_darkness) then
        self.charge_of_darkness = self.caster:FindAbilityByName("aghsfort_spirit_breaker_charge_of_darkness")
        if IsValid(self.charge_of_darkness) then
            self.charge_of_darkness.greater_bash = self
        end
    end
    if not IsValid(self.nether_strike) then
        self.nether_strike = self.caster:FindAbilityByName("aghsfort_spirit_breaker_nether_strike")
        if IsValid(self.nether_strike) then
            self.nether_strike.greater_bash = self
        end
    end
    self:RefreshIntrinsicModifier()
end

function aghsfort_spirit_breaker_greater_bash:doAction(kv)
    if IsServer() and self:GetLevel() > 0 then
        print("bash!")
        if IsValid(self.bash_passive) then
            self.bash_passive:doBash(kv)
        end
    end
end

modifier_aghsfort_spirit_breaker_greater_bash = {}

-- Classifications
function modifier_aghsfort_spirit_breaker_greater_bash:IsHidden()
    return true
end

function modifier_aghsfort_spirit_breaker_greater_bash:OnCreated(kv)
    self.parent = self:GetParent()
    self.team = self.parent:GetTeamNumber()
    self.ability = self:GetAbility()
    self.knockback_table = {
        should_stun = true,
        knockback_duration = 0,
        duration = 0,
        knockback_distance = 0,
        knockback_height = 0, -- 击退高度
        center_x = 0,
        center_y = 0,
        center_z = 0
    }
    self.damage_table = {
        victim = nil,
        attacker = self.parent,
        damage = 0,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self.ability -- Optional.
    }
    self:updateData(kv)
end

function modifier_aghsfort_spirit_breaker_greater_bash:OnRefresh(kv)
    self:updateData(kv)
end

function modifier_aghsfort_spirit_breaker_greater_bash:updateData(kv)
    -- references
    self.chance = self.ability:GetSpecialValueFor("chance_pct")
    self.damage_pct = self.ability:GetSpecialValueFor("damage") * 0.01
    self.duration = self.ability:GetSpecialValueFor("duration")
    self.speed_duration = self.ability:GetSpecialValueFor("movespeed_duration")

    self.knockback_duration = self.ability:GetSpecialValueFor("knockback_duration")
    self.knockback_distance = self.ability:GetSpecialValueFor("knockback_distance")
    self.knockback_table.knockback_height = self.ability:GetSpecialValueFor("knockback_height")
    self.knockback_table.duration = self.duration

    self.movespeed_pct = self.ability:GetSpecialValueFor("bonus_movespeed_pct")
    self.movespeed_duration = self.ability:GetSpecialValueFor("movespeed_duration")

end

function modifier_aghsfort_spirit_breaker_greater_bash:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_PROCATTACK_FEEDBACK}

    return funcs
end

function modifier_aghsfort_spirit_breaker_greater_bash:GetModifierProcAttack_Feedback(event)
    if IsServer() and IsValid(event.target) and event.target:GetName() ~= ""  and event.attacker == self.parent then
        -- print("attack landed!")
        if self.parent:PassivesDisabled() then
            return
        end

        if not self.ability:IsCooldownReady() then
            return
        end
        -- unit filter
        local filter = UnitFilter(event.target, DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
            self.parent:GetTeamNumber())
        if filter == UF_SUCCESS then
            local chance = self.chance + GetTalentValue(self.parent, "spirit_breaker_greater_bash+chance")
            -- roll pseudo random
            if RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_3, self.parent) then
                print("greater bash attack!")
                if IsValid(self.ability.shard_nb) and
                    self.parent:HasModifier("modifier_aghsfort_spirit_breaker_bulldoze") then
                else
                    -- set cooldown
                    self.ability:StartCooldown(self.ability:GetCooldown(self.ability:GetLevel()))
                end

                -- proc
                self:doBash({
                    target = event.target,
                    caster = self.parent
                })
            end
        end
    end
end

function modifier_aghsfort_spirit_breaker_greater_bash:doBash(kv)
    local target = kv.target
    local caster = kv.caster
    local pct = kv.pct or 1.0

    self:playEffects({
        target = target,
        is_creep = not target:IsConsideredHero()
    })

    local origin = caster:GetAbsOrigin()
    local direction = DirectionVector(target:GetAbsOrigin(), origin)

    self.knockback_table.knockback_distance = self.knockback_distance * pct
    self.knockback_table.knockback_duration = self.knockback_duration * pct
    self.knockback_table.duration = self.duration
    self.knockback_table.center_x = origin.x
    self.knockback_table.center_y = origin.y
    self.knockback_table.center_z = origin.z
    AddModifierConsiderResist(target, self.parent, self.ability, "modifier_knockback", self.knockback_table)

    local damage_pct = self.damage_pct + GetTalentValue(self.parent, "spirit_breaker_greater_bash+damage") * 0.01
    self.damage_table.victim = target
    self.damage_table.attacker = caster
    self.damage_table.damage = self.parent:GetIdealSpeed() * damage_pct * pct
    if not target:IsConsideredHero() then
        self.damage_table.damage = self.damage_table.damage * 1.5
    end
    if IsValid(self.ability.shard_serial) then
        AddModifierConsiderResist(target, self.parent, self.ability, "modifier_aghsfort_spirit_breaker_secondary_bash",
            {
                duration = self.knockback_table.knockback_duration + 0.1,
                damage = self.damage_table.damage,
                distance = self.knockback_table.knockback_distance,
                height = self.knockback_table.knockback_height,
                knockback_duration = self.knockback_table.knockback_duration
            })
    end
    ApplyDamage(self.damage_table)
    if IsValid(self.ability.shard_rush) then
        -- print("rush!!"..self.speed_duration)
        caster:AddNewModifier(self.parent, self.ability, "modifier_aghsfort_spirit_breaker_rush_hour", {
            duration = self.speed_duration,
            stack_duration = self.speed_duration
        })
    end
    if IsValid(self.ability.shard_chaos) then
        local crazy_duration = self.duration * self.ability.shard_chaos:GetSpecialValueFor("duration_pct")
        AddModifierConsiderResist(target, self.parent, self.ability, "modifier_aghsfort_spirit_breaker_schizophrenia", {duration = crazy_duration})
    end
end

function modifier_aghsfort_spirit_breaker_greater_bash:playEffects(kv)
    -- Get Resources
    local target = kv.target
    local pfx_name = "particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf"
    local sfx = "Hero_Spirit_Breaker.GreaterBash"
    if kv.is_creep then
        sfx = "Hero_Spirit_Breaker.GreaterBash.Creep"
    end

    -- Create Particle
    local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_POINT_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), -- unknown
        true -- unknown, true
    )
    ParticleManager:ReleaseParticleIndex(pfx)

    -- Create Sound
    EmitSoundOn(sfx, target)
end

-- 用于指示二次碰撞
modifier_aghsfort_spirit_breaker_secondary_bash = {}
LinkLuaModifier("modifier_aghsfort_spirit_breaker_secondary_bash", "abilities/heroes/spirit_breaker/greater_bash",
    LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_spirit_breaker_secondary_bash:IsHidden()
    return true
end

function modifier_aghsfort_spirit_breaker_secondary_bash:IsPurgable()
    return false
end

function modifier_aghsfort_spirit_breaker_secondary_bash:OnCreated(kv)
    if IsServer() then
        self.ability = self:GetAbility()
        self.parent = self:GetParent()
        self.caster = self:GetCaster()
        self.team = self.caster:GetTeamNumber()
        -- print(kv.knockback_duration)
        self.knockback_table = {
            should_stun = true,
            knockback_duration = kv.knockback_duration,
            duration = kv.knockback_duration,
            knockback_distance = kv.distance,
            knockback_height = kv.height, -- 击退高度
            center_x = 0,
            center_y = 0,
            center_z = 0
        }
        self.radius = self.knockback_table.knockback_distance
        self.damage_table = {
            victim = nil,
            attacker = self.caster,
            damage = kv.damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
            ability = self.ability -- Optional.
        }
    end
end

function modifier_aghsfort_spirit_breaker_secondary_bash:OnRemoved()
    if IsServer() then
        if not IsValid(self.parent) then
            return
        end
        local pos = self.parent:GetAbsOrigin()
        self.knockback_table.center_x = pos.x
        self.knockback_table.center_y = pos.y
        self.knockback_table.center_z = pos.z
        self:groundEffects({
            pos = pos
        })
        -- DebugDrawCircle(pos, Vector(255,0,0), 100, self.radius, false, 1.0)
        local enemies = FindUnitsInRadius(self.team, pos, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        for _, enemy in pairs(enemies) do
            if enemy ~= self.parent then
                self:playEffects({
                    target = enemy,
                    is_creep = not enemy:IsConsideredHero()
                })
                AddModifierConsiderResist(enemy, self.caster, self.ability, "modifier_knockback", self.knockback_table)
                self.damage_table.victim = enemy
                ApplyDamage(self.damage_table)
            end
        end
    end
end

function modifier_aghsfort_spirit_breaker_secondary_bash:groundEffects(kv)
    local pos = kv.pos
    local pfx_name = "particles/units/heroes/hero_sandking/sandking_epicenter_pulse.vpcf"

    local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(pfx, 0, self.parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(pfx, 1, Vector(self.radius, 1, 1))
    ParticleManager:ReleaseParticleIndex(pfx)
end

function modifier_aghsfort_spirit_breaker_secondary_bash:playEffects(kv)
    -- Get Resources
    local target = kv.target
    local pfx_name = "particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf"
    local sfx = "Hero_Spirit_Breaker.GreaterBash"
    if kv.is_creep then
        sfx = "Hero_Spirit_Breaker.GreaterBash.Creep"
    end

    -- Create Particle
    local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_POINT_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0, 0, 0), -- unknown
        true -- unknown, true
    )
    ParticleManager:ReleaseParticleIndex(pfx)

    -- Create Sound
    EmitSoundOn(sfx, target)
end

