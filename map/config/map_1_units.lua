-- map/config/map_1_units.lua
-- Unit spawn configuration for Map 1

-- Helper function to easily spawn enemy units
local function spawnEnemy(unitClass, x, y)
    -- Map of unit classes to their module names and enemy variants
    local enemyVariants = {
        soldier = { type = "enemy_soldier", variant = "unit" },
        archer = { type = "archer", variant = "enemy" },
        harpoon_fish = { type = "harpoon_fish", variant = "enemy" }
    }
    
    local config = enemyVariants[unitClass]
    if not config then
        error("Unknown unit class: " .. unitClass)
    end
    
    return {
        type = config.type,
        variant = config.variant,
        x = x,
        y = y
    }
end

return {
    units = {
        -- Player Units
        {
            type = "archer",
            variant = "player",
            x = 3,
            y = 3
        },
        {
            type = "soldier",
            variant = "unit2",
            x = 5,
            y = 2
        },
        {
            type = "harpoon_fish",
            variant = "player",
            x = 2,
            y = 2
        },
        
        -- Enemy Units (using helper function)
        -- Enemy Archers
        spawnEnemy("archer", 2, 4),
        spawnEnemy("archer", 13, 7),
        spawnEnemy("archer", 17, 12),
        
        -- Enemy Soldiers
        spawnEnemy("soldier", 3, 6),
        spawnEnemy("soldier", 9, 2),
        spawnEnemy("soldier", 17, 3),
        
        -- Enemy Harpoon Fish
        spawnEnemy("harpoon_fish", 8, 8),
        spawnEnemy("harpoon_fish", 10, 2)
    }
}
