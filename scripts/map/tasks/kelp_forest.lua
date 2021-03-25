AddTask("kelp_forest", {
    locks = { KEYS.ISLAND_DEEP_TIER1 },
    keys_given = { KEYS.ISLAND_DEEP_TIER2 },
    region_id = "islanddeep",
    --level_set_piece_blocker = true,
    --room_tags = { "RoadPoison", "deeparea", "not_mainland" },
    room_choices = {
        ["BGKelpForest"] = 5
    },
    room_bg = GROUND.SAND_DEEP,
    background_room = "BGKelpForest",
    colour = { r = 0, g = 0, b = 0, a = 0 },
})