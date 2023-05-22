LinkLuaModifier( "modifier_item_dyson_sphere", "items/ext/item_dyson_sphere.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
item_dyson_sphere = class({})
function item_dyson_sphere:GetIntrinsicModifierName()
	return "modifier_item_dyson_sphere"
end
function item_dyson_sphere:OnSpellStart()
	self:doAction()
end
function item_dyson_sphere:doAction(kv)
	local caster = self:GetCaster()
	local exlude = nil

	if kv and (kv.bNoSelf) then
		exlude = caster
	end	
	local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, self:GetCastRange(caster:GetOrigin(), nil), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

	for _, ally in pairs(allies) do
		if ally ~= exlude then
			if ally == caster then
				ally:Purge(false, true, false, false, false)
			end
			ally:AddNewModifier(caster, self, "modifier_item_sphere_target", {duration = self:GetCooldown(-1)})
			ally:EmitSound("DOTA_Item.LinkensSphere.Target")
		end
	end
end
---------------------------------------------------------------------
--Modifiers
modifier_item_dyson_sphere = class({})
function modifier_item_dyson_sphere:IsHidden()
	return true
end
function modifier_item_dyson_sphere:OnCreated(kv)
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.cold_duration = self.ability:GetSpecialValueFor("cold_duration")
	self.all_stats = self.ability:GetSpecialValueFor("bonus_all_stats")
	self.hp_regen = self.ability:GetSpecialValueFor("bonus_health_regen")
	self.mp_regen = self.ability:GetSpecialValueFor("bonus_mana_regen")
end
function modifier_item_dyson_sphere:OnRefresh(kv)
	if IsServer() then
	end
end
function modifier_item_dyson_sphere:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_dyson_sphere:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_ABSORB_SPELL,
	}
end
function modifier_item_dyson_sphere:OnAttackLanded(event)
	if IsServer() then
        if event.attacker == self.parent and not self.parent:HasModifier("modifier_item_majo_thorn_touch_cd") then
            local filter_result = UnitFilter(event.target, DOTA_UNIT_TARGET_TEAM_ENEMY,
                DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, self.parent:GetTeamNumber())
            if filter_result == UF_SUCCESS then
				event.target:AddNewModifier(self.parent, self.ability, "modifier_item_skadi_slow", {duration = self.cold_duration})
            end
        end
    end
end
function modifier_item_dyson_sphere:GetModifierProjectileName()
	return "particles/items2_fx/skadi_projectile.vpcf"
end
function modifier_item_dyson_sphere:GetAbsorbSpell(event)
    if IsServer() then
		if self.ability:IsCooldownReady() then
			if IsValid(event.ability) and event.ability.GetCaster then
				local caster = event.ability:GetCaster()
				if not IsEnemy(self.parent, caster) then
					return 0
				end
			end
			local pfx = ParticleManager:CreateParticle("particles/items_fx/immunity_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.parent)
			ParticleManager:ReleaseParticleIndex(pfx)
			self.parent:EmitSound("DOTA_Item.LinkensSphere.Activate")
			self.ability:doAction()
			self.ability:UseResources(false, false, false, true)
			return 1
		end
	end
	return 0
end
function modifier_item_dyson_sphere:GetModifierBonusStats_Strength()
	return self.all_stats
end
function modifier_item_dyson_sphere:GetModifierBonusStats_Agility()
	return self.all_stats
end
function modifier_item_dyson_sphere:GetModifierBonusStats_Intellect()
	return self.all_stats
end
function modifier_item_dyson_sphere:GetModifierConstantHealthRegen()
	return self.hp_regen
end
function modifier_item_dyson_sphere:GetModifierConstantManaRegen()
	return self.mp_regen
end
