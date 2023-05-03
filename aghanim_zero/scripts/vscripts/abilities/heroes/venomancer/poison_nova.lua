LinkLuaModifier( "modifier_aghsfort2_venomancer_poison_nova", "abilities/heroes/venomancer/poison_nova.lua", LUA_MODIFIER_MOTION_NONE )

if aghsfort2_venomancer_poison_nova == nil then
	aghsfort2_venomancer_poison_nova = class({})
end

function aghsfort2_venomancer_poison_nova:GetCastRange()
    return self:GetSpecialValueFor("radius") + GetTalentValue(self:GetCaster(), "venomancer_poison_nova+radius")
end

function aghsfort2_venomancer_poison_nova:OnSpellStart()
	local caster = self:GetCaster()
	local pos = caster:GetAbsOrigin()
	self:doAction({
		pos = pos
	})
	if IsValid(self.shard_all) then
		local heroes = HeroList:GetAllHeroes()
		local team_num = caster:GetTeamNumber()
		for _, hero in pairs(heroes) do
			
			if IsValid(hero) and hero:GetTeamNumber() == team_num and not hero:IsIllusion() and hero ~= caster then
				self:doAction({
					pos = hero:GetAbsOrigin()
				})
			end
		end
	end
end


function aghsfort2_venomancer_poison_nova:doAction(kv)
	if self:GetLevel() < 1 then
		return
	end
	local caster = self:GetCaster()
	local pos = kv.pos
	local rad_pct = kv.rad_pct or 1.0
	local dur_pct = kv.dur_pct or 1.0

	local start_radius = self:GetSpecialValueFor("start_radius") * rad_pct
	local radius = (self:GetSpecialValueFor("radius") + GetTalentValue(caster, "venomancer_poison_nova+radius")) * rad_pct
	local speed = self:GetSpecialValueFor("speed")
	local duration = (self:GetSpecialValueFor("duration") + GetTalentValue(caster, "venomancer_poison_nova+dur")) * dur_pct
	local thinker_duration = (radius - start_radius) / speed

	local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
	if IsValid(self.shard_heal) then
		target_team = DOTA_UNIT_TARGET_TEAM_BOTH
	end

	-- create ring
	local thinker = CreateModifierThinker(caster, self, "modifier_generic_ring_lua", 
	{
		start_radius = start_radius,
		end_radius = radius,
		speed = speed,
		-- width = 255,
		target_team = target_team,
		target_type = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		IsCircle = 0,
	},
	pos, caster:GetTeamNumber(), false)

	if IsValid(thinker) then
		local ring = thinker:FindModifierByName("modifier_generic_ring_lua")
		if IsValid(ring) then
			-- print(ring:GetName())
			ring:SetCallback( function( target )
				-- add modifier
				target:AddNewModifier(
					caster, -- player source
					self, -- ability source
					"modifier_aghsfort2_venomancer_poison_nova", -- modifier name
					{ duration = duration } -- kv
				)
		
				-- play effects
				EmitSoundOn( "Hero_Venomancer.PoisonNovaImpact", target )
			end)
		end
	end

	self:PlayEffects({
		pos = pos,
		speed = speed,
		duration = thinker_duration
	})
end

-- Effects
function aghsfort2_venomancer_poison_nova:PlayEffects( kv )
	local pos = kv.pos
	local speed = kv.speed
	local duration = kv.duration

	-- Create Particle
	local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf", PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl(pfx, 0, pos)
	ParticleManager:SetParticleControl( pfx, 1, Vector( speed, duration, speed ) )
	ParticleManager:ReleaseParticleIndex( pfx )

	-- Create Sound
	EmitSoundOnLocationWithCaster(pos, "Hero_Venomancer.PoisonNova", nil)
end

--------------------------------------------------------------------
--Modifiers
if modifier_aghsfort2_venomancer_poison_nova == nil then
	modifier_aghsfort2_venomancer_poison_nova = class({})
end
function modifier_aghsfort2_venomancer_poison_nova:IsPurgable()
	return false
end
function modifier_aghsfort2_venomancer_poison_nova:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_poison_debuff_nova.vpcf"
end

function modifier_aghsfort2_venomancer_poison_nova:GetStatusEffectName()
	return "particles/status_fx/status_effect_poison_venomancer.vpcf"
end

function modifier_aghsfort2_venomancer_poison_nova:OnCreated(kv)
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	-- self.slow = 0
	if IsServer() then
		self.damage_table = {
			victim = self.parent,
			attacker = self.caster,
			damage = 0,
			damage_type = self.ability:GetAbilityDamageType(),
			ability = self.ability,
		}
		-- 这里确保之后计数正确
		self:SetStackCount(-1)
	end
	self:updateData(kv)
	if IsServer() then
		self:StartIntervalThink(1.0)
		self:OnIntervalThink()
	end
end
function modifier_aghsfort2_venomancer_poison_nova:OnRefresh(kv)
	self:updateData(kv)
	if IsServer() then
		self:StartIntervalThink(1.0)
		self:OnIntervalThink()
	end
end

function modifier_aghsfort2_venomancer_poison_nova:OnIntervalThink()
	if IsServer() then
		self:dealDamage()
	end
end

function modifier_aghsfort2_venomancer_poison_nova:OnDestroy()
	if IsServer() then
	end
end
function modifier_aghsfort2_venomancer_poison_nova:DeclareFunctions()
	return {
	}
end
function modifier_aghsfort2_venomancer_poison_nova:updateData(kv)
	if IsServer() then
		self.damage_base = self.ability:GetSpecialValueFor("damage")
		-- self.damage_table.damage = self.damage_base

		if IsValid(self.ability.shard_all) then
			IncreaseStack({
				modifier = self,
				duration = kv.duration,
				destroy_no_layer = 0,
				stacks = 1
			})
		end
	end
end
function modifier_aghsfort2_venomancer_poison_nova:dealDamage()
	if IsValid(self.parent) then
		self.damage_table.damage = self.damage_base

		if IsValid(self.ability.shard_worse) then
			self.damage_table.damage = self.damage_table.damage + self.damage_base * self.parent:GetHealthPercent() * 0.01 * self.ability.shard_worse:GetSpecialValueFor("damage_mul")
		end

		if IsValid(self.ability.shard_all) then
			self.damage_table.damage = self.damage_table.damage + self.damage_table.damage * self.ability.shard_all:GetSpecialValueFor("stack_mul") * (self:GetStackCount())
		end

		if IsEnemy(self.caster, self.parent) then
			if not self.parent:IsMagicImmune() then
				-- print(self.damage_table.attacker:GetName())
				SendOverheadEventMessage(
					nil,
					OVERHEAD_ALERT_BONUS_SPELL_DAMAGE,
					self.parent,
					self.damage_table.damage,
					nil
				)
				ApplyDamage(self.damage_table)
			end
		else
			SendOverheadEventMessage(
				nil,
				OVERHEAD_ALERT_HEAL,
				self.parent,
				self.damage_table.damage,
				nil
			)
			self.parent:Heal(self.damage_table.damage, self.ability)
		end
	end
end
