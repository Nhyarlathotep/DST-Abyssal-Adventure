local assets =
{
    Asset("ANIM", "anim/rabbit_hole.zip"),
}

local prefabs =
{
    "crab",
    "smallmeat",
}

local function dig_up(inst, digger)
    if inst.components.spawner:IsOccupied() then
        inst.components.lootdropper:SpawnLootPrefab("crab")
    end

    TheWorld:PushEvent("beginregrowth", inst)

    inst:Remove()
end

local function startspawning(inst)
    if inst.components.spawner ~= nil then
        inst.components.spawner:SetQueueSpawning(false)
        if not inst.components.spawner:IsSpawnPending() then
            inst.components.spawner:SpawnWithDelay(math.random(60, 180))
        end
    end
end

local function stopspawning(inst)
    if inst.components.spawner ~= nil then
        inst.components.spawner:SetQueueSpawning(true, math.random(60, 120))
    end
end

local function onoccupied(inst)
   if TheWorld.state.isday then
        startspawning(inst)
    end
end

local function OnIsDay(inst, isday)
    if isday and inst.components.spawner ~= nil and inst.components.spawner:IsOccupied() then
        startspawning(inst)
    else
        stopspawning(inst)
    end
end

local function OnInit(inst)
    inst.inittask = nil

    inst:WatchWorldState("isday", OnIsDay)
    OnIsDay(inst, TheWorld.state.isday)
    inst.AnimState:PlayAnimation("idle")
end

local function OnLoad(inst, data)
    if data ~= nil and inst.inittask ~= nil then
        inst.inittask:Cancel()
        inst.inittask = inst:DoTaskInTime(0, OnInit, true)
    end
end

local function OnHaunt(inst)
    return inst.components.spawner ~= nil and inst.components.spawner:IsOccupied() and inst.components.spawner:ReleaseChild()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("cattoy")

    inst.AnimState:SetBank("rabbithole")
    inst.AnimState:SetBuild("rabbit_hole")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("spawner")
    inst.components.spawner:Configure("crab", 100)

    inst.components.spawner:SetOnOccupiedFn(onoccupied)
    inst.components.spawner:SetOnVacateFn(stopspawning)

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up)
    inst.components.workable:SetWorkLeft(1)

    inst.inittask = inst:DoTaskInTime(0, OnInit)

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst.OnLoad = OnLoad

    return inst
end

return Prefab("crabhole", fn, assets, prefabs)