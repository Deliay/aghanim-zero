LinkLuaModifier("modifier_aghsfort_bounty_hunter_track", "abilities/heroes/bounty_hunter/track.lua",
    LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghsfort_bounty_hunter_track_buff", "abilities/heroes/bounty_hunter/track.lua",
    LUA_MODIFIER_MOTION_NONE)
-- Abilities
if aghsfort_bounty_hunter_track == nil then
    aghsfort_bounty_hunter_track = class({})
end

function aghsfort_bounty_hunter_track:Init()
	self.toss_crit_white_list = {
		["aghsfort_bounty_hunter_shuriken_toss"] = true,
		["aghsfort_bounty_hunter_jinada"] = true,
	}
end

function aghsfort_bounty_hunter_track:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    if IsValid(target) then

        self:doAction({
            caster = caster,
            target = target,
			bEffect = true
        })
    end
end
-- Server Only
function aghsfort_bounty_hunter_track:doAction(kv)
	if self:GetLevel() > 0 then
		local caster = kv.caster
		local target = kv.target
		local bEffect = kv.bEffect
		if bEffect then
			self:playEffect(kv)
		end
		target:AddNewModifier(caster, self, "modifier_aghsfort_bounty_hunter_track", {
			duration = self:GetSpecialValueFor("duration")
		})
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_BountyHunter.Target", caster)
	end
end

function aghsfort_bounty_hunter_track:playEffect(kv)
	local caster = kv.caster
    local target = kv.target
	local pfx = ParticleManager:CreateParticle(
		"particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_cast.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT, "attach_attack2", caster:GetAbsOrigin(),
		true)
	ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc",
		target:GetAbsOrigin(), true)
	Timers:CreateTimer(3, function()
		ParticleManager:DestroyParticle(pfx, true)
		ParticleManager:ReleaseParticleIndex(pfx)
		return nil
	end)
end
---------------------------------------------------------------------
-- Modifiers
if modifier_aghsfort_bounty_hunter_track == nil then
    modifier_aghsfort_bounty_hunter_track = class({})
end
function modifier_aghsfort_bounty_hunter_track:IsPurgable()
    return true
end
-- function modifier_aghsfort_bounty_hunter_track:RemoveOnDeath()
-- 	return true
-- end
function modifier_aghsfort_bounty_hunter_track:IsAura()
    return true
end
function modifier_aghsfort_bounty_hunter_track:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_aghsfort_bounty_hunter_track:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_aghsfort_bounty_hunter_track:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_aghsfort_bounty_hunter_track:GetAuraRadius()
	return self.bounty_radius
end
function modifier_aghsfort_bounty_hunter_track:GetAuraEntityReject(hEntity)
	if hEntity ~= self.caster then
		return not self.is_buff_ally
	end
	return false
end
function modifier_aghsfort_bounty_hunter_track:GetModifierAura()
    return "modifier_aghsfort_bounty_hunter_track_buff"
end
function modifier_aghsfort_bounty_hunter_track:GetAuraRadius()
	return self.bounty_radius
end
function modifier_aghsfort_bounty_hunter_track:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = self.invis
	}
end
function modifier_aghsfort_bounty_hunter_track:OnCreated(kv)
	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	self.parent = self:GetParent()
	self.team = self.caster:GetTeamNumber()
	self.invis = false
	self:updateData(kv)
    if IsServer() then
        self:playEffects()
		self:StartIntervalThink(0.1)
    end
end
function modifier_aghsfort_bounty_hunter_track:OnRefresh(kv)
    if IsServer() then
    end
	self:updateData(kv)
end
function modifier_aghsfort_bounty_hunter_track:OnDestroy()
    if IsServer() then
		if IsValid(self.ability.shard_pass) and IsValid(self.parent) then			
			local enemies = FindUnitsInRadius(self.team, self.parent:GetAbsOrigin(), nil, self.bounty_radius,
			self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(), self.ability:GetAbilityTargetFlags(),
			FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				if enemy ~= self.parent and enemy:IsAlive() and not enemy:HasModifier("modifier_aghsfort_bounty_hunter_track") then
					self.ability:doAction{
						caster = self.caster,
						target = enemy,
						bEffect = true
					}
					break
				end
			end
		end
    end
end
function modifier_aghsfort_bounty_hunter_track:OnIntervalThink()
	if IsServer() then
		if self.vision_range > 0 then
			AddFOWViewer(self.team, self.parent:GetAbsOrigin(), self.vision_range, 0.15, true)
		end
		if self.parent:HasModifier("modifier_slark_shadow_dance") then
			self.invis = true
		else
			self.invis = false
		end
	end
end
function modifier_aghsfort_bounty_hunter_track:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
		MODIFIER_EVENT_ON_DEATH,
		-- not trigger when killing aghanim creatures
		-- MODIFIER_EVENT_ON_HERO_KILLED
	}
end
function modifier_aghsfort_bounty_hunter_track:GetModifierProvidesFOWVision()
	return 1
end
-- function modifier_aghsfort_bounty_hunter_track:OnHeroKilled(event)
-- 	if IsServer() then
-- 		print("hero:"..event.target:GetName())
-- 	end
-- end
function modifier_aghsfort_bounty_hunter_track:OnDeath(event)
	if IsServer() then
		-- print("unit:"..event.unit:GetName())
		if event.unit == self.parent then
			if IsAghanimConsideredHero(self.parent) then
				local allies = FindUnitsInRadius(self.team, self.parent:GetAbsOrigin(), nil, self.bounty_radius,
				DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO,
				FIND_ANY_ORDER, false)
				for _, ally in pairs(allies) do
					if ally ~= self.caster then
						ally:ModifyGold(self.bonus_gold, true, DOTA_ModifyGold_AbilityGold)
						SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, ally, self.bonus_gold, nil)
						-- EmitSoundOn("General.Coins", ally)
					end
				end
				self.caster:ModifyGold(self.bonus_gold_self, true, DOTA_ModifyGold_AbilityGold)
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, self.caster, self.bonus_gold_self, nil)
				-- EmitSoundOn("General.Coins", self.caster)
			end
			self:Destroy()
		end
	end
end
function modifier_aghsfort_bounty_hunter_track:updateData(kv)
    if IsServer() then
		self.bonus_gold_self = self.ability:GetSpecialValueFor("bonus_gold_self") + GetTalentValue(self.caster, "aghsfort_bounty_hunter_track+gold")
		self.bonus_gold = self.ability:GetSpecialValueFor("bonus_gold") + GetTalentValue(self.caster, "aghsfort_bounty_hunter_track+gold")
		if self.parent:IsBossCreature() then
			self.bonus_gold = self.bonus_gold * self.ability:GetSpecialValueFor("boss_mul")
			self.bonus_gold_self = self.bonus_gold_self * self.ability:GetSpecialValueFor("boss_mul")
		end
		self.vision_range = GetTalentValue(self.caster, "aghsfort_bounty_hunter_track+vison")
    end
	self.is_buff_ally = GetTalentValue(self.caster,"aghsfort_bounty_hunter_track+ally") > 0 or IsValid(self.ability.shard_ally)
	self.bounty_radius = self.ability:GetSpecialValueFor("bonus_gold_radius")
end
-- ServerOnly
function modifier_aghsfort_bounty_hunter_track:playEffects(kv)
    local pfx_name1 = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_trail.vpcf"
    local pfx_name2 = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield.vpcf"

    local pfx1 = ParticleManager:CreateParticleForTeam(pfx_name1, PATTACH_POINT_FOLLOW, self.parent, self.team)
    ParticleManager:SetParticleControlEnt(pfx1, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc",
        self.parent:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(pfx1, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc",
        self.parent:GetAbsOrigin(), true)
    local pfx2 = ParticleManager:CreateParticleForTeam(pfx_name2, PATTACH_OVERHEAD_FOLLOW, self.parent, self.team)
    self:AddParticle(pfx1, false, false, 15, false, false)
    self:AddParticle(pfx2, false, false, 15, false, false)
end

modifier_aghsfort_bounty_hunter_track_buff = {}

function modifier_aghsfort_bounty_hunter_track_buff:IsPurgable()
	return false
end
function modifier_aghsfort_bounty_hunter_track_buff:GetEffectName()
	return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_haste.vpcf"
end

function modifier_aghsfort_bounty_hunter_track_buff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_aghsfort_bounty_hunter_track_buff:OnCreated(kv)
	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	self.parent = self:GetParent()
	self.team = self.caster:GetTeamNumber()
	if IsServer() then
		self:playEffects()
		if IsValid(self.ability.shard_invis) then
			print("track invis on!")
			self.ability.shard_invis:doAction({
				target = self.parent
			})
		end
	end
	self:updateData(kv)
end
function modifier_aghsfort_bounty_hunter_track_buff:OnRefresh(kv)
	if IsServer() then
		
	end
	self:updateData(kv)
end
function modifier_aghsfort_bounty_hunter_track_buff:OnRemoved()
	if IsServer() then
		if IsValid(self.ability.shard_invis) then
			self.ability.shard_invis:stopAction({
				target = self.parent
			})
		end
	end
end

function modifier_aghsfort_bounty_hunter_track_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_aghsfort_bounty_hunter_track_buff:GetModifierMoveSpeedBonus_Percentage()
	if self.parent == self.caster then
		return self.ms_bonus
	end
	return self.ms_bonus_ally
end

function modifier_aghsfort_bounty_hunter_track_buff:GetModifierPreAttack_CriticalStrike(event)
	if IsServer() and event.attacker == self.parent then
		if self.parent ~= self.caster then
			return self.crit_ally
		end
		if event.target:HasModifier("modifier_aghsfort_bounty_hunter_track") then
			return self.crit
		end
	end
	return 0
end

function modifier_aghsfort_bounty_hunter_track_buff:GetModifierTotalDamageOutgoing_Percentage(event)
	if IsServer() and event.attacker == self.parent then
		-- print("!")
		if event.target:HasModifier("modifier_aghsfort_bounty_hunter_track") then
			if event.damage_category == DOTA_DAMAGE_CATEGORY_SPELL and event.inflictor ~= nil and self.ability.toss_crit_white_list[event.inflictor:GetName()] then
				print("critcal toss!"..event.original_damage)
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, event.target, event.original_damage * (1 + self.crit_toss * 0.01), nil)
				return self.crit_toss
			end
		end
	end
	return 0
end

function modifier_aghsfort_bounty_hunter_track_buff:updateData(kv)
	self.ms_bonus = self.ability:GetSpecialValueFor("bonus_move_speed_pct")
	self.ms_bonus_ally = self.ms_bonus * GetTalentValue(self.caster, "aghsfort_bounty_hunter_track+ally")
	if IsServer() then
		self.crit = self.ability:GetSpecialValueFor("target_crit_multiplier")
		self.crit_toss = self.ability:GetSpecialValueFor("toss_crit_multiplier") - 100

		self.crit_ally = 0
		if IsValid(self.ability.shard_ally) then
			self.crit_ally = 100 + (self.crit - 100) * self.ability.shard_ally:GetSpecialValueFor("effect_mul")
		end
	end
end

function modifier_aghsfort_bounty_hunter_track_buff:playEffects(kv)
	-- print("play!")
	-- local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_haste.vpcf", PATTACH_WORLDORIGIN, self.parent)
	-- local origin = self.parent:GetAbsOrigin()
	-- ParticleManager:SetParticleControl(pfx, 0, origin)
	-- ParticleManager:SetParticleControl(pfx, 1, origin)
	-- ParticleManager:SetParticleControl(pfx, 2, origin)
	-- self:AddParticle(pfx, false, false, 20, false, false)
end
