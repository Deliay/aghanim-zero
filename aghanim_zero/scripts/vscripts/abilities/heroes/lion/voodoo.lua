LinkLuaModifier( "modifier_aghsfort_lion_voodoo", "abilities/heroes/lion/voodoo", LUA_MODIFIER_MOTION_NONE )
--Abilities
aghsfort_lion_voodoo = {}
function aghsfort_lion_voodoo:Init()
	self.hex_models = {
		"models/items/hex/fish_hex/fish_hex.vmdl",
		"models/props_gameplay/frog.vmdl"
	}
	self.modelscale_override = {
		["npc_dota_creature_aghsfort_primal_beast_boss"] = 4
	}
	self.modelscale_origin = {
		["npc_dota_creature_aghsfort_primal_beast_boss"] = 1
	}
end

function aghsfort_lion_voodoo:GetBehavior()
	if IsValid(self.shard_aoe) then
		return DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_POINT
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function aghsfort_lion_voodoo:GetAOERadius()
	if IsValid(self.shard_aoe) then
		return self.shard_aoe:GetSpecialValueFor("aoe")
	end
	return 0
end

function aghsfort_lion_voodoo:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local target = self:GetCursorTarget()
	self:doAction({
		caster = caster,
		target = target,
		pos = pos,
	})

	-- if IsValid(self.shard_aoe) then
	-- 	local pos = self:GetCursorPosition()
	-- 	local targets = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetAOERadius(), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)

	-- 	for _, target in pairs(targets) do
	-- 		if IsValid(target) then
	-- 			self:hexSingle({
	-- 				caster = caster,
	-- 				target = target
	-- 			})
	-- 		end
	-- 	end
	-- else	

	-- 	local target = self:GetCursorTarget()
		
	-- 	if IsValid(target) then
	-- 		self:hexSingle({
	-- 			caster = caster,
	-- 			target = target
	-- 		})
	-- 	end
	-- end
end

function aghsfort_lion_voodoo:doAction(kv)
	if self:GetLevel() < 1 then
		return
	end
	local caster = kv.caster
	local target = kv.target
	local pos = kv.pos or target:GetAbsOrigin()
	local damage = self:GetSpecialValueFor("int_damage") * caster:GetIntellect()

	if IsValid(self.shard_aoe) then
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetAOERadius(), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)

		for _, target in pairs(targets) do
			if IsValid(target) then
				self:hexSingle({
					caster = caster,
					target = target,
					damage = damage
				})
			end
		end
	else	
		if IsValid(target) then
			if target:GetTeamNumber() ~= caster:GetTeamNumber() then
				self:hexSingle({
					caster = caster,
					target = target,
					damage = damage
				})
			end
		end
	end
end

function aghsfort_lion_voodoo:hexSingle(kv)
	local caster = kv.caster
	local target = kv.target
	local damage = kv.damage or 0
	caster:EmitSound("Hero_Lion.Voodoo")
	if target:IsIllusion() then
		target:Kill(self, caster)
	end
	local duration = self:GetSpecialValueFor("duration") + GetTalentValue(caster, "lion_voodoo+duration")
	if IsAghanimConsideredHero(target) then
		if target:IsBossCreature() then
			local factor = self:GetSpecialValueFor("boss_factor")
			duration = duration * factor
			damage = damage / factor
		else
			local factor = self:GetSpecialValueFor("captain_factor")
			duration = duration * factor
			damage = damage / factor
		end
	end

	AddModifierConsiderResist(target, caster, self, "modifier_aghsfort_lion_voodoo", {duration = duration, damage = damage, tick_interval = 1.0})
end
---------------------------------------------------------------------
--Modifiers
modifier_aghsfort_lion_voodoo = {}

function modifier_aghsfort_lion_voodoo:IsPurgable()
	return false
end

function modifier_aghsfort_lion_voodoo:CheckState()
	return {
		[MODIFIER_STATE_HEXED] = true,
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_DISARMED] = true
	}
end

function modifier_aghsfort_lion_voodoo:OnCreated(kv)
	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	self.parent = self:GetParent()
	self:updateData(kv)
	if IsServer() then
		if IsValid(self.ability.shard_gold) then
			self.ability.shard_gold:doAction({
				target = self.parent,
				duration = self:GetDuration()
			})
		end
	end
end
function modifier_aghsfort_lion_voodoo:OnRefresh(kv)
	self:updateData(kv)
	if IsServer() then
		if IsValid(self.ability.shard_gold) then
			self.ability.shard_gold:doAction({
				target = self.parent,
				duration = self:GetDuration()
			})
		end
	end
end
function modifier_aghsfort_lion_voodoo:OnIntervalThink()
	if IsServer() then
		local damage_table = {
			victim = self.parent,
			attacker = self.caster,
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability,
		}
		ApplyDamage(damage_table)
	end
end
function modifier_aghsfort_lion_voodoo:OnDestroy()
	if IsServer() then
		if self.original_scale then
			self.parent:SetModelScale(self.original_scale)
		end
	end
end
function modifier_aghsfort_lion_voodoo:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		-- MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
	}
end
function modifier_aghsfort_lion_voodoo:GetModifierMoveSpeed_Absolute()
	return self.ms
end
function modifier_aghsfort_lion_voodoo:GetModifierModelChange() 
	return self.model_name
end
function modifier_aghsfort_lion_voodoo:updateData(kv)
	if self.ability.hex_models then
		self.model_name = self.ability.hex_models[RandomInt(1, #self.ability.hex_models)]
	else
		self.model_name = "models/items/hex/fish_hex/fish_hex.vmdl"
	end
	self.ms = self.ability:GetSpecialValueFor("movespeed")
	if IsServer() then
		self.damage = kv.damage
		self.tick_interval = kv.tick_interval
		if self.ability.modelscale_override then
			-- print(self.parent:GetUnitName())
			self.original_scale = self.ability.modelscale_origin[self.parent:GetUnitName()]
			self.model_scale = self.ability.modelscale_override[self.parent:GetUnitName()]
			if self.model_scale then
				self.parent:SetModelScale(self.model_scale)
			end
		end

		self:playEffects()
		self:OnIntervalThink()
		self:StartIntervalThink(self.tick_interval)
	end
end
function modifier_aghsfort_lion_voodoo:playEffects(kv)
	local pfx = ParticleManager:CreateParticle("particles/econ/items/lion/fish_stick/fish_stick_spell_fish.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:ReleaseParticleIndex(pfx)
	self:GetParent():EmitSound("Hero_Lion.Hex.Target")
end
