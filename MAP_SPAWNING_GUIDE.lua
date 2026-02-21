-- MAP UNIT SPAWNING GUIDE
-- How to add a new map with units

-- OVERVIEW:
-- The unit spawning system is now map-agnostic. Each map has its own
-- unit configuration file that defines which units spawn and where.

-- ADDING A NEW MAP:

-- 1. Create your map file
--    Example: map/map_2.lua

-- 2. Create a unit configuration file for your map
--    Example: map/config/map_2_units.lua

-- 3. Update main.lua to load the correct map and config:
--    
--    function love.load()
--        Map.load("map/map_2.lua")  -- Change this line
--        -- ... other setup code ...
--        local mapUnitConfig = require("map.config.map_2_units")  -- Change this line
--        UnitSpawner.spawnUnits(mapUnitConfig, UnitManager)
--    end

-- UNIT CONFIGURATION FILE STRUCTURE:

-- Each unit config file should return a table with a 'units' array.
-- Example: map/config/map_2_units.lua

--[[
return {
    units = {
        {
            type = "archer",        -- Unit module name
            variant = "player",     -- Which variant of the unit
            x = 5,                  -- Grid X position
            y = 3                   -- Grid Y position
        },
        {
            type = "soldier",
            variant = "unit",
            x = 6,
            y = 4
        },
        {
            type = "enemy_soldier",
            variant = "unit",
            x = 10,
            y = 5
        }
    }
}
--]]

-- AVAILABLE UNIT TYPES AND VARIANTS:

-- archer:
--   - "player" (ArcherPlayer)
--   - "enemy" (ArcherEnemy)

-- soldier:
--   - "unit" (Soldier)
--   - "unit2" (Soldier2)

-- enemy_soldier:
--   - "unit" (Enemy)
--   - "unit2" (Enemy2)

-- harpoon_fish:
--   - "player" (HarpoonFishPlayer)
--   - "enemy" (HarpoonFishEnemy)

-- UNIT SPAWNER BEHAVIOR:

-- UnitSpawner.spawnUnits(config, UnitManager):
--   - Clears all existing units from UnitManager
--   - Loads unit modules dynamically
--   - Adds units to UnitManager
--   - Sets their starting positions

-- UnitSpawner.clearModuleCache():
--   - Unloads cached unit modules (useful for memory management)
