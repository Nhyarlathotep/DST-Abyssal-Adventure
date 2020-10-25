return {
    version = "1.1",
    luaversion = "5.1",
    orientation = "orthogonal",
    width = 5,
    height = 5,
    tilewidth = 64,
    tileheight = 64,
    properties = {},
    tilesets = {
        {
            name = "tiles",
            firstgid = 1,
            tilewidth = 64,
            tileheight = 64,
            spacing = 0,
            margin = 0,
            image = "",
            imagewidth = 512,
            imageheight = 128,
            properties = {},
            tiles = {}
        }
    },
    layers = {
        {
            type = "tilelayer",
            name = "BG_TILES",
            x = 0,
            y = 0,
            width = 5,
            height = 5,
            visible = true,
            opacity = 1,
            properties = {},
            encoding = "lua",
            data = {
                5, 95, 5, 95, 5,
                95, 5, 5, 5, 95,
                5, 95, 5, 95, 5,
                95, 5, 95, 5, 95,
                5, 95, 5, 95, 5
            }
        },
        {
            type = "objectgroup",
            name = "FG_OBJECTS",
            visible = true,
            opacity = 1,
            properties = {},
            objects = {
                {
                    name = "",
                    type = "anchor_exit",
                    shape = "rectangle",
                    x = 134,
                    y = 133,
                    width = 55,
                    height = 55,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower",
                    shape = "rectangle",
                    x = 203,
                    y = 139,
                    width = 7,
                    height = 12,
                    visible = true,
                    properties = {}
                },
                {
                    name = "",
                    type = "flower",
                    shape = "rectangle",
                    x = 228,
                    y = 170,
                    width = 12,
                    height = 9,
                    visible = true,
                    properties = {}
                }
            }
        }
    }
}
