LinkLuaModifier( "modifier_item_greater_crit_v2", "items/ext/item_greater_crit_v2.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_greater_crit_v2 == nil then
	item_greater_crit_v2 = class({})
end
function item_greater_crit_v2:GetIntrinsicModifierName()
	return "modifier_item_greater_crit_v2"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_greater_crit_v2 == nil then
	modifier_item_greater_crit_v2 = class({})
end
function modifier_item_greater_crit_v2:OnCreated(params)
	if IsServer() then
	end
end
function modifier_item_greater_crit_v2:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_item_greater_crit_v2:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_greater_crit_v2:DeclareFunctions()
	return {
	}
end