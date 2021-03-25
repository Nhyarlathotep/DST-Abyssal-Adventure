require("worldsettingsutil")

local assets = {
    Asset("ANIM", "anim/kelp.zip")
}

local prefabs = {
    "cutgrass",
    "grasspartfx",
}

local function onregenfn(inst)
    --inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", true)
end

local function onpickedfn(inst, picker)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
    --inst.AnimState:PlayAnimation("picking")

    if inst.components.pickable:IsBarren() then
        --inst.AnimState:PushAnimation("empty_to_dead")
        --inst.AnimState:PushAnimation("idle_dead", false)
    else
        --inst.AnimState:PushAnimation("picked", false)
    end
end

local function makeemptyfn(inst)
    --[[if not POPULATING and]]
    --[[        (inst.components.witherable ~= nil and]]
    --[[                inst.components.witherable:IsWithered() or]]
    --[[                inst.AnimState:IsCurrentAnimation("idle_dead")) then]]
    --[[    inst.AnimState:PlayAnimation("dead_to_empty")]]
    --[[    inst.AnimState:PushAnimation("picked", false)]]
    --[[else]]
    --[[    inst.AnimState:PlayAnimation("picked")]]
    --[[end]]
end

local function makebarrenfn(inst, wasempty)
    --[[if not POPULATING and
            (inst.components.witherable ~= nil and
                    inst.components.witherable:IsWithered()) then
        inst.AnimState:PlayAnimation(wasempty and "empty_to_dead" or "full_to_dead")
        inst.AnimState:PushAnimation("idle_dead", false)
    else
        inst.AnimState:PlayAnimation("idle_dead")
    end]]
end


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("grass.png")
    --MakeObstaclePhysics(inst, 0.8)

    inst.AnimState:SetBank("kelp")
    inst.AnimState:SetBuild("kelp")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("plant")
    inst:AddTag("renewable")
    inst:AddTag("silviculture") -- for silviculture book

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"

    inst.components.pickable:SetUp("cutgrass", TUNING.GRASS_REGROW_TIME)
    inst.components.pickable.onregenfn = onregenfn
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn
    inst.components.pickable.makebarrenfn = makebarrenfn
    inst.components.pickable.max_cycles = 20
    inst.components.pickable.cycles_left = 20
    --inst.components.pickable.ontransplantfn = ontransplantfn

    MakeNoGrowInWinter(inst)

    return inst
end

return Prefab("kelp_plant", fn, assets, prefabs)