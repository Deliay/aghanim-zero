LinkLuaModifier( "modifier_item_renge", "items/item_renge.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_renge_active", "items/item_renge.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_renge == nil then
	item_renge = class({})
end
function item_renge:Precache( context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_preimage.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/legion/legion_fallen/legion_fallen_press_hands.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_faceless_void.vsndevts", context )
end
function item_renge:GetIntrinsicModifierName()
	return "modifier_item_renge"
end
function item_renge:RequiresFacing()
	return false
end
function item_renge:GetCooldown(iLevel)
	if self:GetCaster():IsRangedAttacker() then
		return self:GetSpecialValueFor("range_cd")
	else
		return self:GetSpecialValueFor("melee_cd")
	end
end
function item_renge:GetCastRange(vLocation, hTarget)
	if IsServer() then
		return 99999
	end
	return self:GetSpecialValueFor("blink_range")
end
function item_renge:OnSpellStart()
	local spos = self:GetCaster():GetAbsOrigin()
	local fpos = self:GetCursorPosition()
	local distance = math.min(VectorDistance(fpos, spos), self:GetSpecialValueFor("blink_range") + self:GetCaster():GetCastRangeBonus())
	fpos = spos + DirectionVector(fpos, spos) * distance

	ProjectileManager:ProjectileDodge(self:GetCaster())

	EmitSoundOn( "Hero_FacelessVoid.TimeWalk", self:GetCaster() )

	if not self:GetCaster():IsRangedAttacker() then
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_renge_active", {duration = self:GetCooldown(-1)})
	end

	FindClearSpaceForUnit(self:GetCaster(), fpos, false)
	local nFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_preimage.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( nFXIndex, 0, spos )
	ParticleManager:SetParticleControl( nFXIndex, 1, self:GetCaster():GetAbsOrigin() )
	ParticleManager:SetParticleControlEnt( nFXIndex, 2, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, spos, true )
	ParticleManager:SetParticleFoWProperties( nFXIndex, 0, 2, 64.0 )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_renge == nil then
	modifier_item_renge = class({})
end
function modifier_item_renge:IsHidden()
	return true
end
function modifier_item_renge:OnCreated(params)
	self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.hp = self:GetAbility():GetSpecialValueFor("bonus_health")
	self.regen = self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
	self.str = self:GetAbility():GetSpecialValueFor("bonus_strength")
	self.int = self:GetAbility():GetSpecialValueFor("bonus_intellect")
	self.as = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	if IsServer() then
		self.bAngle = 0
	end
end
function modifier_item_renge:OnRefresh(params)
	self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.hp = self:GetAbility():GetSpecialValueFor("bonus_health")
	self.regen = self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
	self.str = self:GetAbility():GetSpecialValueFor("bonus_strength")
	self.int = self:GetAbility():GetSpecialValueFor("bonus_intellect")
	self.as = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	if IsServer() then
	end
end
function modifier_item_renge:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_renge:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
end
function modifier_item_renge:GetModifierIgnoreCastAngle(params)
	if IsServer() then
		return self.bAngle
	end
	return 0
end
function modifier_item_renge:OnOrder(event)
	if IsServer() then
		if event.ability == self:GetAbility() then
			self.bAngle = 1
		else
			self.bAngle = 0
		end
	end
end
function modifier_item_renge:GetModifierPreAttack_BonusDamage()
	return self.damage
end
function modifier_item_renge:GetModifierHealthBonus()
	return self.hp
end
function modifier_item_renge:GetModifierConstantManaRegen()
	return self.regen
end
function modifier_item_renge:GetModifierBonusStats_Strength()
	return self.str
end
function modifier_item_renge:GetModifierBonusStats_Intellect()
	return self.int
end
function modifier_item_renge:GetModifierAttackSpeedBonus_Constant()
	return self.as
end
modifier_item_renge_active = modifier_item_renge_active or {}
function modifier_item_renge_active:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true
	}
end
function modifier_item_renge_active:IsPurgable()
	return false
end
function modifier_item_renge_active:IsPurgeException()
	return false
end
function modifier_item_renge_active:OnCreated(table)
	self.range = self:GetAbility():GetSpecialValueFor("bonus_range")
	self.as = self:GetAbility():GetSpecialValueFor("bonus_as")
	self.ap = self:GetAbility():GetSpecialValueFor("attack_point")
	if IsServer() then
		self.slow_dur = self:GetAbility():GetSpecialValueFor("slow_duration")
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("attacks"))
		local attach = "attach_attack1"
		-- if self:GetCaster():ScriptLookupAttachment( attach )==0 then attach = "attach_hand" end
		local pfx = ParticleManager:CreateParticle("particles/econ/items/legion/legion_fallen/legion_fallen_press_hands.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(pfx, 2, self:GetParent(), PATTACH_POINT_FOLLOW, attach, self:GetParent():GetAbsOrigin(), false)
		self:AddParticle(pfx, false, false, -1, false, false)
	end
end
function modifier_item_renge_active:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ATTACK_POINT_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
		-- MODIFIER_PROPERTY_ATTACK_WHILE_MOVING_TARGET,
	}
end
function modifier_item_renge_active:GetModifierAttackPointConstant()
	return self.ap
end
function modifier_item_renge_active:GetModifierAttackRangeBonus()
	return self.range
end
function modifier_item_renge_active:GetModifierAttackSpeedBonus_Constant()
	return self.as
end
function modifier_item_renge_active:OnAttack(event)
	if IsServer() then
		if event.attacker == self:GetParent() and self:GetParent():IsRangedAttacker() then
			self:Destroy()
			return
		end
	end
end
function modifier_item_renge_active:OnAttackLanded(event)
	if IsServer() then
		if event.attacker == self:GetParent() then
			if IsValid(event.target) and UnitFilter(event.target, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, DOTA_TEAM_GOODGUYS) == UF_SUCCESS then
				event.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_echo_sabre_debuff", {duration = self.slow_dur})
			end
			self:DecrementStackCount()
			if self:GetStackCount() <= 0 then
				self:Destroy()
				return
			end
		end
	end
end
function modifier_item_renge_active:GetModifierAttackWhileMovingTarget(params)
	if params then
		print("has params")
	end
	return self:GetParent():GetAggroTarget()
end
function modifier_item_renge_active:GetModifierTurnRate_Percentage( )
	return 100
end