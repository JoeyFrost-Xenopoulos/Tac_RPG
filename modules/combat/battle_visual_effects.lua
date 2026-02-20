-- modules/combat/battle_visual_effects.lua
-- Handles hit and miss visual effects animations

local VisualEffects = {}

function VisualEffects.update(state, attackFrameIndex, attacker, projectileHit)
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
        state.hitEffectStartTime = state.battleTimer - 0.1
        state.hitFrameStartTime = state.battleTimer - 0.1
        
        local MovementEffects = require("modules.combat.battle_movement_effects")
        MovementEffects.startOverlayShake(state)
        
        -- Trigger slide-back for harpoon, sword, and bow attacks (start earlier)
        if attacker and (attacker.weapon == "harpoon" or attacker.weapon == "sword" or attacker.weapon == "bow") then
            -- Determine who is being hit
            local target
            if state.battlePhase == "counterattack" then
                target = state.attacker  -- Attacker is being hit during counterattack
            else
                target = state.defender  -- Defender is being hit during initial attack
            end
            -- Start slide-back earlier to sync with hit effect
            state.slideBackStartTime = state.battleTimer - 0.1
            MovementEffects.startSlideBack(state, target)
        end
    end
end

function VisualEffects.drawBreak(state, targetX, targetY, attacker)
    if not state.hitEffectActive then return end

    local timeSinceHit = state.battleTimer - state.hitFrameStartTime
    if timeSinceHit > state.breakAnimDuration then return end

    -- Determine which hit effect to use based on weapon
    local weaponType = attacker and attacker.weapon or "default"
    local effectImage
    local frameWidth, frameHeight
    local frameCount, cols, rows
    
    if weaponType == "harpoon" then
        effectImage = state.harpoonHitEffectImage
        frameCount = 10
        cols = 5
        rows = 2
        frameWidth = 128
        frameHeight = 64
    elseif weaponType == "sword" then
        effectImage = state.meleeHitEffectImage
        frameCount = 10
        cols = 5
        rows = 2
        frameWidth = 128
        frameHeight = 64
    elseif weaponType == "bow" then
        effectImage = state.meleeHitEffectImage  -- Arrows use melee hit effect
        frameCount = 10
        cols = 5
        rows = 2
        frameWidth = 128
        frameHeight = 64
    else
        effectImage = state.hitEffectImage
        frameCount = 11
        cols = 11
        rows = 1
        frameWidth = 64
        frameHeight = 64
    end
    
    if not effectImage then return end
    
    local animSpeed = state.breakAnimDuration / frameCount
    local frameIndex = math.floor(timeSinceHit / animSpeed)
    if frameIndex < 0 then return end
    if frameIndex >= frameCount then return end

    -- Calculate frame position in sprite sheet
    local col = frameIndex % cols
    local row = math.floor(frameIndex / cols)
    local frameX = col * frameWidth
    local frameY = row * frameHeight
    
    local quad = love.graphics.newQuad(frameX, frameY, frameWidth, frameHeight, effectImage:getDimensions())

    local offsetX = frameWidth / 2
    local offsetY = frameHeight / 2
    
    -- Adjust scale and position for special effects
    local scaleX, scaleY = 4, 4
    local drawX = targetX
    
    if weaponType == "harpoon" or weaponType == "sword" or weaponType == "bow" then
        scaleX = 3.2  -- 0.8 * 4 = scaled down
        scaleY = 3.2
        
        if attacker and attacker.isPlayer then
            scaleX = -3.2  -- Flip horizontally for player attacks
            drawX = targetX - 140  -- Move forward (left)
        else
            drawX = targetX + 140  -- Move forward (right)
        end
    end
    
    love.graphics.draw(effectImage, quad, drawX, targetY, 0, scaleX, scaleY, offsetX, offsetY)
end

function VisualEffects.drawFlash(state, screenW, screenH)
    if not state.hitEffectActive then return end

    local timeSinceHit = state.battleTimer - state.hitEffectStartTime
    if timeSinceHit < state.hitEffectDuration then
        local alpha = math.max(0, math.min(1, 1.0 - (timeSinceHit / state.hitEffectDuration)))
        love.graphics.setColor(1, 1, 1, alpha * 0.6)
        love.graphics.rectangle("fill", 0, 0, screenW, screenH)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function VisualEffects.updateMiss(state, attackFrameIndex, attacker, projectileHit)
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

function VisualEffects.drawMiss(state, targetX, targetY, missSourceUnit)
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

return VisualEffects
