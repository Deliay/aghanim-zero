require( "map_encounter" )
require( "aghanim_utility_functions" )
require( "spawner" )
require( "encounters/encounter_trap_base" )

--------------------------------------------------------------------------------

if CMapEncounter_DungeonTraps == nil then
	CMapEncounter_DungeonTraps = class( {}, {}, CMapEncounter_TrapBase )
end

--------------------------------------------------------------------------------

function CMapEncounter_DungeonTraps:GetPreviewUnit()
	return "npc_dota_arrow_trap"
end

--------------------------------------------------------------------------------

function CMapEncounter_DungeonTraps:CheckForCompletion()
      if not IsServer() then
            return
      end
      local bIsComplete = CMapEncounter_TrapBase.CheckForCompletion( self )
      if bIsComplete then
         self:DisableTraps()
      end

      return bIsComplete
end

--------------------------------------------------------------------------------

function CMapEncounter_DungeonTraps:DisableTraps()
	--print("Disabling Traps!")
	-- Disable any traps in the map
	local hRelays = self:GetRoom():FindAllEntitiesInRoomByName( "disable_traps_relay", false )
	--local hRelays = Entities:FindAllByName( "disable_traps_relay" )
	for _, hRelay in pairs( hRelays ) do
		hRelay:Trigger( nil, nil )
	end
end

--------------------------------------------------------------------------------

return CMapEncounter_DungeonTraps
