-- map/config/map_1_units.lua
-- Unit spawn configuration for Map 1

return {
    units = {
        -- Archer (Player)
        {
            type = "archer",
            variant = "player",
            x = 3,
            y = 3
        },
        -- Archer (Enemy)
        {
            type = "archer",
            variant = "enemy",
            x = 6,
            y = 2
        },
        -- Soldier (Unit 2)
        {
            type = "soldier",
            variant = "unit2",
            x = 5,
            y = 2
        },
        -- Enemy Soldier (Unit 1)
        {
            type = "enemy_soldier",
            variant = "unit",
            x = 9,
            y = 2
        },
        -- Harpoon Fish (Player)
        {
            type = "harpoon_fish",
            variant = "player",
            x = 5,
            y = 7
        },
        -- Harpoon Fish (Enemy)
        {
            type = "harpoon_fish",
            variant = "enemy",
            x = 6,
            y = 7
        }
    }
}
