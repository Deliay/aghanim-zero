require("abilities/heroes/nevermore/legends")
aghsfort_nevermore_necromastery = {}

LinkLuaModifier("modifier_aghsfort_nevermore_necromastery_collection", "abilities/heroes/nevermore/necromastery",
    LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_aghsfort_nevermore_necromastery_regen", "abilities/heroes/nevermore/necromastery",
    LUA_MODIFIER_MOTION_NONE)

function aghsfort_nevermore_necromastery:GetIntrinsicModifierName()
    return "modifier_aghsfort_nevermore_necromastery_collection"
end

function aghsfort_nevermore_necromastery:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if ExtraData ~= nil then
        if ExtraData.duration ~= nil then
            local caster = self:GetCaster()
            local duration = ExtraData.duration
            
            caster:AddNewModifier(caster, self, "modifier_aghsfort_nevermore_necromastery_regen",{
                duration = duration,
                stack_duration = duration,
                stacks = ExtraData.soul_count
            })
            return nil
        end

    end
end

function aghsfort_nevermore_necromastery:getSoulCount()
    local count = 0
    if IsServer() then
        local base_collection = self:GetCaster():FindModifierByName(
            "modifier_aghsfort_nevermore_necromastery_collection")
        local extra_collection = self:GetCaster():FindModifierByName("modifier_aghsfort_nevermore_necromastery_thirst")
        if IsValid(base_collection) then
            count = count + base_collection:GetStackCount()
        end
        if IsValid(extra_collection) then
            count = count + extra_collection:GetStackCount()
        end
    end
    return count
end

function aghsfort_nevermore_necromastery:suckSoul(kv)
    if IsServer() and self:GetLevel() > 0 then
        local collection = self:GetCaster():FindModifierByName("modifier_aghsfort_nevermore_necromastery_collection")
        if IsValid(collection) then
            collection:suckSoul(kv)
        end
    end
end

modifier_aghsfort_nevermore_necromastery_collection = {}

function modifier_aghsfort_nevermore_necromastery_collection:IsPermanent()
    return true
end

function modifier_aghsfort_nevermore_necromastery_collection:RemoveOnDeath()
    return false
end

function modifier_aghsfort_nevermore_necromastery_collection:OnCreated(kv)
    -- if IsInToolsMode() then
    --     self:SetStackCount(20)
    -- end
    -- Ability properties
    self.caster = self:GetCaster()
    -- self.requiem_ability = "pathfinder_nevermore_requiem"
    self.ability = self:GetAbility()
    self.soul_pfx = "particles/units/heroes/hero_nevermore/nevermore_necro_souls.vpcf"

    self.souls_per_kill = self.ability:GetSpecialValueFor("souls_per_kill")
    self.soul_speed = self.ability:GetSpecialValueFor("soul_speed")
    self.release_pct = self.ability:GetSpecialValueFor("soul_release")
    self.soul_projectile = {
        Target = self.caster,
        Source = nil,
        Ability = self.ability,
        EffectName = self.soul_pfx,
        bDodgeable = false,
        bProvidesVision = false,
        iMoveSpeed = self.soul_speed,
        bVisibleToEnemies = not self.caster:IsInvisible(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
    }
    self:updateData(kv)
    self:StartIntervalThink(1.0)
end

function modifier_aghsfort_nevermore_necromastery_collection:OnRefresh(kv)
    self:updateData(kv)
end

function modifier_aghsfort_nevermore_necromastery_collection:OnIntervalThink()
    if IsServer() then
        if not IsValid(self.shard_thirst) then
            self.shard_thirst = self.caster:FindAbilityByName("aghsfort_nevermore_legend_soul_thirst")
        end       
        if not IsValid(self.shard_fusion) then
            self.shard_fusion = self.caster:FindAbilityByName("aghsfort_nevermore_legend_necro_fusion")
        end
        if not IsValid(self.shard_unstable) then
            self.shard_unstable = self.caster:FindAbilityByName("aghsfort_nevermore_legend_unstable_spirit")
        end
        if not IsValid(self.requiem) then
            local requiem = self.caster:FindAbilityByName("aghsfort_nevermore_requiem")
            if requiem:GetLevel() > 0 then
                self.requiem = self.caster:FindAbilityByName("aghsfort_nevermore_requiem")
            end
        end
    end
end

function modifier_aghsfort_nevermore_necromastery_collection:updateData(kv)
    -- Ability specials
    self.damage_per_soul = self.ability:GetSpecialValueFor("damage_per_soul") +
                               GetTalentValue(self.caster, "aghsfort_nevermore_necromastery+atk")
    self.max_souls = self.ability:GetSpecialValueFor("max_souls")
    self.amp_per_soul = self.ability:GetSpecialValueFor("amp_per_soul") +
                            GetTalentValue(self.caster, "aghsfort_nevermore_necromastery+amp")

end

-- MODIFIER_PROPERTY_IGNORE_ATTACKSPEED_LIMIT 
function modifier_aghsfort_nevermore_necromastery_collection:DeclareFunctions()
    return {MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE, 
    MODIFIER_EVENT_ON_DEATH, 
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_EVENT_ON_HERO_KILLED,
    MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_aghsfort_nevermore_necromastery_collection:OnDeath(event)
    if IsServer() then
        local target = event.unit
        local attacker = event.attacker

        -- Only apply if the caster is the attacker (and NOT the victim)
        if self.caster == attacker and self.caster ~= target and self.caster:IsAlive() and
            not self.caster:PassivesDisabled() then
            self:suckSoul({
                target = target
            })

        elseif event.target == self.caster and not self.caster:IsIllusion() then
            local caster = self.caster
            print("Nevermore Died")
        end
    end
end

function modifier_aghsfort_nevermore_necromastery_collection:OnHeroKilled(event)
    if IsServer() then
        print("killed" .. event.target:GetName())
        if event.target == self.caster and not self.caster:IsIllusion() then
            -- self:DeathRattle()
        end
    end
end

function modifier_aghsfort_nevermore_necromastery_collection:OnTakeDamage(event)
    if IsServer() then
        local target = event.unit
        local attacker = event.attacker
        if self.caster == attacker and self.caster ~= target and self.caster:IsAlive() and
            not self.caster:PassivesDisabled() then
                
                if IsValid(self.shard_thirst) then
                    local chance = 0
                    if event.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
                        chance = self.shard_thirst:GetSpecialValueFor("attack_chance")
                    else
                        chance = self.shard_thirst:GetSpecialValueFor("spell_chance")
                    end
                    if RollPseudoRandomPercentage(chance, DOTA_PSEUDO_RANDOM_CUSTOM_GAME_2, self.caster) then 
                        self:suckSoul({
                            target = target
                        })
                     end
                end

            end
    end
end

function modifier_aghsfort_nevermore_necromastery_collection:DeathRattle()
    if IsServer() then
        local caster = self.caster
        -- Death requiem and soul release not available in trap room
        if caster:IsIllusion() or caster:HasModifier("modifier_aghsfort_player_transform") then
            return
        end

        -- update shards and abilities
        self:OnIntervalThink()

        local stacks = self:GetStackCount()
        local stacks_lost = math.floor(stacks * self.release_pct)
        self:removeSouls(stacks_lost)

        local souls_lost = stacks_lost
        if IsValid(self.shard_thirst) then
            souls_lost = souls_lost + self.shard_thirst:reset()
        end

        if IsValid(self.requiem) then
            self.requiem:doAction({
                souls = souls_lost,
                death_cast = 1
            })
        end
        -- Tested: if set immortal on hero killed , will not cost lives
        if IsValid(self.shard_fusion) then
            local return_souls = math.floor( self.shard_fusion:GetSpecialValueFor("return_basic") + self.shard_fusion:GetSpecialValueFor("return_level") * self.caster:GetLevel())
            if souls_lost >= return_souls then                
                print("demon never gone")
                SetImmortalHero(self.caster, true)
            end
        end
    end

end

function modifier_aghsfort_nevermore_necromastery_collection:GetModifierBaseAttack_BonusDamage()
    self:updateData()
    return self:GetStackCount() * self.damage_per_soul
end

function modifier_aghsfort_nevermore_necromastery_collection:GetModifierSpellAmplify_Percentage()
    self:updateData()
    return self:GetStackCount() * self.amp_per_soul
end

function modifier_aghsfort_nevermore_necromastery_collection:suckSoul(kv)
    if IsServer() and IsValid(kv.target) then
        -- Decide how many souls should the caster get
        local soul_count = kv.souls or self.souls_per_kill
        
        
        -- Launch a creep soul to the caster
        self.soul_projectile.Source = kv.target

        if IsValid(self.shard_fusion) then
            soul_count = soul_count * 2
            self.soul_projectile.ExtraData = {
                soul_count = soul_count,
                duration = self.shard_fusion:GetSpecialValueFor("duration")
            }
        end

        if IsValid(self.shard_unstable) and IsValid(self.requiem) then
            local lines = {}
            for i = 1, soul_count, 1 do
                table.insert(lines, RandomFloat(0.0, 360.0))
            end
            self.requiem:releaseSouls({
                origin = kv.target:GetAbsOrigin(),
                lines = lines,
                death_cast = 0,
                heal = 0,
            })
        end

        ProjectileManager:CreateTrackingProjectile(self.soul_projectile)

        -- Increase souls appropriately
        -- necromastery gain soul instantly despite visual effect
        self:increaseSouls(soul_count)
        -- If caster is not disabled and is visible, launch a soul

    end
end

function modifier_aghsfort_nevermore_necromastery_collection:increaseSouls(soul_count)
    local total_souls = self:GetStackCount() + soul_count
    local persist_souls = math.min(total_souls, self.max_souls)
    self:SetStackCount(persist_souls)

    if total_souls > persist_souls then        
        self.shard_thirst = self.caster:FindAbilityByName("aghsfort_nevermore_legend_soul_thirst")
        if IsValid(self.shard_thirst) then
            self.shard_thirst:doAction({
                souls = total_souls - persist_souls
            })
        end
    end
end

function modifier_aghsfort_nevermore_necromastery_collection:removeSouls(soul_count)
    self:SetStackCount(math.max(self:GetStackCount() - soul_count, 0))
end

modifier_aghsfort_nevermore_necromastery_regen = {}

-- Properties
function modifier_aghsfort_nevermore_necromastery_regen:IsPurgable()
    return false
end

function modifier_aghsfort_nevermore_necromastery_regen:DestroyOnExpire()
    return true
end

function modifier_aghsfort_nevermore_necromastery_regen:RemoveOnDeath()
    return true
end

function modifier_aghsfort_nevermore_necromastery_regen:OnCreated(kv)
    -- print("start stacking")
    self:updateData(kv)
end

function modifier_aghsfort_nevermore_necromastery_regen:OnRefresh(kv)
    -- print("update stacking")
    self:updateData(kv)
end

function modifier_aghsfort_nevermore_necromastery_regen:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }
end

function modifier_aghsfort_nevermore_necromastery_regen:GetModifierConstantManaRegen()
    return self.mp_regen * self:GetStackCount()
end

function modifier_aghsfort_nevermore_necromastery_regen:GetModifierConstantHealthRegen()
    return self.hp_regen * self:GetStackCount()
end

function modifier_aghsfort_nevermore_necromastery_regen:updateData(kv)
    self.mp_regen = self:GetAbility():GetSpecialValueFor("amp_per_soul") * 5
    self.hp_regen = self:GetAbility():GetSpecialValueFor("damage_per_soul")
    -- print("hp:"..self.hp_regen..", mp:"..self.mp_regen)
    self.stack_duration = (kv.stack_duration or 0)
    if IsServer() then
        IncreaseStack({
            modifier = self,
            duration = self.stack_duration,
            destroy_no_layer = 1,
            stacks = kv.stacks
        })
    end
end

