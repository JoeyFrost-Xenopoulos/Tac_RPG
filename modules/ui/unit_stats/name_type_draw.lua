-- modules/ui/unit_stats/name_type_draw.lua
-- Name and type drawing for unit stats screen

local Config = require("modules.ui.unit_stats.config")
local Resources = require("modules.ui.unit_stats.resources")

local NameTypeDraw = {}

function NameTypeDraw.draw(unit, panelX, panelY, padding, nameY, opacity)
    if Resources.font then
        love.graphics.setFont(Resources.font)
        love.graphics.setColor(1, 1, 1, opacity)
        local typeText = unit.type or "Unknown"
        local typeX = panelX + padding + Config.HP_X_OFFSET
        love.graphics.print(typeText, typeX, nameY + Config.TYPE_Y_OFFSET + 100, 0)

        local nameText = unit.name or "Unknown"
        local nameWidth = love.graphics.getFont():getWidth(nameText)
        local nameX = 192 - (nameWidth / 2)
        love.graphics.print(nameText, nameX, nameY + Config.TYPE_Y_OFFSET + Config.NAME_Y_OFFSET_FROM_TYPE - 65, 0)
    end
end

return NameTypeDraw
