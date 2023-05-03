require("modifiers/ext/modifier_legend_base")
require("abilities/ext/ability_legend_base")

aghsfort_rylai_legend_letgo = class(ability_legend_base)

function aghsfort_rylai_legend_letgo:Init()
    self.field = self:GetCaster():FindAbilityByName("aghsfort_rylai_freezing_field")
end

function aghsfort_rylai_legend_letgo:OnUpgrade()
    if IsValid(self.field) then
        Timers:CreateTimer(0.5, function()
            if not self.field:GetAutoCastState() then
                self.field:ToggleAutoCast()
            end
            return nil
        end)
    end
end

modifier_aghsfort_rylai_legend_letgo = class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_rylai_legend_letgo", "abilities/heroes/crystal_maiden/legends",
    LUA_MODIFIER_MOTION_NONE)

modifier_rylai_let_it_go = {}

LinkLuaModifier("modifier_rylai_let_it_go", "abilities/heroes/crystal_maiden/legends", LUA_MODIFIER_MOTION_BOTH)

function modifier_rylai_let_it_go:IsDebuff()
    return false
end
function modifier_rylai_let_it_go:IsHidden()
    return false
end
function modifier_rylai_let_it_go:IsPurgable()
    return true
end

function modifier_rylai_let_it_go:GetMotionControllerPriority()
    return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM
end

function modifier_rylai_let_it_go:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ORDER, MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_rylai_let_it_go:GetEffectName()
    return "particles/units/heroes/hero_rylai/rylai_let_it_go_cyclone.vpcf"
end

function modifier_rylai_let_it_go:CheckState()
    return {
        -- [MODIFIER_STATE_FLYING] = true,
        [MODIFIER_STATE_FORCED_FLYING_VISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_ROOTED] = true
    }
end

function modifier_rylai_let_it_go:GetOverrideAnimation()
    return ACT_FLY
end

function modifier_rylai_let_it_go:OnCreated(kv)
    if IsServer() then
        -- if self:CheckMotionControllers() then
        local parent = self:GetParent()
        parent:Purge(false, true, false, true, true)
        self.omega = 5
        self.base_z = 500
        self.a = 50
        self.target = parent:GetAbsOrigin()
        self.target.z = 0

        self.speed = parent:GetBaseMoveSpeed() + 150
        self.flow_radius = 50
        self.flow_omega = 10
        self.flow_speed = 100
        self.flow_r = 0
        self.is_flowing = true

        -- self:OnIntervalThink()
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_rylai_let_it_go:OnIntervalThink()
    local cur_pos = self:GetParent():GetAbsOrigin()
    local next_pos = cur_pos
    -- 2d pos
    if self.is_flowing then
        local r = self.flow_r + RandomFloat(-1, 1) * self.flow_speed * FrameTime()
        self.flow_r = math.min(math.max(r, -self.flow_radius), self.flow_radius)

        local flow_theta = -self.flow_omega * self:GetElapsedTime()
        next_pos.x = self.target.x + self.flow_r * math.cos(flow_theta)
        next_pos.y = self.target.y + self.flow_r * math.sin(flow_theta)
    else
        local delta = self.target - cur_pos
        delta.z = 0
        local distance = delta:Length2D()
        if distance < 0.01 then
            self.is_flowing = true
        else
            local direction = delta:Normalized()
            delta = math.min(distance, self.speed * FrameTime()) * direction
            next_pos = next_pos + delta
        end
    end
    --  z movement
    local next_pos = GetGroundPosition(next_pos, nil)

    if self:GetDuration() - self:GetElapsedTime() < 1 then
        next_pos.z = next_pos.z + self.h * (self:GetDuration() - self:GetElapsedTime())
    else
        self.h = self.a * math.sin(self:GetElapsedTime() * self.omega) + self.base_z
        next_pos.z = next_pos.z + self.h
        if self:GetElapsedTime() < 1 then
            next_pos = LerpVectors(cur_pos, next_pos, self:GetElapsedTime())
        else

        end
    end
    -- print(next_pos)
    self:GetParent():SetOrigin(next_pos)
end

function modifier_rylai_let_it_go:OnOrder(event)
    if IsServer() then
        if event.unit == self:GetParent() and event.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION then
            self.target = event.new_pos
            self.is_flowing = false
        end
    end
end

-- create this modifier with frosbite ability
modifier_rylai_absolute_zero = {}

LinkLuaModifier("modifier_rylai_absolute_zero", "abilities/heroes/crystal_maiden/legends", LUA_MODIFIER_MOTION_NONE)

function modifier_rylai_absolute_zero:IsPurgable()
    return true
end

function modifier_rylai_absolute_zero:GetTexture()
    return "crystal_maiden_freezing_field"
end

function modifier_rylai_absolute_zero:OnCreated()
    if IsServer() then        
        print("freezing...")
        self.caster = self:GetCaster()
        self.target = self:GetParent()
    end
end

function modifier_rylai_absolute_zero:OnDestroy()
    if IsServer() and self:GetDuration() - self:GetElapsedTime() < 0.01 then        
        self:GetAbility():doAction(
            {
                caster = self.caster,
                target = self.target
            }
        )
    end
end
