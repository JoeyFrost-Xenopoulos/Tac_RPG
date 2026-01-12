Walls = {}
Walls.overlayMap = {}

Walls.wallQuads = {}

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
end

function Walls.init()
    for y = 1, GRID_HEIGHT do
        Walls.overlayMap[y] = {}
        for x = 1, GRID_WIDTH do
            Walls.overlayMap[y][x] = nil
        end
    end

local overlayPatch = {
        -- BOTTOM (Base) - Row 5 (The actual bottom row of a 6-row sheet)
        {y=4, x=7, row=5, col=0},
        {y=4, x=8, row=5, col=1},
        {y=4, x=9, row=5, col=2},

        -- MIDDLE - Row 2
        {y=3, x=7, row=2, col=0},
        {y=3, x=8, row=2, col=1},
        {y=3, x=9, row=2, col=2},

        -- MIDDLE/TOP - Row 1
        {y=2, x=7, row=1, col=0},
        {y=2, x=8, row=1, col=1},
        {y=2, x=9, row=1, col=2},

        -- TOP EDGE - Row 0
        {y=1, x=7, row=0, col=0},
        {y=1, x=8, row=0, col=1},
        {y=1, x=9, row=0, col=2},
    }

    for _, t in ipairs(overlayPatch) do
        local index = t.row * 4 + t.col + 1  -- 4 = cols in Tiles.grassQuads
        Walls.overlayMap[t.y][t.x] = Walls.wallQuads[index]
    end
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
