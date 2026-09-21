-- modules/units/unit_spawner.lua
-- Handles spawning units based on map configuration

local UnitSpawner = {}

-- Cache for unit module definitions
local unitModules = {}

-- Load a unit module by name (e.g., "archer", "soldier")
local function loadUnitModule(unitType)
    if not unitModules[unitType] then
        unitModules[unitType] = require("modules.units." .. unitType)
    end
    return unitModules[unitType]
end

-- Helper to get unit instance from module with variant
local function getUnitInstance(unitModule, variant)
    if unitModule.createInstance then
        return unitModule.createInstance(variant)
    end
    
    local unitInstance
    
    if variant then
        if variant == "unit" then
            unitInstance = unitModule.unit
        elseif variant == "unit2" then
            unitInstance = unitModule.unit2
        elseif unitModule[variant] and unitModule[variant].unit then
            unitInstance = unitModule[variant].unit
        else
            error("Variant '" .. variant .. "' not found in unit module")
        end
    else
        if unitModule.unit then
            unitInstance = unitModule.unit
        elseif unitModule.player then
            unitInstance = unitModule.player.unit
        else
            error("Could not find unit in module")
        end
    end
    
    return unitInstance
end

-- Spawn all units for a given map
function UnitSpawner.spawnUnits(spawnConfig, UnitManager)
    if not spawnConfig or not spawnConfig.units then
        print("Warning: No spawn config provided for map")
        return
    end

    -- Clear existing units
    UnitManager.clear()

    -- Spawn each unit according to config
    for _, unitSpawn in ipairs(spawnConfig.units) do
        local unitModule = loadUnitModule(unitSpawn.type)
        local unitInstance = getUnitInstance(unitModule, unitSpawn.variant)
        
        unitInstance:setPosition(unitSpawn.x, unitSpawn.y)
        
        -- Add to manager
        UnitManager.add(unitInstance)
    end
end

-- Unload all unit modules (useful for map transitions)
function UnitSpawner.clearModuleCache()
    unitModules = {}
end

return UnitSpawner
