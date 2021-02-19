require "prefabutil"

local assets = {
    Asset("ANIM", "anim/seaweed.zip")
}

local prefabs =
{
  "bulb_kelp"
}

local function onpickup(inst, picker)
    local x, y, z = inst.Transform:GetWorldPosition()

    inst.components.lootdropper:DropLoot()
    SpawnPrefab("tumbleweedbreakfx").Transform:SetPosition(x, y, z)
    inst:Remove()
end

local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, 0.6)

        inst.AnimState:SetBank("seaweed")
        inst.AnimState:SetBuild("seaweed")

        inst.AnimState:SetScale(1, 1, 1)

        inst.AnimState:PlayAnimation("idle", true)
        inst:AddTag("structure")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:AddChanceLoot("bulb_kelp", 10)
        inst.components.lootdropper.numrandomloot = 1

        inst:AddComponent("pickable")
        inst.components.pickable.picksound = "dontstarve/wilson/harvest_sticks"
        inst.components.pickable.onpickedfn = (onpickup)
        inst.components.pickable.canbepicked = true

        inst:AddComponent("inspectable")

        return inst
end

return Prefab("common/seaweed", fn, assets, prefabs)