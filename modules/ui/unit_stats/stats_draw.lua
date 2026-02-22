-- modules/ui/unit_stats/stats_draw.lua
-- Stats drawing for unit stats screen

local Config = require("modules.ui.unit_stats.config")
local Resources = require("modules.ui.unit_stats.resources")
local StatBar = require("modules.ui.unit_stats.stat_bar")

local StatsDraw = {}

function StatsDraw.draw(unit, panelX, padding, nameY, statsY, opacity)
    if Resources.statsFont then
        love.graphics.setFont(Resources.statsFont)
        love.graphics.setColor(1, 1, 1, opacity)
        local leftColumn = {
            { label = "Str", value = unit.strength and tostring(unit.strength) or "--", key = "strength" },
            { label = "Mag", value = unit.magic and tostring(unit.magic) or "--", key = "magic" },
            { label = "Skl", value = unit.skill and tostring(unit.skill) or "--", key = "skill" },
            { label = "Spd", value = unit.speed and tostring(unit.speed) or "--", key = "speed" },
            { label = "Con", value = unit.constitution and tostring(unit.constitution) or "--", key = "constitution" }
        }
        local rightColumn = {
            { label = "Mov", value = tostring(unit.maxMoveRange or 0), key = "maxMoveRange" },
            { label = "Luk", value = unit.luck and tostring(unit.luck) or "--", key = "luck" },
            { label = "Def", value = unit.defense and tostring(unit.defense) or "--", key = "defense" },
            { label = "Res", value = unit.resistance and tostring(unit.resistance) or "--", key = "resistance" },
            { label = "Aid", value = "--", key = nil }
        }
        
        local statsX = panelX + padding
        
        -- Draw left column
        for i, stat in ipairs(leftColumn) do
            local lineY = statsY + (i - 1) * Config.STATS_LINE_HEIGHT
            -- Draw bar first so the text can sit on top of it.
            if stat.key then
                local barX = statsX + Config.STATS_VALUE_X_OFFSET + Config.STATS_BAR_X_OFFSET
                local barY = lineY + Config.STATS_Y_DRAW_OFFSET + Config.STATS_BAR_Y_OFFSET - Config.STATS_BAR_TEXT_OVERLAP
                StatBar.draw(barX, barY, unit, stat.key, opacity)
            end

            -- Draw border for label
            local labelText = stat.label .. ":"
            local labelX = statsX + Config.STATS_LABEL_X_OFFSET
            local labelY = lineY + Config.STATS_Y_DRAW_OFFSET
            love.graphics.setColor(0.086, 0.094, 0.329, opacity) -- #161754 border
            for dx = -1, 1 do
                for dy = -1, 1 do
                    if dx ~= 0 or dy ~= 0 then
                        love.graphics.print(labelText, labelX + dx, labelY + dy)
                    end
                end
            end
            love.graphics.setColor(0.745, 0.957, 0.965, opacity) -- #bef4f6 fill
            love.graphics.print(labelText, labelX, labelY)

            -- Draw border for value
            local valueText = stat.value
            local valueX = statsX + Config.STATS_VALUE_X_OFFSET
            local valueY = lineY + Config.STATS_Y_DRAW_OFFSET
            love.graphics.setColor(0.086, 0.094, 0.329, opacity) -- #161754 border
            for dx = -1, 1 do
                for dy = -1, 1 do
                    if dx ~= 0 or dy ~= 0 then
                        love.graphics.print(valueText, valueX + dx, valueY + dy)
                    end
                end
            end
            love.graphics.setColor(0.745, 0.957, 0.965, opacity) -- #bef4f6 fill
            love.graphics.print(valueText, valueX, valueY)
        end
        
        -- Draw right column
        local rightX = statsX + Config.STATS_COLUMN_GAP
        for i, stat in ipairs(rightColumn) do
            local lineY = statsY + (i - 1) * Config.STATS_LINE_HEIGHT
            -- Draw bar first so the text can sit on top of it.
            if stat.key then
                local barX = rightX + Config.STATS_VALUE_X_OFFSET + Config.STATS_BAR_X_OFFSET
                local barY = lineY + Config.STATS_Y_DRAW_OFFSET + Config.STATS_BAR_Y_OFFSET - Config.STATS_BAR_TEXT_OVERLAP
                StatBar.draw(barX, barY, unit, stat.key, opacity)
            end

            -- Draw border for label
            local labelText = stat.label .. ":"
            local labelX = rightX + Config.STATS_LABEL_X_OFFSET
            local labelY = lineY + Config.STATS_Y_DRAW_OFFSET
            love.graphics.setColor(0.086, 0.094, 0.329, opacity) -- #161754 border
            for dx = -1, 1 do
                for dy = -1, 1 do
                    if dx ~= 0 or dy ~= 0 then
                        love.graphics.print(labelText, labelX + dx, labelY + dy)
                    end
                end
            end
            love.graphics.setColor(0.745, 0.957, 0.965, opacity) -- #bef4f6 fill
            love.graphics.print(labelText, labelX, labelY)

            -- Draw border for value
            local valueText = stat.value
            local valueX = rightX + Config.STATS_VALUE_X_OFFSET
            local valueY = lineY + Config.STATS_Y_DRAW_OFFSET
            love.graphics.setColor(0.086, 0.094, 0.329, opacity) -- #161754 border
            for dx = -1, 1 do
                for dy = -1, 1 do
                    if dx ~= 0 or dy ~= 0 then
                        love.graphics.print(valueText, valueX + dx, valueY + dy)
                    end
                end
            end
            love.graphics.setColor(0.745, 0.957, 0.965, opacity) -- #bef4f6 fill
            love.graphics.print(valueText, valueX, valueY)
        end
    end
end

return StatsDraw
