require("modifiers/ext/modifier_legend_base")
require("abilities/ext/ability_legend_base")
-- 
aghsfort_lion_legend_impale_split = class(ability_legend_base)

function aghsfort_lion_legend_impale_split:Init()
    self.impale = self:GetCaster():FindAbilityByName("aghsfort_lion_impale")
    if IsValid(self.impale) then
        self.impale.shard_split = self
    end
end

function aghsfort_lion_legend_impale_split:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if IsValid(self.impale) then
        local dir = Vector(ExtraData.x, ExtraData.y, 0)
        if IsValid(hTarget) then
            dir = - hTarget:GetForwardVector()
        end
        local action_table = {
            caster = self:GetCaster(),
            pos = vLocation,
            direction = dir,
            length = ExtraData.length,
            thinker_id = ExtraData.thinker_id,
            canSplit = false,
        }

        local lines = self:GetSpecialValueFor("pieces")
        local angle = QAngle(0, 360.0/lines, 0)
        for i = 1, lines do
            self.impale:doAction(action_table)
            action_table.direction = (RotatePosition(Vector(0,0,0), angle, action_table.direction)):Normalized()
        end

    end
    return true
end

function aghsfort_lion_legend_impale_split:doAction(kv)
    local projectile_info = kv.projectile_info
    local length = kv.length * self:GetSpecialValueFor("length_pct")
    local dir_x = kv.dir_x
    local dir_y = kv.dir_y
    
    projectile_info.Ability = self
    projectile_info.ExtraData.length = length
    projectile_info.ExtraData.x = dir_x
    projectile_info.ExtraData.y = dir_y
    projectile_info.ExtraData.canSplit = false
    ProjectileManager:CreateLinearProjectile(projectile_info)
end

modifier_aghsfort_lion_legend_impale_split=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_lion_legend_impale_split", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_lion_legend_impale_shred = class(ability_legend_base)

function aghsfort_lion_legend_impale_shred:Init()
    self.caster = self:GetCaster()
    self.impale = self.caster:FindAbilityByName("aghsfort_lion_impale")
    if IsValid(self.impale) then
        self.impale.shard_shred = self
    end
    self.finger = self.caster:FindAbilityByName("aghsfort_lion_finger_of_death")
    if IsValid(self.finger) then
        self.finger.shard_shred = self
    end
end

function aghsfort_lion_legend_impale_shred:doAction(kv)
    local target = kv.target
    target:AddNewModifier(self.caster, self, "modifier_aghsfort_lion_impale_shred", {duration = self:GetSpecialValueFor("duration")})
end

modifier_aghsfort_lion_legend_impale_shred=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_lion_legend_impale_shred", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_lion_impale_shred={}

LinkLuaModifier("modifier_aghsfort_lion_impale_shred", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_lion_impale_shred:IsHidden()
    return true
end

-- 
aghsfort_lion_legend_impale_tripple = class(ability_legend_base)

function aghsfort_lion_legend_impale_tripple:Init()
    self.impale = self:GetCaster():FindAbilityByName("aghsfort_lion_impale")
    if IsValid(self.impale) then
        self.impale.shard_tripple = self
    end
end

function aghsfort_lion_legend_impale_tripple:doAction(kv)
    local pos = kv.pos
    local dir = kv.direction
    local length = kv.length

    local action_table = {
        caster = self:GetCaster(),
        pos = pos,
        direction = dir,
        length = length,
        canSplit = true,
    }
    -- print(dir)

    local deg = self:GetSpecialValueFor("angle")
    action_table.direction = (RotatePosition(Vector(0,0,0), QAngle(0, deg, 0), dir)):Normalized()
    self.impale:doAction(action_table)
    action_table.direction = (RotatePosition(Vector(0,0,0), QAngle(0, -deg, 0), dir)):Normalized()
    self.impale:doAction(action_table)
end

modifier_aghsfort_lion_legend_impale_tripple=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_lion_legend_impale_tripple", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_lion_legend_voodoo_gold = class(ability_legend_base)

function aghsfort_lion_legend_voodoo_gold:Init()
    self.caster = self:GetCaster()
    self.hex = self:GetCaster():FindAbilityByName("aghsfort_lion_voodoo")
    if IsValid(self.hex) then
        self.hex.shard_gold = self
    end
end

function aghsfort_lion_legend_voodoo_gold:doAction(kv)
    local duration = kv.duration
    local target = kv.target
    target:AddNewModifier(self.caster, self, "modifier_aghsfort_lion_voodoo_gold", {duration = duration})
end

function aghsfort_lion_legend_voodoo_gold:stopAction(kv)
    local target = kv.target
    target:RemoveModifierByName("modifier_aghsfort_lion_voodoo_gold")
end

modifier_aghsfort_lion_legend_voodoo_gold=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_lion_legend_voodoo_gold", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)
modifier_aghsfort_lion_voodoo_gold={}

LinkLuaModifier("modifier_aghsfort_lion_voodoo_gold", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_lion_voodoo_gold:IsHidden()
    return true
end

function modifier_aghsfort_lion_voodoo_gold:IsPurgable()
    return false
end

function modifier_aghsfort_lion_voodoo_gold:OnCreated(kv)
    -- print("gold bag modifier!")
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
    self:updateData(kv)
end
function modifier_aghsfort_lion_voodoo_gold:OnRefresh(kv)
    self:updateData(kv)
end

function modifier_aghsfort_lion_voodoo_gold:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

-- 这个是减免后的伤害
function modifier_aghsfort_lion_voodoo_gold:OnTakeDamage(event)
    if IsServer() then
        -- print(event.unit:GetUnitName())
        -- print("take damage:"..event.damage)
        if event.unit == self.parent then
            if event.damage > self.thres then
                local gold = self.gold
                if event.damage > self.mul_thres then
                    gold = gold * self.mul
                end
                local pos = self.parent:GetAbsOrigin()
                print("launch gold!"..gold)
                LaunchGoldBag(gold, pos, pos + RandomVector(RandomFloat(100, 300)), self.life_time)
            end
        end
    end
end

function modifier_aghsfort_lion_voodoo_gold:updateData(kv)
    if IsServer() then
        self.gold = self.ability:GetSpecialValueFor("gold")
        self.thres = self.ability:GetSpecialValueFor("thres")
        self.mul_thres = self.ability:GetSpecialValueFor("mul_thres")
        self.mul = self.ability:GetSpecialValueFor("mul")
        self.life_time = self.ability:GetSpecialValueFor("life_time")
    end
end
-- 
aghsfort_lion_legend_voodoo_aoe = class(ability_legend_base)

function aghsfort_lion_legend_voodoo_aoe:Init()
    self.caster = self:GetCaster()
    self.hex = self:GetCaster():FindAbilityByName("aghsfort_lion_voodoo")
    if IsValid(self.hex) then
        self.hex.shard_aoe = self
    end
end

modifier_aghsfort_lion_legend_voodoo_aoe=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_lion_legend_voodoo_aoe", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_lion_legend_voodoo_death = class(ability_legend_base)

function aghsfort_lion_legend_voodoo_death:Init()
    self.caster = self:GetCaster()
    self.hex = self:GetCaster():FindAbilityByName("aghsfort_lion_voodoo")
    if IsValid(self.hex) then
        self.hex.shard_barbecue = self
    end
    self.finger = self.caster:FindAbilityByName("aghsfort_lion_finger_of_death")
    if IsValid(self.finger) then
        self.finger.shard_barbecue = self
    end
end

modifier_aghsfort_lion_legend_voodoo_death=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_lion_legend_voodoo_death", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_lion_legend_drain_ally = class(ability_legend_base)

function aghsfort_lion_legend_drain_ally:Init()
    self.caster = self:GetCaster()
    self.drain = self.caster:FindAbilityByName("aghsfort_lion_mana_drain")
    if IsValid(self.drain) then
        self.drain.shard_ally = self
    end
end

modifier_aghsfort_lion_legend_drain_ally=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_lion_legend_drain_ally", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_lion_legend_drain_tripple = class(ability_legend_base)

function aghsfort_lion_legend_drain_tripple:Init()
    self.caster = self:GetCaster()
    self.drain = self.caster:FindAbilityByName("aghsfort_lion_mana_drain")
    if IsValid(self.drain) then
        self.drain.shard_tripple = self
    end
end

function aghsfort_lion_legend_drain_tripple:doAction(kv)
    local caster = kv.caster
	local target = kv.target
    
    if IsValid(self.drain) then
        local range = self:GetSpecialValueFor("search_range")
        local count = self:GetSpecialValueFor("extra_targets")
        local team = caster:GetTeamNumber()
        
        local target_flags = bit.bor(self.drain:GetAbilityTargetFlags(), DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE)
        local enemies = FindUnitsInRadius(team, target:GetAbsOrigin(), nil, range, self.drain:GetAbilityTargetTeam(), self.drain:GetAbilityTargetType(), target_flags, FIND_ANY_ORDER, false)

        for _, enemy in pairs(enemies) do
            if count == 0 then
                break
            end
            if enemy ~= target then 
                self.drain:doAction({
                    caster = caster,
                    target = enemy,
                    bChannel = true
                })

                if IsValid(self.drain.hex) and IsValid(self.drain.hex.shard_barbecue) then
                    self.drain.hex:doAction({
                        caster = caster,
                        target = enemy,
                    })
                end

                count = count - 1
            end
        end

        caster:AddNewModifier(caster, self, "modifier_aghsfort_lion_drain_tripple", {
        })
    end
end

function aghsfort_lion_legend_drain_tripple:stopAction(kv)
    local caster = kv.caster
    caster:RemoveModifierByName("modifier_aghsfort_lion_drain_tripple")
end
    
modifier_aghsfort_lion_legend_drain_tripple=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_lion_legend_drain_tripple", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_lion_drain_tripple={}

LinkLuaModifier("modifier_aghsfort_lion_drain_tripple", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)


function modifier_aghsfort_lion_drain_tripple:IsDebuff()
    return false
end

function modifier_aghsfort_lion_drain_tripple:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end


function modifier_aghsfort_lion_drain_tripple:GetStatusEffectName()
	return "particles/status_fx/status_effect_avatar.vpcf"
end


function modifier_aghsfort_lion_drain_tripple:CheckState()
    return {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true
    }
end

function modifier_aghsfort_lion_drain_tripple:OnCreated(kv)
    self.parent = self:GetParent()
    self:updateData(kv)
end

function modifier_aghsfort_lion_drain_tripple:OnRefresh(kv)
    self:updateData(kv)
end

function modifier_aghsfort_lion_drain_tripple:updateData(kv)
    if IsServer() then
        self.parent:Purge(false, true, false, true, true)
	    EmitSoundOn( "DOTA_Item.BlackKingBar.Activate", self.parent )
    end
end

-- 
aghsfort_lion_legend_drain_amp = class(ability_legend_base)

function aghsfort_lion_legend_drain_amp:Init()
    self.caster = self:GetCaster()
    self.drain = self.caster:FindAbilityByName("aghsfort_lion_mana_drain")
    if IsValid(self.drain) then
        self.drain.shard_amp = self
    end
end

modifier_aghsfort_lion_legend_drain_amp=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_lion_legend_drain_amp", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_lion_drain_amp={}

LinkLuaModifier("modifier_aghsfort_lion_drain_amp", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_lion_drain_amp:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_aghsfort_lion_drain_amp:OnCreated(kv)
    self.ability = self:GetAbility()
    self:updateData(kv)
end

function modifier_aghsfort_lion_drain_amp:OnRefresh(kv)
    self:updateData(kv)
end

function modifier_aghsfort_lion_drain_amp:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
    }
end

function modifier_aghsfort_lion_drain_amp:GetModifierSpellAmplify_Percentage()
    -- print(self.amp_stack)
    return self:GetStackCount() * self.amp_stack
end

function modifier_aghsfort_lion_drain_amp:updateData(kv)
    local amp_base = 0
    if IsValid(self.ability.drain) then
        amp_base = self.ability.drain:GetSpecialValueFor("movespeed") * self.ability.drain:GetSpecialValueFor("tick_interval")
        print(amp_base)
    end
    self.amp_stack = self.ability:GetSpecialValueFor("amp_slow") * amp_base
end

-- 
aghsfort_lion_legend_finger_charge = class(ability_legend_base)

function aghsfort_lion_legend_finger_charge:Init()
    self.caster = self:GetCaster()
    self.finger = self.caster:FindAbilityByName("aghsfort_lion_finger_of_death")
    if IsValid(self.finger) then
        self.finger.shard_charge = self
    end
end

modifier_aghsfort_lion_legend_finger_charge=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_lion_legend_finger_charge", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_lion_legend_finger_charge:OnCreated(kv)
    if IsServer() then
        self.ability = self:GetAbility()
        self._charges = self.ability:GetLevelSpecialValueFor("charges", 1)
        self.bInit = false
        -- self.level = 0
        self:StartIntervalThink(0.5)
    end
end

function modifier_aghsfort_lion_legend_finger_charge:OnIntervalThink()
    if IsServer() then
        -- print("think!")
		if IsValid(self.ability.finger) then
            if not self.bInit and self.ability.finger:GetLevel() > 0 then
                AbilityChargeController:AbilityChargeInitialize(self.ability.finger, self.ability.finger:GetCooldown(self.ability.finger:GetLevel() - 1), self._charges, 1, true, true)
                self.bInit = true
                self:StartIntervalThink(-1)
		    end
        end
    end
end
-- 
aghsfort_lion_legend_finger_aoe = class(ability_legend_base)

function aghsfort_lion_legend_finger_aoe:Init()
    self.caster = self:GetCaster()
    self.finger = self.caster:FindAbilityByName("aghsfort_lion_finger_of_death")
    if IsValid(self.finger) then
        self.finger.shard_aoe = self
    end
end

modifier_aghsfort_lion_legend_finger_aoe=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_lion_legend_finger_aoe", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)
-- 
aghsfort_lion_legend_finger_doom = class(ability_legend_base)

function aghsfort_lion_legend_finger_doom:Init()
    self.caster = self:GetCaster()
    self.finger = self.caster:FindAbilityByName("aghsfort_lion_finger_of_death")
    if IsValid(self.finger) then
        self.finger.shard_doom = self
    end
end

function aghsfort_lion_legend_finger_doom:doAction(kv)
    local caster = kv.caster
    local target = kv.target
    local duration = kv.duration
    local damage = kv.damage
    -- print("doom action!")
    target:AddNewModifier(caster, self, "modifier_aghsfort_lion_finger_doom", {duration = duration, damage = damage})
end

modifier_aghsfort_lion_legend_finger_doom=class(modifier_legend_base)

LinkLuaModifier("modifier_aghsfort_lion_legend_finger_doom", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)

modifier_aghsfort_lion_finger_doom = {}

LinkLuaModifier("modifier_aghsfort_lion_finger_doom", "abilities/heroes/lion/legends",LUA_MODIFIER_MOTION_NONE)

function modifier_aghsfort_lion_finger_doom:IsPurgable()
    return false
end

function modifier_aghsfort_lion_finger_doom:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_aghsfort_lion_finger_doom:IsHidden()
    return true
end

function modifier_aghsfort_lion_finger_doom:GetEffectName() return "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf" end
function modifier_aghsfort_lion_finger_doom:GetEffectAttachType() return PATTACH_ABSORIGIN_FOLLOW end
function modifier_aghsfort_lion_finger_doom:GetStatusEffectName() return "particles/status_fx/status_effect_doom.vpcf" end
function modifier_aghsfort_lion_finger_doom:StatusEffectPriority() return 15 end

function modifier_aghsfort_lion_finger_doom:CheckState()
    return {
        [MODIFIER_STATE_SILENCED] = true,
        [MODIFIER_STATE_MUTED] = true,
        [MODIFIER_STATE_PASSIVES_DISABLED] = true,
    }
end


function modifier_aghsfort_lion_finger_doom:OnCreated(kv)
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
    if IsServer() then
        self.damage_table = {
            victim = self.parent,
            attacker = self.ability:GetCaster(),
            damage = 0,
            damage_type = DAMAGE_TYPE_PURE,
            ability = self.ability,
        }
        self.parent:Purge(true, false, false, false, false)
    end
    self:updateData(kv)
    if IsServer() then
        self:StartIntervalThink(1.0)
    end
end

function modifier_aghsfort_lion_finger_doom:OnRefresh(kv)
    self:updateData(kv)
end

function modifier_aghsfort_lion_finger_doom:OnIntervalThink()
    if IsServer() then
        ApplyDamage(self.damage_table)
    end
end

function modifier_aghsfort_lion_finger_doom:updateData(kv)
    if IsServer() then
        -- print("update doom!")
        self.damage_table.damage = kv.damage * self.ability:GetSpecialValueFor("damage_mul")
    end
end
