local assets=
{
    Asset("ANIM", "anim/boids.zip")
}

local brain = require "brains/boidsbrain"

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    local shadow = inst.entity:AddDynamicShadow()
    shadow:SetSize( 1.5, .5 )
    inst.Transform:SetSixFaced()

    MakeCharacterPhysics(inst, 1, 0.5)

    inst.AnimState:SetBank("boids")
    inst.AnimState:SetBuild("boids")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("smallcreature")

    inst:AddTag("boids")

    MakeFeedableSmallLivestockPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.runspeed = 7
    inst.components.locomotor.walkspeed = 4
    inst:SetStateGraph("SGboids")

    inst:SetBrain(brain)

    inst:AddComponent("knownlocations")
    return inst
end

return Prefab("boids", fn, assets)