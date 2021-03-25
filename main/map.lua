modimport("tile_adder")

local GROUND_OCEAN_COLOR = {
    primary_color = { 0, 0, 0, 25 },
    secondary_color = { 0, 20, 33, 0 },
    secondary_color_dusk = { 0, 20, 33, 80 },
    minimap_color = { 0, 0, 0, 255 },
}

AddTile("SAND", 95, "beach", {
    noise_texture = "levels/textures/noise_sand_shallow.tex",
    runsound = "dontstarve/movement/walk_grass", --TODO: change to sand
    walksound = "dontstarve/movement/walk_grass", --TODO: change to sand
    snowsound = "dontstarve/movement/run_snow",
    mudsound = "dontstarve/movement/run_mud",
    flashpoint_modifier = 0,
    colors = GROUND_OCEAN_COLOR,
}, {
    noise_texture = "levels/textures/mini_noise_beach.tex"
})

AddTile("SAND_DEEP", 96, "beach", {
    noise_texture = "levels/textures/noise_sand_deep.tex",
    runsound = "dontstarve/movement/walk_grass", --TODO: change to sand
    walksound = "dontstarve/movement/walk_grass", --TODO: change to sand
    snowsound = "dontstarve/movement/run_snow",
    mudsound = "dontstarve/movement/run_mud",
    flashpoint_modifier = 0,
    colors = GROUND_OCEAN_COLOR,
}, {
    noise_texture = "levels/textures/mini_noise_beach.tex"
})


--	[ 			   Rooms		    ]	--

modimport("scripts/map/rooms/safe_shallows")
modimport("scripts/map/rooms/kelp_forest")


--	[ 			   Tasks		    ]	--

modimport("scripts/map/tasks/safe_shallows")
modimport("scripts/map/tasks/kelp_forest")

local function LevelPreInit(level)
    if level.location == "cave" then
        level.overrides.keep_disconnected_tiles = true

        table.insert(level.tasks, "safe_shallows")
        table.insert(level.tasks, "kelp_forest")
    end
end

AddLevelPreInitAny(LevelPreInit)

--	[ 			   Caves		    ]	--

--modmain
--[[AddPrefabPostInit("cave", function(inst)
    if GLOBAL.TheWorld.ismastersim then
        inst:AddComponent("underwaterspawner")
    end
end)]]


--	[ 			Setpieces 			]	--

local Layouts = GLOBAL.require("map/layouts").Layouts
local StaticLayout = GLOBAL.require("map/static_layout")

Layouts["dive_start"] = StaticLayout.Get("map/static_layouts/safe_shallows_start")