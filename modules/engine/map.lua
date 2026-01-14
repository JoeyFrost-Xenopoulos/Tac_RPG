Map = {}

function Map.generate(mapData)
    Grid.createEmpty()
    Map.generateTerrain()
    Map.assignTerrainQuads()
    Foam.initTiles()
end

function Map.generateTerrain()
    for y = 1, GRID_HEIGHT do
        for x = 1, GRID_WIDTH do
            local weights = { grass = 70, water = 30 }
            if y > 1 then
                weights[Game.grid[y-1][x].terrain] =
                    (weights[Game.grid[y-1][x].terrain] or 0) + 100
            end
            if x > 1 then
                weights[Game.grid[y][x-1].terrain] =
                    (weights[Game.grid[y][x-1].terrain] or 0) + 100
            end
            local terrain = pickWeightedRandom(weights)
            local tile = Game.grid[y][x]
            tile.terrain = terrain
            tile.walkable = Grid.terrainTypes[terrain].walkable
        end
    end
end

function Map.assignTerrainQuads()
    for y = 1, GRID_HEIGHT do
        for x = 1, GRID_WIDTH do
            local tile = Grid.getTile(x, y)
            if tile then
                tile.quad = Tiles.getQuadForPosition(x, y)
            end
        end
    end
end