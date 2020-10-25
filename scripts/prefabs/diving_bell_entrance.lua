require "prefabutil"

local assets = {
    Asset("ANIM", "anim/diving_bell.zip")
    --Asset("ANIM", "anim/boat_anchor.zip")
}

local item_assets = {
    Asset("ANIM", "anim/seafarer_anchor.zip"),
    Asset("INV_IMAGE", "anchor_item")
}

local prefabs = {
    "collapse_small",
    "anchor_item", -- deprecated but kept for existing worlds and mods
}

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/anchor/place")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")
end

local function onanchorlowered(inst)
    local boat = inst.components.anchor ~= nil and inst.components.anchor.boat or nil
    if boat ~= nil then
        ShakeAllCamerasOnPlatform(CAMERASHAKE.VERTICAL, 0.3, 0.03, 0.12, boat)
    end
    inst.SoundEmitter:PlaySound("turnoftides/common/together/boat/anchor/ocean_hit")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)
    inst.AnimState:SetBank("boat_anchor")
    inst.AnimState:SetBuild("boat_anchor")

    inst.MiniMapEntity:SetIcon("pighouse.png")

    inst:AddTag("structure")
    inst:AddTag("antlion_sinkhole_blocker")

    inst:AddComponent("anchor")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("boatdrag")
    inst.components.boatdrag.drag = TUNING.BOAT.ANCHOR.BASIC.ANCHOR_DRAG
    inst.components.boatdrag.max_velocity_mod = TUNING.BOAT.ANCHOR.BASIC.MAX_VELOCITY_MOD

    inst:SetStateGraph("SGanchor")

    inst:AddComponent("worldmigrator")
    inst.components.worldmigrator.id = 988
    inst.components.worldmigrator.receivedPortal = 987

    --[[
    -- C'est dans tuning.lua en fonction de la profondeur on set l'id comme ça on a shalow -> safe shalow -> Deep -> deep biome Very_deep -> fond sousmarins
    -- ANCHOR_DEPTH_TIMES = {
        LAND = 0,
        SHALLOW = 2,
        BASIC = 6,
        DEEP = 8,
        VERY_DEEP = 10,
    },]]


    --[[inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(on_hammered)
    inst.components.workable:SetOnWorkCallback(onhit)]]

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("anchor_lowered", onanchorlowered)

    inst:DoTaskInTime(0, function()
        local pt = Vector3(inst.Transform:GetWorldPosition())
        if TheWorld.Map:IsVisualGroundAtPoint(pt.x, pt.y, pt.z) then
            inst.AnimState:Hide("fx")
        end
    end)

    return inst
end

local function ondeploy(inst, pt, deployer)
    local anchor = SpawnPrefab("anchor")
    if anchor ~= nil then
        anchor.Transform:SetPosition(pt:Get())
        anchor.SoundEmitter:PlaySound("turnoftides/common/together/boat/anchor/place")
        anchor.AnimState:PlayAnimation("place")
        anchor.AnimState:PushAnimation("idle")

        inst:Remove()
    end
end

return Prefab("common/diving_bell_entrance", fn, assets, prefabs),
MakeDeployableKitItem("common/diving_bell_entrance_item", "anchor", "seafarer_anchor", "seafarer_anchor", "idle", item_assets, nil, { "boat_accessory" }, { fuelvalue = TUNING.LARGE_FUEL }),
MakePlacer("common/diving_bell_entrance_placer", "boat_anchor", "boat_anchor", "idle")