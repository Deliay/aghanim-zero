require("abilities/heroes/antimage/legends")
aghsfort_antimage_mana_break = {}

LinkLuaModifier("modifier_aghsfort_antimage_mana_break", "abilities/heroes/antimage/mana_break",
    LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghsfort_antimage_imagine_breaker", "abilities/heroes/antimage/mana_break",
    LUA_MODIFIER_MOTION_NONE)

function aghsfort_antimage_mana_break:GetIntrinsicModifierName()
    return "modifier_aghsfort_antimage_mana_break"
end

function aghsfort_antimage_mana_break:OnUpgrade()
    local modifier_passive = self:GetCaster():FindModifierByName("modifier_aghsfort_antimage_mana_break")
    -- print("get modifier")
    if modifier_passive ~= nil then
        -- print("refresh modifier")
        modifier_passive:ForceRefresh()
    end
end

modifier_aghsfort_antimage_mana_break = {}
function modifier_aghsfort_antimage_mana_break:IsDebuff()
    return false
end
function modifier_aghsfort_antimage_mana_break:IsHidden()
    return true
end
function modifier_aghsfort_antimage_mana_break:IsPurgable()
    return false
end

function modifier_aghsfort_antimage_mana_break:OnCreated(table)
    -- references
    self:updateData()
    self.illusion_pct = self:GetAbility():GetSpecialValueFor("illusion_percentage") * 0.01
    self.caster = self:GetAbility():GetCaster()
end

function modifier_aghsfort_antimage_mana_break:OnRefresh(table)
    -- references
    self:updateData()
end

function modifier_aghsfort_antimage_mana_break:DeclareFunctions()
    return {MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL}
end

function modifier_aghsfort_antimage_mana_break:GetModifierProcAttack_BonusDamage_Physical(params)
    if IsServer() and (not self:GetParent():PassivesDisabled()) then
        local target = params.target
        if target == nil then
            return
        end
        local filter = UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
            0, self:GetParent():GetTeamNumber())

        -- self:updateData()
        local mana_break = self.mana_break +
                               GetTalentValue(self:GetAbility():GetCaster(), "aghsfort_antimage_mana_break+mana_per_hit")
        local mana_pct = self.mana_break_pct
        local damage_pct = 1.0
        if self:GetParent():IsIllusion() then
            damage_pct = damage_pct * self.illusion_pct
        end
        if filter == UF_SUCCESS then
            local mana = target:GetMana()
            local mana_burn = mana_break + mana * mana_pct
            local damage = 0
            if mana ~= 0 then
                target:Script_ReduceMana(math.min(mana, mana_burn), self)
                damage = mana_burn * damage_pct
            else
                damage = mana_break * damage_pct
            end
            self:playEffects({
                target = target
            })
            self:manaTransfer({
                amount = mana_burn
            })
            self:manaExplosion({
                target = target,
                damage_pct = damage_pct
            })
            self:imagineBreaker({
                target = target
            })
            -- print(damage)
            return damage
        end
    end

end

function modifier_aghsfort_antimage_mana_break:updateData()
    self.mana_break = self:GetAbility():GetSpecialValueFor("mana_per_hit")
    self.mana_break_pct = self:GetAbility():GetSpecialValueFor("mana_per_hit_pct") * 0.01
    self.mana_damage_pct = self:GetAbility():GetSpecialValueFor("percent_damage_per_burn") * 0.01
end

function modifier_aghsfort_antimage_mana_break:playEffects(kv)
    -- Get Resources
    local pfx_name = "particles/generic_gameplay/generic_manaburn.vpcf"
    local sfx = "Hero_Antimage.ManaBreak"

    -- Create Particle
    local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_ABSORIGIN_FOLLOW, kv.target)
    -- ParticleManager:SetParticleControl( pfx, 0, vControlVector )
    ParticleManager:ReleaseParticleIndex(pfx)

    -- Create Sound
    EmitSoundOn(sfx, kv.target)
end

function modifier_aghsfort_antimage_mana_break:manaTransfer(kv)
    local shard_modifier = self.caster:FindModifierByName("modifier_aghsfort_antimage_legend_mana_transfer")
    -- local shard = self.caster:FindAbilityByName("aghsfort_antimage_legend_mana_transfer")
    if shard_modifier ~= nil then
        local shard = shard_modifier:GetAbility()
        local pct = shard:GetSpecialValueFor("transfer_pct") * 0.01
        local target = self:GetParent()
        -- print("mana transfering.." .. (kv.amount * pct))
        self:manaTransferEffect({
            target = target
        })
        target:Heal(kv.amount * pct, self:GetAbility())
    end
end

function modifier_aghsfort_antimage_mana_break:manaTransferEffect(kv)
    -- Get Resources
    local pfx_name = "particles/generic_gameplay/generic_lifesteal_blue.vpcf"
    -- Create Particle
    local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_ABSORIGIN_FOLLOW, kv.target)
    -- ParticleManager:SetParticleControl( pfx, 0, vControlVector )
    ParticleManager:ReleaseParticleIndex(pfx)
end

function modifier_aghsfort_antimage_mana_break:manaExplosion(kv)
    local shard_modifier = self.caster:FindModifierByName("modifier_aghsfort_antimage_legend_mana_explosion")
    -- local shard = self.caster:FindAbilityByName("aghsfort_antimage_legend_mana_explosion")
    local related_ability = self.caster:FindAbilityByName("aghsfort_antimage_mana_void")
    if shard_modifier ~= nil and related_ability ~= nil and related_ability:GetLevel() > 0 then
        local shard = shard_modifier:GetAbility()
        local chance = shard:GetSpecialValueFor("chance")
        if RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, self.caster) == true then
            local pct = shard:GetSpecialValueFor("effect_pct") * 0.01 * kv.damage_pct
            local target = kv.target
            -- print("mana explode!")
            related_ability:doAction({
                caster = self.caster,
                target = target,
                percentage = pct
            })
        end
    end
end

function modifier_aghsfort_antimage_mana_break:imagineBreaker(kv)
    local shard_modifier = self.caster:FindModifierByName("modifier_aghsfort_antimage_legend_imagine_breaker")
    -- local shard = self.caster:FindAbilityByName("aghsfort_antimage_legend_imagine_breaker")
    -- print("try find imagine breaker...")
    if shard_modifier ~= nil then
        local target = kv.target
        local shard = shard_modifier:GetAbility()
        if target ~= nil then
            -- print("break your imagine")
            -- print(self:GetAbility():GetAbilityName())
            local duration = shard:GetSpecialValueFor("duration")
            target:AddNewModifier(self.caster, self:GetAbility(), "modifier_aghsfort_antimage_imagine_breaker", {
                stack_duration = duration,
                duration = duration
            })
        end
    end
end

modifier_aghsfort_antimage_imagine_breaker = {}
-- Properties
function modifier_aghsfort_antimage_imagine_breaker:IsDebuff()
    return true
end
function modifier_aghsfort_antimage_imagine_breaker:IsHidden()
    return false
end
function modifier_aghsfort_antimage_imagine_breaker:IsPurgable()
    return true
end
function modifier_aghsfort_antimage_imagine_breaker:DestroyOnExpire()
    return true
end
function modifier_aghsfort_antimage_imagine_breaker:RemoveOnDeath()
    return true
end

function modifier_aghsfort_antimage_imagine_breaker:OnCreated(kv)
    -- print("start stacking")
    self:updateData(kv)
    self:playEffect(true)
end

function modifier_aghsfort_antimage_imagine_breaker:OnRefresh(kv)
    -- print("update stacking")
    self:updateData(kv)
end

function modifier_aghsfort_antimage_imagine_breaker:OnStackCountChanged(count)
    self:playEffect(false)
end

function modifier_aghsfort_antimage_imagine_breaker:OnDestroy()
end

function modifier_aghsfort_antimage_imagine_breaker:DeclareFunctions()
    return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_aghsfort_antimage_imagine_breaker:updateData(kv)
    if IsValid(self:GetAbility()) then
        self.pct_per_stack = self:GetAbility():GetSpecialValueFor("mana_per_hit_pct")
    end
    self.stack_duration = (kv.stack_duration or 0)
    if IsServer() then
        IncreaseStack({
            modifier = self,
            duration = self.stack_duration,
            destroy_no_layer = 1
        })
    end
end

function modifier_aghsfort_antimage_imagine_breaker:playEffect(bStart)
    -- particles/units/heroes/hero_antimage/antimage_imagine_breaker_debuff.vpcf
    if IsServer() then
        local parent = self:GetParent()
        if bStart then
            if self.pfx then
                ParticleManager:DestroyParticle(self.pfx, true)
                ParticleManager:ReleaseParticleIndex(self.pfx)
            end

            self.pfx = ParticleManager:CreateParticle(
                "particles/units/heroes/hero_antimage/antimage_imagine_breaker_debuff.vpcf", PATTACH_OVERHEAD_FOLLOW,
                parent)
            -- print(parent:GetAbsOrigin())
            ParticleManager:SetParticleControl(self.pfx, 1, Vector(0, self:GetStackCount(), 0))
            ParticleManager:SetParticleControl(self.pfx, 5, Vector(-8, 0, 0))
            ParticleManager:SetParticleControlEnt(self.pfx, 3, parent, PATTACH_OVERHEAD_FOLLOW, "attach_overhead", Vector(0,0,0), true)
            ParticleManager:SetParticleControlEnt(self.pfx, 5, parent, PATTACH_OVERHEAD_FOLLOW, "attach_overhead", Vector(0,0,0),true)
            self:AddParticle(self.pfx, false, false, 1, false, true)
        else
            if self.pfx then
                print("update")

                if self:GetStackCount() < 10 then
                    ParticleManager:SetParticleControl(self.pfx, 1, Vector(0, self:GetStackCount(), 0))
                    ParticleManager:SetParticleControl(self.pfx, 5, Vector(-8,0,0))
                else
                    local count = self:GetStackCount()
                    ParticleManager:SetParticleControl(self.pfx, 1, Vector(math.floor(count/10), count % 10, 0))
                    ParticleManager:SetParticleControl(self.pfx, 5, Vector(0,0,0))
                end
            end
        end
    end

end

function modifier_aghsfort_antimage_imagine_breaker:GetModifierTotalDamageOutgoing_Percentage(kv)
    if kv ~= nil and kv.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
        local reduction = -self:GetStackCount() * self.pct_per_stack
        -- print("spell damage reduced!:" .. reduction)
        return reduction
    else
        return 0
    end
end

function modifier_aghsfort_antimage_imagine_breaker:OnTooltip()
    return self:GetStackCount() * self.pct_per_stack
end
