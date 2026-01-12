Walls = {}
Walls.overlayMap = {}
Walls.wallQuads = {}
Walls.extraQuads = {}

function Walls.load()
    local sheet = Tiles.grassSheet
    local tileW, tileH = 64, 64
    
    local startCol = 5 
    local wallCols = 4 
    local wallRows = 6
    

    for y = 0, wallRows - 1 do
        for x = 0, wallCols - 1 do
            local pixelX = (startCol + x) * tileW
            local pixelY = y * tileH
            
            table.insert(Walls.wallQuads,
                love.graphics.newQuad(
                    pixelX, pixelY, tileW, tileH,
                    sheet:getDimensions()
                )
            )
        end
    end

    local sheet = Tiles.grassSheet
    local tileW, tileH = 64, 64

    local extraTiles = {
        {col = 0, row = 4},
        {col = 0, row = 5},
        {col = 3, row = 5},
        {col = 3, row = 6},
    }

    for _, t in ipairs(extraTiles) do
        local pixelX = t.col * tileW
        local pixelY = t.row * tileH

        table.insert(Walls.extraQuads,
            love.graphics.newQuad(
                pixelX, pixelY, tileW, tileH,
                sheet:getDimensions()
            )
        )
    end
end

function Walls.init()
    for y = 1, GRID_HEIGHT do
        Walls.overlayMap[y] = {}
        for x = 1, GRID_WIDTH do
            Walls.overlayMap[y][x] = nil
        end
    end

    local blockingTiles = {{y=2, x=7}, {y=4, x=8},{y=4, x=9}}

    local overlayPatch = {
        -- Bottom row
        {y=4, x=7, row=4, col=0},
        {y=4, x=8, row=4, col=1},
        {y=4, x=9, row=4, col=2},

        -- Middle row
        {y=3, x=7, row=2, col=0},
        {y=3, x=8, row=2, col=1},
        {y=3, x=9, row=2, col=2, blockedEdges = {right = true}},

        -- Upper middle
        {y=2, x=7, row=4, col=0},
        {y=2, x=8, row=1, col=0},
        {y=2, x=9, row=1, col=2, blockedEdges = {right = true}},

        -- Top row
        {y=1, x=7, row=3, col=0, blockedEdges = {left = true}}, 
        {y=1, x=8, row=0, col=1},
        {y=1, x=9, row=0, col=2, blockedEdges = {right = true}}
    }

    local wallCols = 4

    for _, t in ipairs(overlayPatch) do
        local index = t.row * wallCols + t.col + 1

        local blocks = false
        for _, b in ipairs(blockingTiles) do
            if b.x == t.x and b.y == t.y then
                blocks = true
                break
            end
        end

        Walls.overlayMap[t.y][t.x] = {
            quad = Walls.wallQuads[index],
            blocksMovement = blocks,
            isRamp = false,
            -- Store the blocked edges here dynamically
            blockedEdges = t.blockedEdges or {} 
        }

        Game.grid[t.y][t.x].walkable = not blocks
    end

    -- (Ramp overrides remain the same...)
    Walls.overlayMap[4][7].quad = Walls.extraQuads[2]
    Walls.overlayMap[4][7].isRamp = true
    Walls.overlayMap[3][7].quad = Walls.extraQuads[1]
    Walls.overlayMap[3][7].isRamp = true
end

function Walls.draw()
    local scale = TILE_SIZE / 64

    for y = 1, GRID_HEIGHT do
        for x = 1, GRID_WIDTH do
            local cell = Walls.overlayMap[y][x]
            if cell then
                local px = (x - 1) * TILE_SIZE
                local py = (y - 1) * TILE_SIZE
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(
                    Tiles.grassSheet,
                    cell.quad,
                    px, py, 0,
                    scale, scale
                )
            end
        end
    end
end