require("abilities/heroes/spirit_breaker/legends")
aghsfort_spirit_breaker_charge_of_darkness = {}

LinkLuaModifier("modifier_aghsfort_spirit_breaker_charge_of_darkness",
    "abilities/heroes/spirit_breaker/charge_of_darkness", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_aghsfort_spirit_breaker_charge_of_darkness_target",
    "abilities/heroes/spirit_breaker/charge_of_darkness", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghsfort_spirit_breaker_charge_of_darkness_knocked",
    "abilities/heroes/spirit_breaker/charge_of_darkness", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_aghsfort_spirit_breaker_charge_of_darkness_stop",
"abilities/heroes/spirit_breaker/charge_of_darkness", LUA_MODIFIER_MOTION_HORIZONTAL)

function aghsfort_spirit_breaker_charge_of_darkness:GetBehavior()
    local behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_ALERT_TARGET +
    DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
    if IsValid(self.shard_orienteering) then
        behavior = behavior + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
    end
    if IsValid(self.shard_rampage) then
        behavior = behavior + DOTA_ABILITY_BEHAVIOR_AUTOCAST
    end
    return behavior
end

function aghsfort_spirit_breaker_charge_of_darkness:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    EmitSoundOn("Hero_Spirit_Breaker.PreAttack", caster)
    return true
end

function aghsfort_spirit_breaker_charge_of_darkness:GetAOERadius()
    if IsValid(self.shard_orienteering) then
        local aoe = self.shard_orienteering:GetSpecialValueFor("radius") + self:GetSpecialValueFor("bash_radius")
        -- print(aoe)
        return aoe
    end
    return 0
end

function aghsfort_spirit_breaker_charge_of_darkness:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if not IsValid(target) then
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(), -- int, your team number
        self:GetCursorPosition(), -- point, center point
        nil, -- handle, cacheUnit. (not known)
        self:GetAOERadius(), -- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
        DOTA_UNIT_TARGET_FLAG_NONE, -- int, flag filter
        FIND_CLOSEST, -- int, order filter
        false -- bool, can grow cache
        )

        if #enemies < 1 then
            return
        else
            target = enemies[1]
        end
    end

    print("charge: casted!")
    if IsValid(target) then
        if target:TriggerSpellAbsorb(self) then
            return
        end
        self:doAction({
            charger = caster,
            caster = caster,
            target = target
        })

        if IsValid(self.shard_rampage) and self:GetAutoCastState() then
            print("rampage charge!")
            local heroes = HeroList:GetAllHeroes()
            local team_num = caster:GetTeamNumber()
            for _, hero in pairs(heroes) do
                if hero ~= self.caster and IsValid(hero) and hero:IsAlive() then
                    -- print(hero:GetName())
                    if hero:GetTeamNumber() == team_num then
                        if hero:HasModifier("modifier_aghsfort_spirit_breaker_bulldoze") then
                            self:doAction({
                                caster = caster,
                                charger = hero,
                                target = target
                            })
                        end
                    end
                end
            end
        end
    end
end

function aghsfort_spirit_breaker_charge_of_darkness:doAction(kv)
    if IsServer() and self:GetLevel() > 0 then
        local charger = kv.charger
        local caster = kv.caster
        local target = kv.target

        EmitSoundOn("Hero_Spirit_Breaker.ChargeOfDarkness", charger)
        charger:RemoveModifierByName("modifier_aghsfort_spirit_breaker_charge_of_darkness")
        -- target:AddNewModifier(caster, self, "modifier_aghsfort_spirit_breaker_charge_of_darkness_target", {})
        charger:AddNewModifier(caster, self, "modifier_aghsfort_spirit_breaker_charge_of_darkness", {
            target = target:entindex()
        })
    end
end

modifier_aghsfort_spirit_breaker_charge_of_darkness = {}

function modifier_aghsfort_spirit_breaker_charge_of_darkness:IsHidden()
    return false
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:IsPurgable()
    return false
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:IsPurgeException()
    return false
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:RemoveOnDeath()
    return false
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:GetStatusEffectName()
    return "particles/status_fx/status_effect_charge_of_darkness.vpcf"
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:StatusEffectPriority()
    return MODIFIER_PRIORITY_HIGH
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:GetMotionPriority()
    return DOTA_MOTION_CONTROLLER_PRIORITY_LOW
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:GetEffectName()
    return "particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge.vpcf"
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.team = self.parent:GetTeamNumber()
    if not IsValid(self.ability) then
        print("charge invalid ability")
        self:Destroy()
    end
    self.stun_duration = self.ability:GetSpecialValueFor("stun_duration")
    self.movement_speed = self.ability:GetSpecialValueFor("movement_speed")
    self.bash_radius = self.ability:GetSpecialValueFor("bash_radius")

    if IsServer() then
        self.search_radius = 4000
        self.tree_radius = 150
        self.min_dist = 150
        self.offset = 20
        self.interrupted = false

        self.ability:SetActivated(false)

        self.parent:AddActivityModifier("charge")
        EmitSoundOn("Hero_Spirit_Breaker.Charge.Impact", self.parent)
        self.target = EntIndexToHScript(kv.target)

        print("charge: init targets")
        if not self:initTargets() then
            print("charge: fail to init targets")
            self:Destroy()
            return
        end
        print("charge: targets initialized, start")
        if not self:ApplyHorizontalMotionController() then
            self:Destroy()
            return
        end
        if IsValid(self.ability.shard_unstoppable) then
            local pfx_name = "particles/units/heroes/hero_pugna/pugna_decrepify.vpcf"
            local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_ABSORIGIN_FOLLOW, self.parent)
            self:AddParticle(pfx, false, false, 20, false, false)
        end
    end
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:OnRemoved()
    if IsServer() and self.ability.shard_runup then
        self.parent:AddNewModifier(self.caster, self.ability, "modifier_aghsfort_spirit_breaker_charge_of_darkness_stop", {
            duration = 3.0
        })
    end
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:OnDestroy()
    if IsServer() then
        print("charge finished")
        self.ability:SetActivated(true)
        self.parent:ClearActivityModifiers()
        -- self.parent:RemoveGesture(ACT_DOTA_RUN)
        -- self.parent:StartGesture(ACT_DOTA_SPIRIT_BREAKER_CHARGE_END)
        self:clearTargets()
        -- destroy trees
        GridNav:DestroyTreesAroundPoint(self:GetParent():GetOrigin(), self.tree_radius, true)
        self.parent:RemoveHorizontalMotionController(self)
        FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), true)
    end
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:UpdateHorizontalMotion(me, dt)
    if IsServer() then
        -- 被打断，结束
        if self:isInterupted() or not IsValid(self.parent) then
            print("charge: interupted!")
            self:Destroy()
            return
        end
        -- 如果目标无了, 尝试更换目标
        if (not IsValid(self.target) or not self.target:IsAlive()) then
            print("charge: target lost, finding next")
            if not self:nextTarget(false) then
                print("charge: failed to find next target, stop")
                self:Destroy()
            end
        end
        -- 执行冲撞
        self.cur_pos = self.parent:GetAbsOrigin()
        self.tar_pos = self.target:GetAbsOrigin()

        self:doGreaterBash()

        local distance = VectorDistance2D(self.cur_pos, self.tar_pos)
        local direction = DirectionVector(self.tar_pos, self.cur_pos)
        self.parent:MoveToPosition(self.tar_pos)
        -- 试图命中,如果中了尝试寻找下个目标
        if self:tryHitTarget(distance) then
            print("charge: hit a target!")
            if not self:nextTarget(true) then
                print("charge: no target in queue!")
                self.parent:MoveToTargetToAttack(self.target)
                self:Destroy()
            end
        else
            self.parent:SetAbsOrigin(self.cur_pos + direction * self.parent:GetIdealSpeed() * dt)
        end
    end
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:OnHorizontalMotionInterrupted()
    if not IsServer() then
        return
    end
    self:Destroy()
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ORDER, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT, MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL}
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:CheckState()
    local state_table = {
        -- [MODIFIER_STATE_DISARMED] = true,  : can still attack if autoattack
        [MODIFIER_STATE_ATTACK_IMMUNE] = IsValid(self.ability.shard_unstoppable),
        [MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
    }
    return state_table
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:GetModifierIgnoreMovespeedLimit()
    return 1
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:GetAbsoluteNoDamagePhysical()
    if IsValid(self.ability.shard_unstoppable) then
        return 1
    end
    return 0
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:GetModifierMoveSpeedBonus_Constant()
    return self.movement_speed
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness:OnOrder(event)
    if IsServer() then

        if event.unit == self.parent then
            if IsValid(self.ability.shard_drift) then
                if event.order_type == DOTA_UNIT_ORDER_HOLD_POSITION or event.order_type == DOTA_UNIT_ORDER_CAST_TARGET or
                    event.order_type == DOTA_UNIT_ORDER_CAST_POSITION then
                    print("charge: player canceled!")
                    self:Destroy()
                elseif event.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or event.order_type ==
                    DOTA_UNIT_ORDER_ATTACK_TARGET then
                    print("attempt to change target")
                    self:changeTarget(event.target)
                end
            else
                if event.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or event.order_type ==
                    DOTA_UNIT_ORDER_MOVE_TO_TARGET or event.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE or
                    event.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET or event.order_type ==
                    DOTA_UNIT_ORDER_HOLD_POSITION or event.order_type == DOTA_UNIT_ORDER_CAST_POSITION or event.order_type == DOTA_UNIT_ORDER_CAST_TARGET then
                    print("charge: player canceled!")
                    self:Destroy()
                end
            end
        end
    end
end

-- 初始化目标
function modifier_aghsfort_spirit_breaker_charge_of_darkness:initTargets()
    self.target:AddNewModifier(self.parent, -- player source
    self.ability, -- ability source
    "modifier_aghsfort_spirit_breaker_charge_of_darkness_target", -- modifier name
    {} -- kv
    )
    self.target_queue = Queue.new()
    if IsValid(self.ability.shard_orienteering) then
        local enemies = FindUnitsInRadius(self.team, -- int, your team number
        self.target:GetAbsOrigin(), -- point, center point
        nil, -- handle, cacheUnit. (not known)
        self.ability:GetAOERadius(), -- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
        DOTA_UNIT_TARGET_FLAG_NONE, -- int, flag filter
        FIND_ANY_ORDER, -- int, order filter
        false -- bool, can grow cache
        )

        for i = 1, #enemies do
            if enemies[i] ~= self.target then
                enemies[i]:AddNewModifier(self.parent, -- player source
                self.ability, -- ability source
                "modifier_aghsfort_spirit_breaker_charge_of_darkness_target", -- modifier name
                {} -- kv
                )
                Queue.pushBack(self.target_queue, enemies[i])
            end
        end
    end
    return true
end
-- 向目标队列增加目标
function modifier_aghsfort_spirit_breaker_charge_of_darkness:addTarget(bFront, hTarget)
    if self.target_queue == nil then
        return false
    else
        Queue.pushBack(self.target_queue, hTarget)
        return true
    end
end
-- 更换当前目标(取消)
function modifier_aghsfort_spirit_breaker_charge_of_darkness:changeTarget(hTarget)
    if not IsValid(hTarget) or not hTarget:IsAlive() or hTarget == self.target then
        return false
    end
    print("changing target!")
    -- in charge queue, just shuffle sequence
    local target_mod = hTarget:FindModifierByNameAndCaster("modifier_aghsfort_spirit_breaker_charge_of_darkness_target",
        self.parent)
    if IsValid(target_mod) then
        Queue.pushBack(self.target_queue, self.target)
        self.target = Queue.popFront(self.target_queue)
        while self.target ~= hTarget do
            Queue.pushBack(self.target_queue, self.target)
            self.target = Queue.popFront(self.target_queue)
        end
        return true
    end
    -- not in charge queue
    local filter = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE, self.team)
    -- local filter = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    --     DOTA_UNIT_TARGET_FLAG_NONE, self.team)
    if filter == UF_SUCCESS then
        self.target:RemoveModifierByNameAndCaster("modifier_aghsfort_spirit_breaker_charge_of_darkness_target",
            self.parent)
        hTarget:AddNewModifier(self.parent, -- player source
        self.ability, -- ability source
        "modifier_aghsfort_spirit_breaker_charge_of_darkness_target", -- modifier name
        {} -- kv
        )
        self.target = hTarget
        return true
    end
    return false
end
-- 更换目标
function modifier_aghsfort_spirit_breaker_charge_of_darkness:nextTarget(bHit)
    if self.target_queue == nil or Queue.empty(self.target_queue) then
        if bHit then
            return false
        else
            local target = self:findNewTarget()
            if IsValid(target) then
                self.target = target
                return true
            end
            return false
        end
    else
        self.target:RemoveModifierByNameAndCaster("modifier_aghsfort_spirit_breaker_charge_of_darkness_target",
            self.parent)
        self.target = Queue.popFront(self.target_queue)
        while (not IsValid(self.target) or not self.target:IsAlive()) do
            if Queue.empty(self.target_queue) then
                if bHit then
                    return false
                else
                    local target = self:findNewTarget()
                    if IsValid(target) then
                        self.target = target
                        return true
                    end
                    return false
                end
            end
            self.target = Queue.popFront(self.target_queue)
        end
        return true
    end
end
-- find another valid target
function modifier_aghsfort_spirit_breaker_charge_of_darkness:findNewTarget()
    local enemies = FindUnitsInRadius(self.team, -- int, your team number
    self.tar_pos, -- point, center point
    nil, -- handle, cacheUnit. (not known)
    self.search_radius, -- float, radius. or use FIND_UNITS_EVERYWHERE
    DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, -- int, flag filter
        FIND_CLOSEST, -- int, order filter
        false -- bool, can grow cache
    )

    if #enemies < 1 then
        return nil
    else
        enemies[1]:AddNewModifier(self.parent, -- player source
        self:GetAbility(), -- ability source
        "modifier_aghsfort_spirit_breaker_charge_of_darkness_target", -- modifier name
        {} -- kv
        )
        return enemies[1]
    end
end
-- 清除目标
function modifier_aghsfort_spirit_breaker_charge_of_darkness:clearTargets()
    if IsValid(self.target) then
        self.target:RemoveModifierByNameAndCaster("modifier_aghsfort_spirit_breaker_charge_of_darkness_target",
            self.parent)
    end
    if self.target_queue == nil or Queue.empty(self.target_queue) then
        return
    end
    while not Queue.empty(self.target_queue) do
        self.target = Queue.popFront(self.target_queue)
        if IsValid(self.target) then
            self.target:RemoveModifierByNameAndCaster("modifier_aghsfort_spirit_breaker_charge_of_darkness_target",
                self.parent)
        end
    end
end
-- 是否打断？
function modifier_aghsfort_spirit_breaker_charge_of_darkness:isInterupted()
    if IsValid(self.ability.shard_unstoppable) then
        return false
    end
    return self.parent:IsStunned() or self.parent:IsOutOfGame() or self.parent:IsRooted() or self.parent:IsHexed()
end
-- 试图撞击目标
function modifier_aghsfort_spirit_breaker_charge_of_darkness:tryHitTarget(fDistance)
    if fDistance > self.min_dist then
        return false
    end
    -- stun enemy
    if IsEnemy(self.parent, self.target) then 
        AddModifierConsiderResist(self.target, self.parent, self.ability, "modifier_stunned", {
            duration = self.stun_duration
        })
        
        if IsValid(self.ability.greater_bash) then
            self.ability.greater_bash:doAction({
                target = self.target,
                caster = self.parent
            })
        end
    end

    return true
end
-- 冲撞
function modifier_aghsfort_spirit_breaker_charge_of_darkness:doGreaterBash()
    if IsValid(self.ability.greater_bash) then
        -- find units
        local enemies = FindUnitsInRadius(self.team, -- int, your team number
        self.cur_pos, -- point, center point
        nil, -- handle, cacheUnit. (not known)
        self.bash_radius, -- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, -- int, flag filter
        0, -- int, order filter
        false -- bool, can grow cache
        )

        for _, enemy in pairs(enemies) do
            if IsValid(enemy) then
                local knocked_modifier = enemy:FindModifierByNameAndCaster(
                    "modifier_aghsfort_spirit_breaker_charge_of_darkness_knocked", self.parent)
                if not IsValid(knocked_modifier) then
                    enemy:AddNewModifier(self.parent, self.ability,
                    "modifier_aghsfort_spirit_breaker_charge_of_darkness_knocked", {
                        duration = 3
                    })
                    self.ability.greater_bash:doAction({
                        target = enemy,
                        caster = self.parent
                    })
                end
            end
        end
    end
end

modifier_aghsfort_spirit_breaker_charge_of_darkness_target = class({})

function modifier_aghsfort_spirit_breaker_charge_of_darkness_target:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness_target:IsHidden()
    return true
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness_target:IsPurgable()
    return false
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness_target:IsPurgeException()
    return false
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness_target:RemoveOnDeath()
    return true
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness_target:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.team = self.caster:GetTeamNumber()
    if IsServer() then
        local particle = ParticleManager:CreateParticleForPlayer(
            "particles/units/heroes/hero_spirit_breaker/spirit_breaker_charge_target.vpcf", PATTACH_OVERHEAD_FOLLOW,
            self.parent, self.caster:GetPlayerOwner())
        ParticleManager:SetParticleControl(particle, 0, self.parent:GetAbsOrigin())
        ParticleManager:SetParticleControl(particle, 1, self.parent:GetAbsOrigin())
        self:AddParticle(particle, false, false, 20, false, false)

        self.vision_range = self.ability:GetSpecialValueFor("vision_radius")
        self.vision_duration = self.ability:GetSpecialValueFor("vision_duration")
        self:StartIntervalThink(0.1)
    end
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness_target:OnIntervalThink()
    if IsServer() then
        AddFOWViewer(self.team, self.parent:GetAbsOrigin(), self.vision_range, self.vision_duration, true)
    end
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness_target:CheckState()
    return {
        [MODIFIER_STATE_PROVIDES_VISION] = false
    }
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness_target:DeclareFunctions()
    return {MODIFIER_PROPERTY_PROVIDES_FOW_POSITION}
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness_target:GetModifierProvidesFOWVision()
    return 1
end

modifier_aghsfort_spirit_breaker_charge_of_darkness_knocked = {}
function modifier_aghsfort_spirit_breaker_charge_of_darkness_knocked:IsHidden()
    return false
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness_knocked:IsPurgable()
    return false
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness_knocked:IsPurgeException()
    return false
end

modifier_aghsfort_spirit_breaker_charge_of_darkness_stop = {}

function modifier_aghsfort_spirit_breaker_charge_of_darkness_stop:IsHidden()
    return true
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness_stop:IsPurgable()
    return false
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness_stop:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TURN_RATE_OVERRIDE
    }
end

function modifier_aghsfort_spirit_breaker_charge_of_darkness_stop:GetModifierTurnRate_Override()
    if self:GetElapsedTime() < 0.5 then
        return 2.0
    end
    return 1.0
end
