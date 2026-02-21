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

local function manhattanDistance(x1, y1, x2, y2)
    return math.abs(x2 - x1) + math.abs(y2 - y1)
end

function TurnAI.findNearestEnemyUnit(enemyUnit)
    local UnitManager = require("modules.units.manager")
    local nearestDist = math.huge
    local nearestUnit = nil

    for _, unit in ipairs(UnitManager.units) do
        if unit.isPlayer then
            local dist = manhattanDistance(enemyUnit.tileX, enemyUnit.tileY, unit.tileX, unit.tileY)
            if dist < nearestDist then
                nearestDist = dist
                nearestUnit = unit
            end
        end
    end

    return nearestUnit
end

-- Check if this unit can possibly reach attack range of any enemy
function TurnAI.canReachAnyEnemy(enemyUnit)
    local UnitManager = require("modules.units.manager")
    local CombatSystem = require("modules.combat.combat_system")
    local weapon = CombatSystem.getWeapon(enemyUnit.weapon)
    local attackRange = weapon.range or 1
    local minRange = weapon.minRange or 1
    local maxMove = enemyUnit.maxMoveRange

    for _, unit in ipairs(UnitManager.units) do
        if unit.isPlayer then
            local dist = manhattanDistance(enemyUnit.tileX, enemyUnit.tileY, unit.tileX, unit.tileY)
            -- Can reach if: after moving, we can be within attack range
            -- That means: dist - maxMove <= attackRange
            if dist - maxMove <= attackRange then
                return true
            end
        end
    end

    return false
end

-- Check if the enemy is too close for their minimum range
local function isTooCloseToTarget(enemyUnit, targetUnit)
    local CombatSystem = require("modules.combat.combat_system")
    local weapon = CombatSystem.getWeapon(enemyUnit.weapon)
    local minRange = weapon.minRange or 1
    local dist = manhattanDistance(enemyUnit.tileX, enemyUnit.tileY, targetUnit.tileX, targetUnit.tileY)
    return dist < minRange
end

-- Find best position to move away from target
local function findRetreatPosition(enemyUnit, targetUnit)
    local CombatSystem = require("modules.combat.combat_system")
    local UnitManager = require("modules.units.manager")
    local weapon = CombatSystem.getWeapon(enemyUnit.weapon)
    local targetRange = weapon.minRange or weapon.range or 1
    local maxMove = enemyUnit.maxMoveRange
    
    local bestPos = nil
    local bestScore = -math.huge
    
    -- BFS to find all reachable tiles
    local visited = {}
    local queue = {{x = enemyUnit.tileX, y = enemyUnit.tileY, dist = 0}}
    local reachableTiles = {}
    
    local function key(x, y)
        return x .. "," .. y
    end
    
    visited[key(enemyUnit.tileX, enemyUnit.tileY)] = true
    
    while #queue > 0 do
        local node = table.remove(queue, 1)
        table.insert(reachableTiles, {x = node.x, y = node.y, dist = node.dist})
        
        if node.dist < maxMove then
            for _, d in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
                local nx, ny = node.x + d[1], node.y + d[2]
                local k = key(nx, ny)
                
                if not visited[k] and Map.canMove(node.x, node.y, nx, ny) then
                    local occupying = getUnitAtTile(nx, ny, enemyUnit)
                    if not occupying then
                        visited[k] = true
                        table.insert(queue, {x = nx, y = ny, dist = node.dist + 1})
                    end
                end
            end
        end
    end
    
    -- Score each reachable tile
    for _, tile in ipairs(reachableTiles) do
        if tile.x ~= enemyUnit.tileX or tile.y ~= enemyUnit.tileY then
            local distToTarget = manhattanDistance(tile.x, tile.y, targetUnit.tileX, targetUnit.tileY)
            
            -- Prefer positions at exactly the target range
            local score = 0
            if distToTarget == targetRange then
                score = 100  -- Perfect position
            elseif distToTarget > targetRange then
                score = 50 - (distToTarget - targetRange)  -- Further is worse
            else
                score = -(targetRange - distToTarget) * 10  -- Too close is bad
            end
            
            -- Penalize being far from movement origin (prefer closer retreats)
            score = score - tile.dist * 2
            
            if score > bestScore then
                bestScore = score
                bestPos = tile
            end
        end
    end
    
    return bestPos
end

function TurnAI.moveEnemyToward(enemyUnit, targetUnit)
    local CombatSystem = require("modules.combat.combat_system")
    local weapon = CombatSystem.getWeapon(enemyUnit.weapon)
    local attackRange = weapon.range or 1
    local minRange = weapon.minRange or 1
    
    -- If we're too close (within minRange), we need to retreat
    if isTooCloseToTarget(enemyUnit, targetUnit) then
        local retreatPos = findRetreatPosition(enemyUnit, targetUnit)
        if retreatPos then
            local UnitManager = require("modules.units.manager")
            local function canMoveWithUnits(fromX, fromY, toX, toY)
                if not Map.canMove(fromX, fromY, toX, toY) then
                    return false
                end
                local occupying = UnitManager.getUnitAt(toX, toY)
                return not occupying
            end
            
            local path = Pathfinding.findPath(
                enemyUnit.tileX, enemyUnit.tileY,
                retreatPos.x, retreatPos.y,
                canMoveWithUnits
            )
            
            if path and #path > 1 then
                MovementEngine.start(enemyUnit, path)
                return true
            end
        end
        return false
    end
    
    -- Otherwise, move toward the target to get into attack range
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
        
        -- Try to stop at optimal attack range
        local bestStep = steps
        for i = 1, steps do
            local pos = path[i + 1]
            local dist = manhattanDistance(pos.x, pos.y, targetUnit.tileX, targetUnit.tileY)
            if dist >= minRange and dist <= attackRange then
                bestStep = i
                break
            end
        end
        
        if bestStep > 0 then
            local finalPos = path[bestStep + 1]
            local occupying = getUnitAtTile(finalPos.x, finalPos.y, enemyUnit)
            while occupying do
                bestStep = bestStep - 1
                if bestStep <= 0 then
                    break
                end
                finalPos = path[bestStep + 1]
                occupying = getUnitAtTile(finalPos.x, finalPos.y, enemyUnit)
            end

            if bestStep > 0 then
                local trimmedPath = {path[1]}
                for i = 2, bestStep + 1 do
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
