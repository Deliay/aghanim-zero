require("modifiers/ext/modifier_legend_base")
require("abilities/ext/ability_legend_base")
-- 
aghsfort_spirit_breaker_legend_orienteering = class(ability_legend_base)

function aghsfort_spirit_breaker_legend_orienteering:Init()
    local charge = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_charge_of_darkness")
    if IsValid(charge) then
        charge.shard_orienteering = self
    end
end

modifier_aghsfort_spirit_breaker_legend_orienteering = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_spirit_breaker_legend_orienteering", "abilities/heroes/spirit_breaker/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_spirit_breaker_legend_drift = class(ability_legend_base)

function aghsfort_spirit_breaker_legend_drift:Init()
    local charge = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_charge_of_darkness")
    if IsValid(charge) then
        charge.shard_drift = self
    end
end

modifier_aghsfort_spirit_breaker_legend_drift = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_spirit_breaker_legend_drift", "abilities/heroes/spirit_breaker/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_spirit_breaker_legend_unstoppable = class(ability_legend_base)

function aghsfort_spirit_breaker_legend_unstoppable:Init()
    local charge = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_charge_of_darkness")
    if IsValid(charge) then
        charge.shard_unstoppable = self
    end
end

modifier_aghsfort_spirit_breaker_legend_unstoppable = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_spirit_breaker_legend_unstoppable", "abilities/heroes/spirit_breaker/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_spirit_breaker_legend_sparking = class(ability_legend_base)

function aghsfort_spirit_breaker_legend_sparking:Init()
    local doze = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_bulldoze")
    if IsValid(doze) then
        doze.shard_spark = self
    end
end

modifier_aghsfort_spirit_breaker_legend_sparking = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_spirit_breaker_legend_sparking", "abilities/heroes/spirit_breaker/legends",
    LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_spirit_breaker_spark_thinker = {}

LinkLuaModifier("modifier_aghsfort_spirit_breaker_spark_thinker", "abilities/heroes/spirit_breaker/legends",
    LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_spirit_breaker_spark_thinker:IsHidden()
    return true
end

function modifier_aghsfort_spirit_breaker_spark_thinker:IsPurgable()
    return false
end

function modifier_aghsfort_spirit_breaker_spark_thinker:OnCreated(kv)
    if IsServer() then
        self.parent = self:GetParent()
        self.ability = self:GetAbility()
        -- print(self.ability:GetName())
        self.caster = self.ability:GetCaster()
        self.team = self.parent:GetTeamNumber()
        self.pos = self.parent:GetAbsOrigin()
        -- print(self.parent:GetAbsOrigin())
        -- DebugDrawCircle(self.parent:GetAbsOrigin(), Vector(255,0,0), 100, 200, false, self:GetDuration())
        self.radius = kv.radius
        self.tick_rate = kv.tick_rate
        self:playEffects()
        self:StartIntervalThink(kv.tick_rate)
    end
end

function modifier_aghsfort_spirit_breaker_spark_thinker:OnIntervalThink()
    if IsServer() then
        local enemies = FindUnitsInRadius(self.team, self.pos, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        for _, enemy in pairs(enemies) do
            enemy:AddNewModifier(self.caster, self.ability, "modifier_aghsfort_spirit_breaker_spark_debuff", {
                duration = self:GetRemainingTime() + 2,
                tick_rate = self.tick_rate
            })
        end
    end
end

function modifier_aghsfort_spirit_breaker_spark_thinker:playEffects()
    self.pfx =
        ParticleManager:CreateParticle("particles/units/heroes/hero_sb/spark_path.vpcf", PATTACH_WORLDORIGIN, nil)
    -- ParticleManager:SetParticleControlEnt(self.pfx, 0, self.parent, PATTACH_WORLDORIGIN, nil, self.parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(self.pfx, 0, self.parent:GetAbsOrigin() + Vector(0, 0, 100))
    ParticleManager:SetParticleControl(self.pfx, 3, Vector(80, 0, 0))
    -- print(self.pfx)
    -- buff particle
    self:AddParticle(self.pfx, false, -- bDestroyImmediately
    false, -- bStatusEffect
    -1, -- iPriority
    false, -- bHeroEffect
    false -- bOverheadEffect
    )
end

modifier_aghsfort_spirit_breaker_spark_debuff = {}
-- 
LinkLuaModifier("modifier_aghsfort_spirit_breaker_spark_debuff", "abilities/heroes/spirit_breaker/legends",
    LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_spirit_breaker_spark_debuff:IsPurgable()
    return true
end

function modifier_aghsfort_spirit_breaker_spark_debuff:OnCreated(kv)
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.parent = self:GetParent()
    
    self:SetHasCustomTransmitterData(true)
    
    -- print(self.ms_slow)
    self.damage_pct = self.ability:GetSpecialValueFor("status_resistance") * 0.01
    if IsServer() then
        self.ms_slow = -self.ability:GetSpecialValueFor("movement_speed")
        self.ms_slow = RescaleSlowUnderResist(self.parent, self.ms_slow)
        self:SendBuffRefreshToClients()

        self.tick_rate = kv.tick_rate
        self.damage_table = {
            victim = self.parent,
            attacker = self.caster,
            damage = self.caster:GetIdealSpeed() * self.damage_pct * self.tick_rate,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self.ability
        }
        self:StartIntervalThink(self.tick_rate)
    end
end

function modifier_aghsfort_spirit_breaker_spark_debuff:AddCustomTransmitterData()
    return {
        slow = self.ms_slow
    }
end

function modifier_aghsfort_spirit_breaker_spark_debuff:HandleCustomTransmitterData(data)
    self.ms_slow = data.slow
end

function modifier_aghsfort_spirit_breaker_spark_debuff:OnRefresh(kv)
    if IsServer() then
        self.damage_table.damage = self.caster:GetIdealSpeed() * self.damage_pct * self.tick_rate
    end
end

function modifier_aghsfort_spirit_breaker_spark_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_aghsfort_spirit_breaker_spark_debuff:OnIntervalThink()
    if IsServer() then
        ApplyDamage(self.damage_table)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self.damage_table.victim, self.damage_table.damage, nil)
    end
end

function modifier_aghsfort_spirit_breaker_spark_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.ms_slow
end

aghsfort_spirit_breaker_legend_niubility = class(ability_legend_base)

function aghsfort_spirit_breaker_legend_niubility:Init()
    local doze = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_bulldoze")
    if IsValid(doze) then
        doze.shard_nb = self
    end
    local bash = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_greater_bash")
    if IsValid(bash) then
        bash.shard_nb = self
    end
end

modifier_aghsfort_spirit_breaker_legend_niubility = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_spirit_breaker_legend_niubility", "abilities/heroes/spirit_breaker/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_spirit_breaker_legend_rampage = class(ability_legend_base)

function aghsfort_spirit_breaker_legend_rampage:Init()
    local doze = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_bulldoze")
    if IsValid(doze) then
        doze.shard_rampage = self
    end
    self.charge = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_charge_of_darkness")
    if IsValid(self.charge) then
        self.charge.shard_rampage = self
    end
end

function aghsfort_spirit_breaker_legend_rampage:OnUpgrade()
    if IsValid(self.charge) then
        Timers:CreateTimer(0.5, function()
            if not self.charge:GetAutoCastState() then
                self.charge:ToggleAutoCast()
            end
            return nil
        end)
    end
end

modifier_aghsfort_spirit_breaker_legend_rampage = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_spirit_breaker_legend_rampage", "abilities/heroes/spirit_breaker/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_spirit_breaker_legend_serial = class(ability_legend_base)

modifier_aghsfort_spirit_breaker_legend_serial = class(modifier_legend_base)

function aghsfort_spirit_breaker_legend_serial:Init()
    local bash = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_greater_bash")
    if IsValid(bash) then
        bash.shard_serial = self
    end
end

LinkLuaModifier("modifier_aghsfort_spirit_breaker_legend_serial", "abilities/heroes/spirit_breaker/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_spirit_breaker_legend_rush = class(ability_legend_base)

function aghsfort_spirit_breaker_legend_rush:Init()
    self.bash = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_greater_bash")
    if IsValid(self.bash) then
        self.bash.shard_rush = self
    end
end

modifier_aghsfort_spirit_breaker_legend_rush = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_spirit_breaker_legend_rush", "abilities/heroes/spirit_breaker/legends",
    LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_spirit_breaker_rush_hour = {}

LinkLuaModifier("modifier_aghsfort_spirit_breaker_rush_hour", "abilities/heroes/spirit_breaker/legends",
    LUA_MODIFIER_MOTION_NONE)
-- Properties
function modifier_aghsfort_spirit_breaker_rush_hour:IsPurgable()
    return false
end

function modifier_aghsfort_spirit_breaker_rush_hour:DestroyOnExpire()
    return true
end

function modifier_aghsfort_spirit_breaker_rush_hour:RemoveOnDeath()
    return true
end

function modifier_aghsfort_spirit_breaker_rush_hour:OnCreated(kv)
    print("start stacking")
    self.ability = self:GetAbility()
    -- print(self.ability:GetName())
    self.ms_increase = self.ability:GetSpecialValueFor("bonus_movespeed_pct")
    self:updateData(kv)
end

function modifier_aghsfort_spirit_breaker_rush_hour:OnRefresh(kv)
    print("update stacking")
    self:updateData(kv)
end

function modifier_aghsfort_spirit_breaker_rush_hour:CheckState()
    return {
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
    }
end

function modifier_aghsfort_spirit_breaker_rush_hour:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT}
end

function modifier_aghsfort_spirit_breaker_rush_hour:GetModifierMoveSpeedBonus_Percentage()
    return self.ms_increase * self:GetStackCount()
end

function modifier_aghsfort_spirit_breaker_rush_hour:GetModifierIgnoreMovespeedLimit()
    return 1
end

function modifier_aghsfort_spirit_breaker_rush_hour:updateData(kv)
    if IsValid(self.ability) then
        self.ms_increase = self.ability:GetSpecialValueFor("bonus_movespeed_pct")
        print(self.ms_increase)
    end
    if IsServer() then
        self.stack_duration = kv.stack_duration
        print("increase stack")
        IncreaseStack({
            modifier = self,
            duration = self.stack_duration,
            destroy_no_layer = 1,
            stacks = 1
        })
    end
end

-- 
aghsfort_spirit_breaker_legend_schizophrenia = class(ability_legend_base)

function aghsfort_spirit_breaker_legend_schizophrenia:Init()
    local bash = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_greater_bash")
    if IsValid(bash) then
        bash.shard_chaos = self
    end
end

modifier_aghsfort_spirit_breaker_legend_schizophrenia = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_spirit_breaker_legend_schizophrenia", "abilities/heroes/spirit_breaker/legends",
    LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_spirit_breaker_schizophrenia = {}

LinkLuaModifier("modifier_aghsfort_spirit_breaker_schizophrenia", "abilities/heroes/spirit_breaker/legends",
    LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_spirit_breaker_schizophrenia:IsPurgable()
    return false
end

function modifier_aghsfort_spirit_breaker_schizophrenia:IsPurgeException()
    return true
end

function modifier_aghsfort_spirit_breaker_schizophrenia:GetPriority()
    return MODIFIER_PRIORITY_HIGH
end

function modifier_aghsfort_spirit_breaker_schizophrenia:OnCreated(kv)
    if IsServer() then
        print("fxxk you stupid!")
        self.parent = self:GetParent()
        self.team = self.parent:GetTeamNumber()
        self.range = math.max(self.parent:GetAcquisitionRange(),600)
        self.target = nil
        if self.parent.bAbsoluteNoCC ~= nil and self.parent.bAbsoluteNoCC == true then
            self:Destroy()
        end
        self:updateOrder()
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_aghsfort_spirit_breaker_schizophrenia:CheckState()
    return {
        [MODIFIER_STATE_ATTACK_ALLIES] = true,
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_TAUNTED] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = IsValidNPC(self.target) and self.target:IsAlive()
    }
end

function modifier_aghsfort_spirit_breaker_schizophrenia:OnIntervalThink()
    -- print("thinking...")
    self:updateOrder()
end

function modifier_aghsfort_spirit_breaker_schizophrenia:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DISABLE_AUTOATTACK 
    }
end

function modifier_aghsfort_spirit_breaker_schizophrenia:GetDisableAutoAttack()
    return 1
end

function modifier_aghsfort_spirit_breaker_schizophrenia:updateOrder()
    if IsServer() then
        if not IsValidNPC(self.target) or not self.target:IsAlive() then
            local allies = FindUnitsInRadius(self.team, self.parent:GetAbsOrigin(), nil, self.range, DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
            if #allies < 1 then
                -- print(self.range)
                -- self.parent:Hold()
            else
                for _, ally in pairs(allies) do
                    if ally ~= self.parent then                        
                        self.target = ally
                        print(self.target:GetName())
                        self.parent:MoveToTargetToAttack(self.target)
                        break
                    end                    
                end
                -- ExecuteOrderFromTable({
                --     UnitIndex = self.parent:entindex(),
                --     OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
                --     TargetIndex = self.target:entindex(),
                --     Queue = false
                -- })
            end
        else
            -- print("ttk!")
            self.parent:MoveToTargetToAttack(self.target)
            -- ExecuteOrderFromTable({
            --     UnitIndex = self.parent:entindex(),
            --     OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
            --     TargetIndex = self.target:entindex(),
            --     Queue = false
            -- })
        end
    end
end

function modifier_aghsfort_spirit_breaker_schizophrenia:GetEffectName()
    return "particles/units/heroes/hero_sb/schizophrenia.vpcf"
end

function modifier_aghsfort_spirit_breaker_schizophrenia:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

-- 
aghsfort_spirit_breaker_legend_rise = class(ability_legend_base)

function aghsfort_spirit_breaker_legend_rise:Init()
    local nether = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_nether_strike")
    if IsValid(nether) then
        nether.shard_rise = self
    end
end

modifier_aghsfort_spirit_breaker_legend_rise = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_spirit_breaker_legend_rise", "abilities/heroes/spirit_breaker/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_spirit_breaker_legend_crash = class(ability_legend_base)

function aghsfort_spirit_breaker_legend_crash:Init()
    local nether = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_nether_strike")
    if IsValid(nether) then
        -- print("learned legend crash")
        nether.shard_crash = self
    end
end

modifier_aghsfort_spirit_breaker_legend_crash = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_spirit_breaker_legend_crash", "abilities/heroes/spirit_breaker/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_spirit_breaker_legend_runup = class(ability_legend_base)

function aghsfort_spirit_breaker_legend_runup:Init()
    local charge = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_charge_of_darkness")
    if IsValid(charge) then
        charge.shard_runup = self
    end
    
    local nether = self:GetCaster():FindAbilityByName("aghsfort_spirit_breaker_nether_strike")
    if IsValid(nether) then
        nether.shard_runup = self
    end
end

modifier_aghsfort_spirit_breaker_legend_runup = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_spirit_breaker_legend_runup", "abilities/heroes/spirit_breaker/legends",
    LUA_MODIFIER_MOTION_NONE)


