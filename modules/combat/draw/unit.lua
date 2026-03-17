local Anim = require("modules.combat.battle_anim")
local UnitAnimation = require("modules.units.base.animation")

local UnitDraw = {}

local whiteSpriteShader

local function getWhiteSpriteShader()
    if whiteSpriteShader then return whiteSpriteShader end

    whiteSpriteShader = love.graphics.newShader([[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec4 tex = Texel(texture, texture_coords);
            return vec4(1.0, 1.0, 1.0, tex.a * color.a);
        }
    ]])

    return whiteSpriteShader
end

local function getDeathAnimVisual(state, unit)
    if not state.deathAnimActive then return true, 1 end
    if not state.deathAnimUnit or unit ~= state.deathAnimUnit then return true, 1 end

    local elapsed = state.battleTimer - (state.deathAnimStartTime or 0)
    if elapsed < 0 then
        return true, 1
    end

    local blinkDuration = state.deathAnimBlinkDuration or 0.22
    local fadeDuration = state.deathAnimFadeDuration or 0.75
    local blinkCount = state.deathAnimBlinkCount or 2

    if elapsed < blinkDuration then
        local toggleCount = math.max(1, blinkCount * 2)
        local blinkProgress = elapsed / blinkDuration
        local blinkSlice = math.floor(blinkProgress * toggleCount)
        return blinkSlice % 2 == 0, 1
    end

    local fadeElapsed = elapsed - blinkDuration
    if fadeElapsed < fadeDuration then
        local alpha = 1 - (fadeElapsed / fadeDuration)
        return true, math.max(0, math.min(1, alpha))
    end

    return false, 0
end

function UnitDraw.drawUnit(state, unit, x, y, facingX, isAttacking, animNameOverride, applyHitEffect, scaleMultiplier)
    if not unit or not unit.animations then return end

    local isVisible, alpha = getDeathAnimVisual(state, unit)
    if not isVisible then return end

    local animName = animNameOverride or (isAttacking and "attack" or "idle")
    local drawAnimName = animName
    local quad
    if animName == "attack" then
        drawAnimName = Anim.getAttackAnimName(unit)
        quad = Anim.getAttackFrame(state, unit)
    else
        quad = Anim.getAnimationFrame(state, unit, animName)
    end
    if not quad then return end

    local _, _, qw, qh = quad:getViewport()
    local offsetX = qw / 2
    local offsetY = qh - 50

    scaleMultiplier = scaleMultiplier or 1
    local sX = unit.scaleX * facingX * scaleMultiplier
    local sY = unit.scaleY * scaleMultiplier

    local shouldWhiteFlash = false
    if applyHitEffect and state.hitEffectActive and state.hitEffectStartTime then
        local spriteFlashLeadTime = 0.025
        local timeSinceHit = state.battleTimer - (state.hitEffectStartTime - spriteFlashLeadTime)
        local spriteFlashDuration = (state.hitEffectDuration or 0.12) * 0.55
        shouldWhiteFlash = timeSinceHit >= 0 and timeSinceHit < spriteFlashDuration
    end

    if shouldWhiteFlash then
        love.graphics.setShader(getWhiteSpriteShader())
    end

    local animImage = UnitAnimation.getImage(unit, drawAnimName)
    if not animImage then return end

    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.draw(animImage, quad, x, y + 280, 0, sX * 2, sY * 2, offsetX, offsetY)
    if shouldWhiteFlash then
        love.graphics.setShader()
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha")
end

return UnitDraw