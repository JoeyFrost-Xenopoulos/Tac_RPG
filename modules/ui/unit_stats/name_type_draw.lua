-- modules/ui/unit_stats/name_type_draw.lua
-- Name and type drawing for unit stats screen

local Config = require("modules.ui.unit_stats.config")
local Resources = require("modules.ui.unit_stats.resources")

local NameTypeDraw = {}

function NameTypeDraw.draw(unit, panelX, panelY, padding, nameY, opacity)
    if Resources.font then
        love.graphics.setFont(Resources.font)
        -- Border color #222021 (RGB: 34, 32, 33)
        local borderColor = {34/255, 32/255, 33/255, opacity}
        local mainColor = {1, 1, 1, opacity}
        local typeText = unit.type or "Unknown"
        local typeX = panelX + padding + Config.HP_X_OFFSET
        local typeY = nameY + Config.TYPE_Y_OFFSET + 100
        local nameText = unit.name or "Unknown"
        local nameWidth = love.graphics.getFont():getWidth(nameText)
        local nameX = 192 - (nameWidth / 2)
        local nameYPos = nameY + Config.TYPE_Y_OFFSET + Config.NAME_Y_OFFSET_FROM_TYPE - 65

        -- Draw border for typeText
        love.graphics.setColor(borderColor)
        for dx = -1, 1 do
            for dy = -1, 1 do
                if dx ~= 0 or dy ~= 0 then
                    love.graphics.print(typeText, typeX + dx, typeY + dy, 0)
                end
            end
        end
        -- Draw border for nameText
        for dx = -1, 1 do
            for dy = -1, 1 do
                if dx ~= 0 or dy ~= 0 then
                    love.graphics.print(nameText, nameX + dx, nameYPos + dy, 0)
                end
            end
        end

        -- Draw main text
        love.graphics.setColor(mainColor)
        love.graphics.print(typeText, typeX, typeY, 0)
        love.graphics.print(nameText, nameX, nameYPos, 0)
    end
end

return NameTypeDraw
