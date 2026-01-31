local TurnAI = {}

local Pathfinding = require("modules.engine.pathfinding")
local Map = require("modules.world.map")
local MovementEngine = require("modules.engine.movement")

local function isUnitOccupyingTile(toX, toY, excludeUnit)
    local UnitManager = require("modules.units.manager")
    for _, unit in ipairs(UnitManager.units) do
        if unit ~= excludeUnit and unit.tileX == toX and unit.tileY == toY then
            return true
        end
    end
    return false
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

return TurnAI
