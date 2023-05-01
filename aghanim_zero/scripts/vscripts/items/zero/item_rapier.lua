LinkLuaModifier( "modifier_item_rapier", "items/zero/item_rapier.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_rapier == nil then
	item_rapier = class({})
end
function item_rapier:GetIntrinsicModifierName()
	return "modifier_item_rapier"
end
---------------------------------------------------------------------
--Modifiers
if modifier_item_rapier == nil then
	modifier_item_rapier = class({})
end
function modifier_item_rapier:OnCreated(params)
	if IsServer() then
	end
end
function modifier_item_rapier:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_item_rapier:OnDestroy()
	if IsServer() then
	end
end
function modifier_item_rapier:DeclareFunctions()
	return {
	}
end