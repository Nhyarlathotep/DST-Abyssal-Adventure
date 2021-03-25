require("stategraphs/commonstates")

local function groundsound(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    if TheWorld.Map:IsVisualGroundAtPoint(x, y, z) then
        --PlayFootstep(inst)
    end
end

local actionhandlers = {}

local events = {
    --CommonHandlers.OnSleep(),
    --CommonHandlers.OnHop(),
    CommonHandlers.OnLocomote(true, true),
    --CommonHandlers.OnFreeze(),
    EventHandler("attacked", function(inst)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") and not inst.sg:HasStateTag("jumping") then
            inst.sg:GoToState("hit")
        end
    end),
    EventHandler("death", function(inst)
        inst.sg:GoToState("death", inst.sg.statemem.dead)
    end),
    EventHandler("doattack", function(inst, data)
        if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
            inst.sg:GoToState("attack", data.target)
        end
    end),
    EventHandler("locomote", function(inst)
        if not inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("moving") then return end

        if inst.components.locomotor:WantsToMoveForward() then
            inst.AnimState:PlayAnimation("swim", true)
            --playSound swim
            inst.components.locomotor:RunForward()
        elseif not inst.sg:HasStateTag("idle") then
            inst.sg:GoToState("idle")
        end
    end),
}

local function DoAttack(inst)
    local targetavailable = false
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.SHARK.AOE_RANGE, nil, { "FX", "NOCLICK", "DECOR", "INLOMBO", "notarget", "" })
    for i, ent in pairs(ents) do
        if inst.components.combat:CanAttack(ent) then
            targetavailable = true
            break
        end
    end
    if targetavailable then
        inst.notargets = nil
    else
        inst.notargets = true
    end
    inst.components.combat:DoAttack()
    if inst:GetCurrentPlatform() then
        ShakeAllCamerasOnPlatform(CAMERASHAKE.VERTICAL, 0.2, 0.05, 0.10, inst:GetCurrentPlatform())
    end
end

local states = {
    State {
        name = "idle",
        tags = { "idle", "canrotate" },
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("swim", true)
            else
                inst.AnimState:PlayAnimation("swim", true)
            end
        end,
        timeline = {
            TimeEvent(1 * FRAMES, function(inst) groundsound(inst) end),
            TimeEvent(11 * FRAMES, function(inst) groundsound(inst) end),
            TimeEvent(23 * FRAMES, function(inst) groundsound(inst) end),
            TimeEvent(34 * FRAMES, function(inst) groundsound(inst) end),
        },
    },

    State {
        name = "attack",
        tags = { "attack", "busy" },
        onenter = function(inst, target)
            inst.sg.statemem.target = target
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("attack", false)
        end,
        timeline = {
            TimeEvent(6 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/bite")
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
        },
        onexit = function(inst)
            inst.components.timer:StartTimer("getdistance", 3)
        end,
        events = {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State {
        name = "hit",
        tags = { "busy", "hit" },
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/hit")
        end,
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State {
        name = "death",
        tags = { "busy" },
        onenter = function(inst)
            inst.AnimState:PlayAnimation("dead", false)
            inst.AnimState:PushAnimation("dead_loop", false)
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            --inst.components.lootdropper:DropLoot(inst:GetPosition())
        end,
        timeline =
        {
            TimeEvent(6 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/death") end),
        },
        onexit = function(inst)
            if not inst:IsInLimbo() then
                inst.AnimState:Resume()
            end
        end,
    },

    --[[State {
        name = "eat_pre",
        tags = { "busy", "jumping" },
        onenter = function(inst)
            inst:ClearBufferedAction()
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("dive")
        end,
        onexit = function(inst)
            inst.Physics:SetActive(true)
        end,
        events =
        {
            EventHandler("animover", function(inst)
                inst.Physics:SetActive(false)
                inst.sg:SetTimeout(2)
            end),
        },
        ontimeout = function(inst)
            local targetpt = Vector3(inst.Transform:GetWorldPosition())
            if inst.foodtoeat and inst.foodtoeat:IsValid() then
                targetpt = Vector3(inst.foodtoeat.Transform:GetWorldPosition())
            end
            inst.Transform:SetPosition(targetpt.x, 0, targetpt.z)
            inst.sg:GoToState("eat_pst")
        end,
    },

    State {
        name = "eat_pst",
        tags = { "busy", "jumping" },
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat")
            -- SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,
        timeline =
        {
            TimeEvent(1 * FRAMES, function(inst)
                if inst.foodtoeat then
                    inst.foodtoeat:Remove()
                end
                inst.foodtoeat = nil
            end),
            TimeEvent(7 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/bite")
                SpawnPrefab("splash_green").Transform:SetPosition(inst.Transform:GetWorldPosition())
            end),

            TimeEvent(30 * FRAMES, function(inst)
                if inst:HasTag("swimming") then
                    SpawnPrefab("splash_green_large").Transform:SetPosition(inst.Transform:GetWorldPosition())
                else
                    groundsound(inst)
                end
            end),
        },
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },]]
}

--[[CommonStates.AddSleepStates(states,
    {
        sleeptimeline =
        {-- TimeEvent(30 * FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep) end),
        },
    })

CommonStates.AddRunStates(states,
    {
        runtimeline =
        {
            TimeEvent(0, function(inst)
                -- inst.SoundEmitter:PlaySound(inst.sounds.growl)
                if inst:HasTag("swimming") then
                    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small", nil, .25)
                else
                    PlayFootstep(inst)
                end

                if inst:HasTag("swimming") then
                    inst.waketask = inst:DoPeriodicTask(0.25, function()
                        local wake = SpawnPrefab("wake_small")
                        local rotation = inst.Transform:GetRotation()

                        local theta = rotation * DEGREES
                        local offset = Vector3(math.cos(theta), 0, -math.sin(theta))
                        local pos = Vector3(inst.Transform:GetWorldPosition()) + offset
                        wake.Transform:SetPosition(pos.x, pos.y, pos.z)
                        wake.Transform:SetScale(1.35, 1.36, 1.35)

                        wake.Transform:SetRotation(rotation - 90)
                    end)
                end
            end),
            TimeEvent(4 * FRAMES, function(inst)
                if inst:HasTag("swimming") then
                    inst.SoundEmitter:PlaySound("turnoftides/common/together/water/splash/jump_small", nil, .25)
                else
                    PlayFootstep(inst)
                end
            end),
        }
    }, nil, nil, nil,
    {
        runonexit = function(inst)
            if inst.waketask then
                inst.waketask:Cancel()
                inst.waketask = nil
            end
        end,
        runonupdate = function(inst)

            inst:testfooddist()
        end,
    })
CommonStates.AddWalkStates(states,
    {
        walktimeline =
        {--TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dangerous_sea/creatures/shark/swim") end),
        },
    }, nil, nil, nil,
    {
        startonenter = function(inst)
            inst:AddTag("walking")
        end,
        startonexit = function(inst)
            inst:RemoveTag("walking")
        end,
        walkonenter = function(inst)
            inst:AddTag("walking")
        end,
        walkonexit = function(inst)
            inst:RemoveTag("walking")
        end,
        exitonenter = function(inst)
            inst:AddTag("walking")
        end,
        endonexit = function(inst)
            inst:RemoveTag("walking")
        end,
        walkonupdate = function(inst)
            inst:testfooddist()
        end,
    })
CommonStates.AddFrozenStates(states)]]

return StateGraph("hunting_shark", states, events, "idle", actionhandlers)

