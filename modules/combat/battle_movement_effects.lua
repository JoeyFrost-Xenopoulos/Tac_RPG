-- modules/combat/battle_movement_effects.lua
-- Handles screen shake and unit slide-back effects

local MovementEffects = {}

function MovementEffects.getOverlayShake(state)
    if not state.overlayShakeActive then return 0, 0 end
    
    local timeSinceStart = state.battleTimer - state.overlayShakeStartTime
    if timeSinceStart > state.overlayShakeDuration then
        state.overlayShakeActive = false
        return 0, 0
    end
    
    -- Create a bouncy shake pattern: up -> down -> up
    local progress = timeSinceStart / state.overlayShakeDuration
    local shakeY
    
    if progress < 0.15 then
        -- Snap up: 0 to -intensity
        shakeY = -state.overlayShakeIntensity * (progress / 0.15)
    elseif progress < 0.65 then
        -- Drop down: -intensity to +intensity (exaggerated)
        local dropProgress = (progress - 0.15) / 0.5
        shakeY = -state.overlayShakeIntensity + (state.overlayShakeIntensity * 2.2) * dropProgress
    else
        -- Bounce back up: +intensity to 0
        local bounceProgress = (progress - 0.65) / 0.35
        shakeY = state.overlayShakeIntensity * (1 - bounceProgress)
    end
    
    local shakeX = math.sin(timeSinceStart * 25) * state.overlayShakeIntensity * 0.2
    
    return shakeX, shakeY
end

function MovementEffects.startOverlayShake(state)
    state.overlayShakeActive = true
    state.overlayShakeStartTime = state.battleTimer
end

function MovementEffects.startSlideBack(state, target)
    state.slideBackActive = true
    state.slideBackStartTime = state.battleTimer
    state.slideBackTarget = target
end

function MovementEffects.getSlideBackOffset(state)
    if not state.slideBackActive then return 0 end
    
    local timeSinceStart = state.battleTimer - state.slideBackStartTime
    local totalDuration = state.slideBackDuration + state.slideReturnDuration
    
    if timeSinceStart > totalDuration then
        state.slideBackActive = false
        return 0
    end
    
    local offset = 0
    if timeSinceStart < state.slideBackDuration then
        -- Slide back phase: ease out
        local progress = math.max(0, timeSinceStart / state.slideBackDuration)
        local easeOut = 1 - math.pow(1 - progress, 3)  -- Cubic ease out
        offset = state.slideBackDistance * easeOut
    else
        -- Return phase: ease in-out
        local returnTime = timeSinceStart - state.slideBackDuration
        local progress = math.max(0, returnTime / state.slideReturnDuration)
        local easeInOut = progress < 0.5 
            and 4 * progress * progress * progress 
            or 1 - math.pow(-2 * progress + 2, 3) / 2
        offset = state.slideBackDistance * (1 - easeInOut)
    end
    
    -- Return negative for player (slide right), positive for enemy (slide left)
    if state.slideBackTarget and state.slideBackTarget.isPlayer then
        return offset
    else
        return -offset
    end
end

function MovementEffects.isWalkingBack(state)
    if not state.slideBackActive then return false end
    
    local timeSinceStart = state.battleTimer - state.slideBackStartTime
    -- Return true if we're in the return phase (walking back)
    return timeSinceStart >= state.slideBackDuration
end

function MovementEffects.update(state)
    if not state.slideBackActive then return end
    
    local timeSinceStart = state.battleTimer - state.slideBackStartTime
    local totalDuration = state.slideBackDuration + state.slideReturnDuration
    
    if timeSinceStart > totalDuration then
        state.slideBackActive = false
    end
end

return MovementEffects
