-- modules/combat/battle_projectile.lua
-- Handles projectile animations for ranged attacks

local Projectile = {}

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
        return 0.0  -- Arrows spawn immediately on frame 6 (no additional delay)
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
    
    -- Calculate start position (attacker's position)
    if attacker.isPlayer then
        state.projectileStartX = screenW / 2 + platformW * 0.3
    else
        state.projectileStartX = screenW / 2 - platformW * 0.3
    end
    state.projectileStartY = platformY - 60 + 96 + 100  -- Center of unit sprite, adjusted down
    
    -- Calculate target position (defender's position - middle of sprite)
    if defender.isPlayer then
        state.projectileTargetX = screenW / 2 + platformW * 0.3
    else
        state.projectileTargetX = screenW / 2 - platformW * 0.3
    end
    state.projectileTargetY = platformY - 60 + 96 + 100  -- Center of defender sprite, adjusted down
    
    -- Set duration based on weapon type
    if attacker.weapon == "bow" then
        state.projectileDuration = 0.35  -- Longer duration for arc trajectory
    else
        state.projectileDuration = 0.25  -- Default duration
    end
end

-- Update projectile and check if it has reached target
function Projectile.update(state)
    if not state.projectileActive then return false end
    
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
