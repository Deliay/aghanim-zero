LinkLuaModifier("modifier_aghsfort_storm_spirit_electric_vortex_thinker",
"abilities/heroes/storm_spirit/electric_vortex", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghsfort_storm_spirit_electric_vortex_pull", "abilities/heroes/storm_spirit/electric_vortex",
LUA_MODIFIER_MOTION_HORIZONTAL)
aghsfort_storm_spirit_electric_vortex = {}

function aghsfort_storm_spirit_electric_vortex:GetBehavior()
    if IsValid(self.shard_aoe) then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function aghsfort_storm_spirit_electric_vortex:GetCastRange()
    return self:GetSpecialValueFor("cast_range")
end

function aghsfort_storm_spirit_electric_vortex:OnSpellStart()
    local caster = self:GetCaster()
    -- print("cast vortex!")
    self:doAction({
        caster = caster,
        pos = caster:GetAbsOrigin(),
        target = self:GetCursorTarget()
    })
end

function aghsfort_storm_spirit_electric_vortex:OnProjectileHit(hTarget, vLocation)
    if IsValid(hTarget) then
        self:GetCaster():PerformAttack(hTarget, true, true, true, true, false, false, false)
    end
end

function aghsfort_storm_spirit_electric_vortex:doAction(kv)
    if self:GetLevel() > 0 then
        local caster = kv.caster
        local pos = kv.pos
        local target = kv.target
        local duration = self:GetSpecialValueFor("duration") + GetTalentValue(caster, "storm_spirit_electric_vortex+duration")
        
        local thinker = CreateModifierThinker(caster, self, "modifier_aghsfort_storm_spirit_electric_vortex_thinker", {
            duration = duration
        }, pos, caster:GetTeamNumber(), false)

        if IsValid(target) then
            -- print(thinker:GetName())
            self:pullSingle({
                caster = caster,
                pos = pos,
                target = target,
                duration = duration
            })
        end

        if IsValid(self.shard_aoe) then
            self.shard_aoe:doAction({
                radius = self:GetCastRange() + caster:GetCastRangeBonus(),
                caster = caster,
                target = target,
                duration = duration,
                pos = pos,
            })
        end
    end
end

function aghsfort_storm_spirit_electric_vortex:pullSingle(kv)
    local caster = kv.caster
    local pos = kv.pos
    local target = kv.target
    AddModifierConsiderResist(target, caster, self, "modifier_stunned", {duration = kv.duration})
    AddModifierConsiderResist(target, caster, self, "modifier_aghsfort_storm_spirit_electric_vortex_pull", {
        duration = kv.duration,
        origin_duration = kv.duration,
        pos_x = pos.x,
        pos_y = pos.y,
        pos_z = pos.z
    })
end

modifier_aghsfort_storm_spirit_electric_vortex_thinker = {}

function modifier_aghsfort_storm_spirit_electric_vortex_thinker:OnCreated(kv)
    if IsServer() then
        -- print("vortex thinker!")
        -- print(self:GetCaster():GetName()..":"..self:GetParent():GetName())
        self.parent = self:GetParent() -- this gets the thinker npc
        self.ability = self:GetAbility()
        self.pos = self.parent:GetAbsOrigin()
        self:playEffects()

        if IsValid(self.ability.shard_uhv) then
            self:StartIntervalThink(self.ability.shard_uhv:GetSpecialValueFor("interval"))
        end
    end
end

function modifier_aghsfort_storm_spirit_electric_vortex_thinker:OnIntervalThink()
    if IsServer() then
        self.ability.shard_uhv:doAction({
            pos = self.pos
        })
    end
end

function modifier_aghsfort_storm_spirit_electric_vortex_thinker:playEffects(kv)
    -- print("vortex thinker effect!")
    self.parent:EmitSound("Hero_StormSpirit.ElectricVortexCast")
    local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ss/stormspirit_vortex_aproset.vpcf", PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(pfx, 0, self.parent:GetAbsOrigin())
    ParticleManager:SetParticleControl(pfx, 1, self.parent:GetAbsOrigin())

    self:AddParticle(pfx, false, false, 15, false, false)
end

modifier_aghsfort_storm_spirit_electric_vortex_pull = {}

function modifier_aghsfort_storm_spirit_electric_vortex_pull:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_aghsfort_storm_spirit_electric_vortex_pull:IsPurgable()
    return false
end
function modifier_aghsfort_storm_spirit_electric_vortex_pull:IsPurgeException()
    return true
end
function modifier_aghsfort_storm_spirit_electric_vortex_pull:GetPriority()
    return MODIFIER_PRIORITY_HIGH
end

function modifier_aghsfort_storm_spirit_electric_vortex_pull:CheckState()
    return {
        -- [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_ROOTED] = true,
    }
end

function modifier_aghsfort_storm_spirit_electric_vortex_pull:OnCreated(kv)
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    if IsServer() then
        local pull_distance = self.ability:GetSpecialValueFor("electric_vortex_pull_distance")
        -- print(pull_distance)

        self.origin = Vector(kv.pos_x, kv.pos_y, kv.pos_z)
        self.pull_speed = pull_distance / ( kv.origin_duration or 3.0)
        self.break_distance = self.ability:GetSpecialValueFor("electric_vortex_pull_tether_range")
        -- print(self.pull_speed)

        local pfx = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_stormspirit/stormspirit_electric_vortex.vpcf", PATTACH_CUSTOMORIGIN,
            self.parent)
        ParticleManager:SetParticleControl(pfx, 0, self.origin)
        ParticleManager:SetParticleControlEnt(pfx, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc",
            self.parent:GetAbsOrigin(), true)
        self:AddParticle(pfx, false, false, 15, false, false)
        self.parent:EmitSound("Hero_StormSpirit.ElectricVortex")

        if not self:ApplyHorizontalMotionController() then
            self:Destroy()
            return
        end
        if IsValid(self.ability.shard_attack) then
            self:OnIntervalThink()
        end
    end
end

function modifier_aghsfort_storm_spirit_electric_vortex_pull:OnIntervalThink()
    if IsServer() then
        -- print("start vortex attack!")
        if IsValid(self.caster) and self.caster:IsAlive() and not self.caster:IsDisarmed() then
            self:StartIntervalThink(self.caster:GetSecondsPerAttack())
            local projectile_info =
            {
                Target = self.parent,
                -- Source = self.caster,
                Ability = self.ability,
                EffectName = "particles/units/heroes/hero_stormspirit/stormspirit_base_attack.vpcf",
                iMoveSpeed = (self.caster:IsRangedAttacker() and self.caster:GetProjectileSpeed() or 1100),
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
                bDrawsOnMinimap = false,
                bDodgeable = true,
                bIsAttack = false,
                bVisibleToEnemies = true,
                bReplaceExisting = false,
                bProvidesVision = false,
                vSourceLoc = self.origin
                -- ExtraData = {}
            }
            ProjectileManager:CreateTrackingProjectile(projectile_info)
        else
            self:StartIntervalThink(0.5)
        end
    end
end
function modifier_aghsfort_storm_spirit_electric_vortex_pull:UpdateHorizontalMotion(me, dt)
    if IsServer() then
        if IsAbsoluteResist(self.parent) then
            return
        end
        local pos = self.parent:GetAbsOrigin()
        local distance = VectorDistance2D(self.origin, pos)
        if distance > 0.1 then
            if distance  > self.break_distance then
                self:Destroy()
                return
            end        
            local direction = DirectionVector(self.origin, pos)
            local new_pos = GetGroundPosition(self:GetParent():GetAbsOrigin() + self.pull_speed * direction * dt, nil)
            self.parent:SetOrigin(new_pos)
        end
    end
end

function modifier_aghsfort_storm_spirit_electric_vortex_pull:OnRemoved()
    if IsServer() then
        if IsValid(self.parent) then
            self.parent:StopSound("Hero_StormSpirit.ElectricVortex")
            FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), true)
        end
    end
end

function modifier_aghsfort_storm_spirit_electric_vortex_pull:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }
end

function modifier_aghsfort_storm_spirit_electric_vortex_pull:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end
