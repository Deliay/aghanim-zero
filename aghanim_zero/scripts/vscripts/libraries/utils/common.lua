function IsValidNPC(npc)
    return npc ~= nil and not npc:IsNull()
end

function IsValid(cobject)
    return cobject ~= nil and not cobject:IsNull()
end

function IsImmortalHero(hHero)
    return hHero.bImmortal or false
end

function SetImmortalHero(hHero, bImmortal)
    hHero.bImmortal = bImmortal
end

function IsEnemy(unit1, unit2)
	if unit1:GetTeamNumber() == unit2:GetTeamNumber() then
		return false
	else
		return true
	end
end

function DirectionVector(fpos,spos)
    local DIR=( fpos - spos)
    DIR.z=0
    return DIR:Normalized()
end

function VectorDistance2D(fpos,spos)
    return ( fpos - spos):Length2D()
end

function IsAghanimConsideredHero(hNPC)
   return hNPC:IsConsideredHero() or hNPC:IsBossCreature()
end

function IsAbsoluteResist(hNPC)
	return hNPC.bAbsoluteNoCC ~= nil and hNPC.bAbsoluteNoCC == true
end

function PopupNumbers(hTarget, pfx, color, lifetime, number, presymbol, postsymbol)
	--[[
	POPUP_SYMBOL_PRE_PLUS = 0
	POPUP_SYMBOL_PRE_MINUS = 1
	POPUP_SYMBOL_PRE_SADFACE = 2
	POPUP_SYMBOL_PRE_BROKENARROW = 3
	POPUP_SYMBOL_PRE_SHADES = 4
	POPUP_SYMBOL_PRE_MISS = 5
	POPUP_SYMBOL_PRE_EVADE = 6
	POPUP_SYMBOL_PRE_DENY = 7
	POPUP_SYMBOL_PRE_ARROW = 8

	POPUP_SYMBOL_POST_EXCLAMATION = 0
	POPUP_SYMBOL_POST_POINTZERO = 1
	POPUP_SYMBOL_POST_MEDAL = 2
	POPUP_SYMBOL_POST_DROP = 3
	POPUP_SYMBOL_POST_LIGHTNING = 4
	POPUP_SYMBOL_POST_SKULL = 5
	POPUP_SYMBOL_POST_EYE = 6
	POPUP_SYMBOL_POST_SHIELD = 7
	POPUP_SYMBOL_POST_POINTFIVE = 8
	]]
	local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
	local pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_ABSORIGIN, hTarget) -- target:GetOwner()

	local digits = 0
	if number ~= nil then
		digits = #tostring(number)
	end
	if presymbol ~= nil then
		digits = digits + 1
	end
	if postsymbol ~= nil then
		digits = digits + 1
	end
	local a = postsymbol or 0
	ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(presymbol), tonumber(number), a))
	ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
	ParticleManager:SetParticleControl(pidx, 3, color)
	ParticleManager:ReleaseParticleIndex(pidx)
end
