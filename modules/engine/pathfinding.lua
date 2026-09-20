local Pathfinding = {}

local directions = {
    { 1,  0}, -- right
    {-1,  0}, -- left
    { 0,  1}, -- down
    { 0, -1}, -- up
}

function Pathfinding.findPath(startX, startY, goalX, goalY, checkFunc)
    local queue = {}
    local head, tail = 1, 1
    local visited = {}
    local cameFrom = {}

    local function key(x, y)
        return x .. "," .. y
    end

    queue[1] = {x = startX, y = startY}
    tail = 2
    visited[key(startX, startY)] = true

    while head < tail do
        local current = queue[head]
        head = head + 1

        if current.x == goalX and current.y == goalY then
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
                queue[tail] = {x = nx, y = ny}
                tail = tail + 1
            end
        end
    end
    return nil
end

return Pathfinding
