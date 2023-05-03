LinkLuaModifier( "modifier_aghsfort2_venomancer_chimera_botany", "abilities/heroes/venomancer/chimera_botany.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if aghsfort2_venomancer_chimera_botany == nil then
	aghsfort2_venomancer_chimera_botany = class({})
end

function aghsfort2_venomancer_chimera_botany:OnUpgrade()
	if not IsValid(self.sting) then
		self.sting = self:GetCaster():FindAbilityByName("aghsfort2_venomancer_poison_sting")
	end
end

function aghsfort2_venomancer_chimera_botany:GetAOERadius()
	return self:GetSpecialValueFor("aoe")
end

function aghsfort2_venomancer_chimera_botany:OnSpellStart()
	local caster = self:GetCaster()
	local pos = caster:GetCursorPosition()

	self:doAction({
		caster = caster,
		pos = pos
	})
end

function aghsfort2_venomancer_chimera_botany:doAction(kv)
	local caster = kv.caster
	local pos = kv.pos
	local radius = self:GetAOERadius()
	local duration = self:GetSpecialValueFor("duration")
	local power_mul = self:GetSpecialValueFor("power_mul")
	local as_bonus = self:GetSpecialValueFor("ward_as") - 100

	local units = FindUnitsInRadius(caster:GetTeamNumber(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_OTHER  , DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

	local count = 0
	local hp = 0
	local atk = 0
	for _, unit in pairs(units) do
		if IsValid(unit) and unit:GetUnitName() == "npc_dota_venomancer_plague_ward_1_aghs2" then
			count = count + 1
			hp = hp + unit:GetBaseMaxHealth()
			atk = atk + unit:GetBaseDamageMax() + unit:GetBaseDamageMin()
			unit:Kill(self, caster)
		end
	end
	hp = hp * power_mul
	atk = atk * 0.5 * power_mul
	print("sacrificed "..count.." plague wards!")
	print("hp:"..hp)
	local delay = self:GetSpecialValueFor("spawn_delay")

	
	if count > 0 then
		Timers:CreateTimer(delay, function()
			CreateUnitByNameAsync("npc_aghs2_venomancer_chimera_ward", pos, true, caster, caster, caster:GetTeamNumber(), function (ward)
				ward:SetBaseMaxHealth(hp)
				ward:AddNewModifier(caster, self, "modifier_aghsfort2_venomancer_plague_ward", {damage = atk, as_bonus = as_bonus})
				ward:AddNewModifier(caster, self, "modifier_aghsfort2_venomancer_chimera_botany", {count = count})
				if IsValid(self.sting) then
					self.sting:setApplier({
						target = ward
					})
				end
				ward:SetControllableByPlayer(caster:GetPlayerID(), true)
				ward:AddNewModifier(caster, self, "modifier_kill", {
					duration = duration
				})
				if IsValid(self.shard_nova) then
					self.shard_nova:doAction({
						bWard = false,
						target = ward,
					})
				end
				-- 这里应该是kv里不设置，这样在创建时才可以改
				if IsValid(self.shard_move) then
					print("ground move!")
					self.shard_move:doAction({
						target = ward,
					})
				else
					ward:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
				end

				EmitSoundOnLocationWithCaster(pos, "Hero_Venomancer.Plague_Ward", nil)
			end)
			return nil
		end)
	end

	self:playEffects({
		pos = pos,
		radius = radius
	})
end

function aghsfort2_venomancer_chimera_botany:playEffects(kv)
	local pos = kv.pos
	local radius = kv.radius
		-- Create Particle
		local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_pugna/pugna_netherblast.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl(pfx, 0, pos)
		ParticleManager:SetParticleControl( pfx, 1, Vector( radius, 0, 0 ) )
		ParticleManager:ReleaseParticleIndex( pfx )

		EmitSoundOnLocationWithCaster(pos, "Hero_Pugna.NetherBlast", nil)
end

---------------------------------------------------------------------
--Modifiers
if modifier_aghsfort2_venomancer_chimera_botany == nil then
	modifier_aghsfort2_venomancer_chimera_botany = class({})
end
function modifier_aghsfort2_venomancer_chimera_botany:OnCreated(kv)
	self.parent = self:GetParent()
	self.team = self.parent:GetTeamNumber()
	if IsServer() then
		self.multi_attacking = false
	end
	self:updateData(kv)
end
function modifier_aghsfort2_venomancer_chimera_botany:OnRefresh(kv)
	if IsServer() then
	end
	self:updateData(kv)
end
function modifier_aghsfort2_venomancer_chimera_botany:OnDestroy()
	if IsServer() then
	end
end
function modifier_aghsfort2_venomancer_chimera_botany:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK,
	}
end
function modifier_aghsfort2_venomancer_chimera_botany:OnAttack(event)
    if IsServer() then
        if not self.multi_attacking and IsValid(event.attacker) and event.attacker == self.parent and not event.no_attack_cooldown then
			local count = self:GetStackCount() - 1
			if count < 1 then
				return
			end
			local radius = self.parent:Script_GetAttackRange()
			-- print("multi atk search radius:"..radius)
            local enemies = FindUnitsInRadius(self.team, self.parent:GetAbsOrigin(), nil, radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
            -- local num = 0
			if #enemies > 0 then
				local id = 1
				self.multi_attacking = true
				for i = 1, count, 1 do
					self.parent:PerformAttack(enemies[id], true, true, true, true, true, false, false)
					id = id + 1
					if id > #enemies then
						ShuffledList(enemies)
						id = 1
					end
				end
				self.multi_attacking = false
			end
		end
	end
end
function modifier_aghsfort2_venomancer_chimera_botany:updateData(kv)
	if IsServer() then
		self:SetStackCount(kv.count or 1)
	end
end
