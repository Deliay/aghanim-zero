
modifier_ascension_firefly_display = class({})

-----------------------------------------------------------------------------------------
-- All this does is display a visible icon, useful for abilities that trigger on death for example

function modifier_ascension_firefly_display:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_ascension_firefly_display:GetTexture()
	return "events/aghanim/interface/hazard_firefly"
end
