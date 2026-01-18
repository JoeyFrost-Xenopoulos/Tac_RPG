-- modules/ui/bigbar.lua
local BigBar = {}

local BigBar_Base = love.graphics.newImage("assets/ui/bars/BigBar_Base.png")
local barQuads = {}
local bw, bh = BigBar_Base:getDimensions()

barQuads.left  = love.graphics.newQuad(0,   0, 64,  bh, bw, bh)
barQuads.mid   = love.graphics.newQuad(128, 0, 64,  bh, bw, bh)
barQuads.right = love.graphics.newQuad(256, 0, 64,  bh, bw, bh)

function BigBar.draw(x, y, width, anchor)
    if not width or width <= 0 then return end

    local barHeight = 64
    local barY = y + 30

    local barLeftQuad = barQuads.left
    local barMidQuad = barQuads.mid
    local barRightQuad = barQuads.right

    local _, _, lw = barLeftQuad:getViewport()
    local _, _, mw = barMidQuad:getViewport()
    local _, _, rw = barRightQuad:getViewport()

    local barX = x + 110

    if anchor == "right" then
        barX = x - 185
        love.graphics.draw(BigBar_Base, barRightQuad, barX, barY)
        local midX = barX - width
        local scaleX = width / mw
        love.graphics.draw(BigBar_Base, barMidQuad, midX, barY, 0, scaleX, 1)
        local leftX = midX - lw
        love.graphics.draw(BigBar_Base, barLeftQuad, leftX, barY)
    else
        love.graphics.draw(BigBar_Base, barLeftQuad, barX, barY)
        local midX = barX + lw
        local scaleX = width / mw
        love.graphics.draw(BigBar_Base, barMidQuad, midX, barY, 0, scaleX, 1)
        local rightX = midX + mw * scaleX
        love.graphics.draw(BigBar_Base, barRightQuad, rightX, barY)
    end
end

return BigBar
