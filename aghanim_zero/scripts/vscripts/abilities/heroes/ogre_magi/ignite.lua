LinkLuaModifier( "modifier_aghsfort_ogre_magi_ignite", "abilities/heroes/ogre_magi/ignite.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if aghsfort_ogre_magi_ignite == nil then
	aghsfort_ogre_magi_ignite = class({})
end
function aghsfort_ogre_magi_ignite:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	self.start_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_ignite_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.start_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_toss", Vector(0,0,0), true)
	return true
end

function aghsfort_ogre_magi_ignite:OnAbilityPhaseInterrupted()
	if self.start_pfx then
		ParticleManager:DestroyParticle(self.start_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.start_pfx)
	end
end

function aghsfort_ogre_magi_ignite:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()

	if self.start_pfx then
		ParticleManager:DestroyParticle(self.start_pfx, true)
		ParticleManager:ReleaseParticleIndex(self.start_pfx)
	end

	if IsValid(target) then
		self:doAction({
			caster = caster,
			target = target,
		})
		local pos = self:GetCaster():GetAbsOrigin()
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, self:GetCastRange(pos, nil), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags() + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)

		local targets = self:GetSpecialValueFor("targets") + GetTalentValue(self:GetCaster(), "ogre_magi_ignite+target") - 1
		for _, enemy in pairs(enemies) do
			if targets <= 0 then
				break
			end
			if enemy ~= target and not enemy:HasModifier("modifier_aghsfort_ogre_magi_ignite") then
				self:doAction({
					caster = caster,
					target = enemy,
				})
				targets = targets - 1
			end
		end
		for _, enemy in pairs(enemies) do
			if targets <= 0 then
				break
			end
			self:doAction({
				caster = caster,
				target = enemy,
			})
			targets = targets - 1
		end
	end
end

function aghsfort_ogre_magi_ignite:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

    EmitSoundOnLocationWithCaster(vLocation, "Hero_OgreMagi.Ignite.Target", nil)
	if IsValid(hTarget) then
		local ignite_mod = hTarget:FindModifierByName("modifier_aghsfort_ogre_magi_ignite")
		if IsValid(ignite_mod) then
			ignite_mod:SetDuration(ignite_mod:GetRemainingTime() + duration, true)
		else
			hTarget:AddNewModifier(caster, self, "modifier_aghsfort_ogre_magi_ignite", {duration = duration})
		end
	end
	if IsValid(self.shard_ground) then
		self.shard_ground:doAction({
			pos = vLocation,
			duration = duration
		})
	end
end

function aghsfort_ogre_magi_ignite:doAction(kv)
	local caster = kv.caster
	local target = kv.target

	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )

	if IsValid(target) then
		local projectile_info = {
			Target = target,
			Source = caster,
			Ability = self,	
			
			EffectName = "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite.vpcf",
			iMoveSpeed = projectile_speed,
			bDodgeable = true,    
		}
		ProjectileManager:CreateTrackingProjectile(projectile_info)
		EmitSoundOn( "Hero_OgreMagi.Ignite.Cast", caster )
	end
end
---------------------------------------------------------------------
--Modifiers
if modifier_aghsfort_ogre_magi_ignite == nil then
	modifier_aghsfort_ogre_magi_ignite = class({})
end
function modifier_aghsfort_ogre_magi_ignite:IsDebuff()
	return true
end

function modifier_aghsfort_ogre_magi_ignite:GetEffectName()
	return "particles/units/heroes/hero_ogre_magi/ogre_magi_ignite_debuff.vpcf"
end

function modifier_aghsfort_ogre_magi_ignite:OnCreated(kv)
	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	self.parent = self:GetParent()
	self.team = self.caster:GetTeamNumber()
	if IsServer() then
		self.damage = 0
		self.damage_table = {
			victim = self.parent,
			attacker = self.caster,
			damage = 0,
			damage_type = self.ability:GetAbilityDamageType(),
			ability = self.ability,
			damage_category = DOTA_DAMAGE_CATEGORY_SPELL
		}
	end
	self:SetHasCustomTransmitterData(true)
	self:updateData(kv)
	self:OnIntervalThink()
	self:StartIntervalThink(1.0)
end
function modifier_aghsfort_ogre_magi_ignite:OnRefresh(kv)
	if IsServer() then
		print("ignite refreshed!")
	end
	self:updateData(kv)
end
function modifier_aghsfort_ogre_magi_ignite:OnDestroy()
	if IsServer() then
		if IsValid(self.ability.shard_splash) then
			self.ability.shard_splash:stopAction({
				target = self.parent
			})
		end
	end
end
function modifier_aghsfort_ogre_magi_ignite:OnIntervalThink()
	if IsServer() then
		self.damage_table.damage = self.damage
		if IsValid(self.ability.shard_stack) then
			self.damage_table.damage = self.damage_table.damage + self:GetRemainingTime() * self.ability.shard_stack:GetSpecialValueFor("duration_mul") * self.damage
		end
		ApplyDamage(self.damage_table)
	end
end
function modifier_aghsfort_ogre_magi_ignite:AddCustomTransmitterData()
	return {
		slow = self.slow
	}
end
function modifier_aghsfort_ogre_magi_ignite:HandleCustomTransmitterData(data)
	self.slow = data.slow
end

function modifier_aghsfort_ogre_magi_ignite:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end
function modifier_aghsfort_ogre_magi_ignite:GetModifierMoveSpeedBonus_Percentage()
	-- if IsServer() then
	-- 	return RescaleSlowUnderResist(self.parent, self.slow)
	-- end
	return self.slow
end

function modifier_aghsfort_ogre_magi_ignite:updateData(kv)
	if IsServer() then
		self.slow = self.ability:GetSpecialValueFor("slow_movement_speed_pct")
		self.slow = RescaleSlowUnderResist(self.parent, self.slow)
		-- print("slow:"..self.slow)
		self:SendBuffRefreshToClients()

		self.damage =  self.ability:GetSpecialValueFor("burn_damage") + GetTalentValue(self.caster, "ogre_magi_ignite+damage")

		if IsValid(self.ability.shard_splash) then
			self.ability.shard_splash:doAction({
				target = self.parent
			})
		end
	end
end
