AddRoom("BeachHome", {
    colour = { r = 0, g = 0, b = 0, a = 0 },
    value = GROUND.SAND,
    contents = {
        countstaticlayouts = {
            ["dive_start"] = 1,
        },
        distributepercent = .25,
        distributeprefabs = {
            --rock_limpet = .05,
            --crabhole = .2,
            --rocks = .03, --trying
            --rock1 = .1, --trying
            --grassnova = .2, --trying
            --saplingnova = .2, --trying
            flint = .005,
            --sandhill = .6,
            --seashell_beached = .02,
            --wildborehouse = .01,
            --crate = .01, --oui
        },
    }
})

AddRoom("BGBeach", {
    colour = { r = 0, g = 0, b = 0, a = 0 },
    value = GROUND.SAND,
    contents = {
        distributepercent = .25,
        distributeprefabs = {
            --rock_limpet = .05,
            --crabhole = .2,
            --rocks = .03, --trying
            --rock1 = .1, --trying
            beehive = .001, --was .05,
            --grassnova = .2, --trying
            --saplingnova = .2, --trying
            flint = .005,
            --sandhill = .6,
            --seashell_beached = .02,
            --wildborehouse = .01,
            --crate = .01, --oui
        },
    }
})