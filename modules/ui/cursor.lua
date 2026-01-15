-- modules/world/cursor.lua
local Cursor = {}
Cursor.color = {1, 1, 0, 0.5}
Cursor.tileX = 1
Cursor.tileY = 1

Cursor.tileSize = 64
Cursor.scaleX = 1
Cursor.scaleY = 1
Cursor.gridWidth = 15
Cursor.gridHeight = 12
Cursor.pulse = 0

function Cursor.load()
    Cursor.image = love.graphics.newImage("assets/ui/cursors/Cursor_04.png")
    Cursor.imageWidth = Cursor.image:getWidth()
end

function Cursor.setGrid(tileSize, gridWidth, gridHeight, scaleX, scaleY)
    Cursor.tileSize = tileSize or Cursor.tileSize
    Cursor.gridWidth = gridWidth or Cursor.gridWidth
    Cursor.gridHeight = gridHeight or Cursor.gridHeight
    Cursor.scaleX = scaleX or 1
    Cursor.scaleY = scaleY or 1
end

function Cursor.update()
    local mx, my = love.mouse.getPosition()
    
    local scaledX = mx / Cursor.scaleX
    local scaledY = my / Cursor.scaleY

    Cursor.tileX = math.floor(scaledX / Cursor.tileSize) + 1
    Cursor.tileY = math.floor(scaledY / Cursor.tileSize) + 1

    Cursor.tileX = math.max(1, math.min(Cursor.tileX, Cursor.gridWidth))
    Cursor.tileY = math.max(1, math.min(Cursor.tileY, Cursor.gridHeight))

    Cursor.pulse = Cursor.pulse + love.timer.getDelta()
end

function Cursor.draw()
    if not Cursor.image then return end

    love.graphics.push()
    love.graphics.scale(Cursor.scaleX, Cursor.scaleY)

    local tilePx = (Cursor.tileX - 1) * Cursor.tileSize
    local tilePy = (Cursor.tileY - 1) * Cursor.tileSize

    local imgW, imgH = Cursor.image:getDimensions()
    local scale = Cursor.tileSize / Cursor.imageWidth

    local pulse = 1 + math.sin(Cursor.pulse * 5) * 0.05
    scale = scale * pulse

    local drawX = tilePx + Cursor.tileSize / 2
    local drawY = tilePy + Cursor.tileSize / 2

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        Cursor.image,
        drawX,
        drawY,
        0,
        scale,
        scale,
        imgW / 2,
        imgH / 2
    )

    love.graphics.pop()
end

return Cursor
