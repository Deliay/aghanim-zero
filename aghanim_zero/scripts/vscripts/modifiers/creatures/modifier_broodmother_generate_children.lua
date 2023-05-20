
-- Note: this modifier's ability gets added by hand to the dummy unit that Broodmother creates.

modifier_broodmother_generate_children = class({})

--------------------------------------------------------------------------------

function modifier_broodmother_generate_children:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_broodmother_generate_children:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_broodmother_generate_children:OnCreated( kv )
	if IsServer() then
		self.hBabies = { }

		self.spawn_interval = self:GetAbility():GetSpecialValueFor( "spawn_interval" )

		-- Note: nAmountToSpawn gets attached to the parent (a dummy) by broodmother, prior to modifier being added
		self.nAmountToSpawn = self:GetParent().nAmountToSpawn
		self.bWantsToBeRemoved = false
		self.nMaxSpawnRadius = 75 + ( self.nAmountToSpawn * 15 )

		self.szBabyUnit = "npc_dota_creature_broodmother_baby_c"

		self.nFXIndex = ParticleManager:CreateParticle( "particles/baby_brood_venom_pool.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControl( self.nFXIndex, 0, self:GetCaster():GetAbsOrigin() )
		ParticleManager:SetParticleControl( self.nFXIndex, 1, Vector( self.nMaxSpawnRadius, 1, 1 ) )

		self:StartIntervalThink( self.spawn_interval )
	end
end

--------------------------------------------------------------------------------

function modifier_broodmother_generate_children:OnIntervalThink()
	if IsServer() then
		if #self.hBabies < self.nAmountToSpawn then
			self:CreateBaby()
		end

		if self.bWantsToBeRemoved == false and #self.hBabies >= self.nAmountToSpawn then
			self.bWantsToBeRemoved = true
		end

		if self.bWantsToBeRemoved then
			self:TryToRemoveMyself()
		end
	end
end

--------------------------------------------------------------------------------

function modifier_broodmother_generate_children:CreateBaby()
	local hBaby = CreateUnitByName( self.szBabyUnit, self:GetParent():GetAbsOrigin(), true, self:GetParent(), self:GetParent(), self:GetParent():GetTeamNumber() )

	local nMaxDistance = 75 + ( #self.hBabies * 15 )
	local vSpawnLoc = nil

	local nMaxAttempts = 7
	local nAttempts = 0

	repeat
		if nAttempts > nMaxAttempts then
			vSpawnLoc = nil
			printf( "WARNING - modifier_broodmother_generate_children:CreateBaby() - failed to find valid spawn loc for baby spider" )
			break
		end

		local vPos = self:GetParent():GetAbsOrigin() + RandomVector( nMaxDistance )
		vSpawnLoc = FindPathablePositionNearby( vPos, 0, 100 )
		nAttempts = nAttempts + 1
	until ( GameRules.Aghanim:GetCurrentRoom():IsInRoomBounds( vSpawnLoc ) )

	if hBaby and vSpawnLoc ~= nil then
		table.insert( self.hBabies, hBaby )

		hBaby:SetInitialGoalEntity( self:GetParent().hInitialGoalEntity )
		hBaby:SetDeathXP( 0 )
		hBaby:SetMinimumGoldBounty( 0 )
		hBaby:SetMaximumGoldBounty( 0 )

		local kv =
		{
			vLocX = vSpawnLoc.x,
			vLocY = vSpawnLoc.y,
			vLocZ = vSpawnLoc.z,
		}
		hBaby:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_frostivus2018_broodbaby_launch", kv )

		EmitSoundOn( "Creature_Broodmother.CreateBabySpider", hBaby )
	end
end

--------------------------------------------------------------------------------

function modifier_broodmother_generate_children:TryToRemoveMyself()
	if IsServer() then
		-- Are all my babies done with their movement modifier?
		self.bSafeToRemove = true
		for _, hBaby in pairs( self.hBabies ) do
			if hBaby ~= nil and hBaby:IsNull() == false and hBaby:IsAlive() and hBaby:HasModifier( "modifier_frostivus2018_broodbaby_launch" ) then
				self.bSafeToRemove = false
			end
		end

		if self.bSafeToRemove then
			self:Destroy()
			return
		end
	end
end

--------------------------------------------------------------------------------

function modifier_broodmother_generate_children:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nFXIndex, false )
		self:GetParent():Kill( nil, nil )
		UTIL_Remove( self:GetParent() )
	end
end

--------------------------------------------------------------------------------
