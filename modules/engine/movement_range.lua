-- modules/engine/movement_range.lua
local MovementRange = {}

local Grid = require("modules.ui.grid")
local Map  = require("modules.world.map")

MovementRange.reachable = {}

local function key(x, y)
    return x .. "," .. y
end

function MovementRange.show(unit)
    Grid.clearHighlights()
    MovementRange.reachable = {}

    local CombatSystem = require("modules.combat.combat_system")
    local maxMove = unit.maxMoveRange
    local attackRange = CombatSystem.getAttackRange(unit)
    local startX, startY = unit.tileX, unit.tileY
    local visited = {}
    local moveQueue = {}
    local moveTiles = {}

    table.insert(moveQueue, {x = startX, y = startY, dist = 0})
    visited[key(startX, startY)] = true
    table.insert(moveTiles, {x = startX, y = startY})

    while #moveQueue > 0 do
        local node = table.remove(moveQueue, 1)
        local x, y, dist = node.x, node.y, node.dist

        if dist > 0 then
            Grid.highlightTile(x, y, {0.2, 0.4, 1.0, 0.4})
            MovementRange.reachable[key(x, y)] = true
        end

        if dist < maxMove then
            for _, d in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
                local nx, ny = x + d[1], y + d[2]
                local k = key(nx, ny)

                if not visited[k] and Map.canMove(x, y, nx, ny) then
                    local UnitManager = require("modules.units.manager")
                    local blocked = false
                    for _, otherUnit in ipairs(UnitManager.units) do
                        if otherUnit ~= unit and otherUnit.tileX == nx and otherUnit.tileY == ny then
                            if not otherUnit.isPlayer then
                                blocked = true
                                break
                            end
                        end
                    end
                    
                    if not blocked then
                        visited[k] = true
                        table.insert(moveQueue, {x = nx, y = ny, dist = dist + 1})
                        table.insert(moveTiles, {x = nx, y = ny})
                    end
                end
            end
        end
    end

    local attackHighlighted = {}

    for _, tile in ipairs(moveTiles) do
        for dx = -attackRange, attackRange do
            for dy = -attackRange, attackRange do
                if math.abs(dx) + math.abs(dy) <= attackRange then
                    local ax, ay = tile.x + dx, tile.y + dy
                    local ak = key(ax, ay)
                    if not visited[ak] and not attackHighlighted[ak] then
                        Grid.highlightTile(ax, ay, {1.0, 0.2, 0.2, 0.4})
                        attackHighlighted[ak] = true
                    end
                end
            end
        end
    end
end

function MovementRange.clear()
    Grid.clearHighlights()
    MovementRange.reachable = {}
end

function MovementRange.showAttackRange(unit)
    Grid.clearHighlights()
    local CombatSystem = require("modules.combat.combat_system")
    local attackRange = CombatSystem.getAttackRange(unit)
    local x, y = unit.tileX, unit.tileY

    for dx = -attackRange, attackRange do
        for dy = -attackRange, attackRange do
            if math.abs(dx) + math.abs(dy) <= attackRange then
                local ax, ay = x + dx, y + dy
                if ax ~= x or ay ~= y then  -- don't highlight the unit's own tile
                    Grid.highlightTile(ax, ay, {1.0, 0.2, 0.2, 0.4})
                end
            end
        end
    end
end

function MovementRange.canReach(x, y)
    return MovementRange.reachable[key(x, y)] == true
end

return MovementRange