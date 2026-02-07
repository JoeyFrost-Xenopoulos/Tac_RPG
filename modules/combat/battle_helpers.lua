-- modules/combat/battle_helpers.lua
-- Shared utility functions for battle system

local Helpers = {}

function Helpers.clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

function Helpers.easeOutQuad(t)
    return 1 - (1 - t) * (1 - t)
end

function Helpers.getPlayerUnit(attacker, defender)
    if attacker and attacker.isPlayer then
        return attacker
    end
    if defender and defender.isPlayer then
        return defender
    end
    return nil
end

function Helpers.getEnemyUnit(attacker, defender)
    if attacker and not attacker.isPlayer then
        return attacker
    end
    if defender and not defender.isPlayer then
        return defender
    end
    return nil
end

function Helpers.getPhaseTimings(state)
    return {
        runDuration = state.runDuration or 0,
        attackDuration = state.attackDuration or 0,
        returnDuration = state.returnDuration or 0,
        returnStartTime = (state.runDuration or 0) + (state.attackDuration or 0),
    }
end

function Helpers.isRunPhase(state)
    return state.battleTimer < (state.runDuration or 0)
end

function Helpers.isAttackPhase(state)
    local timings = Helpers.getPhaseTimings(state)
    return state.battleTimer >= timings.runDuration
        and state.battleTimer < timings.returnStartTime
end

function Helpers.isReturnPhase(state)
    local timings = Helpers.getPhaseTimings(state)
    return timings.returnDuration > 0
        and state.battleTimer >= timings.returnStartTime
        and state.battleTimer < timings.returnStartTime + timings.returnDuration
end

function Helpers.getAttackAnimName(state)
    if Helpers.isRunPhase(state) or Helpers.isReturnPhase(state) then
        return "walk"
    elseif Helpers.isAttackPhase(state) then
        return "attack"
    else
        return "idle"
    end
end

return Helpers
