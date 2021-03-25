AddRoom("BeachHome", {
    colour = { r = 0, g = 0, b = 0, a = 0 },
    value = GROUND.SAND,
    contents = {
        countstaticlayouts = {
            ["dive_start"] = 1,
        },
        distributepercent = .05,
        distributeprefabs = {
            rock1 = 0.02,
            crabhole = 0.02,
            sandune = 0.02,

            small_crate = 0.005,
            medium_crate = 0.005,
            big_crate = 0.005,

            crab = 0.03,
            small_fish = 0.03,
            dogfish = 0.03,
            boids = 0.05,
        },
    }
})

AddRoom("BGBeach", {
    colour = { r = 0, g = 0, b = 0, a = 0 },
    value = GROUND.SAND,
    contents = {
        distributepercent = .15,
        distributeprefabs = {
            rock1 = 0.02,
            crabhole = 0.01,
            sandune = 0.02,
            coral = 0.02,

            small_crate = 0.005,
            medium_crate = 0.005,
            big_crate = 0.005,
            drowned = 0.005,

            crab = 0.03,
            small_fish = 0.03,
            dogfish = 0.03,
            boids = 0.05,
        },
    }
})