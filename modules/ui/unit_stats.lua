-- modules/ui/unit_stats.lua
local UnitStats = {}

UnitStats.visible = false
UnitStats.font = nil
UnitStats.background = nil
UnitStats.units = {}
UnitStats.index = 1
UnitStats.smallFont = nil

function UnitStats.load()
    UnitStats.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 36)
    UnitStats.smallFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 28)
    UnitStats.background = love.graphics.newImage("assets/ui/menu/stats_menu.png")
end

function UnitStats.show()
    local UnitManager = require("modules.units.manager")
    UnitStats.units = {}
    for _, unit in ipairs(UnitManager.units or {}) do
        if unit.isPlayer then
            table.insert(UnitStats.units, unit)
        end
    end
    UnitStats.index = 1
    UnitStats.visible = true
end

function UnitStats.hide()
    UnitStats.visible = false
end

function UnitStats.nextUnit()
    if #UnitStats.units == 0 then return end
    UnitStats.index = UnitStats.index + 1
    if UnitStats.index > #UnitStats.units then
        UnitStats.index = 1
    end
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

    local unit = UnitStats.units[UnitStats.index]
    if unit then
        local panelW = math.min(420, math.floor(screenW * 0.35))
        local panelX = screenW - panelW - 60
        local panelY = 80
        local padding = 20

        if unit.avatar then
            local maxPortrait = 160
            local scale = math.min(maxPortrait / unit.avatar:getWidth(), maxPortrait / unit.avatar:getHeight())
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(unit.avatar, panelX + padding, panelY + padding, 0, scale, scale)
        end

        local nameY = panelY + padding + 170
        if UnitStats.font then
            love.graphics.setFont(UnitStats.font)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(unit.type or "Unknown", panelX + padding, nameY)
            love.graphics.print(unit.name or "Unknown", panelX + padding, nameY + 36)
        end

        local statsX = panelX + padding
        local statsY = nameY + 90
        if UnitStats.smallFont then
            love.graphics.setFont(UnitStats.smallFont)
            local stats = {
                { label = "HP", value = string.format("%d/%d", unit.health or 0, unit.maxHealth or 0) },
                { label = "Atk", value = tostring(unit.attackDamage or 0) },
                { label = "Range", value = tostring(unit.attackRange or 0) },
                { label = "Move", value = tostring(unit.maxMoveRange or 0) }
            }
            for i, stat in ipairs(stats) do
                local lineY = statsY + (i - 1) * 28
                love.graphics.print(stat.label .. ":", statsX, lineY)
                love.graphics.print(stat.value, statsX + 120, lineY)
            end
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return UnitStats
