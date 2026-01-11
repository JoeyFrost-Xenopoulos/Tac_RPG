-- modules/movement.lua

Movement = {}

-- Flood-fill / BFS-lite movement range
function Movement.getReachableTiles(unit)
    local reachable = {}
    local visited = {}

    local queue = {
        { x = unit.x, y = unit.y, dist = 0 }
    }

    visited[unit.y .. "," .. unit.x] = true

    while #queue > 0 do
        local current = table.remove(queue, 1)

        if current.dist > 0 then
            table.insert(reachable, { x = current.x, y = current.y })
        end

        if current.dist >= unit.movePoints then  -- use remaining movement
            goto continue
        end

        local neighbors = {
            { x = current.x + 1, y = current.y },
            { x = current.x - 1, y = current.y },
            { x = current.x, y = current.y + 1 },
            { x = current.x, y = current.y - 1 }
        }

        for _, n in ipairs(neighbors) do
            local key = n.y .. "," .. n.x

            if not visited[key]
                and Grid.isWalkable(n.x, n.y)
                and not Units.getAt(n.x, n.y) then

                visited[key] = true
                table.insert(queue, {
                    x = n.x,
                    y = n.y,
                    dist = current.dist + 1
                })
            end
        end

        ::continue::
    end

    return reachable
end


function Movement.findPath(startX, startY, endX, endY)
    local queue = { { x = startX, y = startY } }
    local cameFrom = {} -- Used to reconstruct path: cameFrom["y,x"] = {x, y}
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
            -- Check bounds, walkability, and if visited
            if not cameFrom[key] and Grid.isWalkable(n.x, n.y) then
                if not Units.getAt(n.x, n.y) or (n.x == endX and n.y == endY) then
                    cameFrom[key] = current
                    table.insert(queue, n)
                end
            end
        end
    end

    if not found then return nil end

    -- Reconstruct Path backwards
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

    -- Check if reachable
    local dist = math.abs(targetX - unit.x) + math.abs(targetY - unit.y)
    if dist > unit.movePoints then return false end

    local path = Movement.findPath(unit.x, unit.y, targetX, targetY)
    if not path then return false end

    unit.path = path
    unit.isMoving = true
    unit.moveDirX = targetX - unit.x

    return true
end