aghsfort_nevermore_shadowraze = class({})

LinkLuaModifier("modifier_aghsfort_nevermore_shadowraze_debuff", "abilities/heroes/nevermore/shadowraze",
    LUA_MODIFIER_MOTION_NONE)

function aghsfort_nevermore_shadowraze:Init()
    if IsServer() then
        local kv = self:GetAbilityKeyValues()
        self.next_raze = kv["LinkedAbility"]
        self.raze_id = ("raze_" .. string.sub(self:GetAbilityName(), -1))
        self.caster = self:GetCaster()
        -- print(self:GetAbilityName() .. "->" .. self.next_raze)
        -- print("raze id:", self.raze_id)
    end
end
-- 这个施法距离不加
function aghsfort_nevermore_shadowraze:GetCastRange()
    return self:GetSpecialValueFor("shadowraze_range") - self:GetCaster():GetCastRangeBonus()
end

function aghsfort_nevermore_shadowraze:OnSpellStart()
    local next_raze = self:doAction({
        caster = self.caster
    })
    -- print("raze id:", self.raze_id)
    
    -- shadow volley
    local shard = self.caster:FindAbilityByName("aghsfort_nevermore_legend_shadow_volley")
    if IsValid(shard) then
        local self_raze = self:GetAbilityName()
        local next_ability = self.caster:FindAbilityByName(next_raze)

        if IsValid(next_ability) then
            next_ability:doAction({
                caster = self.caster
            })
        end
    end
end

function aghsfort_nevermore_shadowraze:doAction(kv)
    if IsServer() and self:GetLevel() > 0 then
        local caster = kv.caster
        local distance = self:GetSpecialValueFor("shadowraze_range")
        local point = caster:GetAbsOrigin() + caster:GetForwardVector() * distance
        self:doShadowraze({
            point = point
        })
        self:shadowWaltz({
            start_pos = point,
            origin = caster:GetAbsOrigin()
        })
        return self.next_raze
    end
end

function aghsfort_nevermore_shadowraze:doShadowraze(kv)
    if IsServer() and self:GetLevel() > 0 then
        -- Ability properties
        local sfx = "Hero_Nevermore.Shadowraze"
        local pfx_name = "particles/units/heroes/hero_nevermore/nevermore_shadowraze.vpcf"
        local point = GetGroundPosition(kv.point, nil)
        local caster = self:GetCaster()
        local radius = self:GetSpecialValueFor("shadowraze_radius")

        EmitSoundOnLocationWithCaster(point, sfx, caster)

        -- Add particle effects. CP0 is location, CP1 is radius
        local particle_raze_fx = ParticleManager:CreateParticle(pfx_name, PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(particle_raze_fx, 0, point)
        ParticleManager:SetParticleControl(particle_raze_fx, 1, Vector(radius, 1, 1))
        ParticleManager:ReleaseParticleIndex(particle_raze_fx)

        -- Find enemy units in radius
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)

        self:applyRazeEffect({
            targets = enemies
        })
        --  end   
    end
end

function aghsfort_nevermore_shadowraze:applyRazeEffect(kv)
    local caster = self:GetCaster()
    local base_damage = self:GetSpecialValueFor("shadowraze_damage")
    local stack_damage = self:GetSpecialValueFor("stack_bonus_damage")
    local damage_table = {
        -- victim = nil,
        attacker = caster,
        damage = self:GetSpecialValueFor("shadowraze_damage") +
            GetTalentValue(caster, "aghsfort_nevermore_shadowraze+damage"),
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self -- Optional.
    }
    local stack_duration = self:GetSpecialValueFor("duration")
    local extra_damage = self:shadowOverlay({
        stack_duration = stack_duration,
        stacks = #kv.targets
    }) * stack_damage
    for _, enemy in pairs(kv.targets) do
        --  if not enemy:IsMagicImmune() then
        local stack = 0
        local stack_modifier = enemy:FindModifierByName("modifier_aghsfort_nevermore_shadowraze_debuff")
        if IsValid(stack_modifier) then
            stack = stack_modifier:GetStackCount()
        end
        damage_table.victim = enemy
        damage_table.damage = base_damage + stack * stack_damage

        damage_table.damage = damage_table.damage + extra_damage

        ApplyDamage(damage_table)
        enemy:AddNewModifier(caster, self, "modifier_aghsfort_nevermore_shadowraze_debuff", {
            duration = stack_duration
        })
    end
end

function aghsfort_nevermore_shadowraze:shadowWaltz(kv)
    if IsServer() then
        local pos = kv.start_pos
        local origin = kv.origin

        local shard_waltz = self.caster:FindAbilityByName("aghsfort_nevermore_legend_shadow_waltz")
        if IsValid(shard_waltz) then
            if not IsValid(self.necromastery) then
                self.necromastery = self.caster:FindAbilityByName("aghsfort_nevermore_necromastery")
            end
            local base_razes = shard_waltz:GetSpecialValueFor(self.raze_id.."_base")
            local souls_per_raze = shard_waltz:GetSpecialValueFor(self.raze_id)
            -- print("souls_per_raze:"..souls_per_raze)
            local souls = self.necromastery:getSoulCount()
            if souls_per_raze ~= 0 then
                local razes = math.floor(souls / souls_per_raze) + base_razes
                local delta_angle = 360 / (razes + 1)

                for i = 1, razes do
                    pos = RotatePosition(origin, QAngle(0, delta_angle, 0), pos)
                    self:doShadowraze({
                        point = pos
                    })
                end
            end
        end
    end
end

function aghsfort_nevermore_shadowraze:shadowOverlay(kv)
    if IsServer() and kv.stacks > 0 then
        if not IsValid(self.shard_shadow_overlay) then
            self.shard_shadow_overlay = self.caster:FindAbilityByName("aghsfort_nevermore_legend_shadow_overlay")
        end
        if IsValid(self.shard_shadow_overlay) then
            local duration = kv.stack_duration * self.shard_shadow_overlay:GetSpecialValueFor("duration_multiplier")
            local modifier = self.caster:AddNewModifier(self.caster, self.shard_shadow_overlay,"modifier_aghsfort_nevermore_shadowraze_overlay", {
                duration = duration,
                stack_duration = duration,
                stacks = kv.stacks
            })
            if IsValid(modifier) then
                return modifier:GetStackCount() * self.shard_shadow_overlay:GetSpecialValueFor("damage_multiplier")
            end
        end
    end
    return 0
end

-- This type of "inherit" can be taken as simply duplicate the code from parent
aghsfort_nevermore_shadowraze1 = class(aghsfort_nevermore_shadowraze)

aghsfort_nevermore_shadowraze2 = class(aghsfort_nevermore_shadowraze)

aghsfort_nevermore_shadowraze3 = class(aghsfort_nevermore_shadowraze)

modifier_aghsfort_nevermore_shadowraze_debuff = {}

function modifier_aghsfort_nevermore_shadowraze_debuff:OnCreated(kv)
    if IsServer() then
        self.ability = self:GetAbility()
        local parent = self:GetParent()
        local pfx = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        -- ParticleManager:SetParticleControl(pfx, 0, self:GetParent():GetAbsOrigin())
        self:AddParticle(pfx, false, false, 20, false, false)
        self:SetStackCount(1)
    end
    self:updateData(kv)
end

function modifier_aghsfort_nevermore_shadowraze_debuff:OnRefresh(kv)
    self:updateData(kv)
    if IsServer() then
        if self:GetStackCount() < self.max_stacks then
               self:IncrementStackCount()
        end
    end
end

function modifier_aghsfort_nevermore_shadowraze_debuff:updateData(kv)
    if IsServer() then
        self.max_stacks = self.ability:GetSpecialValueFor("max_stacks")
    end
end

modifier_aghsfort_nevermore_shadowraze_overlay = {}

LinkLuaModifier("modifier_aghsfort_nevermore_shadowraze_overlay", "abilities/heroes/nevermore/shadowraze",
    LUA_MODIFIER_MOTION_NONE)

-- Properties
function modifier_aghsfort_nevermore_shadowraze_overlay:IsPurgable()
    return true
end

function modifier_aghsfort_nevermore_shadowraze_overlay:DestroyOnExpire()
    return true
end

function modifier_aghsfort_nevermore_shadowraze_overlay:RemoveOnDeath()
    return true
end

function modifier_aghsfort_nevermore_shadowraze_overlay:OnCreated(kv)
    print("start stacking")
    self:updateData(kv)
end

function modifier_aghsfort_nevermore_shadowraze_overlay:OnRefresh(kv)
    print("update stacking")
    self:updateData(kv)
end

function modifier_aghsfort_nevermore_shadowraze_overlay:updateData(kv)
    self.stack_duration = (kv.stack_duration or 0)
    if IsServer() then
        IncreaseStack({
            modifier = self,
            duration = self.stack_duration,
            destroy_no_layer = 1,
            stacks = kv.stacks
        })
    end
end
