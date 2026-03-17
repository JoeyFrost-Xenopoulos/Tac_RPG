local ExpBarDraw = require("modules.combat.draw.progression.exp_bar")
local LevelUpStatsDraw = require("modules.combat.draw.progression.level_up_stats")

local ProgressionDraw = {}

function ProgressionDraw.drawExpBar(state, screenW, screenH)
    ExpBarDraw.draw(state, screenW, screenH)
end

function ProgressionDraw.drawLevelUpStats(state, screenW, screenH)
    LevelUpStatsDraw.draw(state, screenW, screenH)
end

return ProgressionDraw