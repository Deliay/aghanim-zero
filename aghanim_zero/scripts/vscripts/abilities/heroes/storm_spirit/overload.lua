aghsfort_storm_spirit_overload = {}

LinkLuaModifier("modifier_aghsfort_storm_spirit_overload", "abilities/heroes/storm_spirit/overload",
    LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghsfort_storm_spirit_overload_buff", "abilities/heroes/storm_spirit/overload",
    LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghsfort_storm_spirit_overload_debuff", "abilities/heroes/storm_spirit/overload",
    LUA_MODIFIER_MOTION_NONE)

function aghsfort_storm_spirit_overload:GetIntrinsicModifierName()
    return "modifier_aghsfort_storm_spirit_overload"
end

function aghsfort_storm_spirit_overload:Init()
    self.ability_whitelist = {
        ["aghsfort_storm_spirit_static_remnant"] = true,
        ["aghsfort_storm_spirit_electric_vortex"] = true,
        ["aghsfort_storm_spirit_ball_lightning"] = true
    }
    self.caster = self:GetCaster()
end

function aghsfort_storm_spirit_overload:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    local attacker = EntIndexToHScript(ExtraData.attacker_id)
	if IsValid(hTarget) and IsValid(attacker) then
        local damage = ExtraData.damage
		hTarget:EmitSound("Hero_StormSpirit.ProjectileImpact")

        self:doAction({
            attacker = attacker,
            pos = vLocation,
            bAttack = true,
        })

		local bounce = ExtraData.bounces - 1
		if bounce > 0 then
            local next_target = hTarget
            self:bounceAttack({
                attacker = attacker,
                source = next_target,
                damage = damage,
                bounces = bounce
            })
		end

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

function aghsfort_storm_spirit_overload:doAction(kv)
    if self:GetLevel() > 0 then
        local attacker = kv.attacker
        local pos = kv.pos
        local bAttack = kv.bAttack
        
        local caster = self:GetCaster()
        local damage_base = self:GetSpecialValueFor("overload_damage")
        local damage_mana = attacker:GetMaxMana() * self:GetSpecialValueFor("mana_damage") * 0.01
        local aoe = self:GetSpecialValueFor("overload_aoe")
        local duration = self:GetSpecialValueFor("duration")
        
        self:playEffects({
            pos = pos,
            radius = aoe
        })
        
        local damage_table = {
            victim = nil,
            attacker = attacker,
            damage = damage_base + damage_mana,
            damage_type = self:GetAbilityDamageType(),
            ability = self,
            damage_category = DOTA_DAMAGE_CATEGORY_SPELL
        }
        local enemies = FindUnitsInRadius(attacker:GetTeam(), pos, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
        
        for _, enemy in pairs(enemies) do
            damage_table.victim = enemy
            ApplyDamage(damage_table)
            enemy:AddNewModifier(caster, self, "modifier_aghsfort_storm_spirit_overload_debuff", {
                duration = duration
            })
        end

        if IsValid(self.shard_mana) then
            print("restoring mana")
            local mana_gain = damage_mana * self.shard_mana:GetSpecialValueFor("effect_mul")
            attacker:GiveMana(mana_gain)
        end

        if IsValid(self.shard_remnant) then
            print("shard remnants!")
            if bAttack then
                self.shard_remnant:doAction({
                    caster = caster,
                    pos = pos,
                })
            end
        end
    end

end
function aghsfort_storm_spirit_overload:charge(kv)
    if self:GetLevel() < 1 then
        return
    end
    local caster = self:GetCaster()
    EmitSoundOn("Hero_StormSpirit.Overload", caster)
    caster:AddNewModifier(caster, self, "modifier_aghsfort_storm_spirit_overload_buff", {duration = -1})
    if IsValid(self.shard_ally) then
        print("charging allies")
        self.shard_ally:doAction({})
    end
end

-- 弹射，但不是真的攻击
function aghsfort_storm_spirit_overload:bounceAttack(kv)
    local bounces = kv.bounces
    if bounces <= 0 then
        return
    end

    local attacker = kv.attacker
    local source = kv.source
    local damage = kv.damage

    local range = self:GetSpecialValueFor("bounce_radius")
	local target = nil
	local enemies = FindUnitsInRadius(attacker:GetTeamNumber(), source:GetAbsOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_CLOSEST, false)
	for _, enemy in pairs(enemies) do
		if enemy ~= source then
			target = enemy
			break
		end
	end
	if target == nil then
		return
	end
	local projectile_info =
	{
		Target = target,
		Source = source,
		Ability = self,
		EffectName = "particles/units/heroes/hero_stormspirit/stormspirit_base_attack.vpcf",
		iMoveSpeed = (self:GetCaster():IsRangedAttacker() and self:GetCaster():GetProjectileSpeed() or 1100),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		bDrawsOnMinimap = false,
		bDodgeable = true,
		bIsAttack = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
		bProvidesVision = false,
		ExtraData = {bounces = bounces, damage = damage, attacker_id = attacker:entindex()}
	}
	ProjectileManager:CreateTrackingProjectile(projectile_info)
end

function aghsfort_storm_spirit_overload:playEffects(kv)
    local pos = kv.pos
    local radius = kv.radius
    -- print("overload effect!")

    local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ss/stormspirit_overload_discharge.vpcf",
    PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(pfx, 0, pos)
    ParticleManager:SetParticleControl(pfx, 4, Vector(radius / 300, 0, 0))
    ParticleManager:ReleaseParticleIndex(pfx)

    EmitSoundOnLocationWithCaster(pos, "Hero_StormSpirit.StaticRemnantExplode", nil)
end

modifier_aghsfort_storm_spirit_overload = {}

function modifier_aghsfort_storm_spirit_overload:IsHidden()
    return true
end

function modifier_aghsfort_storm_spirit_overload:OnCreated(kv)
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
end

function modifier_aghsfort_storm_spirit_overload:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

function modifier_aghsfort_storm_spirit_overload:OnAbilityExecuted(event)
    if IsServer() then
        if self.parent:PassivesDisabled() or not IsValid(event.ability) or event.ability:GetName() == "" then
            return
        end
        if event.ability:GetCaster() == self.parent and self.ability.ability_whitelist[event.ability:GetName()] then
            -- print("overload charged!")
            EmitSoundOn("Hero_StormSpirit.Overload", self.parent)
            self.parent:AddNewModifier(self.caster, self.ability, "modifier_aghsfort_storm_spirit_overload_buff", {duration = -1})
            if IsValid(self.ability.shard_ally) then
                print("charging allies")
                self.ability.shard_ally:doAction({})
            end
        end
    end
end

modifier_aghsfort_storm_spirit_overload_buff = {}
function modifier_aghsfort_storm_spirit_overload_buff:IsPurgable()
    return false
end

function modifier_aghsfort_storm_spirit_overload_buff:OnCreated(kv)
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()

    if IsServer() then
        local pfx_name = "particles/units/heroes/hero_stormspirit/stormspirit_overload_ambient.vpcf"
        local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_CUSTOMORIGIN, self.parent)
        ParticleManager:SetParticleControlEnt(pfx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_attack1", self.parent:GetAbsOrigin(), true)
        self:AddParticle(pfx, false, false, 15, false, false)
    end

    self:updateData(kv)
end

function modifier_aghsfort_storm_spirit_overload_buff:OnRefresh(kv)
    self:updateData(kv)
end

function modifier_aghsfort_storm_spirit_overload_buff:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_aghsfort_storm_spirit_overload_buff:OnAttackLanded(event)
    if IsServer() and event.attacker == self.parent and IsValid(event.target) then
        -- print("attack!")
        self.ability:doAction({
            attacker = event.attacker,
            pos = event.target:GetAbsOrigin(),
            bAttack = true,
        })

        local bounces = GetTalentValue(self.caster, "storm_spirit_overload+bounce")
        if bounces > 0 then
            self.ability:bounceAttack({
            attacker = self.parent,
            source = event.target,
            damage = event.damage,
            bounces = bounces
        })
        end

        self:Destroy()
    end
end

function modifier_aghsfort_storm_spirit_overload_buff:updateData(kv)
end

modifier_aghsfort_storm_spirit_overload_debuff = {}

function modifier_aghsfort_storm_spirit_overload_debuff:IsPurgable()
    return true
end

function modifier_aghsfort_storm_spirit_overload_debuff:OnCreated(kv)
    self.ability = self:GetAbility()
    self.parent = self:GetParent()

    self:updateData(kv)
end

function modifier_aghsfort_storm_spirit_overload_debuff:OnRefresh(kv)
    self:updateData(kv)
end

function modifier_aghsfort_storm_spirit_overload_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_aghsfort_storm_spirit_overload_debuff:GetModifierMoveSpeedBonus_Percentage()
    return self.ms_slow
end

function modifier_aghsfort_storm_spirit_overload_debuff:GetModifierAttackSpeedBonus_Constant()
    return self.as_slow
end

function modifier_aghsfort_storm_spirit_overload_debuff:updateData(kv)
    self.ms_slow = self.ability:GetSpecialValueFor("overload_move_slow")
    self.as_slow = self.ability:GetSpecialValueFor("overload_attack_slow")
end
