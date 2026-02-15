-- modules/ui/unit_stats/state.lua
-- State management for unit stats screen

local State = {}

State.visible = false
State.units = {}
State.index = 1
State.animTimer = 0
State.animFrame = 1

function State.show()
    local UnitManager = require("modules.units.manager")
    State.units = {}
    for _, unit in ipairs(UnitManager.units or {}) do
        if unit.isPlayer then
            table.insert(State.units, unit)
        end
    end
    State.index = 1
    State.visible = true
end

function State.hide()
    State.visible = false
end

function State.nextUnit()
    if #State.units == 0 then return end
    State.index = State.index + 1
    if State.index > #State.units then
        State.index = 1
    end
end

function State.previousUnit()
    if #State.units == 0 then return end
    State.index = State.index - 1
    if State.index < 1 then
        State.index = #State.units
    end
end

function State.update(dt)
    if not State.visible then return end
    
    local unit = State.units[State.index]
    if unit and unit.animations and unit.animations.idle then
        local anim = unit.animations.idle
        State.animTimer = State.animTimer + dt
        if State.animTimer >= (anim.speed or 0.1) then
            State.animTimer = State.animTimer - (anim.speed or 0.1)
            State.animFrame = State.animFrame + 1
            if State.animFrame > anim.frameCount then
                State.animFrame = 1
            end
        end
    end
end

return State
