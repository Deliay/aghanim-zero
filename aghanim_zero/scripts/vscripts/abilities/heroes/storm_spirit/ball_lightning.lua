aghsfort_storm_spirit_ball_lightning = {}

LinkLuaModifier("modifier_aghsfort_storm_spirit_ball_lightning_thinker", "abilities/heroes/storm_spirit/ball_lightning",
    LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_aghsfort_storm_spirit_ball_lightning_travel", "abilities/heroes/storm_spirit/ball_lightning",
LUA_MODIFIER_MOTION_HORIZONTAL)

function aghsfort_storm_spirit_ball_lightning:Init()
    self.caster = self:GetCaster()
end

function aghsfort_storm_spirit_ball_lightning:OnUpgrade()
    self.ability_remnant = self.caster:FindAbilityByName("aghsfort_storm_spirit_static_remnant")
    self.ability_overload = self.caster:FindAbilityByName("aghsfort_storm_spirit_overload")
end

function aghsfort_storm_spirit_ball_lightning:GetBehavior()
    if IsValid(self.shard_ally) then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES + DOTA_ABILITY_BEHAVIOR_AUTOCAST
    end
    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
end

function aghsfort_storm_spirit_ball_lightning:GetManaCost()
    local max_mana = self:GetCaster():GetMaxMana()
    self._last_manacost = self:GetSpecialValueFor("ball_lightning_initial_mana_base") + max_mana * self:GetSpecialValueFor("ball_lightning_initial_mana_percentage") * 0.01
    return self._last_manacost
end

function aghsfort_storm_spirit_ball_lightning:GetCastRange()
    if IsServer() then
        return 0
    end
    return self:GetSpecialValueFor("ball_lightning_aoe") - self:GetCaster():GetCastRangeBonus()
end

function aghsfort_storm_spirit_ball_lightning:OnSpellStart()
    local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
    if caster:HasModifier("modifier_aghsfort_storm_spirit_ball_lightning_travel") then
        caster:SetMana(caster:GetMana() + self._last_manacost)
    else
        caster:AddNewModifier(caster, self, "modifier_aghsfort_storm_spirit_ball_lightning_travel", {pos_x = pos.x, pos_y = pos.y, pos_z = pos.z})
        ProjectileManager:ProjectileDodge(caster)
    end
end

modifier_aghsfort_storm_spirit_ball_lightning_thinker = {}

function modifier_aghsfort_storm_spirit_ball_lightning_thinker:OnCreated(kv)
    if IsServer() then
        self.parent = self:GetParent()
        self.team = self.parent:GetTeamNumber()
        self.ability = self:GetAbility()
        self.caster = self.ability:GetCaster()
        self.vision = self.ability:GetSpecialValueFor("ball_lightning_vision_radius")
        -- self.vision = 2000
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_aghsfort_storm_spirit_ball_lightning_thinker:OnIntervalThink()
    if IsServer() then
        if IsValid(self.caster) then
            self.parent:SetAbsOrigin(self.caster:GetAbsOrigin())
            AddFOWViewer(self.team, self.parent:GetAbsOrigin(), self.vision, 0.3, false)
        end
    end
end


modifier_aghsfort_storm_spirit_ball_lightning_travel = {}

function modifier_aghsfort_storm_spirit_ball_lightning_travel:GetPriority()
    return MODIFIER_PRIORITY_HIGH
end
function modifier_aghsfort_storm_spirit_ball_lightning_travel:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        -- [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
    }
end

function modifier_aghsfort_storm_spirit_ball_lightning_travel:OnCreated(kv)
    if IsServer() then
        self.parent = self:GetParent()
        self.team = self.parent:GetTeamNumber()
        self.ability = self:GetAbility()
        self.caster = self.ability:GetCaster()
        self.team = self.parent:GetTeamNumber()
        self.target_pos = Vector(kv.pos_x, kv.pos_y, kv.pos_z)

        self.mana_base = self.ability:GetSpecialValueFor("ball_lightning_travel_cost_base")
        self.mana_pct = self.ability:GetSpecialValueFor("ball_lightning_travel_cost_percent") * 0.01
        self.radius = self.ability:GetSpecialValueFor("ball_lightning_aoe")
        self.speed = self.ability:GetSpecialValueFor("ball_lightning_move_speed")
        self.damage_delta = self.ability:GetSpecialValueFor("damage")
        
        self.travel_record={
            pos = self.parent:GetAbsOrigin(),
            dx = 0,
            total_distance = 0,
        }

        self.damage_table = {
            victim = nil,
            attacker = self.caster,
            damage = 0,
            damage_type = self.ability:GetAbilityDamageType(),
            ability = self.ability,
            damage_category = DOTA_DAMAGE_CATEGORY_SPELL
        }

        self.damage_record = {}

        if self.parent == self.caster then
            self.thinker = CreateModifierThinker(self.caster, self.ability, "modifier_aghsfort_storm_spirit_ball_lightning_thinker", {}, self.caster:GetAbsOrigin(), self.team, false)

            if IsValid(self.ability.ability_remnant) and self.ability.ability_remnant:GetLevel() > 0 then
                local remnant_interval = GetTalentValue(self.parent, "storm_spirit_ball_lightning+remnant")
                if remnant_interval > 0 then
                    self.auto_remnant_record = {
                        interval = remnant_interval,
                        last_distance = 0,
                    }
                end
            end

            self.bAutocast = self.ability:GetAutoCastState()
        end
        self:playEffects(true)

        if IsValid(self.ability.shard_fenzy) then
            self.ability.shard_fenzy:doAction({
                target = self.parent
            })
        end
        -- self:StartIntervalThink(FrameTime())
        if not self:ApplyHorizontalMotionController() then
            self:Destroy()
            return
        end
    end
    self:updateData(kv)
end
function modifier_aghsfort_storm_spirit_ball_lightning_travel:OnRefresh(kv)
    self:updateData(kv)
end

function modifier_aghsfort_storm_spirit_ball_lightning_travel:UpdateHorizontalMotion(me, dt)
    if IsServer() then
        if self.parent:IsStunned() or self.parent:IsHexed() then
            self:Destroy()
        end

        local distance = VectorDistance2D(self.target_pos, self.travel_record.pos)
        if distance < 50 then
            -- print("lightning arrives")
            self:Destroy()
        end
        -- self:blockerTest(distance, dt)

        local direction = DirectionVector(self.target_pos, self.travel_record.pos)
        local delta = self.speed * dt

        self.travel_record.dx = self.travel_record.dx + delta
        if self.travel_record.dx > 100 then
            self.travel_record.dx = self.travel_record.dx - 100
            self.travel_record.total_distance = self.travel_record.total_distance + 100

            if self.parent == self.caster then
                -- cost mana
                local manacost = self.mana_base + self.parent:GetMaxMana() * self.mana_pct
                if self.parent:GetMana() < manacost then
                    self:onFailure()
                    return
                else
                    self.parent:SpendMana(manacost, self.ability)
                end

                if self.auto_remnant_record then
                    if self.travel_record.total_distance - self.auto_remnant_record.last_distance > self.auto_remnant_record.interval then
                        self.auto_remnant_record.last_distance = self.travel_record.total_distance
                        if IsValid(self.ability.ability_remnant) and self.ability.ability_remnant:GetLevel() > 0 then                            
                            self.ability.ability_remnant:doAction({
                                caster = self.caster,
                                pos = self.caster:GetAbsOrigin(),
                            })
                            self.ability.ability_overload:charge({})
                        end
                        -- self.ability.ability_remnant:CastAbility()
                        -- self.ability.ability_remnant:EndCooldown()
                        -- self.parent:GiveMana(self.ability.ability_remnant:GetManaCost(self.ability.ability_remnant:GetLevel()))
                    end
                end

                if self.bAutocast and IsValid(self.ability.shard_ally) then
                    self.ability.shard_ally:doAction({
                        pos = self.travel_record.pos,
                        target_pos = self.target_pos
                    })
                end
            end

            self.damage_table.damage = self.damage_table.damage + self.damage_delta
            local enemies = FindUnitsInRadius(self.team, self.travel_record.pos, nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

            if IsValid(self.ability.shard_overload) then
                for _, enemy in pairs(enemies) do
                    local enemy_id = enemy:entindex()
                    if self.damage_record[enemy_id] then
                    else
                        self.ability.shard_overload:doAction({
                            parent = self.parent,
                            pos = enemy:GetAbsOrigin()
                        })
                        break
                    end
                end
            end

            for _, enemy in pairs(enemies) do
                local enemy_id = enemy:entindex()
                if self.damage_record[enemy_id] then
                else
                    self.damage_record[enemy_id] = true
                    self.damage_table.victim = enemy
                    ApplyDamage(self.damage_table)
                    print("ball damage:"..self.damage_table.damage)
                end
            end

            if IsValid(self.ability.shard_fenzy) then
                self.ability.shard_fenzy:update({
                    target = self.parent
                })
            end
        end

        
        self.travel_record.pos = GetGroundPosition(self.travel_record.pos + direction * delta, nil)

        self.parent:SetAbsOrigin(self.travel_record.pos)
        GridNav:DestroyTreesAroundPoint(self.travel_record.pos, 100, true)
    end
end

-- function modifier_aghsfort_storm_spirit_ball_lightning_travel:blockerTest(newDistance, dt)
--     if self.blocker == nil then
--         self.blocker = {
--             last_value = VectorDistance2D(self.target_pos, self.travel_record.pos),
--             thres = 0.8 * self.speed,
--             frame_count = 0,
--             frame_count_max = 10,
--         }
--     end
--     print(abs(self.blocker.last_value - newDistance))
--     if abs(self.blocker.last_value - newDistance) < self.blocker.thres * dt then
--         self.blocker.frame_count = self.blocker.frame_count + 1
--         if self.blocker.frame_count >= self.blocker.frame_count_max then
--             -- print("kale!")
--             FindClearSpaceForUnit(self.parent, self.travel_record.pos, false)
--             self.travel_record.pos = self.parent:GetAbsOrigin()
--             self.blocker.frame_count = 0
--         end
--     else
--         self.blocker.frame_count = 0
--     end
-- end

function modifier_aghsfort_storm_spirit_ball_lightning_travel:OnHorizontalMotionInterrupted()
    self:onFailure()
end
function modifier_aghsfort_storm_spirit_ball_lightning_travel:OnVerticalMotionInterrupted()
    self:onFailure()
end

function modifier_aghsfort_storm_spirit_ball_lightning_travel:OnRemoved()
    if IsServer() then
        self:playEffects(false)
        if self.caster == self.parent and IsValid(self.thinker) then
            self.thinker:Kill( nil, nil )
        end
        FindClearSpaceForUnit(self.parent, self.target_pos, false)

        if IsValid(self.ability.shard_fenzy) then
            self.ability.shard_fenzy:stopAction({
                target = self.parent
            })
        end
    end
end
-- 没有成功到达
function modifier_aghsfort_storm_spirit_ball_lightning_travel:onFailure()
    if IsServer() then
        if self.caster == self.parent then
            if IsValid(self.ability.shard_ally) then
                self.ability.shard_ally:stopAction()
            end
        end
        self:Destroy()
    end
end

function modifier_aghsfort_storm_spirit_ball_lightning_travel:updateData(kv)
    
end

function modifier_aghsfort_storm_spirit_ball_lightning_travel:playEffects(bStart)
    local sound_name = "Hero_StormSpirit.BallLightning"
    local pfx_name = "particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning.vpcf"
    if bStart then
        self.parent:EmitSound(sound_name)
        self.parent:EmitSound("Hero_StormSpirit.BallLightning.Loop")
        local pos = self.parent:GetAbsOrigin()
        local pfx = ParticleManager:CreateParticle(pfx_name, PATTACH_ABSORIGIN, self.parent)
        ParticleManager:SetParticleControlEnt(pfx, 0, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", pos, true)
        -- ParticleManager:SetParticleControlEnt(pfx, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_hitloc", pos, true)
        ParticleManager:SetParticleControlEnt(pfx, 1, self.parent, PATTACH_ABSORIGIN_FOLLOW, nil, pos, true)
        self:AddParticle(pfx, false, false, 15, false, false)
    else
        if IsValid(self.parent) then
            self.parent:StopSound("Hero_StormSpirit.BallLightning.Loop")
            print(self.parent:GetName()..": loop sound stopped!")
        end
    end

end