LinkLuaModifier( "modifier_aghsfort_bounty_hunter_loan", "abilities/heroes/bounty_hunter/loan", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_bounty_hunter_loan_debt", "abilities/heroes/bounty_hunter/loan", LUA_MODIFIER_MOTION_NONE )
--Abilities
if aghsfort_bounty_hunter_loan == nil then
	aghsfort_bounty_hunter_loan = class({})
end
function aghsfort_bounty_hunter_loan:GetIntrinsicModifierName()
	return "modifier_aghsfort_bounty_hunter_loan"
end

function aghsfort_bounty_hunter_loan:Init()
	print("loan init!")
end
-- 以服务端为准
function aghsfort_bounty_hunter_loan:CastFilterResultTarget(hTarget)
	if not IsValid(self.jinada) or self.jinada:GetLevel() < 1 then
		return UF_FAIL_CUSTOM
	end 
	if IsServer() then		
		local caster = self:GetCaster()
		local result = UnitFilter(hTarget, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), caster:GetTeamNumber())
		if result ~= UF_SUCCESS then
			return result
		end
		if caster == hTarget then
			return UF_SUCCESS
		else
			if caster:GetGold() <= self:getLoanGold() then
				return UF_FAIL_CUSTOM
			end
		end
	end
	return UF_SUCCESS
end
function aghsfort_bounty_hunter_loan:GetCustomCastErrorTarget(hTarget)
	return "CANT PAY THAT!"
end
function aghsfort_bounty_hunter_loan:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_jinada.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(pfx,0,Vector(100,0,0))
	ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(pfx)

	target:AddNewModifier(caster, self, "modifier_aghsfort_bounty_hunter_loan_debt", {
		duration = self:GetSpecialValueFor("interval"),
	})
end

function aghsfort_bounty_hunter_loan:getLoanGold()
	local cost = 0
	if IsValid(self.jinada) then
		cost = self.jinada:GetSpecialValueFor("gold_steal")
	end
	cost = cost * self:GetSpecialValueFor("mul")
	return cost
end
---------------------------------------------------------------------
--Modifiers
if modifier_aghsfort_bounty_hunter_loan == nil then
	modifier_aghsfort_bounty_hunter_loan = class({})
end
function modifier_aghsfort_bounty_hunter_loan:IsHidden()
	return true
end
function modifier_aghsfort_bounty_hunter_loan:OnCreated(params)
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	if IsServer() then
		-- self:StartIntervalThink(1.0)
	end
end
function modifier_aghsfort_bounty_hunter_loan:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_aghsfort_bounty_hunter_loan:OnDestroy()
	if IsServer() then
	end
end
function modifier_aghsfort_bounty_hunter_loan:OnIntervalThink()
	if IsServer() then
		-- if self.parent:HasAbility("aghsfort_bounty_hunter_legend_jinada_loan") then
		-- 	self.ability:SetHidden(false)
		-- 	self:StartIntervalThink(-1)
		-- end
	end
end
function modifier_aghsfort_bounty_hunter_loan:DeclareFunctions()
	return {
	}
end

modifier_aghsfort_bounty_hunter_loan_debt = {}
function modifier_aghsfort_bounty_hunter_loan_debt:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_aghsfort_bounty_hunter_loan_debt:IsDebuff()
	return true
end
function modifier_aghsfort_bounty_hunter_loan_debt:IsPurgable()
	return false
end
function modifier_aghsfort_bounty_hunter_loan_debt:IsPurgeException()
	return false
end
function modifier_aghsfort_bounty_hunter_loan_debt:RemoveOnDeath()
	return false
end
function modifier_aghsfort_bounty_hunter_loan_debt:DestroyOnExpire()
	return false
end
function modifier_aghsfort_bounty_hunter_loan_debt:OnCreated(kv)
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.caster = self.ability:GetCaster()
	self.loan = self.ability:getLoanGold()
	self.interval = self.ability:GetSpecialValueFor("interval")
	self.interest = self.ability:GetSpecialValueFor("interest") * 0.01
	if self.caster == self.parent then
		self.interest = 0
	end
	self.instance = self.ability:GetSpecialValueFor("instances") or 10
	self.total_payback = self.loan * (1 + self.interest)
	self.delta = math.floor( self.total_payback /self.instance)
	if IsServer() then
		if not IsValid(self.parent) then
			self:Destroy()
		end
		if self.caster ~= self.parent then
			self.caster:ModifyGold(-self.loan, true, DOTA_ModifyGold_AbilityCost)
			-- SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, self.caster, -self.loan, nil)
			-- PopupNumbers(self.caster, "gold", Vector(255, 200, 33), 1.0, -self.loan, 1)
		end
		self.parent:ModifyGold(self.loan, true, DOTA_ModifyGold_AbilityGold)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, self.parent, self.loan, nil)
		EmitSoundOn("DOTA_Item.Hand_Of_Midas", self.parent)
		self:SetStackCount(self.instance)
		self:StartIntervalThink(1.0)
	end
end
function modifier_aghsfort_bounty_hunter_loan_debt:OnIntervalThink()
	if IsServer() then
		if not IsValid(self.parent) then
			self:Destroy()
		end
		if self:GetRemainingTime() <= 0 then
			if self.parent:IsAlive() then
				if self.parent:GetGold() > self.delta then
					self.parent:ModifyGold(-self.delta, true, DOTA_ModifyGold_AbilityCost)
					-- SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, self.parent, -self.delta, nil)
					-- PopupNumbers(self.parent, "gold", Vector(255, 200, 33), 1.0, -self.delta, 1)
					if self.parent ~= self.caster then
						self.caster:ModifyGold(self.delta, true, DOTA_ModifyGold_AbilityGold)
						SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, self.caster, self.delta, nil)
					end
					self:DecrementStackCount()
					if self:GetStackCount() <= 0 then
						self:Destroy()
					end
					self:SetDuration(self.interval, true)
				end
			end
		end
	end
end
function modifier_aghsfort_bounty_hunter_loan_debt:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_PROPERTY_TOOLTIP2
	}
end

function modifier_aghsfort_bounty_hunter_loan_debt:OnTooltip()
	-- print(self:GetStackCount())
	return self.delta * self:GetStackCount()
end

function modifier_aghsfort_bounty_hunter_loan_debt:OnTooltip2()
	return self.delta
end
