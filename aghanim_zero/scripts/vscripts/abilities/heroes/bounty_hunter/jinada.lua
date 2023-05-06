LinkLuaModifier( "modifier_aghsfort_bounty_hunter_jinada", "abilities/heroes/bounty_hunter/jinada", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_bounty_hunter_jinada_cd", "abilities/heroes/bounty_hunter/jinada", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_bounty_hunter_jinada_debuff", "abilities/heroes/bounty_hunter/jinada", LUA_MODIFIER_MOTION_NONE )
--Abilities
if aghsfort_bounty_hunter_jinada == nil then
	aghsfort_bounty_hunter_jinada = class({})
end
function aghsfort_bounty_hunter_jinada:GetIntrinsicModifierName()
	return "modifier_aghsfort_bounty_hunter_jinada"
end

function aghsfort_bounty_hunter_jinada:Init()
	self.caster = self:GetCaster()
end

function aghsfort_bounty_hunter_jinada:OnUpgrade()
	if IsServer() then
		if self:GetLevel() == 1 then
			self:ToggleAutoCast()
		end
	end
end

function aghsfort_bounty_hunter_jinada:CastFilterResultTarget(hTarget)
	if IsServer() then
		if not IsValid(self.passive_modifier) then
			self.passive_modifier = self.caster:FindModifierByName("modifier_aghsfort_bounty_hunter_jinada")
		end
		if IsValid(self.passive_modifier) and self:IsCooldownReady() then
			-- print("active cast!")
			self.passive_modifier:setActive(true)
		end
	end
	return UF_SUCCESS
end

function aghsfort_bounty_hunter_jinada:getDamage()
	return  self:GetSpecialValueFor("bonus_damage") + GetTalentValue(self:GetCaster(), "aghsfort_bounty_hunter_jinada+damage")
end

function aghsfort_bounty_hunter_jinada:getGoldSteal()
	return  self:GetSpecialValueFor("gold_steal") + GetTalentValue(self:GetCaster(), "aghsfort_bounty_hunter_jinada+gold")
end

function aghsfort_bounty_hunter_jinada:doAction(kv)
	if self:GetLevel() > 0 then
		local caster = kv.caster
		local target = kv.target
		local bDamage = kv.bDamage or false
		local damage = self:getDamage()

		if IsValid(target) and IsValid(caster) then
			local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinada.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(pfx,0,Vector(100,0,0))
			ParticleManager:SetParticleControlEnt(pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
			ParticleManager:ReleaseParticleIndex(pfx)


			if not target:HasModifier("modifier_aghsfort_bounty_hunter_jinada_debuff") then
				target:AddNewModifier(caster, self, "modifier_aghsfort_bounty_hunter_jinada_debuff", {})
				local bounty = self:getGoldSteal()
				if not IsAghanimConsideredHero(target) then
					bounty = self:GetSpecialValueFor("creep_multiplier") * bounty
					bounty = math.floor(bounty)
				end

				if IsValid(caster) and caster:IsHero() then
					caster:ModifyGold(bounty, false, DOTA_ModifyGold_AbilityGold)
				end
				-- PopupNumbers(target, "gold", Vector(255, 200, 33), 1.0, bounty, 1)
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, target, bounty, nil)
				EmitSoundOn("DOTA_Item.Hand_Of_Midas", target)
			else
				if IsValid(self.shard_murder) then
					damage = damage + (damage * 0.75)
				end
			end

			if bDamage then
				local damage_table = {
					victim = target,
					attacker = caster,
					damage = damage,
					damage_type = self:GetAbilityDamageType(),
					ability = self,
					damage_category = DOTA_DAMAGE_CATEGORY_SPELL
				}
				ApplyDamage(damage_table)		
				EmitSoundOn("Hero_BountyHunter.Attack", target)		
			end
		end
	end
end

---------------------------------------------------------------------
--Modifiers
if modifier_aghsfort_bounty_hunter_jinada == nil then
	modifier_aghsfort_bounty_hunter_jinada = class({})
end
function modifier_aghsfort_bounty_hunter_jinada:IsHidden()
	return true
end
function modifier_aghsfort_bounty_hunter_jinada:OnCreated(kv)
	self.parent = self:GetParent()
    self.team = self.parent:GetTeamNumber()
    self.ability = self:GetAbility()
	self:updateData(kv)
end
function modifier_aghsfort_bounty_hunter_jinada:OnRefresh(kv)
	self:updateData(kv)
end
function modifier_aghsfort_bounty_hunter_jinada:updateData(kv)
	if IsServer() then
		-- self.bounty = self.ability:GetSpecialValueFor("gold_steal")
	end
end
function modifier_aghsfort_bounty_hunter_jinada:OnDestroy()
	if IsServer() then
	end
end
-- 
function modifier_aghsfort_bounty_hunter_jinada:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK_CANCELLED,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		MODIFIER_EVENT_ON_DEATH

		-- not triggered
		-- MODIFIER_EVENT_ON_SPELL_TARGET_READY, 
		-- MODIFIER_EVENT_ON_ABILITY_START
	}
end
-- 
function modifier_aghsfort_bounty_hunter_jinada:OnOrder(event)
	if IsServer() and event.unit == self:GetParent() then
		if event.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or event.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or event.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET or event.order_type == DOTA_UNIT_ORDER_STOP or event.order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
			self:setActive(false)
		end
	end
end
-- 
function modifier_aghsfort_bounty_hunter_jinada:OnAbilityExecuted(event)
	if IsServer() then
		if event.ability:GetCaster() == self.parent then
			self:setActive(false)
		end
	end
end
function modifier_aghsfort_bounty_hunter_jinada:OnAttackCancelled(event)
	if IsServer() then
		if event.attacker == self.parent then
			self:setActive(false)
        end
	end
end
-- 
function modifier_aghsfort_bounty_hunter_jinada:GetModifierPreAttack_BonusDamage()
	if self.parent:HasModifier("modifier_aghsfort_bounty_hunter_jinada_cd") then
		return 0
	end
	if IsServer() then
		if not self.ability:GetAutoCastState() and not self._active then
            return 0
        end
	end
	return self.ability:getDamage()
end

function modifier_aghsfort_bounty_hunter_jinada:GetModifierProcAttack_BonusDamage_Physical(event)
	if not IsValid(self.ability.shard_murder) or not event.target:HasModifier("modifier_aghsfort_bounty_hunter_jinada_debuff") then
		return 0
	end
	return self.ability:getDamage()
end
-- 
function modifier_aghsfort_bounty_hunter_jinada:OnAttackLanded(event)
	if IsServer() and event.attacker == self.parent then
		if not self.ability:GetAutoCastState() and not self._active then
            return
        end
		self:setActive(false)
		if not self.ability:IsCooldownReady() or self.parent:PassivesDisabled() then
            return
        end
		-- unit filter
		local filter = UnitFilter(event.target, DOTA_UNIT_TARGET_TEAM_ENEMY,
		self.ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		self.team)

		if filter == UF_SUCCESS then
			self.ability:UseResources(true, false, true, true)
			self.ability:doAction({
				target = event.target,
				caster = self.parent,
				bDamage = false
			})
			self.parent:AddNewModifier(self.parent, self.ability, "modifier_aghsfort_bounty_hunter_jinada_cd", {
				duration = self.ability:GetEffectiveCooldown(self.ability:GetLevel())
			})
		end
	end
end
function modifier_aghsfort_bounty_hunter_jinada:OnDeath(event)
	if IsServer() then
		-- print("unit:"..event.unit:GetName())
		if IsValid(event.unit) and event.unit:GetTeamNumber() ~= self.team then
			if IsAghanimConsideredHero(event.unit) and IsValid(self.ability.shard_konyiji) then
				if event.unit:HasModifier("modifier_aghsfort_bounty_hunter_jinada_debuff") then
					self.ability.shard_konyiji:doAction({
						target = event.unit
					})
				end
			end
		end
	end
end


function modifier_aghsfort_bounty_hunter_jinada:setActive(bActive)
	if IsServer() then
		self._active = bActive
	end
end
-- 
modifier_aghsfort_bounty_hunter_jinada_cd = {}
function modifier_aghsfort_bounty_hunter_jinada_cd:IsHidden()
	return true
end
function modifier_aghsfort_bounty_hunter_jinada_cd:IsPurgable()
	return false
end
-- 
modifier_aghsfort_bounty_hunter_jinada_debuff = {}
function modifier_aghsfort_bounty_hunter_jinada_debuff:IsPurgable()
	return false
end
function modifier_aghsfort_bounty_hunter_jinada_debuff:RemoveOnDeath()
	return false
end
function modifier_aghsfort_bounty_hunter_jinada_debuff:OnCreated(kv)
	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	self.parent = self:GetParent()
end
-- function modifier_aghsfort_bounty_hunter_jinada_debuff:DeclareFunctions()
-- 	return {
-- 	}
-- end
