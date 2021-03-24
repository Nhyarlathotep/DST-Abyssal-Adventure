require "prefabutil"

local assets = {
    Asset("ANIM", "anim/drowned.zip")
}

local prefabs =
{
    "collapse_small",
    "houndstooth",
    "boneshard"
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end

local function onhit(inst, worker)
    --TODO anim
    --inst.AnimState:PlayAnimation("hit")
    --inst.AnimState:PushAnimation("idle")
end

local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, 0.6)

        inst.AnimState:SetBank("drowned")
        inst.AnimState:SetBuild("drowned")

        inst.AnimState:SetScale(1, 1, 1)

        inst.AnimState:PlayAnimation("idle", true)
        inst:AddTag("structure")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:AddChanceLoot("houndstooth", 10)
        inst.components.lootdropper:AddRandomLoot("boneshard", 10)
        inst.components.lootdropper.numrandomloot = 1

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(3)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)

        inst:AddComponent("inspectable")

        return inst
end

return Prefab("common/drowned", fn, assets, prefabs)