-- draw.lua

Draw = {}

local function isAdjacentToEnemy(tile, unitTeam)
    local directions = {
        {x = 1, y = 0}, {x = -1, y = 0},
        {x = 0, y = 1}, {x = 0, y = -1}
    }

    for _, d in ipairs(directions) do
        local neighborX = tile.x + d.x
        local neighborY = tile.y + d.y
        local neighborTile = Grid.getTile(neighborX, neighborY)
        if neighborTile and neighborTile.unit and neighborTile.unit.team ~= unitTeam then
            return true
        end
    end

    return false
end

function Draw.grid()
    for y = 1, GRID_HEIGHT do
        for x = 1, GRID_WIDTH do
            local tile = Grid.getTile(x, y)
            if tile and tile.quad then
                local px = (x - 1) * TILE_SIZE
                local py = (y - 1) * TILE_SIZE

                local sheet
                if tile.terrain == "grass" then
                    sheet = Tiles.grassSheet
                elseif tile.terrain == "high" then
                    sheet = Tiles.highSheet
                else
                    sheet = Tiles.grassSheet
                end

                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(
                    sheet,
                    tile.quad,
                    px, py,
                    0,
                    TILE_SIZE / Tiles.tileW,
                    TILE_SIZE / Tiles.tileH
                )
            end
        end
    end
end


function Draw.units()
    for _, unit in ipairs(Units.list) do
        local x = (unit.x - 1) * TILE_SIZE
        local y = (unit.y - 1) * TILE_SIZE

        local teamColor = (unit.team == "enemy") and {1, 0, 0} or {0, 0, 1}

        local classColor, classSymbol
        if unit.class == "Soldier" then
            classColor, classSymbol = {0.2, 0.8, 0.2}, "S"
        elseif unit.class == "Archer" then
            classColor, classSymbol = {0.8, 0.8, 0.2}, "A"
        elseif unit.class == "Mage" then
            classColor, classSymbol = {0.6, 0.2, 0.8}, "M"
        else
            classColor, classSymbol = {1, 1, 1}, "?"
        end

        if unit.hasActed and unit.team == "player" then
            classColor = {0.2, 0.2, 0.2}
        end

        local shrink = 0.1 * TILE_SIZE
        local rectSize = TILE_SIZE - shrink * 2

        if not unit.animations then
            love.graphics.setColor(classColor)
            love.graphics.rectangle("fill", x + shrink, y + shrink, rectSize, rectSize)

            love.graphics.setLineWidth(4)
            love.graphics.setColor(teamColor)
            love.graphics.rectangle("line", x + shrink, y + shrink, rectSize, rectSize)
        end

        if Game.selectedUnit == unit and not unit.isMoving then
            love.graphics.setLineWidth(4)
            love.graphics.setColor(1, 1, 0)
            love.graphics.rectangle("line", x + shrink, y + shrink, rectSize, rectSize)
        end

        if not unit.animations then
            love.graphics.setColor(teamColor)
            love.graphics.print(classSymbol, x + TILE_SIZE / 2 - 4, y + TILE_SIZE / 2 - 8)
        end

        love.graphics.setLineWidth(1)
    end
end

function Draw.heals()
    local unit = Game.selectedUnit
    if not unit or not Game.healTiles or unit.isMoving then
        return
    end

    local speed = 2
    local shimmerWidth = 0.4

    for _, tile in ipairs(Game.healTiles) do
        local x = (tile.x - 1) * TILE_SIZE
        local y = (tile.y - 1) * TILE_SIZE

        local diagonalPos = (tile.x + tile.y) / (GRID_WIDTH + GRID_HEIGHT)
        local wave = math.sin((Game.flashTimer * speed) + diagonalPos * math.pi * 2)
        local brightness = 0.8 + 0.2 * wave

        local r = math.min(0.2 * brightness, 1)
        local g = math.min(1 * brightness, 1)
        local b = math.min(0.4 * brightness, 1)

        love.graphics.setColor(r, g, b, 0.5)
        love.graphics.rectangle("fill", x, y, TILE_SIZE, TILE_SIZE)
    end
end

function Draw.hover()
    if not Game.hoveredTile then return end

    local x = (Game.hoveredTile.x - 1) * TILE_SIZE
    local y = (Game.hoveredTile.y - 1) * TILE_SIZE

    love.graphics.setColor(0.8, 0.8, 0.3, 0.8)
    love.graphics.rectangle("fill", x, y, TILE_SIZE, TILE_SIZE)
end

function Draw.selection()
    if not Game.selectedTile then return end

    local x = (Game.selectedTile.x - 1) * TILE_SIZE
    local y = (Game.selectedTile.y - 1) * TILE_SIZE

    love.graphics.setColor(0.2, 0.8, 0.2, 0.6)
    love.graphics.rectangle("fill", x, y, TILE_SIZE, TILE_SIZE)
end

function Draw.movementAndAttacks()
    local unit = Game.selectedUnit
    if not unit or not Game.movementTiles then return end

    local movementTiles = Game.movementTiles
    local attackRange = unit.attackRange or 1
    local minRange = (unit.class == "Archer") and 2 or 1

    local speed = 2

    if not unit.isMoving then
        local predictiveTiles = {}

        for _, mTile in ipairs(movementTiles) do
            for dy = -attackRange, attackRange do
                for dx = -attackRange, attackRange do
                    local dist = math.abs(dx) + math.abs(dy)
                    if dist >= minRange and dist <= attackRange then
                        local tx = mTile.x + dx
                        local ty = mTile.y + dy

                        local tile = Grid.getTile(tx, ty)
                        if tile then
                            local key = tx .. "," .. ty
                            predictiveTiles[key] = true
                        end
                    end
                end
            end
        end

        for key, _ in pairs(predictiveTiles) do
            local coords = {}
            for n in string.gmatch(key, "[^,]+") do
                table.insert(coords, tonumber(n))
            end
            local x = (coords[1] - 1) * TILE_SIZE
            local y = (coords[2] - 1) * TILE_SIZE
            local targetUnit = Units.getAt(coords[1], coords[2])
            if not targetUnit or targetUnit.team ~= unit.team then
                love.graphics.setColor(1, 0.2, 0.2, 0.5)
                love.graphics.rectangle("fill", x, y, TILE_SIZE, TILE_SIZE)
            end
        end
    end
    for _, tile in ipairs(movementTiles) do
        local x = (tile.x - 1) * TILE_SIZE
        local y = (tile.y - 1) * TILE_SIZE

        local diagonalPos = (tile.x + tile.y) / (GRID_WIDTH + GRID_HEIGHT)
        local wave = math.sin((Game.flashTimer * speed) + diagonalPos * math.pi * 2)
        local brightness = 0.8 + 0.2 * wave

        local r, g, b = 0.2 * brightness, 0.8 * brightness, 1 * brightness
        love.graphics.setColor(r, g, b, 0.8)
        love.graphics.rectangle("fill", x, y, TILE_SIZE, TILE_SIZE)
    end
end