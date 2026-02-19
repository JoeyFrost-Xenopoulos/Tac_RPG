-- modules.ui.grid.lua

local Grid = {}

Grid.tileSize = 64
Grid.width = 15
Grid.height = 15
Grid.scaleX = 1
Grid.scaleY = 1
Grid.waveSpeed = 10
Grid.waveWidth = 2.2
Grid.waveIntensity = 0.45
Grid.highlightInset = 2

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
    -- Don't draw highlights if item selector or weapon selector is visible
    local ItemSelector = require("modules.ui.item_selector")
    local WeaponSelector = require("modules.ui.weapon_selector")
    if ItemSelector.isVisible() or WeaponSelector.isVisible() then
        return
    end
    
    love.graphics.push()
    love.graphics.scale(Grid.scaleX, Grid.scaleY)

    local w = Grid.width * Grid.tileSize
    local h = Grid.height * Grid.tileSize
    local time = love.timer.getTime()
    local diagonalCount = Grid.width + Grid.height
    local waveTravel = diagonalCount + Grid.waveWidth * 2
    local wavePosition = (time * Grid.waveSpeed) % waveTravel - Grid.waveWidth

    for _, tile in ipairs(Grid.highlights) do
        local col = tile.x - 1
        local row = tile.y - 1
        local drawX = col * Grid.tileSize + Grid.highlightInset
        local drawY = row * Grid.tileSize + Grid.highlightInset
        local drawSize = math.max(1, Grid.tileSize - Grid.highlightInset * 2)
        local c = tile.color
        local baseA = c[4] or 0.5
        love.graphics.setColor(c[1], c[2], c[3], baseA)
        love.graphics.rectangle("fill", drawX, drawY, drawSize, drawSize)

        local diagonal = col + row
        local distanceFromWave = math.abs(diagonal - wavePosition)
        if distanceFromWave < Grid.waveWidth then
            local waveFactor = 1 - (distanceFromWave / Grid.waveWidth)
            local lightAlpha = waveFactor * Grid.waveIntensity * baseA
            love.graphics.setColor(1, 1, 1, lightAlpha)
            love.graphics.rectangle("fill", drawX, drawY, drawSize, drawSize)
        end
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
