-- modules/combat/battle_draw.lua
local Anim = require("modules.combat.battle_anim")
local Effects = require("modules.combat.battle_effects")
local TransitionDraw = require("modules.combat.battle_transition_draw")
local UiDraw = require("modules.combat.battle_ui_draw")
local Helpers = require("modules.combat.battle_helpers")
local FrameDraw = require("modules.combat.battle_frame_draw")

local Draw = {}

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
        if state.battlePhase == "counterattack" then
            -- During counterattack: defender animates, attacker is static
            local attackerStaticX
            if state.attacker.isPlayer then
                attackerStaticX = centerX + platformW * 0.3
            else
                attackerStaticX = centerX - platformW * 0.3
            end
            local attackerFacingX = state.attacker.isPlayer and -1 or 1
            
            if state.attacker then
                Draw.drawUnit(state, state.attacker, attackerStaticX, platformY - 60, attackerFacingX, false, "idle")
            end

            if state.defender then
                local defenderX = Anim.getAttackerDisplayPosition(state, screenW, platformW)
                local defenderAnim = Helpers.getAttackAnimName(state)
                Draw.drawUnit(state, state.defender, defenderX, platformY - 60, defenderFacingX, false, defenderAnim)
            end

            -- Hit effect should be on the attacker during counterattack
            if state.attacker and state.hitEffectActive then
                Effects.drawBreak(state, attackerStaticX, platformY + 160)
            end
            if state.attacker and state.missEffectActive then
                Effects.drawMiss(state, attackerStaticX, platformY + 160)
            end
        else
            -- During initial attack: attacker animates, defender is static
            if state.defender then
                Draw.drawUnit(state, state.defender, defenderStaticX, platformY - 60, defenderFacingX, false, nil, true)
            end

            if state.defender and state.hitEffectActive then
                Effects.drawBreak(state, defenderStaticX, platformY + 160)
            end
            if state.defender and state.missEffectActive then
                Effects.drawMiss(state, defenderStaticX, platformY + 160)
            end

            if state.attacker then
                local attackerX = Anim.getAttackerDisplayPosition(state, screenW, platformW)
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
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(state.battleFrameImage, frameX, frameY - 60)

        FrameDraw.drawAttackPreview(state, frameX, frameY, frameW)
        FrameDraw.drawWeaponInfo(state, frameX, frameY, frameW, state.swordIconImage, state.weaponFont)
    end

    UiDraw.drawBigBar(state, screenW, screenH)

    Effects.drawFlash(state, screenW, screenH)

end

function Draw.drawUnit(state, unit, x, y, facingX, isAttacking, animNameOverride, applyHitEffect, scaleMultiplier)
    if not unit or not unit.animations then return end

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

    love.graphics.draw(unit.animations[animName].img, quad, x, y + 280, 0, sX * 2, sY * 2, offsetX, offsetY)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode("alpha")
end

return Draw
