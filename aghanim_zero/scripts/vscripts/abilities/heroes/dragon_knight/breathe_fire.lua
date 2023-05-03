aghsfort_dk_breathe_fire = {}

LinkLuaModifier( "modifier_aghsfort_dk_breathe_fire", "abilities/heroes/dragon_knight/breathe_fire", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_dk_macropyre_thinker", "abilities/heroes/dragon_knight/breathe_fire", LUA_MODIFIER_MOTION_NONE )

function aghsfort_dk_breathe_fire:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local point = self:GetCursorPosition()

	if target then point = target:GetOrigin() end

	local projectile_direction = (point - caster:GetOrigin()):Normalized()
	projectile_direction.z = 0

	local info = {
		Source = caster,
		Ability = self,
		vSpawnOrigin = caster:GetAbsOrigin(),
		bDeleteOnHit = false,
		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
		fDistance = self:GetSpecialValueFor( "range" ),
		fStartRadius = self:GetSpecialValueFor( "start_radius" ),
		fEndRadius = self:GetSpecialValueFor( "end_radius" ),
		vVelocity = projectile_direction * self:GetSpecialValueFor( "speed" ),
	}

	ProjectileManager:CreateLinearProjectile(info)

	EmitSoundOn( "Hero_DragonKnight.BreathFire", caster )

	if not IsServer() then return end

	local start = caster:GetAbsOrigin() + projectile_direction * 120
	local stop = caster:GetAbsOrigin() + projectile_direction * self:GetSpecialValueFor( "range" )
	if self:GetCaster():HasAbility("aghsfort_dk_breathe_fire_macropyre") then
		-- create thinker
		local thinker = CreateModifierThinker(
			caster, -- player source
			self, -- ability source
			"modifier_aghsfort_dk_macropyre_thinker", -- modifier name
			{
				duration = self:GetCaster():FindAbilityByName("aghsfort_dk_breathe_fire_macropyre"):GetLevelSpecialValueFor("duration",1),
				fromx = start.x,
				fromy = start.y,
				fromz = start.z,
				tox = stop.x,
				toy = stop.y,
				toz = stop.z,			
			}, -- kv
			start,
			caster:GetTeamNumber(),
			false
		)
	end
end

function aghsfort_dk_breathe_fire:OnProjectileHit( target, location )
	if not target or target:IsNull() then return end

	local damage = self:GetLevelSpecialValueFor( "damage", self:GetLevel() - 1 )
	local duration = self:GetSpecialValueFor( "duration" )

	local damageTable = {
		victim = target,
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbilityDamageType(),
		ability = self,
	}

	ApplyDamage(damageTable)

	if target and not target:IsNull() then
		target:AddNewModifier(
			self:GetCaster(),
			self,
			"modifier_aghsfort_dk_breathe_fire",
			{ duration = duration }
		)
	end

	if self:GetCaster():HasAbility("aghsfort_dk_breathe_fire_stun") and self:GetCaster():FindAbilityByName("aghsfort_dk_dragon_tail"):IsTrained() then
		local chance = self:GetCaster():FindAbilityByName("aghsfort_dk_breathe_fire_stun"):GetLevelSpecialValueFor("chance",1)
		if RollPseudoRandomPercentage( chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_1, self:GetCaster() ) == true then
			self:GetCaster():FindAbilityByName("aghsfort_dk_dragon_tail"):HitSingle(target)
		end
	end
end

modifier_aghsfort_dk_breathe_fire = {}

function modifier_aghsfort_dk_breathe_fire:IsHidden() 	return false end
function modifier_aghsfort_dk_breathe_fire:IsDebuff() 	return true end
function modifier_aghsfort_dk_breathe_fire:IsStunDebuff() return false end
function modifier_aghsfort_dk_breathe_fire:IsPurgable() 	return true end

function modifier_aghsfort_dk_breathe_fire:OnCreated( kv )
	self.reduction = self:GetAbility():GetSpecialValueFor( "reduction" )
end

function modifier_aghsfort_dk_breathe_fire:OnRefresh( kv )
	self.reduction = self:GetAbility():GetSpecialValueFor( "reduction" )	
end

function modifier_aghsfort_dk_breathe_fire:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PREATTACK_TARGET_CRITICALSTRIKE,
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_aghsfort_dk_breathe_fire:GetModifierTotalDamageOutgoing_Percentage()
	if self:GetCaster():HasAbility("special_bonus_unique_aghsfort_dk_breathe_fire") then
		return self.reduction * -1
	end
end

function modifier_aghsfort_dk_breathe_fire:GetModifierDamageOutgoing_Percentage()
	return self.reduction * -1
end


function modifier_aghsfort_dk_breathe_fire:GetEffectName()
	return "particles/items4_fx/bull_whip_enemy_debuff.vpcf"
end

function modifier_aghsfort_dk_breathe_fire:GetModifierPreAttack_Target_CriticalStrike(params)
	if not IsServer() then return end
	if self:GetCaster() == params.attacker then
		if self:GetCaster():HasAbility("aghsfort_dk_breathe_fire_crit_lifesteal") then
			local shard = self:GetCaster():FindAbilityByName("aghsfort_dk_breathe_fire_crit_lifesteal")
			local chance = shard:GetLevelSpecialValueFor("chance",1)
			local crit_mult = shard:GetLevelSpecialValueFor("crit_mult",1)

			if RollPseudoRandomPercentage( chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_2, self:GetCaster() ) == true then
				self.record = params.record
				return crit_mult
			end
		end
	end
	return 0
end

function modifier_aghsfort_dk_breathe_fire:OnAttacked( params )
	if not IsServer() then return end
	if not self.record or self:GetCaster() ~= params.attacker then return end

	self.record = nil
	local particle_cast = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf"
	local sound_cast = "Hero_PhantomAssassin.CoupDeGrace"


	-- Create Particle
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, params.target )
	ParticleManager:SetParticleControlEnt( effect_cast, 0, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetOrigin(), true )
	ParticleManager:SetParticleControl( effect_cast, 1, params.target:GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 1, -params.attacker:GetForwardVector() )
	ParticleManager:SetParticleControlEnt( effect_cast, 10, params.target, PATTACH_ABSORIGIN_FOLLOW, nil, params.target:GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( effect_cast )				

	local shard = self:GetCaster():FindAbilityByName("aghsfort_dk_breathe_fire_crit_lifesteal")

	self:GetCaster():Heal( params.damage / 100 * shard:GetLevelSpecialValueFor("lifesteal",1), self:GetAbility() )
	local nFXIndex = ParticleManager:CreateParticle( "particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex( nFXIndex )

	EmitSoundOn( "Dungeon.BloodSplatterImpact.Lesser", params.target )
end
------------------------------------------
------------------------------------------
------------------------------------------

modifier_aghsfort_dk_macropyre_thinker	= class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,		
})

function modifier_aghsfort_dk_macropyre_thinker:OnCreated( kv )
	if not IsServer() then return end

	self.caster = self:GetCaster()
	self.parent = self:GetParent()	

	self.shard_ability = self.caster:FindAbilityByName("aghsfort_dk_breathe_fire_macropyre")

	-- references
	self.radius = self.shard_ability:GetLevelSpecialValueFor( "width",1 )
	self.interval = self.shard_ability:GetLevelSpecialValueFor( "interval",1 )
	self.debuff_duration = self:GetAbility():GetLevelSpecialValueFor( "duration",1 )

	self.damage = self:GetAbility():GetLevelSpecialValueFor( "damage", self:GetAbility():GetLevel() - 1 ) * (self.shard_ability:GetLevelSpecialValueFor("damage_percent",1) / 100)

	-- ability properties
	self.abilityDamageType = self:GetAbility():GetAbilityDamageType()
	self.abilityTargetTeam = self:GetAbility():GetAbilityTargetTeam()
	self.abilityTargetType = self:GetAbility():GetAbilityTargetType()
	self.abilityTargetFlags = self:GetAbility():GetAbilityTargetFlags()
	self.ability = self:GetAbility()

	self.startpoint = Vector(kv.fromx, kv.fromy, kv.fromz)
	self.endpoint = Vector(kv.tox, kv.toy, kv.toz)

	-- Start interval
	self:StartIntervalThink( self.interval )

	-- play effects
	self:PlayEffects()
end

function modifier_aghsfort_dk_macropyre_thinker:OnDestroy()
	if not IsServer() then return end
	if self.effect_cast then
		ParticleManager:DestroyParticle(self.effect_cast, false)
		ParticleManager:ReleaseParticleIndex(self.effect_cast)
	end
	if self.effect_cast2 then
		ParticleManager:DestroyParticle(self.effect_cast2, false)
		ParticleManager:ReleaseParticleIndex(self.effect_cast2)
	end
	UTIL_Remove( self:GetParent() )
end

function modifier_aghsfort_dk_macropyre_thinker:OnIntervalThink()
	-- continuously find units in line
	local enemies = FindUnitsInLine(
		self.caster:GetTeamNumber(),	-- int, your team number
		self.startpoint,	-- point, center point
		self.endpoint,
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		self.abilityTargetType,	-- int, type filter
		self.abilityTargetFlags	-- int, flag filter
	)

	for _,enemy in pairs(enemies) do
		-- add modifier
		enemy:AddNewModifier(
			self.caster, -- player source
			self:GetAbility(), -- ability source
			"modifier_aghsfort_dk_breathe_fire", -- modifier name
			{
				duration = self.debuff_duration,
			} -- kv
		)

		local damageTable = {
			victim = enemy,
			attacker = self.caster,
			damage = self.damage,
			damage_type = self.abilityDamageType,
			ability = self.ability,
		}

		ApplyDamage(damageTable)
	end
end

function modifier_aghsfort_dk_macropyre_thinker:PlayEffects()
	-- Get Resources
	local particle_cast = "particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre_leading_after_burn.vpcf"
	local particle_cast2 = "particles/econ/items/jakiro/jakiro_ti10_immortal/jakiro_ti10_macropyre_ground_shockwave.vpcf"
		

	-- Create Particle
	self.effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self.parent )
	ParticleManager:SetParticleControl( self.effect_cast, 0, self.startpoint )
	ParticleManager:SetParticleControl( self.effect_cast, 1, self.endpoint )

	self.effect_cast2 = ParticleManager:CreateParticle( particle_cast2, PATTACH_WORLDORIGIN, self.parent )
	ParticleManager:SetParticleControl( self.effect_cast2, 0, self.startpoint )
	ParticleManager:SetParticleControl( self.effect_cast2, 1, self.endpoint )

	-- buff particle
	self:AddParticle(
		self.effect_cast,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)

	self:AddParticle(
		self.effect_cast2,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end
