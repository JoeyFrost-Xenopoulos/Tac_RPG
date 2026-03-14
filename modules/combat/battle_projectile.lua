-- modules/combat/battle_projectile.lua
-- Handles projectile animations for ranged attacks

local Projectile = {}

local function buildQuads(image, frameWidth, frameHeight, columns, rows)
    local quads = {}
    local imageW, imageH = image:getDimensions()

    for row = 0, rows - 1 do
        for col = 0, columns - 1 do
            local x = col * frameWidth
            local y = row * frameHeight
            table.insert(quads, love.graphics.newQuad(x, y, frameWidth, frameHeight, imageW, imageH))
        end
    end

    return quads
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function getFrameFromRange(startIndex, endIndex, progress)
    local frameCount = endIndex - startIndex + 1
    if frameCount <= 1 then
        return startIndex
    end

    local frameOffset = math.min(frameCount - 1, math.floor(progress * frameCount))
    return startIndex + frameOffset
end

local function getIceTimings(state)
    local chargeDuration = state.projectileChargeDuration or 0.28
    local flightDuration = state.projectileFlightDuration or 0.40
    local impactDuration = state.projectileImpactDuration or 0.24
    local elapsed = state.battleTimer - state.projectileStartTime

    return elapsed, chargeDuration, flightDuration, impactDuration
end

-- Check if a unit uses a ranged weapon and needs projectile
function Projectile.needsProjectile(unit)
    if not unit or not unit.weapon then return false end
    local CombatSystem = require("modules.combat.combat_system")
    local range = CombatSystem.getAttackRange(unit)
    return range > 1
end

-- Get the frame at which to spawn the projectile for a given weapon
function Projectile.getSpawnFrame(weapon)
    if weapon == "bow" then
        return 6  -- Arrows spawn on frame 6
    else
        return 4  -- Default to frame 4 for other weapons
    end
end

-- Get projectile spawn delay for a given weapon
function Projectile.getSpawnDelay(weapon)
    if weapon == "bow" then
        return 0.0  -- Arrows spawn immediately on frame 6
    else
        return 0.15  -- Default delay for other weapons
    end
end

-- Spawn a projectile from attacker to defender
function Projectile.spawn(state, attacker, defender, screenW, platformW, platformY)
    if not Projectile.needsProjectile(attacker) then return end
    if not state.projectileImages or not state.projectileImages[attacker.weapon] then return end
    
    state.projectileActive = true
    state.projectileSpawned = true
    state.projectileStartTime = state.battleTimer
    state.projectileImage = state.projectileImages[attacker.weapon]
    state.projectileWeapon = attacker.weapon  -- Store weapon type for later reference
    state.projectileFlipX = false

    -- Optional animated spritesheet data (used by ice shard)
    state.projectileQuads = nil
    state.projectileFrameDuration = nil
    state.projectileImpactHitTriggered = false
    state.projectileChargeDuration = nil
    state.projectileFlightDuration = nil
    state.projectileImpactDuration = nil
    
    -- Calculate start position (attacker's position)
    if attacker.isPlayer then
        state.projectileStartX = screenW / 2 + platformW * 0.3
    else
        state.projectileStartX = screenW / 2 - platformW * 0.3
    end
    state.projectileStartY = platformY + 150  -- Approx chest height
    
    -- Calculate target position (defender's position - middle of sprite)
    if defender.isPlayer then
        state.projectileTargetX = screenW / 2 + platformW * 0.3
    else
        state.projectileTargetX = screenW / 2 - platformW * 0.3
    end
    state.projectileTargetY = platformY + 150  -- Defender chest height
    
    -- Set duration based on weapon type
    if attacker.weapon == "bow" then
        state.projectileDuration = 0.35  -- Longer duration for arc trajectory
    elseif attacker.weapon == "ice" then
        state.projectileDuration = 0.92
        -- Ice sheet faces left in source art; mirror for player-side casts.
        state.projectileFlipX = attacker.isPlayer == true

        -- Ice shard sheet: 2048x1536, 4 columns x 3 rows, 512x512 frames
        state.projectileQuads = buildQuads(state.projectileImage, 512, 512, 4, 3)
        state.projectileFrameDuration = 0.08
        state.projectileChargeDuration = state.projectileFrameDuration * 4  -- Frames 1-4 in place
        state.projectileFlightDuration = state.projectileFrameDuration * 3  -- Frames 5-7 while flying
        state.projectileImpactDuration = state.projectileFrameDuration * 3  -- Last 3 frames on impact
    else
        state.projectileDuration = 0.25  -- Default duration
    end
end

-- Update projectile and check if it has reached target
function Projectile.update(state)
    if not state.projectileActive then return false end

    if state.projectileWeapon == "ice" then
        local elapsed, chargeDuration, flightDuration, impactDuration = getIceTimings(state)
        local impactStart = chargeDuration + flightDuration
        local endTime = impactStart + impactDuration
        local impactTriggeredNow = false

        if not state.projectileImpactHitTriggered and elapsed >= impactStart then
            state.projectileImpactHitTriggered = true
            impactTriggeredNow = true
        end

        if elapsed >= endTime then
            state.projectileActive = false
        end

        return impactTriggeredNow
    end
    
    local timeSinceLaunch = state.battleTimer - state.projectileStartTime
    
    -- Check if projectile has reached target
    if timeSinceLaunch >= state.projectileDuration then
        state.projectileActive = false
        return true  -- Return true to indicate projectile hit
    end
    
    return false
end

-- Get current projectile position
function Projectile.getPosition(state)
    if not state.projectileActive then return nil, nil end
    
    local timeSinceLaunch = state.battleTimer - state.projectileStartTime
    local progress = math.min(timeSinceLaunch / state.projectileDuration, 1.0)
    
    local x, y, angle
    
    -- Different trajectory based on weapon type
    if state.projectileWeapon == "bow" then
        -- Arrow: parabolic arc trajectory
        x, y, angle = Projectile.getArrowPosition(state, progress)
    else
        -- Default (harpoon): linear trajectory
        x, y, angle = Projectile.getLinearPosition(state, progress)
    end
    
    return x, y, angle
end

-- Get linear position for harpoon-like projectiles
function Projectile.getLinearPosition(state, progress)
    -- Linear interpolation for both X and Y (straight line)
    local x = state.projectileStartX + (state.projectileTargetX - state.projectileStartX) * progress
    local y = state.projectileStartY + (state.projectileTargetY - state.projectileStartY) * progress
    
    -- Calculate rotation to point toward target
    -- The harpoon image is drawn at 45 degrees pointing to top-right, so we subtract that base angle
    local dx = state.projectileTargetX - state.projectileStartX
    local dy = state.projectileTargetY - state.projectileStartY
    local targetAngle = math.atan2(dy, dx)
    local baseAngle = -math.pi / 4  -- -45 degrees (image's default orientation)
    local angle = targetAngle - baseAngle
    
    return x, y, angle
end

-- Get parabolic position for arrow projectiles
function Projectile.getArrowPosition(state, progress)
    -- Parabolic arc: X follows linear path, Y follows parabolic path
    local x = state.projectileStartX + (state.projectileTargetX - state.projectileStartX) * progress
    
    -- Parabolic arc: rise and fall
    -- Peak at 50% progress, height adjustment of -120 pixels
    local arcHeight = 120
    local parabolaY = -4 * arcHeight * (progress - 0.5) * (progress - 0.5) + arcHeight
    
    local y = state.projectileStartY + (state.projectileTargetY - state.projectileStartY) * progress - parabolaY
    
    -- Calculate rotation based on trajectory slope
    local dx = state.projectileTargetX - state.projectileStartX
    
    -- Calculate vertical velocity (derivative of parabola)
    -- parabolaY = -4 * arcHeight * (progress - 0.5)^2 + arcHeight
    -- d(parabolaY)/d(progress) = -8 * arcHeight * (progress - 0.5)
    local verticalVelocity = -8 * arcHeight * (progress - 0.5)
    
    -- Calculate angle from horizontal and vertical components
    -- Negative dx means player is attacking (arrow going left)
    local horizontalVelocity = dx / state.projectileDuration
    
    -- atan2 gives angle from x-axis
    local angle = math.atan2(-verticalVelocity, horizontalVelocity)
    
    return x, y, angle
end

-- Draw the projectile
function Projectile.draw(state)
    if not state.projectileActive or not state.projectileImage then return end

    if state.projectileWeapon == "ice" and state.projectileQuads and #state.projectileQuads > 0 then
        local elapsed, chargeDuration, flightDuration, impactDuration = getIceTimings(state)
        local chargeEnd = chargeDuration
        local flightEnd = chargeDuration + flightDuration
        local impactEnd = flightEnd + impactDuration

        local x = state.projectileStartX
        local y = state.projectileStartY
        local frameIndex = 1

        if elapsed < chargeEnd then
            local progress = math.max(0, math.min(1, elapsed / chargeDuration))
            frameIndex = getFrameFromRange(1, 4, progress)
        elseif elapsed < flightEnd then
            local progress = math.max(0, math.min(1, (elapsed - chargeDuration) / flightDuration))
            frameIndex = getFrameFromRange(5, 7, progress)
            x = lerp(state.projectileStartX, state.projectileTargetX, progress)
            y = lerp(state.projectileStartY, state.projectileTargetY, progress)
        elseif elapsed < impactEnd then
            local progress = math.max(0, math.min(1, (elapsed - flightEnd) / impactDuration))
            local lastFrameStart = math.max(1, #state.projectileQuads - 2)
            frameIndex = getFrameFromRange(lastFrameStart, #state.projectileQuads, progress)
            x = state.projectileTargetX
            y = state.projectileTargetY
        else
            return
        end

        local quad = state.projectileQuads[frameIndex]
        local _, _, qw, qh = quad:getViewport()
        local scale = 0.35
        local scaleX = state.projectileFlipX and -scale or scale

        love.graphics.draw(
            state.projectileImage,
            quad,
            x,
            y,
            0,
            scaleX,
            scale,
            qw / 2,
            qh / 2
        )
        return
    end

    local x, y, angle = Projectile.getPosition(state)
    if not x or not y then return end

    local imgW, imgH = state.projectileImage:getDimensions()
    local scale = 2.0
    
    love.graphics.draw(
        state.projectileImage,
        x, y,
        angle,
        scale, scale,
        imgW / 2, imgH / 2
    )
end

return Projectile
