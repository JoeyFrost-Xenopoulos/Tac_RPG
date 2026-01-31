-- modules/engine/turn.lua
-- Turn management system for tactical RPG
local TurnManager = {}

TurnManager.currentTurn = "player" -- "player" or "enemy"
TurnManager.currentUnitIndex = 0
TurnManager.unitsThatHaveMoved = {} -- Set to track which units have moved
TurnManager.enemyTurnState = "idle" -- "idle", "moving"

local function getAvailableUnits()
    local UnitManager = require("modules.units.manager")
    local units = {}
    
    if TurnManager.currentTurn == "player" then
        for _, unit in ipairs(UnitManager.units) do
            if unit.isPlayer then
                table.insert(units, unit)
            end
        end
    else
        for _, unit in ipairs(UnitManager.units) do
            if not unit.isPlayer then
                table.insert(units, unit)
            end
        end
    end
    
    return units
end

local function getNextAvailableUnit()
    local units = getAvailableUnits()
    
    if #units == 0 then
        return nil
    end
    
    for i = TurnManager.currentUnitIndex + 1, #units do
        if not TurnManager.unitsThatHaveMoved[units[i]] then
            TurnManager.currentUnitIndex = i
            return units[i]
        end
    end
    
    -- If all units have moved, turn is over
    return nil
end

local function findNearestEnemyUnit(enemyUnit)
    local UnitManager = require("modules.units.manager")
    local nearestDist = math.huge
    local nearestUnit = nil
    
    for _, unit in ipairs(UnitManager.units) do
        if unit.isPlayer then
            local dist = math.abs(unit.tileX - enemyUnit.tileX) + 
                         math.abs(unit.tileY - enemyUnit.tileY)
            if dist < nearestDist then
                nearestDist = dist
                nearestUnit = unit
            end
        end
    end
    
    return nearestUnit
end

local function isUnitOccupyingTile(toX, toY, excludeUnit)
    local UnitManager = require("modules.units.manager")
    for _, unit in ipairs(UnitManager.units) do
        if unit ~= excludeUnit and unit.tileX == toX and unit.tileY == toY then
            return true
        end
    end
    return false
end

local function moveEnemyToward(enemyUnit, targetUnit)
    local Pathfinding = require("modules.engine.pathfinding")
    local Map = require("modules.world.map")
    local MovementEngine = require("modules.engine.movement")
    
    local path = Pathfinding.findPath(
        enemyUnit.tileX, enemyUnit.tileY, 
        targetUnit.tileX, targetUnit.tileY, 
        Map.canMove
    )
    
    if path and #path > 1 then
        local steps = math.min(#path - 1, enemyUnit.maxMoveRange)
        if steps > 0 then
            local finalPos = path[steps + 1]
            if isUnitOccupyingTile(finalPos.x, finalPos.y, enemyUnit) then
                steps = steps - 1
            end
            
            if steps > 0 then
                local trimmedPath = {path[1]}
                for i = 2, steps + 1 do
                    table.insert(trimmedPath, path[i])
                end
                MovementEngine.start(enemyUnit, trimmedPath)
                return true
            end
        end
    end
    
    return false
end

function TurnManager.startTurn()
    -- Reset units that have acted
    TurnManager.unitsThatHaveMoved = {}
    TurnManager.currentUnitIndex = 0
    
    -- Mark all units as not acted
    local UnitManager = require("modules.units.manager")
    for _, unit in ipairs(UnitManager.units) do
        unit.hasActed = false
    end
    
    if TurnManager.currentTurn == "player" then
        TurnManager.enemyTurnState = "idle"
    else
        TurnManager.enemyTurnState = "moving"
    end
end

function TurnManager.selectNextUnit()
    local unit = getNextAvailableUnit()
    
    if unit then
        local UnitManager = require("modules.units.manager")
        UnitManager.select(unit)
    else
        -- All units have moved, end turn
        TurnManager.endTurn()
    end
end

function TurnManager.markUnitAsMoved(unit)
    TurnManager.unitsThatHaveMoved[unit] = true
    unit.hasActed = true
end

function TurnManager.areAllUnitsMoved()
    local units = getAvailableUnits()
    for _, u in ipairs(units) do
        if not TurnManager.unitsThatHaveMoved[u] then
            return false
        end
    end
    return true
end

function TurnManager.updateEnemyTurn(dt)
    if TurnManager.currentTurn ~= "enemy" or TurnManager.enemyTurnState ~= "moving" then 
        return 
    end
    
    local units = getAvailableUnits()
    
    -- Move to next enemy that hasn't moved
    if TurnManager.currentUnitIndex < #units then
        local currentUnit = units[TurnManager.currentUnitIndex + 1]
        
        if not TurnManager.unitsThatHaveMoved[currentUnit] then
            -- First time seeing this unit, move it
            if not currentUnit.hasMoveOrderQueued then
                local targetUnit = findNearestEnemyUnit(currentUnit)
                if targetUnit then
                    moveEnemyToward(currentUnit, targetUnit)
                end
                currentUnit.hasMoveOrderQueued = true
            end
            
            -- Wait for movement to complete
            if not currentUnit.isMoving then
                TurnManager.markUnitAsMoved(currentUnit)
                currentUnit.hasMoveOrderQueued = false
                TurnManager.currentUnitIndex = TurnManager.currentUnitIndex + 1
            end
        else
            TurnManager.currentUnitIndex = TurnManager.currentUnitIndex + 1
        end
    else
        -- All enemies have moved, end turn
        TurnManager.endTurn()
    end
end

function TurnManager.endTurn()
    local UnitManager = require("modules.units.manager")
    UnitManager.deselectAll()
    
    if TurnManager.currentTurn == "player" then
        TurnManager.currentTurn = "enemy"
        TurnManager.startTurn()
    else
        TurnManager.currentTurn = "player"
        TurnManager.startTurn()
    end
end

function TurnManager.getCurrentTurn()
    return TurnManager.currentTurn
end

function TurnManager.getCurrentUnit()
    local units = getAvailableUnits()
    return units[TurnManager.currentUnitIndex]
end

return TurnManager
