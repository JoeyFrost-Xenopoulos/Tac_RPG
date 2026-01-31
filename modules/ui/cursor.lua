-- modules/world/cursor.lua
local Cursor = {}
local Map = require("modules.world.map")
local MovementRange = require("modules.engine.movement_range")
local Menu = require("modules.ui.menu")

Cursor.color = {1, 1, 0, 0.5}
Cursor.tileX = 1
Cursor.tileY = 1

Cursor.tileSize = 64
Cursor.scaleX = 1
Cursor.scaleY = 1
Cursor.gridWidth = 15
Cursor.gridHeight = 12
Cursor.pulse = 0

Cursor.cursors = {}
Cursor.current = nil

function Cursor.load()
    -- Grid cursor
    Cursor.image = love.graphics.newImage("assets/ui/cursors/Cursor_04.png")
    Cursor.imageWidth = Cursor.image:getWidth()

    -- Default cursor
    local img1 = love.image.newImageData("assets/ui/cursors/Cursor_01.png")
    Cursor.cursors.default = love.mouse.newCursor(img1, 0, 0)

    -- Hover cursor
    local img2 = love.image.newImageData("assets/ui/cursors/Cursor_02.png")
    Cursor.cursors.hover = love.mouse.newCursor(img2, 0, 0)

    -- Blocked cursor
    local img3 = love.image.newImageData("assets/ui/cursors/Cursor_03.png")
    Cursor.cursors.blocked = love.mouse.newCursor(img3, 0, 0)
end

function Cursor.setMouse(name)
    if Cursor.current == name then return end
    Cursor.current = name
    love.mouse.setCursor(Cursor.cursors[name])
end

function Cursor.setGrid(tileSize, gridWidth, gridHeight, scaleX, scaleY)
    Cursor.tileSize = tileSize or Cursor.tileSize
    Cursor.gridWidth = gridWidth or Cursor.gridWidth
    Cursor.gridHeight = gridHeight or Cursor.gridHeight
    Cursor.scaleX = scaleX or 1
    Cursor.scaleY = scaleY or 1
end

function Cursor.getTile()
    return Cursor.tileX, Cursor.tileY
end

function Cursor.update()
    local mx, my = love.mouse.getPosition()
    if Menu.isHovered(mx, my) then
        Cursor.setMouse("default")
        return
    end

    local scaledX = mx / Cursor.scaleX
    local scaledY = my / Cursor.scaleY

    Cursor.tileX = math.floor(scaledX / Cursor.tileSize) + 1
    Cursor.tileY = math.floor(scaledY / Cursor.tileSize) + 1

    Cursor.tileX = math.max(1, math.min(Cursor.tileX, Cursor.gridWidth))
    Cursor.tileY = math.max(1, math.min(Cursor.tileY, Cursor.gridHeight))

    Cursor.pulse = Cursor.pulse + love.timer.getDelta()

    local UnitManager = require("modules.units.manager")
    local tx, ty = Cursor.tileX, Cursor.tileY
    local selectedUnit = UnitManager.selectedUnit

    if selectedUnit then
        if (tx == selectedUnit.tileX and ty == selectedUnit.tileY)
        or MovementRange.canReach(tx, ty) then
            Cursor.setMouse("hover")
        else
            Cursor.setMouse("blocked")
        end
    else
        Cursor.setMouse("default")
    end
end

function Cursor.draw()
    if not Cursor.image then return end
    local mx, my = love.mouse.getPosition()
    if Menu.isHovered(mx, my) then return end

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
    love.graphics.draw(Cursor.image, drawX, drawY, 0, scale, scale, imgW / 2, imgH / 2)

    love.graphics.pop()
end

return Cursor
