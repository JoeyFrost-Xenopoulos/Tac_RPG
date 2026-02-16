-- modules/ui/unit_stats/name_type_draw.lua
-- Name and type drawing for unit stats screen

local Config = require("modules.ui.unit_stats.config")
local Resources = require("modules.ui.unit_stats.resources")

local NameTypeDraw = {}

function NameTypeDraw.draw(unit, panelX, panelY, padding, nameY, opacity)
    if Resources.font then
        love.graphics.setFont(Resources.font)
        love.graphics.setColor(1, 1, 1, opacity)
        love.graphics.print(unit.type or "Unknown", panelX + padding + Config.TYPE_X_OFFSET, nameY + Config.TYPE_Y_OFFSET, 0)
        love.graphics.print(unit.name or "Unknown", panelX + padding + Config.TYPE_X_OFFSET, nameY + Config.TYPE_Y_OFFSET + Config.NAME_Y_OFFSET_FROM_TYPE, 0)
    end
end

return NameTypeDraw
