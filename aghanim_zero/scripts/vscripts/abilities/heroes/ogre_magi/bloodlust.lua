LinkLuaModifier( "modifier_aghsfort_ogre_magi_bloodlust", "abilities/heroes/ogre_magi/bloodlust", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_ogre_magi_bloodlust_buff", "abilities/heroes/ogre_magi/bloodlust", LUA_MODIFIER_MOTION_NONE )
--Abilities
if aghsfort_ogre_magi_bloodlust == nil then
	aghsfort_ogre_magi_bloodlust = class({})
end
function aghsfort_ogre_magi_bloodlust:GetIntrinsicModifierName()
	return "modifier_aghsfort_ogre_magi_bloodlust"
end

function aghsfort_ogre_magi_bloodlust:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()

	if IsValid(target) then
		self:doAction({
			caster = caster,
			target = target,
		})
	end
end

function aghsfort_ogre_magi_bloodlust:doAction(kv)
	local caster = kv.caster
	local target = kv.target
	local duration = self:GetSpecialValueFor("duration")
	if IsValid(target) then
		self:playEffects({
			caster = caster,
			target = target
		})
		target:AddNewModifier(caster, self, "modifier_aghsfort_ogre_magi_bloodlust_buff", {duration = duration})
	end
end
function aghsfort_ogre_magi_bloodlust:playEffects(kv)
	local caster = kv.caster
	local target = kv.target
	-- Get Resources
	local sfx = "Hero_OgreMagi.Bloodlust.Cast"

	-- Create Particle
	local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt(
		pfx,
		0,
		caster,
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		pfx,
		2,
		caster,
		PATTACH_POINT_FOLLOW,
		"attach_attack1",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		pfx,
		3,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:ReleaseParticleIndex( pfx )

	-- Create Sound
	EmitSoundOn( sfx, caster )

	local random_response = RandomInt(1, 4)
	caster:EmitSound("ogre_magi_ogmag_ability_bloodlust_0"..random_response)
end

---------------------------------------------------------------------
--Modifiers
if modifier_aghsfort_ogre_magi_bloodlust == nil then
	modifier_aghsfort_ogre_magi_bloodlust = class({})
end
function modifier_aghsfort_ogre_magi_bloodlust:IsHidden()
	return true
end
function modifier_aghsfort_ogre_magi_bloodlust:OnCreated(kv)
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self:updateData(kv)
	if IsServer() then
		self:StartIntervalThink(1.0)
	end
end
function modifier_aghsfort_ogre_magi_bloodlust:OnRefresh(kv)
	if IsServer() then
		
	end
	self:updateData(kv)
end
function modifier_aghsfort_ogre_magi_bloodlust:OnDestroy()
	if IsServer() then
	end
end
function modifier_aghsfort_ogre_magi_bloodlust:OnIntervalThink()
	if IsServer() then
		if self.parent:IsAlive() and self.ability:GetAutoCastState() and self.ability:IsCooldownReady() then
			if self.parent:IsSilenced() or self.parent:IsChanneling() or self.parent:IsHexed() then
				return
			end
			if self.parent:HasModifier("modifier_aghsfort_player_transform") then
				return
			end
			if self.parent:GetMana() < self.ability:GetManaCost(self.ability:GetLevel()) then
				self.ability:ToggleAutoCast()
				return
			end
			local allies = FindUnitsInRadius(self.parent:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.auto_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
			for _, ally in pairs(allies) do
				if not ally:HasModifier("modifier_aghsfort_ogre_magi_bloodlust_buff") then
					self.parent:CastAbilityOnTarget(ally, self.ability, self.parent:GetPlayerOwnerID())
					break
				end
			end
		end
	end
end
function modifier_aghsfort_ogre_magi_bloodlust:DeclareFunctions()
	return {
	}
end

function modifier_aghsfort_ogre_magi_bloodlust:updateData(kv)
	if IsServer() then
		self.auto_radius = self.ability:GetSpecialValueFor("multicast_bloodlust_aoe")
	end
end
-- 
modifier_aghsfort_ogre_magi_bloodlust_buff = {}

function modifier_aghsfort_ogre_magi_bloodlust_buff:IsDebuff()
	return false
end

function modifier_aghsfort_ogre_magi_bloodlust_buff:IsPurgable()
	return true
end

-- function modifier_aghsfort_ogre_magi_bloodlust_buff:GetEffectName()
-- 	return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf"
-- end
-- function modifier_aghsfort_ogre_magi_bloodlust_buff:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end
function modifier_aghsfort_ogre_magi_bloodlust_buff:OnCreated(kv)
	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	self.parent = self:GetParent()
	if IsServer() then
		-- 这个方法可以实现modifier变主属性
		-- if self.parent:IsRealHero() then
		-- 	self.primary = self.parent:GetPrimaryAttribute()
		-- 	self.parent:SetPrimaryAttribute(DOTA_ATTRIBUTE_STRENGTH)
		-- end
		if IsValid(self.ability.shard_multicast) then
			-- print("shard multicast: apply!")
			self.ability.shard_multicast:doAction({
				target = self.parent
			})
		end
		if IsValid(self.ability.shard_shield) then
			print("shield shard!")
			self.ability.shard_shield:doAction({
				target = self.parent
			})
		end
		self:playEffects()
	end
	self:updateData(kv)
end
function modifier_aghsfort_ogre_magi_bloodlust_buff:OnRefresh(kv)
	if IsServer() then
		self:playEffects()
		if IsValid(self.ability.shard_shield) then
			print("shield shard!")
			self.ability.shard_shield:doAction({
				target = self.parent
			})
		end
	end
	self:updateData(kv)
end
function modifier_aghsfort_ogre_magi_bloodlust_buff:OnRemoved()
	if IsServer() then
		-- if self.primary then
		-- 	self.parent:SetPrimaryAttribute(self.primary)
		-- end
		if IsValid(self.ability.shard_multicast) then
			-- print("shard multicast: remove!")
			self.ability.shard_multicast:stopAction({
				target = self.parent
			})
		end

		if IsValid(self.ability.shard_shield) then
			self.ability.shard_shield:stopAction({
				target = self.parent
			})
		end
	end
end
function modifier_aghsfort_ogre_magi_bloodlust_buff:OnDestroy()
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
end
function modifier_aghsfort_ogre_magi_bloodlust_buff:OnIntervalThink()
	if IsServer() then 
		local heal = (self.str_bonus - self._last_str) * STRENGTH_HP
		print("heal:"..heal)
		if heal > 0 then
			self.parent:Heal(heal, self.ability)
		end
		self:StartIntervalThink(-1)
	end
end
function modifier_aghsfort_ogre_magi_bloodlust_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_EXTRA_STRENGTH_BONUS,
	}
end

function modifier_aghsfort_ogre_magi_bloodlust_buff:GetModifierModelScale()
	return self.scale
end
function modifier_aghsfort_ogre_magi_bloodlust_buff:GetModifierAttackSpeedBonus_Constant()
	return self.as_bonus
end
function modifier_aghsfort_ogre_magi_bloodlust_buff:GetModifierMoveSpeedBonus_Percentage()
	return self.ms_bonus
end
function modifier_aghsfort_ogre_magi_bloodlust_buff:GetModifierExtraStrengthBonus()
	-- print(self.str_bonus)
	return self.str_bonus
end

function modifier_aghsfort_ogre_magi_bloodlust_buff:updateData(kv)
	if self.caster == self.parent then
		self.as_bonus = self.ability:GetSpecialValueFor("self_bonus")
	else
		self.as_bonus = self.ability:GetSpecialValueFor("bonus_attack_speed")
	end
	self.as_bonus = self.as_bonus + GetTalentValue(self.caster, "ogre_magi_bloodlust+as")
	self.scale = self.ability:GetSpecialValueFor("modelscale")
	self.ms_bonus = self.ability:GetSpecialValueFor("bonus_movement_speed")
	self.str_bonus = self.str_bonus or 0

	if IsValid(self.ability.shard_str) then
		self._last_str = self.str_bonus
		self.str_bonus = self.ability.shard_str:GetSpecialValueFor("str_mul") * self.as_bonus
		self.scale = self.scale + self.ability.shard_str:GetSpecialValueFor("bonus_scale")
		
		self:StartIntervalThink(0)

	end
end
function modifier_aghsfort_ogre_magi_bloodlust_buff:playEffects(kv)
	self.parent:EmitSound("Hero_OgreMagi.Bloodlust.Target")
	if self.pfx then
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	end
	self.pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent )
end