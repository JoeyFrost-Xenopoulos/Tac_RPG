-- modules/ui/unit_stats/init.lua
-- Main unit stats module

local Resources = require("modules.ui.unit_stats.resources")
local State = require("modules.ui.unit_stats.state")
local Draw = require("modules.ui.unit_stats.draw")

local UnitStats = {}

-- Expose visible state for backwards compatibility
setmetatable(UnitStats, {
    __index = function(t, k)
        if k == "visible" then
            return State.visible
        end
    end
})

function UnitStats.load()
    Resources.load()
end

function UnitStats.show()
    State.show()
end

function UnitStats.hide()
    State.hide()
end

function UnitStats.isVisible()
    return State.visible
end

function UnitStats.nextUnit()
    State.nextUnit()
end

function UnitStats.previousUnit()
    State.previousUnit()
end

function UnitStats.update(dt)
    State.update(dt)
end

function UnitStats.draw()
    Draw.draw()
end

return UnitStats
