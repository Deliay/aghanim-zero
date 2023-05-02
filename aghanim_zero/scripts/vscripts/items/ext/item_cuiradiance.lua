LinkLuaModifier( "modifier_item_cuiradiance", "items/ext/item_cuiradiance.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_cuiradiance_active", "items/ext/item_cuiradiance.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_cuiradiance_debuff", "items/ext/item_cuiradiance.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_cuiradiance_buff", "items/ext/item_cuiradiance.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
item_cuiradiance = class({})
function item_cuiradiance:Precache( context )
	PrecacheResource( "particle", "particles/econ/events/ti10/radiance_owner_ti10.vpcf", context )
	PrecacheResource( "particle", "particles/econ/events/ti10/radiance_ti10.vpcf", context )
end
function item_cuiradiance:GetIntrinsicModifierName()
	return "modifier_item_cuiradiance"
end
function item_cuiradiance:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasModifier("modifier_item_cuiradiance_active") then
		return self:GetSpecialValueFor("active_radius")
	end
	return self:GetSpecialValueFor("aura_radius")
end
function item_cuiradiance:GetAbilityTextureName()
	if self:GetCaster():HasModifier("modifier_item_cuiradiance_active") then
		return	"item_thermail_active"
	end
	return "item_thermail_inactive"
end
function item_cuiradiance:Spawn()
	self.bOn = true
end
function item_cuiradiance:OnOwnerSpawned()
	-- if not self:IsInBackpack() then
	-- 	self:init()
	-- end
end
function item_cuiradiance:OnEquip()
	-- self:init()
end
function item_cuiradiance:init()
	local caster = self:GetCaster()
	if self.bOn then
		caster:AddNewModifier(caster, self, "modifier_item_cuiradiance_active", {})
	else
		caster:RemoveModifierByName("modifier_item_cuiradiance_active")		
	end
end
function item_cuiradiance:OnUnequip()
	local caster = self:GetCaster()
	if IsValid(caster) then
		caster:RemoveModifierByName("modifier_item_cuiradiance_active")
	end
end
function item_cuiradiance:OnToggle()
	local caster = self:GetCaster()
	self.bOn = not self.bOn
	if self.bOn then
		caster:AddNewModifier(caster, self, "modifier_item_cuiradiance_active", {})
	else
		caster:RemoveModifierByName("modifier_item_cuiradiance_active")		
	end
end
---------------------------------------------------------------------
--Modifiers
modifier_item_cuiradiance = class({})
function modifier_item_cuiradiance:IsHidden()
	return true
end
function modifier_item_cuiradiance:GetTexture()
	return "item_thermail_active"
end
function modifier_item_cuiradiance:IsAura()
	return true
end
function modifier_item_cuiradiance:GetModifierAura()
	return "modifier_item_cuiradiance_buff"
end
function modifier_item_cuiradiance:IsAuraActiveOnDeath()
	return false
end
function modifier_item_cuiradiance:GetAuraRadius()
	return self.radius
end
function modifier_item_cuiradiance:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end
function modifier_item_cuiradiance:GetAuraSearchType()
	return DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_item_cuiradiance:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end
function modifier_item_cuiradiance:OnCreated(kv)
	self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.evasion = self:GetAbility():GetSpecialValueFor("evasion")
	self.armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.as = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	self.vision = self:GetAbility():GetSpecialValueFor("upgrade_day_vision")
	self.radius = self:GetAbility():GetSpecialValueFor("aura_radius")
	if IsServer() then
		if not self:GetParent():IsIllusion() and self:GetAbility().init then
			self:GetAbility():init()
		end
	end
end
function modifier_item_cuiradiance:OnRefresh(kv)
	self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.evasion = self:GetAbility():GetSpecialValueFor("evasion")
	self.armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
	self.as = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
end
function modifier_item_cuiradiance:OnDestroy()
	if IsServer() then
		local parent = self:GetParent()
		if IsValid(parent) then
			parent:RemoveModifierByName("modifier_item_cuiradiance_active")		
		end
	end
end
function modifier_item_cuiradiance:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
	}
end
function modifier_item_cuiradiance:GetModifierPhysicalArmorBonus()
	return self.armor
end
function modifier_item_cuiradiance:GetModifierEvasion_Constant()
	return self.evasion
end
function modifier_item_cuiradiance:GetModifierAttackSpeedBonus_Constant()
	return self.as
end
function modifier_item_cuiradiance:GetModifierPreAttack_BonusDamage()
	return self.damage
end
function modifier_item_cuiradiance:GetBonusDayVision()
	return self.vision
end

---------------------------------------------------------------------
modifier_item_cuiradiance_active = class({})
function modifier_item_cuiradiance_active:GetEffectName()
	return "particles/econ/events/ti10/radiance_owner_ti10.vpcf"
end
function modifier_item_cuiradiance_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_item_cuiradiance_active:IsAura()
	return true
end
function modifier_item_cuiradiance_active:IsAuraActiveOnDeath()
	return false
end
function modifier_item_cuiradiance_active:GetModifierAura()
	return "modifier_item_cuiradiance_debuff"
end
function modifier_item_cuiradiance_active:GetAuraRadius()
	return self.radius
end
function modifier_item_cuiradiance_active:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end
function modifier_item_cuiradiance_active:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end
function modifier_item_cuiradiance_active:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end
function modifier_item_cuiradiance_active:OnCreated(kv)
	self.radius = self:GetAbility():GetSpecialValueFor("aura_radius")
	self:GetAbility().bOn = true
	if IsServer() then
		self.interval = self:GetAbility():GetSpecialValueFor("attack_time")
		self:StartIntervalThink(0.5)
	end
end
function modifier_item_cuiradiance_active:AllowIllusionDuplicate()
	return true
end
function modifier_item_cuiradiance_active:OnRefresh(kv)
	self.radius = self:GetAbility():GetSpecialValueFor("active_radius")
	if IsServer() then
		self.interval = self:GetAbility():GetSpecialValueFor("attack_time")
	end
end
function modifier_item_cuiradiance_active:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		if IsValid(parent) and parent:IsAlive() and not parent:IsInvisible() then
			local units = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
			if #units > 0 then
				for _, unit in pairs(units) do
					if IsAghanimConsideredHero(unit) and IsValid(parent) then
						parent:PerformAttack(unit, true, true, true, true, false, true, true)
					end
				end
				if IsValid(parent) then
					ShuffleListInPlace(units)
					for _, unit in pairs(units) do
						if IsValid(unit) then
							parent:PerformAttack(unit, true, true, true, true, false, true, true)
							break
						end
					end
				end
				self:StartIntervalThink(self.interval)
				return
			end
		end
		self:StartIntervalThink(0.5)
	end
end
function modifier_item_cuiradiance_active:OnRemoved()
	if IsClient() then
		-- if IsValid(self:GetAbility()) then
		-- 	self:GetAbility().bOn = false
		-- end
	end
end
---------------------------------------------------------------------
modifier_item_cuiradiance_debuff = class({})
function modifier_item_cuiradiance_debuff:OnCreated(kv)
	self.miss = self:GetAbility():GetSpecialValueFor("blind_pct")
	if IsServer() then
		self.pfx = ParticleManager:CreateParticle("particles/econ/events/ti10/radiance_ti10.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		local owner = self:GetAuraOwner()
		if IsValid(owner) then
			ParticleManager:SetParticleControl(self.pfx, 1, owner:GetOrigin())
		end
		self:AddParticle(self.pfx, false, false, -1, false, false)
		self.damage = self:GetAbility():GetSpecialValueFor("aura_damage")
		self:StartIntervalThink(1.0)
	end
end
function modifier_item_cuiradiance_debuff:OnRefresh(kv)
	self.miss = self:GetAbility():GetSpecialValueFor("blind_pct")
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("aura_damage")
	end
end
function modifier_item_cuiradiance_debuff:OnIntervalThink()
	if IsServer() then
		local owner = self:GetAuraOwner()
		if IsValid(owner) then
			ParticleManager:SetParticleControl(self.pfx, 1, owner:GetOrigin())
		end
		local damage_table = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(),
		}
		ApplyDamage(damage_table)
	end
end
function modifier_item_cuiradiance_debuff:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_cuiradiance_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MISS_PERCENTAGE
	}
end
function modifier_item_cuiradiance_debuff:GetModifierMiss_Percentage()
	return self.miss
end
---------------------------------------------------------------------
modifier_item_cuiradiance_buff = class({})
function modifier_item_cuiradiance_buff:GetTexture()
	return "item_thermail_active"
end
function modifier_item_cuiradiance_buff:OnCreated(kv)
	self.as = 0
	if self:IsDebuff() then
		self.armor = self:GetAbility():GetSpecialValueFor("aura_negative_armor")
	else
		self.armor = self:GetAbility():GetSpecialValueFor("aura_positive_armor")
		self.as = self:GetAbility():GetSpecialValueFor("aura_attack_speed")
	end
end
function modifier_item_cuiradiance_buff:OnRefresh(kv)
	if self:IsDebuff() and self:GetAbility() then
		self.armor = self:GetAbility():GetSpecialValueFor("aura_negative_armor")
	else
		if self:GetAbility() then
			self.armor = self:GetAbility():GetSpecialValueFor("aura_positive_armor")
			self.as = self:GetAbility():GetSpecialValueFor("aura_attack_speed")
		end
	end
end
function modifier_item_cuiradiance_buff:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_cuiradiance_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_item_cuiradiance_buff:GetModifierPhysicalArmorBonus()
	return self.armor
end
function modifier_item_cuiradiance_buff:GetModifierAttackSpeedBonus_Constant()
	return self.as
end