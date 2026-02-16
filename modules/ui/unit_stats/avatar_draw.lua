-- modules/ui/unit_stats/avatar_draw.lua
-- Avatar drawing for unit stats screen

local Config = require("modules.ui.unit_stats.config")

local AvatarDraw = {}

function AvatarDraw.draw(unit, panelX, panelY, padding, opacity)
    if unit.avatar then
        local maxPortrait = Config.AVATAR_SIZE
        local scale = math.min(maxPortrait / unit.avatar:getWidth(), maxPortrait / unit.avatar:getHeight())
        love.graphics.setColor(1, 1, 1, opacity)
        love.graphics.draw(unit.avatar, panelX + padding + Config.AVATAR_X_OFFSET, panelY + padding + Config.AVATAR_Y_OFFSET, 0, scale * Config.AVATAR_SCALE, scale * Config.AVATAR_SCALE)
    end
end

return AvatarDraw
