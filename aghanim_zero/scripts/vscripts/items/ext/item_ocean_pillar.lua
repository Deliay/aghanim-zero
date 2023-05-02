LinkLuaModifier( "modifier_item_ocean_pillar", "items/ext/item_ocean_pillar.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_ocean_pillar_chain", "items/ext/item_ocean_pillar.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_ocean_pillar == nil then
	item_ocean_pillar = class({})
end
function item_ocean_pillar:GetIntrinsicModifierName()
	return "modifier_item_ocean_pillar"
end
item_ocean_pillar_creature = item_ocean_pillar
---------------------------------------------------------------------
--Modifiers
if modifier_item_ocean_pillar == nil then
	modifier_item_ocean_pillar = class({})
end
function modifier_item_ocean_pillar:IsHidden()
	return true
end
function modifier_item_ocean_pillar:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true,
	}
end

function modifier_item_ocean_pillar:OnCreated(kv)
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	if IsServer() then
	end
	self:updateData(kv)
end
function modifier_item_ocean_pillar:OnRefresh(kv)
	if IsServer() then
	end
	self:updateData(kv)
end
function modifier_item_ocean_pillar:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_ocean_pillar:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
end

function modifier_item_ocean_pillar:OnAttackLanded(event)
    if IsServer() and not self.parent:IsIllusion() and event.attacker == self.parent and IsValid(event.target) then
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, event.target, self.magic_dmg, nil)
		if UnitFilter(event.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, self.parent:GetTeamNumber()) == UF_SUCCESS then
			if RollPseudoRandomPercentage(self.chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_9, self.parent) then
				self.parent:AddNewModifier(self.caster, self.ability, "modifier_item_ocean_pillar_chain", {target_id = event.target:entindex()})
			end
		end
	end
end

function modifier_item_ocean_pillar:GetModifierPreAttack_BonusDamage()
	return self.dmg
end
function modifier_item_ocean_pillar:GetModifierAttackSpeedBonus_Constant()
	return self.as
end
function modifier_item_ocean_pillar:GetModifierProcAttack_BonusDamage_Magical()
	return self.magic_dmg
end
function modifier_item_ocean_pillar:GetModifierAttackRangeBonus()
	if self.parent:IsRangedAttacker() then
		return 0
	end
	return self.range
end
function modifier_item_ocean_pillar:GetModifierBonusStats_Strength()
	return self.str
end

function modifier_item_ocean_pillar:updateData(kv)
	self.dmg = self.ability:GetSpecialValueFor("bonus_damage")
	self.as = self.ability:GetSpecialValueFor("bonus_attack_speed")
	self.magic_dmg = self.ability:GetSpecialValueFor("bonus_magical_damage")
	self.range = self.ability:GetSpecialValueFor("bonus_melee_range")
	self.str = self.ability:GetSpecialValueFor("bonus_strength")
	if IsServer() then
		self.chance = self.ability:GetSpecialValueFor("bash_chance")
	end
end

modifier_item_ocean_pillar_chain = {}
function modifier_item_ocean_pillar_chain:IsHidden()
	return true
end
function modifier_item_ocean_pillar_chain:IsPurgable()
	return false
end
function modifier_item_ocean_pillar_chain:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_item_ocean_pillar_chain:RemoveOnDeath()
	return false
end
function modifier_item_ocean_pillar_chain:OnCreated(kv)
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.team = self.parent:GetTeamNumber()
	if IsServer() then
		self.parent:EmitSound("Item.Maelstrom.Chain_Lightning")
		self.damage_table = {
			victim = EntIndexToHScript(kv.target_id),
			attacker = self.parent,
			damage = 0,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability,
		}
		if not IsValid(self.damage_table.victim) or not IsValid(self.ability) then
			self:Destroy()
			return
		end
		self.source = self.parent
		self.target = self.damage_table.victim
		self.target_list = {}
		table.insert(self.target_list, self.target)
	end
	self:updateData(kv)
	if IsServer() then
		self:chainStrike()
		self:StartIntervalThink(self.delay)
	end
end
function modifier_item_ocean_pillar_chain:OnIntervalThink()
	if IsServer() then
		if self:GetStackCount() < 1 or not IsValid(self.target) then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end
		local enemies = FindUnitsInRadius(self.team, self.target:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
		self.source = self.target
		self.target = nil
		for _, enemy in pairs(enemies) do
			if IsValid(enemy) and not TableContainsValue(self.target_list, enemy) then
				self.target = enemy
				break
			end
		end
		if not IsValid(self.target) then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end
		table.insert(self.target_list, self.target)
		self:chainStrike()
	end
end

function modifier_item_ocean_pillar_chain:updateData(kv)
	if IsServer() then
		self:SetStackCount(self.ability:GetSpecialValueFor("chain_strikes"))
		self.damage_table.damage = self.ability:GetSpecialValueFor("bonus_chance_damage")
		self.delay = self.ability:GetSpecialValueFor("chain_delay")
		self.radius = self.ability:GetSpecialValueFor("chain_radius")
		self.minstun = self.ability:GetSpecialValueFor("bash_ministun")
	end
end
function modifier_item_ocean_pillar_chain:chainStrike()
	-- TableContainsValue
	local pfx = ParticleManager:CreateParticle("particles/econ/events/ti10/maelstrom_ti10.vpcf", PATTACH_POINT_FOLLOW, self.source)
	ParticleManager:SetParticleControlEnt(pfx, 0, self.source, PATTACH_POINT_FOLLOW, "attach_hitloc", self.source:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(pfx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(pfx, 2, Vector(1,1,1))
	ParticleManager:ReleaseParticleIndex(pfx)
	self.damage_table.victim = self.target
	self.target:EmitSound("DOTA_Item.SkullBasher")
	self.target:EmitSound("Item.Maelstrom.Chain_Lightning.Jump")
	self.target:AddNewModifier(self.parent, self.ability, "modifier_bashed", {duration = self.minstun})
	ApplyDamage(self.damage_table)
	self:DecrementStackCount()
end
