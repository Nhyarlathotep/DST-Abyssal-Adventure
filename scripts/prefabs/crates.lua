require "prefabutil"

local assets = {
    Asset("ANIM", "anim/crates.zip")
}

local prefabs =
{
    "collapse_small",
    "boards",
    "rope",
    "goldnugget"
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

local function fn(name, count)
    return function ()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, 0.6)

        inst.AnimState:SetBank("crates")
        inst.AnimState:SetBuild("crates")

        inst.AnimState:SetScale(1, 1, 1)

        inst.AnimState:PlayAnimation(name .. "_idle", true)
        inst:AddTag("structure")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:AddChanceLoot("goldnugget", 10)
        inst.components.lootdropper:AddRandomLoot("boards", 10)
        inst.components.lootdropper:AddRandomLoot("rope", 10)
        inst.components.lootdropper.numrandomloot = count

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(count)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)

        inst:AddComponent("inspectable")

        return inst
    end
end

return Prefab("common/small_crate", fn('small', 2), assets, prefabs),
    Prefab("common/medium_crate", fn('medium', 3), assets, prefabs),
    Prefab("common/big_crate", fn('big', 4), assets, prefabs)