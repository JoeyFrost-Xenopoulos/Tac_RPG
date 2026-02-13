-- modules/ui/unit_stats.lua
local UnitStats = {}

UnitStats.visible = false
UnitStats.font = nil
UnitStats.background = nil

function UnitStats.load()
    UnitStats.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 36)
    UnitStats.background = love.graphics.newImage("assets/ui/menu/stats_menu.png")
end

function UnitStats.show()
    UnitStats.visible = true
end

function UnitStats.hide()
    UnitStats.visible = false
end

function UnitStats.update(dt)
end

function UnitStats.draw()
    if not UnitStats.visible then return end

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    if UnitStats.background then
        local imgW, imgH = UnitStats.background:getDimensions()
        local scaleX = screenW / imgW
        local scaleY = screenH / imgH
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(UnitStats.background, 0, 0, 0, scaleX, scaleY)
    else
        love.graphics.setColor(0.1, 0.2, 0.8, 1)
        love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    end

    if UnitStats.font then
        love.graphics.setFont(UnitStats.font)
        love.graphics.setColor(1, 1, 1, 1)
        local text = "Backspace to go back"
        local textW = UnitStats.font:getWidth(text)
        local textH = UnitStats.font:getHeight()
        love.graphics.print(text, (screenW - textW) / 2, screenH - textH - 40)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return UnitStats
