-- modules/ui/unit_stats/hp_level_draw.lua
-- HP and level drawing for unit stats screen

local Config = require("modules.ui.unit_stats.config")
local Resources = require("modules.ui.unit_stats.resources")

local HPLevelDraw = {}

function HPLevelDraw.draw(unit, panelX, padding, nameY, opacity)
    if Resources.hpFont and Resources.levelFont then
        love.graphics.setColor(1, 1, 1, opacity)
        local hpText = string.format("HP: %d/%d", unit.health or 0, unit.maxHealth or 0)
        love.graphics.setFont(Resources.hpFont)
        love.graphics.print(hpText, panelX + padding + Config.HP_X_OFFSET, nameY + Config.HP_Y_OFFSET, 0)
        love.graphics.setFont(Resources.levelFont)
        love.graphics.print("Lvl: --", panelX + padding + Config.HP_X_OFFSET, nameY + Config.LEVEL_Y_OFFSET, 0)
    end
end

return HPLevelDraw
