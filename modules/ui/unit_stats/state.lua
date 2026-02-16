-- modules/ui/unit_stats/state.lua
-- State management for unit stats screen

local Config = require("modules.ui.unit_stats.config")

local State = {}

State.visible = false
State.playerUnits = {}
State.enemyUnits = {}
State.currentView = "player"  -- "player" or "enemy"
State.index = 1
State.animTimer = 0
State.animFrame = 1

-- Arrow pendulum animation
State.arrowAnimTimer = 0
State.arrowAnimOffset = 0

-- Transition state
State.isTransitioning = false
State.transitionProgress = 0  -- 0 to 1
State.transitionDirection = 0  -- For vertical: 1 for down/next, -1 for up/previous
State.transitionType = "vertical"  -- "vertical" or "horizontal"
State.previousIndex = 1  -- Tracks the unit being transitioned away from
State.previousView = "player"  -- Tracks the view being transitioned away from

function State.show()
    local UnitManager = require("modules.units.manager")
    State.playerUnits = {}
    State.enemyUnits = {}
    
    -- Separate units into player and enemy
    for _, unit in ipairs(UnitManager.units or {}) do
        if unit.isPlayer then
            table.insert(State.playerUnits, unit)
        else
            table.insert(State.enemyUnits, unit)
        end
    end
    
    State.currentView = "player"
    State.index = 1
    State.visible = true
end

function State.hide()
    State.visible = false
end

function State.getCurrentUnits()
    if State.currentView == "player" then
        return State.playerUnits
    else
        return State.enemyUnits
    end
end

function State.nextUnit()
    local units = State.getCurrentUnits()
    if #units == 0 or State.isTransitioning then return end
    State.index = State.index + 1
    if State.index > #units then
        State.index = 1
    end
    State.startVerticalTransition(1)  -- Down direction
end

function State.previousUnit()
    local units = State.getCurrentUnits()
    if #units == 0 or State.isTransitioning then return end
    State.index = State.index - 1
    if State.index < 1 then
        State.index = #units
    end
    State.startVerticalTransition(-1)  -- Up direction
end

function State.switchToEnemyView()
    if State.currentView == "enemy" or #State.enemyUnits == 0 or State.isTransitioning then return end
    State.previousView = State.currentView
    State.previousIndex = State.index
    State.currentView = "enemy"
    State.index = 1
    State.startHorizontalTransition(1)  -- Right direction
end

function State.switchToPlayerView()
    if State.currentView == "player" or #State.playerUnits == 0 or State.isTransitioning then return end
    State.previousView = State.currentView
    State.previousIndex = State.index
    State.currentView = "player"
    State.index = 1
    State.startHorizontalTransition(-1)  -- Left direction
end

function State.startVerticalTransition(direction)
    State.previousIndex = State.index  -- Store the current index before changing
    State.transitionType = "vertical"
    State.isTransitioning = true
    State.transitionProgress = 0
    State.transitionDirection = direction
end

function State.startHorizontalTransition(direction)
    State.transitionType = "horizontal"
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
    
    -- Update arrow pendulum animation
    State.arrowAnimTimer = State.arrowAnimTimer + dt
    -- Use sine wave for smooth ease in/out pendulum motion
    State.arrowAnimOffset = Config.ARROW_ANIM_AMPLITUDE * math.sin(State.arrowAnimTimer * Config.ARROW_ANIM_SPEED * math.pi * 2)
    
    local units = State.getCurrentUnits()
    local unit = units[State.index]
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
