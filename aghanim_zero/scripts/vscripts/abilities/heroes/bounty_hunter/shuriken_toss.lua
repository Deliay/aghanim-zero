LinkLuaModifier( "modifier_aghsfort_bounty_hunter_shuriken_toss", "abilities/heroes/bounty_hunter/shuriken_toss.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if aghsfort_bounty_hunter_shuriken_toss == nil then
	aghsfort_bounty_hunter_shuriken_toss = class({})
end
function aghsfort_bounty_hunter_shuriken_toss:GetIntrinsicModifierName()
	return "modifier_aghsfort_bounty_hunter_shuriken_toss"
end

function aghsfort_bounty_hunter_shuriken_toss:OnUpgrade()
	if not(IsValid(self.track)) then
		self.track = self:GetCaster():FindAbilityByName("aghsfort_bounty_hunter_track")
	end
	if not(IsValid(self.jinada)) then
		self.jinada = self:GetCaster():FindAbilityByName("aghsfort_bounty_hunter_jinada")
	end
end

function aghsfort_bounty_hunter_shuriken_toss:GetCastRange()
	return self:GetSpecialValueFor("range")
end

function aghsfort_bounty_hunter_shuriken_toss:OnSpellStart()
	local hCaster = self:GetCaster()
	local hTarget = self:GetCursorTarget()
	if IsValid(hTarget) then
		self:doAction({
			caster = hCaster,
			target = hTarget,
		})
		if IsValid(self.shard_tripple) then
			local radius = self.shard_tripple:GetSpecialValueFor("search_radius")
			local num =  self.shard_tripple:GetSpecialValueFor("max_toss")
			local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), hTarget:GetAbsOrigin(), nil, radius , self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)

			print("multiple:"..num.." to "..#enemies.." in "..radius)
			for i = 1, math.min(#enemies, num) do
				if enemies[i] ~= hTarget then
					self:doAction({
						caster = hCaster,
						target = enemies[i],
					})
				end
			end
		end
	end
end
-- Server Only
function aghsfort_bounty_hunter_shuriken_toss:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	local hCaster = self:GetCaster()
	local tossed_table = ExtraData
	if tossed_table == nil then
		tossed_table = {}
		-- print("no table")
	end

	if  IsValid(hTarget) and hTarget:IsAlive() then
		if IsValid(self.shard_track) and IsValid(self.track) then
			if not hTarget:HasModifier("modifier_aghsfort_bounty_hunter_track") then			
				self.track:doAction({
					caster = hCaster,
					target = hTarget,
					bEffect = false
				})
			end
		end

		if IsValid(self.shard_jinada) and IsValid(self.jinada) then
			self.jinada:doAction({
				target = hTarget,
				caster = hCaster,
				bDamage = true
			})
		end
		local damage_table = {
			victim = hTarget,
			attacker = hCaster,
			damage = self:GetSpecialValueFor("bonus_damage") + GetTalentValue(hCaster, "aghsfort_bounty_hunter_shuriken_toss+damage"),
			damage_type = self:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
			ability = self,
		}
		ApplyDamage(damage_table)
		EmitSoundOn("Hero_BountyHunter.Shuriken.Impact", hTarget)
		hTarget:AddNewModifier(hCaster, self, "modifier_stunned", {
			duration = self:GetSpecialValueFor("ministun")
		})

		-- bounce table regist
		-- print("hit!")
		-- PrintTable(tossed_table)

		-- 这里Extradata在传过去后键值会自动转成str，所以统一转了
		local target_id = tostring(hTarget:entindex())
		if tossed_table[target_id] == nil then
			tossed_table[target_id] = 0
			-- print("first hit："..target_id)
		end
		tossed_table[target_id] = tossed_table[target_id] + 1
		-- print("checked!"..Time())
		-- PrintTable(tossed_table)
	end

	local enemies = FindUnitsInRadius(hCaster:GetTeamNumber(), vLocation, nil, self:GetSpecialValueFor("bounce_aoe"),
	DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE,
	FIND_ANY_ORDER, false)

	local bounce_times = 1
	if IsValid(self.shard_jinada) then
		bounce_times = self.shard_jinada:GetSpecialValueFor("bounce_times")
		-- print("bounces:"..bounce_times)
	end

	for _, enemy in pairs(enemies) do
		-- print(enemy:GetName())
		if enemy ~= hTarget and enemy:HasModifier("modifier_aghsfort_bounty_hunter_track") then
			local enemy_id = tostring(enemy:entindex())
			if tossed_table[enemy_id] == nil or tossed_table[enemy_id] < bounce_times then
				local projectile_info = {
					Target = enemy,
					-- Source = hCaster,
					Ability = self,
					EffectName = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf",
					iMoveSpeed = self:GetSpecialValueFor("speed"),
					vSourceLoc= vLocation,
					bDrawsOnMinimap = false,
					bDodgeable = true,
					bIsAttack = false,
					bVisibleToEnemies = true,
					bReplaceExisting = false,
					bProvidesVision = false,
					ExtraData = tossed_table
				}
				ProjectileManager:CreateTrackingProjectile(projectile_info)
				-- EmitSoundOn("Hero_BountyHunter.Shuriken", hTarget)
				EmitSoundOnLocationWithCaster(vLocation, "Hero_BountyHunter.Shuriken", hCaster)
				break
			end
		end
	end
end
	-- Server Only
function aghsfort_bounty_hunter_shuriken_toss:doAction(kv)
	if self:GetLevel() > 0 then	
		local target = kv.target
		local caster = kv.caster
		local tossed_table = {}

		-- 这里Extradata在传过去后键值会自动转成str，所以统一转了
		local target_id = tostring(target:entindex())

		tossed_table[target_id] = 0
		local projectile_info = {
			Target = target,
			Source = caster,
			Ability = self,
			EffectName = "particles/units/heroes/hero_bounty_hunter/bounty_hunter_suriken_toss.vpcf",
			iMoveSpeed = self:GetSpecialValueFor("speed"),
			vSourceLoc= caster:GetAbsOrigin(),
			bDrawsOnMinimap = false,
			bDodgeable = true,
			bIsAttack = false,
			bVisibleToEnemies = true,
			bReplaceExisting = false,
			bProvidesVision = false,
			ExtraData = tossed_table
		}
		ProjectileManager:CreateTrackingProjectile(projectile_info)
		EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Hero_BountyHunter.Shuriken", caster)
	end
end
---------------------------------------------------------------------
--Modifiers
if modifier_aghsfort_bounty_hunter_shuriken_toss == nil then
	modifier_aghsfort_bounty_hunter_shuriken_toss = class({})
end
function modifier_aghsfort_bounty_hunter_shuriken_toss:IsHidden()
	return true
end

function modifier_aghsfort_bounty_hunter_shuriken_toss:OnCreated(params)
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	if IsServer() then
		self:StartIntervalThink(1)
	end
end
function modifier_aghsfort_bounty_hunter_shuriken_toss:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_aghsfort_bounty_hunter_shuriken_toss:OnDestroy()
	if IsServer() then
	end
end
function modifier_aghsfort_bounty_hunter_shuriken_toss:OnIntervalThink()
	if IsServer() then
		local charges = GetTalentValue(self.parent, "aghsfort_bounty_hunter_shuriken_toss+charge")
		if charges > 0 then
            AbilityChargeController:AbilityChargeInitialize(self.ability, self.ability:GetCooldown(self.ability:GetLevel()), charges, 1, true, true)
		end
	end
end
function modifier_aghsfort_bounty_hunter_shuriken_toss:DeclareFunctions()
	return {
	}
end