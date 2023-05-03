require("abilities/heroes/antimage/legends")
aghsfort_antimage_blink = aghsfort_antimage_blink or {}

function aghsfort_antimage_blink:OnSpellStart()
    -- 让施法者躲避弹道
    local caster = self:GetCaster()
    local start_pos = caster:GetAbsOrigin()
    ProjectileManager:ProjectileDodge(caster)

    local target_pos = self:GetCursorPosition()
    local direction = target_pos - start_pos
    direction.z = 0.0
    direction = direction:Normalized()

    -- local max_distance = self:GetSpecialValueFor("blink_range") + caster:GetCastRangeBonus()
    -- print(target_pos)
    local max_distance = self:getMaxDistance()
    -- print("max_distance:"..max_distance)

	caster:EmitSound("Hero_Antimage.Blink_out")

    local pfx_start_name = "particles/units/heroes/hero_antimage/antimage_blink_start.vpcf"
	local pfx_end_name = "particles/units/heroes/hero_antimage/antimage_blink_end.vpcf"
	local pfx_start = ParticleManager:CreateParticle(pfx_start_name, PATTACH_CUSTOMORIGIN, caster)
    -- 播放跳出特效
    ParticleManager:SetParticleControl(pfx_start, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(pfx_start, 1, caster, PATTACH_CUSTOMORIGIN, "attach_hitloc", caster:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlForward(pfx_start, 0, direction)

    -- 执行位移
	local distance = (target_pos - caster:GetAbsOrigin()):Length2D()
	if distance <= max_distance then
        FindClearSpaceForUnit(caster, target_pos, false)
	else
		target_pos = caster:GetAbsOrigin() + direction * max_distance
		FindClearSpaceForUnit(caster, target_pos, false)
    end
    ProjectileManager:ProjectileDodge(caster)

    self:blinkIllusion({
        position = start_pos
    })

    self:blinkCounter(
        {}
    )
    -- 播放跳入特效
    local pfx_end = ParticleManager:CreateParticle(pfx_end_name, PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(pfx_end, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	caster:EmitSound("Hero_Antimage.Blink_in")
	ParticleManager:ReleaseParticleIndex(pfx_start)
	ParticleManager:ReleaseParticleIndex(pfx_end)
end

function aghsfort_antimage_blink:GetCastRange()
    if IsServer() then
        return 99999
    end
    -- local cast_range = self:GetSpecialValueFor("blink_range")+ GetTalentValue(self:GetCaster(),"aghsfort_antimage_blink+blink_distance")
    local cast_range = self:getMaxDistance()
    -- print("cast range:"..cast_range)
    return cast_range
end

function aghsfort_antimage_blink:GetCooldown(iLevel)
    local cooldown = self.BaseClass.GetCooldown(self, iLevel) - GetTalentValue(self:GetCaster(),"aghsfort_antimage_blink-cd")
    -- print(cooldown)
    return math.max(cooldown, 0)
end

function aghsfort_antimage_blink:OnUpgrade()
    local caster = self:GetCaster()
    local illusion_ability = caster:FindAbilityByName("aghsfort_antimage_illusion")
    if illusion_ability ~= nil then
        illusion_ability:SetLevel(1)
    end
end

function aghsfort_antimage_blink:blinkIllusion(kv)
    -- local shard_modifier = self.caster:FindModifierByName("modifier_aghsfort_antimage_legend_mana_transfer")
    local caster = self:GetCaster()
    local shard = caster:FindAbilityByName("aghsfort_antimage_legend_blink_illusion")
    if shard ~= nil then
        local illusion_ability = caster:FindAbilityByName("aghsfort_antimage_illusion")
        if illusion_ability ~= nil then
            illusion_ability:doAction({
                position = kv.position,
            })
        end
    end
end

function aghsfort_antimage_blink:blinkCounter(kv)
    local caster = self:GetCaster()
    if not caster:IsIllusion() then
        local shard = caster:FindAbilityByName("aghsfort_antimage_legend_blink_counter")
        if shard ~= nil then
            local ability = caster:FindAbilityByName("aghsfort_antimage_counterspell")
            if ability ~= nil then
                ability:doAction(
                    {
                        illusion_replicate = true
                    }
                )
            end
        end
    end
end

function aghsfort_antimage_blink:getMaxDistance()
    local range_bonus = self:GetCaster():GetCastRangeBonus()
    local max_distance = self:GetSpecialValueFor("blink_range") + range_bonus + GetTalentValue(self:GetCaster(),"aghsfort_antimage_blink+blink_distance")
    -- local max_distance = self:GetSpecialValueFor("blink_range") + range_bonus 
    return max_distance
end
