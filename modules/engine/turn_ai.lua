local TurnAI = {}

local Pathfinding = require("modules.engine.pathfinding")
local Map = require("modules.world.map")
local MovementEngine = require("modules.engine.movement")

local function getUnitAtTile(toX, toY, excludeUnit)
    local UnitManager = require("modules.units.manager")
    for _, unit in ipairs(UnitManager.units) do
        if unit ~= excludeUnit and unit.tileX == toX and unit.tileY == toY then
            return unit
        end
    end
    return nil
end

function TurnAI.findNearestEnemyUnit(enemyUnit)
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

function TurnAI.moveEnemyToward(enemyUnit, targetUnit)
    local UnitManager = require("modules.units.manager")
    local function canMoveWithUnits(fromX, fromY, toX, toY)
        if not Map.canMove(fromX, fromY, toX, toY) then
            return false
        end
        local occupying = UnitManager.getUnitAt(toX, toY)
        return not occupying or occupying == targetUnit
    end

    local path = Pathfinding.findPath(
        enemyUnit.tileX, enemyUnit.tileY, 
        targetUnit.tileX, targetUnit.tileY, 
        canMoveWithUnits
    )

    if path and #path > 1 then
        local steps = math.min(#path - 1, enemyUnit.maxMoveRange)
        if steps > 0 then
            local finalPos = path[steps + 1]
            local occupying = getUnitAtTile(finalPos.x, finalPos.y, enemyUnit)
            while occupying do
                steps = steps - 1
                if steps <= 0 then
                    break
                end
                finalPos = path[steps + 1]
                occupying = getUnitAtTile(finalPos.x, finalPos.y, enemyUnit)
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

return TurnAI
