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

-- Spawn a projectile from attacker to defender
function Projectile.spawn(state, attacker, defender, screenW, platformW, platformY)
    if not Projectile.needsProjectile(attacker) then return end
    if not state.projectileImages or not state.projectileImages[attacker.weapon] then return end
    
    state.projectileActive = true
    state.projectileSpawned = true
    state.projectileStartTime = state.battleTimer
    state.projectileImage = state.projectileImages[attacker.weapon]
    
    -- Calculate start position (attacker's position)
    if attacker.isPlayer then
        state.projectileStartX = screenW / 2 + platformW * 0.3
    else
        state.projectileStartX = screenW / 2 - platformW * 0.3
    end
    state.projectileStartY = platformY - 60 + 96 + 100  -- Center of unit sprite, adjusted down
    
    -- Calculate target position (defender's position)
    if defender.isPlayer then
        state.projectileTargetX = screenW / 2 + platformW * 0.3
    else
        state.projectileTargetX = screenW / 2 - platformW * 0.3
    end
    state.projectileTargetY = platformY - 60 + 96 + 100  -- Center of defender sprite, adjusted down
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

-- Get current projectile position (straight line)
function Projectile.getPosition(state)
    if not state.projectileActive then return nil, nil end
    
    local timeSinceLaunch = state.battleTimer - state.projectileStartTime
    local progress = math.min(timeSinceLaunch / state.projectileDuration, 1.0)
    
    -- Linear interpolation for both X and Y (straight line)
    local x = state.projectileStartX + (state.projectileTargetX - state.projectileStartX) * progress
    local y = state.projectileStartY + (state.projectileTargetY - state.projectileStartY) * progress
    
    -- Calculate rotation to point toward target (straight line angle)
    -- The harpoon image is drawn at 45 degrees pointing to top-right, so we subtract that base angle
    local dx = state.projectileTargetX - state.projectileStartX
    local dy = state.projectileTargetY - state.projectileStartY
    local targetAngle = math.atan2(dy, dx)
    local baseAngle = -math.pi / 4  -- -45 degrees (image's default orientation)
    local angle = targetAngle - baseAngle
    
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
