-- modules/units.lua
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
        pixelX = (data.x - 1) * TILE_SIZE,
        pixelY = (data.y - 1) * TILE_SIZE,
        
        path = nil,
        isMoving = false,

        attackRange = data.attackRange or 1,
        damage = data.damage or Combat.BASE_DAMAGE,
        hp = data.hp or 10,
        maxHp = data.hp or 10,
        move = data.move or 4,
        movePoints = data.move or 4,
        hasActed = false
    }

    table.insert(Units.list, unit)
    
    if Game.grid[unit.y] and Game.grid[unit.y][unit.x] then
        Game.grid[unit.y][unit.x].unit = unit
    end

    return unit
end

function Units.remove(unit)
    if Game.grid[unit.y] and Game.grid[unit.y][unit.x] then
        Game.grid[unit.y][unit.x].unit = nil
    end

    for i, u in ipairs(Units.list) do
        if u == unit then
            table.remove(Units.list, i)
            break
        end
    end
end

function Units.update(dt)
    for _, unit in ipairs(Units.list) do
        -- Handle Movement Animation
        if unit.isMoving and unit.path then
            local targetStep = unit.path[1]
            
            if targetStep then
                local targetPixelX = (targetStep.x - 1) * TILE_SIZE
                local targetPixelY = (targetStep.y - 1) * TILE_SIZE

                if unit.pixelX < targetPixelX then
                    unit.pixelX = math.min(unit.pixelX + MOVE_SPEED * dt, targetPixelX)
                elseif unit.pixelX > targetPixelX then
                    unit.pixelX = math.max(unit.pixelX - MOVE_SPEED * dt, targetPixelX)
                end

                if unit.pixelY < targetPixelY then
                    unit.pixelY = math.min(unit.pixelY + MOVE_SPEED * dt, targetPixelY)
                elseif unit.pixelY > targetPixelY then
                    unit.pixelY = math.max(unit.pixelY - MOVE_SPEED * dt, targetPixelY)
                end

                if unit.pixelX == targetPixelX and unit.pixelY == targetPixelY then
                    Game.grid[unit.y][unit.x].unit = nil -- leave old tile
                    
                    unit.x = targetStep.x
                    unit.y = targetStep.y
                    
                    Game.grid[unit.y][unit.x].unit = unit -- enter new tile
                    
                    table.remove(unit.path, 1)
                    unit.movePoints = unit.movePoints - 1
                end
            else
                unit.isMoving = false
                unit.path = nil
            end

            if #unit.path == 0 then
        unit.isMoving = false
        unit.path = nil
        
        if unit.team == "player" and Game.selectedUnit == unit then
            if unit.movePoints > 0 then
                Game.movementTiles = Movement.getReachableTiles(unit)
            else
                Game.movementTiles = nil
            end
            Game.attackTiles = Combat.getAttackableTiles(unit)            
            Input.checkUnitTurn(unit) 
        end
    end
        end
    end
end

function Units.getAt(x, y)
    if not Game.grid[y] or not Game.grid[y][x] then return nil end
    return Game.grid[y][x].unit
end