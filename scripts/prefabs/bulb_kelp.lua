local assets =
{
    Asset("ANIM", "anim/bulb_kelp.zip"),
    Asset("ATLAS", "images/inventoryimages/bulb_kelp.xml")
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetBank("bulb_kelp")
    inst.AnimState:SetBuild("bulb_kelp")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/bulb_kelp.xml"
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("stackable")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(1000)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("edible")
    inst.components.edible.ismeat = false
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
    inst.components.edible.healthvalue = 1
    inst.components.edible.hungervalue = 15
    inst.components.edible.sanityvalue = -5

    inst:AddComponent("inspectable")

    MakeHauntableLaunchAndSmash(inst)

    return inst
end

return Prefab("bulb_kelp", fn, assets)

