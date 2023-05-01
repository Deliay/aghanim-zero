-- keys
-- modifier: the modifier to increase stack
-- duration: stack duration
-- destroy_no_layer : if destroy when no layer
function IncreaseStack(kv)
    if IsValid(kv.modifier) then
        local ability = kv.modifier:GetAbility()
        local caster = ability:GetCaster()
        local duration = kv.duration or 0
        if kv.stacks == nil then
            local modifier_layer = kv.modifier:GetParent():AddNewModifier(caster, ability, "modifier_generic_layer_stack", {
                duration = duration,
                purgable = kv.modifier:IsPurgable(),
                destroy_no_layer = kv.destroy_no_layer,
                stacks = 1
            })
            if IsValid(modifier_layer) then 
                modifier_layer.modifier = kv.modifier
                kv.modifier:IncrementStackCount()
            end
        else
            local modifier_layer = kv.modifier:GetParent():AddNewModifier(caster, ability, "modifier_generic_layer_stack", {
                duration = duration,
                purgable = kv.modifier:IsPurgable(),
                destroy_no_layer = kv.destroy_no_layer,
                stacks = kv.stacks
            })
            if IsValid(modifier_layer) then 
                modifier_layer.modifier = kv.modifier
                kv.modifier:SetStackCount(kv.modifier:GetStackCount() + kv.stacks)
            end
        end
    end
end

function DecreaseStack(kv)
    if IsValid(kv.modifier) then
        kv.modifier:SetStackCount(kv.modifier:GetStackCount() - kv.stacks)

        local destroy_no_layer = kv.destroy_no_layer or 1
        if destroy_no_layer > 0 and kv.modifier:GetStackCount() <= 0 then
            kv.modifier:Destroy()
        end
    end
end

function AddModifierConsiderResist(hTarget, hCaster, hAbility, szModifierName, kv)
    -- if hCaster ~= nil and not hCaster:IsNull() then
    --     print("debuff amp:"..hCaster:)
    -- end
    if IsValid(hTarget) then
        local duration_pct = 1 - hTarget:GetStatusResistance()
        kv.duration = kv.duration * duration_pct
        if kv.tick_interval ~= nil then
            -- print(kv.tick_interval.."dsfdsf"..duration_pct)
            kv.tick_interval = math.max(kv.tick_interval * duration_pct, FrameTime())
            -- print(kv.tick_damage)
        end
        hTarget:AddNewModifier(hCaster, hAbility, szModifierName, kv)
    end
end

function UpdateDurationUnderResist(hTarget, hCaster, hModifier, fDelta, fMax)
    local duration_pct = (100 - hTarget:GetStatusResistance()) * 0.01
    local new_duration = math.min(fMax*duration_pct, hModifier:GetDuration() + fDelta * duration_pct)

    hModifier:SetDuration(new_duration, true)
end

function RescaleSlowUnderResist(hNPC, slow)
    local resist = hNPC
    return slow * (1 - hNPC:GetStatusResistance())
end

function RescaleDamageUnderResist(hNPC, damage)
    local resist = math.max(0.1, 1 - hNPC:GetStatusResistance())
    return damage / resist
end


function AddNewModifierWhenPossible(hTarget, hCaster, hAbility, pszScriptName, hModifierTable)
	Timers:CreateTimer(0.1, function()
		if not IsValid(hTarget) then
            return nil
        end
        if not hTarget:IsAlive() or (IsEnemy(hTarget, hCaster) and hTarget:IsInvulnerable()) then
			return 0.1
		else
			hTarget:AddNewModifier(hCaster, hAbility, pszScriptName, hModifierTable)
		end			
	end)
end