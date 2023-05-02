LinkLuaModifier( "modifier_item_chrysanthemail", "items/ext/item_chrysanthemail.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_chrysanthemail_reflect", "items/ext/item_chrysanthemail.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_chrysanthemail == nil then
	item_chrysanthemail = class({})
end

function item_chrysanthemail:GetIntrinsicModifierName()
	return "modifier_item_chrysanthemail"
end

function item_chrysanthemail:OnSpellStart()
	local caster = self:GetCaster()
	local team = caster:GetTeamNumber()

	local radius = self:GetSpecialValueFor("bonus_aoe_radius")
	local duration = self:GetSpecialValueFor("duration")
	local duration_nostack = self:GetSpecialValueFor("tooltip_reapply_time")

	local allies = FindUnitsInRadius(team, caster:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)

	self:setExceptions()
	caster:EmitSound("Item.CrimsonGuard.Cast")

	for _, ally in pairs(allies) do
		if IsValid(ally) and IsValidEntity(ally) then
			ally:Purge(false, true, false, false, false)
			ally:AddNewModifier(caster, self, "modifier_item_crimson_guard_extra", {duration = duration})
			if self.unit_exception[ally:GetUnitName()] then
			else
				-- 是刃甲的被动检测到这个modifier的时候增加了弹射，这个modifier并不能提供弹射
				ally:AddNewModifier(caster, self, "modifier_item_blade_mail_reflect", {duration = duration})
				ally:AddNewModifier(caster, self, "modifier_item_blade_mail", {duration = duration})
				ally:AddNewModifier(caster, self, "modifier_item_lotus_orb_active", {duration = duration})
				ally:EmitSound("DOTA_Item.BladeMail.Activate")
				ally:EmitSound("Item.LotusOrb.Target")
			end
		end
	end
end

function item_chrysanthemail:setExceptions()
	if self.unit_exception == nil then
		self.unit_exception = {
			["npc_dota_rylai_ice_golem"] = true,
			["npc_dota_venomancer_plague_ward_1_aghs2"] = true,
			["npc_aghsfort_juggernaut_healing_ward"] = true,
			["npc_aghsfort_juggernaut_blade_fury_npc"] = true,
			["npc_aghsfort_unit_undying_soul_rip_ward"] = true,
			["npc_aghsfort_unit_undying_zombie_torso"] = true,
			["npc_aghsfort_unit_undying_zombie"] = true,
			["npc_dota_earthshaker_aghs2_minion"] = true,
			["aghsfort_mars_bulwark_soldier"] = true,
			["aghsfort_ursa_minor"] = true,
			["npc_dota_warlock_golem_1_aghs2"] = true,
			["npc_dota_warlock_golem_2_aghs2"] = true,
			["npc_dota_warlock_golem_3_aghs2"] = true,
		}
	end
end
item_chrysanthemail_creature = item_chrysanthemail
---------------------------------------------------------------------
--Modifiers
if modifier_item_chrysanthemail == nil then
	modifier_item_chrysanthemail = class({})
end
function modifier_item_chrysanthemail:IsHidden()
	return true
end

function modifier_item_chrysanthemail:OnCreated(kv)
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	if IsServer() then
	end
	self:updateData(kv)
end
function modifier_item_chrysanthemail:OnRefresh(kv)
	if IsServer() then
	end
	self:updateData(kv)
end
function modifier_item_chrysanthemail:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_chrysanthemail:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK_UNAVOIDABLE_PRE_ARMOR,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
function modifier_item_chrysanthemail:GetModifierPhysical_ConstantBlockUnavoidablePreArmor(event)
	if IsServer() then
		local block = self.block_melee
		if self.parent:IsRangedAttacker() then
			block = self.block_range
		end
		if RollPseudoRandomPercentage(self.block_chance,DOTA_PSEUDO_RANDOM_CUSTOM_GAME_7, self.parent) == true then
			return block
		end
	end
	return 0
end

function modifier_item_chrysanthemail:OnTakeDamage(event)
	if IsServer() then
		if IsServer() then
			-- print(event.unit:GetUnitName())
			-- print("take damage:"..event.damage)
			if event.unit == self.parent and IsValid(event.attacker) and IsValidEntity(event.attacker) and IsEnemy(self.parent, event.attacker) and not event.attacker:IsMagicImmune() and not self.parent:HasModifier("modifier_item_blade_mail_reflect") then
				local damage_table = {
					victim = event.attacker,
					attacker = self.parent,
					ability = self.ability,
					damage = event.original_damage * self.passive_reflect + self.reflect_constant,
					damage_type = event.damage_type,
					damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL+DOTA_DAMAGE_FLAG_REFLECTION+DOTA_DAMAGE_FLAG_HPLOSS
				}
				ApplyDamage(damage_table)
			end
		end
	end
end

function modifier_item_chrysanthemail:GetModifierPreAttack_BonusDamage()
	return self.dmg
end
function modifier_item_chrysanthemail:GetModifierHealthBonus()
	return self.hp
end
function modifier_item_chrysanthemail:GetModifierManaBonus()
	return self.mp
end
function modifier_item_chrysanthemail:GetModifierConstantHealthRegen()
	return self.hp_regen
end
function modifier_item_chrysanthemail:GetModifierConstantManaRegen()
	return self.mp_regen
end
function modifier_item_chrysanthemail:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_chrysanthemail:updateData(kv)
	self.hp = self.ability:GetSpecialValueFor("bonus_health")
	self.hp_regen = self.ability:GetSpecialValueFor("bonus_health_regen")
	self.mp = self.ability:GetSpecialValueFor("bonus_mana")
	self.mp_regen = self.ability:GetSpecialValueFor("bonus_mana_regen")
	self.armor = self.ability:GetSpecialValueFor("bonus_armor")
	self.dmg = self.ability:GetSpecialValueFor("bonus_damage")
	if IsServer() then
		self.block_melee = self.ability:GetSpecialValueFor("block_damage_melee")
		self.block_range = self.ability:GetSpecialValueFor("block_damage_ranged")
		self.block_chance = self.ability:GetSpecialValueFor("block_chance")
		self.passive_reflect = self.ability:GetSpecialValueFor("passive_reflection_pct") * 0.01
		self.reflect_constant = self.ability:GetSpecialValueFor("passive_reflection_constant")
	end
end
