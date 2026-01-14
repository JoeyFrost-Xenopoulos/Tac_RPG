-- tiles.lua
Tiles = {}

Tiles.grassSheet = nil
Tiles.grassQuads = {}

Tiles.quadLogic = {}
Tiles.tileW, Tiles.tileH = 64, 64

function Tiles.load()
    local colorIndex = love.math.random(1,2,3,4,5)
    Tiles.grassSheet = love.graphics.newImage(
        "map/Tilemap_color" .. colorIndex .. ".png"
    )

    Tiles.grassQuads = {}
    for y = 0, 3 do
        for x = 0, 3 do
            table.insert(Tiles.grassQuads,
                love.graphics.newQuad(
                    x * Tiles.tileW, y * Tiles.tileH,
                    Tiles.tileW, Tiles.tileH,
                    Tiles.grassSheet:getDimensions()
                )
            )
        end
    end

    Tiles.quadLogic["grass"] = function(x, y)
        return Tiles.getGrassQuadForPosition(x, y)
    end
end

local function getAutoTileQuad(x, y, terrainType, quadSet)
    local function isSame(nx, ny)
        local t = Grid.getTile(nx, ny)
        return t and t.terrain == terrainType
    end

    local hasTop    = isSame(x, y - 1)
    local hasBottom = isSame(x, y + 1)
    local hasLeft   = isSame(x - 1, y)
    local hasRight  = isSame(x + 1, y)

    local col = 2
    local row = 2

    if not hasTop and not hasBottom and not hasLeft and not hasRight then
        return quadSet[(4 - 1) * 4 + 4]
    end
    if not hasTop and not hasLeft and not hasRight then
        return quadSet[(1 - 1) * 4 + 4]
    end
    if not hasBottom and not hasLeft and not hasRight then
        return quadSet[(3 - 1) * 4 + 4]
    end
    if not hasLeft and not hasTop and not hasBottom then
        return quadSet[(4 - 1) * 4 + 1]
    end
    if not hasRight and not hasTop and not hasBottom then
        return quadSet[(4 - 1) * 4 + 3]
    end
    if not hasTop and not hasBottom then
        return quadSet[(4 - 1) * 4 + 2]
    end
    if not hasLeft and not hasRight then
        return quadSet[(2 - 1) * 4 + 4]
    end

    if not hasLeft then col = 1
    elseif not hasRight then col = 3 end

    if not hasTop then row = 1
    elseif not hasBottom then row = 3 end

    return quadSet[(row - 1) * 4 + col]
end

function Tiles.getGrassQuadForPosition(x, y)
    return getAutoTileQuad(x, y, "grass", Tiles.grassQuads)
end

function Tiles.getQuadForPosition(x, y)
    local tile = Grid.getTile(x, y)
    if not tile then return nil end

    local logicFunc = Tiles.quadLogic[tile.terrain]
    if logicFunc then
        return logicFunc(x, y)
    else
        return nil
    end
end
