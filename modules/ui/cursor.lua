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
end

function Cursor.draw()
    love.graphics.push()
    love.graphics.scale(Cursor.scaleX, Cursor.scaleY)

    love.graphics.setColor(Cursor.color)
    love.graphics.rectangle("fill", 
        (Cursor.tileX-1)*Cursor.tileSize, 
        (Cursor.tileY-1)*Cursor.tileSize, 
        Cursor.tileSize, 
        Cursor.tileSize
    )
    
    love.graphics.setColor(1,1,1,1)
    love.graphics.pop()
end

return Cursor
