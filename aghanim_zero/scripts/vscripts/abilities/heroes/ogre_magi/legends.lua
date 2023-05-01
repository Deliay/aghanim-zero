require("modifiers/ext/modifier_legend_base")
require("abilities/ext/ability_legend_base")
-- 
aghsfort_ogre_magi_legend_fireblast_unref = class(ability_legend_base)

function aghsfort_ogre_magi_legend_fireblast_unref:OnUpgrade()
    local caster = self:GetCaster()
    local ability = caster:FindAbilityByName("aghsfort_ogre_magi_unrefined_fireblast")
    if ability ~= nil then
        print("grant abilitiy unrefined!")
        ability:SetHidden(false)
    end
end

modifier_aghsfort_ogre_magi_legend_fireblast_unref=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_ogre_magi_legend_fireblast_unref", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_ogre_magi_legend_fireblast_aoe = class(ability_legend_base)

function aghsfort_ogre_magi_legend_fireblast_aoe:Init()
    local blast = self:GetCaster():FindAbilityByName("aghsfort_ogre_magi_fireblast")
    if IsValid(blast) then
        blast.shard_aoe = self
    end
    local unrefined = self:GetCaster():FindAbilityByName("aghsfort_ogre_magi_unrefined_fireblast")
    if IsValid(unrefined) then
        unrefined.shard_aoe = self
    end
end

modifier_aghsfort_ogre_magi_legend_fireblast_aoe=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_ogre_magi_legend_fireblast_aoe", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_ogre_magi_legend_fireblast_atk = class(ability_legend_base)

function aghsfort_ogre_magi_legend_fireblast_atk:Init()
    if IsServer() then      
        self.blasts = {
            self:GetCaster():FindAbilityByName("aghsfort_ogre_magi_fireblast"),
            self:GetCaster():FindAbilityByName("aghsfort_ogre_magi_unrefined_fireblast")
        }
        self.multicast = self:GetCaster():FindAbilityByName("aghsfort_ogre_magi_multicast")
    end
end

function aghsfort_ogre_magi_legend_fireblast_atk:doAction(kv)
    -- print("do blast attack!")
    local target = kv.target
    local caster = kv.caster
    for _, blast in pairs(self.blasts) do
        if IsValid(blast) and not blast:IsHidden() then
            blast:doAction({
                caster = caster,
                target = target,
            })
            if IsValid(self.multicast) then
                self.multicast:doAction({
                    ability = blast,
                    caster = caster,
                    target = target,
                })
            end
        end
    end
end

modifier_aghsfort_ogre_magi_legend_fireblast_atk=class(modifier_legend_base)

function modifier_aghsfort_ogre_magi_legend_fireblast_atk:OnCreated(kv)
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.parent = self:GetParent()
    self.team = self.parent:GetTeamNumber()
    self:updateData(kv)
end

function modifier_aghsfort_ogre_magi_legend_fireblast_atk:OnRefresh(kv)
    self:updateData(kv)
end

function modifier_aghsfort_ogre_magi_legend_fireblast_atk:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_FINISHED
    }
end

function modifier_aghsfort_ogre_magi_legend_fireblast_atk:OnAttackFinished(event)
    if IsServer() then
        if not IsValid(event.target) or event.target:GetName() == "" or self.parent ~= event.attacker then
            return
        end
        local filter_result = UnitFilter(event.target, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
        0, self.team)
        if filter_result == UF_SUCCESS then
            -- print("try proc blast attack:"..self.chance)
            if RollPseudoRandomPercentage(self.chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_5, self.parent) == true then
                self.ability:doAction({
                    caster = self.parent,
                    target = event.target
                })
            end
        end
    end
end


function modifier_aghsfort_ogre_magi_legend_fireblast_atk:updateData(kv)
    if IsServer() then
        self.chance = self.ability:GetSpecialValueFor("chance")
    end
end

LinkLuaModifier("modifier_aghsfort_ogre_magi_legend_fireblast_atk", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_ogre_magi_legend_ignite_ground = class(ability_legend_base)

function aghsfort_ogre_magi_legend_ignite_ground:Init()
    self.ignite = self:GetCaster():FindAbilityByName("aghsfort_ogre_magi_ignite")
    if IsValid(self.ignite) then
        self.ignite.shard_ground = self
    end
end

function aghsfort_ogre_magi_legend_ignite_ground:doAction(kv)
    local pos = kv.pos
    local caster = self:GetCaster()
    local duration = kv.duration * self:GetSpecialValueFor("duration_mul")
    CreateModifierThinker(caster, self, "modifier_aghsfort_ogre_magi_ignite_ground_thinker", {
        duration = duration
    }, pos, caster:GetTeam(), false)
end

modifier_aghsfort_ogre_magi_legend_ignite_ground=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_ogre_magi_legend_ignite_ground", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_ogre_magi_ignite_ground_thinker = {}
LinkLuaModifier("modifier_aghsfort_ogre_magi_ignite_ground_thinker", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)
function modifier_aghsfort_ogre_magi_ignite_ground_thinker:IsAura()
    return true
end
function modifier_aghsfort_ogre_magi_ignite_ground_thinker:GetModifierAura()
    return "modifier_aghsfort_ogre_magi_ignite_ground"
end
function modifier_aghsfort_ogre_magi_ignite_ground_thinker:GetAuraSearchTeam()
    return self.ability.ignite:GetAbilityTargetTeam()
end
function modifier_aghsfort_ogre_magi_ignite_ground_thinker:GetAuraSearchType()
    return self.ability.ignite:GetAbilityTargetType()
end
function modifier_aghsfort_ogre_magi_ignite_ground_thinker:GetAuraSearchFlags()
    return self.ability.ignite:GetAbilityTargetFlags()
end
function modifier_aghsfort_ogre_magi_ignite_ground_thinker:GetAuraRadius()
    return self.radius
end
function modifier_aghsfort_ogre_magi_ignite_ground_thinker:OnCreated(kv)
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.radius = self.ability:GetSpecialValueFor("aoe")
    if IsServer() then
        self:playEffects()
        GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self.radius, false)
    end
end

function modifier_aghsfort_ogre_magi_ignite_ground_thinker:playEffects(kv)
    local pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_om/ogre_magi_ignite_ground.vpcf", PATTACH_WORLDORIGIN, nil );
    ParticleManager:SetParticleControl( pfx, 0, self:GetParent():GetOrigin() );
    ParticleManager:SetParticleControl( pfx, 1, self:GetParent():GetOrigin() );
    ParticleManager:SetParticleControl( pfx, 2, Vector( self:GetDuration(), 0, 0 ) );
    ParticleManager:ReleaseParticleIndex( pfx );
end

modifier_aghsfort_ogre_magi_ignite_ground = {}
LinkLuaModifier("modifier_aghsfort_ogre_magi_ignite_ground", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_ogre_magi_ignite_ground:OnCreated(kv)
    if IsServer() then
        self.parent = self:GetParent()
        self.ability = self:GetAbility()
        self.caster = self.ability:GetCaster()
        self.damage_table = {
            victim = self.parent,
			attacker = self.caster,
			damage = 0,
			damage_type = self.ability.ignite:GetAbilityDamageType(),
			ability = self.ability.ignite,
			damage_category = DOTA_DAMAGE_CATEGORY_SPELL
        }
    end
    self:updateData(kv)
    if IsServer() then
        self:StartIntervalThink(self.interval)
    end
end

function modifier_aghsfort_ogre_magi_ignite_ground:OnIntervalThink()
    if IsServer() then
        local ignite_mod = self.parent:FindModifierByName("modifier_aghsfort_ogre_magi_ignite")
		if IsValid(ignite_mod) then
            ignite_mod:SetDuration(math.max(self.ignite_duration, ignite_mod:GetRemainingTime() + self.interval), true)
		else
			self.parent:AddNewModifier(self.parent, self.ability.ignite, "modifier_aghsfort_ogre_magi_ignite", {duration = self.ignite_duration})
		end
        -- print("ground damage:"..self.damage_table.damage)
        ApplyDamage(self.damage_table)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, self.damage_table.victim, self.damage_table.damage, nil)
    end
end

function modifier_aghsfort_ogre_magi_ignite_ground:updateData(kv)
    if IsServer() then
        self.interval = self.ability:GetSpecialValueFor("interval")
        self.ignite_duration = self.ability.ignite:GetSpecialValueFor("duration")
		self.damage_table.damage = (self.ability.ignite:GetSpecialValueFor("burn_damage") + GetTalentValue(self.caster, "ogre_magi_ignite+damage")) * self.interval
    end
end

-- 
aghsfort_ogre_magi_legend_ignite_splash = class(ability_legend_base)

function aghsfort_ogre_magi_legend_ignite_splash:Init()
    self.ignite = self:GetCaster():FindAbilityByName("aghsfort_ogre_magi_ignite")
    if IsValid(self.ignite) then
        self.ignite.shard_splash = self
    end
end

function aghsfort_ogre_magi_legend_ignite_splash:doAction(kv)
    local target = kv.target
    target:AddNewModifier(self:GetCaster(), self, "modifier_aghsfort_ogre_magi_ignite_splash", {})
end
function aghsfort_ogre_magi_legend_ignite_splash:stopAction(kv)
    local target = kv.target
    if IsValid(target) then
        target:RemoveModifierByName("modifier_aghsfort_ogre_magi_ignite_splash")
    end
end

modifier_aghsfort_ogre_magi_legend_ignite_splash=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_ogre_magi_legend_ignite_splash", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_ogre_magi_ignite_splash={}

LinkLuaModifier("modifier_aghsfort_ogre_magi_ignite_splash", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_ogre_magi_ignite_splash:IsHidden()
    return true
end

function modifier_aghsfort_ogre_magi_ignite_splash:OnCreated(kv)
    if IsServer() then
        self.parent = self:GetParent()
        self.ability = self:GetAbility()
        self.caster = self.ability:GetCaster()
        self.damage_table = {
            victim = self.parent,
			attacker = self.caster,
			damage = 0,
			ability = self.ability.ignite,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			damage_category = DOTA_DAMAGE_CATEGORY_SPELL,
            damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR
        }
    end
    self:updateData(kv)
end

function modifier_aghsfort_ogre_magi_ignite_splash:OnRefresh(kv)
    self:updateData(kv)
end

function modifier_aghsfort_ogre_magi_ignite_splash:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_aghsfort_ogre_magi_ignite_splash:OnAttackLanded(event)
    if IsServer() then
        if event.target == self.parent and IsValid(event.attacker) and event.attacker:GetName() ~= "" then
            self.damage_table.attacker = event.attacker
            self.damage_table.damage = (event.damage or 0) * self.splash_mul
            local enemies = FindUnitsInRadius(self.caster:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
            for _, enemy in pairs(enemies) do
                if enemy ~= self.parent then
                    self.damage_table.victim = enemy
                    ApplyDamage(self.damage_table)
                end
            end
            self:playEffects()
        end
    end
end

function modifier_aghsfort_ogre_magi_ignite_splash:updateData(kv)
    if IsServer() then
        self.splash_mul = math.abs(self.ability.ignite:GetSpecialValueFor("slow_movement_speed_pct")) * 0.01
        self.aoe = self.ability:GetSpecialValueFor("aoe")
    end
end
function modifier_aghsfort_ogre_magi_ignite_splash:playEffects(kv)
	local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_jakiro/jakiro_liquid_fire_explosion.vpcf", PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(pfx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), false)
	ParticleManager:ReleaseParticleIndex(pfx)
	EmitSoundOn("Hero_DragonKnight.ProjectileImpact", self.parent)
end
-- 
-- 剩余持续时间越长，伤害越高
aghsfort_ogre_magi_legend_ignite_stack = class(ability_legend_base)

function aghsfort_ogre_magi_legend_ignite_stack:Init()
    self.ignite = self:GetCaster():FindAbilityByName("aghsfort_ogre_magi_ignite")
    if IsValid(self.ignite) then
        self.ignite.shard_stack = self
    end
end

modifier_aghsfort_ogre_magi_legend_ignite_stack=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_ogre_magi_legend_ignite_stack", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_ogre_magi_legend_bloodlust_multicast = class(ability_legend_base)

function aghsfort_ogre_magi_legend_bloodlust_multicast:Init()
    self.bloodlust = self:GetCaster():FindAbilityByName("aghsfort_ogre_magi_bloodlust")
    self.multicast = self:GetCaster():FindAbilityByName("aghsfort_ogre_magi_multicast")
    if IsValid(self.bloodlust) then
        self.bloodlust.shard_multicast = self
    end
end

function aghsfort_ogre_magi_legend_bloodlust_multicast:doAction(kv)
    if self.multicast:GetLevel() < 1 then
        return
    end
    local target = kv.target
    local caster = self:GetCaster()
    -- print(target == caster)
    -- print(target:HasModifier("modifier_aghsfort_ogre_magi_multicast"))
    if target ~= caster and not target:HasModifier("modifier_aghsfort_ogre_magi_multicast") then
        print("add multicast!")
        print(self.multicast:GetName())
        target:AddNewModifier(caster, self.multicast, "modifier_aghsfort_ogre_magi_multicast", {})
    end
end

function aghsfort_ogre_magi_legend_bloodlust_multicast:stopAction(kv)
    local target = kv.target
    local caster = self:GetCaster()
    if target ~= caster and IsValid(target) then
        print("remove multicast!")
        target:RemoveModifierByName("modifier_aghsfort_ogre_magi_multicast")
    end
end

modifier_aghsfort_ogre_magi_legend_bloodlust_multicast=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_ogre_magi_legend_bloodlust_multicast", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_ogre_magi_legend_bloodlust_shield = class(ability_legend_base)

function aghsfort_ogre_magi_legend_bloodlust_shield:Init()
    self.caster = self:GetCaster()
    self.blast = self.caster:FindAbilityByName("aghsfort_ogre_magi_fireblast")
    self.bloodlust = self.caster:FindAbilityByName("aghsfort_ogre_magi_bloodlust")
    self.multicast = self.caster:FindAbilityByName("aghsfort_ogre_magi_multicast")
    if IsValid(self.bloodlust) then
        self.bloodlust.shard_shield = self
    end
end

function aghsfort_ogre_magi_legend_bloodlust_shield:OnProjectileHit(hTarget, vLocation)
    if IsValid(hTarget) then
        local caster = self:GetCaster()
        if IsValid(self.blast) then 
            self.blast:doAction({
                caster = caster,
                target = hTarget,
            })
            if IsValid(self.multicast) then
                self.multicast:doAction({
                    ability = self.blast,
                    caster = caster,
                    target = hTarget,
                })
            end
        end
    end
end

function aghsfort_ogre_magi_legend_bloodlust_shield:doAction(kv)
    print("add shield!")
    local target = kv.target
    local caster = self:GetCaster()
    target:AddNewModifier(caster, self, "modifier_aghsfort_ogre_magi_bloodlust_shield", {})
end

function aghsfort_ogre_magi_legend_bloodlust_shield:stopAction(kv)
    local target = kv.target
    local caster = self:GetCaster()
    if IsValid(target) then
        target:RemoveModifierByName("modifier_aghsfort_ogre_magi_bloodlust_shield")
    end
end

modifier_aghsfort_ogre_magi_legend_bloodlust_shield=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_ogre_magi_legend_bloodlust_shield", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_ogre_magi_bloodlust_shield={}

LinkLuaModifier("modifier_aghsfort_ogre_magi_bloodlust_shield", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_ogre_magi_bloodlust_shield:GetTexture()
    return "ogre_magi_smash"
end
function modifier_aghsfort_ogre_magi_bloodlust_shield:OnCreated(kv)
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self.team = self.parent:GetTeamNumber()
    if IsServer() then
        self.projectile_info = {
            Target = nil,
            Source = self.parent,
            Ability = self.ability,
            EffectName = "particles/units/heroes/hero_ogre_magi/ogre_magi_fire_shield_projectile.vpcf",
            iMoveSpeed = self.ability:GetSpecialValueFor("projectile_speed"),
            -- vSourceLoc= vLocation,
            bDrawsOnMinimap = false,
            bDodgeable = true,
            bIsAttack = false,
            bVisibleToEnemies = true,
            bReplaceExisting = false,
            bProvidesVision = false,
        }
    end
    self:updateData(kv)
    if IsServer() then
        self:playEffects(true)
    end
end
function modifier_aghsfort_ogre_magi_bloodlust_shield:OnRefresh(kv)
    self:updateData(kv)
    if IsServer() then
        self:playEffects(false)
    end
end

function modifier_aghsfort_ogre_magi_bloodlust_shield:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK,
    }
end
function modifier_aghsfort_ogre_magi_bloodlust_shield:GetModifierTotal_ConstantBlock(event)
    if IsServer() then
        -- print(event.target:GetName())
        if self:GetStackCount() > 0 then
            if IsValid(event.attacker) and event.attacker:GetName() ~= "" then
                if self.team ~= event.attacker:GetTeamNumber() then        
                    if event.damage > self.thres then
                        self:DecrementStackCount()
                        self.projectile_info.Target = event.attacker
                        ProjectileManager:CreateTrackingProjectile(self.projectile_info)
                    end            
                end
            end
            -- Do something
            self:playEffects(false)
            self.parent:EmitSound("Hero_OgreMagi.FireShield.Damage")
            self:StartIntervalThink(self.stack_time)
            print("block!"..self.block_damage)
            return self.block_damage
        end
    end
    return 0
end
function modifier_aghsfort_ogre_magi_bloodlust_shield:OnIntervalThink()
    if IsServer() then
        if self:GetStackCount() < self.max_stacks then
            self:IncrementStackCount()
            self:playEffects(false)
        end
    end
end
function modifier_aghsfort_ogre_magi_bloodlust_shield:updateData(kv)
    if IsServer() then
        self.max_stacks = self.ability:GetSpecialValueFor("max_stack")
        self.stack_time = self.ability:GetSpecialValueFor("stack_time")
        self.block_damage = self.ability.blast:GetSpecialValueFor("fireblast_damage") + GetTalentValue(self.caster, "ogre_magi_fireblast+damage")
        self.thres = self.ability:GetSpecialValueFor("damage_thres")

        if self.ability.blast:GetLevel() < 1 then
            self.max_stacks = 0
        end
        self:SetStackCount(self.max_stacks)
    end
end
function modifier_aghsfort_ogre_magi_bloodlust_shield:playEffects(bStart)
    if bStart then
       self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_fire_shield.vpcf", PATTACH_CUSTOMORIGIN, self.parent)
       ParticleManager:SetParticleControlEnt(self.pfx, 0, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, Vector(0,0,100), false)
       ParticleManager:SetParticleControl(self.pfx, 1, Vector(3, 0, 0))
       ParticleManager:SetParticleControl(self.pfx, 9, Vector(1, 0, 0))
       ParticleManager:SetParticleControl(self.pfx, 10, Vector(1, 0, 0))
       ParticleManager:SetParticleControl(self.pfx, 11, Vector(1, 0, 0))
       self:AddParticle(self.pfx, false, false, 15, false, false)
       EmitSoundOn("Hero_OgreMagi.FireShield.Target", self.parent)
    end
    local stacks = self:GetStackCount()
    for i = 1, 3, 1 do
        if i <= stacks then
            ParticleManager:SetParticleControl(self.pfx, 8 + i, Vector(1, 0, 0))
        else
            ParticleManager:SetParticleControl(self.pfx, 8 + i, Vector(0, 0, 0))
        end
    end
end

-- 
aghsfort_ogre_magi_legend_bloodlust_str = class(ability_legend_base)

function aghsfort_ogre_magi_legend_bloodlust_str:Init()
    self.caster = self:GetCaster()
    self.bloodlust = self.caster:FindAbilityByName("aghsfort_ogre_magi_bloodlust")
    if IsValid(self.bloodlust) then
        self.bloodlust.shard_str = self
    end
end

modifier_aghsfort_ogre_magi_legend_bloodlust_str=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_ogre_magi_legend_bloodlust_str", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_ogre_magi_legend_multicast_midas = class(ability_legend_base)

function aghsfort_ogre_magi_legend_multicast_midas:OnUpgrade()
    local caster = self:GetCaster()
    GrantItemDropToHero(caster, "item_hand_of_midas")
end

modifier_aghsfort_ogre_magi_legend_multicast_midas=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_ogre_magi_legend_multicast_midas", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_ogre_magi_legend_multicast_five = class(ability_legend_base)

function aghsfort_ogre_magi_legend_multicast_five:Init()
    self.caster = self:GetCaster()
    self.multicast = self.caster:FindAbilityByName("aghsfort_ogre_magi_multicast")
    if IsValid(self.multicast) then
        self.multicast.shard_five = self
    end
end

modifier_aghsfort_ogre_magi_legend_multicast_five=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_ogre_magi_legend_multicast_five", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_ogre_magi_legend_multicast_stupid = class(ability_legend_base)

modifier_aghsfort_ogre_magi_legend_multicast_stupid=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_ogre_magi_legend_multicast_stupid", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_ogre_magi_legend_multicast_stupid:IsHidden()
    return true
end

function modifier_aghsfort_ogre_magi_legend_multicast_stupid:RemoveOnDeath()
    return false
end

function modifier_aghsfort_ogre_magi_legend_multicast_stupid:OnCreated(kv)
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self.str_scale = self.ability:GetLevelSpecialValueFor("str_scale",1)
    self.transfer_mul = self.ability:GetLevelSpecialValueFor("transfer_mul", 1)
    self.str_gain = 0
    self.int_loss = 0
    -- 这个方法可以实现modifier变主属性
    if IsServer() then
		if self.parent:IsRealHero() then
			self.primary = self.parent:GetPrimaryAttribute()
			self.parent:SetPrimaryAttribute(DOTA_ATTRIBUTE_ALL)
		end
    end
    self:OnIntervalThink()
    self:StartIntervalThink(0.3)
end

function modifier_aghsfort_ogre_magi_legend_multicast_stupid:OnIntervalThink()

    local agi = self.parent:GetAgility()
    self.str_gain = agi * self.transfer_mul
    -- print("base int:"..int_base)
    -- print("transfer:"..self.str_gain)
    -- self.parent:AddNewModifier(self.parent, self.ability, "modifier_aghsfort_ogre_magi_multicast_stupid", {duration = 0.3})
    -- 这样他就更新啦！
    if IsServer() then
        self.parent:CalculateStatBonus(true)
    end
end

function modifier_aghsfort_ogre_magi_legend_multicast_stupid:OnRemoved(kv)
    if IsServer() then
        if self.primary then
            self.parent:SetPrimaryAttribute(self.primary)
        end
    end
end

function modifier_aghsfort_ogre_magi_legend_multicast_stupid:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_MODEL_SCALE
    }
end

function modifier_aghsfort_ogre_magi_legend_multicast_stupid:GetModifierBonusStats_Strength()
    return self.str_gain
end

function modifier_aghsfort_ogre_magi_legend_multicast_stupid:GetModifierBonusStats_Intellect()
    return -self.int_loss
end

function modifier_aghsfort_ogre_magi_legend_multicast_stupid:GetModifierModelScale()
    return self.parent:GetStrength() * self.str_scale
end

-- modifier_aghsfort_ogre_magi_multicast_stupid=class(modifier_legend_base)

-- LinkLuaModifier("modifier_aghsfort_ogre_magi_multicast_stupid", "abilities/heroes/ogre_magi/legends",LUA_MODIFIER_MOTION_NONE)

-- modifier_aghsfort_ogre_magi_multicast_stupid = {}

-- function modifier_aghsfort_ogre_magi_multicast_stupid:IsHidden()
--     return true
-- end
