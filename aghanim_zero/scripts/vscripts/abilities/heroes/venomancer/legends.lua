require("modifiers/ext/modifier_legend_base")
require("abilities/ext/ability_legend_base")
-- 
aghsfort_venomancer_legend_gale_ward = class(ability_legend_base)

function aghsfort_venomancer_legend_gale_ward:Init()
    local caster = self:GetCaster()
    self.gale = caster:FindAbilityByName("aghsfort2_venomancer_venomous_gale")
    if IsValid(self.gale) then
        print("found ability gale")
        self.gale.shard_ward = self
    end
    self.ward = caster:FindAbilityByName("aghsfort2_venomancer_plague_ward")
    if IsValid(self.ward) then
        print("found ability ward")
    end
end

function aghsfort_venomancer_legend_gale_ward:doAction(kv)
    local target = kv.target
    local caster = kv.caster
    -- print("try spawn ward!")
    if not IsValid(target) or not IsValid(self.ward) or self.ward:GetLevel() < 1 then
        -- print("spawn ward failed")
        return
    end
    local pos_list = {}
    local offset = self:GetSpecialValueFor("offset")
    local origin = target:GetAbsOrigin()
    if IsAghanimConsideredHero(target) then
        local count = self:GetSpecialValueFor("wards_cap")
        if target:IsBossCreature() then
            count = self:GetSpecialValueFor("wards_boss")
        end
        print("ward count is ..."..count)
        for i = 1, count do
            table.insert(pos_list, origin + RandomVector(offset))
        end
    else
        local chance = self:GetSpecialValueFor("creep_pct")
        if RollPercentage(chance) == true then
            table.insert(pos_list, origin + RandomVector(offset))
        end
    end
    if #pos_list > 0 then
        self.ward:doAction({
            caster = caster,
            pos_list = pos_list
        })
    end
end

modifier_aghsfort_venomancer_legend_gale_ward=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_venomancer_legend_gale_ward", "abilities/heroes/venomancer/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_venomancer_legend_gale_ring = class(ability_legend_base)

function aghsfort_venomancer_legend_gale_ring:Init()
    local caster = self:GetCaster()
    self.gale = caster:FindAbilityByName("aghsfort2_venomancer_venomous_gale")
    if IsValid(self.gale) then
        print("found ability gale")
        self.gale.shard_ring = self
    end
end

modifier_aghsfort_venomancer_legend_gale_ring=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_venomancer_legend_gale_ring", "abilities/heroes/venomancer/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_venomancer_legend_gale_atk = class(ability_legend_base)

function aghsfort_venomancer_legend_gale_atk:Init()
    local caster = self:GetCaster()
    self.gale = caster:FindAbilityByName("aghsfort2_venomancer_venomous_gale")
    if IsValid(self.gale) then
        print("found ability gale")
        self.gale.shard_atk = self
    end
end

modifier_aghsfort_venomancer_legend_gale_atk=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_venomancer_legend_gale_atk", "abilities/heroes/venomancer/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_venomancer_legend_sting_boom = class(ability_legend_base)

function aghsfort_venomancer_legend_sting_boom:Init()
    local caster = self:GetCaster()
    self.sting = caster:FindAbilityByName("aghsfort2_venomancer_poison_sting")
    if IsValid(self.sting) then
        print("found ability sting")
        self.sting.shard_boom = self
    end
end

function aghsfort_venomancer_legend_sting_boom:doAction(kv)
    local attacker = kv.attacker
    local target = kv.target
    local duration = kv.duration

    local result = {}
    if IsValid(target) then
        result.mod = target:FindModifierByName("modifier_aghsfort_venomancer_sting_boom")
        if IsValid(result.mod) then
            result.mod:SetDuration(math.max(result.mod:GetRemainingTime(), duration), true)
        else
            result.mod = target:AddNewModifier(attacker, self, "modifier_aghsfort_venomancer_sting_boom", {duration = duration})
        end
    end
    return result
end

function aghsfort_venomancer_legend_sting_boom:explode(kv)
    local attacker = kv.attacker
    local target = kv.target
    local bDeath = kv.bDeath
    local damage = kv.damage * self:GetSpecialValueFor("damage_mul")
    if damage < 0.1 then
        return
    end
    if not IsValid(attacker) then
        attacker = self:GetCaster()
    end

    local pos = target:GetAbsOrigin()
    local radius = self:GetSpecialValueFor("radius")
    if not bDeath then
        damage = damage * self:GetSpecialValueFor("no_death_mul")
    end

    self:PlayEffects({
        -- pos = pos
        target = target
    })

    local damage_table = {
        victim = target,
        attacker = attacker,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self,
    }
    local enemies = FindUnitsInRadius(attacker:GetTeamNumber(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _, enemy in pairs(enemies) do
        damage_table.victim = enemy
        ApplyDamage(damage_table)
        if IsValid(damage_table.victim) then
            SendOverheadEventMessage(
                nil,
                OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,
                damage_table.victim,
                damage_table.damage,
                nil
            )
        end
    end
end

function aghsfort_venomancer_legend_sting_boom:PlayEffects(kv)
    local target = kv.target
    local pos = target:GetAbsOrigin()
	-- Get Resources
	local pfx_name = "particles/econ/items/sand_king/sandking_ti7_arms/sandking_ti7_caustic_finale_explode.vpcf"
	local sfx = "Ability.Embiggen.Target"

	-- Create Particle
	local pfx = ParticleManager:CreateParticle( pfx_name, PATTACH_WORLDORIGIN, nil )
    ParticleManager:SetParticleControl(pfx, 0, pos)
	ParticleManager:ReleaseParticleIndex( pfx )

	-- Create Sound
    -- EmitSoundOnLocationWithCaster(pos, sfx, self:GetCaster())
    target:EmitSound(sfx)
end

modifier_aghsfort_venomancer_legend_sting_boom=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_venomancer_legend_sting_boom", "abilities/heroes/venomancer/legends",LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_venomancer_sting_boom={}

LinkLuaModifier("modifier_aghsfort_venomancer_sting_boom", "abilities/heroes/venomancer/legends",LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_venomancer_sting_boom:IsHidden()
    return false
    -- return true
end

function modifier_aghsfort_venomancer_sting_boom:GetPriority()
    return MODIFIER_PRIORITY_ULTRA
end

function modifier_aghsfort_venomancer_sting_boom:IsPurgable()
    return self.bPurgable
end

function modifier_aghsfort_venomancer_sting_boom:RemoveOnDeath()
    return true
end

function modifier_aghsfort_venomancer_sting_boom:OnCreated(kv)
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.attacker = self:GetCaster()
	self.bPurgable = not IsValid(self.ability.sting.shard_side)

    if IsServer() then
        self.damage = 0
    end
end


function modifier_aghsfort_venomancer_sting_boom:OnRefresh(kv)
    
end

function modifier_aghsfort_venomancer_sting_boom:OnRemoved()
    if IsServer() then
        print("remove boom check!")
        if IsValid(self.parent) then
            if IsValid(self.ability) then
                local bDeath = self.parent:GetHealth() <= 0 or not self.parent:IsAlive()
                if not bDeath then
                    if self:GetRemainingTime() > 0.03 then
                        print("purged!"..self.parent:GetHealth())
                        return
                    end
                    print("non death!")
                else
                    print("death trigger!")
                end
                self.ability:explode({
                    attacker = self.attacker,
                    target = self.parent,
                    damage = self.damage,
                    bDeath = bDeath
                })
            else
                print("invalid ability!")
            end
            
        else
            print("parent removed!")
        end
    end
end

-- function modifier_aghsfort_venomancer_sting_boom:DeclareFunctions()
--     return {
--         MODIFIER_EVENT_ON_DEATH
--     }
-- end

-- function modifier_aghsfort_venomancer_sting_boom:OnDeath(event)
--     if IsServer() then
-- 		if IsValid(event.unit) and event.unit == self.parent and IsValid(self.ability) then
--             print("death explosion!")
--             self.ability:explode({
--                 attacker = self.attacker,
--                 target = self.parent,
--                 damage = self.damage,
--                 bDeath = true
--             })
-- 		end
--         if IsValid(self) then
--             self:Destroy()
--         end
-- 	end
-- end

function modifier_aghsfort_venomancer_sting_boom:addDamage(fDamage)
    self.damage = self.damage + fDamage
end

-- 
aghsfort_venomancer_legend_sting_side = class(ability_legend_base)

function aghsfort_venomancer_legend_sting_side:Init()
    local caster = self:GetCaster()
    self.sting = caster:FindAbilityByName("aghsfort2_venomancer_poison_sting")
    if IsValid(self.sting) then
        print("found ability sting")
        self.sting.shard_side = self
    end
end

function aghsfort_venomancer_legend_sting_side:doAction(kv)
    local caster = self:GetCaster()
    local target = kv.target
    local duration = kv.duration
    -- print("apply side effect")
    local result = {}
    if IsValid(target) then
        result.mod = target:FindModifierByName("modifier_aghsfort_venomancer_sting_side")
        if IsValid(result.mod) then
            result.mod:SetDuration(math.max(result.mod:GetRemainingTime(), duration), true)
        else
            result.mod = target:AddNewModifier(caster, self, "modifier_aghsfort_venomancer_sting_side", {duration = duration})
        end
    end
    return result
end

modifier_aghsfort_venomancer_legend_sting_side=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_venomancer_legend_sting_side", "abilities/heroes/venomancer/legends",LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_venomancer_sting_side={}

LinkLuaModifier("modifier_aghsfort_venomancer_sting_side", "abilities/heroes/venomancer/legends",LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_venomancer_sting_side:IsPurgable()
    return false
end

function modifier_aghsfort_venomancer_sting_side:GetEffectName()
    return "particles/items4_fx/spirit_vessel_damage.vpcf"
end

function modifier_aghsfort_venomancer_sting_side:OnCreated(kv)
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.parent = self:GetParent()
    if IsServer() then
        self.damage_table = {
			victim = self.parent,
			attacker = self.caster,
			damage = 0,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_HPLOSS,
			ability = self.ability,
        }
    end
    self:updateData(kv)
end
function modifier_aghsfort_venomancer_sting_side:OnRefresh(kv)
    self:updateData(kv)
end

function modifier_aghsfort_venomancer_sting_side:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_EVENT_ON_HEAL_RECEIVED,
    }
end

function modifier_aghsfort_venomancer_sting_side:GetModifierHPRegenAmplify_Percentage()
    return -self.regen_sup
end

function modifier_aghsfort_venomancer_sting_side:OnHealReceived(event)
    if event.unit == self.parent then
        -- print('heal')
        -- PrintTable(event)
        if IsValid(self.parent) and event.gain > 1 then
            self.damage_table.damage = event.gain
            self.parent:ModifyHealth(self.parent:GetHealth() - event.gain, self.ability, false, DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DIRECTOR_EVENT)
            ApplyDamage(self.damage_table)
        end
    end
end

function modifier_aghsfort_venomancer_sting_side:updateData(kv)
    self.regen_sup = self.ability:GetSpecialValueFor("regen_pct")
end

-- 
aghsfort_venomancer_legend_sting_splash = class(ability_legend_base)

function aghsfort_venomancer_legend_sting_splash:Init()
    local caster = self:GetCaster()
    self.sting = caster:FindAbilityByName("aghsfort2_venomancer_poison_sting")
    if IsValid(self.sting) then
        print("found ability sting")
        self.sting.shard_splash = self
    end
end

function aghsfort_venomancer_legend_sting_splash:OnUpgrade()
    self.pct_base = self:GetSpecialValueFor("pct_base")
    self.pct_mul = self:GetSpecialValueFor("pct_mul")
end

function aghsfort_venomancer_legend_sting_splash:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    local attacker = EntIndexToHScript(ExtraData.attacker_id)
	if IsValid(hTarget) and IsValid(attacker) then
        local damage = ExtraData.damage
        if ExtraData.iHero > 0 then
            hTarget:EmitSound("Hero_Venomancer.ProjectileImpact")
        else
            hTarget:EmitSound("Hero_VenomancerWard.ProjectileImpact")
        end

		local bounce = ExtraData.bounces - 1
		if bounce > 0 then
            if hTarget:HasModifier("modifier_aghsfort2_venomancer_poison_sting_ward") or hTarget:HasModifier("modifier_aghsfort2_venomancer_poison_sting") then
                local next_target = hTarget
                self:splashAttack({
                    attacker = attacker,
                    source = next_target,
                    damage = damage,
                    bounces = bounce,
                    iHero = ExtraData.iHero,
                })
            end
		end
        self.sting:doAction({
            target = hTarget,
            attacker = attacker,
        })

        local damage_table = {
            attacker = attacker,
            victim = hTarget,
            damage = damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL
        }
		ApplyDamage(damage_table)
	end
end

function aghsfort_venomancer_legend_sting_splash:doAction(kv)
    local attacker = kv.attacker
    local iHero = kv.iHero
    local target = kv.target
    local damage = kv.damage

    if IsValid(attacker) and IsValid(target) then
        if not target:HasModifier("modifier_aghsfort2_venomancer_poison_sting_ward") and not target:HasModifier("modifier_aghsfort2_venomancer_poison_sting") then
            return
        end
        local projectile_name = attacker:GetRangedProjectileName()
        local projectile_speed = attacker:GetProjectileSpeed()
        local bounces = 1
        if attacker:IsHero() then
            bounces = self:GetSpecialValueFor("bounce")
        else
            bounces = self:GetSpecialValueFor("bounce_ward")
        end
        self.reduction = (self.pct_base + self.pct_mul * math.abs(self.sting:GetSpecialValueFor("movement_speed") + GetTalentValue( self:GetCaster(), "venomancer_poison_sting-ms"))) * 0.01

        self:splashAttack({
            bounces = bounces,
            attacker = attacker,
            source = target,
            damage = damage,
            iHero = iHero,
        })
    end
end

function aghsfort_venomancer_legend_sting_splash:splashAttack(kv)
    local bounces = kv.bounces
    if bounces <= 0 then
        return
    end
    local attacker = kv.attacker
    local source = kv.source
    if not IsValid(attacker) or not IsValid(source) then
        return
    end
    local damage = kv.damage * self.reduction
    local iHero = kv.iHero
    
    local projectile_speed = 1200
    local projectile_name = "particles/units/heroes/hero_venomancer/venomancer_plague_ward_projectile.vpcf"
    if iHero > 0 then
        projectile_name = "particles/units/heroes/hero_venomancer/venomancer_base_attack.vpcf"
        projectile_speed = 900
    end

    local range = self:GetSpecialValueFor("radius")
    local targets = {}
	local enemies = FindUnitsInRadius(attacker:GetTeamNumber(), source:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		if enemy ~= source then
			table.insert(targets, enemy)
            if #targets >= bounces then
                break
            end
		end
	end
    for _, target in pairs(targets) do
        local projectile_info =
        {
            Target = target,
            Source = source,
            Ability = self,
            EffectName = projectile_name,
            iMoveSpeed = projectile_speed,
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
            bDrawsOnMinimap = false,
            bDodgeable = true,
            bIsAttack = false,
            bVisibleToEnemies = true,
            bReplaceExisting = false,
            bProvidesVision = false,
            ExtraData = {bounces = bounces, damage = damage, attacker_id = attacker:entindex(), iHero = iHero,}
        }
        ProjectileManager:CreateTrackingProjectile(projectile_info)
    end
end

modifier_aghsfort_venomancer_legend_sting_splash=class(modifier_legend_base)

function modifier_aghsfort_venomancer_legend_sting_splash:OnCreated(kv)
    local parent = self:GetParent()
    local ability = self:GetAbility()
    if IsValid(parent) and parent:IsIllusion() then        
        local sting = parent:FindAbilityByName("aghsfort2_venomancer_poison_sting")
        if IsValid(sting) then
            print("found illusion ability sting")
            sting.shard_splash = ability
        end
    end
end

LinkLuaModifier("modifier_aghsfort_venomancer_legend_sting_splash", "abilities/heroes/venomancer/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_venomancer_legend_ward_nova = class(ability_legend_base)

function aghsfort_venomancer_legend_ward_nova:Init()
    local caster = self:GetCaster()
    self.ward = caster:FindAbilityByName("aghsfort2_venomancer_plague_ward")
    if IsValid(self.ward) then
        print("found ability ward")
        self.ward.shard_nova = self
    end
    self.chimera = caster:FindAbilityByName("aghsfort2_venomancer_chimera_botany")
    if IsValid(self.chimera) then
        print("found ability chimera")
        self.chimera.shard_nova = self
    end
    self.nova = caster:FindAbilityByName("aghsfort2_venomancer_poison_nova")
end

function aghsfort_venomancer_legend_ward_nova:doAction(kv)
    local bWard = kv.bWard
    local target = kv.target
    if IsValid(target) then
        local dur_pct = self:GetSpecialValueFor("duration_mul")
        local rad_pct = self:GetSpecialValueFor("radius_mul")
        if not bWard then
            local mul = self:GetSpecialValueFor("chimera_mul")
            dur_pct = dur_pct * mul
            rad_pct = rad_pct * mul
        end
        local attack_count = self:GetSpecialValueFor("attacks")
        target:AddNewModifier(self:GetCaster(), self, "modifier_aghsfort_venomancer_ward_nova", {rad_pct = rad_pct, dur_pct = dur_pct, attack_count = attack_count})
    end
end

modifier_aghsfort_venomancer_legend_ward_nova=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_venomancer_legend_ward_nova", "abilities/heroes/venomancer/legends",LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_venomancer_ward_nova={}

LinkLuaModifier("modifier_aghsfort_venomancer_ward_nova", "abilities/heroes/venomancer/legends",LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_venomancer_ward_nova:OnCreated(kv)
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    if IsServer() then
        self.rad_pct = kv.rad_pct
        self.dur_pct = kv.dur_pct
        self.attack_count = kv.attack_count
        self.attacks = 0
    end
end

function modifier_aghsfort_venomancer_ward_nova:OnRemoved()
    if IsServer() then
        if IsValid(self.parent) and IsValid(self.ability.nova) then            
            self.ability.nova:doAction({
                pos = self.parent:GetAbsOrigin(),
                rad_pct = self.rad_pct,
                dur_pct = self.dur_pct
            })
        end
    end
end

function modifier_aghsfort_venomancer_ward_nova:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_FINISHED
    }
end

function modifier_aghsfort_venomancer_ward_nova:OnAttackFinished(event)
    if IsServer() then
        if IsValid(event.attacker) and event.attacker == self.parent and not event.no_attack_cooldown then
            self.attacks = self.attacks + 1
            if self.attacks == self.attack_count then
                if IsValid(self.parent) and IsValid(self.ability.nova) then            
                    self.ability.nova:doAction({
                        pos = self.parent:GetAbsOrigin(),
                        rad_pct = self.rad_pct,
                        dur_pct = self.dur_pct
                    })
                end
            end
		end
	end
end

-- 
aghsfort_venomancer_legend_ward_yugo = class(ability_legend_base)

function aghsfort_venomancer_legend_ward_yugo:OnUpgrade()
    local caster = self:GetCaster()
    local ability = caster:FindAbilityByName("aghsfort2_venomancer_chimera_botany")
    if ability ~= nil then
        print("grant abilitiy chimera!")
        ability:SetHidden(false)
    end
end

modifier_aghsfort_venomancer_legend_ward_yugo=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_venomancer_legend_ward_yugo", "abilities/heroes/venomancer/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_venomancer_legend_ward_move = class(ability_legend_base)

function aghsfort_venomancer_legend_ward_move:Init()
    local caster = self:GetCaster()
    self.ward = caster:FindAbilityByName("aghsfort2_venomancer_plague_ward")
    if IsValid(self.ward) then
        print("found ability ward")
        self.ward.shard_move = self
    end
    self.chimera = caster:FindAbilityByName("aghsfort2_venomancer_chimera_botany")
    if IsValid(self.chimera) then
        print("found ability chimera")
        self.chimera.shard_move = self
    end
end

function aghsfort_venomancer_legend_ward_move:doAction(kv)
    local target = kv.target
    if IsValid(target) then
        target:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
        target:SetBaseMoveSpeed(100)
        target:AddNewModifier(self:GetCaster(), self, "modifier_aghsfort_venomancer_ward_move", {})
    end
end

modifier_aghsfort_venomancer_legend_ward_move=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_venomancer_legend_ward_move", "abilities/heroes/venomancer/legends",LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_venomancer_ward_move={}

LinkLuaModifier("modifier_aghsfort_venomancer_ward_move", "abilities/heroes/venomancer/legends",LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_venomancer_ward_move:OnCreated(kv)
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self:SetHasCustomTransmitterData(true)
    self:updateData(kv)
end

function modifier_aghsfort_venomancer_ward_move:AddCustomTransmitterData()
    return {
        atk_bonus = self.atk_bonus
    }
end

function modifier_aghsfort_venomancer_ward_move:HandleCustomTransmitterData(data)
    self.atk_bonus = data.atk_bonus
end

function modifier_aghsfort_venomancer_ward_move:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
    }
end

function modifier_aghsfort_venomancer_ward_move:GetModifierPreAttack_BonusDamage()
    return self.atk_bonus
end

function modifier_aghsfort_venomancer_ward_move:GetModifierMoveSpeedBonus_Constant()
    return self.ms_bonus
end

function modifier_aghsfort_venomancer_ward_move:updateData(kv)
    self.ms_bonus = self.ability:GetSpecialValueFor("speed_bonus")
    if IsServer() then
        self.atk_bonus = self.ability:GetSpecialValueFor("atk_mul") * self.caster:GetAverageTrueAttackDamage(nil)
        self:SendBuffRefreshToClients()
    end
end
-- 
aghsfort_venomancer_legend_nova_heal = class(ability_legend_base)

function aghsfort_venomancer_legend_nova_heal:Init()
    local caster = self:GetCaster()
    self.nova = caster:FindAbilityByName("aghsfort2_venomancer_poison_nova")
    if IsValid(self.nova) then
        print("found ability nova")
        self.nova.shard_heal = self
    end
end

modifier_aghsfort_venomancer_legend_nova_heal=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_venomancer_legend_nova_heal", "abilities/heroes/venomancer/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_venomancer_legend_nova_worse = class(ability_legend_base)

function aghsfort_venomancer_legend_nova_worse:Init()
    local caster = self:GetCaster()
    self.nova = caster:FindAbilityByName("aghsfort2_venomancer_poison_nova")
    if IsValid(self.nova) then
        print("found ability nova")
        self.nova.shard_worse = self
    end
end

modifier_aghsfort_venomancer_legend_nova_worse=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_venomancer_legend_nova_worse", "abilities/heroes/venomancer/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_venomancer_legend_nova_all = class(ability_legend_base)

function aghsfort_venomancer_legend_nova_all:Init()
    local caster = self:GetCaster()
    self.nova = caster:FindAbilityByName("aghsfort2_venomancer_poison_nova")
    if IsValid(self.nova) then
        print("found ability nova")
        self.nova.shard_all = self
    end
end

modifier_aghsfort_venomancer_legend_nova_all=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_venomancer_legend_nova_all", "abilities/heroes/venomancer/legends",LUA_MODIFIER_MOTION_NONE)
-- 
