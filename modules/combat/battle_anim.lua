-- modules/combat/battle_anim.lua
local Anim = {}

local function clamp(value, minValue, maxValue)
    if value < minValue then return minValue end
    if value > maxValue then return maxValue end
    return value
end

function Anim.getAnimationFrame(state, unit, animName, timeOffset)
    local anim = unit.animations[animName]
    if not anim or not anim.quads then return nil end

    local speed = anim.speed or 0.1
    timeOffset = timeOffset or 0
    local frameIndex = math.floor((state.battleTimer - timeOffset) / speed) % #anim.quads + 1

    return anim.quads[frameIndex]
end

function Anim.getAttackFrameIndex(state, unit)
    if not unit or not unit.animations or not unit.animations.attack then return nil end

    local anim = unit.animations.attack
    if not anim.quads or #anim.quads == 0 then return nil end

    local speed = anim.speed or 0.1
    local attackTime = state.battleTimer - state.runDuration
    if attackTime < 0 then
        return 1
    end

    local frameIndex = math.floor(attackTime / speed) + 1
    local maxFrames = math.min(4, #anim.quads)
    if frameIndex < 1 then frameIndex = 1 end
    if frameIndex > maxFrames then frameIndex = maxFrames end

    return frameIndex
end

function Anim.getAttackFrame(state, unit)
    local anim = unit.animations.attack
    if not anim or not anim.quads then return nil end

    local frameIndex = Anim.getAttackFrameIndex(state, unit)
    if not frameIndex then return nil end

    return anim.quads[frameIndex]
end

function Anim.getAttackerDisplayPosition(state, screenW, platformW)
    local runDuration = state.runDuration or 0
    local attackDuration = state.attackDuration or 0
    local returnDuration = state.returnDuration or 0
    local time = state.battleTimer

    -- Determine which unit is currently animating
    local animatingUnit = state.attacker
    if state.battlePhase == "counterattack" then
        animatingUnit = state.defender
    end

    local startX
    if animatingUnit.isPlayer then
        startX = screenW / 2 + platformW * 0.3
    else
        startX = screenW / 2 - platformW * 0.3
    end

    local endX
    if animatingUnit.isPlayer then
        endX = screenW / 2 - platformW * 0.25 + 70
    else
        endX = screenW / 2 + platformW * 0.25 - 70
    end

    if runDuration > 0 and time <= runDuration then
        local runProgress = clamp(time / runDuration, 0, 1)
        return startX + (endX - startX) * runProgress
    end

    local attackEndTime = runDuration + attackDuration
    if time <= attackEndTime or returnDuration <= 0 then
        return endX
    end

    local returnProgress = clamp((time - attackEndTime) / returnDuration, 0, 1)
    return endX + (startX - endX) * returnProgress
end

function Anim.getAnimatingUnit(state)
    if state.battlePhase == "counterattack" then
        return state.defender
    end
    return state.attacker
end

return Anim
