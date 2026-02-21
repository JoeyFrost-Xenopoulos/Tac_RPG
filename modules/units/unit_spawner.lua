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

-- Helper to get unit and setPosition functions from module with variant
local function getUnitAndSetPosition(unitModule, variant)
    -- Check if module has a factory function (new system)
    if unitModule.createInstance then
        local instance = unitModule.createInstance(variant)
        return instance.unit, instance.setPosition
    end
    
    -- Fall back to legacy singleton system
    local unitInstance, setPositionFunc
    
    if variant then
        if variant == "unit" then
            -- Special case for units named .unit
            unitInstance = unitModule.unit
            setPositionFunc = unitModule.setPosition
        elseif variant == "unit2" then
            -- Special case for units named .unit2
            unitInstance = unitModule.unit2
            setPositionFunc = unitModule.setPosition2
        elseif unitModule[variant] and unitModule[variant].unit then
            -- Standard nested structure (e.g., module.player.unit)
            unitInstance = unitModule[variant].unit
            setPositionFunc = unitModule[variant].setPosition
        else
            error("Variant '" .. variant .. "' not found in unit module")
        end
    else
        -- No variant - try to find the unit in different ways
        if unitModule.unit then
            unitInstance = unitModule.unit
            setPositionFunc = unitModule.setPosition
        elseif unitModule.player then
            -- Assume player variant if no explicit variant given
            unitInstance = unitModule.player.unit
            setPositionFunc = unitModule.player.setPosition
        else
            error("Could not find unit in module")
        end
    end
    
    return unitInstance, setPositionFunc
end

-- Spawn all units for a given map
function UnitSpawner.spawnUnits(spawnConfig, UnitManager)
    if not spawnConfig or not spawnConfig.units then
        print("Warning: No spawn config provided for map")
        return
    end

    -- Clear existing units
    UnitManager.units = {}
    UnitManager.selectedUnit = nil

    -- Spawn each unit according to config
    for _, unitSpawn in ipairs(spawnConfig.units) do
        local unitModule = loadUnitModule(unitSpawn.type)
        local unitInstance, setPositionFunc = getUnitAndSetPosition(unitModule, unitSpawn.variant)
        
        -- Add to manager
        UnitManager.add(unitInstance)
        
        -- Set position
        setPositionFunc(unitSpawn.x, unitSpawn.y)
    end
end

-- Unload all unit modules (useful for map transitions)
function UnitSpawner.clearModuleCache()
    unitModules = {}
end

return UnitSpawner
