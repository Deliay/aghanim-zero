LinkLuaModifier( "modifier_aghsfort2_venomancer_plague_ward", "abilities/heroes/venomancer/plague_ward.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if aghsfort2_venomancer_plague_ward == nil then
	aghsfort2_venomancer_plague_ward = class({})
end

function aghsfort2_venomancer_plague_ward:GetCooldown(iLevel)
    local cooldown = self.BaseClass.GetCooldown(self, iLevel) -
                         GetTalentValue(self:GetCaster(), "venomancer_plague_ward-cd")
    return math.max(cooldown, 0)
end

function aghsfort2_venomancer_plague_ward:OnUpgrade()
	if not IsValid(self.sting) then
		self.sting = self:GetCaster():FindAbilityByName("aghsfort2_venomancer_poison_sting")
	end
end

function aghsfort2_venomancer_plague_ward:OnSpellStart()
	local caster = self:GetCaster()
	local pos = caster:GetCursorPosition()

	self:doAction({
		caster = caster,
		pos_list = {pos}
	})
end

function aghsfort2_venomancer_plague_ward:doAction(kv)
	if self:GetLevel() < 1 then
		return
	end
	local caster = kv.caster
	local pos_list = kv.pos_list
	local ward_hp = self:GetSpecialValueFor("ward_hp")
	local ward_damage = self:GetSpecialValueFor("ward_damage") * (caster:GetSpellAmplification(false) + 1)
	local duration = self:GetSpecialValueFor("duration")
	local as_bonus = self:GetSpecialValueFor("ward_as") - 100
	
	local mul = GetTalentValue(caster, "venomancer_plague_wardxstats")
	if mul > 0 then
		ward_hp = ward_hp * mul
		ward_damage = ward_damage * mul
	end

	for _, pos in pairs(pos_list) do	
		CreateUnitByNameAsync("npc_dota_venomancer_plague_ward_1_aghs2", pos, true, caster, caster, caster:GetTeamNumber(), function (ward)
			ward:SetBaseMaxHealth(ward_hp)
			ward:AddNewModifier(caster, self, "modifier_aghsfort2_venomancer_plague_ward", {damage = ward_damage, as_bonus = as_bonus})
			if IsValid(self.sting) then
				self.sting:setApplier({
					target = ward
				})
			end
			ward:SetControllableByPlayer(caster:GetPlayerID(), true)
			ward:AddNewModifier(caster, self, "modifier_kill", {
				duration = duration
			})
			if IsValid(self.shard_nova) then
				self.shard_nova:doAction({
					bWard = true,
					target = ward,
				})
			end
			-- 这里应该是kv里不设置，这样在创建时才可以改
			if IsValid(self.shard_move) then
				print("ground move!")
				self.shard_move:doAction({
					target = ward,
				})
			else
				ward:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
			end
			
			EmitSoundOnLocationWithCaster(pos, "Hero_Venomancer.Plague_Ward", nil)
		end)
	end
end

---------------------------------------------------------------------
--Modifiers
if modifier_aghsfort2_venomancer_plague_ward == nil then
	modifier_aghsfort2_venomancer_plague_ward = class({})
end
function modifier_aghsfort2_venomancer_plague_ward:IsHidden()
	return true
end
function modifier_aghsfort2_venomancer_plague_ward:CheckState()
	return {
		-- [MODIFIER_STATE_ROOTED] = true
	}
end

function modifier_aghsfort2_venomancer_plague_ward:OnCreated(kv)
	self:SetHasCustomTransmitterData(true)
	self:updateData(kv)
end
function modifier_aghsfort2_venomancer_plague_ward:OnRefresh(kv)
	self:updateData(kv)
end
function modifier_aghsfort2_venomancer_plague_ward:OnDestroy()
	if IsServer() then
	end
end

function modifier_aghsfort2_venomancer_plague_ward:AddCustomTransmitterData()
	return {
		damage = self.damage,
		as_bonus = self.as_bonus
	}
end

function modifier_aghsfort2_venomancer_plague_ward:HandleCustomTransmitterData(data)
	self.damage = data.damage
	self.as_bonus = data.as_bonus
end

function modifier_aghsfort2_venomancer_plague_ward:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_aghsfort2_venomancer_plague_ward:GetModifierBaseAttack_BonusDamage()
	return self.damage
end

function modifier_aghsfort2_venomancer_plague_ward:GetModifierAttackSpeedBonus_Constant()
	return self.as_bonus
end

function modifier_aghsfort2_venomancer_plague_ward:updateData(kv)
	if IsServer() then
		-- print("modify damage!")
		self.damage = kv.damage
		self.as_bonus = kv.as_bonus
		self:SendBuffRefreshToClients()
	end
end
