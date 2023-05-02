-- LinkLuaModifier( "modifier_item_save_world", "items/ext/item_save_world.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if item_save_world == nil then
	item_save_world = class({})
end
function item_save_world:GetIntrinsicModifierName()
	-- return "modifier_item_save_world"
	return "modifier_item_battlefury"
end

function item_save_world:OnSpellStart()
	local tree = self:GetCursorTarget()
	
	if tree ~= nil then
		print("cut tree")
		tree:CutDown(self:GetCaster():GetTeamNumber())
	end
end
