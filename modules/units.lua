-- units.lua

Units = {
    list = {}
}

function Units.create(data)
    local unit = {
        id = #Units.list + 1,
        name = data.name or "Unit",
        team = data.team or "player",
        x = data.x,
        y = data.y,
        hp = data.hp or 10,
        maxHp = data.hp or 10,
        move = data.move or 4,
        movePoints = data.move or 4,
        hasActed = false,
        phase = "ready"
    }

    table.insert(Units.list, unit)
    Game.grid[unit.y][unit.x].unit = unit

    return unit
end

function Units.remove(unit)
    Game.grid[unit.y][unit.x].unit = nil

    for i, u in ipairs(Units.list) do
        if u == unit then
            table.remove(Units.list, i)
            break
        end
    end
end

function Units.create(data)
    local unit = {
        id = #Units.list + 1,
        name = data.name or "Unit",
        team = data.team or "player",
        x = data.x,
        y = data.y,
        hp = data.hp or 10,
        maxHp = data.hp or 10,
        move = data.move or 4,      -- maximum move per turn
        movePoints = data.move or 4, -- current remaining move points
        hasActed = false
    }

    table.insert(Units.list, unit)
    Game.grid[unit.y][unit.x].unit = unit

    return unit
end


function Units.getAt(x, y)
    if not Game.grid[y] or not Game.grid[y][x] then return nil end
    return Game.grid[y][x].unit
end
