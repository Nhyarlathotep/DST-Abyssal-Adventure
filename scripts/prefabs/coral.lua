require "prefabutil"

local assets = {
    Asset("ANIM", "anim/coral.zip")
}

local prefabs =
{
    "goldnugget",
    "coral_shard"
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_rock")
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

        inst.AnimState:SetBank("coral")
        inst.AnimState:SetBuild("coral")

        inst.AnimState:SetScale(1, 1, 1)

        inst.AnimState:PlayAnimation("idle", true)
        inst:AddTag("structure")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:AddChanceLoot("coral_shard", 10)
        inst.components.lootdropper.numrandomloot = 1

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(3)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)

        inst:AddComponent("inspectable")

        return inst
end

return Prefab("common/coral", fn, assets, prefabs)