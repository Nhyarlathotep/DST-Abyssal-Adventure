local assets = {
    Asset("ANIM", "anim/hunting_shark.zip")
}

local prefabs = {
    --"sharktooth",
    "monstermeat",
}

local brain = require("brains/hunting_sharkbrain")

local sounds = {-- pant = "dontstarve/creatures/hound/pant",
    -- attack = "dontstarve/creatures/hound/attack",
    -- bite = "dontstarve/creatures/hound/bite",
    -- bark = "dontstarve/creatures/hound/bark",
    -- death = "dontstarve/creatures/hound/death",
    -- sleep = "dontstarve/creatures/hound/sleep",
    -- growl = "dontstarve/creatures/hound/growl",
    -- howl = "dontstarve/creatures/together/clayhound/howl",
    -- hurt = "dontstarve/creatures/hound/hurt",
}

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or (inst.components.follower and inst.components.follower.leader and not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE))
end

local function ShouldSleep(inst)
    return false
end

local function OnNewTarget(inst, data)
    --if inst.components.sleeper:IsAsleep() then
    --    inst.components.sleeper:WakeUp()
    --end
end

--local function KeepTarget(inst, target)
--    if target then
--        local x, y, z = target.Transform:GetWorldPosition()
--        if not TheWorld.Map:IsVisualGroundAtPoint(x, y, z) then
--            return true
--        end
--    end
--end

local function KeepTarget(inst, target)
    local leader = inst.components.follower.leader
    local playerleader = leader ~= nil and leader:HasTag("player")

    return (leader == nil or not playerleader or inst:IsNear(leader, TUNING.HOUND_FOLLOWER_RETURN_DIST)) and
            inst.components.combat:CanTarget(target) and (not leader ~= nil or
            inst:IsNear(target, TUNING.HOUND_FOLLOWER_TARGET_KEEP))
end

--local function Retarget(inst)
--    return FindEntity(inst, 20 --[[TUNING.SHARK.TARGET_DIST]], function(guy)
--        local x, y, z = guy.Transform:GetWorldPosition()
--        if not guy:HasTag("shark") and not inst.components.timer:TimerExists("calmtime") and not TheWorld.Map:IsVisualGroundAtPoint(x, y, z) then
--            return inst.components.combat:CanTarget(guy)
--        end
--    end) or nil
--end

local function Retarget(inst)
    local leader = inst.components.follower.leader
    local playerleader = leader ~= nil and leader:HasTag("player")

    return (leader == nil or not playerleader or inst:IsNear(leader, TUNING.HOUND_FOLLOWER_AGGRO_DIST)) and
            FindEntity(inst, leader ~= nil and TUNING.HOUND_FOLLOWER_TARGET_DIST or TUNING.HOUND_TARGET_DIST,
                function(guy)
                    return guy ~= leader and inst.components.combat:CanTarget(guy)
                end,
                nil, { "wall", "houndfriend" }) or nil
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
        return not (dude.components.health ~= nil and dude.components.health:IsDead()) and dude:HasTag("shark")
    end, 5)
    inst.components.timer:StopTimer("calmtime")
end

local function OnAttackOther(inst, data)
    inst.components.combat:ShareTarget(data.target, 30, function(dude)
        return not (dude.components.health ~= nil and dude.components.health:IsDead())
                and (dude:HasTag("shark") or dude:HasTag("hound"))
                and data.target ~= (dude.components.follower ~= nil and dude.components.follower.leader or nil)
    end, 5)
end

local function OnStartFollowing(inst, data)
    if inst.leadertask ~= nil then
        inst.leadertask:Cancel()
        inst.leadertask = nil
    end
    if data == nil or data.leader == nil then
        inst.components.follower.maxfollowtime = nil
    elseif data.leader:HasTag("player") then
        inst.components.follower.maxfollowtime = TUNING.HOUNDWHISTLE_EFFECTIVE_TIME * 1.5
    else
        inst.components.follower.maxfollowtime = nil
        if inst.components.entitytracker:GetEntity("leader") == nil then
            inst.components.entitytracker:TrackEntity("leader", data.leader)
        end
    end
end

local function RestoreLeader(inst)
    inst.leadertask = nil
    local leader = inst.components.entitytracker:GetEntity("leader")
    if leader ~= nil and not leader.components.health:IsDead() then
        inst.components.follower:SetLeader(leader)
        leader:PushEvent("restoredfollower", { follower = inst })
    end
end

local function OnStopFollowing(inst)
    inst.leader_offset = nil
    if not inst.components.health:IsDead() then
        local leader = inst.components.entitytracker:GetEntity("leader")
        if leader ~= nil and not leader.components.health:IsDead() then
            inst.leadertask = inst:DoTaskInTime(.2, RestoreLeader)
        end
    end
end


local function removefood(inst, target)
    inst.foodtoeat = nil
end

local function testfooddist(inst)
    if not inst.foodtoeat then
        local action = inst:GetBufferedAction()
        if action and action.target and action.target:IsValid() and action.target:HasTag("oceanfish") then
            inst.foodtoeat = action.target
            inst.components.timer:StartTimer("gobble_cooldown", 2 + math.random() * 15)
        end
    end
    if inst.foodtoeat then
        if inst.foodtoeat:IsValid() then
            if inst.foodtoeat:GetDistanceSqToInst(inst) < 6 * 6 then
                inst:PushEvent("dive_eat")
            end
        else
            inst.foodtoeat = nil
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 100, .5)

    inst.DynamicShadow:SetSize(2.5, 1.5)
    inst.Transform:SetSixFaced()

    inst:AddTag("scarytoprey")
    inst:AddTag("scarytooceanprey")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("shark")
    inst:AddTag("largecreature")
    inst:AddTag("canbestartled")

    inst.AnimState:SetBank("hunting_shark")
    inst.AnimState:SetBuild("hunting_shark")
    inst.AnimState:SetScale(0.6, 0.6, 0.6)
    inst.AnimState:PlayAnimation("swim", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.sounds = sounds

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 7
    inst.components.locomotor.runspeed = 8

    inst:SetStateGraph("SGhunting_shark")

    inst:SetBrain(brain)

    inst:AddComponent("follower")
    inst:AddComponent("entitytracker")

    --inst:AddComponent("eater")
    --inst.components.eater:SetDiet({ FOODTYPE.MEAT }, { FOODTYPE.MEAT })
    --inst.components.eater:SetCanEatHorrible()
    --inst.components.eater.strongstomach = true -- can eat monster meat!

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SHARK.HEALTH)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "shark_parts"
    inst.components.combat:SetDefaultDamage(5 --[[TUNING.SHARK.DAMAGE]])
    inst.components.combat:SetRetargetFunction(3 --[[1]], Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetAreaDamage(TUNING.SHARK.AOE_RANGE, TUNING.SHARK.AOE_SCALE)


    --inst:AddComponent("lootdropper")
    --inst.components.lootdropper:SetChanceLootTable('shark')


    inst:AddComponent("inspectable")

    --MakeLargeFreezableCharacter(inst, "beefalo_body")

    inst:AddComponent("timer")

    --inst:AddComponent("sleeper")
    --inst.components.sleeper:SetResistance(3)
    --inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    --inst.components.sleeper:SetSleepTest(ShouldSleep)
    --inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    --inst.removefood = removefood
    --inst.testfooddist = testfooddist
    --inst.GetFormationOffsetNormal = GetFormationOffsetNormal
    --inst.OnEntitySleep = OnEntitySleep
    --inst.OnEntityWake = OnEntityWake

    MakeHauntablePanic(inst)

    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onattackother", OnAttackOther)
    inst:ListenForEvent("startfollowing", OnStartFollowing)
    inst:ListenForEvent("stopfollowing", OnStopFollowing)

    return inst
end

return Prefab("hunting_shark", fn, assets, nil)


