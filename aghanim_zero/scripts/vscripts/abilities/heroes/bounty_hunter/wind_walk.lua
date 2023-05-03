LinkLuaModifier("modifier_aghsfort_bounty_hunter_wind_walk", "abilities/heroes/bounty_hunter/wind_walk.lua",
    LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghsfort_bounty_hunter_wind_walk_invis", "abilities/heroes/bounty_hunter/wind_walk.lua",
    LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghsfort_bounty_hunter_wind_walk_fade", "abilities/heroes/bounty_hunter/wind_walk.lua",
    LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_aghsfort_bounty_hunter_wind_walk_break", "abilities/heroes/bounty_hunter/wind_walk.lua",
    LUA_MODIFIER_MOTION_NONE)
-- Abilities
aghsfort_bounty_hunter_wind_walk = {}
-- 使用被动判断当前攻击的record来决定远程破隐一击的触发
function aghsfort_bounty_hunter_wind_walk:GetIntrinsicModifierName()
	return "modifier_aghsfort_bounty_hunter_wind_walk"
end
function aghsfort_bounty_hunter_wind_walk:OnSpellStart()
	self:doAction(
		{
			target = self:GetCaster(),
		}
	)
end
-- Sever Only
function aghsfort_bounty_hunter_wind_walk:doAction(kv)
    if self:GetLevel() > 0 then
        local target = kv.target
        local caster = self:GetCaster()
        EmitSoundOnLocationWithCaster(target:GetAbsOrigin(), "Hero_BountyHunter.WindWalk", target)
        target:AddNewModifier(target, self, "modifier_aghsfort_bounty_hunter_wind_walk_fade", {
            duration = self:GetSpecialValueFor("fade_time")
        })
        local pfx = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_bounty_hunter/bounty_hunter_windwalk.vpcf", PATTACH_ABSORIGIN, target)
        ParticleManager:ReleaseParticleIndex(pfx)
    end
end
---------------------------------------------------------------------
-- Modifiers
-- 负责记录破隐一击的触发，并处理破隐一击
modifier_aghsfort_bounty_hunter_wind_walk = {}

function modifier_aghsfort_bounty_hunter_wind_walk:IsHidden()
	return true
end
function modifier_aghsfort_bounty_hunter_wind_walk:RemoveOnDeath()
	return false
end
function modifier_aghsfort_bounty_hunter_wind_walk:IsPurgable()
	return false
end

function modifier_aghsfort_bounty_hunter_wind_walk:OnCreated(kv)
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.team = self.parent:GetTeamNumber()
	if IsServer() then
		self.records = {}
	end
	self:updateData(kv)
end

function modifier_aghsfort_bounty_hunter_wind_walk:OnRefresh(kv)
	self:updateData(kv)
end

function modifier_aghsfort_bounty_hunter_wind_walk:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end
function modifier_aghsfort_bounty_hunter_wind_walk:OnAttackLanded(event)
	if IsServer() then
		-- print(event.attacker:GetName())
		if self.records[event.record] then
			self:doInvisStrike(event)
			self.records[event.record] = nil
		end
	end
end

function modifier_aghsfort_bounty_hunter_wind_walk:updateData(kv)
	if IsServer() then
		self.slow_duration = self.ability:GetSpecialValueFor("slow_duration") + GetTalentValue(self:GetCaster(), "aghsfort_bounty_hunter_wind_walk+slow")
	end
end
function modifier_aghsfort_bounty_hunter_wind_walk:recordAttack(iRecord)
	self.records[iRecord] = true
end
function modifier_aghsfort_bounty_hunter_wind_walk:doInvisStrike(event)
	local filter = UnitFilter(event.target, DOTA_UNIT_TARGET_TEAM_ENEMY,
	DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
	self.team)

	if filter == UF_SUCCESS then
		AddModifierConsiderResist(event.target,self.parent, self.ability, "modifier_aghsfort_bounty_hunter_wind_walk_break", {
			duration = self.slow_duration
		})
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinda_slow.vpcf", PATTACH_ABSORIGIN_FOLLOW, event.target)
		ParticleManager:SetParticleControl(pfx, 0, event.target:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(pfx)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_DAMAGE, event.target, event.damage, nil)
		EmitSoundOn("Hero_BountyHunter.Jinada", event.target)
	end
end
modifier_aghsfort_bounty_hunter_wind_walk_invis = {}
function modifier_aghsfort_bounty_hunter_wind_walk_invis:IsPurgable()
	return false
end
function modifier_aghsfort_bounty_hunter_wind_walk_invis:GetEffectName()
	return "particles/generic_hero_status/status_invisibility_start.vpcf" 
end
function modifier_aghsfort_bounty_hunter_wind_walk_invis:GetEffectAttachType() 
	return PATTACH_ABSORIGIN 
end

function modifier_aghsfort_bounty_hunter_wind_walk_invis:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end
function modifier_aghsfort_bounty_hunter_wind_walk_invis:GetModifierInvisibilityLevel()
	return 1
end
function modifier_aghsfort_bounty_hunter_wind_walk_invis:GetDisableAutoAttack()
	return 1
end
-- 
function modifier_aghsfort_bounty_hunter_wind_walk_invis:OnCreated(kv)
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.team = self.parent:GetTeamNumber()
    if IsServer() then
		self.break_attack_mod = self.ability:GetCaster():FindModifierByName(self.ability:GetIntrinsicModifierName())
		if IsValid(self.ability.shard_pickup) then
			self.ability.shard_pickup:doAction({
				target = self.parent
			})
		end
		if IsValid(self.ability.shard_track) then
			self.ability.shard_track:doAction({
				target = self.parent
			})
		end
		self.break_exceptions = {
			["aghsfort_bounty_hunter_track"] = true,
			["item_greater_clarity"] = true,
			["item_health_potion"] = true,
			["item_mana_potion"] = true,
			["item_bag_of_gold"] = true,
			["item_bag_of_gold2"] = true,
			["item_battle_points"] = true,
			["item_arcane_fragments"] = true,
			["item_quest_star"] = true,
		}
    end
	self:updateData(kv)
end
function modifier_aghsfort_bounty_hunter_wind_walk_invis:OnRefresh(kv)
    if IsServer() then
    end
	self:updateData(kv)
end

function modifier_aghsfort_bounty_hunter_wind_walk_invis:OnDestroy()
    if IsServer() then
		if IsValid(self.ability.shard_pickup) then
			self.ability.shard_pickup:stopAction({
				target = self.parent
			})
		end
		if IsValid(self.ability.shard_track) then
			self.ability.shard_track:stopAction({
				target = self.parent
			})
		end
		if IsValid(self.ability.shard_windy) then
			self.ability.shard_windy:doAction({
				target = self.parent
			})
		end
    end
end
function modifier_aghsfort_bounty_hunter_wind_walk_invis:DeclareFunctions()
    return {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_PROPERTY_DISABLE_AUTOATTACK,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end
-- 远程：攻击即破隐，此次攻击触发破隐一击
function modifier_aghsfort_bounty_hunter_wind_walk_invis:OnAttack(event)
	if IsServer() then
		-- event.ranged_attack不对
		if event.attacker == self.parent and self.parent:IsRangedAttacker() then
			if IsValid(self.break_attack_mod) then
				self.break_attack_mod:recordAttack(event.record)
			end
			self:Destroy()
		end
	end
end
-- 近战：攻击命中才会破隐
-- 注意，多个modifier的同一事件存在优先级，不设定无法保证顺序
function modifier_aghsfort_bounty_hunter_wind_walk_invis:OnAttackLanded(event)
	if IsServer() then
		if event.attacker == self.parent and not self.parent:IsRangedAttacker() then
			if IsValid(self.break_attack_mod) then
				self.break_attack_mod:doInvisStrike(event)
				-- print("done!")
			end
			self:Destroy()
		end
	end
end
function modifier_aghsfort_bounty_hunter_wind_walk_invis:OnAbilityExecuted(event)
	if IsServer() then
        if not IsValid(event.ability) or event.ability:GetName() == "" then
            return
        end
		if event.ability:GetCaster() == self.parent then
			if not self.break_exceptions[event.ability:GetName()] then
				self:Destroy()
			end
		end
	end
end
function modifier_aghsfort_bounty_hunter_wind_walk_invis:GetModifierIncomingDamage_Percentage(event)
	if IsValid(self.ability.shard_windy) then
		return -self.ability.shard_windy:GetSpecialValueFor("damage_reduction")
	end
	return 0
end
function modifier_aghsfort_bounty_hunter_wind_walk_invis:updateData(kv)
	if IsServer() then
	end
end
-- 
modifier_aghsfort_bounty_hunter_wind_walk_fade = {}
function modifier_aghsfort_bounty_hunter_wind_walk_fade:IsHidden()
	return true
end
function modifier_aghsfort_bounty_hunter_wind_walk_fade:IsPurgable()
	return false
end
function modifier_aghsfort_bounty_hunter_wind_walk_fade:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}
end
function modifier_aghsfort_bounty_hunter_wind_walk_fade:OnCreated(kv)
	if IsServer() then
		self.ability = self:GetAbility()
	end
	self:updateData(kv)
end
function modifier_aghsfort_bounty_hunter_wind_walk_fade:OnRefresh(kv)
	self:updateData(kv)
end
function modifier_aghsfort_bounty_hunter_wind_walk_fade:updateData(kv)
	if IsServer() then
		self.invis_duration = self.ability:GetSpecialValueFor("duration")
	end
end
function modifier_aghsfort_bounty_hunter_wind_walk_fade:OnRemoved()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_aghsfort_bounty_hunter_wind_walk_invis", {
			duration = self.invis_duration
		})
	end
end

modifier_aghsfort_bounty_hunter_wind_walk_break = {}
function modifier_aghsfort_bounty_hunter_wind_walk_break:IsPurgable()
	return true
end
function modifier_aghsfort_bounty_hunter_wind_walk_break:GetStatusEffectName()
	return "particles/units/heroes/hero_bounty_hunter/status_effect_bounty_hunter_jinda_slow.vpcf"
end
function modifier_aghsfort_bounty_hunter_wind_walk_break:OnCreated(kv)
	self.parent = self:GetParent()
	self:updateData(kv)
end
function modifier_aghsfort_bounty_hunter_wind_walk_break:OnRefresh(kv)
	self:updateData(kv)
end
function modifier_aghsfort_bounty_hunter_wind_walk_break:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end
function modifier_aghsfort_bounty_hunter_wind_walk_break:GetModifierMoveSpeedBonus_Percentage()
	return -self.ms_slow
end
function modifier_aghsfort_bounty_hunter_wind_walk_break:GetModifierPhysicalArmorBonus()
	return -self.armor
end

function modifier_aghsfort_bounty_hunter_wind_walk_break:updateData(kv)
	self.ability = self:GetAbility()
	self.ms_slow = self.ability:GetSpecialValueFor("slow")
	self.armor = self.ability:GetSpecialValueFor("armor_reduction")
end
