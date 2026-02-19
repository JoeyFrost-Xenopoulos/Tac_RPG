-- modules/combat/battle_effects.lua
local Effects = {}

function Effects.getOverlayShake(state)
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

function Effects.startOverlayShake(state)
    state.overlayShakeActive = true
    state.overlayShakeStartTime = state.battleTimer
end

function Effects.update(state, attackFrameIndex, attacker, projectileHit)
    if state.hitEffectActive then return end

    -- Only show hit effect if the attack actually hit
    if not state.currentAttackHit then return end

    local shouldTrigger = false
    
    -- Check if this is a ranged attack with projectile
    local Projectile = require("modules.combat.battle_projectile")
    if attacker and Projectile.needsProjectile(attacker) then
        -- For ranged attacks, wait for projectile to hit
        if projectileHit then
            shouldTrigger = true
        end
    else
        -- For melee attacks, use frame-based timing
        if attackFrameIndex and attackFrameIndex >= 3 then
            shouldTrigger = true
        else
            local hitEffectTriggerTime = state.runDuration + 0.2
            if state.battleTimer >= hitEffectTriggerTime then
                shouldTrigger = true
            end
        end
    end

    if shouldTrigger then
        state.hitEffectActive = true
        state.hitEffectStartTime = state.battleTimer
        state.hitFrameStartTime = state.battleTimer
        Effects.startOverlayShake(state)
    end
end

function Effects.drawBreak(state, targetX, targetY, attacker)
    if not state.hitEffectActive then return end

    local timeSinceHit = state.battleTimer - state.hitFrameStartTime
    if timeSinceHit > state.breakAnimDuration then return end

    -- Check if this is a harpoon attack
    local isHarpoon = attacker and attacker.weapon == "harpoon"
    local effectImage = isHarpoon and state.harpoonHitEffectImage or state.hitEffectImage
    
    if not effectImage then return end

    local frameWidth = 64
    local frameHeight = 64
    local frameCount, cols, rows
    
    if isHarpoon then
        -- Harpoon effect: 4x4 grid = 16 frames
        frameCount = 16
        cols = 4
        rows = 4
    else
        -- Default break effect: 1x11 strip
        frameCount = 11
        cols = 11
        rows = 1
    end
    
    local animSpeed = state.breakAnimDuration / frameCount
    local frameIndex = math.floor(timeSinceHit / animSpeed)
    if frameIndex >= frameCount then return end

    -- Calculate frame position in sprite sheet
    local col = frameIndex % cols
    local row = math.floor(frameIndex / cols)
    local frameX = col * frameWidth
    local frameY = row * frameHeight
    
    local quad = love.graphics.newQuad(frameX, frameY, frameWidth, frameHeight, effectImage:getDimensions())

    local offsetX = frameWidth / 2
    local offsetY = frameHeight / 2
    love.graphics.draw(effectImage, quad, targetX, targetY, 0, 4, 4, offsetX, offsetY)
end

function Effects.drawFlash(state, screenW, screenH)
    if not state.hitEffectActive then return end

    local timeSinceHit = state.battleTimer - state.hitEffectStartTime
    local flashDuration = (state.hitEffectDuration or 0.12) * 0.45
    if timeSinceHit < flashDuration then
        local alpha = 1.0 - (timeSinceHit / flashDuration)
        local baseAlpha = math.min(1, alpha * 0.95)
        local additiveAlpha = math.min(1, alpha * 0.65)

        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(1, 1, 1, baseAlpha)
        love.graphics.rectangle("fill", 0, 0, screenW, screenH)

        love.graphics.setBlendMode("add")
        love.graphics.setColor(1, 1, 1, additiveAlpha)
        love.graphics.rectangle("fill", 0, 0, screenW, screenH)

        love.graphics.setBlendMode("alpha")
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function Effects.updateMiss(state, attackFrameIndex, attacker, projectileHit)
    if state.missEffectActive then return end

    -- Only show miss effect if the attack missed
    if state.currentAttackHit then return end

    local shouldTrigger = false
    
    -- Check if this is a ranged attack with projectile
    local Projectile = require("modules.combat.battle_projectile")
    if attacker and Projectile.needsProjectile(attacker) then
        -- For ranged attacks, wait for projectile to hit
        if projectileHit then
            shouldTrigger = true
        end
    else
        -- For melee attacks, use frame-based timing
        if attackFrameIndex and attackFrameIndex >= 3 then
            shouldTrigger = true
        else
            local missEffectTriggerTime = state.runDuration + 0.2
            if state.battleTimer >= missEffectTriggerTime then
                shouldTrigger = true
            end
        end
    end

    if shouldTrigger then
        state.missEffectActive = true
        state.missEffectStartTime = state.battleTimer
        state.missFrameStartTime = state.battleTimer
    end
end

function Effects.drawMiss(state, targetX, targetY, missSourceUnit)
    if not state.missEffectActive then return end

    local missImage = state.missEffectImage
    if missSourceUnit and missSourceUnit.isPlayer and state.missEffectPlayerImage then
        missImage = state.missEffectPlayerImage
    elseif missSourceUnit and missSourceUnit.isPlayer == false and state.missEffectEnemyImage then
        missImage = state.missEffectEnemyImage
    end
    if not missImage then return end

    local timeSinceMiss = state.battleTimer - state.missFrameStartTime
    if timeSinceMiss > state.missAnimDuration then return end

    local frameWidth = 100
    local frameHeight = 100
    local frameCount = 16
    local frameDuration = 0.075
    local animSpeed = state.missAnimDuration / frameCount

    local frameIndex = math.floor(timeSinceMiss / animSpeed)
    if frameIndex >= frameCount then return end

    local frameX = frameIndex * frameWidth
    local quad = love.graphics.newQuad(frameX, 0, frameWidth, frameHeight, missImage:getDimensions())

    local offsetX = frameWidth / 2
    local offsetY = frameHeight / 2
    love.graphics.draw(missImage, quad, targetX, targetY, 0, 2, 2, offsetX, offsetY)
end

return Effects
