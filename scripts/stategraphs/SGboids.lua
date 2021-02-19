require("stategraphs/commonstates")

local actionhandlers =
{
}

local events=
{
    EventHandler("locomote", function(inst)
        if not inst.sg:HasStateTag("busy") then
            local is_moving = inst.sg:HasStateTag("moving")
            local wants_to_move = inst.components.locomotor:WantsToMoveForward()
            if is_moving ~= wants_to_move then
                if wants_to_move then
                    inst.sg.statemem.wantstomove = true
                else
                    inst.sg:GoToState("idle")
                end
            end
        end
    end),
    --EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    --CommonHandlers.OnFreeze(),
}

local states=
{

    State{
        name = "moving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:WalkForward()
            --inst.AnimState:PlayAnimation("flight_cycle", true)
        end,
    },

    State{
        name = "idle",
        tags = {"idle"},

        onenter = function(inst)
            inst.Physics:Stop()
            if not inst.AnimState:IsCurrentAnimation("idle") then
                inst.AnimState:PlayAnimation("idle", true)
            end
            inst.sg:SetTimeout( inst.AnimState:GetCurrentAnimationLength() )
        end,

        ontimeout = function(inst)
            if inst.sg.statemem.wantstomove then
                inst.sg:GoToState("moving")
            else
                inst.sg:GoToState("idle")
            end
        end,
    },

}
--CommonStates.AddFrozenStates(states, LandFlyingCreature, RaiseFlyingCreature)

return StateGraph("boids", states, events, "idle")

