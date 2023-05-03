require("abilities/heroes/spirit_breaker/legends")

aghsfort_spirit_breaker_bulldoze = {}

LinkLuaModifier("modifier_aghsfort_spirit_breaker_bulldoze", "abilities/heroes/spirit_breaker/bulldoze",
    LUA_MODIFIER_MOTION_NONE)

function aghsfort_spirit_breaker_bulldoze:GetCooldown(iLevel)
    local cooldown = self.BaseClass.GetCooldown(self, iLevel) - GetTalentValue(self:GetCaster(),"spirit_breaker_bulldoze-cd")
    -- print(cooldown)
    return math.max(cooldown, 0)
end

function aghsfort_spirit_breaker_bulldoze:OnSpellStart()
    -- print("delta_time:"..FrameTime())
    local caster = self:GetCaster()
    self:doAction({
        caster = caster
    })
end

function aghsfort_spirit_breaker_bulldoze:doAction(kv)
    if IsServer() and self:GetLevel() > 0 then     
        -- unit identifier
        local caster = kv.caster
        
        -- load data
        local duration = self:GetSpecialValueFor( "duration" )
        
        -- add modifier
        caster:AddNewModifier(
            caster, -- player source
            self, -- ability source
            "modifier_aghsfort_spirit_breaker_bulldoze", -- modifier name
            { duration = duration } -- kv
        )

        if IsValid(self.shard_rampage) then
            local heroes = HeroList:GetAllHeroes()
            local team_num = caster:GetTeamNumber()
            for i = 1, #heroes do
                if heroes[i]:GetTeamNumber() == team_num and not heroes[i]:IsIllusion() then
                    heroes[i]:AddNewModifier(
                        caster, -- player source
                        self, -- ability source
                        "modifier_aghsfort_spirit_breaker_bulldoze", -- modifier name
                        { duration = duration } -- kv
                    )
                end
            end
        end
    end
end

modifier_aghsfort_spirit_breaker_bulldoze = {}

--------------------------------------------------------------------------------
-- Classifications

function modifier_aghsfort_spirit_breaker_bulldoze:IsPurgable()
    return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_aghsfort_spirit_breaker_bulldoze:OnCreated( kv )
	-- references
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.parent = self:GetParent()
    self.team = self.parent:GetTeamNumber()

	self:updateData(kv)

    if IsServer() then
        if IsValid(self.ability.shard_spark) then
            self.pos = self.parent:GetAbsOrigin()
            self.trail_time = Time()
            self.trail_radius = self.ability.shard_spark:GetSpecialValueFor("radius")
            self.trail_interval = self.trail_radius*0.7
            self.trail_duration = self.ability.shard_spark:GetSpecialValueFor("duration")
            self.trail_max = self.ability.shard_spark:GetSpecialValueFor("max_length")
            self.trail_queue = Queue.new()
            self.spark_table = {
                duration = self.trail_duration,
                tick_rate = self.ability.shard_spark:GetSpecialValueFor("tick_rate"),
                radius = self.trail_radius
            }
            local hTinker = CreateModifierThinker(self.parent, self.ability, "modifier_aghsfort_spirit_breaker_spark_thinker", self.spark_table, self.pos, self.team, false)
            Queue.pushBack(self.trail_queue, hTinker)
            self:StartIntervalThink(FrameTime())
        end
        if IsValid(self.ability.shard_rampage) then
            self.charge = self.caster:FindAbilityByName("aghsfort_spirit_breaker_charge_of_darkness")
        end
    end
end

function modifier_aghsfort_spirit_breaker_bulldoze:OnRefresh( kv )
	self:updateData(kv)
end

function modifier_aghsfort_spirit_breaker_bulldoze:updateData( kv )
	self.movespeed = self.ability:GetSpecialValueFor( "movement_speed" )
	self.resistance = self.ability:GetSpecialValueFor( "status_resistance" )

	if IsServer() then 
        -- play effects
        local sfx = "Hero_Spirit_Breaker.Bulldoze.Cast"
        EmitSoundOn( sfx, self.parent )

    end
end

function modifier_aghsfort_spirit_breaker_bulldoze:OnIntervalThink()
    if IsServer() then 
        local cpos = self.parent:GetAbsOrigin()
        local distance = VectorDistance2D(cpos, self.pos)
        local time = Time()
        if distance > self.trail_interval or time - self.trail_time > self.trail_duration then
            -- DebugDrawCircle(cpos, Vector(255,0,0), 200, 250, false, self.trail_duration)
            self.pos = cpos
            self.trail_time = time
            local hTinker = CreateModifierThinker(self.parent, self.ability, "modifier_aghsfort_spirit_breaker_spark_thinker", self.spark_table, self.pos, self.team, false)
            Queue.pushBack(self.trail_queue, hTinker)
            if Queue.length(self.trail_queue) > self.trail_max then
                hTinker = Queue.popFront(self.trail_queue)
                if IsValid(hTinker) then
                    hTinker:Destroy()
                end
            end
        end
    end
end

function modifier_aghsfort_spirit_breaker_bulldoze:OnRemoved()
end

function modifier_aghsfort_spirit_breaker_bulldoze:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_aghsfort_spirit_breaker_bulldoze:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_STATUS_RESISTANCE,
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
	}
	return funcs
end

function modifier_aghsfort_spirit_breaker_bulldoze:CheckState()
    local state_table = {
        -- [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = IsValid(self.ability.shard_nb)
    }
    return state_table
end

function modifier_aghsfort_spirit_breaker_bulldoze:GetModifierIgnoreMovespeedLimit()
    if IsValid(self.ability.shard_nb) then
        return 1
    end
    return 0
end

function modifier_aghsfort_spirit_breaker_bulldoze:GetModifierBaseAttackTimeConstant()
    if IsValid(self.ability.shard_nb) and self.parent == self.caster then
        -- print("base attack time adjust")
        return self.ability.shard_nb:GetSpecialValueFor("attack_time") 
    end
    return nil
end

function modifier_aghsfort_spirit_breaker_bulldoze:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_aghsfort_spirit_breaker_bulldoze:GetModifierStatusResistance()
	return self.resistance
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_aghsfort_spirit_breaker_bulldoze:GetEffectName()
	return "particles/units/heroes/hero_spirit_breaker/spirit_breaker_haste_owner.vpcf"
end

function modifier_aghsfort_spirit_breaker_bulldoze:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
