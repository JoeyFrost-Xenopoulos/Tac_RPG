Tiles = {}

Tiles.grassSheet = nil
Tiles.grassQuads = {}  -- store 3x3 quads

function Tiles.load()
    Tiles.grassSheet = love.graphics.newImage("map/Tilemap_color1.png")

    local tileW, tileH = 64, 64
    local cols, rows = 4, 4

    for y = 0, rows - 1 do
        for x = 0, cols - 1 do
            table.insert(Tiles.grassQuads,
                love.graphics.newQuad(
                    x * tileW, y * tileH, tileW, tileH,
                    Tiles.grassSheet:getDimensions()
                )
            )
        end
    end
end

function Tiles.getGrassQuadForPosition(x, y)
    local topTile    = Grid.getTile(x, y - 1)
    local bottomTile = Grid.getTile(x, y + 1)
    local leftTile   = Grid.getTile(x - 1, y)
    local rightTile  = Grid.getTile(x + 1, y)

    local hasTop    = topTile and topTile.terrain == "grass"
    local hasBottom = bottomTile and bottomTile.terrain == "grass"
    local hasLeft   = leftTile and leftTile.terrain == "grass"
    local hasRight  = rightTile and rightTile.terrain == "grass"

    -- Determine Column (Horizontal Edges)
    local col = 2

    if not hasTop and not hasBottom and not hasLeft and not hasRight then
        return Tiles.grassQuads[(4 - 1) * 4 + 4] -- row = 4, col = 4
    end

    if not hasTop and not hasLeft and not hasRight then
        return Tiles.grassQuads[(1 - 1) * 4 + 4] -- row = 1, col = 4
    end

    if not hasBottom and not hasLeft and not hasRight then
        return Tiles.grassQuads[(3 - 1) * 4 + 4] -- row=3, col=4
    end

    if not hasLeft and not hasTop and not hasBottom then
        return Tiles.grassQuads[(4 - 1) * 4 + 1] -- row=4, col=1
    end

    if not hasRight and not hasTop and not hasBottom then
        return Tiles.grassQuads[(4 - 1) * 4 + 3] -- row=4, col=3
    end

    if not hasTop and not hasBottom then
        return Tiles.grassQuads[(4 - 1) * 4 + 2] -- row=4, col=2
    end

    if not hasLeft and not hasRight then
        return Tiles.grassQuads[(2 - 1) * 4 + 4] -- row=2, col=4
    end

    if not hasLeft then col = 1 -- Left Edge
    elseif not hasRight then col = 3 end -- Right Edge

    local row = 2
    if not hasTop then row = 1  -- Top Edge
    elseif not hasBottom then row = 3 end -- Bottom Edge
    local index = (row - 1) * 4 + col
    return Tiles.grassQuads[index]
end