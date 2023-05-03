LinkLuaModifier( "modifier_aghsfort_lion_impale_air", "abilities/heroes/lion/impale", LUA_MODIFIER_MOTION_BOTH )
--Abilities
aghsfort_lion_impale = {}

function aghsfort_lion_impale:Spawn()
	self._secondary_dmg = 0
end
function aghsfort_lion_impale:OnUpgrade()
	self.caster = self:GetCaster()
    self.hex = self.caster:FindAbilityByName("aghsfort_lion_voodoo")
end

function aghsfort_lion_impale:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local pos = self:GetCursorPosition()
	if IsValid(target) then
		pos = target:GetAbsOrigin()

		if IsValid(self.hex) and IsValid(self.hex.shard_barbecue) then
			self.hex:doAction({
				caster = caster,
				target = target,
			})
		end
	end
	local start_pos = caster:GetAbsOrigin()
	local direction = DirectionVector(pos, start_pos)
	local length = self:GetSpecialValueFor("cast_range") + self:GetSpecialValueFor("length_buffer") + caster:GetCastRangeBonus()

	-- PrintTable(self._hit_data)
	self:doAction({
		caster = caster,
		target = target,
		pos = start_pos,
		direction = direction,
		length = length,
		splitted = true,
	})

	if IsValid(self.shard_tripple) then
		self.shard_tripple:doAction({
			pos = start_pos,
			direction = direction,
			length = length
		})
	end
end

function aghsfort_lion_impale:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	local caster = EntIndexToHScript(ExtraData.caster_id)
	if IsValid(hTarget) and IsValid(caster) then
		local bSecondary = 0
		if ExtraData.thinker_id then
			local target_id = hTarget:entindex()
			if target_id == ExtraData.thinker_id then
				return
			end
			bSecondary = 1
		end
		if TriggerStandardTargetSpell(hTarget, self) then
			return
		end
		self:playEffects({
			target = hTarget
		})
	
		hTarget:AddNewModifier(caster, self, "modifier_aghsfort_lion_impale_air", {duration = ExtraData.air_time, height = ExtraData.height, bSecondary = bSecondary})
		AddModifierConsiderResist(hTarget, caster, self, "modifier_stunned", {duration = ExtraData.duration})

		if IsValid(self.shard_shred) then
			self.shard_shred:doAction({
				target = hTarget
			})
		end
		
		-- local damage_table = {
		-- 	victim = hTarget,
		-- 	attacker = caster,
		-- 	damage = ExtraData.damage,
		-- 	damage_type = self:GetAbilityDamageType(),
		-- 	ability = self,
		-- }
		-- ApplyDamage(damage_table)
	
	else
		if hTarget == nil then
			-- if ExtraData.thinker_id then
			-- 	local hit_table = self._hit_data[ExtraData.thinker_id]
			-- 	if hit_table then
			-- 		hit_table.count = hit_table.count - 1
			-- 		if hit_table.count <= 0 then
			-- 			-- print("deleted!")
			-- 			self._hit_data[ExtraData.thinker_id] = nil
			-- 		end
			-- 	end
			-- end
			ParticleManager:DestroyParticle(ExtraData.pfx, false)
		end
	end
end

function aghsfort_lion_impale:doAction(kv)
	if self:GetLevel() < 1 then
		return
	end
	local caster = kv.caster
	local team = caster:GetTeamNumber()
	local pos = kv.pos
	local direction = kv.direction
	local length = kv.length
	local thinker_id = kv.thinker_id
	local canSplit = kv.canSplit


	local speed = self:GetSpecialValueFor("speed")
	local width = self:GetSpecialValueFor("width")
	local height = self:GetSpecialValueFor("height")
	local air_time = self:GetSpecialValueFor("air_time")
	-- local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("duration")

	local thinker_duration = length / speed + 2.0

	local end_pos = pos + direction * length

	EmitSoundOnLocationWithCaster(pos, "Hero_Lion.Impale", caster)
	
	-- 这里需要交给回调事件销毁之
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_impale.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, pos)
	ParticleManager:SetParticleControl(pfx, 1, direction * speed)

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
		fStartRadius = width,
		fEndRadius = width,
		vVelocity = direction * speed,
		ExtraData = {
			thinker_id = thinker_id,
			caster_id = caster:entindex(),
			duration = duration,
			-- damage = damage,
			pfx = pfx,
			-- bSecondary = bSecondary,
			height = height,
			air_time = air_time
		}
	}
	ProjectileManager:CreateLinearProjectile(projectile_info)
	if thinker_id == nil then
		-- print(IsValid(self.shard_split))
		if IsValid(self.shard_split) then
			-- print("split!")
			if IsValid(self.shard_tripple) and canSplit then
				print("]]]]]]]]]]]]]]]]] splitted now!")
				self.shard_split:doAction({
					projectile_info = projectile_info,
					length = length,
					dir_x = direction.x,
					dir_y = direction.y,
				})
			else
				print("]]]]]]]]]]]]]]]]] already splitted!")
			end
		end
	end
end

function aghsfort_lion_impale:playEffects(kv)
	local target = kv.target
	target:EmitSound("Hero_Lion.ImpaleHitTarget")
	local pos = GetGroundPosition(target:GetAbsOrigin(), nil)
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_impale_hit_spikes.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(pfx, 0, GetGroundPosition(pos, nil))
	ParticleManager:SetParticleControl(pfx, 1, GetGroundPosition(pos, nil))
	ParticleManager:SetParticleControl(pfx, 2, GetGroundPosition(pos, nil))
	
	ParticleManager:ReleaseParticleIndex(pfx)
end

---------------------------------------------------------------------
--Modifiers
modifier_aghsfort_lion_impale_air = {}

function modifier_aghsfort_lion_impale_air:IsHidden()
	return true
end
function modifier_aghsfort_lion_impale_air:IsPurgable()
	return false
end
function modifier_aghsfort_lion_impale_air:IsPurgeException()
	return true
end
function modifier_aghsfort_lion_impale_air:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end
function modifier_aghsfort_lion_impale_air:GetMotionPriority()
	return DOTA_MOTION_CONTROLLER_PRIORITY_HIGH
end
function modifier_aghsfort_lion_impale_air:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end
function modifier_aghsfort_lion_impale_air:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
	}
end
function modifier_aghsfort_lion_impale_air:OnCreated(kv)
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	if IsServer() then
		self.damage_table = {
			victim = self.parent,
			attacker = self.caster,
			damage = 0,
			damage_type = self.ability:GetAbilityDamageType(),
			ability = self.ability,
			damage_category = DOTA_DAMAGE_CATEGORY_SPELL,
		}
	end
	self:updateData(kv)
	if IsServer() then
		if IsAbsoluteResist(self.parent) or self:ApplyVerticalMotionController() == false then
			self:Destroy()
			return
		end
	end
end
function modifier_aghsfort_lion_impale_air:OnRefresh(kv)
	if IsServer() then
		ApplyDamage(self.damage_table)
	end
	self:updateData(kv)
	if IsServer() then
	end
end
function modifier_aghsfort_lion_impale_air:OnVerticalMotionInterrupted()
	self:Destroy()
end

function modifier_aghsfort_lion_impale_air:UpdateVerticalMotion(me, dt)
	local t = self:GetRemainingTime()
	local pos = self.parent:GetAbsOrigin()
	local pt = self.air_time * 0.5 - t
	pos.z = GetGroundHeight(pos, nil) + self.height - self.alpha * pt * pt
	self.parent:SetAbsOrigin(pos)
end

function modifier_aghsfort_lion_impale_air:OnDestroy()
	if IsServer() then
		if IsValid(self.parent) and self.parent:IsAlive() then
			self.parent:RemoveVerticalMotionController(self)
			self.parent:EmitSound("Hero_Lion.ImpaleTargetLand")
			FindClearSpaceForUnit(self.parent, self.parent:GetAbsOrigin(), true)
			ApplyDamage(self.damage_table)
		end
	end
end
function modifier_aghsfort_lion_impale_air:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}
end

function modifier_aghsfort_lion_impale_air:updateData(kv)
	if IsServer() then
		self.air_time = self:GetDuration()
		if self.air_time < 0.001 then
			self.air_time = 0.1
		end
		self.height = kv.height
		self.alpha = 4 * self.height / (self.air_time * self.air_time)
		self.damage_table.damage = self.ability:GetSpecialValueFor("damage")
		if kv.bSecondary > 0 then
			self.damage_table.damage = self.damage_table.damage * self.ability._secondary_dmg
		end
	end
end
