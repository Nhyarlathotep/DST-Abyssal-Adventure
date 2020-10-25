Assets = {
    Asset("ANIM", "anim/oxygen.zip"),
}

PrefabFiles = {
    "anchor_exit",
    "divingbell",
    "diving_bell_entrance"
}

modimport("main/strings.lua")
modimport("main/actions")

AddReplicableComponent("oxygen")

AddPlayerPostInit(function(inst)
    if GLOBAL.TheWorld.ismastersim then
        --Server
        inst:AddComponent("oxygen")
        inst:AddComponent("interactions")
    else
        --Client
        modimport("scripts/widgets/oxygenbloodover.lua")
        modimport("scripts/widgets/oxygenstatusdisplays.lua")
        modimport("scripts/widgets/oxygenuiclock.lua")
    end
end)

AddPrefabPostInit("balloon", function(inst)
    inst:AddComponent("interactions")
end)

AddPrefabPostInit("anchor", function(inst)
    inst:AddComponent("anchor") --needed by the client
    if GLOBAL.TheWorld.ismastersim then
        inst:AddComponent("worldmigrator")
        inst.components.worldmigrator.id = 988
        inst.components.worldmigrator.receivedPortal = 987
    end
end)

-- check deployable.lua pour empecher de placer des trucs dans l'eau

local resolvefilepath = GLOBAL.resolvefilepath
table.insert(Assets, Asset("IMAGE", "images/colour_cubes/sw_mild_day_cc.tex"))
--table.insert(Assets, Asset("IMAGE", "images/colour_cubes/SW_wet_dusk_cc.tex"))
--table.insert(Assets, Asset("IMAGE", "images/colour_cubes/SW_wet_night_cc.tex"))

--identity_colourcube pas mal
--purple_moon_cc bcp accentué et c pas mal
--sinkhole_cc full vert clai bien pour la kelp forst
-- snow_cc pas  mal si le bleu peut être plus tropical
local DEEPVISION_COLOURCUBES = {
    day = resolvefilepath("images/colour_cubes/identity_colourcube.tex"),
    dusk = resolvefilepath("images/colour_cubes/identity_colourcube.tex"),
    night = resolvefilepath("images/colour_cubes/identity_colourcube.tex"),
    --night = resolvefilepath("images/colour_cubes/sw_mild_day_cc.tex"),
}

local DEEPVISION_PHASEFN = {
    blendtime = 0.25,
    events = {},
    fn = nil,
}

AddComponentPostInit("playervision", function(self)
    function self:SetDeepVision(underwater)
        print("---SetDeepVision---")
        print(underwater)
        if underwater then
            self.inst:PushEvent("ccoverrides", DEEPVISION_COLOURCUBES)
            self.inst:PushEvent("ccphasefn", DEEPVISION_PHASEFN)
        else
            self.inst:PushEvent("ccoverrides", nil)
            self.inst:PushEvent("ccphasefn", nil)
        end
    end
end)

local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")
local PlayerVision = GLOBAL.require("components/playervision")

local _OnAreaChanged = UpvalueHacker.GetUpvalue(PlayerVision._ctor, "OnAreaChanged")
local function OnAreaChanged(inst, area)
    inst.components.playervision:SetDeepVision(area ~= nil and area.tags ~= nil and table.contains(area.tags, "deeparea"))
    _OnAreaChanged(inst, area)
end

UpvalueHacker.SetUpvalue(PlayerVision._ctor, OnAreaChanged, "OnAreaChanged")
