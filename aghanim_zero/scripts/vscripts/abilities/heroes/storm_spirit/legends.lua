require("modifiers/ext/modifier_legend_base")
require("abilities/ext/ability_legend_base")

aghsfort_storm_spirit_legend_remnant_vortex = class(ability_legend_base)

function aghsfort_storm_spirit_legend_remnant_vortex:Init()
    self.remnant = self:GetCaster():FindAbilityByName("aghsfort_storm_spirit_static_remnant")
    self.vortex = self:GetCaster():FindAbilityByName("aghsfort_storm_spirit_electric_vortex")
    if IsValid(self.remnant) then
        self.remnant.shard_vortex = self
    end
end

function aghsfort_storm_spirit_legend_remnant_vortex:doAction(kv)
    if IsValid(self.vortex) then
        self.vortex:doAction(kv)
    end
end

modifier_aghsfort_storm_spirit_legend_remnant_vortex = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_storm_spirit_legend_remnant_vortex", "abilities/heroes/storm_spirit/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_storm_spirit_legend_remnant_giant = class(ability_legend_base)

function aghsfort_storm_spirit_legend_remnant_giant:Init()
    self.remnant = self:GetCaster():FindAbilityByName("aghsfort_storm_spirit_static_remnant")
    if IsValid(self.remnant) then
        self.remnant.shard_giant = self
    end
    if IsServer() then
        self.counter = 0
        self.counter_max = self:GetLevelSpecialValueFor("counter", 1)
    end
end

function aghsfort_storm_spirit_legend_remnant_giant:updateCounter()
    self.counter = self.counter + 1
    print(self.counter .. ":" .. self.counter_max)
    if self.counter >= self.counter_max then
        self.counter = 0
    end
    if IsValid(self.mod_counter) then
        self.mod_counter:SetStackCount(self.counter)
    end
    if self.counter > 0 then
        return false
    end
    return true
end

modifier_aghsfort_storm_spirit_legend_remnant_giant = class(modifier_legend_base)

function modifier_aghsfort_storm_spirit_legend_remnant_giant:IsHidden()
    return false
end

function modifier_aghsfort_storm_spirit_legend_remnant_giant:OnCreated(kv)
    if IsServer() then
        local ability = self:GetAbility()
        if IsValid(ability) then
            ability.mod_counter = self
            self:SetStackCount(ability.counter)
        end
    end
end

LinkLuaModifier("modifier_aghsfort_storm_spirit_legend_remnant_giant", "abilities/heroes/storm_spirit/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_storm_spirit_legend_remnant_power = class(ability_legend_base)

modifier_aghsfort_storm_spirit_legend_remnant_power = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_storm_spirit_legend_remnant_power", "abilities/heroes/storm_spirit/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_storm_spirit_legend_remnant_taunt = class(ability_legend_base)

function aghsfort_storm_spirit_legend_remnant_taunt:Init()
    self.remnant = self:GetCaster():FindAbilityByName("aghsfort_storm_spirit_static_remnant")
    if IsValid(self.remnant) then
        self.remnant.shard_taunt = self
    end
    self.caster = self:GetCaster()
end

function aghsfort_storm_spirit_legend_remnant_taunt:OnUpgrade()
    if IsValid(self.remnant) then
        Timers:CreateTimer(0.5, function()
            if not self.remnant:GetAutoCastState() then
                self.remnant:ToggleAutoCast()
            end
            return nil
        end)
    end
end

function aghsfort_storm_spirit_legend_remnant_taunt:doAction(kv)
    local remnant = kv.remnant
    if IsValid(remnant) then
        remnant:AddNewModifier(self.caster, self, "modifier_aghsfort_storm_spirit_remnant_taunter", {
            radius = kv.radius
        })
    end
end

modifier_aghsfort_storm_spirit_legend_remnant_taunt = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_storm_spirit_legend_remnant_taunt", "abilities/heroes/storm_spirit/legends",
    LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_storm_spirit_remnant_taunter = {}

LinkLuaModifier("modifier_aghsfort_storm_spirit_remnant_taunter", "abilities/heroes/storm_spirit/legends",
    LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_storm_spirit_remnant_taunter:OnCreated(kv)
    if IsServer() then
        self.radius = kv.radius

        self.parent = self:GetParent()
        self.team = self.parent:GetTeam()
        self.ability = self:GetAbility()

        local interval = self.ability:GetSpecialValueFor("interval")
        self.duration = self.ability:GetSpecialValueFor("duration")

        self:StartIntervalThink(interval)
        self:OnIntervalThink()
    end
end

function modifier_aghsfort_storm_spirit_remnant_taunter:OnIntervalThink()
    if IsServer() then
        self:playEffects()
        local enemies = FindUnitsInRadius(self.team, self.parent:GetAbsOrigin(), nil, self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
        for _, enemy in pairs(enemies) do
            if IsValid(enemy) and enemy:IsAlive() and not IsAbsoluteResist(enemy) then
                AddModifierConsiderResist(enemy, self.parent, self.ability, "modifier_axe_berserkers_call", {
                    duration = self.duration
                })
            end
        end
    end
end

function modifier_aghsfort_storm_spirit_remnant_taunter:playEffects(kv)
    local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ss/stormspirit_remnant_taunt.vpcf",
        PATTACH_ABSORIGIN, self.parent)
    ParticleManager:SetParticleControl(pfx, 1, Vector(self.radius / 300, 0, 0))
    ParticleManager:ReleaseParticleIndex(pfx)

    -- EmitSoundOn("Hero_Axe.Berserkers_Call", self.parent)
    EmitSoundOnLocationWithCaster(self.parent:GetAbsOrigin(), "Hero_Axe.Berserkers_Call", nil)
end
-- 
aghsfort_storm_spirit_legend_vortex_attack = class(ability_legend_base)

function aghsfort_storm_spirit_legend_vortex_attack:Init()
    self.vortex = self:GetCaster():FindAbilityByName("aghsfort_storm_spirit_electric_vortex")

    if IsValid(self.vortex) then
        self.vortex.shard_attack = self
    end
end

modifier_aghsfort_storm_spirit_legend_vortex_attack = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_storm_spirit_legend_vortex_attack", "abilities/heroes/storm_spirit/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_storm_spirit_legend_vortex_aoe = class(ability_legend_base)

function aghsfort_storm_spirit_legend_vortex_aoe:Init()
    self.vortex = self:GetCaster():FindAbilityByName("aghsfort_storm_spirit_electric_vortex")

    if IsValid(self.vortex) then
        self.vortex.shard_aoe = self
    end
end

function aghsfort_storm_spirit_legend_vortex_aoe:doAction(kv)
    local radius = kv.radius
    local caster = kv.caster
    local target = kv.target
    local duration = kv.duration
    local pos = kv.pos
    print("vortex aoe!" .. radius)
    local enemies = FindUnitsInRadius(caster:GetTeam(), pos, nil, radius, self.vortex:GetAbilityTargetTeam(),
        self.vortex:GetAbilityTargetType(), self.vortex:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
    print("vortexed enemies" .. #enemies)
    for _, enemy in pairs(enemies) do
        if enemy ~= target then
            print("pull!")
            self.vortex:pullSingle({
                caster = caster,
                pos = pos,
                target = enemy,
                duration = duration
            })
        end
    end
end

modifier_aghsfort_storm_spirit_legend_vortex_aoe = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_storm_spirit_legend_vortex_aoe", "abilities/heroes/storm_spirit/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_storm_spirit_legend_vortex_overload = class(ability_legend_base)

function aghsfort_storm_spirit_legend_vortex_overload:Init()
    self.caster = self:GetCaster()
    self.vortex = self.caster:FindAbilityByName("aghsfort_storm_spirit_electric_vortex")
    self.overload = self.caster:FindAbilityByName("aghsfort_storm_spirit_overload")
    if IsValid(self.vortex) then
        self.vortex.shard_uhv = self
    end
end

function aghsfort_storm_spirit_legend_vortex_overload:doAction(kv)
    if IsValid(self.overload) then
        self.overload:doAction({
            attacker = self.caster,
            pos = kv.pos
        })
    end
end

modifier_aghsfort_storm_spirit_legend_vortex_overload = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_storm_spirit_legend_vortex_overload", "abilities/heroes/storm_spirit/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_storm_spirit_legend_overload_ally = class(ability_legend_base)

function aghsfort_storm_spirit_legend_overload_ally:Init()
    self.caster = self:GetCaster()
    self.overload = self.caster:FindAbilityByName("aghsfort_storm_spirit_overload")
    if IsValid(self.overload) then
        self.overload.shard_ally = self
    end
end

function aghsfort_storm_spirit_legend_overload_ally:doAction(kv)
    local allies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.caster:GetAbsOrigin(), nil,
        self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
    for _, ally in pairs(allies) do
        if ally ~= self.caster then
            EmitSoundOn("Hero_StormSpirit.Overload", ally)
            ally:AddNewModifier(self.caster, self.overload, "modifier_aghsfort_storm_spirit_overload_buff", {
                duration = -1
            })
        end
    end
end

modifier_aghsfort_storm_spirit_legend_overload_ally = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_storm_spirit_legend_overload_ally", "abilities/heroes/storm_spirit/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_storm_spirit_legend_overload_mana = class(ability_legend_base)

function aghsfort_storm_spirit_legend_overload_mana:Init()
    self.caster = self:GetCaster()
    self.overload = self.caster:FindAbilityByName("aghsfort_storm_spirit_overload")
    if IsValid(self.overload) then
        self.overload.shard_mana = self
    end
end

modifier_aghsfort_storm_spirit_legend_overload_mana = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_storm_spirit_legend_overload_mana", "abilities/heroes/storm_spirit/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_storm_spirit_legend_overload_remnant = class(ability_legend_base)

function aghsfort_storm_spirit_legend_overload_remnant:Init()
    self.caster = self:GetCaster()
    self.overload = self.caster:FindAbilityByName("aghsfort_storm_spirit_overload")
    self.remnant = self:GetCaster():FindAbilityByName("aghsfort_storm_spirit_static_remnant")

    if IsValid(self.overload) then
        print("learnt shard overload remnant")
        self.overload.shard_remnant = self
    end
end

function aghsfort_storm_spirit_legend_overload_remnant:doAction(kv)
    self.remnant:doAction(kv)
end

modifier_aghsfort_storm_spirit_legend_overload_remnant = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_storm_spirit_legend_overload_remnant", "abilities/heroes/storm_spirit/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_storm_spirit_legend_ball_ally = class(ability_legend_base)

function aghsfort_storm_spirit_legend_ball_ally:Init()
    self.caster = self:GetCaster()
    self.team = self.caster:GetTeamNumber()
    self.ball = self.caster:FindAbilityByName("aghsfort_storm_spirit_ball_lightning")
    if IsValid(self.ball) then
        self.ball.shard_ally = self
    end
end

function aghsfort_storm_spirit_legend_ball_ally:OnUpgrade()
    if IsValid(self.ball) then
        Timers:CreateTimer(0.5, function()
            if not self.ball:GetAutoCastState() then
                self.ball:ToggleAutoCast()
            end
            return nil
        end)
    end
end

function aghsfort_storm_spirit_legend_ball_ally:doAction(kv)
    if IsValid(self.mod_ally) then
        return
    end
    local pos = kv.pos
    local target_pos = kv.target_pos
    local allies = FindUnitsInRadius(self.team, pos, nil, 150, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO,
        DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
    for _, ally in pairs(allies) do
        if IsValid(ally) and ally ~= self.caster and ally:IsAlive() then
            self.mod_ally = ally:AddNewModifier(self.caster, self.ball,
                "modifier_aghsfort_storm_spirit_ball_lightning_travel", {
                    pos_x = target_pos.x,
                    pos_y = target_pos.y,
                    pos_z = target_pos.z
                })
            ProjectileManager:ProjectileDodge(ally)
            return
        end
    end
end

function aghsfort_storm_spirit_legend_ball_ally:stopAction(kv)
    if IsValid(self.mod_ally) then
        self.mod_ally:Destroy()
    end
end

modifier_aghsfort_storm_spirit_legend_ball_ally = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_storm_spirit_legend_ball_ally", "abilities/heroes/storm_spirit/legends",
    LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_storm_spirit_legend_ball_fenzy = class(ability_legend_base)

function aghsfort_storm_spirit_legend_ball_fenzy:Init()
    self.caster = self:GetCaster()
    self.team = self.caster:GetTeamNumber()
    self.ball = self.caster:FindAbilityByName("aghsfort_storm_spirit_ball_lightning")
    if IsValid(self.ball) then
        self.ball.shard_fenzy = self
    end
    if IsServer() then
        self.mod_fenzy = {}
    end
end

function aghsfort_storm_spirit_legend_ball_fenzy:doAction(kv)
    local target = kv.target
    local id = target:entindex()
    if IsValid(self.mod_fenzy[id]) then
        self.mod_fenzy[id]:linger()
        self.mod_fenzy[id] = nil
    end
    self.mod_fenzy[id] = target:AddNewModifier(self.caster, self, "modifier_aghsfort_storm_spirit_ball_fenzy", {})
end

function aghsfort_storm_spirit_legend_ball_fenzy:stopAction(kv)
    local target = kv.target
    local id = target:entindex()
    if IsValid(self.mod_fenzy[id]) then
        self.mod_fenzy[id]:removeLinger()
        self.mod_fenzy[id] = nil
    end
end

function aghsfort_storm_spirit_legend_ball_fenzy:update(kv)
    local target = kv.target
    local id = target:entindex()
    if IsValid(self.mod_fenzy[id]) then
        self.mod_fenzy[id]:IncrementStackCount()
    end
end


modifier_aghsfort_storm_spirit_legend_ball_fenzy = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_storm_spirit_legend_ball_fenzy", "abilities/heroes/storm_spirit/legends",
    LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_storm_spirit_ball_fenzy = {}

LinkLuaModifier("modifier_aghsfort_storm_spirit_ball_fenzy", "abilities/heroes/storm_spirit/legends",
LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_storm_spirit_ball_fenzy:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_aghsfort_storm_spirit_ball_fenzy:OnCreated(kv)
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.pct = self:GetAbility():GetSpecialValueFor("effect_mul")
    self.linger = self.ability:GetSpecialValueFor("linger")
    self:updateData(kv)
end

function modifier_aghsfort_storm_spirit_ball_fenzy:OnRefresh(kv)
    self:updateData(kv)
end

function modifier_aghsfort_storm_spirit_ball_fenzy:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_IGNORE_ATTACKSPEED_LIMIT,
    }
end

function modifier_aghsfort_storm_spirit_ball_fenzy:GetModifierAttackRangeBonus()
    return self.range_bonus
end

function modifier_aghsfort_storm_spirit_ball_fenzy:GetModifierAttackSpeedBonus_Constant()
    return self.as_stack * self:GetStackCount()
end

function modifier_aghsfort_storm_spirit_ball_fenzy:GetModifierAttackSpeed_Limit()
    return 1
end

function modifier_aghsfort_storm_spirit_ball_fenzy:updateData(kv)
    self.range_bonus = self.ability.ball:GetSpecialValueFor("ball_lightning_aoe")
    self.as_stack = self.ability.ball:GetSpecialValueFor("damage") * self.pct
end

function modifier_aghsfort_storm_spirit_ball_fenzy:removeLinger()
    -- Timers:CreateTimer(self.linger, function()
	-- 	self:Destroy()
	-- 	return nil
	-- end)
    self:SetDuration(self.linger, true)
end

-- 
aghsfort_storm_spirit_legend_ball_overload = class(ability_legend_base)

function aghsfort_storm_spirit_legend_ball_overload:Init()
    self.caster = self:GetCaster()
    self.overload = self.caster:FindAbilityByName("aghsfort_storm_spirit_overload")
    self.ball = self.caster:FindAbilityByName("aghsfort_storm_spirit_ball_lightning")
    if IsValid(self.ball) then
        self.ball.shard_overload = self
    end
end

function aghsfort_storm_spirit_legend_ball_overload:doAction(kv)
    if IsValid(self.overload) then
        self.overload:doAction({
            attacker = kv.parent,
            pos = kv.pos
        })
    end
end

modifier_aghsfort_storm_spirit_legend_ball_overload = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_storm_spirit_legend_ball_overload", "abilities/heroes/storm_spirit/legends",
    LUA_MODIFIER_MOTION_NONE)
