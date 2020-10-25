AddTask("safe_shallows", {
    locks = {},
    keys_given = { KEYS.ISLAND_DEEP },
    region_id = "islanddeep",
    level_set_piece_blocker = true,
    room_tags = { "RoadPoison", "deeparea", "not_mainland" },
    room_choices = {
        ["BeachHome"] = 1,
        ["BGBeach"] = 9
    },
    room_bg = GROUND.SAND,
    background_room = "Empty_Cove",
    cove_room_name = "Empty_Cove",
    make_loop = true,
    crosslink_factor = 2,
    colour = { r = 0, g = 0, b = 0, a = 0 },
})