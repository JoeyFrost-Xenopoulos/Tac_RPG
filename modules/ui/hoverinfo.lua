HoverInfo = {}

-- Configuration
HoverInfo.width = 200
HoverInfo.height = 60
HoverInfo.padding = 10
HoverInfo.offsetX = 10
HoverInfo.offsetY = 10
HoverInfo.barWidth = 120
HoverInfo.barHeight = 12

-- Draw the hover info panel
function HoverInfo.draw()
    local unit = Game.hoveredTile and Units.getAt(Game.hoveredTile.x, Game.hoveredTile.y)
    if not unit then return end

    local x = HoverInfo.offsetX
    local y = HoverInfo.offsetY

    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", x, y, HoverInfo.width, HoverInfo.height, 5, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, HoverInfo.width, HoverInfo.height, 5, 5)
    love.graphics.setColor(1, 1, 1)

    -- Name
    love.graphics.print("Name: " .. unit.name, x + 10, y + 10)

    -- Class
    -- love.graphics.print("Class: " .. (unit.class or "?"), x + 10, y + 25)

    -- Health bar background
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", x + 10, y + 40, HoverInfo.barWidth, HoverInfo.barHeight)

    -- Health bar foreground
    local hpRatio = math.max(unit.hp / unit.maxHp, 0)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", x + 10, y + 40, HoverInfo.barWidth * hpRatio, HoverInfo.barHeight)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(unit.hp .. "/" .. unit.maxHp, x + 10 + HoverInfo.barWidth + 5, y + 40)
end
