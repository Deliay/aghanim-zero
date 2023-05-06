aghsfort_nevermore_dark_lord = {}

LinkLuaModifier("modifier_aghsfort_nevermore_dark_lord_debuff", "abilities/heroes/nevermore/dark_lord",
    LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_aghsfort_nevermore_dark_lord_assault", "abilities/heroes/nevermore/dark_lord",
    LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_aghsfort_nevermore_dark_lord_overlord", "abilities/heroes/nevermore/dark_lord",
    LUA_MODIFIER_MOTION_NONE)

function aghsfort_nevermore_dark_lord:GetCastRange()
    return self:GetSpecialValueFor("radius") - self:GetCaster():GetCastRangeBonus()
end

function aghsfort_nevermore_dark_lord:OnSpellStart()
    self:doAction()
end

function aghsfort_nevermore_dark_lord:getArmorReduction()
    return self:GetSpecialValueFor("armor_reduction") +
    GetTalentValue(self:GetCaster(), "aghsfort_nevermore_dark_lord-armor")
end

function aghsfort_nevermore_dark_lord:doAction(kv)
    
    if IsServer() and self:GetLevel() > 0 then
        local caster = self:GetCaster()
        if not IsValid(self.necromastery) then
            self.necromastery = caster:FindAbilityByName("aghsfort_nevermore_necromastery")
        end
        local radius = self:GetCastRange()
        local duration = self:GetSpecialValueFor("duration")
        
        local caster = self:GetCaster()

        local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

        for _, enemy in pairs(enemies) do
            self.necromastery:suckSoul({
                target = enemy
            })
            enemy:AddNewModifier(caster, self, "modifier_aghsfort_nevermore_dark_lord_debuff", {
                duration = duration
            })
        end

        self:lordAssault({
            radius = radius,
            duration = duration
        })

        self:overlord({
            duration = duration,
            enemies = enemies
        })
        
    end
end

function aghsfort_nevermore_dark_lord:lordAssault(kv)
    local caster = self:GetCaster()
    if not IsValid(self.shard_assault) then
        self.shard_assault = caster:FindAbilityByName("aghsfort_nevermore_legend_lord_assault")
    end
    if IsValid(self.shard_assault) then
        local radius = kv.radius
        local duration = kv.duration

        local count = math.ceil(math.abs(self:getArmorReduction())/2)
        local reduction = self.shard_assault:GetSpecialValueFor("reduction")
        local assault_mod = caster:AddNewModifier(caster, self, "modifier_aghsfort_nevermore_dark_lord_assault", {
            count = count,
            reduction = reduction,
            radius = radius,
            duration = duration
        })
        if IsValid(assault_mod) then
            assault_mod:SetStackCount(count)
        end
    end
end

function aghsfort_nevermore_dark_lord:overlord(kv)
    local caster = self:GetCaster()
    if not IsValid(self.shard_overlord) then
        self.shard_overlord = caster:FindAbilityByName("aghsfort_nevermore_legend_overlord")
    end
    if IsValid(self.shard_overlord) then
        local duration = kv.duration
        local amp = self.shard_overlord:GetSpecialValueFor("amp")
        local amp_boss = self.shard_overlord:GetSpecialValueFor("amp_boss")
        local stacks = 0
        for _, enemy in pairs(kv.enemies) do
            if IsAghanimConsideredHero(enemy) then
                if enemy:IsBossCreature() then
                    stacks = stacks + amp_boss
                else
                    stacks = stacks + amp
                end
            else
                stacks = stacks + 1
            end
        end
        local overlord_mod = caster:AddNewModifier(caster, self, "modifier_aghsfort_nevermore_dark_lord_overlord", {
            duration = duration,
            model_scale = stacks
        })
        if IsValid(overlord_mod) then
            overlord_mod:SetStackCount(stacks)
        end
    end
end

modifier_aghsfort_nevermore_dark_lord_debuff = {}

function modifier_aghsfort_nevermore_dark_lord_debuff:IsPurgable()
    return false
end

function modifier_aghsfort_nevermore_dark_lord_debuff:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_aghsfort_nevermore_dark_lord_debuff:OnCreated(kv)
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    self.armor_reduction = ability:getArmorReduction()
    self.base_reduction = self.armor_reduction
    -- print("normal darkness")
    self.need_refresh = false

    local shard_darkness = caster:FindAbilityByName("aghsfort_nevermore_legend_advanced_darkness")
    if IsValid(shard_darkness) then
        -- print("advanced darkness!")
        local tick_interval = shard_darkness:GetSpecialValueFor("tick_interval")
        self.tick_increase = shard_darkness:GetSpecialValueFor("tick_increase") * self.base_reduction
        self:StartIntervalThink(tick_interval)
        self.need_refresh = true
    end
end

function modifier_aghsfort_nevermore_dark_lord_debuff:OnIntervalThink()
    self.armor_reduction = self.armor_reduction + self.tick_increase
    -- print(self.armor_reduction)
    if IsServer() then
        self:IncrementStackCount()
    end
end

function modifier_aghsfort_nevermore_dark_lord_debuff:GetModifierUnitStatsNeedsRefresh()
    return self.need_refresh
end

function modifier_aghsfort_nevermore_dark_lord_debuff:DeclareFunctions()
    return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
}
end

function modifier_aghsfort_nevermore_dark_lord_debuff:GetModifierProvidesFOWVision()
    if self:GetElapsedTime() < 0.5 then
        return 1
    end
    return 0
end

function modifier_aghsfort_nevermore_dark_lord_debuff:GetModifierPhysicalArmorBonus()
    return self.armor_reduction
end

modifier_aghsfort_nevermore_dark_lord_assault = {}

function modifier_aghsfort_nevermore_dark_lord_assault:IsPurgable()
    return false
end

function modifier_aghsfort_nevermore_dark_lord_assault:OnCreated(kv)
    if IsServer() then
        self.parent = self:GetParent()
        self:updateData(kv)
        self.multi_attacking = false
    end
end

function modifier_aghsfort_nevermore_dark_lord_assault:OnRefresh(kv)
    if IsServer() then
        self:updateData(kv)
    end
end

function modifier_aghsfort_nevermore_dark_lord_assault:updateData(kv)
    self.radius = kv.radius
    self.count = kv.count
    self.reduction = kv.reduction
    -- print("start attack up to "..self.count.."enemies in range"..self.radius)
end

function modifier_aghsfort_nevermore_dark_lord_assault:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK,
    MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,}
end

function modifier_aghsfort_nevermore_dark_lord_assault:OnAttack(event)
    if IsServer() then
        if not self.multi_attacking and IsValid(event.attacker) and event.attacker == self.parent and not event.no_attack_cooldown then
            local enemies = FindUnitsInRadius(self.parent:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.radius,
                DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
                DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
            local num = 0
            self.multi_attacking = true
            for _, enemy in pairs(enemies) do
                -- print("attack")
                self.parent:PerformAttack(enemy, false, false, true, true, true, false, false)
                num = num + 1
                if num >= self.count then
                    break
                end
            end
            self.multi_attacking = false
        end
    end
end

function modifier_aghsfort_nevermore_dark_lord_assault:GetModifierDamageOutgoing_Percentage(event)
    if event.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and self.multi_attacking then
        return -self.reduction
    end
    return 0
end

modifier_aghsfort_nevermore_dark_lord_overlord = {}

function modifier_aghsfort_nevermore_dark_lord_overlord:IsPurgable()
    return false
end

function modifier_aghsfort_nevermore_dark_lord_overlord:OnCreated( kv )
	EmitSoundOn( "DOTA_Item.BlackKingBar.Activate", self:GetParent() )
    
    self.as_stack = -self:GetAbility():getArmorReduction()
    -- print(self.as_stack)

    if IsServer() then
        self:GetParent():Purge(false, true, false, false, false)
    end
end

function modifier_aghsfort_nevermore_dark_lord_overlord:CheckState()
    return	{
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}
end

function modifier_aghsfort_nevermore_dark_lord_overlord:DeclareFunctions()
    return  
	{
		MODIFIER_PROPERTY_MODEL_SCALE,
        MODIFIER_PROPERTY_IGNORE_ATTACKSPEED_LIMIT,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end


function modifier_aghsfort_nevermore_dark_lord_overlord:GetModifierModelScale()
	return self:GetStackCount() 
end

function modifier_aghsfort_nevermore_dark_lord_overlord:GetModifierAttackSpeed_Limit()
    return 1
end

function modifier_aghsfort_nevermore_dark_lord_overlord:GetModifierAttackSpeedBonus_Constant()
    local bonus = self:GetStackCount() * self.as_stack   
    return bonus    
end

function modifier_aghsfort_nevermore_dark_lord_overlord:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end


function modifier_aghsfort_nevermore_dark_lord_overlord:GetStatusEffectName()
	return "particles/status_fx/status_effect_avatar.vpcf"
end
