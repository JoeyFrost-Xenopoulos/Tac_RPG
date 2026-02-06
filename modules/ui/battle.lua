-- modules/ui/battle.lua
local Battle = {}

Battle.visible = false
Battle.attacker = nil
Battle.defender = nil
Battle.platformImage = nil
Battle.platformX = 0
Battle.platformY = 0
Battle.battleTimer = 0
Battle.battleDuration = 1.5  -- Duration to show battle screen
Battle.runDuration = 0.8  -- Time spent running towards target
Battle.attackDuration = 0.7  -- Time spent attacking

-- Hit effect variables
Battle.hitEffectImage = nil
Battle.hitEffectActive = false
Battle.hitEffectStartTime = 0
Battle.hitEffectDuration = 0.6  -- Duration of white flash
Battle.breakAnimDuration = 0.7  -- Duration of break animation
Battle.hitFrameStartTime = 0  -- When the hit visual starts (break animation)
Battle.defenderHitX = 0
Battle.defenderHitY = 0

function Battle.load()
    Battle.platformImage = love.graphics.newImage("assets/combat/arena/battle_platform.png")
    Battle.platformImage:setFilter("nearest", "nearest")
    Battle.hitEffectImage = love.graphics.newImage("assets/combat/hit_effect/break01.png")
    Battle.hitEffectImage:setFilter("nearest", "nearest")
end

function Battle.startBattle(attacker, defender)
    Battle.attacker = attacker
    Battle.defender = defender
    Battle.visible = true
    Battle.battleTimer = 0
    Battle.hitEffectActive = false
    Battle.hitFrameStartTime = 0
end

function Battle.endBattle()
    Battle.visible = false
    Battle.attacker = nil
    Battle.defender = nil
    Battle.battleTimer = 0
    Battle.hitEffectActive = false
    Battle.hitFrameStartTime = 0
end

function Battle.update(dt)
    if not Battle.visible then return end
    
    Battle.battleTimer = Battle.battleTimer + dt
    
    -- Trigger hit effect in the middle of attack animation frames (around 0.2s into attack)
    local hitEffectTriggerTime = Battle.runDuration + 0.2
    if Battle.battleTimer >= hitEffectTriggerTime and not Battle.hitEffectActive then
        Battle.hitEffectActive = true
        Battle.hitEffectStartTime = Battle.battleTimer
        Battle.hitFrameStartTime = Battle.battleTimer
    end
    
    -- After battle duration, process the attack and close
    if Battle.battleTimer >= Battle.battleDuration then
        if Battle.attacker and Battle.defender then
            local Attack = require("modules.engine.attack")
            local TurnManager = require("modules.engine.turn")
            local UnitManager = require("modules.units.manager")
            
            -- Perform the actual attack
            local damage = Attack.performAttack(Battle.attacker, Battle.defender)
            UnitManager.showDamage(Battle.defender, damage)
            
            -- Mark attacker as acted
            TurnManager.markUnitAsMoved(Battle.attacker)
            
            if TurnManager.areAllUnitsMoved() then
                TurnManager.endTurn()
            end
        end
        
        Battle.endBattle()
    end
end

function Battle:getAnimationFrame(unit, animName, timeOffset)
    local anim = unit.animations[animName]
    if not anim or not anim.quads then return nil end
    
    -- Calculate frame index based on animation speed and elapsed time
    -- speed is in seconds per frame (e.g., 0.10 = 10 fps)
    local speed = anim.speed or 0.1
    timeOffset = timeOffset or 0
    local frameIndex = math.floor((Battle.battleTimer - timeOffset) / speed) % #anim.quads + 1
    
    return anim.quads[frameIndex]
end

function Battle:drawBreakAnimation(targetX, targetY)
    if not Battle.hitEffectImage or not Battle.hitEffectActive then return end
    
    local timeSinceHit = Battle.battleTimer - Battle.hitFrameStartTime
    if timeSinceHit > Battle.breakAnimDuration then return end
    
    -- break01.png is 704x64, 11 frames of 64x64 each
    local frameWidth = 64
    local frameHeight = 64
    local frameCount = 11
    local animSpeed = Battle.breakAnimDuration / frameCount  -- Spread animation over duration
    
    local frameIndex = math.floor(timeSinceHit / animSpeed)
    if frameIndex >= frameCount then return end
    
    -- Create quad for current frame
    local frameX = frameIndex * frameWidth
    local quad = love.graphics.newQuad(frameX, 0, frameWidth, frameHeight, Battle.hitEffectImage:getDimensions())
    
    -- Draw break animation centered on target
    local offsetX = frameWidth / 2
    local offsetY = frameHeight / 2
    love.graphics.draw(Battle.hitEffectImage, quad, targetX, targetY, 0, 2, 2, offsetX, offsetY)
end

function Battle:getAttackerDisplayPosition(screenW, platformW)
    -- Calculate attacker progress through the battle
    local runProgress = math.min(Battle.battleTimer / Battle.runDuration, 1.0)
    
    -- Start on the side the attacker is on
    local startX
    if Battle.attacker.isPlayer then
        startX = screenW / 2 + platformW * 0.3  -- Right side
    else
        startX = screenW / 2 - platformW * 0.3  -- Left side
    end
    
    -- End at defender's position (20 pixels less movement)
    local endX
    if Battle.attacker.isPlayer then
        endX = screenW / 2 - platformW * 0.25 + 70  -- Move towards left (enemy) but 20px less
    else
        endX = screenW / 2 + platformW * 0.25 - 70  -- Move towards right (player) but 20px less
    end
    
    -- Interpolate position
    local x = startX + (endX - startX) * runProgress
    return x
end

function Battle.draw()
    if not Battle.visible then return end
    
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    
    -- Draw background
    love.graphics.setColor(0.1, 0.1, 0.15, 1)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    love.graphics.setColor(1, 1, 1, 1)
    
    -- Draw platforms
    if Battle.platformImage then
        local platformW, platformH = Battle.platformImage:getDimensions()
        local centerX = screenW / 2
        local platformY = screenH / 2 - platformH * 0.6 / 2 + 80
        
        -- Left platform (flipped horizontally)
        local leftPlatformX = centerX - platformW * 0.6
        love.graphics.draw(Battle.platformImage, leftPlatformX + 360, platformY + 100, 0, -0.8, 0.8)
        
        -- Right platform (normal)
        local rightPlatformX = centerX
        love.graphics.draw(Battle.platformImage, rightPlatformX, platformY + 100, 0, 0.8, 0.8)
        
        Battle.platformX = leftPlatformX
        Battle.platformY = platformY
        
        -- Determine if we're in run phase or attack phase
        local isRunPhase = Battle.battleTimer < Battle.runDuration
        
        -- Determine positioning: player always on right (at rest)
        local defenderX, defenderFacingX
        if Battle.attacker.isPlayer then
            -- Attacker (player) on right, defender (enemy) on left
            defenderX = centerX - platformW * 0.3
            defenderFacingX = 1
        else
            -- Attacker (enemy) on left, defender (player) on right
            defenderX = centerX + platformW * 0.3
            defenderFacingX = -1
        end
        
        -- Draw defender (always stationary)
        if Battle.defender then
            Battle:drawUnit(Battle.defender, defenderX, platformY - 60, defenderFacingX, false, nil, true)
        end
        
        -- Draw break animation on defender
        if Battle.defender and Battle.hitEffectActive then
            Battle:drawBreakAnimation(defenderX, platformY + 160, 0, 1, 1)
        end
        
        -- Draw attacker (moves towards defender)
        if Battle.attacker then
            local attackerX = Battle:getAttackerDisplayPosition(screenW, platformW)
            local attackerFacingX = Battle.attacker.isPlayer and -1 or 1
            local attackAnim = isRunPhase and "walk" or "attack"
            Battle:drawUnit(Battle.attacker, attackerX, platformY - 60, attackerFacingX, false, attackAnim)
        end
    end
    
    -- Draw full screen white flash
    if Battle.hitEffectActive then
        local timeSinceHit = Battle.battleTimer - Battle.hitEffectStartTime
        if timeSinceHit < Battle.hitEffectDuration then
            local alpha = 1.0 - (timeSinceHit / Battle.hitEffectDuration)
            love.graphics.setColor(1, 1, 1, alpha * 0.6)
            love.graphics.rectangle("fill", 0, 0, screenW, screenH)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

function Battle:drawUnit(unit, x, y, facingX, isAttacking, animNameOverride, applyHitEffect)
    if not unit or not unit.animations then return end
    
    -- Use provided animation name or determine from isAttacking
    local animName = animNameOverride or (isAttacking and "attack" or "idle")
    local quad = Battle:getAnimationFrame(unit, animName)
    if not quad then return end
    
    local _, _, qw, qh = quad:getViewport()
    local offsetX = qw / 2
    local offsetY = qh - 50
    
    local sX = unit.scaleX * facingX
    
    love.graphics.draw(unit.animations[animName].img, quad, x, y + 280, 0, sX * 2, unit.scaleY * 2, offsetX, offsetY)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha")
end

function Battle.clicked(mx, my)
    if not Battle.visible then return false end
    -- Click to advance battle if needed
    return true
end

return Battle

