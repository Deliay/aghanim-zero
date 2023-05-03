LinkLuaModifier( "modifier_aghsfort2_venomancer_poison_sting_applier", "abilities/heroes/venomancer/poison_sting.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort2_venomancer_poison_sting_ward", "abilities/heroes/venomancer/poison_sting.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort2_venomancer_poison_sting", "abilities/heroes/venomancer/poison_sting.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if aghsfort2_venomancer_poison_sting == nil then
	aghsfort2_venomancer_poison_sting = class({})
end

function aghsfort2_venomancer_poison_sting:GetIntrinsicModifierName()
	return "modifier_aghsfort2_venomancer_poison_sting_applier"
end

function aghsfort2_venomancer_poison_sting:setApplier(kv)
	if self:GetLevel() > 0 then
		local target = kv.target
		if IsValid(target) then
			target:AddNewModifier(self:GetCaster(), self, "modifier_aghsfort2_venomancer_poison_sting_applier", {})
		end
	end
end

function aghsfort2_venomancer_poison_sting:doAction(kv)
	local target = kv.target
	local attacker = kv.attacker
	local bHero = attacker:IsHero() or attacker:IsCreepHero() or attacker:IsBossCreature()
	local duration = self:GetSpecialValueFor("duration")

	if UnitFilter(target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	DOTA_UNIT_TARGET_FLAG_NONE, attacker:GetTeamNumber()) ~= UF_SUCCESS then
		return
	end
	
	if bHero then
		target:AddNewModifier(attacker, self, "modifier_aghsfort2_venomancer_poison_sting", {duration = duration})
	else
		target:AddNewModifier(attacker, self, "modifier_aghsfort2_venomancer_poison_sting_ward", {duration = duration})				
	end
end
---------------------------------------------------------------------
--Modifiers
modifier_aghsfort2_venomancer_poison_sting_applier = {}

function modifier_aghsfort2_venomancer_poison_sting_applier:IsHidden()
	return true
end

function modifier_aghsfort2_venomancer_poison_sting_applier:OnCreated(kv)
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.team = self.parent:GetTeamNumber()
	if IsServer() then
		self.bHero = self.parent:IsHero() or self.parent:IsCreepHero() or self.parent:IsBossCreature()
		self.iHero = 0
		if self.parent:IsHero() then
			self.iHero = 1
		end
	end
	-- print("Is hero poisoner?")
	-- print(self.bHero)
	self:updateData(kv)
end

function modifier_aghsfort2_venomancer_poison_sting_applier:OnRefresh(kv)
	self:updateData(kv)
end

function modifier_aghsfort2_venomancer_poison_sting_applier:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_aghsfort2_venomancer_poison_sting_applier:OnAttackLanded(event)
	if IsServer() then
		if IsServer() and event.attacker == self.parent and IsValid(event.target) then
			if UnitFilter(event.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE, self.team) ~= UF_SUCCESS then
				return
			end
			if IsValid(self.ability.shard_splash) then
				self.ability.shard_splash:doAction({
					attacker = self.parent,
					iHero = self.iHero,
					target = event.target,
					damage = event.damage
				})
			end
			if self.bHero then
				event.target:AddNewModifier(self.parent, self.ability, "modifier_aghsfort2_venomancer_poison_sting", {duration = self.duration})
			else
				event.target:AddNewModifier(self.parent, self.ability, "modifier_aghsfort2_venomancer_poison_sting_ward", {duration = self.duration})				
			end
		end
	end
end

function modifier_aghsfort2_venomancer_poison_sting_applier:updateData(kv)
	if IsServer() then
		self.duration = self.ability:GetSpecialValueFor("duration")
	end
end


if modifier_aghsfort2_venomancer_poison_sting == nil then
	modifier_aghsfort2_venomancer_poison_sting = class({})
end

function modifier_aghsfort2_venomancer_poison_sting:IsPurgable()
	return self.bPurgable
end

function modifier_aghsfort2_venomancer_poison_sting:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_poison_debuff.vpcf"
end

function modifier_aghsfort2_venomancer_poison_sting:OnCreated(kv)
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.bPurgable = not IsValid(self.ability.shard_side)
	if IsServer() then
		-- 这里真的可以设为-1,而且不显示层数
		-- self:SetStackCount(-1)
		local ward_mod = self.parent:FindModifierByName("modifier_aghsfort2_venomancer_poison_sting_ward")
		if IsValid(ward_mod) then
			ward_mod:SetStackCount(-1)
		end

		self.damage_table = {
			victim = self.parent,
			attacker = self.caster,
			damage = 0,
			damage_type = self.ability:GetAbilityDamageType(),
			ability = self.ability,
		}
	end
	self:SetHasCustomTransmitterData(true)
	self:updateData(kv)
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_aghsfort2_venomancer_poison_sting:OnRefresh(kv)
	if IsServer() then
	end
	self:updateData(kv)
end

function modifier_aghsfort2_venomancer_poison_sting:OnRemoved()
	if IsServer() then
		if IsValid(self.parent) then
			
			local ward_mod = self.parent:FindModifierByName("modifier_aghsfort2_venomancer_poison_sting_ward")
			if IsValid(ward_mod) then
				ward_mod:SetStackCount(0)
			end
		end
	end
end

function modifier_aghsfort2_venomancer_poison_sting:OnIntervalThink()
	if IsServer() then
		-- print("stacks:"..self:GetStackCount())
		if IsValid(self.ability.shard_boom) and IsValid(self._mod_boom) then
			self._mod_boom:addDamage(self.damage_table.damage)
		end
		ApplyDamage(self.damage_table)
		if IsValid(self.parent) then
			SendOverheadEventMessage(
				nil,
				OVERHEAD_ALERT_BONUS_POISON_DAMAGE,
				self.parent,
				self.damage_table.damage,
				nil
			)
		end
	end
end

function modifier_aghsfort2_venomancer_poison_sting:AddCustomTransmitterData()
	return {
		slow = self.slow
	}
end

function modifier_aghsfort2_venomancer_poison_sting:HandleCustomTransmitterData(data)
	self.slow = data.slow
end

function modifier_aghsfort2_venomancer_poison_sting:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_aghsfort2_venomancer_poison_sting:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_aghsfort2_venomancer_poison_sting:updateData(kv)
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	if IsServer() then
		self.slow = self.ability:GetSpecialValueFor("movement_speed") + GetTalentValue(self.ability:GetCaster(), "venomancer_poison_sting-ms")
		self.slow = RescaleSlowUnderResist(self.parent, self.slow)
		self:SendBuffRefreshToClients()

		self.damage_table.damage = self.ability:GetSpecialValueFor("damage")
		if IsValid(self.ability.shard_side) then
			self.ability.shard_side:doAction({
				target = self.parent,
				duration = self:GetRemainingTime()
			})
		end
		if IsValid(self.ability.shard_boom) then
			local result = self.ability.shard_boom:doAction({
				attacker = self.caster,
				target = self.parent,
				duration = self:GetRemainingTime()
			})
			self._mod_boom = result.mod
		end
	end
end

if modifier_aghsfort2_venomancer_poison_sting_ward == nil then
	modifier_aghsfort2_venomancer_poison_sting_ward = class({})
end

function modifier_aghsfort2_venomancer_poison_sting_ward:IsPurgable()
	return self.bPurgable
end

function modifier_aghsfort2_venomancer_poison_sting_ward:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_poison_debuff.vpcf"
end

function modifier_aghsfort2_venomancer_poison_sting_ward:OnCreated(kv)
	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	self.parent = self:GetParent()
	self.bPurgable = not IsValid(self.ability.shard_side)

	if IsServer() then
		-- 这里真的可以设为-1,而且不显示层数
		-- self:SetStackCount(-1)
		if self.parent:HasModifier("modifier_aghsfort2_venomancer_poison_sting") then
			self:SetStackCount(-1)
		end
		self.damage_table = {
			victim = self.parent,
			attacker = self.caster,
			damage = 0,
			damage_type = self.ability:GetAbilityDamageType(),
			ability = self,
		}
	end
	self:SetHasCustomTransmitterData(true)
	self:updateData(kv)
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end

function modifier_aghsfort2_venomancer_poison_sting_ward:OnRefresh(kv)
	if IsServer() then
	end
	self:updateData(kv)
end

function modifier_aghsfort2_venomancer_poison_sting_ward:OnRemoved()
	if IsServer() then
	end
end

function modifier_aghsfort2_venomancer_poison_sting_ward:OnIntervalThink()
	if IsServer() then
		-- print("stacks:"..self:GetStackCount())
		if self:GetStackCount() >= 0 then
			if IsValid(self.ability.shard_boom) and IsValid(self._mod_boom) then
				self._mod_boom:addDamage(self.damage_table.damage)
			end
			ApplyDamage(self.damage_table)
			if IsValid(self.parent) then
				SendOverheadEventMessage(
					nil,
					OVERHEAD_ALERT_BONUS_POISON_DAMAGE,
					self.parent,
					self.damage_table.damage,
					nil
				)
			end
		end
	end
end

function modifier_aghsfort2_venomancer_poison_sting_ward:AddCustomTransmitterData()
	return {
		slow = self.slow
	}
end

function modifier_aghsfort2_venomancer_poison_sting_ward:HandleCustomTransmitterData(data)
	self.slow = data.slow
end

function modifier_aghsfort2_venomancer_poison_sting_ward:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_aghsfort2_venomancer_poison_sting_ward:GetModifierMoveSpeedBonus_Percentage()
	if self:GetStackCount() >= 0 then
		return self.slow
	end
	return 0
end

function modifier_aghsfort2_venomancer_poison_sting_ward:updateData(kv)
	if IsServer() then
		self.slow = self.ability:GetSpecialValueFor("movement_speed") + GetTalentValue(self.ability:GetCaster(), "venomancer_poison_sting-ms")
		self.slow = RescaleSlowUnderResist(self.parent, self.slow)
		self:SendBuffRefreshToClients()

		self.damage_table.damage = self.ability:GetSpecialValueFor("damage") * 0.5
		if IsValid(self.ability.shard_side) then
			self.ability.shard_side:doAction({
				target = self.parent,
				duration = self:GetRemainingTime()
			})
		end
		if IsValid(self.ability.shard_boom) then
			local result = self.ability.shard_boom:doAction({
				attacker = self.caster,
				target = self.parent,
				duration = self:GetRemainingTime()
			})
			self._mod_boom = result.mod
		end
	end
end
