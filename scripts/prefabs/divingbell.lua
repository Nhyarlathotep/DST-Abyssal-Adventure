require "prefabutil"

local assets = {
    Asset("ANIM", "anim/diving_bell.zip")
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()

    MakeObstaclePhysics(inst, 0.6)

    inst.MiniMapEntity:SetIcon("pighouse.png")

    inst.AnimState:SetBank("diving_bell")
    inst.AnimState:SetBuild("diving_bell")

    inst.AnimState:SetScale(0.75, 0.75, 0.75)

    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("structure")

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

return Prefab("common/diving_bell", fn, assets, prefabs)