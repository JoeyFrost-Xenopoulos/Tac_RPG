-- modules/combat/battle_draw.lua
local SceneDraw = require("modules.combat.draw.scene")
local UnitDraw = require("modules.combat.draw.unit")

local Draw = {}

function Draw.draw(state)
    SceneDraw.draw(state, UnitDraw.drawUnit)
end

Draw.drawUnit = UnitDraw.drawUnit

return Draw
