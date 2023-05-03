LinkLuaModifier( "modifier_aghsfort2_venomancer_venomous_gale", "abilities/heroes/venomancer/venomous_gale.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if aghsfort2_venomancer_venomous_gale == nil then
	aghsfort2_venomancer_venomous_gale = class({})
end

function aghsfort2_venomancer_venomous_gale:GetCastRange()
	return self:GetSpecialValueFor("distance")
end

function aghsfort2_venomancer_venomous_gale:GetCooldown(iLevel)
    local cooldown = self.BaseClass.GetCooldown(self, iLevel) -
                         GetTalentValue(self:GetCaster(), "venomancer_venomous_gale-cd")
    return math.max(cooldown, 0)
end

function aghsfort2_venomancer_venomous_gale:OnSpellStart()
	local caster = self:GetCaster()
	local pos = caster:GetCursorPosition()
	local origin = caster:GetAbsOrigin()
	
	local dir_list = {DirectionVector(pos, origin)}

	if IsValid(self.shard_ring) then
		local count = self.shard_ring:GetSpecialValueFor("count")
		local delta = 360.0 / count
		for i = 1, count - 1 do
			table.insert(dir_list, RotatePosition(Vector(0,0,0), QAngle(0, delta * i, 0), dir_list[1]))
		end
	end

	self:doAction({
		caster = caster,
		pos = origin,
		-- dir = DirectionVector(pos, origin),
		dir_list = dir_list
	})
end

function aghsfort2_venomancer_venomous_gale:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	local thinker = EntIndexToHScript(ExtraData.thinker_id)
	local caster = EntIndexToHScript(ExtraData.caster_id)
	if IsValid(hTarget) and IsValid(thinker) and IsValid(caster) then
		-- print(hTarget:GetName())
		local target_id = hTarget:entindex()
		if thinker._hit_table[target_id] then
			return
		end
		thinker._hit_table[target_id] = true

		print("hit!"..hTarget:GetUnitName())

		self:playEffects({
			target = hTarget
		})

		if IsValid(self.shard_ward) then
			self.shard_ward:doAction({
				caster = caster,
				target = hTarget
			})
		end

		if IsValid(self.shard_atk) then
			caster:PerformAttack(hTarget, true, true, true, false, true, false, false)
		end

		hTarget:AddNewModifier(caster, self, "modifier_aghsfort2_venomancer_venomous_gale", {
			damage = ExtraData.damage,
			-- interval = ExtraData.interval,
			duration = ExtraData.duration,
		})
	
	else
		if hTarget == nil then
			ParticleManager:DestroyParticle(ExtraData.pfx, false)
		end
	end
end

function aghsfort2_venomancer_venomous_gale:doAction(kv)
	if self:GetLevel() < 1 then
		return
	end
	local caster = kv.caster
	local team = caster:GetTeamNumber()
	local dir_list = kv.dir_list
	local pos = kv.pos

	local radius = self:GetSpecialValueFor("radius")
	local length = self:GetSpecialValueFor("distance") + caster:GetCastRangeBonus()
	local speed = self:GetSpecialValueFor("speed")
	local thinker_duration = length / speed + 1.0
	local duration = self:GetSpecialValueFor("duration")
	local damage = self:GetSpecialValueFor("strike_damage")
	-- local interval = self:GetSpecialValueFor("tick_interval")

	local gale_thinker =  CreateModifierThinker(caster, self, "modifier_dummy_thinker", {duration = thinker_duration}, pos, team, false)
	gale_thinker._hit_table = {}

	gale_thinker:EmitSound("Hero_Venomancer.VenomousGale")
	
	for _, dir in pairs(dir_list) do
		
		-- 这里需要交给回调事件销毁之
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_venomous_gale.vpcf", PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(pfx, 0, pos)
		ParticleManager:SetParticleControl(pfx, 1, dir * speed)
		
		local projectile_info = {
			Source = caster,
			Ability = self,
			vSpawnOrigin = pos,
			-- EffectName = "particles/units/heroes/hero_lion/lion_spell_impale.vpcf",
			bDeleteOnHit = false,
			iUnitTargetTeam = self:GetAbilityTargetTeam(),
			iUnitTargetFlags = self:GetAbilityTargetFlags(),
			iUnitTargetType = self:GetAbilityTargetType(),
			fDistance = length,
			fStartRadius = radius,
			fEndRadius = radius,
			vVelocity = dir * speed,
			ExtraData = {
				thinker_id = gale_thinker:entindex(),
				caster_id = caster:entindex(),
				duration = duration,
				damage = damage,
				-- interval = interval,
				pfx = pfx,
			}
		}
		ProjectileManager:CreateLinearProjectile(projectile_info)
	end

end

function aghsfort2_venomancer_venomous_gale:playEffects(kv)
	local target = kv.target
	target:EmitSound("Hero_Venomancer.ProjectileImpact")
	local pos = GetGroundPosition(target:GetAbsOrigin(), nil)
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_venomancer/venomancer_venomous_gale_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	
	ParticleManager:ReleaseParticleIndex(pfx)
end

---------------------------------------------------------------------
--Modifiers
if modifier_aghsfort2_venomancer_venomous_gale == nil then
	modifier_aghsfort2_venomancer_venomous_gale = class({})
end

function modifier_aghsfort2_venomancer_venomous_gale:IsPurgable()
	return true
end

function modifier_aghsfort2_venomancer_venomous_gale:GetEffectName()
	return "particles/units/heroes/hero_venomancer/venomancer_gale_poison_debuff.vpcf"
end

function modifier_aghsfort2_venomancer_venomous_gale:OnCreated(kv)
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	self.tick_mul = 10
	-- self.slow = 0
	if IsServer() then
		self.damage_table = {
			victim = self.parent,
			attacker = self.caster,
			damage = kv.damage,
			damage_type = self.ability:GetAbilityDamageType(),
			ability = self.ability,
		}
		ApplyDamage(self.damage_table)
	end
	if IsValid(self) then
		self:SetHasCustomTransmitterData(true)
		self:updateData(kv)
		self:StartIntervalThink(self.interval / self.tick_mul)
	end
end
function modifier_aghsfort2_venomancer_venomous_gale:AddCustomTransmitterData()
	return {
		slow = self.slow
	}
end

function modifier_aghsfort2_venomancer_venomous_gale:HandleCustomTransmitterData(data)
	self.slow = data.slow
	-- print("slow:"..self.slow)
end

function modifier_aghsfort2_venomancer_venomous_gale:OnRefresh(kv)
	if IsServer() then
	end
	self:updateData(kv)
end
function modifier_aghsfort2_venomancer_venomous_gale:OnDestroy()
	if IsServer() then
	end
end
function modifier_aghsfort2_venomancer_venomous_gale:OnIntervalThink()
	self.slow = math.min(self.slow + 1, 0)
	self.ticks = self.ticks + 1
	if self.ticks >= self.tick_mul then
		self.ticks = 0
		if IsServer() then
			ApplyDamage(self.damage_table)
			if IsValid(self.parent) then
				SendOverheadEventMessage(
					nil,
					OVERHEAD_ALERT_BONUS_POISON_DAMAGE,
					self.parent,
					self.damage_table.damage,
					nil
				)
			end
		end
	end
end

function modifier_aghsfort2_venomancer_venomous_gale:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_aghsfort2_venomancer_venomous_gale:GetModifierMoveSpeedBonus_Percentage()
	-- if IsClient() then
	-- 	print("slow:"..self.slow)
	-- end
	return self.slow
end

function modifier_aghsfort2_venomancer_venomous_gale:updateData(kv)
	self.interval = self.ability:GetSpecialValueFor("tick_interval")
	self.ticks = 0
	
	if IsServer() then
		self.slow = self.ability:GetSpecialValueFor("movement_slow")
		self.slow = RescaleSlowUnderResist(self.parent, self.slow)
		self:SendBuffRefreshToClients()

		self.damage_table.damage = self.ability:GetSpecialValueFor("tick_damage")
	end
end
