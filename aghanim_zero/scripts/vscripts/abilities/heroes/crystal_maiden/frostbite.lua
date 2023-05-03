require("abilities/heroes/crystal_maiden/legends")
aghsfort_rylai_frostbite = {}

LinkLuaModifier("modifier_aghsfort_rylai_frostbite_passive", "abilities/heroes/crystal_maiden/frostbite",
    LUA_MODIFIER_MOTION_NONE)

function aghsfort_rylai_frostbite:GetIntrinsicModifierName()
    return "modifier_aghsfort_rylai_frostbite_passive"
end

--------------------------------------------------------------------------------
-- Ability Start
function aghsfort_rylai_frostbite:OnSpellStart()
    -- unit identifier
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    self:doAction({
        caster = caster,
        target = target
    })

    self:PlayEffects({
        caster = caster,
        target = target
    })
end

--------------------------------------------------------------------------------
-- Ability Considerations
function aghsfort_rylai_frostbite:doAction(kv)
    if self:GetLevel() <= 0 then
        return 
    end
    local stun_duration = 0.1
    local caster = kv.caster
    local target = kv.target

    -- set duration
    local duration = self:GetSpecialValueFor("duration")
    local tick_interval = self:GetSpecialValueFor("tick_interval")
    local tick_damage = self:GetSpecialValueFor("damage_per_second") * tick_interval
    -- if target:IsCreep() and (target:GetLevel() <= 6) then
    if not target:IsConsideredHero() and not target:IsBoss() then
        duration = self:GetSpecialValueFor("creep_duration")
        tick_damage = self:GetSpecialValueFor("creep_damage_per_second") * tick_interval
    end

    local is_chain = caster:HasAbility("aghsfort_rylai_legend_frost_chain")

    duration = duration + GetTalentValue(caster, "aghsfort_rylai_frostbite+duration")

    -- Add modifier
    AddModifierConsiderResist(target, caster, self, "modifier_aghsfort_rylai_frostbite", {
        duration = duration,
        tick_damage = tick_damage,
        tick_interval = tick_interval,
        is_chain = is_chain
    })

    target:AddNewModifier(caster, -- player source
    self, -- ability source
    "modifier_stunned", -- modifier name
    {
        duration = stun_duration
    } -- kv
    )
end

--------------------------------------------------------------------------------
function aghsfort_rylai_frostbite:PlayEffects(kv)
    -- Create Projectile
    local projectile_name = "particles/units/heroes/hero_crystalmaiden/maiden_frostbite.vpcf"
    local projectile_speed = 1000
    local info = {
        Target = kv.target,
        Source = kv.caster,
        Ability = self,

        EffectName = projectile_name,
        iMoveSpeed = projectile_speed,
        vSourceLoc = kv.caster:GetAbsOrigin(), -- Optional (HOW)

        bDodgeable = false -- Optional
    }
    ProjectileManager:CreateTrackingProjectile(info)
end

function aghsfort_rylai_frostbite:OnProjectileHit_ExtraData(hTarget, vLocation, table)
    if IsServer() then
        if table.percentage ~= nil then
            local caster = self:GetCaster()

            print("total_damage:"..table.damage)
            if table.damage then                
                local damage_table = {
                    victim = hTarget,
                    attacker = caster,
                    damage = table.damage,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    ability = self-- Optional.
                }
                ApplyDamage(damage_table)
            end


            local nova = self:GetCaster():FindAbilityByName("aghsfort_rylai_crystal_nova")
            if IsValid(nova) then
                nova:doAction(
                    {
                        caster = caster,
                        pos = vLocation,
                        percentage = table.percentage
                    }
                )
            end
        end
    end
end

function aghsfort_rylai_frostbite:frostChain(kv)
    local stun_duration = 0.1
    local caster = kv.caster
    local target = kv.target

    if IsValid(target) then

        if target:HasModifier("modifier_aghsfort_rylai_frostbite") then
            return
        end
        -- set duration
        local duration = kv.duration

        local tick_interval = self:GetSpecialValueFor("tick_interval")
        local tick_damage = self:GetSpecialValueFor("damage_per_second") * tick_interval
        -- if target:IsCreep() and (target:GetLevel() <= 6) then
        if not target:IsConsideredHero() and not target:IsBossCreature() then
            tick_damage = self:GetSpecialValueFor("creep_damage_per_second") * tick_interval
        end

        local is_chain = caster:HasAbility("aghsfort_rylai_legend_frost_chain")

        -- Add modifier
        AddModifierConsiderResist(target, caster, self, "modifier_aghsfort_rylai_frostbite", {
            duration = duration,
            tick_damage = tick_damage,
            tick_interval = tick_interval,
            is_chain = is_chain
        })

        target:AddNewModifier(caster, -- player source
        self, -- ability source
        "modifier_stunned", -- modifier name
        {
            duration = stun_duration
        } -- kv
        )
    end

end

function aghsfort_rylai_frostbite:frostSplit(kv)
    if IsServer() then
        local caster = self:GetCaster()
        local target = kv.target
        local shard = caster:FindAbilityByName("aghsfort_rylai_legend_frost_split")
        if IsValid(shard) then
            local radius = shard:GetSpecialValueFor("radius")
            local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
            
            -- Create Projectile
            local projectile_name = "particles/units/heroes/hero_winter_wyvern/wyvern_splinter_blast.vpcf"
            local projectile_speed = 800
            local info = {
                Target = target,
                -- Source = caster,
                Ability = self,

                EffectName = projectile_name,
                iMoveSpeed = projectile_speed,
                vSourceLoc = target:GetAbsOrigin(),
                
                bDodgeable = false, -- Optional
                iVisionRadius = 100,

                ExtraData = {
                    percentage = shard:GetSpecialValueFor("nova_pct") * 0.01,
                    damage = kv.damage * shard:GetSpecialValueFor("damage_pct") * 0.01,
                }
            }
            local max_split = shard:GetSpecialValueFor("split_count")
            for i = 1, math.min(#enemies, max_split) do
                if enemies[i] ~= target then     
                    info.Target = enemies[i]                   
                    ProjectileManager:CreateTrackingProjectile(info)
                end
            end
        end
    end
end



modifier_aghsfort_rylai_frostbite = {}

LinkLuaModifier("modifier_aghsfort_rylai_frostbite", "abilities/heroes/crystal_maiden/frostbite",
    LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Classifications
function modifier_aghsfort_rylai_frostbite:IsPurgable()
    return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_aghsfort_rylai_frostbite:OnCreated(kv)
    if IsServer() then
        self.total_damage = 0
        self.parent = self:GetParent()
    end
    self:updateData(kv)
end

function modifier_aghsfort_rylai_frostbite:OnRefresh(kv)
    self:updateData(kv)
end

function modifier_aghsfort_rylai_frostbite:updateData(kv)
    -- references
    if IsServer() then
        -- print(kv.tick_interval)
        self.is_chain = kv.is_chain
        self.tick_interval = kv.tick_interval
        self.tick_damage = kv.tick_damage

        self.caster = self:GetCaster()
        self.team_num = self:GetCaster():GetTeamNumber()
        self.ability = self:GetAbility()
        -- Apply Damage	 
        self.damageTable = {
            victim = self.parent,
            attacker = self.caster,
            damage = self.tick_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
			damage_category = DOTA_DAMAGE_CATEGORY_SPELL,
            ability = self.ability -- Optional.
        }

        -- Start interval
        self:StartIntervalThink(self.tick_interval)
        self:OnIntervalThink()

        -- Play Effects
        self.sound_target = "hero_Crystal.frostbite"
        EmitSoundOn(self.sound_target, self:GetParent())
    end
end

function modifier_aghsfort_rylai_frostbite:OnDestroy()
    StopSoundOn(self.sound_target, self:GetParent())
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_aghsfort_rylai_frostbite:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_INVISIBLE] = false
    }

    return state
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_aghsfort_rylai_frostbite:OnIntervalThink()
    if IsServer() then
        ApplyDamage(self.damageTable)
        self.total_damage = self.total_damage + self.tick_damage

        local duration = self:GetDuration() - self:GetElapsedTime()
        if duration > 0.2 and self.caster:HasAbility("aghsfort_rylai_legend_frost_chain") then
            local radius = self.parent:GetHullRadius() + 50
            local enemies = FindUnitsInRadius(self.team_num, self.parent:GetAbsOrigin(), self.parent, radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE,
                FIND_ANY_ORDER, true)

            if #enemies > 0 then
                for _, enemy in pairs(enemies) do
                    if enemy ~= self.parent then                        
                        self.ability:frostChain({
                            caster = self.caster,
                            target = enemy,
                            duration = duration - 0.1
                        })
                    end
                end
            end
        end
    end
end

function modifier_aghsfort_rylai_frostbite:OnRemoved()
    if IsServer() then
        if IsValid(self.parent) then 
            self.ability:frostSplit({
                target = self.parent,
                damage = self.total_damage
            })
        end
    end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_aghsfort_rylai_frostbite:GetEffectName()
    return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end

function modifier_aghsfort_rylai_frostbite:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

-- attack frostbite
modifier_aghsfort_rylai_frostbite_passive = {}

function modifier_aghsfort_rylai_frostbite_passive:IsHidden()
    return true
end

function modifier_aghsfort_rylai_frostbite_passive:OnCreated(kv)
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function modifier_aghsfort_rylai_frostbite_passive:DeclareFunctions()
    return {MODIFIER_PROPERTY_PROCATTACK_FEEDBACK}
end

function modifier_aghsfort_rylai_frostbite_passive:GetModifierProcAttack_Feedback(event)
    if IsServer() and event.attacker == self.parent then
        local shard = self.parent:FindAbilityByName("aghsfort_rylai_legend_frost_touch")
        if IsValid(shard) then
            local chance = shard:GetSpecialValueFor("chance_pct")
            if RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_2, self.parent) == true then
                self.ability:doAction({
                    caster = event.attacker,
                    target = event.target
                })
            end
        end
    end
end
