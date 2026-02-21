-- modules/combat/battle_effects.lua
-- Re-exports effects from specialized modules for backward compatibility
-- Code has been split into:
--   - battle_movement_effects.lua (shake, slide-back)
--   - battle_visual_effects.lua (hit, miss effects)

local MovementEffects = require("modules.combat.battle_movement_effects")
local VisualEffects = require("modules.combat.battle_visual_effects")

local Effects = {}

-- Movement Effects Re-exports
function Effects.getOverlayShake(state)
    return MovementEffects.getOverlayShake(state)
end

function Effects.startOverlayShake(state)
    return MovementEffects.startOverlayShake(state)
end

function Effects.startSlideBack(state, target)
    return MovementEffects.startSlideBack(state, target)
end

function Effects.getSlideBackOffset(state)
    return MovementEffects.getSlideBackOffset(state)
end

function Effects.isWalkingBack(state)
    return MovementEffects.isWalkingBack(state)
end

function Effects.updateSlideBack(state)
    return MovementEffects.update(state)
end

-- Visual Effects Re-exports
function Effects.update(state, attackFrameIndex, attacker, projectileHit)
    return VisualEffects.update(state, attackFrameIndex, attacker, projectileHit)
end

function Effects.drawBreak(state, targetX, targetY, attacker)
    return VisualEffects.drawBreak(state, targetX, targetY, attacker)
end

function Effects.drawFlash(state, screenW, screenH)
    return VisualEffects.drawFlash(state, screenW, screenH)
end

function Effects.updateMiss(state, attackFrameIndex, attacker, projectileHit)
    return VisualEffects.updateMiss(state, attackFrameIndex, attacker, projectileHit)
end

function Effects.drawMiss(state, targetX, targetY, missSourceUnit)
    return VisualEffects.drawMiss(state, targetX, targetY, missSourceUnit)
end

function Effects.updateCrit(state, attackFrameIndex, attacker, projectileHit)
    return VisualEffects.updateCrit(state, attackFrameIndex, attacker, projectileHit)
end

function Effects.drawCrit(state, targetX, targetY)
    return VisualEffects.drawCrit(state, targetX, targetY)
end

return Effects
