local assets = {
    Asset("ANIM", "anim/small_fish.zip"),
}

local prefabs = {
    "smallmeat"
}

local SOLOFISH_WALK_SPEED = 5
local SOLOFISH_RUN_SPEED = 8
local SOLOFISH_HEALTH = 60
local SOLOFISH_WANDER_DIST = 10

local brain = require "brains/small_fishbrain"

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeCharacterPhysics(inst, 1, 0.5)

    inst.AnimState:SetBank("small_fish")
    inst.AnimState:SetBuild("small_fish")
    inst.AnimState:PlayAnimation("walk_loop", true)
    inst.Transform:SetFourFaced()

    local shadow = inst.entity:AddDynamicShadow()
    shadow:SetSize(1.5, .5)

    inst:AddTag("aquatic")
    inst:AddTag("tropicalspawner")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = SOLOFISH_WALK_SPEED
    inst.components.locomotor.runspeed = SOLOFISH_RUN_SPEED

    inst:AddComponent("knownlocations")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(SOLOFISH_HEALTH)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({ "smallmeat" })

    --inst:AddComponent("sleeper")
    --inst.components.sleeper:SetSleepTest(ShouldSleep)
    --MakeMediumFreezableCharacter(inst, "dogfish_body")

    inst:SetStateGraph("SGsmall_fish")

    inst:SetBrain(brain)
    return inst
end

return Prefab("small_fish", fn, assets, prefabs)