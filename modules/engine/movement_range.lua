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

    local maxRange = unit.maxMoveRange
    local startX, startY = unit.tileX, unit.tileY

    local visited = {}
    local queue = {}

    table.insert(queue, {x = startX, y = startY, dist = 0})
    visited[key(startX, startY)] = true

    while #queue > 0 do
        local node = table.remove(queue, 1)
        local x, y, dist = node.x, node.y, node.dist

        if dist > 0 then
            Grid.highlightTile(x, y, {0.2, 0.4, 1.0, 0.4})
            MovementRange.reachable[key(x, y)] = true
        end

        if dist >= maxRange then goto continue end

        for _, d in ipairs({{1,0},{-1,0},{0,1},{0,-1}}) do
            local nx, ny = x + d[1], y + d[2]
            local k = key(nx, ny)

            if not visited[k] and Map.canMove(x, y, nx, ny) then
                visited[k] = true
                table.insert(queue, {x = nx, y = ny, dist = dist + 1})
            end
        end

        ::continue::
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
