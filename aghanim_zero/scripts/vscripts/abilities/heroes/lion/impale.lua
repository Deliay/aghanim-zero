LinkLuaModifier( "modifier_aghsfort_lion_impale_air", "abilities/heroes/lion/impale", LUA_MODIFIER_MOTION_BOTH )
--Abilities
aghsfort_lion_impale = {}

function aghsfort_lion_impale:GetCooldown(iLevel)
    local cooldown = self.BaseClass.GetCooldown(self, iLevel) -
                         GetTalentValue(self:GetCaster(), "lion_impale-cd")
    return math.max(cooldown, 0)
end

function aghsfort_lion_impale:GetCastRange()
	return self:GetSpecialValueFor("cast_range") + GetTalentValue(self:GetCaster(), "lion_impale+range")
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
	local length = self:GetSpecialValueFor("cast_range") + self:GetSpecialValueFor("length_buffer") + caster:GetCastRangeBonus() + GetTalentValue(caster, "lion_impale+range")

	self:doAction({
		caster = caster,
		target = target,
		pos = start_pos,
		direction = direction,
		length = length,
	})

	if IsValid(self.shard_tripple) then
		self.shard_tripple:doAction({
			pos = start_pos,
			direction = direction,
			length = length
		})
	end
end

function aghsfort_lion_impale:OnProjectileThink_ExtraData(vLocation, ExtraData)
	if ExtraData.bSecondary and ExtraData.bSecondary == 0 then
		local thinker = EntIndexToHScript(ExtraData.thinker_id)
		if IsValid(thinker) then
			thinker:SetAbsOrigin(vLocation)
		end
	end
end

function aghsfort_lion_impale:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	local thinker = EntIndexToHScript(ExtraData.thinker_id)
	local caster = EntIndexToHScript(ExtraData.caster_id)
	if IsValid(hTarget) and IsValid(thinker) and IsValid(caster) then
		-- print(hTarget:GetName())
		local target_id = hTarget:entindex()
		if thinker._hit_table[target_id] then
			return
		end
		thinker._hit_table[target_id] = true
		if TriggerStandardTargetSpell(hTarget, self) then
			return
		end
		self:playEffects({
			target = hTarget
		})

	
		local air_time = 0.5
		local height = 350
		hTarget:AddNewModifier(caster, self, "modifier_aghsfort_lion_impale_air", {duration = air_time, height = height})
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
	local bSecondary = 0
	if thinker_id then
		bSecondary = 1
	end

	local speed = self:GetSpecialValueFor("speed")
	local width = self:GetSpecialValueFor("width")
	-- local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("duration")

	local thinker_duration = length / speed + 1.0

	local end_pos = pos + direction * length

	local spike_thinker = nil
	if bSecondary ~= 0 then
		spike_thinker = EntIndexToHScript(thinker_id)
		local thinker_mod = spike_thinker:FindModifierByName("modifier_dummy_thinker")
		thinker_mod:SetDuration(math.max(thinker_mod:GetRemainingTime(), thinker_duration), false)
	else
		spike_thinker = CreateModifierThinker(caster, self, "modifier_dummy_thinker", {duration = thinker_duration}, pos, team, false)
		spike_thinker._hit_table = {}
	end
	spike_thinker:EmitSound("Hero_Lion.Impale")
	
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
			thinker_id = spike_thinker:entindex(),
			caster_id = caster:entindex(),
			duration = duration,
			-- damage = damage,
			pfx = pfx,
			bSecondary = bSecondary
		}
	}
	ProjectileManager:CreateLinearProjectile(projectile_info)
	if bSecondary == 0 then
		-- print(IsValid(self.shard_split))
		if IsValid(self.shard_split) then
			-- print("split!")
			self.shard_split:doAction({
				projectile_info = projectile_info,
				length = length,
				dir_x = direction.x,
				dir_y = direction.y,
			})
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
	end
end
