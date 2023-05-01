modifier_dummy_thinker = class({})

function modifier_dummy_thinker:IsDebuff()			return false end
function modifier_dummy_thinker:IsHidden() 			return true end
function modifier_dummy_thinker:IsPurgable() 		return false end
function modifier_dummy_thinker:IsPurgeException() 	return false end
function modifier_dummy_thinker:CheckState() return {[MODIFIER_STATE_INVULNERABLE] = true, [MODIFIER_STATE_NO_HEALTH_BAR] = true} end

--[[
	@params:
	string: destroy_sound
	string: create_sound
]]

function modifier_dummy_thinker:OnCreated(keys)
	if IsServer() and IsInToolsMode() and self:GetParent():GetName() == "npc_dota_thinker" then
		self:StartIntervalThink(0.3)
		self:OnIntervalThink()
	end
	if IsServer() then
		self.kvtable = keys
		if self.kvtable.create_sound then
			self:GetParent():EmitSound(self.kvtable.create_sound)
		end
	end
end

function modifier_dummy_thinker:OnIntervalThink()
	if IsValid(self) and IsValid(self:GetParent()) then
		DebugDrawCircle(self:GetParent():GetAbsOrigin(), Vector(255,0,0), 100, 50, true, 0.3)
		if IsValid(self:GetAbility()) then
			DebugDrawText(self:GetParent():GetAbsOrigin(), self:GetAbility():GetAbilityName(), false, 0.3)
		end
	end
end

function modifier_dummy_thinker:OnDestroy()
	if IsServer() then
		if IsValid(self) and IsValid(self:GetParent()) then
			if self.kvtable.destroy_sound then
				self:GetParent():EmitSound(self.kvtable.destroy_sound)
			end
			self.kvtable = nil
			self:GetParent():RemoveSelf()
		end
	end
end

