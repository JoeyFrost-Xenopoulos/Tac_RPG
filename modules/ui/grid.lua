-- modules.ui.grid.lua

local Grid = {}

Grid.tileSize = 64
Grid.width = 15
Grid.height = 15
Grid.scaleX = 1
Grid.scaleY = 1

Grid.highlights = {}

function Grid.setSize(width, height, tileSize)
    Grid.width = width or Grid.width
    Grid.height = height or Grid.height
    Grid.tileSize = tileSize or Grid.tileSize
end

function Grid.setScale(sx, sy)
    Grid.scaleX = sx or 1
    Grid.scaleY = sy or 1
end

function Grid.highlightTile(x, y, color)
    color = color or {1,0,0,0.5}
    table.insert(Grid.highlights, {x=x, y=y, color=color})
end

function Grid.clearHighlights()
    Grid.highlights = {}
end

function Grid.draw()
    love.graphics.push()
    love.graphics.scale(Grid.scaleX, Grid.scaleY)

    local w = Grid.width * Grid.tileSize
    local h = Grid.height * Grid.tileSize

    for _, tile in ipairs(Grid.highlights) do
        local col = tile.x - 1
        local row = tile.y - 1
        local c = tile.color
        love.graphics.setColor(c[1], c[2], c[3], c[4])
        love.graphics.rectangle("fill", col*Grid.tileSize, row*Grid.tileSize, Grid.tileSize, Grid.tileSize)
    end

    love.graphics.setColor(1,1,1,1)
    love.graphics.pop()
end

function Grid.drawLines()
    love.graphics.push()
    love.graphics.scale(Grid.scaleX, Grid.scaleY)

    local w = Grid.width * Grid.tileSize
    local h = Grid.height * Grid.tileSize

    love.graphics.setColor(1, 1, 1, 0.3)
    for i = 0, Grid.width do
        love.graphics.line(i*Grid.tileSize, 0, i*Grid.tileSize, h)
    end
    for j = 0, Grid.height do
        love.graphics.line(0, j*Grid.tileSize, w, j*Grid.tileSize)
    end
    love.graphics.setColor(1,1,1,1)
    love.graphics.pop()
end

function mouseToTile(mx, my)
    return
    math.floor(mx / Grid.tileSize) + 1,
    math.floor(my / Grid.tileSize) + 1
end

return Grid
