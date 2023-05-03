require("abilities/heroes/antimage/legends")
aghsfort_antimage_blink_fragment = aghsfort_antimage_blink_fragment or {}

aghsfort_antimage_blink_fragment.parent_ability_name = "aghsfort_antimage_blink"
function aghsfort_antimage_blink_fragment:GetManaCost(iLevel)
    return GetParentAbilityManaCost(self)
end

function aghsfort_antimage_blink_fragment:GetCooldown(iLevel)
    return GetParentAbilityCooldown(self)
end

function aghsfort_antimage_blink_fragment:OnAbilityPhaseStart()
    self.parent_ability = self:GetCaster():FindAbilityByName(self.parent_ability_name)
    if self.parent_ability == nil or self.parent_ability:GetLevel() < 1 then
        return false
    end
    return true
end

function aghsfort_antimage_blink_fragment:GetCastRange()
    self.parent_ability = self:GetCaster():FindAbilityByName("aghsfort_antimage_blink")
    if self.parent_ability ~= nil then
        local cast_range = self.parent_ability:getMaxDistance()
        -- print("frsagment_range:"..cast_range)
        return cast_range
    else
        return self.BaseClass.GetCastRange()
    end
end

function aghsfort_antimage_blink_fragment:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local target_pos = self:GetCursorPosition()
    local direction = (target_pos - caster:GetAbsOrigin()):Normalized()
    direction.z = 0.0

    EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_Antimage.Blink_out", caster)

    local pfx_start_name = "particles/units/heroes/hero_antimage/antimage_blink_start.vpcf"
	local pfx_end_name = "particles/units/heroes/hero_antimage/antimage_blink_end.vpcf"
	local pfx_start = ParticleManager:CreateParticle(pfx_start_name, PATTACH_CUSTOMORIGIN, caster)
    -- 播放跳出特效
    ParticleManager:SetParticleControl(pfx_start, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControlEnt(pfx_start, 1, caster, PATTACH_CUSTOMORIGIN, "attach_hitloc", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlForward(pfx_start, 0, direction)

    local illusion_ability = caster:FindAbilityByName("aghsfort_antimage_illusion")
    if illusion_ability ~= nil then
        local result = illusion_ability:doAction({
            position = target_pos,
        })

        -- 播放跳入特效
        -- print("blinking in")
        local pfx_end = ParticleManager:CreateParticle(pfx_end_name, PATTACH_POINT_FOLLOW, result.new_illusion)
        ParticleManager:SetParticleControlEnt(pfx_end, 0, result.new_illusion, PATTACH_POINT_FOLLOW, "attach_hitloc", result.new_illusion:GetAbsOrigin(), true)
        
        ParticleManager:ReleaseParticleIndex(pfx_start)
        ParticleManager:ReleaseParticleIndex(pfx_end)
        
        if IsValid(target) and IsValid(result.new_illusion) then
            EmitSoundOnLocationWithCaster(target_pos, "Hero_Antimage.Blink_in", result.new_illusion)
            result.new_illusion:MoveToTargetToAttack(target)
        end
    end

    if not caster:IsIllusion() then
        GetParentAbility(self):blinkCounter({})
    end
    
end
