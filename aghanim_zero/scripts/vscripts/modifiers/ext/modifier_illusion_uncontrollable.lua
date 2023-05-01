modifier_illusion_uncontrollable = {}

function modifier_illusion_uncontrollable:IsDebuff()				return true end
function modifier_illusion_uncontrollable:IsHidden() 			return true end
function modifier_illusion_uncontrollable:IsPurgable() 			return false end
function modifier_illusion_uncontrollable:IsPurgeException() 	return false end
function modifier_illusion_uncontrollable:CheckState()
	return 
		{
		[MODIFIER_STATE_COMMAND_RESTRICTED]	= true,
		-- [MODIFIER_STATE_ROOTED]	= true,
		-- [MODIFIER_STATE_DISARMED]	= true,
		-- [MODIFIER_STATE_INVULNERABLE]	= true,
		-- [MODIFIER_STATE_UNSELECTABLE]	= true,
		-- [MODIFIER_STATE_NOT_ON_MINIMAP]	= true,
		-- [MODIFIER_STATE_NO_HEALTH_BAR]	= true,
		-- [MODIFIER_STATE_NO_UNIT_COLLISION]	= true,
		}
end