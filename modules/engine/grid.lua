-- grid.lua
Grid = {}

Grid.terrainTypes = {
    grass = { walkable = true,  color = {0.3, 0.8, 0.3} },
    water = { walkable = false, color = {0.2, 0.4, 0.8} },
}

function pickWeightedRandom(weights)
    local total = 0
    for _, weight in pairs(weights) do total = total + weight end
    local r = math.random() * total

    for terrain, weight in pairs(weights) do
        r = r - weight
        if r <= 0 then return terrain end
    end
    for terrain in pairs(weights) do return terrain end
end


function Grid.getTile(x, y)
    if not Game.grid[y] or not Game.grid[y][x] then return nil end
    return Game.grid[y][x]
end

function Grid.screenToGrid(x, y)
    local gridX = math.floor(x / TILE_SIZE) + 1
    local gridY = math.floor(y / TILE_SIZE) + 1

    if gridX < 1 or gridX > GRID_WIDTH or
       gridY < 1 or gridY > GRID_HEIGHT then
        return nil
    end

    return { x = gridX, y = gridY }
end

function Grid.isWalkable(x, y, fromX, fromY)
    local tile = Grid.getTile(x, y)
    if not tile or not tile.walkable or tile.unit then return false end

    return true
end

function Grid.createEmpty()
    Game.grid = {}
    for y = 1, GRID_HEIGHT do
        Game.grid[y] = {}
        for x = 1, GRID_WIDTH do
            Game.grid[y][x] = {
                terrain = nil,
                walkable = true,
                unit = nil,
                quad = nil
            }
        end
    end
end