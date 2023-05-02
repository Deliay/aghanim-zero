LinkLuaModifier( "modifier_item_gavuric", "items/ext/item_gavuric.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_gavuric_active", "items/ext/item_gavuric.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
item_gavuric = class({})
function item_gavuric:GetIntrinsicModifierName()
	return "modifier_item_gavuric"
end
function item_gavuric:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")
	caster:Purge(false, true, false, true, false)
	caster:EmitSound("DOTA_Item.BlackKingBar.Activate")
	caster:EmitSound("DOTA_Item.Satanic.Activate")
	caster:AddNewModifier(caster, self, "modifier_black_king_bar_immune", {duration = duration})
	caster:AddNewModifier(caster, self, "modifier_item_gavuric_active", {duration = duration})
end
---------------------------------------------------------------------
--Modifiers
modifier_item_gavuric = class({})
function modifier_item_gavuric:IsHidden()
	return true
end
function modifier_item_gavuric:OnCreated(kv)
	self.parent = self:GetParent()
	self:updateData(kv)
end
function modifier_item_gavuric:OnRefresh(kv)
	self:updateData(kv)
end
function modifier_item_gavuric:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end
function modifier_item_gavuric:OnTakeDamage( event )
	if IsServer() then
		local Attacker = event.attacker
		local Target = event.unit
		local Ability = event.inflictor
		local flDamage = event.damage

		if Attacker ~= self.parent or Target == nil or event.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK then
			return 0
		end


		if bit.band( event.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION ) == DOTA_DAMAGE_FLAG_REFLECTION then
			return 0
		end

		if Target == self.parent and self.parent:IsIllusion() then
			return 0
		end

		local pfx = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, Attacker )
		ParticleManager:ReleaseParticleIndex( pfx )

		local flLifesteal = flDamage * self.steal
		if self.parent:HasModifier("modifier_item_gavuric_active") then
			flLifesteal = flDamage * self.steal_unholy
		end
		Attacker:HealWithParams( flLifesteal, self.ability, true, true, self.parent, false )
	end
	return 0
end
function modifier_item_gavuric:GetModifierBonusStats_Strength()
	return self.str
end
function modifier_item_gavuric:GetModifierPreAttack_BonusDamage()
	return self.dmg
end
function modifier_item_gavuric:updateData(kv)
	self.str = self:GetAbility():GetSpecialValueFor("bonus_str")
	self.dmg = self:GetAbility():GetSpecialValueFor("bonus_damage")
	if IsServer() then
		self.steal = self:GetAbility():GetSpecialValueFor("lifesteal_percent") * 0.01
		self.steal_unholy = self:GetAbility():GetSpecialValueFor("unholy_lifesteal_total_tooltip") * 0.01
	end
end
modifier_item_gavuric_active = {}
function modifier_item_gavuric_active:IsPurgable()
	return false
end
function modifier_item_gavuric_active:OnCreated(kv)
	if IsServer() then
		local pfx = ParticleManager:CreateParticle("particles/items2_fx/satanic_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(pfx, false, false, -1, false, false)
	end
end
