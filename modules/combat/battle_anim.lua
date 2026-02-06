-- modules/combat/battle_anim.lua
local Anim = {}

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
    local runProgress = math.min(state.battleTimer / state.runDuration, 1.0)

    local startX
    if state.attacker.isPlayer then
        startX = screenW / 2 + platformW * 0.3
    else
        startX = screenW / 2 - platformW * 0.3
    end

    local endX
    if state.attacker.isPlayer then
        endX = screenW / 2 - platformW * 0.25 + 70
    else
        endX = screenW / 2 + platformW * 0.25 - 70
    end

    local x = startX + (endX - startX) * runProgress
    return x
end

return Anim
