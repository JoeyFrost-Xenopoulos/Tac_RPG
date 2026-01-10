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


function Movement.moveUnit(unit, x, y)
    -- Calculate distance moved
    local dist = math.abs(x - unit.x) + math.abs(y - unit.y)

    if dist > unit.movePoints then
        return false -- cannot move beyond remaining points
    end

    -- Clear old tile
    Game.grid[unit.y][unit.x].unit = nil

    -- Move
    unit.x = x
    unit.y = y

    -- Deduct movement points
    unit.movePoints = unit.movePoints - dist

    -- Register new tile
    Game.grid[y][x].unit = unit

    return true
end

