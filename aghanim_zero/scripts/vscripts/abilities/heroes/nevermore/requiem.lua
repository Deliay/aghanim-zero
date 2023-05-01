require("abilities/heroes/nevermore/legends")
aghsfort_nevermore_requiem = {}

LinkLuaModifier("modifier_aghsfort_nevermore_requiem_precast", "abilities/heroes/nevermore/requiem",
    LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_aghsfort_nevermore_requiem_debuff", "abilities/heroes/nevermore/requiem",
    LUA_MODIFIER_MOTION_NONE)

function aghsfort_nevermore_requiem:GetCastRange()
    return self:GetSpecialValueFor("radius")
end

function aghsfort_nevermore_requiem:GetCooldown(iLevel)
    local cooldown = self.BaseClass.GetCooldown(self, iLevel) -
                         GetTalentValue(self:GetCaster(), "aghsfort_nevermore_requiem-cd")
    return math.max(cooldown, 0)
end

function aghsfort_nevermore_requiem:OnUpgrade()
    self.raze = self:GetCaster():FindAbilityByName("aghsfort_nevermore_shadowraze1")
end

function aghsfort_nevermore_requiem:GetAssociatedSecondaryAbilities()
    return "aghsfort_nevermore_necromastery"
end

function aghsfort_nevermore_requiem:OnAbilityPhaseStart()
    if IsServer() then
        local caster = self:GetCaster()
        self:GetCaster():AddNewModifier(caster, self, "modifier_aghsfort_nevermore_requiem_precast", {})
        self:playEffects({
            bStart = true
        })
    end
    return true
end

function aghsfort_nevermore_requiem:OnAbilityPhaseInterrupted()
    if IsServer() then
        local caster = self:GetCaster()
        self:GetCaster():RemoveModifierByName("modifier_aghsfort_nevermore_requiem_precast")
        self:playEffects({
            bStart = false,
            bInterrupt = true
        })
    end
end

function aghsfort_nevermore_requiem:OnSpellStart()
    local caster = self:GetCaster()
    caster:RemoveModifierByName("modifier_aghsfort_nevermore_requiem_precast")
    if not IsValid(self.necromastery) then
        self.necromastery = caster:FindAbilityByName("aghsfort_nevermore_necromastery")
    end
    self:doAction({
        souls = self.necromastery:getSoulCount(),
        death_cast = 0,
    })
end

function aghsfort_nevermore_requiem:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if IsServer() then       
        -- If there was no target, do nothing
        if hTarget == nil then
            -- print(ExtraData.heal)
            if IsValid(self.shard_callback) and ExtraData.heal == 0 then
                self:releaseSouls({
                    origin = vLocation,
                    lines = {ExtraData.line + 180},
                    death_cast = ExtraData.death_cast,
                    heal = 1,
                    pct = self.shard_callback.damage_pct
                })
            end
            return nil
        else
            if hTarget:IsNull() then
                return true
            end
        end
    
        -- Ability properties
        local caster = self:GetCaster()
        local ability = self
        local death_cast = ExtraData.death_cast
        local heal = ExtraData.heal
        -- print(death_cast)
    
        -- Ability specials
        local damage = ExtraData.damage
        local slow_duration = ability:GetSpecialValueFor("slow_duration")
        local max_duration = ability:GetSpecialValueFor("slow_duration_max")
        -- print("hit!:" .. damage)
    
        -- Apply the debuff on enemies hit
    
        hTarget:EmitSound("Hero_Nevermore.RequiemOfSouls.Damage")
    
        -- Damage the target
        local damageTable = {
            victim = hTarget,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            attacker = caster,
            ability = ability
        }
    
        local damage_dealt = ApplyDamage(damageTable)

        if heal ~= 0 then
            caster:Heal(damage, self)
        end
    
        local max_duration = self:GetSpecialValueFor("slow_duration_max")
        local duration = self:GetSpecialValueFor("slow_duration")
        -- slow
        local debuff_mod = hTarget:FindModifierByName("modifier_aghsfort_nevermore_requiem_debuff")
        if IsValid(debuff_mod) then
            UpdateDurationUnderResist(hTarget, caster, debuff_mod, duration, max_duration)
        else
            AddModifierConsiderResist(hTarget, caster, self, "modifier_aghsfort_nevermore_requiem_debuff", {
                duration = duration
            })
        end
        -- print("slowed!")
    
        if death_cast == 0 and not(hTarget.bAbsoluteNoCC ~= nil and hTarget.bAbsoluteNoCC == true)  then
            -- print("fear you!")
            debuff_mod = hTarget:FindModifierByName("modifier_nevermore_requiem_fear")
            if IsValid(debuff_mod) then
                UpdateDurationUnderResist(hTarget, caster, debuff_mod, duration, max_duration)
            else
                AddModifierConsiderResist(hTarget, caster, self, "modifier_nevermore_requiem_fear", {
                    duration = duration
                })
                -- hTarget:MoveToNPC(caster)
            end
        end
    end
end

function aghsfort_nevermore_requiem:doAction(kv)
    if IsServer() and self:GetLevel() > 0 then
        local caster = self:GetCaster()

        local souls = kv.souls or 0
        local death_cast = kv.death_cast
        local convert_pct = self:GetSpecialValueFor("soul_conversion")
        local line_count = math.ceil(convert_pct * souls)

        self:playGroundEffects({
            line_count = line_count
        })
        if line_count then
            local lines = {}
            local origin = caster:GetAbsOrigin()
            local direction = caster:GetForwardVector()
            local delta_angle = 360.0 / line_count
            local cur_angle = 0
            for i = 1, line_count do
                table.insert(lines, cur_angle)
                cur_angle = cur_angle + delta_angle
            end
            self:releaseSouls({
                origin = origin,
                lines = lines,
                death_cast = death_cast,
                heal = 0
            })
        end
    end
end

function aghsfort_nevermore_requiem:releaseSouls(kv)
    if IsServer() then
        local death_cast = kv.death_cast
        local lines = kv.lines
        -- Ability properties
        local caster = self:GetCaster()
        local pfx_name = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_line.vpcf"
        local heal = kv.heal

        -- Ability specials
        local travel_distance = self:GetSpecialValueFor("radius")
        local lines_starting_width = self:GetSpecialValueFor("line_width_start")
        local lines_end_width = self:GetSpecialValueFor("line_width_end")
        local lines_speed = self:GetSpecialValueFor("line_speed")
        local origin = kv.origin
        -- -- Calculate the time that it would take to reach the maximum distance
        local max_distance_time = (travel_distance + lines_starting_width) / lines_speed
        local damage = self:GetSpecialValueFor("soul_damage")

        if kv.pct ~= nil then
            damage = damage * kv.pct
        end

        -- Launch the line
        -- projectile doesnt take praticle
        local projectile_info = {
            Ability = self,
            -- EffectName = pfx_name,
            vSpawnOrigin = origin,
            fDistance = travel_distance,
            fStartRadius = lines_starting_width,
            fEndRadius = lines_end_width,
            Source = caster,
            bHasFrontalCone = true,
            bReplaceExisting = false,
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            bDeleteOnHit = false,
            vVelocity = Vector(0, 0, 0),
            bProvidesVision = false,
            ExtraData = {
                death_cast = death_cast,
                damage = damage,
                heal = heal,
                line = 0,
            }
        }
        for _, line in pairs(lines) do
            local velocity = lines_speed * QAngle(0, line, 0):Forward()
            projectile_info.vVelocity = velocity
            projectile_info.ExtraData.line = line
            -- Create the projectile
            ProjectileManager:CreateLinearProjectile(projectile_info)
            -- print("go:"..pid)
            -- Create the particle
            local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_WORLDORIGIN, nil)
            ParticleManager:SetParticleControl(pfx, 0, origin)
            ParticleManager:SetParticleControl(pfx, 1, velocity)
            ParticleManager:SetParticleControl(pfx, 2, Vector(0, max_distance_time, 0))
            ParticleManager:ReleaseParticleIndex(pfx)
        end

        if IsValid(self.shard_reiatsu) then
            projectile_info.Ability = self.shard_reiatsu
            for _, line in pairs(lines) do
                local velocity = lines_speed * QAngle(0, line, 0):Forward()
                projectile_info.vVelocity = velocity
                ProjectileManager:CreateLinearProjectile(projectile_info)
            end
        end

        if IsValid(self.shard_hell) then
            self.shard_hell:doAction({
                caster = caster,
                base_duration = self:GetSpecialValueFor("slow_duration_max"),
                stacks = #lines
            })
        end
        -- Play cast sound
        EmitSoundOn( "Hero_Nevermore.RequiemOfSouls", caster)
    end
end

function aghsfort_nevermore_requiem:playEffects(kv)
    local sfx = "Hero_Nevermore.RequiemOfSoulsCast"
    local pfx_name = "particles/units/heroes/hero_nevermore/nevermore_wings.vpcf"
    if kv.bStart then
        -- Play sound
        self:GetCaster():EmitSound(sfx)
        if self.start_pfx then
            ParticleManager:DestroyParticle(self.start_pfx, true)
            ParticleManager:ReleaseParticleIndex(self.start_pfx)
            self.start_pfx = nil
        end
        self.start_pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())

    else
        if kv.bInterrupt then
            self:GetCaster():StopSound(sfx)
            if self.start_pfx then
                ParticleManager:DestroyParticle(self.start_pfx, true)
                ParticleManager:ReleaseParticleIndex(self.start_pfx)
                self.start_pfx = nil
            end
        else
            if self.start_pfx then
                ParticleManager:ReleaseParticleIndex(self.start_pfx)
                self.start_pfx = nil
            end
        end
    end
end

function aghsfort_nevermore_requiem:playGroundEffects(kv)
    local caster = self:GetCaster()
    local lines = kv.line_count

    local sfx = "Hero_Nevermore.RequiemOfSouls"
    local pfx_name_souls = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls_a.vpcf"
    local pfx_name_ground = "particles/units/heroes/hero_nevermore/nevermore_requiemofsouls.vpcf"

    EmitSoundOn(sfx, caster)

    -- Add particles for the caster and the ground
    local pfx_souls = ParticleManager:CreateParticle(pfx_name_souls, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(pfx_souls, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(pfx_souls, 1, Vector(lines, 0, 0))
    ParticleManager:SetParticleControl(pfx_souls, 2, caster:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(pfx_souls)

    local pfx_ground = ParticleManager:CreateParticle(pfx_name_ground, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(pfx_ground, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(pfx_ground, 1, Vector(lines, 0, 0))
    ParticleManager:ReleaseParticleIndex(pfx_ground)

end

modifier_aghsfort_nevermore_requiem_precast = {}

function modifier_aghsfort_nevermore_requiem_precast:IsHidden()
    return true
end

function modifier_aghsfort_nevermore_requiem_precast:IsPurgable()
    return false
end

function modifier_aghsfort_nevermore_requiem_precast:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
end

modifier_aghsfort_nevermore_requiem_debuff = {}

function modifier_aghsfort_nevermore_requiem_debuff:IsPurgable()
    return true
end

function modifier_aghsfort_nevermore_requiem_debuff:OnCreated(kv)
    self.ms_slow = self:GetAbility():GetSpecialValueFor("reduction_ms")
end

function modifier_aghsfort_nevermore_requiem_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_aghsfort_nevermore_requiem_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.ms_slow
end
