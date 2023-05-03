LinkLuaModifier( "modifier_aghsfort_lion_finger_of_death", "abilities/heroes/lion/finger_of_death", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_lion_finger_of_death_debuff", "abilities/heroes/lion/finger_of_death", LUA_MODIFIER_MOTION_NONE )
--Abilities
if aghsfort_lion_finger_of_death == nil then
	aghsfort_lion_finger_of_death = class({})
end
function aghsfort_lion_finger_of_death:GetBehavior()
	if IsValid(self.shard_aoe) then
		return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function aghsfort_lion_finger_of_death:GetAOERadius()
	if IsValid(self.shard_aoe) then
		return self.shard_aoe:GetSpecialValueFor("aoe")
	end
	return 0
end

function aghsfort_lion_finger_of_death:CastFilterResultTarget(hTarget)
	local team = self:GetCaster():GetTeamNumber()
	if IsValid(self.shard_doom) then
		return UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, team)
	end
	return UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, team)
end

function aghsfort_lion_finger_of_death:GetAbilityTargetFlags()
	if IsValid(self.shard_doom) then
		return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	end
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function aghsfort_lion_finger_of_death:GetIntrinsicModifierName()
	return "modifier_aghsfort_lion_finger_of_death"
end

function aghsfort_lion_finger_of_death:OnUpgrade()
	self.caster = self:GetCaster()
    self.hex = self.caster:FindAbilityByName("aghsfort_lion_voodoo")
	if AbilityChargeController:IsChargeTypeAbility(self) then
		AbilityChargeController:ChangeChargeAbilityConfig(self, self:GetCooldown(self:GetLevel() - 1),nil,nil,nil,nil)
	end
end

function aghsfort_lion_finger_of_death:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local team = caster:GetTeamNumber()

	if IsValid(target) then

		EmitSoundOn( "Hero_Lion.FingerOfDeath", caster )

		local first_targets = {}
		local target_flags = bit.bor(self:GetAbilityTargetFlags(), DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE)
		first_targets[target] = true
		if IsValid(self.shard_barbecue) then
			local range = self.shard_barbecue:GetSpecialValueFor("range")
			local enemies = FindUnitsInRadius(team, caster:GetAbsOrigin(), nil, range, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), target_flags, FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				if IsValid(enemy) and enemy:IsHexed() then
				-- if IsValid(enemy) and enemy:HasModifier("modifier_aghsfort_lion_voodoo") then
					first_targets[enemy] = true
				end
			end
		end
		local aoe = self:GetAOERadius()
		-- print("aoe:"..aoe)
		local second_targets = {}
		for first_target, v in pairs(first_targets) do
			second_targets[first_target] = true
			if aoe > 0 then
				local enemies = FindUnitsInRadius(team, target:GetAbsOrigin(), nil, aoe, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), target_flags, FIND_ANY_ORDER, false)
				for _, enemy in pairs(enemies) do
					if IsValid(enemy) then
						second_targets[enemy] = true
					end
				end
			end

			if IsValid(self.hex) and IsValid(self.hex.shard_barbecue) then
				self.hex:doAction({
					caster = caster,
					target = first_target,
				})
			end
		end

		for second_target, v in pairs(second_targets) do	
			self:doAction({
				caster = caster,
				target = second_target
			})
		end

	end
end
function aghsfort_lion_finger_of_death:doAction(kv)
	local caster = kv.caster
	local target = kv.target
	local duration = self:GetSpecialValueFor("grace_period")
	local delay = self:GetSpecialValueFor("damage_delay")

	self:playEffects({
		caster = caster, 
		target = target
	})
	local damage = self:GetSpecialValueFor("damage")
	if IsValid(self._intrinsic) then
		damage = damage + self._intrinsic:getDamageBonus()
	end

	local damage_table = {
		victim = target,
		attacker = caster,
		damage =  damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self,
	}

	if IsValid(self.shard_shred) then
		if target:HasModifier("modifier_aghsfort_lion_impale_shred") then
			damage_table.damage_type = DAMAGE_TYPE_PURE
			damage_table.damage = damage * self.shard_shred:GetSpecialValueFor("damage_mul")
		end
	end

	if IsValid(self.shard_doom) then
		duration = duration * self.shard_doom:GetSpecialValueFor("duration_mul")
		self.shard_doom:doAction({
			caster = caster,
			target = target,
			duration = duration,
			damage = damage
		})
	end
	target:AddNewModifier(caster, self, "modifier_aghsfort_lion_finger_of_death_debuff", {duration = duration})

	Timers:CreateTimer(delay, function()
		if IsValid(target) and target:IsAlive() then
			ApplyDamage(damage_table)
		end
		return nil
	end)
end

function aghsfort_lion_finger_of_death:addCounter(dCount)
	if not IsValid(self._intrinsic) then
		local caster = self:GetCaster()
		self._intrinsic = caster:FindModifierByName("modifier_aghsfort_lion_finger_of_death")
	end
	self._intrinsic:SetStackCount(self._intrinsic:GetStackCount() + dCount)
end

function aghsfort_lion_finger_of_death:playEffects(kv)
	local caster = kv.caster
	local target = kv.target

	-- Get Resources
	local pfx_name = "particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf"
	local sfx = "Hero_Lion.FingerOfDeathImpact"

	-- load data
	local direction = DirectionVector(target:GetOrigin(),caster:GetOrigin())

	-- Create Particle
	local pfx = ParticleManager:CreateParticle( pfx_name, PATTACH_ABSORIGIN, caster )
	local attach = "attach_attack1"
	if caster:ScriptLookupAttachment( "attach_attack2" )~=0 then attach = "attach_attack2" end
	ParticleManager:SetParticleControlEnt(
		pfx,
		0,
		caster,
		PATTACH_POINT_FOLLOW,
		attach,
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControlEnt(
		pfx,
		1,
		target,
		PATTACH_POINT_FOLLOW,
		"attach_hitloc",
		Vector(0,0,0), -- unknown
		true -- unknown, true
	)
	ParticleManager:SetParticleControl( pfx, 2, target:GetOrigin() )
	ParticleManager:SetParticleControl( pfx, 3, target:GetOrigin() - direction )
	ParticleManager:SetParticleControlForward( pfx, 3, direction )
	ParticleManager:ReleaseParticleIndex( pfx )

	-- Create Sound
	EmitSoundOn( sfx, target )
end

---------------------------------------------------------------------
--Modifiers
if modifier_aghsfort_lion_finger_of_death == nil then
	modifier_aghsfort_lion_finger_of_death = class({})
end

function modifier_aghsfort_lion_finger_of_death:RemoveOnDeath()
	return false
end
function modifier_aghsfort_lion_finger_of_death:OnCreated(kv)
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	self.damage_layer = 0
	self.hp_layer = 0
	self.last_stack = 0
	if IsServer() then
	end
	self:updateData(kv)
	self:StartIntervalThink(0.5)
end
function modifier_aghsfort_lion_finger_of_death:OnRefresh(kv)
	if IsServer() then
	end
	self:updateData(kv)
end
function modifier_aghsfort_lion_finger_of_death:OnIntervalThink()
	if IsServer() then
	end
	self:updateData()
end
function modifier_aghsfort_lion_finger_of_death:OnDestroy()
	if IsServer() then
	end
end
function modifier_aghsfort_lion_finger_of_death:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end
function modifier_aghsfort_lion_finger_of_death:GetModifierHealthBonus()
	return self.hp_layer * self:GetStackCount()
end
function modifier_aghsfort_lion_finger_of_death:OnTooltip()
	return self:getDamageBonus()
end

function modifier_aghsfort_lion_finger_of_death:getDamageBonus()
	return self.damage_layer * self:GetStackCount()
end

function modifier_aghsfort_lion_finger_of_death:updateData(kv)
	-- print("update")
	local damage_layer = self.ability:GetSpecialValueFor("damage_per_layer") + GetTalentValue(self.parent, "lion_finger_of_death+layer_dmg")
	local hp_layer = GetTalentValue(self.parent, "lion_finger_of_death+layer_hp")
	local bRefresh = self.damage_layer ~= damage_layer
	bRefresh = bRefresh or self.hp_layer ~= hp_layer
	bRefresh = bRefresh or self.last_stack ~= self:GetStackCount()
	self.damage_layer = damage_layer
	self.hp_layer = hp_layer
	self.last_stack = self:GetStackCount()
	if IsServer() then
		-- print(bRefresh)
		if bRefresh then
			self.parent:CalculateStatBonus(true)
			-- print("stats refresh!")
		end
	end
end

modifier_aghsfort_lion_finger_of_death_debuff = {}
-- function modifier_aghsfort_lion_finger_of_death_debuff:GetAttributes()
	
-- end
function modifier_aghsfort_lion_finger_of_death_debuff:IsPurgable()
	return false
end

function modifier_aghsfort_lion_finger_of_death_debuff:IsPurgeException()
	return false
end
function modifier_aghsfort_lion_finger_of_death_debuff:OnCreated(kv)
	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	self.parent = self:GetParent()
	self:updateData(kv)
end

function modifier_aghsfort_lion_finger_of_death_debuff:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH
	}
end

function modifier_aghsfort_lion_finger_of_death_debuff:updateData(kv)
	if IsServer() then
		self.layer = 1
		if IsAghanimConsideredHero(self.parent) then
			if self.parent:IsBossCreature() then
				self.layer = self.ability:GetSpecialValueFor("boss_layer")
			else
				self.layer = self.ability:GetSpecialValueFor("captain_layer")
			end
		end
	end
end

function modifier_aghsfort_lion_finger_of_death_debuff:OnDeath(event)
	if IsServer() then
		if IsValid(event.unit) and event.unit == self.parent and IsValid(self.ability) then
			EmitSoundOnLocationWithCaster(event.unit:GetAbsOrigin(), "Hero_Lion.KillCounter", self.caster)
			self.ability:addCounter(self.layer)
		end
	end
end
