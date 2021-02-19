local assets =
{
    Asset("ANIM", "anim/shard.zip"),
    Asset("ATLAS", "images/inventoryimages/coral_shard.xml")
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetBank("shard")
    inst.AnimState:SetBuild("shard")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/coral_shard.xml"
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("stackable")

    MakeHauntableLaunchAndSmash(inst)

    return inst
end

return Prefab("coral_shard", fn, assets)

