-- grid.lua

Grid = {}

Grid.terrainTypes = {
    grass = { walkable = true, color = {0.3, 0.8, 0.3} },
    river = { walkable = false, color = {0.3, 0.4, 0.9} },
    forest = { walkable = true, color = {0.1, 0.6, 0.1} },
    mountain = { walkable = false, color = {0.25, 0.25, 0.25} }
}

-- Grid.lua
function Grid.init()
    Game.grid = {}

    for y = 1, GRID_HEIGHT do
        Game.grid[y] = {}
        for x = 1, GRID_WIDTH do
            local terrainWeights = {
                grass = 70, forest = 20, river = 15, mountain = 15
            }

            local neighbors = {}
            if y > 1 then table.insert(neighbors, Game.grid[y-1][x].terrain) end
            if x > 1 then table.insert(neighbors, Game.grid[y][x-1].terrain) end

            for _, t in ipairs(neighbors) do
                terrainWeights[t] = terrainWeights[t] + 100
            end

            local terrain = pickWeightedRandom(terrainWeights)

            Game.grid[y][x] = {
                terrain = terrain,
                walkable = Grid.terrainTypes[terrain].walkable,
                unit = nil,
                quad = nil 
            }
        end
    end

    for y = 1, GRID_HEIGHT do
        for x = 1, GRID_WIDTH do
            local tile = Game.grid[y][x]
            if tile.terrain == "grass" then
                tile.quad = Tiles.getGrassQuadForPosition(x, y)
            end
        end
    end
end


function pickWeightedRandom(weights)
    local total = 0
    for _, weight in pairs(weights) do total = total + weight end
    local r = math.random() * total

    for terrain, weight in pairs(weights) do
        r = r - weight
        if r <= 0 then return terrain end
    end

    -- fallback
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

function Grid.isWalkable(x, y)
    local tile = Grid.getTile(x, y)
    if not tile then return false end
    return tile.walkable and tile.unit == nil
end
