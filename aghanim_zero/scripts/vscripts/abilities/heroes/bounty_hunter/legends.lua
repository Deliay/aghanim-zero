require("modifiers/ext/modifier_legend_base")
require("abilities/ext/ability_legend_base")
-- 
aghsfort_bounty_hunter_legend_toss_track = class(ability_legend_base)

function aghsfort_bounty_hunter_legend_toss_track:Init()
    self.shuriken = self:GetCaster():FindAbilityByName("aghsfort_bounty_hunter_shuriken_toss")
    if IsValid(self.shuriken) then
        self.shuriken.shard_track = self
    end
end

modifier_aghsfort_bounty_hunter_legend_toss_track=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_toss_track", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_bounty_hunter_legend_toss_jinada = class(ability_legend_base)

function aghsfort_bounty_hunter_legend_toss_jinada:Init()
    self.shuriken = self:GetCaster():FindAbilityByName("aghsfort_bounty_hunter_shuriken_toss")
    if IsValid(self.shuriken) then
        self.shuriken.shard_jinada = self
    end
end

modifier_aghsfort_bounty_hunter_legend_toss_jinada=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_toss_jinada", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_bounty_hunter_legend_toss_tripple = class(ability_legend_base)

function aghsfort_bounty_hunter_legend_toss_tripple:Init()
    self.shuriken = self:GetCaster():FindAbilityByName("aghsfort_bounty_hunter_shuriken_toss")
    if IsValid(self.shuriken) then
        self.shuriken.shard_tripple = self
    end
end

modifier_aghsfort_bounty_hunter_legend_toss_tripple=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_toss_tripple", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_bounty_hunter_legend_jinada_konyiji = class(ability_legend_base)

function aghsfort_bounty_hunter_legend_jinada_konyiji:Init()
    self.caster = self:GetCaster()
    self.jinada = self.caster:FindAbilityByName("aghsfort_bounty_hunter_jinada")
    if IsValid(self.jinada) then
        self.jinada.shard_konyiji = self
    end
    if IsServer() then
        self.book_list = {
            "item_torrent_effect_potion",
            "item_shadow_wave_effect_potion",
            "item_book_of_strength",
            "item_book_of_agility",
            "item_book_of_intelligence",
            "item_tome_of_knowledge",
            "item_book_of_strength",
            "item_book_of_agility",
            "item_book_of_intelligence",
            "item_tome_of_knowledge"
        }
        self.act_mul = {
            ["item_torrent_effect_potion"] = 0,
            ["item_shadow_wave_effect_potion"] = 0,
            ["item_book_of_strength"] = 1,
            ["item_book_of_agility"] = 1,
            ["item_book_of_intelligence"] = 1,
            ["item_tome_of_knowledge"] = 2,
        }
    end
end

function aghsfort_bounty_hunter_legend_jinada_konyiji:doAction(kv)
    local iBookToGrant = RandomInt(1, #self.book_list)

    local nBooks = 1
    -- print(CAghanim:GetPlayerCurrentRoom(self:GetCaster():GetPlayerOwnerID()))
    local passive_mod = self.caster:FindModifierByName(self:GetIntrinsicModifierName())
    if IsValid(passive_mod) then
        print("Current Act:"..passive_mod:GetStackCount())
        nBooks = nBooks + (passive_mod:GetStackCount() - 1) * self.act_mul[self.book_list[iBookToGrant]]
    end

	self.caster:EmitSoundParams( "Item.BattlePointsClaimed", 0, 0.5, 0)
    
    local item = nil
    
    for i = 1, nBooks do
        item = GrantItemDropToHero(self.caster, self.book_list[iBookToGrant])
    end
    if IsValid(item) then
        -- print("kong yi ji!"..item:GetModelName())
        local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_bh/kongyiji.vpcf", PATTACH_OVERHEAD_FOLLOW, self.caster)
        ParticleManager:SetParticleControl(pfx, PATTACH_OVERHEAD_FOLLOW, Vector(0,0,40))
        -- ParticleManager:SetParticleControlEnt(pfx, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin() + Vector(0,0,40), true)
        ParticleManager:ReleaseParticleIndex(pfx)
    end
end

modifier_aghsfort_bounty_hunter_legend_jinada_konyiji=class(modifier_legend_base)

function modifier_aghsfort_bounty_hunter_legend_jinada_konyiji:OnCreated(kv)
    self:StartIntervalThink(30)
    self:OnIntervalThink()
end
function modifier_aghsfort_bounty_hunter_legend_jinada_konyiji:RemoveOnDeath()
    return false
end
function modifier_aghsfort_bounty_hunter_legend_jinada_konyiji:OnIntervalThink()
    local nDepth = 1
	local depth = CustomNetTables:GetTableValue( "encounter_state", "depth" )
	if depth ~= nil then
		nDepth = depth["1"]
	end
    print("current depth:"..nDepth)
    self:SetStackCount(math.floor(nDepth / 7) + 1)
end

LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_jinada_konyiji", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_bounty_hunter_legend_jinada_loan = class(ability_legend_base)

function aghsfort_bounty_hunter_legend_jinada_loan:Init()
    self.caster = self:GetCaster()
    self.jinada = self.caster:FindAbilityByName("aghsfort_bounty_hunter_jinada")
    
    local loan = self:GetCaster():FindAbilityByName("aghsfort_bounty_hunter_loan")
    if IsValid(loan) then
        if IsValid(self.jinada) then
            loan.jinada = self.jinada
        end
        if IsServer() then
            loan:SetLevel(1)
            loan:SetHidden(false)
            print("unlock!")
        end
    end
end

modifier_aghsfort_bounty_hunter_legend_jinada_loan=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_jinada_loan", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)

-- 
aghsfort_bounty_hunter_legend_jinada_murder = class(ability_legend_base)

function aghsfort_bounty_hunter_legend_jinada_murder:Init()
    self.caster = self:GetCaster()
    self.jinada = self.caster:FindAbilityByName("aghsfort_bounty_hunter_jinada")
    if IsValid(self.jinada) then
        self.jinada.shard_murder = self
    end
end

modifier_aghsfort_bounty_hunter_legend_jinada_murder=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_jinada_murder", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_bounty_hunter_legend_walk_windy = class(ability_legend_base)

function aghsfort_bounty_hunter_legend_walk_windy:Init()
    self.caster = self:GetCaster()
    self.wind_walk = self.caster:FindAbilityByName("aghsfort_bounty_hunter_wind_walk")
    if IsValid(self.wind_walk) then
        self.wind_walk.shard_windy = self
    end
end
function aghsfort_bounty_hunter_legend_walk_windy:doAction(kv)
    local target = kv.target
    if IsValid(self.wind_walk) then        
        target:AddNewModifier(self.caster, self, "modifier_aghsfort_bounty_hunter_legend_walk_windy_buff",{
            duration = self.wind_walk:GetSpecialValueFor("slow_duration") + GetTalentValue(self.caster, "aghsfort_bounty_hunter_wind_walk+slow")
        })
    end
end

modifier_aghsfort_bounty_hunter_legend_walk_windy=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_walk_windy", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_bounty_hunter_legend_walk_windy_buff = {}
LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_walk_windy_buff", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)
function modifier_aghsfort_bounty_hunter_legend_walk_windy_buff:GetEffectName()
    return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf"
end
function modifier_aghsfort_bounty_hunter_legend_walk_windy_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_aghsfort_bounty_hunter_legend_walk_windy_buff:OnCreated(kv)
    self.ability = self:GetAbility()
    self:updateData(kv)
end
function modifier_aghsfort_bounty_hunter_legend_walk_windy_buff:OnRefresh(kv)
    self:updateData(kv)
end
function modifier_aghsfort_bounty_hunter_legend_walk_windy_buff:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DODGE_PROJECTILE,
        MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
    }
end
function modifier_aghsfort_bounty_hunter_legend_walk_windy_buff:GetModifierDodgeProjectile()
    return 1
end
function modifier_aghsfort_bounty_hunter_legend_walk_windy_buff:GetModifierEvasion_Constant(event)
    return self.evasion
end
function modifier_aghsfort_bounty_hunter_legend_walk_windy_buff:GetModifierAttackSpeedPercentage()
    return self.as_pct
end

function modifier_aghsfort_bounty_hunter_legend_walk_windy_buff:updateData(kv)
    if IsValid(self.ability.wind_walk) then
        self.evasion = self.ability.wind_walk:GetSpecialValueFor("slow") * self.ability:GetSpecialValueFor("evasion_mul")
        self.as_pct = self.ability.wind_walk:GetSpecialValueFor("slow") * self.ability:GetSpecialValueFor("as_mul")
    end
end
-- 
aghsfort_bounty_hunter_legend_walk_pickup = class(ability_legend_base)

function aghsfort_bounty_hunter_legend_walk_pickup:Init()
    self.caster = self:GetCaster()
    self.wind_walk = self.caster:FindAbilityByName("aghsfort_bounty_hunter_wind_walk")
    self.jinada = self.caster:FindAbilityByName("aghsfort_bounty_hunter_jinada")
    if IsValid(self.wind_walk) then
        self.wind_walk.shard_pickup = self
    end
end

function aghsfort_bounty_hunter_legend_walk_pickup:doAction(kv)
    local target = kv.target
    target:AddNewModifier(self.caster, self, "modifier_aghsfort_bounty_hunter_legend_walk_pickup_buff", {})
end
function aghsfort_bounty_hunter_legend_walk_pickup:stopAction(kv)
    local target = kv.target
    if IsValid(target) then
        target:RemoveModifierByName("modifier_aghsfort_bounty_hunter_legend_walk_pickup_buff")
    end
end

modifier_aghsfort_bounty_hunter_legend_walk_pickup=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_walk_pickup", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_bounty_hunter_legend_walk_pickup_buff={}
LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_walk_pickup_buff", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_bounty_hunter_legend_walk_pickup_buff:IsHidden()
    return true
end

function modifier_aghsfort_bounty_hunter_legend_walk_pickup_buff:IsPurgable()
    return false
end

function modifier_aghsfort_bounty_hunter_legend_walk_pickup_buff:OnCreated(kv)
    if IsServer() then
        self.ability = self:GetAbility()
        self.radius = self.ability:GetSpecialValueFor("radius")
        self.parent = self:GetParent()
        self.team = self.parent:GetTeamNumber()
        if IsValid(self.ability) and IsValid(self.ability.wind_walk) and IsValid(self.ability.jinada) then
            self.affected_enemies = {}
            self.steal_interval = self.ability.jinada:GetEffectiveCooldown(math.max(self.ability.jinada:GetLevel(), 1))
            self:StartIntervalThink(0.1)
        else
            self:Destroy()
        end
    end
end
function modifier_aghsfort_bounty_hunter_legend_walk_pickup_buff:OnIntervalThink()
    if IsServer() then
        local enemies = FindUnitsInRadius(self.team, self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
        for _, enemy in pairs(enemies) do
            local enemy_id = enemy:entindex()
            if self.affected_enemies[enemy_id] then
            else
                self.affected_enemies[enemy_id] = true
                self.ability.jinada:doAction({
                    target = enemy,
                    caster = self.parent,
                    bDamage = true
                })
            end
            -- if not enemy:FindModifierByNameAndCaster("modifier_aghsfort_bounty_hunter_legend_walk_pickuped", self.parent) then
            --     self.ability.jinada:doAction({
            --         target = enemy,
            --         caster = self.parent,
            --         bDamage = true
            --     })
            --     enemy:AddNewModifier(self.parent, self.ability, "modifier_aghsfort_bounty_hunter_legend_walk_pickuped", {duration = self.steal_interval})
            -- end
        end
    end
end
-- modifier_aghsfort_bounty_hunter_legend_walk_pickuped = {}
-- function modifier_aghsfort_bounty_hunter_legend_walk_pickuped:GetAttributes()
--     return MODIFIER_ATTRIBUTE_MULTIPLE
-- end
-- LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_walk_pickuped", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)
-- function modifier_aghsfort_bounty_hunter_legend_walk_pickuped:IsHidden()
--     return true
-- end
-- function modifier_aghsfort_bounty_hunter_legend_walk_pickuped:IsPurgable()
--     return false
-- end
-- 
aghsfort_bounty_hunter_legend_walk_track = class(ability_legend_base)

function aghsfort_bounty_hunter_legend_walk_track:Init()
    self.caster = self:GetCaster()
    self.wind_walk = self.caster:FindAbilityByName("aghsfort_bounty_hunter_wind_walk")
    self.track = self.caster:FindAbilityByName("aghsfort_bounty_hunter_track")
    if IsValid(self.wind_walk) then
        self.wind_walk.shard_track = self
    end
end

function aghsfort_bounty_hunter_legend_walk_track:doAction(kv)
    local target = kv.target
    target:AddNewModifier(self.caster, self, "modifier_aghsfort_bounty_hunter_legend_walk_track_buff", {})
end

function aghsfort_bounty_hunter_legend_walk_track:stopAction(kv)
    local target = kv.target
    target:RemoveModifierByName("modifier_aghsfort_bounty_hunter_legend_walk_track_buff")
end

modifier_aghsfort_bounty_hunter_legend_walk_track=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_walk_track", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_bounty_hunter_legend_walk_track_buff={}
LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_walk_track_buff", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)
function modifier_aghsfort_bounty_hunter_legend_walk_track_buff:IsHidden()
    return true
end
function modifier_aghsfort_bounty_hunter_legend_walk_track_buff:IsPurgable()
    return false
end
function modifier_aghsfort_bounty_hunter_legend_walk_track_buff:OnCreated(kv)
    if IsServer() then
        self.ability = self:GetAbility()
        self.parent = self:GetParent()
        self.team = self.parent:GetTeamNumber()
        if IsValid(self.ability) and IsValid(self.ability.wind_walk) and IsValid(self.ability.track) then
            self.radius = self.ability.track:GetEffectiveCastRange(self.parent:GetAbsOrigin(), self.parent)
            self.track_interval = self.ability.track:GetEffectiveCooldown(math.max(self.ability.track:GetLevel(), 1)) * self.ability:GetSpecialValueFor("interval_pct")
            self:StartIntervalThink(self.track_interval)
        else
            self:Destroy()
        end
    end
end
function modifier_aghsfort_bounty_hunter_legend_walk_track_buff:OnIntervalThink()
    if IsServer() then
        local enemies = FindUnitsInRadius(self.team, self.parent:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
        for _, enemy in pairs(enemies) do
            if not enemy:HasModifier("modifier_aghsfort_bounty_hunter_track") then
                self.ability.track:doAction({
                    caster = self.parent,
                    target = enemy,
                    bEffect = true
                })
                self:StartIntervalThink(self.track_interval)
                return
            end
        end
        self:StartIntervalThink(0.5)
    end
end

-- 
aghsfort_bounty_hunter_legend_track_invis = class(ability_legend_base)

function aghsfort_bounty_hunter_legend_track_invis:Init()
    self.caster = self:GetCaster()
    self.wind_walk = self.caster:FindAbilityByName("aghsfort_bounty_hunter_wind_walk")
    self.track = self.caster:FindAbilityByName("aghsfort_bounty_hunter_track")
    if IsValid(self.track) then
        self.track.shard_invis = self
    end
end

function aghsfort_bounty_hunter_legend_track_invis:doAction(kv)
    local target = kv.target
    target:AddNewModifier(self.caster, self, "modifier_aghsfort_bounty_hunter_legend_track_invis_buff", {})
end

function aghsfort_bounty_hunter_legend_track_invis:stopAction(kv)
    local target = kv.target
    if IsValid(target) then 
        target:RemoveModifierByName("modifier_aghsfort_bounty_hunter_legend_track_invis_buff")
    end
end

modifier_aghsfort_bounty_hunter_legend_track_invis=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_track_invis", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_bounty_hunter_legend_track_invis_buff = {}
LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_track_invis_buff", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_bounty_hunter_legend_track_invis_buff:IsHidden()
    return self:GetRemainingTime() <= 0 or self:GetDuration() <= 0
end
function modifier_aghsfort_bounty_hunter_legend_track_invis_buff:IsDebuff()
    return false
end

function modifier_aghsfort_bounty_hunter_legend_track_invis_buff:IsPurgable()
    return false
end
function modifier_aghsfort_bounty_hunter_legend_track_invis_buff:DestroyOnExpire()
    return false
end
function modifier_aghsfort_bounty_hunter_legend_track_invis_buff:OnCreated(kv)
    if IsServer() then
        print("track invis buff!")
        self.ability = self:GetAbility()
        self.parent = self:GetParent()
        -- self.team = self.parent:GetTeamNumber()
        if IsValid(self.ability) and IsValid(self.ability.wind_walk) and IsValid(self.ability.track) then
            self.delay = self.ability:GetSpecialValueFor("delay")
            self:StartIntervalThink(0.2)
        else
            self:Destroy()
        end
    end
end
function modifier_aghsfort_bounty_hunter_legend_track_invis_buff:OnIntervalThink()
    if IsServer() then
        if self.parent:HasModifier("modifier_aghsfort_bounty_hunter_wind_walk_invis") then
            if self:GetDuration() > 0 then
                -- print("set!")
                self:SetDuration(-1, true)
            end
        else
            if self:GetDuration() <= 0 then
                self:SetDuration(self.delay, true)
            else
                if self:GetRemainingTime() <= 0 then
                    self.ability.wind_walk:doAction({
                        target = self.parent,
                    })
                    self:SetDuration(-1, true)
                end
            end
        end
    end
end

-- 
aghsfort_bounty_hunter_legend_track_ally = class(ability_legend_base)

function aghsfort_bounty_hunter_legend_track_ally:Init()
    self.caster = self:GetCaster()
    self.track = self.caster:FindAbilityByName("aghsfort_bounty_hunter_track")
    if IsValid(self.track) then
        self.track.shard_ally = self
    end
end

modifier_aghsfort_bounty_hunter_legend_track_ally=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_track_ally", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_bounty_hunter_legend_track_pass = class(ability_legend_base)

function aghsfort_bounty_hunter_legend_track_pass:Init()
    self.caster = self:GetCaster()
    self.track = self.caster:FindAbilityByName("aghsfort_bounty_hunter_track")
    if IsValid(self.track) then
        self.track.shard_pass = self
    end
end

modifier_aghsfort_bounty_hunter_legend_track_pass=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_bounty_hunter_legend_track_pass", "abilities/heroes/bounty_hunter/legends",LUA_MODIFIER_MOTION_NONE)
