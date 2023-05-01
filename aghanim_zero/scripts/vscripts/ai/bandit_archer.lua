
--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	thisEntity.hArrowAbility = thisEntity:FindAbilityByName( "bandit_archer_arrow" )

	thisEntity.flRetreatRange = 600
	thisEntity.flAttackRange = thisEntity.hArrowAbility:GetCastRange( thisEntity:GetOrigin(), nil )
	thisEntity.PreviousOrder = "no_order"
	thisEntity.fRetreatCooldown = 5

	thisEntity:SetContextThink( "BanditArcherThink", BanditArcherThink, 0.5 )
end

--------------------------------------------------------------------------------

function BanditArcherThink()
	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if not thisEntity.bInitialized then
		for i = 0, DOTA_ITEM_MAX - 1 do
			local item = thisEntity:GetItemInSlot( i )
			if item and item:GetAbilityName() == "item_bandit_archer_shadow_blade" then
				thisEntity.hShadowBladeAbility = item
			end
		end

		thisEntity.bInitialized = true
	end

	if GameRules:IsGamePaused() == true then
		return 0.1
	end
	
	local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, thisEntity.flAttackRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false )
	if #hEnemies == 0 then
		return 0.1
	end

	local fHealthPctInvis = 15
	if thisEntity:GetHealthPercent() <= fHealthPctInvis and thisEntity.hShadowBladeAbility and thisEntity.hShadowBladeAbility:IsFullyCastable() then
		return CastShadowBlade()
	end

	if thisEntity:IsInvisible() then
		-- Force a retreat, even if we've retreated recently
		local hNearestEnemy = hEnemies[ 1 ]
		return Retreat( hNearestEnemy )
	end

	local hAttackTarget = nil
	local hApproachTarget = nil
	for _, hEnemy in pairs( hEnemies ) do
		if hEnemy ~= nil and hEnemy:IsAlive() then
			local flDist = ( hEnemy:GetOrigin() - thisEntity:GetOrigin() ):Length2D()
			if flDist < thisEntity.flRetreatRange then
				if ( thisEntity.fTimeOfLastRetreat and ( GameRules:GetGameTime() < thisEntity.fTimeOfLastRetreat + thisEntity.fRetreatCooldown ) ) then
					-- We already retreated recently, so just attack
					hAttackTarget = hEnemy
				else
					return Retreat( hEnemy )
				end
			end
			if flDist <= thisEntity.flAttackRange then
				hAttackTarget = hEnemy
			end
			if flDist > thisEntity.flAttackRange then
				hApproachTarget = hEnemy
			end
		end
	end

	if hAttackTarget == nil and hApproachTarget ~= nil then
		return Approach( hApproachTarget )
	end

	if hAttackTarget and thisEntity.hArrowAbility ~= nil and thisEntity.hArrowAbility:IsFullyCastable() then
		return CastArrow( hAttackTarget )
	end

	if hAttackTarget then
		thisEntity:FaceTowards( hAttackTarget:GetOrigin() )
		return HoldPosition()
	end

	return 0.1
end

--------------------------------------------------------------------------------

function CastArrow( hEnemy )
	--print( "ai_bandit_archer - CastArrow" )

	local fDist = ( hEnemy:GetOrigin() - thisEntity:GetOrigin() ):Length2D()
	local vTargetPos = hEnemy:GetOrigin()

	if ( fDist > 400 ) and hEnemy and hEnemy:IsMoving() then
		local vLeadingOffset = hEnemy:GetForwardVector() * RandomInt( 200, 400 )
		vTargetPos = hEnemy:GetOrigin() + vLeadingOffset
	end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = vTargetPos,
		AbilityIndex = thisEntity.hArrowAbility:entindex(),
		Queue = false,
	})

	return 2
end

--------------------------------------------------------------------------------

function Approach(unit)
	--print( "ai_bandit_archer - Approach" )

	local vToEnemy = unit:GetOrigin() - thisEntity:GetOrigin()
	vToEnemy = vToEnemy:Normalized()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = thisEntity:GetOrigin() + vToEnemy * thisEntity:GetIdealSpeed()
	})

	return 1
end

--------------------------------------------------------------------------------

function Retreat(unit)
	--print( "ai_bandit_archer - Retreat" )

	local vAwayFromEnemy = thisEntity:GetOrigin() - unit:GetOrigin()
	vAwayFromEnemy = vAwayFromEnemy:Normalized()
	local vMoveToPos = thisEntity:GetOrigin() + vAwayFromEnemy * thisEntity:GetIdealSpeed()

	-- if away from enemy is an unpathable area, find a new direction to run to
	local nAttempts = 0
	while ( ( not GridNav:CanFindPath( thisEntity:GetOrigin(), vMoveToPos ) ) and ( nAttempts < 5 ) ) do
		vMoveToPos = thisEntity:GetOrigin() + RandomVector( thisEntity:GetIdealSpeed() )
		nAttempts = nAttempts + 1
	end

	thisEntity.fTimeOfLastRetreat = GameRules:GetGameTime()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = vMoveToPos,
	})

	return 1.25
end

--------------------------------------------------------------------------------

function HoldPosition()
	--print( "ai_bandit_archer - Hold Position" )
	if thisEntity.PreviousOrder == "hold_position" then
		return 0.5
	end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_HOLD_POSITION,
		Position = thisEntity:GetOrigin()
	})

	thisEntity.PreviousOrder = "hold_position"

	return 0.5
end

--------------------------------------------------------------------------------

function CastShadowBlade()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.hShadowBladeAbility:entindex(),
		Queue = false,
	})

	return 0.5
end

--------------------------------------------------------------------------------
