LinkLuaModifier( "modifier_aghsfort_ogre_magi_multicast", "abilities/heroes/ogre_magi/multicast", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_ogre_magi_multicast_proc", "abilities/heroes/ogre_magi/multicast", LUA_MODIFIER_MOTION_NONE )
--Abilities
if aghsfort_ogre_magi_multicast == nil then
	aghsfort_ogre_magi_multicast = class({})
end
function aghsfort_ogre_magi_multicast:GetIntrinsicModifierName()
	return "modifier_aghsfort_ogre_magi_multicast"
end

function aghsfort_ogre_magi_multicast:Init()
    self.ability_exceptions = {
		-- Game
        ["ability_aghsfort_capture"] = true,
        ["aghsfort_aziyog_underlord_portal_warp"] = true,
        ["ability_capture"] = true,
		-- Item
		-- ["item_refresher"] = true,
		["item_dust"] = true,
		["item_health_potion"] = true,
		["item_mana_potion"] = true,
		["item_bag_of_gold"] = true,
		["item_bag_of_gold2"] = true,
		["item_quest_star"] = true,
		["item_arcane_fragments"] = true,
		["item_power_treads"] = true,
		["item_vambrace"] = true,
		["item_small_scepter_fragment"] = true,
		["item_battle_points"] = true,
		["item_tombstone"] = true,
		["item_treasure_box"] = true,
		["item_life_rune"] = true,
		["item_bottle"] = true,
		["item_ring_of_aquila"] = true,
		["item_moon_shard"] = true,
		["item_magic_stick"] = true,
		["item_magic_wand"] = true,
		["item_holy_locket"] = true,
		["item_urn_of_shadows"] = true,
		["item_meteor_hammer"] = true,	-- 这个有地板但是没效果
		-- Heroes
		["aghsfort_tusk_launch_snowball"] = true,
		["enigma_black_hole"] = true,
		-- ["aghsfort_enigma_black_hole"] = true,
    }
	self.ability_same_target = {
		["aghsfort_ogre_magi_fireblast"] = true, 
		["aghsfort_ogre_magi_unrefined_fireblast"] = true, 
	}
	self.ability_target_custom = {
	}
	self.ability_as_consumable = {
		["item_ancient_janggo"] = true,
		["item_boots_of_bearing"] = true,
	}
	self.consume_charge_except = {
		-- ["item_purification_potion"] = 0,
	}
	self._level = 0
end

function aghsfort_ogre_magi_multicast:rollMulticast(kv)
	local caster = kv.caster
	
	local max_casts = self:GetLevel() + 1
	if IsValid(self.shard_five) then
		max_casts = max_casts + 1
	end
	print(max_casts)


	local chances = {}
	for i = 2, max_casts do
		chances[i] = self:GetLevelSpecialValueFor("multicast_"..i.."_times", max_casts - 1)
	end
	for i = max_casts, 2, -1 do
		if RollPseudoRandomPercentage(chances[i], DOTA_PSEUDO_RANDOM_CUSTOM_GAME_4, caster) == true then
			return i - 1
		end
	end
	return 0
end
function aghsfort_ogre_magi_multicast:doAction(kv)
	if self:GetLevel() < 1 then
		return
	end
	local ability = kv.ability
	local caster = kv.caster
	local target = kv.target
	local pos = kv.pos
	if self.ability_exceptions[ability:GetName()] then
		print("ability in blacklist, no multicasting...")
		return
	end
	local modifier_table = {
		ability_id = ability:entindex(),
		duration = 5,
	}
	if pos then	
		modifier_table.pos_x = pos.x
		modifier_table.pos_y = pos.y
		modifier_table.pos_z = pos.z
	end
	if IsValid(target) then
		modifier_table.target_id = target:entindex()
	end
	modifier_table.casts = self:rollMulticast({caster = caster})
	if modifier_table.casts > 0 then
		caster:AddNewModifier(self:GetCaster(), self, "modifier_aghsfort_ogre_magi_multicast_proc", modifier_table)
	end
end
---------------------------------------------------------------------
--Modifiers
if modifier_aghsfort_ogre_magi_multicast == nil then
	modifier_aghsfort_ogre_magi_multicast = class({})
end
function modifier_aghsfort_ogre_magi_multicast:OnCreated(kv)
	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	self.parent = self:GetParent()
	if IsServer() then
		-- print(self.parent:GetName())
	end
end
function modifier_aghsfort_ogre_magi_multicast:OnRefresh(kv)
	if IsServer() then
	end
end
function modifier_aghsfort_ogre_magi_multicast:OnDestroy()
	if IsServer() then
	end
end
function modifier_aghsfort_ogre_magi_multicast:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
end
function modifier_aghsfort_ogre_magi_multicast:OnAbilityFullyCast(event)
	if IsServer() then
		-- print(event)
		-- print(event.ability)
		-- print(event.ability:GetName()) 可以是""
		-- print(event.ability:GetName() == "")
		-- print(IsValid(event.ability))
		if self.caster == self.parent and self.parent:PassivesDisabled() then
			return
		end
		if IsValid(event.ability) and event.ability:GetName() ~= "" and event.ability:GetCaster() == self.parent then
			-- print(event.ability:GetName())
			if self.ability.ability_exceptions[event.ability:GetName()] then
				print("ability in blacklist, no multicasting...")
				return
			end
			local modifier_table = {
				ability_id = event.ability:entindex(),
				duration = 5,
			}
            -- DebugDrawCircle(event.new_pos, Vector(255,0,0), 200, 250, false, 0.5)
            -- DebugDrawCircle(event.unit:GetCursorPosition(), Vector(255,255,0), 200, 250, false, 0.5)
            -- DebugDrawCircle(self.parent:GetAbsOrigin(), Vector(0,255,0), 200, 250, false, 0.5)
            -- DebugDrawCircle(self.parent:GetCursorPosition(), Vector(0,0,255), 200, 250, false, 0.5)
			local cast_pos = event.unit:GetCursorPosition()
			if cast_pos then	
				modifier_table.pos_x = cast_pos.x
				modifier_table.pos_y = cast_pos.y
				modifier_table.pos_z = cast_pos.z
			end
			if IsValid(event.target) then
				modifier_table.target_id = event.target:entindex()
			end
			modifier_table.casts = self.ability:rollMulticast({caster = self.parent})
			if modifier_table.casts > 0 then
				self.parent:AddNewModifier(self.parent, self.ability, "modifier_aghsfort_ogre_magi_multicast_proc", modifier_table)
			end
		end
	end
end

modifier_aghsfort_ogre_magi_multicast_proc = {}
function modifier_aghsfort_ogre_magi_multicast_proc:IsHidden()
	return true
end
function modifier_aghsfort_ogre_magi_multicast_proc:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_aghsfort_ogre_magi_multicast_proc:OnCreated(kv)
	if IsServer() then
		self.parent = self:GetParent()
		self.ability = self:GetAbility()
		self.ability_cast = EntIndexToHScript(kv.ability_id)
		if kv.target_id ~= nil then
			self.target = EntIndexToHScript(kv.target_id)
		end
		self.pos = Vector(kv.pos_x, kv.pos_y, kv.pos_z)
		self.max_cast = kv.casts
		self.team = self.parent:GetTeamNumber()
		self.range_buffer = self.ability:GetSpecialValueFor("range_buffer")
		self.aoe_bias = self.ability:GetSpecialValueFor("aoe_bias")
		if not self:shouldMulticast() then
			self:Destroy()
			return
		end
		-- print("ability:"..self.ability_cast:GetName().." should multicast")
		if not self:initMulticast() then
			self:Destroy()
			return
		end
		-- print("ability:"..self.ability_cast:GetName().." multicast initialized")
		self.interval = self.ability_cast:GetSpecialValueFor("multicast_delay")
		if not self.bPointTarget and not self.bUnitTarget then
			-- print("a no target ability!")
			self.interval = self.ability:GetSpecialValueFor("no_target_delay")
		end
		self:SetStackCount(kv.casts)
		self:StartIntervalThink(self.interval)
	end
end

function modifier_aghsfort_ogre_magi_multicast_proc:OnIntervalThink()
	if IsServer() then
		if not IsValid(self.ability_cast) or self.ability_cast:GetName() == "" then
			print("ability removed! stop multicasting..")
			self:Destroy()
			return
		end
		
		self:handleConsumables(true, true)

		if self:doMulticast() then
			print("multicast!")
			-- self:handleCharged(false, true)
		else
			self:handleConsumables(false, false)
			print("fail to multicast!")			
		end
		self:DecrementStackCount()
		-- self:playEffect(self.max_cast - self:GetStackCount() + 1)
		if self.interval > 0 then
			print("pfx!")
			self:playEffect(self.max_cast - self:GetStackCount() + 1, self.interval)
		else
			if self:GetStackCount() < 1 then
				print("pfx!"..self.max_cast)
				self:playEffect(self.max_cast + 1, 1.0)
			end
		end
		if self:GetStackCount() < 1 then
			self:Destroy()
		end
	end
end

function modifier_aghsfort_ogre_magi_multicast_proc:shouldMulticast()
	-- 无法对无效技能生效
	if not IsValid(self.ability_cast) or self.max_cast < 1 then
		print("invalid ability or cast time")
		return false
	end
	-- 这里API虽然写的是LUA技能的接口，但是实际上内置技能也有此接口
	if self.ability_cast.OnSpellStart == nil then
		-- print("has on spell start!")
		-- local last_target = self.parent:GetCursorCastTarget()
		-- self.parent:SetCursorCastTarget(self.target)
		-- self.ability_cast:OnSpellStart()
	-- else
		print("no on spell start!")
		return false
	end
	-- 无法对缠绕禁止和黑名单技能生效
	if bitand(self.ability_cast:GetBehavior(), DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES) ~= 0 then
		-- print(bitand(self.ability_cast:GetBehavior(), DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES))
		print("not for root disables!")
		return false
	end

	-- 目前不知道如何调用矢量技能
	if bitand(self.ability_cast:GetBehavior(), DOTA_ABILITY_BEHAVIOR_VECTOR_TARGETING) ~= 0 then
		print("not for vector target!")
		return false
	end

	if self.ability.ability_exceptions[self.ability_cast:GetName()] then
		print("blacklist ability:"..self.ability_cast:GetName())
		return false

	end
	return true
end

function modifier_aghsfort_ogre_magi_multicast_proc:initMulticast()
	self.cast_behavior = self.ability_cast:GetBehavior()
	-- print("get ability behavior")
	self.cast_range = self.ability_cast:GetCastRange(self.parent:GetAbsOrigin(), self.parent) + self.parent:GetCastRangeBonus()
	-- print("get cast range")
	if self.ability_cast:IsItem() and (not self.ability_cast:IsPermanent() or self.ability.ability_as_consumable[self.ability_cast:GetName()]) then
		print(self.ability_cast:GetName().."is treated as a consumable item!")
		self.bConsumableItem = true
	end

	if AbilityChargeController:IsChargeTypeAbility(self.ability_cast) then
		self.bChargeAbility = true
	end

	if bitand(self.cast_behavior, DOTA_ABILITY_BEHAVIOR_CAN_SELF_CAST) ~= 0 then
		-- print("can selfcast!")
		self.bSelfCast = true
	end

	self.bSameTarget = self.ability.ability_same_target[self.ability_cast:GetName()] or false
	if bitand(self.cast_behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) ~= 0 or bitand(self.cast_behavior, DOTA_ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET) ~= 0 then
		print("unit target!")
		self.bUnitTarget = true
		if self.bSameTarget then
			print("same target!")
		else
			self.targeted = {}
			if IsValid(self.target) then
				self.targeted[self.target:entindex()] = true
			end
			-- print("collecting target info...")
			self.target_info = {}
			-- self.target_info.team = self.ability_cast:GetAbilityTargetTeam()
			if IsValid(self.target) and self.team == self.target:GetTeamNumber() then
				-- print("targeting ally")
				self.target_info.team = DOTA_UNIT_TARGET_TEAM_FRIENDLY
				self.bSelfCast = true
			else
				print("targeting enemy")
				self.target_info.team = DOTA_UNIT_TARGET_TEAM_ENEMY
			end
			-- print("get target team!...")
			self.target_info.type = self.ability_cast:GetAbilityTargetType()
			if bitand(self.target_info.type, DOTA_UNIT_TARGET_CUSTOM) ~= 0 then
				if self.ability.ability_target_custom[self.ability_cast:GetName()] then
				else
					if self.target_info.team == DOTA_UNIT_TARGET_TEAM_ENEMY then
						self.target_info.type = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
					else
						self.target_info.type = DOTA_UNIT_TARGET_NONE
					end
				end
			end
			-- print("get target type!..."..self.target_info.type)
			self.target_info.flag = self.ability_cast:GetAbilityTargetFlags()
			-- print("get target flag!..."..self.target_info.flag)
			if bitand(self.target_info.flag, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE) == 0 then
				self.target_info.flag = self.target_info.flag + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
			end
			PrintTable(self.target_info)
		end
	end

	if bitand(self.cast_behavior, DOTA_ABILITY_BEHAVIOR_POINT) ~= 0 or bitand(self.cast_behavior, DOTA_ABILITY_BEHAVIOR_OPTIONAL_POINT) ~= 0 then
		-- print("point target!")
		self.bPointTarget = true
	end
	self.dRadius = 0
	if bitand(self.cast_behavior, DOTA_ABILITY_BEHAVIOR_AOE) ~= 0 then
		self.dRadius = self.ability_cast:GetAOERadius()
	end
	-- print("radius:"..self.dRadius)
	return true
end

function modifier_aghsfort_ogre_magi_multicast_proc:doMulticast()
	if self:doMulticastTarget() then
		return true
	end
	if self:doMulticastPoint() then
		return true
	end
	if self:doMulticastNoTarget() then
		return true
	end
	return false
end

function modifier_aghsfort_ogre_magi_multicast_proc:doMulticastTarget()
	if not self.bUnitTarget then
		return false
	end
	-- print("do target multicast!")
	if not self.bSameTarget then
		if self.bSelfCast and not self.targeted[self.parent:entindex()] then
			-- print("targeting self...")
			self.target = self.parent
			self.targeted[self.parent:entindex()] = true
		else
			-- print("searching for target...")
			self.target = nil
			local radius = self.cast_range + self.range_buffer
			local candidates = FindUnitsInRadius(self.team, self.parent:GetAbsOrigin(), nil, radius, self.target_info.team, self.target_info.type,self.target_info.flag, FIND_ANY_ORDER, false)
			print("find candidates:"..#candidates.."in"..radius)
			for _, candidate in pairs(candidates) do
				if not self.targeted[candidate:entindex()] then
					self.target = candidate
					self.targeted[candidate:entindex()] = true
					break
				end
			end
		end
	end
	if IsValid(self.target) then
		local last_target = self.parent:GetCursorCastTarget()
		self.parent:SetCursorCastTarget(self.target)
		self.ability_cast:OnSpellStart()
		self.parent:SetCursorCastTarget(last_target)
		return true
	end
	-- print("invalid target!")
	return false
end

function modifier_aghsfort_ogre_magi_multicast_proc:doMulticastPoint()
	if not self.bPointTarget then
		 return false
	end
	local delta = RandomVector(RandomFloat(self.dRadius, self.dRadius + self.aoe_bias))
	self.pos = self.pos + delta
	print(self.pos)
	local last_pos = self.parent:GetCursorPosition()
	self.parent:SetCursorPosition(self.pos)
	self.ability_cast:OnSpellStart()
	self.parent:SetCursorPosition(last_pos)
	return true
end

function modifier_aghsfort_ogre_magi_multicast_proc:doMulticastNoTarget()
	if self.bUnitTarget or self.bPointTarget then
		return false
	end
	-- local last_target = self.parent:GetCursorCastTarget()
	-- self.parent:SetCursorCastTarget(self.parent)
	self.ability_cast:OnSpellStart()
	-- self.parent:SetCursorCastTarget(last_target)
	return true
end

function modifier_aghsfort_ogre_magi_multicast_proc:handleConsumables(bStart, bSuccess)
	if self.bConsumableItem and self.bConsumableItem == true then
		if bStart then
			print("add a charge!")
			self.ability_cast:SetCurrentCharges(self.ability_cast:GetCurrentCharges() + 1)
		else
			if bSuccess then
			else
				print("remove charge!")
				self.ability_cast:SpendCharge()
			end
		end
	end
end

function modifier_aghsfort_ogre_magi_multicast_proc:handleCharged(bStart, bSuccess)
	if self.bChargeAbility and self.bChargeAbility == true then
		if bStart then
			
		else
			if bSuccess then
				print("restore charge!")
				AbilityChargeController:CostCharge(self.ability_cast, -1, true)
			else
			end
		end
	end
end

function modifier_aghsfort_ogre_magi_multicast_proc:playEffect(nCast, fInterval)
	self.parent:EmitSound("Hero_OgreMagi.Fireblast.x"..math.max(nCast, 3))
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_om/ogre_magi_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(pfx, 1, Vector(nCast, 1 / fInterval, 0))
end
