GLOBAL.ACTIONS.MAKEBALLOON.fn = function(act)
    if act.doer ~= nil and act.invobject ~= nil and act.invobject.components.balloonmaker ~= nil and act.doer:HasTag("balloonomancer") then
        if true --[[act.doer.components.oxygen:IsUnderWater()]] then
            act.doer.components.oxygen:DoDelta(-GLOBAL.GetRandomMinMax(12, 18))
        elseif act.doer.components.sanity ~= nil then
            if act.doer.components.sanity.current < TUNING.SANITY_TINY then
                return false
            end
            act.doer.components.sanity:DoDelta(-TUNING.SANITY_TINY)
        end
        --Spawn it to either side of doer's current facing with some variance
        local x, y, z = act.doer.Transform:GetWorldPosition()
        local angle = act.doer.Transform:GetRotation()
        local angle_offset = GLOBAL.GetRandomMinMax(-10, 10)

        angle_offset = angle_offset + (angle_offset < 0 and -65 or 65)
        angle = (angle + angle_offset) * GLOBAL.DEGREES
        --TODO CHANGE THE BALLOON TEXTURE AND REMOVE PUSHABLE IF UNDERWATER
        act.invobject.components.balloonmaker:MakeBalloon(x + .5 * math.cos(angle), 0, z - .5 * math.sin(angle))
        return true
    end
    return false
end

AddAction("POPBALLOON", "Refill oxygen with", function(act)
    if act.target --[[and act.doer.components.oxygen:IsUnderWater()]] then
        act.doer.components.oxygen:DoDelta(12)

        act.target:OnRemoveEntity(act.target)
        GLOBAL.RemovePhysicsColliders(act.target)
        act.target.AnimState:PlayAnimation("pop")
        act.target.SoundEmitter:PlaySound("dontstarve/common/balloon_pop")
        act.target.DynamicShadow:Enable(false)
        act.target:AddTag("NOCLICK")
        act.target.persists = false
        act.target:DoTaskInTime(.1 + math.random() * .2  + GLOBAL.FRAMES, act.target.Remove)
        return true
    end
    return false
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(GLOBAL.ACTIONS.POPBALLOON, "give"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(GLOBAL.ACTIONS.POPBALLOON, "give"))

AddAction("CRAB_HIDE", "", function(act)
    return false
end)