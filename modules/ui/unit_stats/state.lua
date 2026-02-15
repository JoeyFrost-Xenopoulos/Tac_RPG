-- modules/ui/unit_stats/state.lua
-- State management for unit stats screen

local Config = require("modules.ui.unit_stats.config")

local State = {}

State.visible = false
State.units = {}
State.index = 1
State.animTimer = 0
State.animFrame = 1

-- Transition state
State.isTransitioning = false
State.transitionProgress = 0  -- 0 to 1
State.transitionDirection = 0  -- 1 for down/next, -1 for up/previous
State.previousIndex = 1  -- Tracks the unit being transitioned away from

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
    if #State.units == 0 or State.isTransitioning then return end
    State.index = State.index + 1
    if State.index > #State.units then
        State.index = 1
    end
    State.startTransition(1)  -- Down direction
end

function State.previousUnit()
    if #State.units == 0 or State.isTransitioning then return end
    State.index = State.index - 1
    if State.index < 1 then
        State.index = #State.units
    end
    State.startTransition(-1)  -- Up direction
end

function State.startTransition(direction)
    State.previousIndex = State.index  -- Store the current index before changing
    State.isTransitioning = true
    State.transitionProgress = 0
    State.transitionDirection = direction
end

function State.update(dt)
    if not State.visible then return end
    
    -- Update transition
    if State.isTransitioning then
        State.transitionProgress = State.transitionProgress + dt / Config.TRANSITION_DURATION
        if State.transitionProgress >= 1 then
            State.transitionProgress = 1
            State.isTransitioning = false
        end
    end
    
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
