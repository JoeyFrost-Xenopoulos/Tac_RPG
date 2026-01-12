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

    local overlayPatch = {
        -- Bottom row
        {y=4, x=7, row=4, col=0},
        {y=4, x=8, row=4, col=1},
        {y=4, x=9, row=4, col=2},

        -- Middle row
        {y=3, x=7, row=2, col=0},
        {y=3, x=8, row=2, col=1},
        {y=3, x=9, row=2, col=2},

        -- Upper middle
        {y=2, x=7, row=4, col=0},
        {y=2, x=8, row=1, col=0},
        {y=2, x=9, row=1, col=2},

        -- Top row
        {y=1, x=7, row=3, col=0},
        {y=1, x=8, row=0, col=1},
        {y=1, x=9, row=0, col=2}
    }

    local zoneTop, zoneBottom = 1, 5
    local zoneLeft, zoneRight = 7, 9

    for _, t in ipairs(overlayPatch) do
        if t.y >= zoneTop and t.y <= zoneBottom and
           t.x >= zoneLeft and t.x <= zoneRight then

            local index = t.row * 4 + t.col + 1
            Walls.overlayMap[t.y][t.x] = Walls.wallQuads[index]
        end
    end

    Walls.overlayMap[4][7] = Walls.extraQuads[2] -- bottom ramp
    Walls.overlayMap[3][7] = Walls.extraQuads[1] -- top ramp

end

function Walls.draw()
    local scale = TILE_SIZE / 64
    for y = 1, GRID_HEIGHT do
        for x = 1, GRID_WIDTH do
            local quad = Walls.overlayMap[y][x]
            if quad then
                local px = (x - 1) * TILE_SIZE
                local py = (y - 1) * TILE_SIZE
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(Tiles.grassSheet, quad, px, py, 0, scale, scale)
            end
        end
    end
end
