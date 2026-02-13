-- modules/ui/turn_counter.lua
local TurnCounter = {}

TurnCounter.turnNumber = 1
TurnCounter.width = 160
TurnCounter.height = 80
TurnCounter.padding = 35

function TurnCounter.load()
    TurnCounter.image = love.graphics.newImage("assets/ui/menu/menu.png")
    local imgW, imgH = TurnCounter.image:getDimensions()

    -- Use the same 9-slice quads as the menu
    TurnCounter.quads = {
        topLeft   = love.graphics.newQuad(0,   0,   105, 105, imgW, imgH),
        topMid    = love.graphics.newQuad(128, 0,   64, 64, imgW, imgH),
        topRight  = love.graphics.newQuad(256, 0,   64, 64, imgW, imgH),
        midLeft   = love.graphics.newQuad(0,   128, 105, 105, imgW, imgH),
        midMid    = love.graphics.newQuad(128, 128, 64, 64, imgW, imgH),
        midRight  = love.graphics.newQuad(256, 128, 64, 64, imgW, imgH),
        botLeft   = love.graphics.newQuad(0,   256, 105, 105, imgW, imgH),
        botMid    = love.graphics.newQuad(128, 256, 64, 64, imgW, imgH),
        botRight  = love.graphics.newQuad(256, 256, 64, 64, imgW, imgH)
    }

    TurnCounter.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 36)
    TurnCounter.labelFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 30)
end

function TurnCounter.incrementTurn()
    TurnCounter.turnNumber = TurnCounter.turnNumber + 1
end

function TurnCounter.reset()
    TurnCounter.turnNumber = 1
end

function TurnCounter.getTurnNumber()
    return TurnCounter.turnNumber
end

function TurnCounter.draw()
    local Menu = require("modules.ui.menu")
    local WeaponSelect = require("modules.ui.weapon_selector")
    local UnitStats = require("modules.ui.unit_stats")
    
    -- Hide turn counter if menu is visible
    if Menu.visible or WeaponSelect.visible or UnitStats.visible then
        return
    end
    
    local mx, my = love.mouse.getPosition()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- Always draw on the right side
    local x = screenWidth - TurnCounter.width - TurnCounter.padding
    
    -- Determine vertical position based on mouse location
    local y
    if mx < screenWidth / 2 then
        -- Mouse on left side, always draw at top
        y = TurnCounter.padding
    else
        -- Mouse on right side, check vertical position
        if my > screenHeight / 2 then
            -- Mouse in bottom half, draw at top
            y = TurnCounter.padding
        else
            -- Mouse in top half, draw at bottom
            y = screenHeight - TurnCounter.height - TurnCounter.padding
        end
    end
    
    local q = TurnCounter.quads
        love.graphics.setColor(1, 1, 1, 0.85)
    
    -- Top row
    love.graphics.draw(TurnCounter.image, q.topLeft,  x, y, 0, 0.5, 0.5)
    love.graphics.draw(TurnCounter.image, q.topMid,   x + 32, y, 0, (TurnCounter.width - 64) / 64, 0.5)
    love.graphics.draw(TurnCounter.image, q.topRight, x + TurnCounter.width - 32, y, 0, 0.5, 0.5)
    
    -- Middle row
    love.graphics.draw(TurnCounter.image, q.midLeft,  x, y + 32, 0, 0.5, (TurnCounter.height - 64) / 64)
    love.graphics.draw(TurnCounter.image, q.midMid,   x + 32, y + 32, 0, (TurnCounter.width - 64) / 64, (TurnCounter.height - 64) / 64)
    love.graphics.draw(TurnCounter.image, q.midRight, x + TurnCounter.width - 32, y + 32, 0, 0.5, (TurnCounter.height - 64) / 64)
    
    -- Bottom row
    love.graphics.draw(TurnCounter.image, q.botLeft,  x, y + TurnCounter.height - 32, 0, 0.5, 0.5)
    love.graphics.draw(TurnCounter.image, q.botMid,   x + 32, y + TurnCounter.height - 32, 0, (TurnCounter.width - 64) / 64, 0.5)
    love.graphics.draw(TurnCounter.image, q.botRight, x + TurnCounter.width - 32, y + TurnCounter.height - 32, 0, 0.5, 0.5)
    
    -- Draw the text
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(TurnCounter.font)
    
    -- Draw "Turn X"
    local text = "Turn " .. tostring(TurnCounter.turnNumber)
    local textWidth = TurnCounter.font:getWidth(text)
    love.graphics.print(text, x + (TurnCounter.width - textWidth) / 2, y + (TurnCounter.height - TurnCounter.font:getHeight()) / 2 + 3)
    
    love.graphics.setColor(1, 1, 1, 1)
end

return TurnCounter
