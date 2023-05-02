LinkLuaModifier( "modifier_item_phantom_wings", "items/ext/item_phantom_wings.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_phantom_wings_sec_cast", "items/ext/item_phantom_wings.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_phantom_wings_active", "items/ext/item_phantom_wings.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_phantom_wings == nil then
	item_phantom_wings = class({})
end
function item_phantom_wings:Precache( context )
	PrecacheResource( "particle", "particles/creatures/aghanim/aghanim_preimage.vpcf", context )
	PrecacheResource( "particle", "particles/econ/items/legion/legion_fallen/legion_fallen_press_hands.vpcf", context )
	PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_faceless_void.vsndevts", context )
end
function item_phantom_wings:GetIntrinsicModifierName()
	return "modifier_item_phantom_wings"
end
function item_phantom_wings:GetCastRange(vLocation, hTarget)
	if IsServer() then
		return 99999
	end
	return self:GetSpecialValueFor("blink_range")
end
function item_phantom_wings:GetCooldown(iLevel)
	if self:GetCaster():IsRangedAttacker() then
		return self:GetSpecialValueFor("range_cd")
	else
		return self:GetSpecialValueFor("melee_cd")
	end
end
function item_phantom_wings:Spawn()
	if IsServer() then
		self.bMulticast = true
		self.iMultiState = 0
	end
end
-- immediate的技能没有这个阶段
function item_phantom_wings:OnAbilityPhaseStart()
	self.bMulticast = false
	self.iMultiState = self:GetCurrentCharges()
	return true
end
function item_phantom_wings:OnSpellStart()
	if not self.bMulticast then
		local phase = self:GetCurrentCharges()
		self:doAction({phase = phase})
		if phase == 0 then
			self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_phantom_wings_sec_cast", {duration = self:GetSpecialValueFor("sec_cast")})
		else
			self:GetCaster():RemoveModifierByName("modifier_item_phantom_wings_sec_cast")
		end
	else
		self:doAction({phase = self.iMultiState})
	end
	self.bMulticast = true
end
function item_phantom_wings:doAction(kv)
	local spos = self:GetCaster():GetAbsOrigin()
	local fpos = self:GetCursorPosition()
	local distance = math.min(VectorDistance(fpos, spos), self:GetSpecialValueFor("blink_range") + self:GetCaster():GetCastRangeBonus())
	fpos = spos + DirectionVector(fpos, spos) * distance
	local bRanged = self:GetCaster():IsRangedAttacker()

	local illusion_table = {
		outgoing_damage = 0,
		incoming_damage = self:GetSpecialValueFor("incoming_damage") - 100,
		bounty_base = 0,
		bounty_growth = 0,
		outgoing_damage_structure = 0,
		outgoing_damage_roshan = 0,
		duration = self:GetSpecialValueFor("illusion_duration")
	}
	if bRanged then
		illusion_table.outgoing_damage = self:GetSpecialValueFor("outgoing_ranged") - 100
	else
		illusion_table.outgoing_damage = self:GetSpecialValueFor("outgoing_melee") - 100
	end
	local illusion = CreateIllusions(self:GetCaster(), self:GetCaster(), illusion_table, 1, 0, false, false)[1]
	if IsValid(illusion) then
		illusion:SetControllableByPlayer(-1, true)
		illusion:AddNewModifier(self:GetCaster(), self, "modifier_no_healthbar", {})
		-- illusion:AddNewModifier(self:GetCaster(), self, "modifier_kill", { duration = self:GetSpecialValueFor("illusion_duration") } )
	end
	local unit_go = self:GetCaster()
	local unit_stay = illusion
	if kv.phase and kv.phase ~= 0 then
		unit_stay = unit_go
		unit_go = illusion		
	end
	ProjectileManager:ProjectileDodge(self:GetCaster())
	EmitSoundOn( "Hero_FacelessVoid.TimeWalk", unit_go )
	if not bRanged then
		unit_go:AddNewModifier(self:GetCaster(), self, "modifier_item_phantom_wings_active", {duration = self:GetCooldown(-1)})
		unit_stay:AddNewModifier(self:GetCaster(), self, "modifier_item_phantom_wings_active", {duration = self:GetCooldown(-1)})
	end
	local invul_kv = {
		duration = self:GetSpecialValueFor("invuln_duration")
	} 
	self:GetCaster():Purge(false, true, false, false, false)
	unit_stay:AddNewModifier(self:GetCaster(), self, "modifier_invulnerable", invul_kv )
	unit_go:AddNewModifier(self:GetCaster(), self, "modifier_invulnerable", invul_kv )
	FindClearSpaceForUnit(unit_go, fpos, false)
	FindClearSpaceForUnit(unit_stay, spos, false)

	local nFXIndex = ParticleManager:CreateParticle( "particles/creatures/aghanim/aghanim_preimage.vpcf", PATTACH_CUSTOMORIGIN, nil )
	ParticleManager:SetParticleControl( nFXIndex, 0, spos )
	ParticleManager:SetParticleControl( nFXIndex, 1, unit_go:GetAbsOrigin() )
	ParticleManager:SetParticleControlEnt( nFXIndex, 2, unit_go, PATTACH_ABSORIGIN_FOLLOW, nil, spos, true )
	ParticleManager:SetParticleFoWProperties( nFXIndex, 0, 2, 64.0 )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	if IsValid(illusion) then
		illusion:MoveToPositionAggressive(illusion:GetAbsOrigin())
	end
end

---------------------------------------------------------------------
--Modifiers
if modifier_item_phantom_wings == nil then
	modifier_item_phantom_wings = class({})
end
function modifier_item_phantom_wings:IsHidden()
	return true
end
function modifier_item_phantom_wings:OnCreated(params)
	self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.hp = self:GetAbility():GetSpecialValueFor("bonus_health")
	self.regen = self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
	self.str = self:GetAbility():GetSpecialValueFor("bonus_strength")
	self.int = self:GetAbility():GetSpecialValueFor("bonus_intellect")
	self.as = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	self.agi = self:GetAbility():GetSpecialValueFor("bonus_agility")
	self.ms = self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
	if IsServer() then
		self.bAngle = 0
	end
end
function modifier_item_phantom_wings:OnRefresh(params)
	self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.hp = self:GetAbility():GetSpecialValueFor("bonus_health")
	self.regen = self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
	self.str = self:GetAbility():GetSpecialValueFor("bonus_strength")
	self.int = self:GetAbility():GetSpecialValueFor("bonus_intellect")
	self.as = self:GetAbility():GetSpecialValueFor("bonus_attack_speed")
	self.agi = self:GetAbility():GetSpecialValueFor("bonus_agility")
	self.ms = self:GetAbility():GetSpecialValueFor("bonus_movement_speed")
	if IsServer() then
	end
end
function modifier_item_phantom_wings:OnDestroy()
	if IsServer() then
		self:GetCaster():RemoveModifierByName("modifier_item_phantom_wings_sec_cast")
	end
end
function modifier_item_phantom_wings:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE_UNIQUE,
	}
end
function modifier_item_phantom_wings:GetModifierIgnoreCastAngle(params)
	if IsServer() then
		return self.bAngle
	end
	return 0
end
function modifier_item_phantom_wings:OnOrder(event)
	if IsServer() then
		if event.ability == self:GetAbility() then
			self.bAngle = 1
		else
			self.bAngle = 0
		end
	end
end
function modifier_item_phantom_wings:GetModifierBaseAttack_BonusDamage()
	return self.damage
end
function modifier_item_phantom_wings:GetModifierHealthBonus()
	return self.hp
end
function modifier_item_phantom_wings:GetModifierConstantManaRegen()
	return self.regen
end
function modifier_item_phantom_wings:GetModifierBonusStats_Agility()
	return self.agi
end
function modifier_item_phantom_wings:GetModifierBonusStats_Strength()
	return self.str
end
function modifier_item_phantom_wings:GetModifierBonusStats_Intellect()
	return self.int
end
function modifier_item_phantom_wings:GetModifierAttackSpeedBonus_Constant()
	return self.as
end
function modifier_item_phantom_wings:GetModifierMoveSpeedBonus_Percentage_Unique()
	return self.ms
end
-- 
modifier_item_phantom_wings_sec_cast = modifier_item_phantom_wings_sec_cast or {}
function modifier_item_phantom_wings_sec_cast:IsHidden()
	return false
end
function modifier_item_phantom_wings_sec_cast:IsPurgable()
	return false
end
function modifier_item_phantom_wings_sec_cast:IsPurgeException()
	return false
end
function modifier_item_phantom_wings_sec_cast:OnCreated(kv)
	if IsServer() then
		-- print("prepare 2nd cast!")
		self:GetAbility():SetCurrentCharges(1)
		self:GetAbility():EndCooldown()
	end
end
function modifier_item_phantom_wings_sec_cast:OnDestroy()
	if IsServer() and IsValid(self:GetAbility()) then
		self:GetAbility():SetCurrentCharges(0)
		self:GetAbility():UseResources(false, false, false, true)
	end
end
-- 
modifier_item_phantom_wings_active = modifier_item_phantom_wings_active or {}
function modifier_item_phantom_wings_active:CheckState()
	return {
		[MODIFIER_STATE_CANNOT_MISS] = true
	}
end
function modifier_item_phantom_wings_active:IsPurgable()
	return false
end
function modifier_item_phantom_wings_active:IsPurgeException()
	return false
end
function modifier_item_phantom_wings_active:OnCreated(table)
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
function modifier_item_phantom_wings_active:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_ATTACK_POINT_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
	}
end
function modifier_item_phantom_wings_active:GetModifierAttackPointConstant()
	return self.ap
end
function modifier_item_phantom_wings_active:GetModifierAttackRangeBonus()
	return self.range
end
function modifier_item_phantom_wings_active:GetModifierAttackSpeedBonus_Constant()
	return self.as
end
function modifier_item_phantom_wings_active:OnAttack(event)
	if IsServer() then
		if event.attacker == self:GetParent() and self:GetParent():IsRangedAttacker() then
			self:Destroy()
			return
		end
	end
end
function modifier_item_phantom_wings_active:OnAttackLanded(event)
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
function modifier_item_phantom_wings_active:GetModifierTurnRate_Percentage( )
	return 100
end