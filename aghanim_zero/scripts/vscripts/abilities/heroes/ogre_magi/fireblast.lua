LinkLuaModifier( "modifier_aghsfort_ogre_magi_fireblast", "abilities/heroes/ogre_magi/fireblast.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if aghsfort_ogre_magi_fireblast == nil then
	aghsfort_ogre_magi_fireblast = class({})
end
function aghsfort_ogre_magi_fireblast:GetIntrinsicModifierName()
	return "modifier_aghsfort_ogre_magi_fireblast"
end

function aghsfort_ogre_magi_fireblast:GetCastRange()
	return self:GetSpecialValueFor("cast_range")
end


function aghsfort_ogre_magi_fireblast:GetCooldown(iLevel)
    local cooldown = self.BaseClass.GetCooldown(self, iLevel) - GetTalentValue(self:GetCaster(),"ogre_magi_fireblast-cd")
    -- print(cooldown)
    return math.max(cooldown, 0)
end

function aghsfort_ogre_magi_fireblast:OnSpellStart()
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()

	if IsValid(target) then
		self:doAction({
			caster = caster,
			target = target,
		})
	end
end

function aghsfort_ogre_magi_fireblast:doAction(kv)
	local caster = kv.caster
	local target = kv.target
	local damage = self:GetSpecialValueFor("fireblast_damage") + GetTalentValue(self:GetCaster(), "ogre_magi_fireblast+damage")
	local duration = self:GetSpecialValueFor("stun_duration")
	if IsValid(target) then
		self:playEffects({
			caster = caster,
			target = target
		})
		local damage_table = {
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self,
			damage_category = DOTA_DAMAGE_CATEGORY_SPELL
		}
		ApplyDamage(damage_table)
		AddModifierConsiderResist(target, caster, self, "modifier_stunned", {duration = duration})
		if IsValid(self.shard_aoe) then
			local radius = self.shard_aoe:GetSpecialValueFor("aoe")
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
			for _, enemy in pairs(enemies) do
				if IsValid(enemy) and enemy ~= target then
					damage_table.victim = enemy
					ApplyDamage(damage_table)
				end
			end
		end
	end
end

function aghsfort_ogre_magi_fireblast:playEffects(kv)
	local target = kv.target
	local caster = kv.caster
	EmitSoundOn("Hero_OgreMagi.Fireblast.Cast", caster)
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fireblast.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(pfx, 1, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(pfx)
	EmitSoundOn("Hero_OgreMagi.Fireblast.Target", target)
end

---------------------------------------------------------------------
--Modifiers
if modifier_aghsfort_ogre_magi_fireblast == nil then
	modifier_aghsfort_ogre_magi_fireblast = class({})
end
function modifier_aghsfort_ogre_magi_fireblast:IsHidden()
	return true
end
function modifier_aghsfort_ogre_magi_fireblast:OnCreated(params)
	if IsServer() then
	end
end
function modifier_aghsfort_ogre_magi_fireblast:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_aghsfort_ogre_magi_fireblast:OnDestroy()
	if IsServer() then
	end
end
function modifier_aghsfort_ogre_magi_fireblast:DeclareFunctions()
	return {
	}
end