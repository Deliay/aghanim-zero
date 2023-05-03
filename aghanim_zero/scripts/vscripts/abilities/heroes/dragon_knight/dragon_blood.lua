aghsfort_dk_dragon_blood = {}

LinkLuaModifier( "modifier_aghsfort_dk_dragon_blood", "abilities/heroes/dragon_knight/dragon_blood", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_dk_dragon_blood_damage", "abilities/heroes/dragon_knight/dragon_blood", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_aghsfort_dk_dragon_blood_active", "abilities/heroes/dragon_knight/dragon_blood", LUA_MODIFIER_MOTION_NONE )

function aghsfort_dk_dragon_blood:GetIntrinsicModifierName()
	return "modifier_aghsfort_dk_dragon_blood"
end

function aghsfort_dk_dragon_blood:GetCastRange(vLocation, hTarget)
	if self:GetCaster():HasModifier("modifier_aghsfort_dk_dragon_blood_active") then
		return self:GetCaster():GetModifierStackCount("modifier_aghsfort_dk_dragon_blood_active", self:GetCaster())
	end
end

function aghsfort_dk_dragon_blood:GetBehavior()
	if self:GetCaster():HasModifier("modifier_aghsfort_dk_dragon_blood_active") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_AOE
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end	
end

function aghsfort_dk_dragon_blood:OnAbilityPhaseStart()
	if not IsServer() or not self:GetCaster():HasModifier("modifier_aghsfort_dk_dragon_blood_active") then return end

	if self:GetCaster():HasModifier("modifier_aghsfort_dk_elder_dragon_form") then
		self:GetCaster():StartGesture(ACT_DOTA_CAST_ABILITY_4)
	else
		self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_VICTORY, 2)

		local this = self
		Timers(0.4, function()
			this:GetCaster():FadeGesture(ACT_DOTA_VICTORY)
		end
		)		
	end
	return true
end

function aghsfort_dk_dragon_blood:OnSpellStart()
	if not IsServer() or not self:GetCaster():HasModifier("modifier_aghsfort_dk_dragon_blood_active") then return end

	local shard = self:GetCaster():FindAbilityByName("aghsfort_dk_dragon_blood_active")
	local duration = shard:GetLevelSpecialValueFor("duration",1)
	local radius = shard:GetLevelSpecialValueFor("radius",1)
	local stun_duration = shard:GetLevelSpecialValueFor("stun_duration",1)
	local regen_damage_mult = shard:GetLevelSpecialValueFor("regen_damage_mult",1)

	local damage = self:GetCaster():GetHealthRegen() / 100 * regen_damage_mult

	EmitSoundOn( "Hero_DragonKnight.ElderDragonForm", self:GetCaster() )
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_minotaur_horn_immune", {duration = duration})
	local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_huskar/huskar_inner_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:ReleaseParticleIndex(particle)

	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _, enemy in pairs(enemies) do
		local knockback =
		{
			knockback_duration = 0.35,
			duration = 0.35,
			knockback_distance = 250,
			knockback_height = 30,
			center_x = self:GetCaster():GetAbsOrigin().x,
			center_y = self:GetCaster():GetAbsOrigin().y,
			center_z = self:GetCaster():GetAbsOrigin().z,
		}
		enemy:RemoveModifierByName("modifier_knockback")
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_knockback", knockback)	
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", {duration = stun_duration})	

		local damageTable = {
			victim = enemy,
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self,
		}
		ApplyDamage(damageTable)

		Timers(0.35, function()
			FindClearSpaceForUnit(enemy, enemy:GetAbsOrigin(), false)
		end)		
	end
end


modifier_aghsfort_dk_dragon_blood = {}

function modifier_aghsfort_dk_dragon_blood:IsHidden()
	return true
end

function modifier_aghsfort_dk_dragon_blood:OnCreated()
	if not IsServer() then return end

	self.magic_resist = 0
	self.bonus_armor = 0
	self.bonus_regen = 0
	self:SetHasCustomTransmitterData( true )
	

	self:StartIntervalThink(1.5)
end

function modifier_aghsfort_dk_dragon_blood:OnIntervalThink()
	if not self:GetCaster():HasModifier("modifier_aghsfort_dk_dragon_blood_damage") and self:GetCaster():HasAbility("aghsfort_dk_dragon_blood_damage") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_aghsfort_dk_dragon_blood_damage", {})
	end

	if self:GetCaster():HasAbility("aghsfort_dk_dragon_blood_gold") then
		local shard = self:GetCaster():FindAbilityByName("aghsfort_dk_dragon_blood_gold")
		local armor_gold = shard:GetLevelSpecialValueFor("gold_per_armor",1)
		local magic_resist_gold = shard:GetLevelSpecialValueFor("gold_per_magic_resist",1)

		self.magic_resist = self:GetCaster():GetGold() / magic_resist_gold
		self.bonus_armor = self:GetCaster():GetGold() / armor_gold

		self:SendBuffRefreshToClients()
	end

	if self:GetParent():HasAbility("aghsfort_dk_dragon_blood_active") then
		self:GetCaster():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_aghsfort_dk_dragon_blood_active", {})
	end
end

function modifier_aghsfort_dk_dragon_blood:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
end

function modifier_aghsfort_dk_dragon_blood:GetModifierConstantHealthRegen()
	if not self:GetParent():PassivesDisabled() then
		return self:GetAbility():GetSpecialValueFor( "bonus_health_regen" ) + self.bonus_regen
	end
end

function modifier_aghsfort_dk_dragon_blood:GetModifierPhysicalArmorBonus()
	if not self:GetParent():PassivesDisabled() then		
		return self:GetAbility():GetSpecialValueFor( "bonus_armor" ) + self.bonus_armor
	end
end

function modifier_aghsfort_dk_dragon_blood:GetModifierMagicalResistanceBonus()
	if not self:GetParent():PassivesDisabled() then
		return self.magic_resist
	end
end

function modifier_aghsfort_dk_dragon_blood:AddCustomTransmitterData( )
	return
	{
		magic_resist = self.magic_resist,
		bonus_armor = self.bonus_armor,
		bonus_regen = self.bonus_regen,
	}
end

function modifier_aghsfort_dk_dragon_blood:HandleCustomTransmitterData( data )
	self.magic_resist = data.magic_resist
	self.bonus_armor = data.bonus_armor
	self.bonus_regen = data.bonus_regen
end

---------------------

modifier_aghsfort_dk_dragon_blood_damage	= class({
	IsHidden				= function(self) return false end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,		
	RemoveOnDeath  			= function(self) return false end,		
})

function modifier_aghsfort_dk_dragon_blood_damage:OnCreated()
	self:SetStackCount(0)

	if not IsServer() then return end

	self.max_stack_mult = self:GetParent():FindAbilityByName("aghsfort_dk_dragon_blood_damage"):GetLevelSpecialValueFor("max_stack",1)
	self:StartIntervalThink(1)
end

function modifier_aghsfort_dk_dragon_blood_damage:OnIntervalThink()
	if not IsServer() then return end
	local max_stack = math.ceil(self:GetParent():GetHealthRegen()) * self.max_stack_mult
	if self:GetStackCount() < max_stack then
		local new_stack = self:GetStackCount() + math.ceil(self:GetParent():GetHealthRegen())
		if new_stack >= max_stack then
			new_stack = max_stack

			if not self.particle then
				self.particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_invoker_kid/invoker_kid_exort_orb_fire.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
				ParticleManager:SetParticleControlEnt( self.particle, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true )
			end
		end
		self:SetStackCount(new_stack)
	end
end

function modifier_aghsfort_dk_dragon_blood_damage:DeclareFunctions()
	local funcs =
	{
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function modifier_aghsfort_dk_dragon_blood_damage:OnAttackLanded(params)
	if IsServer() and self:GetParent() == params.attacker and not params.no_attack_cooldown then

		local damageTable = {
			victim = params.target,
			attacker = params.attacker,
			damage = self:GetStackCount(),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(),
		}
		ApplyDamage(damageTable)

		local max_stack = math.ceil(self:GetParent():GetHealthRegen()) * self.max_stack_mult
		if self:GetStackCount() >= max_stack then
			self:GetParent():Heal(params.damage + max_stack, self:GetAbility())
			local heal_effect = ParticleManager:CreateParticle( "particles/items3_fx/fish_bones_active.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
			ParticleManager:SetParticleControlEnt( heal_effect, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true )
			ParticleManager:ReleaseParticleIndex(heal_effect)
			EmitSoundOn( "Dungeon.BloodSplatterImpact.Lesser", params.target )

			if self.particle then
				ParticleManager:DestroyParticle(self.particle, false)
				ParticleManager:ReleaseParticleIndex(self.particle)
				self.particle = nil
			end
		end

		self:SetStackCount(0)
		self:StartIntervalThink(1)
	end
end

---------------------

modifier_aghsfort_dk_dragon_blood_active	= class({
	IsHidden				= function(self) return true end,
	IsPurgable	  			= function(self) return false end,
	IsDebuff	  			= function(self) return false end,		
	RemoveOnDeath  			= function(self) return false end,		
})

function modifier_aghsfort_dk_dragon_blood_active:OnCreated()
	if not IsServer() then return end
	local radius = self:GetParent():FindAbilityByName("aghsfort_dk_dragon_blood_active"):GetLevelSpecialValueFor("radius",1)
	self:SetStackCount(radius)
end
