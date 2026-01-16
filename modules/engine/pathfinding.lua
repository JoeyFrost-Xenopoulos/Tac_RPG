local Pathfinding = {}

local directions = {
    { 1,  0}, -- right
    {-1,  0}, -- left
    { 0,  1}, -- down
    { 0, -1}, -- up
}

function Pathfinding.findPath(startX, startY, goalX, goalY, checkFunc)
    local queue = {}
    local visited = {}
    local cameFrom = {}

    local function key(x, y)
        return x .. "," .. y
    end

    table.insert(queue, {x = startX, y = startY})
    visited[key(startX, startY)] = true

    while #queue > 0 do
        local current = table.remove(queue, 1)

        if current.x == goalX and current.y == goalY then
            -- Reconstruct path
            local path = {}
            local k = key(goalX, goalY)

            while k do
                local pos = cameFrom[k]
                if pos then
                    table.insert(path, 1, pos)
                    k = key(pos.x, pos.y)
                else
                    break
                end
            end

            table.insert(path, {x = goalX, y = goalY})
            return path
    end

for _, d in ipairs(directions) do
            local nx = current.x + d[1]
            local ny = current.y + d[2]
            local nk = key(nx, ny)

            if not visited[nk] and checkFunc(current.x, current.y, nx, ny) then
                
                visited[nk] = true
                cameFrom[nk] = {x = current.x, y = current.y}
                table.insert(queue, {x = nx, y = ny})
            end
        end
    end
    return nil
end

return Pathfinding
