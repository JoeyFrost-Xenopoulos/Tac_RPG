-- modules/combat/battle_draw.lua
local Anim = require("modules.combat.battle_anim")
local Effects = require("modules.combat.battle_effects")
local TransitionDraw = require("modules.combat.battle_transition_draw")
local UiDraw = require("modules.combat.battle_ui_draw")

local Draw = {}

local WEAPON_NAMES = {
    sword = "Heavy Sword",
    -- Add more weapons as needed
}

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

        local runDuration = state.runDuration or 0
        local attackDuration = state.attackDuration or 0
        local returnDuration = state.returnDuration or 0
        local returnStartTime = runDuration + attackDuration
        local isRunPhase = state.battleTimer < runDuration
        local isAttackPhase = state.battleTimer >= runDuration
            and state.battleTimer < returnStartTime
        local isReturnPhase = returnDuration > 0
            and state.battleTimer >= returnStartTime
            and state.battleTimer < returnStartTime + returnDuration

        local defenderX, defenderFacingX
        if state.attacker.isPlayer then
            defenderX = centerX - platformW * 0.3
            defenderFacingX = 1
        else
            defenderX = centerX + platformW * 0.3
            defenderFacingX = -1
        end

        if state.defender then
            Draw.drawUnit(state, state.defender, defenderX, platformY - 60, defenderFacingX, false, nil, true)
        end

        if state.defender and state.hitEffectActive then
            Effects.drawBreak(state, defenderX, platformY + 160)
        end

        if state.attacker then
            local attackerX = Anim.getAttackerDisplayPosition(state, screenW, platformW)
            local attackerFacingX = state.attacker.isPlayer and -1 or 1
            local attackAnim
            if isRunPhase or isReturnPhase then
                attackAnim = "walk"
            elseif isAttackPhase then
                attackAnim = "attack"
            else
                attackAnim = "idle"
            end
            Draw.drawUnit(state, state.attacker, attackerX, platformY - 60, attackerFacingX, false, attackAnim)
        end
    end

    if state.battleFrameImage then
        local frameW, frameH = state.battleFrameImage:getDimensions()
        local frameX = (screenW - frameW) / 2
        local frameY = (screenH - frameH) / 2
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(state.battleFrameImage, frameX, frameY - 60)

        if state.pixelFont then
            local enemyPreview = state.enemyAttackPreview or {}
            local playerPreview = state.playerAttackPreview or {}
            local previewTopY = frameY + 60
            local leftPreviewX = frameX + 80
            local rightPreviewX = frameX + frameW - 300
            local previewWidth = 220
            local lineHeight = state.previewFont:getHeight() + 2

            love.graphics.setFont(state.previewFont)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(string.format("Hit: %d%%", enemyPreview.hit or 0), leftPreviewX + 50, previewTopY + 620)
            love.graphics.print(string.format("Dmg: %d", enemyPreview.damage or 0), leftPreviewX + 50, previewTopY + 620 + lineHeight)
            love.graphics.print(string.format("Crit: %d%%", enemyPreview.crit or 0), leftPreviewX + 50, previewTopY + 620 + lineHeight * 2)

            love.graphics.printf(string.format("Hit: %d%%", playerPreview.hit or 0), rightPreviewX - 112, previewTopY + 620, previewWidth, "right")
            love.graphics.printf(string.format("Dmg: %d", playerPreview.damage or 0), rightPreviewX - 118, previewTopY + 620 + lineHeight, previewWidth, "right")
            love.graphics.printf(string.format("Crit: %d%%", playerPreview.crit or 0), rightPreviewX - 100, previewTopY + 620 + lineHeight * 2, previewWidth, "right")
        end
        
        -- Draw sword icons for attacker and defender
        if state.swordIconImage then
            local swordW, swordH = state.swordIconImage:getDimensions()
            
            -- Attacker sword icon (left side)
            if state.attacker then
                local attackerSwordX = frameX + 290
                local attackerSwordY = frameY + 735
                love.graphics.draw(state.swordIconImage, attackerSwordX, attackerSwordY, 0, 0.80, 0.80)
                
                -- Draw attacker weapon name
                local weaponType = state.attacker.weapon or "sword"
                local weaponName = WEAPON_NAMES[weaponType] or "Unknown"
                if state.weaponFont then
                    love.graphics.setFont(state.weaponFont)
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.print(weaponName, attackerSwordX + swordW * 0.80 + 10, attackerSwordY)
                end
            end
            
            -- Defender sword icon (right side)
            if state.defender then
                local defenderSwordX = frameX + frameW - swordW - 500
                local defenderSwordY = frameY + 735
                love.graphics.draw(state.swordIconImage, defenderSwordX, defenderSwordY, 0, 0.80, 0.80)
                
                -- Draw defender weapon name
                local weaponType = state.defender.weapon or "sword"
                local weaponName = WEAPON_NAMES[weaponType] or "Unknown"
                if state.weaponFont then
                    love.graphics.setFont(state.weaponFont)
                    love.graphics.setColor(1, 1, 1, 1)
                    love.graphics.print(weaponName, defenderSwordX + swordW * 0.80 + 10, defenderSwordY)
                end
            end
        end
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
