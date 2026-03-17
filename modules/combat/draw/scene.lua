local Anim = require("modules.combat.battle_anim")
local Effects = require("modules.combat.battle_effects")
local TransitionDraw = require("modules.combat.battle_transition_draw")
local UiDraw = require("modules.combat.battle_ui_draw")
local Helpers = require("modules.combat.battle_helpers")
local FrameDraw = require("modules.combat.battle_frame_draw")
local Projectile = require("modules.combat.battle_projectile")
local ProgressionDraw = require("modules.combat.draw.progression")

local SceneDraw = {}

function SceneDraw.draw(state, drawUnit)
    if not state.visible then return end

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    if TransitionDraw.draw(state, screenW, screenH, drawUnit) then
        return
    end

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

        local useCounterattackLayout = state.battlePhase == "counterattack"
            or (state.battlePhase == "death_anim" and state.deathAnimUnit and state.deathAnimUnit == state.attacker)

        if useCounterattackLayout then
            local attackerStaticX
            if state.attacker.isPlayer then
                attackerStaticX = centerX + platformW * 0.3
            else
                attackerStaticX = centerX - platformW * 0.3
            end
            local attackerFacingX = state.attacker.isPlayer and -1 or 1

            local slideOffset = 0
            local attackerAnim = "idle"
            if state.slideBackTarget == state.attacker then
                slideOffset = Effects.getSlideBackOffset(state)
                if Effects.isWalkingBack(state) then
                    attackerAnim = "walk"
                end
            end

            if state.attacker then
                drawUnit(state, state.attacker, attackerStaticX + slideOffset, platformY - 60, attackerFacingX, false, attackerAnim, true)
            end

            if state.defender then
                local defenderX = Anim.getAttackerDisplayPosition(state, screenW, platformW, state.defender)
                local defenderAnim = Helpers.getAttackAnimName(state, state.defender)
                drawUnit(state, state.defender, defenderX, platformY - 60, defenderFacingX, false, defenderAnim)
            end

            if state.attacker and state.hitEffectActive then
                Effects.drawBreak(state, attackerStaticX + slideOffset, platformY + 160, state.defender)
            end
            if state.attacker and state.missEffectActive then
                Effects.drawMiss(state, attackerStaticX + slideOffset, platformY + 160, state.defender)
            end
            if state.attacker and state.critEffectActive then
                Effects.drawCrit(state, attackerStaticX + slideOffset, platformY + 160)
            end

            if state.attacker and state.fireEffectActive then
                Effects.drawFire(state, attackerStaticX + slideOffset, platformY + 160, state.defender)
            end
        else
            local slideOffset = 0
            local defenderAnim = nil
            if state.slideBackTarget == state.defender then
                slideOffset = Effects.getSlideBackOffset(state)
                if Effects.isWalkingBack(state) then
                    defenderAnim = "walk"
                end
            end

            if state.defender then
                drawUnit(state, state.defender, defenderStaticX + slideOffset, platformY - 60, defenderFacingX, false, defenderAnim, true)
            end

            if state.defender and state.fireEffectActive then
                Effects.drawFire(state, defenderStaticX + slideOffset, platformY + 160, state.attacker)
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
                local attackAnim = Helpers.getAttackAnimName(state, state.attacker)
                drawUnit(state, state.attacker, attackerX, platformY - 60, attackerFacingX, false, attackAnim)
            end
        end
    end

    if state.battleFrameImage then
        local frameW, frameH = state.battleFrameImage:getDimensions()
        local frameX = (screenW - frameW) / 2
        local frameY = (screenH - frameH) / 2

        local shakeX, shakeY = Effects.getOverlayShake(state)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(state.battleFrameImage, frameX + shakeX, frameY + shakeY - 60)

        FrameDraw.drawAttackPreview(state, frameX + shakeX, frameY + shakeY, frameW)
        FrameDraw.drawWeaponInfo(state, frameX + shakeX, frameY + shakeY, frameW, state.weaponIcons, state.weaponFont)
    end

    local shakeX, shakeY = Effects.getOverlayShake(state)
    UiDraw.drawBigBar(state, screenW, screenH, nil, shakeX, shakeY)

    Projectile.draw(state)

    ProgressionDraw.drawExpBar(state, screenW, screenH)
    -- Legacy level-up overlay disabled; level-up UI is now handled by LevelUpMenu in exp_bar.

    Effects.drawFlash(state, screenW, screenH)
end

return SceneDraw