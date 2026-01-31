-- modules/engine/turn.lua
local TurnManager = {}

TurnManager.currentTurn = "player"
TurnManager.currentUnitIndex = 0
TurnManager.unitsThatHaveMoved = {}
TurnManager.enemyTurnState = "idle"
local TurnAI = require("modules.engine.turn_ai")

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
    
    return nil
end

local function moveEnemyToward(enemyUnit, targetUnit)
    return TurnAI.moveEnemyToward(enemyUnit, targetUnit)
end

function TurnManager.startTurn()
    TurnManager.unitsThatHaveMoved = {}
    TurnManager.currentUnitIndex = 0
    
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
    
    if TurnManager.currentUnitIndex < #units then
        local currentUnit = units[TurnManager.currentUnitIndex + 1]
        
        if not TurnManager.unitsThatHaveMoved[currentUnit] then
            if not currentUnit.hasMoveOrderQueued then
                local targetUnit = TurnAI.findNearestEnemyUnit(currentUnit)
                if targetUnit then
                    moveEnemyToward(currentUnit, targetUnit)
                end
                currentUnit.hasMoveOrderQueued = true
            end
            
            if not currentUnit.isMoving then
                TurnManager.markUnitAsMoved(currentUnit)
                currentUnit.hasMoveOrderQueued = false
                TurnManager.currentUnitIndex = TurnManager.currentUnitIndex + 1
            end
        else
            TurnManager.currentUnitIndex = TurnManager.currentUnitIndex + 1
        end
    else
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
