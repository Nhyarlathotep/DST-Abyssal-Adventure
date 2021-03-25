local assets =
{
    Asset("ANIM", "anim/sandune.zip"),
    Asset("SOUND", "sound/common.fsb")
}

local prefabs =
{
    "oceansand"
}

local function onregenfn(inst)
    if (inst.state == 0) then
        inst.state = 2
        inst.AnimState:PushAnimation("full")
    end
end

local function makeemptyfn(inst)
    if not POPULATING and
            (   inst.components.witherable ~= nil and
                    inst.components.witherable:IsWithered() or
                    inst.AnimState:IsCurrentAnimation("idle_dead")
            ) then
        inst.AnimState:PlayAnimation("dead_to_empty")
        inst.AnimState:PushAnimation("picked", false)
    else
        inst.AnimState:PlayAnimation("picked")
    end
end

local function makebarrenfn(inst, wasempty)
    if not POPULATING and
            (   inst.components.witherable ~= nil and
                    inst.components.witherable:IsWithered()
            ) then
        inst.AnimState:PlayAnimation(wasempty and "empty_to_dead" or "full_to_dead")
        inst.AnimState:PushAnimation("idle_dead", false)
    else
        inst.AnimState:PlayAnimation("idle_dead")
    end
end

local function onpickedfn(inst, picker)
    inst.state = inst.state - 1
    inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
    if (inst.state == 1) then
        inst.components.pickable:SetUp("oceansand", 0)
        inst.AnimState:PushAnimation("med")
    elseif (inst.state == 0) then
        inst.components.pickable:SetUp("oceansand", 10)
        inst.AnimState:PushAnimation("low")
    end
end

local function onload(inst, data)
    inst.state = data.state
end

local function onsave(inst, data)
    data.state = inst.state
end

local function fn()
        local inst = CreateEntity()
        inst.state = 2

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        inst.MiniMapEntity:SetIcon("grass.png")

        inst.AnimState:SetBank("sandune")
        inst.AnimState:SetBuild("sandune")
        inst.AnimState:PlayAnimation("full", true)

        inst.AnimState:SetScale(1, 1, 1)

        inst:AddTag("renewable")

        inst:AddTag("witherable")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.AnimState:SetTime(math.random() * 2)
        local color = 0.75 + math.random() * 0.25
        inst.AnimState:SetMultColour(color, color, color, 1)

        inst:AddComponent("pickable")
        inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"

        inst.components.pickable:SetUp("oceansand", 0)
        inst.components.pickable.onregenfn = onregenfn
        inst.components.pickable.onpickedfn = onpickedfn
        inst.components.pickable.makeemptyfn = makeemptyfn
        inst.components.pickable.makebarrenfn = makebarrenfn
        inst.components.pickable.max_cycles = 20
        inst.components.pickable.cycles_left = 20

        inst:AddComponent("witherable")

        inst:AddComponent("lootdropper")
        inst:AddComponent("inspectable")

        inst.OnSave = onsave
        inst.OnLoad = onload

        return inst
end

return Prefab("sandune", fn, assets, prefabs)
