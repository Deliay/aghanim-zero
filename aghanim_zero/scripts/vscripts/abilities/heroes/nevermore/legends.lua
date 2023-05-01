
require("modifiers/ext/modifier_legend_base")
require("abilities/ext/ability_legend_base")

aghsfort_nevermore_legend_soul_thirst = {}

LinkLuaModifier("modifier_aghsfort_nevermore_necromastery_thirst", "abilities/heroes/nevermore/legends",
LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghsfort_nevermore_necromastery_thirst_stack", "abilities/heroes/nevermore/legends",
LUA_MODIFIER_MOTION_NONE)

function aghsfort_nevermore_legend_soul_thirst:GetIntrinsicModifierName()
    return "modifier_aghsfort_nevermore_necromastery_thirst"
end

function aghsfort_nevermore_legend_soul_thirst:doAction(kv)
    if IsServer() then
        if not IsValid(self.intrinsic_modifier) then
            self.intrinsic_modifier = self:GetCaster():FindModifierByName("modifier_aghsfort_nevermore_necromastery_thirst")
        end
        if IsValid(self.intrinsic_modifier) then
            self.intrinsic_modifier:gainStacks(kv.souls)
        end
    end
end

function aghsfort_nevermore_legend_soul_thirst:reset()
    if IsServer() then
        if not IsValid(self.intrinsic_modifier) then
            self.intrinsic_modifier = self:GetCaster():FindModifierByName("modifier_aghsfort_nevermore_necromastery_thirst")
        end
        if IsValid(self.intrinsic_modifier) then
            return self.intrinsic_modifier:reset()
        end
    end
    return 0
end

modifier_aghsfort_nevermore_necromastery_thirst = {}

function modifier_aghsfort_nevermore_necromastery_thirst:IsHidden()
    -- return self:GetStackCount() == 0
    return false
end

function modifier_aghsfort_nevermore_necromastery_thirst:IsPurgable()
    return false
end

function modifier_aghsfort_nevermore_necromastery_thirst:DestroyOnExpire()
    return false
end

function modifier_aghsfort_nevermore_necromastery_thirst:OnCreated(kv)
    self.parent = self:GetParent()
    self.necromastery = self.parent:FindAbilityByName("aghsfort_nevermore_necromastery")
    self.stack_duration = self:GetAbility():GetLevelSpecialValueFor("duration", 1)
    self.max_times = self:GetAbility():GetLevelSpecialValueFor("max_times", 1)
    self.count = 0
    self.damage_per_soul = 0
    self.amp_per_soul = 0
    
    self:updateData()
    self:StartIntervalThink(3.0)
end

function modifier_aghsfort_nevermore_necromastery_thirst:OnIntervalThink()
    self:updateData()
end

function modifier_aghsfort_nevermore_necromastery_thirst:updateData()
    -- Ability specials
    self.damage_per_soul = self.necromastery:GetSpecialValueFor("damage_per_soul") +
                               GetTalentValue(self.parent, "aghsfort_nevermore_necromastery+atk")
    self.max_stacks = self.necromastery:GetSpecialValueFor("max_souls") * self.max_times
    self.amp_per_soul = self.necromastery:GetSpecialValueFor("amp_per_soul") +
                            GetTalentValue(self.parent, "aghsfort_nevermore_necromastery+amp")
    -- print(self.damage_per_soul)
end



function modifier_aghsfort_nevermore_necromastery_thirst:DeclareFunctions()
    return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, 
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
    MODIFIER_PROPERTY_MODEL_SCALE 
}
end

function modifier_aghsfort_nevermore_necromastery_thirst:GetModifierPreAttack_BonusDamage()
    return self:GetStackCount() * self.damage_per_soul
end

function modifier_aghsfort_nevermore_necromastery_thirst:GetModifierSpellAmplify_Percentage()
    return self:GetStackCount() * self.amp_per_soul
end

function modifier_aghsfort_nevermore_necromastery_thirst:GetModifierModelScale()
    return self:GetStackCount()
end

function modifier_aghsfort_nevermore_necromastery_thirst:gainStacks(nStacks)
    if IsServer() then        
        print("gain extra stacks")
        self.count = self.count + nStacks
        
        self:SetStackCount(math.min(self.count, self.max_stacks))
        self.parent:AddNewModifier(self.parent, self:GetAbility(), "modifier_aghsfort_nevermore_necromastery_thirst_stack", {
            duration = self.stack_duration,
            stacks = nStacks
        })
    end
end

function modifier_aghsfort_nevermore_necromastery_thirst:reduceStacks(nStacks)
    if IsServer() then        
        print("reduce stacks")
        
        self.count = math.max(self.count - nStacks, 0)
        
        self:SetStackCount(math.min(self.count, self.max_stacks))
    end
end

function modifier_aghsfort_nevermore_necromastery_thirst:reset()
    local stacks = self:GetStackCount()
    self:GetParent():RemoveModifierByName("modifier_aghsfort_nevermore_necromastery_thirst_stack")
    self:SetStackCount(0)
    self.count = 0
    return stacks
end

modifier_aghsfort_nevermore_necromastery_thirst_stack = {}

function modifier_aghsfort_nevermore_necromastery_thirst_stack:IsHidden()
    return true
end

function modifier_aghsfort_nevermore_necromastery_thirst_stack:IsPurgable()
    return false
end

function modifier_aghsfort_nevermore_necromastery_thirst_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_aghsfort_nevermore_necromastery_thirst_stack:OnCreated(kv)
    if IsServer() then
        self.stacks = kv.stacks
    end
end

function modifier_aghsfort_nevermore_necromastery_thirst_stack:OnRemoved(kv)
    if IsServer() == false then
		return
	end

	local hBuff = self:GetParent():FindModifierByName( "modifier_aghsfort_nevermore_necromastery_thirst" )
	if hBuff == nil then
		return
	end

 	local nNewStackCount = hBuff:reduceStacks(self.stacks)
end

aghsfort_nevermore_legend_reiatsu = class(ability_legend_base)

function aghsfort_nevermore_legend_reiatsu:OnUpgrade()
    local requiem = self:GetCaster():FindAbilityByName("aghsfort_nevermore_requiem")
    if IsValid(requiem) then
        requiem.shard_reiatsu = self
    end
    self.raze = self:GetCaster():FindAbilityByName("aghsfort_nevermore_shadowraze1")
end

function aghsfort_nevermore_legend_reiatsu:OnProjectileHit(hTarget, vLocation)
    if IsValid(self.raze) and IsValid(hTarget) then
        self.raze:doShadowraze({
        point = hTarget:GetAbsOrigin()
        })
        return true
    end
end

modifier_aghsfort_nevermore_legend_reiatsu=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_nevermore_legend_reiatsu", "abilities/heroes/nevermore/legends",LUA_MODIFIER_MOTION_NONE)

-- 
aghsfort_nevermore_legend_soul_callback = class(ability_legend_base)

function aghsfort_nevermore_legend_soul_callback:OnUpgrade()
    self.damage_pct = self:GetSpecialValueFor("damage_pct") * 0.01
    local requiem = self:GetCaster():FindAbilityByName("aghsfort_nevermore_requiem")
    if IsValid(requiem) then
        requiem.shard_callback = self
    end
end

modifier_aghsfort_nevermore_legend_soul_callback=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_nevermore_legend_soul_callback", "abilities/heroes/nevermore/legends",LUA_MODIFIER_MOTION_NONE)


-- 
aghsfort_nevermore_legend_made_in_hell = class(ability_legend_base)

function aghsfort_nevermore_legend_made_in_hell:OnUpgrade()
    self.atk_increase = self:GetSpecialValueFor("atk_increase")
    self.fly_thres = self:GetSpecialValueFor("fly_thres")
    self.multiplier = self:GetSpecialValueFor("duration_multiplier")
    local requiem = self:GetCaster():FindAbilityByName("aghsfort_nevermore_requiem")
    if IsValid(requiem) then
        requiem.shard_hell = self
    end
end

function aghsfort_nevermore_legend_made_in_hell:doAction(kv)
    local duration = self.multiplier * kv.base_duration
    kv.caster:AddNewModifier(kv.caster, self, "modifier_aghsfort_nevermore_made_in_hell", {
        duration = duration,
        stack_duration = duration,
        stacks = kv.stacks
    })
end

modifier_aghsfort_nevermore_legend_made_in_hell=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_nevermore_legend_made_in_hell", "abilities/heroes/nevermore/legends",LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_nevermore_made_in_hell = {}

LinkLuaModifier("modifier_aghsfort_nevermore_made_in_hell", "abilities/heroes/nevermore/legends",LUA_MODIFIER_MOTION_NONE)
-- Properties
function modifier_aghsfort_nevermore_made_in_hell:IsPurgable()
    return true
end

function modifier_aghsfort_nevermore_made_in_hell:DestroyOnExpire()
    return true
end

function modifier_aghsfort_nevermore_made_in_hell:RemoveOnDeath()
    return true
end

function modifier_aghsfort_nevermore_made_in_hell:OnCreated(kv)
    -- print("start stacking")
    self.atk_increase = self:GetAbility():GetSpecialValueFor("atk_increase")
    self.fly_thres = self:GetAbility():GetSpecialValueFor("fly_thres")
    self:updateData(kv)
end

function modifier_aghsfort_nevermore_made_in_hell:OnRefresh(kv)
    -- print("update stacking")
    self:updateData(kv)
end

function modifier_aghsfort_nevermore_made_in_hell:CheckState()
    local flying = self:GetStackCount() >= self.fly_thres
    return {
        [MODIFIER_STATE_FLYING] = flying,
        [MODIFIER_STATE_FORCED_FLYING_VISION] = flying
    }
    
end

function modifier_aghsfort_nevermore_made_in_hell:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_SCALE,
    }
end

function modifier_aghsfort_nevermore_made_in_hell:GetModifierBaseDamageOutgoing_Percentage()
    return self.atk_increase * self:GetStackCount()
end

function modifier_aghsfort_nevermore_made_in_hell:GetModifierModelScale()
    return self:GetStackCount()
end

function modifier_aghsfort_nevermore_made_in_hell:updateData(kv)

    -- print("hp:"..self.hp_regen..", mp:"..self.mp_regen)
    self.stack_duration = kv.stack_duration
    if IsServer() then
        IncreaseStack({
            modifier = self,
            duration = self.stack_duration,
            destroy_no_layer = 1,
            stacks = kv.stacks
        })
    end
end

