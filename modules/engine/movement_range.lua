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

    local maxMove = unit.maxMoveRange
    local attackRange = unit.attackRange or 1
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
                    visited[k] = true
                    table.insert(moveQueue, {x = nx, y = ny, dist = dist + 1})
                    table.insert(moveTiles, {x = nx, y = ny})
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
                        Grid.highlightTile(ax, ay, {1.0, 0.2, 0.2, 0.4}) -- Red Color
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

function MovementRange.canReach(x, y)
    return MovementRange.reachable[key(x, y)] == true
end

return MovementRange