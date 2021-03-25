modimport("main/actions/balloon")

local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")

AddAction("ENTERBELL", "Refill oxygen in", function(act)
    if act.doer ~= nil and act.target ~= nil and act.doer:HasTag('player') and act.target.components.interactions then
        act.target.components.oxygen:DoDelta(60)
        return true
    else
        return false
    end
end)

AddStategraphState("wilson", GLOBAL.State {
    name = "enterbell",
    tags = { "hiding", "notalking", "notarget", "nomorph", "busy", "nopredict" },
    onenter = function(inst)
        inst.components.locomotor:Stop()
        --inst.SoundEmitter:PlaySound("manhole cover sound")
        inst.sg.statemem.action = inst.bufferedaction
        if not GLOBAL.TheWorld.ismastersim then
            inst:PerformPreviewBufferedAction()
        end
    end,
    timeline = {
        GLOBAL.TimeEvent(2 * GLOBAL.FRAMES, function(inst)
            if GLOBAL.TheWorld.ismastersim then
                inst:PerformBufferedAction()
            end
            inst:Hide()
            inst.DynamicShadow:Enable(false)
            inst.sg:RemoveStateTag("busy")
        end),
        GLOBAL.TimeEvent(24 * GLOBAL.FRAMES, function(inst)
            inst.sg:RemoveStateTag("nopredict")
            inst.sg:AddStateTag("idle")
        end),
    },
    events = {
        GLOBAL.EventHandler("ontalk", function(inst)
            inst.AnimState:PushAnimation("hide_idle", false)

            if inst.sg.statemem.talktask ~= nil then
                inst.sg.statemem.talktask:Cancel()
                inst.sg.statemem.talktask = nil
                inst.SoundEmitter:KillSound("talk")
            end
            if DoTalkSound(inst) then
                inst.sg.statemem.talktask =
                inst:DoTaskInTime(1.5 + math.random() * .5,
                    function()
                        inst.SoundEmitter:KillSound("talk")
                        inst.sg.statemem.talktask = nil
                    end)
            end
        end),
        GLOBAL.EventHandler("donetalking", function(inst)
            if inst.sg.statemem.talktalk ~= nil then
                inst.sg.statemem.talktask:Cancel()
                inst.sg.statemem.talktask = nil
                inst.SoundEmitter:KillSound("talk")
            end
        end),
    },
    onexit = function(inst)
        inst:Show()
        --inst.components.interactions:ExitBell(inst)
        inst.DynamicShadow:Enable(true)
        inst.AnimState:PlayAnimation("run_pst")
        --inst.SoundEmitter:PlaySound("manhole cover sound")
        if inst.sg.statemem.talktask ~= nil then
            inst.sg.statemem.talktask:Cancel()
            inst.sg.statemem.talktask = nil
            inst.SoundEmitter:KillSound("talk")
        end

        if inst.bufferedaction == inst.sg.statemem.action then
            inst:ClearBufferedAction()
        end
        inst.sg.statemem.action = nil
    end,
})

AddGlobalClassPostConstruct("entityscript", "EntityScript", function(self)
    local tlb = UpvalueHacker.GetUpvalue(self.CollectActions, "COMPONENT_ACTIONS")

    tlb.SCENE.anchor = function(inst, doer, actions, right)
        if not inst:HasTag("burnt") then
            if not inst:HasTag("anchor_raised") or inst:HasTag("anchor_transitioning") then
                if right and math.floor(inst.components.anchor:GetCurrentDepth()) > 0 then
                    table.insert(actions, GLOBAL.ACTIONS.MIGRATE)
                else
                    table.insert(actions, GLOBAL.ACTIONS.RAISE_ANCHOR)
                end
            elseif inst:HasTag("anchor_raised") then
                table.insert(actions, GLOBAL.ACTIONS.LOWER_ANCHOR)
            end
        end
    end
end)

AddComponentAction("SCENE", "interactions", function(inst, doer, actions, right)
    if inst.components.interactions then
        if inst.prefab == "diving_bell" then
            table.insert(actions, GLOBAL.ACTIONS.ENTERBELL)
            --[[if right then
                table.insert(actions, GLOBAL.ACTIONS.ENTERBELL)
            else
                table.insert(actions, GLOBAL.ACTIONS.MIGRATE)
            end]]
        elseif inst.prefab == "anchor_exit" then
            table.insert(actions, GLOBAL.ACTIONS.MIGRATE)
        elseif inst.prefab == "balloon" then
            table.insert(actions, GLOBAL.ACTIONS.POPBALLOON)
        end
    end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.ENTERBELL, "enterbell"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.ENTERBELL, "enterbell"))