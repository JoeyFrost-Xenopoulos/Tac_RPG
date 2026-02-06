-- modules/combat/battle_effects.lua
local Effects = {}

function Effects.update(state, attackFrameIndex)
    if state.hitEffectActive then return end

    local shouldTrigger = false
    if attackFrameIndex and attackFrameIndex >= 3 then
        shouldTrigger = true
    else
        local hitEffectTriggerTime = state.runDuration + 0.2
        if state.battleTimer >= hitEffectTriggerTime then
            shouldTrigger = true
        end
    end

    if shouldTrigger then
        state.hitEffectActive = true
        state.hitEffectStartTime = state.battleTimer
        state.hitFrameStartTime = state.battleTimer
    end
end

function Effects.drawBreak(state, targetX, targetY)
    if not state.hitEffectImage or not state.hitEffectActive then return end

    local timeSinceHit = state.battleTimer - state.hitFrameStartTime
    if timeSinceHit > state.breakAnimDuration then return end

    local frameWidth = 64
    local frameHeight = 64
    local frameCount = 11
    local animSpeed = state.breakAnimDuration / frameCount

    local frameIndex = math.floor(timeSinceHit / animSpeed)
    if frameIndex >= frameCount then return end

    local frameX = frameIndex * frameWidth
    local quad = love.graphics.newQuad(frameX, 0, frameWidth, frameHeight, state.hitEffectImage:getDimensions())

    local offsetX = frameWidth / 2
    local offsetY = frameHeight / 2
    love.graphics.draw(state.hitEffectImage, quad, targetX, targetY, 0, 2, 2, offsetX, offsetY)
end

function Effects.drawFlash(state, screenW, screenH)
    if not state.hitEffectActive then return end

    local timeSinceHit = state.battleTimer - state.hitEffectStartTime
    if timeSinceHit < state.hitEffectDuration then
        local alpha = 1.0 - (timeSinceHit / state.hitEffectDuration)
        love.graphics.setColor(1, 1, 1, alpha * 0.6)
        love.graphics.rectangle("fill", 0, 0, screenW, screenH)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return Effects
