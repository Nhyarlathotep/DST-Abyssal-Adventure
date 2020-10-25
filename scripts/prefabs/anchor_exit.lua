require "prefabutil"
require "recipes"

local assets = {
    Asset("ANIM", "anim/anchor_exit.zip")
}

local prefabs = {}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 0.8)
    inst.AnimState:SetBank("anchor_exit")
    inst.AnimState:SetBuild("anchor_exit")

    inst.MiniMapEntity:SetIcon("pighouse.png")

    inst:AddTag("structure")

    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("interactions")
    inst:AddComponent("worldmigrator")
    inst.components.worldmigrator.id = 987
    inst.components.worldmigrator.receivedPortal = 988

    return inst
end

return Prefab("common/anchor_exit", fn, assets, prefabs)