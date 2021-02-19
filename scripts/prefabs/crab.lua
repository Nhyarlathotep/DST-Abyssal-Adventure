local assets=
{
    Asset("ANIM", "anim/crabbit_build.zip"),
    Asset("ANIM", "anim/crabbit.zip"),
    Asset("SOUNDPACKAGE", "sound/ia.fev"),
    Asset("SOUND", "sound/ia_creature.fsb"),
    Asset("ATLAS", "images/inventoryimages/crab.xml")
}

local prefabs =
{
    "smallmeat",
    "cookedsmallmeat"
}

local crabbitsounds =
{
    scream = "ia/creatures/crab/scream",
    hurt = "ia/creatures/crab/scream_short",
}

local brain = require "brains/crabbrain"

local function SetRabbitLoot(lootdropper)
    if not lootdropper.inst._fixedloot then
        lootdropper:SetLoot({"smallmeat"})
    end
end

local function MakeInventoryRabbit(inst)
    inst.components.inventoryitem:ChangeImageName("crab")
    inst.components.health.murdersound = inst.sounds.hurt
    SetRabbitLoot(inst.components.lootdropper)
end

local function BecomeRabbit(inst)
    if inst.components.health:IsDead() then
        return
    end

    inst.AnimState:SetBuild("crabbit_build")
    inst.sounds = crabbitsounds
    if inst.components.hauntable ~= nil then
        inst.components.hauntable.haunted = false
    end
end

local function OnDropped(inst)
    MakeInventoryRabbit(inst)
    inst.sg:GoToState("stunned")
end

local function LootSetupFunction(lootdropper)
    local guy = lootdropper.inst.causeofdeath
    SetRabbitLoot(lootdropper)
end

local function OnAttacked(inst, data)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 30, {'crab'})

    local num_friends = 0
    local maxnum = 5
    for k,v in pairs(ents) do
        v:PushEvent("gohome")
        num_friends = num_friends + 1

        if num_friends > maxnum then
            break
        end
    end
end

local function OnDug(inst, worker)
    local rnd = math.random()
    local home = inst.components.homeseeker and inst.components.homeseeker.home
    if rnd >= 0.66 or not home then
        --Sometimes just go to stunned state
        inst:PushEvent("stunned")
    else
        --Sometimes return home instantly?
        worker:DoTaskInTime(1, function()
            worker:PushEvent("crab_fail")
        end)

        inst.components.lootdropper:SpawnLootPrefab("sand")
        local home = inst.components.homeseeker.home
        home.components.spawner:GoHome(inst)
    end
end

local function DisplayName(inst)
    if inst:HasTag("crab_hidden") then
        return STRINGS.NAMES.CRAB_HIDDEN
    end
    return STRINGS.NAMES.CRAB
end

local function getstatus(inst)
    if inst.sg:HasStateTag("invisible") then
        return "HIDDEN"
    end
end

local function GetCookProductFn(inst, cooker, chef)
    return "cookedsmallmeat"
end

local function OnCookedFn(inst)
    inst.SoundEmitter:PlaySound("ia/creatures/crab/scream_short")
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()
    inst.entity:AddLightWatcher()
    inst.entity:AddSoundEmitter()
    local shadow = inst.entity:AddDynamicShadow()
    shadow:SetSize( 1.5, .5 )
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 1, 0.5)

    inst.AnimState:SetBank("crabbit")
    inst.AnimState:SetBuild("crabbit_build")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("rabbit")
    inst:AddTag("smallcreature")
    inst:AddTag("canbetrapped")
    inst:AddTag("cookable")

    MakeFeedableSmallLivestockPristine(inst)

    inst.displaynamefn = DisplayName

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = 7
    inst.components.locomotor.walkspeed = 4
    inst:SetStateGraph("SGcrab")

    inst:SetBrain(brain)

    inst.data = {}

    inst:AddComponent("eater")
    local diet = { FOODTYPE.MEAT, FOODTYPE.VEGGIE, FOODTYPE.INSECT }
    inst.components.eater:SetDiet(diet, diet)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/crab.xml"
    inst.components.inventoryitem.nobounce = true
    inst.components.inventoryitem.canbepickedup = false
    inst.components.inventoryitem.canbepickedupalive = true
    inst.components.inventoryitem:SetSinks(true)

    inst:AddComponent("cookable")
    inst.components.cookable.product = GetCookProductFn
    inst.components.cookable:SetOnCookedFn(OnCookedFn)

    inst:AddComponent("knownlocations")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "eyes"
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(10)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable.workable = false
    inst.components.workable:SetOnFinishCallback(OnDug)

    MakeSmallBurnableCharacter(inst, nil, Vector3(0, 0.1, 0))
    MakeTinyFreezableCharacter(inst, nil, Vector3(0, 0.1, 0))

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLootSetupFn(LootSetupFunction)

    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus
    inst:AddComponent("sleeper")

    BecomeRabbit(inst)

    MakeHauntablePanic(inst)

    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end

return Prefab( "crab", fn, assets, prefabs)