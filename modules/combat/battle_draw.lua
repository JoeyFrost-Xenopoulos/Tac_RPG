-- modules/combat/battle_draw.lua
local Anim = require("modules.combat.battle_anim")
local Effects = require("modules.combat.battle_effects")
local TransitionDraw = require("modules.combat.battle_transition_draw")
local UiDraw = require("modules.combat.battle_ui_draw")
local Helpers = require("modules.combat.battle_helpers")
local FrameDraw = require("modules.combat.battle_frame_draw")
local Projectile = require("modules.combat.battle_projectile")

local Draw = {}
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

function Draw.draw(state)
    if not state.visible then return end

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    if TransitionDraw.draw(state, screenW, screenH, Draw.drawUnit) then
        return
    end

    -- Draw semi-transparent dark overlay to darken the map
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    love.graphics.setColor(1, 1, 1, 1)

    if state.platformImage then
        local platformW, platformH = state.platformImage:getDimensions()
        local centerX = screenW / 2
        local platformY = screenH / 2 - platformH * 0.6 / 2 + 80

        local leftPlatformX = centerX - platformW * 0.6
        love.graphics.draw(state.platformImage, leftPlatformX + 360, platformY + 100, 0, -0.8, 0.8)

        local rightPlatformX = centerX
        love.graphics.draw(state.platformImage, rightPlatformX, platformY + 100, 0, 0.8, 0.8)

        state.platformX = leftPlatformX
        state.platformY = platformY

        local defenderStaticX, defenderFacingX
        if state.attacker.isPlayer then
            defenderStaticX = centerX - platformW * 0.3
            defenderFacingX = 1
        else
            defenderStaticX = centerX + platformW * 0.3
            defenderFacingX = -1
        end

        -- Determine which unit is animating and which is static
        local useCounterattackLayout = state.battlePhase == "counterattack"
            or (state.battlePhase == "death_anim" and state.deathAnimUnit and state.deathAnimUnit == state.attacker)

        if useCounterattackLayout then
            -- During counterattack: defender animates, attacker is static
            local attackerStaticX
            if state.attacker.isPlayer then
                attackerStaticX = centerX + platformW * 0.3
            else
                attackerStaticX = centerX - platformW * 0.3
            end
            local attackerFacingX = state.attacker.isPlayer and -1 or 1
            
            -- Apply slide-back offset if attacker is the target
            local slideOffset = 0
            local attackerAnim = "idle"
            if state.slideBackTarget == state.attacker then
                slideOffset = Effects.getSlideBackOffset(state)
                if Effects.isWalkingBack(state) then
                    attackerAnim = "walk"
                end
            end
            
            if state.attacker then
                Draw.drawUnit(state, state.attacker, attackerStaticX + slideOffset, platformY - 60, attackerFacingX, false, attackerAnim, true)
            end

            if state.defender then
                local defenderX = Anim.getAttackerDisplayPosition(state, screenW, platformW, state.defender)
                local defenderAnim = Helpers.getAttackAnimName(state)
                Draw.drawUnit(state, state.defender, defenderX, platformY - 60, defenderFacingX, false, defenderAnim)
            end

            -- Hit effect should be on the attacker during counterattack
            if state.attacker and state.hitEffectActive then
                Effects.drawBreak(state, attackerStaticX + slideOffset, platformY + 160, state.defender)
            end
            if state.attacker and state.missEffectActive then
                Effects.drawMiss(state, attackerStaticX + slideOffset, platformY + 160, state.defender)
            end
            if state.attacker and state.critEffectActive then
                Effects.drawCrit(state, attackerStaticX + slideOffset, platformY + 160)
            end
        else
            -- During initial attack: attacker animates, defender is static
            
            -- Apply slide-back offset if defender is the target
            local slideOffset = 0
            local defenderAnim = nil
            if state.slideBackTarget == state.defender then
                slideOffset = Effects.getSlideBackOffset(state)
                if Effects.isWalkingBack(state) then
                    defenderAnim = "walk"
                end
            end
            
            if state.defender then
                Draw.drawUnit(state, state.defender, defenderStaticX + slideOffset, platformY - 60, defenderFacingX, false, defenderAnim, true)
            end

            if state.defender and state.hitEffectActive then
                Effects.drawBreak(state, defenderStaticX + slideOffset, platformY + 160, state.attacker)
            end
            if state.defender and state.missEffectActive then
                Effects.drawMiss(state, defenderStaticX + slideOffset, platformY + 160, state.attacker)
            end
            if state.defender and state.critEffectActive then
                Effects.drawCrit(state, defenderStaticX + slideOffset, platformY + 160)
            end

            if state.attacker then
                local attackerX = Anim.getAttackerDisplayPosition(state, screenW, platformW, state.attacker)
                local attackerFacingX = state.attacker.isPlayer and -1 or 1
                local attackAnim = Helpers.getAttackAnimName(state)
                Draw.drawUnit(state, state.attacker, attackerX, platformY - 60, attackerFacingX, false, attackAnim)
            end
        end
    end

    if state.battleFrameImage then
        local frameW, frameH = state.battleFrameImage:getDimensions()
        local frameX = (screenW - frameW) / 2
        local frameY = (screenH - frameH) / 2
        
        -- Apply overlay shake offset
        local shakeX, shakeY = Effects.getOverlayShake(state)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(state.battleFrameImage, frameX + shakeX, frameY + shakeY - 60)

        FrameDraw.drawAttackPreview(state, frameX + shakeX, frameY + shakeY, frameW)
        FrameDraw.drawWeaponInfo(state, frameX + shakeX, frameY + shakeY, frameW, state.weaponIcons, state.weaponFont)
    end

    -- Apply overlay shake offset to big bar
    local shakeX, shakeY = Effects.getOverlayShake(state)
    UiDraw.drawBigBar(state, screenW, screenH, nil, shakeX, shakeY)
    
    -- Draw projectile on top of units
    Projectile.draw(state)

    Effects.drawFlash(state, screenW, screenH)

end

function Draw.drawUnit(state, unit, x, y, facingX, isAttacking, animNameOverride, applyHitEffect, scaleMultiplier)
    if not unit or not unit.animations then return end

    local isVisible, alpha = getDeathAnimVisual(state, unit)
    if not isVisible then return end

    local animName = animNameOverride or (isAttacking and "attack" or "idle")
    local quad
    if animName == "attack" then
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

    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.draw(unit.animations[animName].img, quad, x, y + 280, 0, sX * 2, sY * 2, offsetX, offsetY)
    if shouldWhiteFlash then
        love.graphics.setShader()
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha")
end

return Draw
