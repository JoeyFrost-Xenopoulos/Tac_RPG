-- modules/ui/bigbar.lua
local BigBar = {}

local BigBar_Base = love.graphics.newImage("assets/ui/bars/SmallBar_Base.png")
local BigBar_Fill = love.graphics.newImage("assets/ui/bars/SmallBar_Fill.png")
local PixelFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 32)

local barQuads = {}
local bw, bh = BigBar_Base:getDimensions()

barQuads.left  = love.graphics.newQuad(0,   0, 64,  bh, bw, bh)
barQuads.mid   = love.graphics.newQuad(128, 0, 64,  bh, bw, bh)
barQuads.right = love.graphics.newQuad(256, 0, 64,  bh, bw, bh)

function BigBar.drawHealthText(x, y, maxWidth, anchor, hp, maxHp)
    local barY = y + 30
    local text = "HP:" .. hp .. " / " .. maxHp

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(PixelFont)

    local textX
    textX = x + maxWidth + 10

    local textY = barY + 15
    love.graphics.print(text, textX, textY)
end

function BigBar.draw(x, y, width, anchor)
    if not width or width <= 0 then return end

    local barHeight = 64
    local barY = y + 50

    local barLeftQuad = barQuads.left
    local barMidQuad = barQuads.mid
    local barRightQuad = barQuads.right

    local _, _, lw = barLeftQuad:getViewport()
    local _, _, mw = barMidQuad:getViewport()

    local barX = x + 110
    love.graphics.draw(BigBar_Base, barLeftQuad, barX, barY)
    local midX = barX + lw
    local scaleX = width / mw
    love.graphics.draw(BigBar_Base, barMidQuad, midX, barY, 0, scaleX, 1)
    local rightX = midX + mw * scaleX
    love.graphics.draw(BigBar_Base, barRightQuad, rightX, barY)

    local totalWidth = width + 15
    local fillX = barX + 56
    local fillScaleX = totalWidth / BigBar_Fill:getWidth()
    love.graphics.draw(BigBar_Fill, fillX, barY, 0, fillScaleX, 1)
end

return BigBar
