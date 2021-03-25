Assets = {
    Asset("ANIM", "anim/oxygen.zip")
}

PrefabFiles = {
    "anchor_exit",
    "divingbell",
    "diving_bell_entrance",
    "crates",
    "coral",
    "coral_shard",
    "crab",
    "crabhole",
    "boids",
    "hunting_shark",
    "kelp_plant",
    "swordfish",
    "dogfish",
    "small_fish",
    "drowned",
    "chimineafire",
    "chiminea",
    "sandune",
    "sandonground"
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


----------------------------------------------------------------
local function CanBuildAtPoint(pt)
    --TODO ADD OTHER TILES AND ALLOWED PREFABS
    if (GLOBAL.TheWorld.Map:GetTile(GLOBAL.TheWorld.Map:GetTileCoordsAtPoint(pt:Get())) == GROUND.SAND) then
        return false
    end
    return true
end

local function BuilderPostInit(self)
    local OldCanBuildAtPoint = self.CanBuildAtPoint
    local OldMakeRecipeAtPoint = self.MakeRecipeAtPoint

    self.CanBuildAtPoint = function(self, pt, recipe, ...)
        return OldCanBuildAtPoint(self, pt, recipe, ...) and CanBuildAtPoint(pt)
    end

    self.MakeRecipeAtPoint = function(self, recipe, pt, ...)
        return OldMakeRecipeAtPoint(self, recipe, pt, ...) and CanBuildAtPoint(pt)
    end
end

AddComponentPostInit("builder", BuilderPostInit) --Server
AddClassPostConstruct("components/builder_replica", BuilderPostInit) --Client

local function DeployablePostInit(self)
    local OldCanDeploy = self.CanDeploy

    self.CanDeploy = function(self, pt, mouseover, deployer, ...)
        return OldCanDeploy(self, pt, mouseover, deployer, ...) and CanBuildAtPoint(pt)
    end
end

AddComponentPostInit("deployable", DeployablePostInit) --Server
AddClassPostConstruct("components/inventoryitem_replica", DeployablePostInit) --Client
----------------------------------------------------------------

local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")
local PlayerVision = GLOBAL.require("components/playervision")

local _OnAreaChanged = UpvalueHacker.GetUpvalue(PlayerVision._ctor, "OnAreaChanged")
local function OnAreaChanged(inst, area)
    inst.components.playervision:SetDeepVision(area ~= nil and area.tags ~= nil and table.contains(area.tags, "deeparea"))
    _OnAreaChanged(inst, area)
end

UpvalueHacker.SetUpvalue(PlayerVision._ctor, OnAreaChanged, "OnAreaChanged")