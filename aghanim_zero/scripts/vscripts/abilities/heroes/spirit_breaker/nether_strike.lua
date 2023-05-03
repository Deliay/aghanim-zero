require("abilities/heroes/spirit_breaker/legends")
aghsfort_spirit_breaker_nether_strike = {}

LinkLuaModifier("modifier_aghsfort_spirit_breaker_nether_strike_target",
    "abilities/heroes/spirit_breaker/nether_strike", LUA_MODIFIER_MOTION_NONE)

function aghsfort_spirit_breaker_nether_strike:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES

    if IsValid(self.shard_crash) then
        behavior = behavior + DOTA_ABILITY_BEHAVIOR_AOE
    end

    return behavior
end

function aghsfort_spirit_breaker_nether_strike:GetAOERadius()
    if IsValid(self.shard_crash) then
        return self.shard_crash:GetSpecialValueFor("base_radius") * self:GetSpecialValueFor("bash_pct")
    end
    return 0
end

function aghsfort_spirit_breaker_nether_strike:GetCastPoint()
    if IsValid(self.shard_runup) then
        local caster = self:GetCaster()
        if caster:HasModifier("modifier_aghsfort_spirit_breaker_charge_of_darkness") or caster:HasModifier("modifier_aghsfort_spirit_breaker_charge_of_darkness_stop") then
            -- print("go!")
            return 0
        end    
    end
    return self.BaseClass.GetCastPoint(self)
end

function aghsfort_spirit_breaker_nether_strike:GetCastRange(vLocation, hTarget)
    if IsValid(self.shard_runup) then
        local caster = self:GetCaster()
        if caster:HasModifier("modifier_aghsfort_spirit_breaker_charge_of_darkness") or caster:HasModifier("modifier_aghsfort_spirit_breaker_charge_of_darkness_stop") then
            -- print("go!")
            return 99999
        end    
    end
    return self.BaseClass.GetCastRange(self,vLocation, hTarget)
end
--------------------------------------------------------------------------------
-- Ability Phase Start
function aghsfort_spirit_breaker_nether_strike:OnAbilityPhaseStart()
    -- unit identifier
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetCastPoint() + 1.0

    if IsServer() then

        -- add vision modifier
        target:AddNewModifier(caster, -- player source
        self, -- ability source
        "modifier_aghsfort_spirit_breaker_nether_strike_target", -- modifier name
        {
            duration = duration
        } -- kv
        )

        -- play effects
        local sfx = "Hero_Spirit_Breaker.NetherStrike.Begin"
        EmitSoundOn(sfx, self:GetCaster())
    end

    return true -- if success
end

function aghsfort_spirit_breaker_nether_strike:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if IsServer() then

        -- delete vision modifier
        target:RemoveModifierByNameAndCaster("modifier_aghsfort_spirit_breaker_nether_strike_target", caster)

        -- stop effects
        local sfx = "Hero_Spirit_Breaker.NetherStrike.Begin"
        StopSoundOn(sfx, caster)
    end
end

--------------------------------------------------------------------------------
-- Ability Start
function aghsfort_spirit_breaker_nether_strike:OnSpellStart()
    -- unit identifier
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    self:doAction({
        caster = caster,
        target = target
    })
end

function aghsfort_spirit_breaker_nether_strike:doAction(kv)
    if IsServer() and self:GetLevel() > 0 then
        -- unit identifier
        local caster = kv.caster
        local target = kv.target
        -- load data
        local damage = self:GetSpecialValueFor("damage")
        local offset = 54
        local bash_pct = self:GetSpecialValueFor("bash_pct")

        -- get direction
        local direction = DirectionVector(target:GetOrigin(), caster:GetOrigin())

        if IsValid(self.shard_rise) then
            caster:Purge(false, true, false, true, true)
            local bulldoze = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_bulldoze")
            if IsValid(bulldoze) then
                bulldoze:doAction({
                    caster = caster
                })
            end
            caster:AddNewModifier(self:GetCaster(), self, "modifier_black_king_bar_immune", {
                duration = self.shard_rise:GetSpecialValueFor("base_duration") * bash_pct
            })
        end

        -- set pos
        local pos = target:GetOrigin() + direction * offset
 
        caster:SetOrigin(pos)

        -- prepare damage table
        local damageTable = {
            victim = target,
            attacker = caster,
            damage = damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self -- Optional.
        }

        if not IsValid(self.shard_crash) then            
            -- proc bash
            if IsValid(self.greater_bash) then
                self.greater_bash:doAction({
                    target = target,
                    caster = caster,
                    pct = bash_pct
                })
            end
    
            ApplyDamage(damageTable)
        else
            local enemies = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetAOERadius(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
            for _, enemy in pairs(enemies) do
                if IsValid(self.greater_bash) then
                    self.greater_bash:doAction({
                        target = enemy,
                        caster = caster,
                        pct = bash_pct
                    })
                end
                
                damageTable.victim = enemy

                ApplyDamage(damageTable)
            end
        end

        FindClearSpaceForUnit(caster, pos, true)

        if IsValid(self.shard_runup) then
            local charge = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_charge_of_darkness")
            if IsValid(charge) then
                charge:EndCooldown()
            end
        end

        caster:MoveToTargetToAttack(target)
        -- play effects
        local sound_cast = "Hero_Spirit_Breaker.NetherStrike.End"
        EmitSoundOn(sound_cast, caster)
    end
end

modifier_aghsfort_spirit_breaker_nether_strike_target = {}

-- Classifications
function modifier_aghsfort_spirit_breaker_nether_strike_target:IsHidden()
    return true
end

function modifier_aghsfort_spirit_breaker_nether_strike_target:IsDebuff()
    return true
end

function modifier_aghsfort_spirit_breaker_nether_strike_target:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_aghsfort_spirit_breaker_nether_strike_target:OnCreated(kv)
    if IsServer() then

    end
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_aghsfort_spirit_breaker_nether_strike_target:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_PROVIDES_FOW_POSITION}

    return funcs
end

function modifier_aghsfort_spirit_breaker_nether_strike_target:GetModifierProvidesFOWVision()
    return 1
end
