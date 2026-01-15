-- modules/movement.lua
Movement = {}

-- Flood-fill / BFS-lite movement range
function Movement.getReachableTiles(unit)
    local reachable = {}
    local visited = {}
    local queue = {{ x = unit.x, y = unit.y, dist = 0 }}
    visited[unit.y .. "," .. unit.x] = true

    while #queue > 0 do
        local current = table.remove(queue, 1)
        if current.dist > 0 then table.insert(reachable, { x = current.x, y = current.y }) end
        if current.dist >= unit.movePoints then goto continue end

        local neighbors = {
            { x = current.x + 1, y = current.y },
            { x = current.x - 1, y = current.y },
            { x = current.x, y = current.y + 1 },
            { x = current.x, y = current.y - 1 }
        }

        for _, n in ipairs(neighbors) do
            local key = n.y .. "," .. n.x
            if not visited[key] and Grid.isWalkable(n.x, n.y, current.x, current.y) then
                visited[key] = true
                table.insert(queue, { x = n.x, y = n.y, dist = current.dist + 1 })
            end
        end
        ::continue::
    end
    return reachable
end

function Movement.findPath(startX, startY, endX, endY)
    local queue = { { x = startX, y = startY } }
    local cameFrom = {} 
    cameFrom[startY .. "," .. startX] = "start"
    local found = false

    while #queue > 0 do
        local current = table.remove(queue, 1)
        if current.x == endX and current.y == endY then
            found = true
            break
        end

        local neighbors = {
            { x = current.x + 1, y = current.y },
            { x = current.x - 1, y = current.y },
            { x = current.x, y = current.y + 1 },
            { x = current.x, y = current.y - 1 }
        }

        for _, n in ipairs(neighbors) do
            local key = n.y .. "," .. n.x
            if not cameFrom[key] and Grid.isWalkable(n.x, n.y, current.x, current.y) then
                local targetN = n

                local targetKey = targetN.y .. "," .. targetN.x
                if not cameFrom[targetKey] then
                    cameFrom[targetKey] = current
                    table.insert(queue, targetN)
                end
            end
        end
    end

    if not found then return nil end

    local path = {}
    local curr = { x = endX, y = endY }
    while curr ~= "start" do
        table.insert(path, 1, curr)
        local key = curr.y .. "," .. curr.x
        curr = cameFrom[key]
    end
    return path
end

function Movement.moveUnit(unit, targetX, targetY)
    if unit.isMoving then return false end

    local dist = math.abs(targetX - unit.x) + math.abs(targetY - unit.y)
    if dist > unit.movePoints then return false end

    local path = Movement.findPath(unit.x, unit.y, targetX, targetY)
    if not path then return false end

    unit.path = path
    unit.isMoving = true
    unit.moveDirX = targetX - unit.x

    return true
end