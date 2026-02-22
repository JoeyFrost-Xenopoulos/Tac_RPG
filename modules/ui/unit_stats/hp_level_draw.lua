-- modules/ui/unit_stats/hp_level_draw.lua
-- HP and level drawing for unit stats screen

local Config = require("modules.ui.unit_stats.config")
local Resources = require("modules.ui.unit_stats.resources")

local HPLevelDraw = {}

function HPLevelDraw.draw(unit, panelX, padding, nameY, opacity)
    if Resources.hpFont and Resources.levelFont then
        -- Colors
        local textColor = {190/255, 244/255, 246/255, opacity} -- #bef4f6
        local borderColor = {22/255, 23/255, 84/255, opacity}   -- #161754
        local hpText = string.format("HP: %d/%d", unit.health or 0, unit.maxHealth or 0)
        local hpX = panelX + padding + Config.HP_X_OFFSET
        local hpY = nameY + Config.HP_Y_OFFSET
        local levelText = "Lvl: --"
        local levelX = panelX + padding + Config.HP_X_OFFSET
        local levelY = nameY + Config.LEVEL_Y_OFFSET

        -- Draw border for HP text
        love.graphics.setFont(Resources.hpFont)
        love.graphics.setColor(borderColor)
        for dx = -1, 1 do
            for dy = -1, 1 do
                if dx ~= 0 or dy ~= 0 then
                    love.graphics.print(hpText, hpX + dx, hpY + dy, 0)
                end
            end
        end
        -- Draw HP text
        love.graphics.setColor(textColor)
        love.graphics.print(hpText, hpX, hpY, 0)

        -- Draw border for Level text
        love.graphics.setFont(Resources.levelFont)
        love.graphics.setColor(borderColor)
        for dx = -1, 1 do
            for dy = -1, 1 do
                if dx ~= 0 or dy ~= 0 then
                    love.graphics.print(levelText, levelX + dx, levelY + dy, 0)
                end
            end
        end
        -- Draw Level text
        love.graphics.setColor(textColor)
        love.graphics.print(levelText, levelX, levelY, 0)
    end
end

return HPLevelDraw
