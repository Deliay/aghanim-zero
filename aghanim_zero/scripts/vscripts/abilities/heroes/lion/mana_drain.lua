LinkLuaModifier( "modifier_aghsfort_lion_mana_drain", "abilities/heroes/lion/mana_drain", LUA_MODIFIER_MOTION_NONE )
--Abilities
if aghsfort_lion_mana_drain == nil then
	aghsfort_lion_mana_drain = class({})
end

function aghsfort_lion_mana_drain:Init()
	if IsServer() then
		self._drain_modifiers = {}
	end
end

function aghsfort_lion_mana_drain:OnUpgrade()
	self.caster = self:GetCaster()
    self.hex = self.caster:FindAbilityByName("aghsfort_lion_voodoo")
end

function aghsfort_lion_mana_drain:GetCooldown(iLevel)
    local cooldown = self.BaseClass.GetCooldown(self, iLevel)
	if IsValid(self.shard_ally) then
		return self.shard_ally:GetSpecialValueFor("cd")	
	end
    return math.max(cooldown, 0)
end


function aghsfort_lion_mana_drain:CastFilterResultTarget(hTarget)
	if IsServer() then
		local caster = self:GetCaster()
		local team = caster:GetTeamNumber()
		if IsValid(self.shard_ally) and hTarget:GetTeamNumber() == team then
			if hTarget == caster then
				return UF_FAIL_OTHER
			end
			return UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, team)
		else
			return UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, team)
		end
	end
	return UF_SUCCESS
end

function aghsfort_lion_mana_drain:GetChannelTime()
	return self:GetSpecialValueFor("duration") + 0.1
end

function aghsfort_lion_mana_drain:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	if IsValid(target) then
		self:doAction({
			caster = caster,
			target = target,
			bChannel = true
		})

		if IsValid(self.hex) and IsValid(self.hex.shard_barbecue) then
			self.hex:doAction({
				caster = caster,
				target = target,
			})
		end

		if IsValid(self.shard_tripple) then
			self.shard_tripple:doAction({
				caster = caster,
				target = target,
			})
		end
	end
end

function aghsfort_lion_mana_drain:OnChannelThink(flInterval)
	local bStop = true
	-- print("thinking!")
	for _, mod in pairs(self._drain_modifiers) do
		if IsValid(mod) then
			bStop = false
		end
	end
	if bStop then
		self:EndChannel(true)
	end
end

function aghsfort_lion_mana_drain:OnChannelFinish(bInterrupted)
	for _, mod in pairs(self._drain_modifiers) do
		if IsValid(mod) then
			mod:Destroy()
		end
	end
	if IsValid(self.shard_tripple) then
		self.shard_tripple:stopAction({
			caster = self:GetCaster(),
		})
	end
	self._drain_modifiers = {}
end

function aghsfort_lion_mana_drain:doAction(kv)
	local caster = kv.caster
	local target = kv.target
	local bChannel = kv.bChannel

	-- load data
	local duration = self:GetSpecialValueFor("duration")

	-- register modifier (in case for multi-target)
	local modifier = target:AddNewModifier(
		caster, -- player source
		self, -- ability source
		"modifier_aghsfort_lion_mana_drain", -- modifier name
		{ duration = duration } -- kv
	)
	if bChannel then
		table.insert(self._drain_modifiers, modifier)
	end

	-- play effects
	self.sound_cast = "Hero_Lion.ManaDrain"
	EmitSoundOn( self.sound_cast, caster )
end


---------------------------------------------------------------------
--Modifiers
if modifier_aghsfort_lion_mana_drain == nil then
	modifier_aghsfort_lion_mana_drain = class({})
end
function modifier_aghsfort_lion_mana_drain:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_aghsfort_lion_mana_drain:IsPurgable()
	return false
end

function modifier_aghsfort_lion_mana_drain:OnCreated(kv)
	self.ability = self:GetAbility()
	self.parent = self:GetParent()
	self.caster = self.ability:GetCaster()
	self.team = self.caster:GetTeamNumber()
	self.bAlly = self.team == self.parent:GetTeamNumber()

	if IsServer() then		
		self.damage_table = {
			victim = self.parent,
			attacker = self.caster,
			damage = 0,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_HPLOSS,
			ability = self.ability,
		}
		if IsValid(self.ability.shard_amp) then
			if self.bAlly then
				self.amp_mod = self.parent:AddNewModifier(self.caster, self.ability.shard_amp, "modifier_aghsfort_lion_drain_amp", {})
			else
				self.amp_mod = self.caster:AddNewModifier(self.caster, self.ability.shard_amp, "modifier_aghsfort_lion_drain_amp", {})
			end
		end
	end
	self:updateData(kv)
	if IsServer() then
		self:playEffects()
		self:StartIntervalThink(self.interval)
	end
end
function modifier_aghsfort_lion_mana_drain:OnRefresh(kv)
	if IsServer() then
	end
	self:updateData(kv)
end
function modifier_aghsfort_lion_mana_drain:OnIntervalThink()
	if IsServer() then
		if not IsValid(self.caster) or not self.caster:IsAlive() then
			self:Destroy()
			return
		end
		if IsValid(self.parent) then
			if not self.bAlly then
				local filter_result = UnitFilter(self.parent, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, self.team)
				if filter_result ~= UF_SUCCESS then
					self:Destroy()
					return
				end
			end
			local distance = VectorDistance(self.caster:GetAbsOrigin(), self.parent:GetAbsOrigin())
			if distance > self.break_distance then
				self:Destroy()
				return
			end
		end
		if self.bAlly then
			if self.caster:GetMana() < self.drain then
				self:Destroy()
				return
			end
			self.parent:Heal(self.damage_table.damage, self.ability)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self.parent, self.drain, nil)
			self.caster:SpendMana(self.drain, self.ability)
		else
			ApplyDamage(self.damage_table)
			self.caster:GiveMana(self.drain)
		end
		if IsValid(self.ability.shard_amp) and IsValid(self.amp_mod) then
			self.amp_mod:IncrementStackCount()
		end
	end
end
function modifier_aghsfort_lion_mana_drain:OnRemoved()
	if IsServer() then
		if IsValid(self.ability.shard_amp) and IsValid(self.amp_mod) then
			self.amp_mod:SetDuration(self.ability.shard_amp:GetSpecialValueFor("linger"), true)
		end
	end
end
function modifier_aghsfort_lion_mana_drain:OnDestroy()
	if IsServer() then
	end
end
function modifier_aghsfort_lion_mana_drain:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end
function modifier_aghsfort_lion_mana_drain:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_aghsfort_lion_mana_drain:updateData(kv)
	self.slow = self.ability:GetSpecialValueFor("movespeed")
	if not self.bAlly then
		self.slow = -self.slow
	end
	if IsServer() then
		self.interval = self.ability:GetSpecialValueFor("tick_interval")
		self.drain = (self.ability:GetSpecialValueFor("drain_per_second") + GetTalentValue(self.caster, "lion_mana_drain+drain")) * self.interval
		self.damage_mana = self.ability:GetSpecialValueFor("damage_mana")
		self.damage_table.damage = self.drain / self.damage_mana
		local base_distance = math.max(self.ability:GetCastRange(self.caster:GetAbsOrigin(), self.parent), VectorDistance2D(self.caster:GetAbsOrigin(), self.parent:GetAbsOrigin()))
		self.break_distance = base_distance + self.caster:GetCastRangeBonus() + self.ability:GetSpecialValueFor("buff_distance")
	end
end

function modifier_aghsfort_lion_mana_drain:playEffects(kv)
	-- Create Particle
	local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_lion/lion_spell_mana_drain.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent )

	if self.bAlly then
		ParticleManager:SetParticleControlEnt(
			pfx,
			0,
			self.caster,
			PATTACH_POINT_FOLLOW,
			"attach_mouth",
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
		ParticleManager:SetParticleControlEnt(
			pfx,
			1,
			self.parent,
			PATTACH_POINT_FOLLOW,
			"attach_hitloc",
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	else
		ParticleManager:SetParticleControlEnt(
			pfx,
			0,
			self.parent,
			PATTACH_POINT_FOLLOW,
			"attach_hitloc",
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
		ParticleManager:SetParticleControlEnt(
			pfx,
			1,
			self.caster,
			PATTACH_POINT_FOLLOW,
			"attach_mouth",
			Vector(0,0,0), -- unknown
			true -- unknown, true
		)
	end

	-- buff particle
	self:AddParticle(
		pfx,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end
