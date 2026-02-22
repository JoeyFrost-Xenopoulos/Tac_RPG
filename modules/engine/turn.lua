-- modules/engine/turn.lua
local TurnManager = {}

TurnManager.currentTurn = "player"
TurnManager.currentUnitIndex = 0
TurnManager.unitsThatHaveMoved = {}
TurnManager.enemyTurnState = "idle"
TurnManager.enemyAttackTarget = nil  -- Track the target of the current enemy attacker
local TurnAI = require("modules.engine.turn_ai")
local TurnOverlay = require("modules.ui.turn_overlay")
local Attack = require("modules.engine.attack")

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
    local Effects = require("modules.audio.sound_effects")
    TurnManager.unitsThatHaveMoved = {}
    TurnManager.currentUnitIndex = 0
    TurnManager.enemyBattleInProgress = false
    TurnManager.enemyCurrentUnit = nil

    Effects.playNextTurn()
    
    local UnitManager = require("modules.units.manager")
    for _, unit in ipairs(UnitManager.units) do
        unit.hasActed = false
        unit.hasMoveOrderQueued = false
    end
    
    if TurnManager.currentTurn == "player" then
        TurnOverlay.show("Player Turn", true)
        TurnManager.enemyTurnState = "idle"
        TurnManager.enemyAttackTarget = nil  -- Clear attack target when player turn starts
    else
        TurnOverlay.show("Enemy Turn", false)
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

-- Helper function to check if any unit is currently moving
local function isAnyUnitMoving()
    local UnitManager = require("modules.units.manager")
    for _, unit in ipairs(UnitManager.units) do
        if unit.isMoving then
            return true
        end
    end
    return false
end

function TurnManager.updateEnemyTurn(dt)
    if TurnManager.currentTurn ~= "enemy" or TurnManager.enemyTurnState ~= "moving" then 
        return 
    end
    
    if TurnOverlay.isActive() then
        return
    end
    
    local Battle = require("modules.combat.battle")
    
    -- If a battle is in progress, wait for it to complete
    if Battle.visible then
        return
    end
    
    -- Check if we just finished a battle
    if TurnManager.enemyBattleInProgress then
        local currentUnit = TurnManager.enemyCurrentUnit
        if currentUnit then
            TurnManager.markUnitAsMoved(currentUnit)
            currentUnit.hasMoveOrderQueued = false
        end
        TurnManager.enemyBattleInProgress = false
        TurnManager.enemyCurrentUnit = nil
        TurnManager.enemyAttackTarget = nil  -- Clear attack target after battle
        TurnManager.currentUnitIndex = TurnManager.currentUnitIndex + 1
        return
    end
    
    -- Wait for all units to finish moving before processing the next unit
    if isAnyUnitMoving() then
        return
    end
    
    local units = getAvailableUnits()
    
    if TurnManager.currentUnitIndex < #units then
        local currentUnit = units[TurnManager.currentUnitIndex + 1]
        
        if not TurnManager.unitsThatHaveMoved[currentUnit] then
            if not currentUnit.hasMoveOrderQueued then
                local targetUnit = TurnAI.findNearestEnemyUnit(currentUnit)
                -- Only move if we can actually reach an enemy
                if targetUnit and TurnAI.canReachAnyEnemy(currentUnit) then
                    moveEnemyToward(currentUnit, targetUnit)
                end
                currentUnit.hasMoveOrderQueued = true
            end
            
            if not currentUnit.isMoving then
                -- Enemy finished moving, check if they can attack
                if Attack.canAttack(currentUnit) then
                    local enemies = Attack.getEnemiesInRange(currentUnit)
                    if #enemies > 0 then
                        local target = enemies[1]
                        TurnManager.enemyAttackTarget = target  -- Update to the actual target being attacked
                        -- Make attacker face the target
                        if target.tileX > currentUnit.tileX then
                            currentUnit.facingX = 1
                        elseif target.tileX < currentUnit.tileX then
                            currentUnit.facingX = -1
                        end
                        -- Make defender face the attacker
                        if currentUnit.tileX > target.tileX then
                            target.facingX = 1
                        elseif currentUnit.tileX < target.tileX then
                            target.facingX = -1
                        end
                        -- Show battle screen instead of direct damage
                        Battle.startBattle(currentUnit, target)
                        TurnManager.enemyBattleInProgress = true
                        TurnManager.enemyCurrentUnit = currentUnit
                    else
                        -- No target, just mark as moved
                        TurnManager.markUnitAsMoved(currentUnit)
                        currentUnit.hasMoveOrderQueued = false
                        TurnManager.currentUnitIndex = TurnManager.currentUnitIndex + 1
                    end
                else
                    -- Can't attack, just mark as moved
                    TurnManager.markUnitAsMoved(currentUnit)
                    currentUnit.hasMoveOrderQueued = false
                    TurnManager.currentUnitIndex = TurnManager.currentUnitIndex + 1
                end
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
    UnitManager.deselectAll()    TurnManager.enemyAttackTarget = nil  -- Clear attack target when turn ends    
    if TurnManager.currentTurn == "player" then
        TurnManager.currentTurn = "enemy"
        TurnManager.startTurn()
    else
        TurnManager.currentTurn = "player"
        TurnManager.startTurn()
        -- Increment turn counter when a new player turn begins
        local TurnCounter = require("modules.ui.turn_counter")
        TurnCounter.incrementTurn()
    end
end

function TurnManager.getCurrentTurn()
    return TurnManager.currentTurn
end

function TurnManager.getCurrentUnit()
    local units = getAvailableUnits()
    return units[TurnManager.currentUnitIndex]
end

function TurnManager.isOverlayActive()
    return TurnOverlay.isActive()
end

return TurnManager
