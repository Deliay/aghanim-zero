modifier_item_precious_egg = class({})

------------------------------------------------------------------------------

function modifier_item_precious_egg:IsHidden() 
	return true
end

--------------------------------------------------------------------------------

function modifier_item_precious_egg:IsPurgable()
	return false
end

----------------------------------------

function modifier_item_precious_egg:OnCreated( kv )
	self.bonus_all_stats = self:GetAbility():GetSpecialValueFor( "bonus_all_stats" )
	self.chance_to_resist_death = self:GetAbility():GetSpecialValueFor( "chance_to_resist_death" )
	self.bDeathPrevented = false
end

--------------------------------------------------------------------------------

function modifier_item_precious_egg:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_EVENT_ON_DEATH_PREVENTED,
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_item_precious_egg:GetModifierBonusStats_Strength( params )
	return self.bonus_all_stats
end 
--------------------------------------------------------------------------------

function modifier_item_precious_egg:GetModifierBonusStats_Agility( params )
	return self.bonus_all_stats
end 
--------------------------------------------------------------------------------

function modifier_item_precious_egg:GetModifierBonusStats_Intellect( params )
	return self.bonus_all_stats
end 

--------------------------------------------------------------------------------

function modifier_item_precious_egg:GetMinHealth( params )
	if IsServer() then
		if RollPercentage( self.chance_to_resist_death ) then
			self.bDeathPrevented = true
			return 1
		end
	end
	return 0
end 

--------------------------------------------------------------------------------

function modifier_item_precious_egg:OnDeathPrevented( params )
	if IsServer() then
		if self:GetParent() == params.unit and self:GetParent():IsAlive() and self.bDeathPrevented then
			local nFXIndex = ParticleManager:CreateParticle( "particles/items4_fx/combo_breaker_spell.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
			ParticleManager:ReleaseParticleIndex( nFXIndex )

			EmitSoundOn( "DOTA_Item.ComboBreaker", self:GetParent() )
			self.bDeathPrevented = false
		end
	end
	return 0
end
