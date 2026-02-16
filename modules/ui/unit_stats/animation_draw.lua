-- modules/ui/unit_stats/animation_draw.lua
-- Animation drawing for unit stats screen

local Config = require("modules.ui.unit_stats.config")
local State = require("modules.ui.unit_stats.state")

local AnimationDraw = {}

function AnimationDraw.draw(unit, panelX, padding, nameY, opacity)
    if unit.animations and unit.animations.idle then
        local anim = unit.animations.idle
        if anim.quads and anim.quads[State.animFrame] and anim.img then
            local quad = anim.quads[State.animFrame]
            local animScale = 1
            local animX = panelX + padding + Config.ANIM_X_OFFSET
            local animY = nameY + Config.ANIM_Y_OFFSET
            love.graphics.setColor(1, 1, 1, opacity)
            love.graphics.draw(anim.img, quad, animX + Config.ANIM_DRAW_X_OFFSET, animY + Config.ANIM_DRAW_Y_OFFSET, 0, animScale, animScale)
        end
    end
end

return AnimationDraw
