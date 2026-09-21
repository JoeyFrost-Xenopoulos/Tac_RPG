-- modules/combat/battle_transition_draw.lua
local TransitionDraw = {}
local UiDraw = require("modules.combat.battle_ui_draw")
local Helpers = require("modules.combat.battle_helpers")
local Utils = require("modules.manager.utils")

local whiteMixShader = nil

local function smoothstep(t)
    return t * t * (3 - 2 * t)
end

local function getWhiteMixShader()
    if whiteMixShader then
        return whiteMixShader
    end

    whiteMixShader = love.graphics.newShader([[
        extern number mixAmount;

        vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord)
        {
            vec4 texColor = Texel(texture, texCoord) * color;
            vec3 mixed = mix(vec3(1.0), texColor.rgb, mixAmount);
            return vec4(mixed, texColor.a);
        }
    ]])

    return whiteMixShader
end

local function getBattleLayout(state, screenW, screenH)
    if not state.platformImage then
        return nil
    end

    local platformW, platformH = state.platformImage:getDimensions()
    local centerX = screenW / 2
    local platformY = screenH / 2 - platformH * 0.6 / 2 + 80
    local drawScale = 0.8

    local leftDrawX = centerX - platformW * 0.6 + 360
    local rightDrawX = centerX
    local platformCenterY = platformY + 100 + (platformH * drawScale) / 2
    local leftCenterX = leftDrawX - (platformW * drawScale) / 2
    local rightCenterX = rightDrawX + (platformW * drawScale) / 2

    local attackerTargetX
    local defenderTargetX
    if state.attacker and state.attacker.isPlayer then
        attackerTargetX = centerX + platformW * 0.3
        defenderTargetX = centerX - platformW * 0.3
    else
        attackerTargetX = centerX - platformW * 0.3
        defenderTargetX = centerX + platformW * 0.3
    end

    return {
        platformW = platformW,
        platformH = platformH,
        drawScale = drawScale,
        platformCenterY = platformCenterY,
        leftCenterX = leftCenterX,
        rightCenterX = rightCenterX,
        unitTargetY = platformY - 60,
        attackerTargetX = attackerTargetX,
        defenderTargetX = defenderTargetX
    }
end

local function drawPlatformAt(state, centerX, centerY, flipX, scale, alpha)
    if not state.platformImage then return end

    local platformW, platformH = state.platformImage:getDimensions()
    love.graphics.setColor(1, 1, 1, alpha or 1)
    love.graphics.draw(state.platformImage, centerX, centerY, 0, flipX * scale, scale, platformW / 2, platformH / 2)
    love.graphics.setColor(1, 1, 1, 1)
end

local function drawFrameAt(state, screenW, screenH, progress)
    if not state.battleFrameImage then return end

    local frameW, frameH = state.battleFrameImage:getDimensions()
    local targetX = (screenW - frameW) / 2
    local targetY = (screenH - frameH) / 2
    local startY = screenH + frameH * 0.2
    local currentY = Utils.lerp(startY, targetY, progress)
    local scale = Utils.lerp(0.9, 1.0, progress)
    local alpha = Utils.lerp(0.0, 1.0, progress)

    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.draw(state.battleFrameImage, targetX + frameW / 2, currentY + frameH / 2, 0, scale, scale, frameW / 2, frameH / 2)
    love.graphics.setColor(1, 1, 1, 1)
end

function TransitionDraw.draw(state, screenW, screenH, drawUnit)
    if state.transitionPhase ~= "platform_move" then
        return false
    end

    local layout = getBattleLayout(state, screenW, screenH)
    if not layout then return true end

    local duration = state.transitionMoveDuration or 0
    local progress = duration > 0 and state.transitionTimer / duration or 1
    progress = smoothstep(Utils.clamp(progress, 0, 1))

    local startScale = 0.35
    local currentScale = Utils.lerp(startScale, layout.drawScale, progress)
    local platformYOffset = (layout.platformH * currentScale) * 0.2
    local attackerStartX = state.transitionStartAttackerX or screenW / 2
    local attackerStartY = (state.transitionStartAttackerY or screenH / 2) + platformYOffset
    local defenderStartX = state.transitionStartDefenderX or screenW / 2
    local defenderStartY = (state.transitionStartDefenderY or screenH / 2) + platformYOffset

    local attackerOnRight = state.attacker and state.attacker.isPlayer
    local attackerTargetPlatformX = attackerOnRight and layout.rightCenterX or layout.leftCenterX
    local defenderTargetPlatformX = attackerOnRight and layout.leftCenterX or layout.rightCenterX
    local targetPlatformY = layout.platformCenterY

    local attackerPlatformX = Utils.lerp(attackerStartX, attackerTargetPlatformX, progress)
    local attackerPlatformY = Utils.lerp(attackerStartY, targetPlatformY, progress)
    local defenderPlatformX = Utils.lerp(defenderStartX, defenderTargetPlatformX, progress)
    local defenderPlatformY = Utils.lerp(defenderStartY, targetPlatformY, progress)

    local attackerUnitX = Utils.lerp(state.transitionStartAttackerX or screenW / 2, layout.attackerTargetX, progress)
    local attackerUnitStartY = (state.transitionStartAttackerY or screenH / 2) - 280
    local attackerUnitY = Utils.lerp(attackerUnitStartY, layout.unitTargetY, progress)
    local defenderUnitX = Utils.lerp(state.transitionStartDefenderX or screenW / 2, layout.defenderTargetX, progress)
    local defenderUnitStartY = (state.transitionStartDefenderY or screenH / 2) - 280
    local defenderUnitY = Utils.lerp(defenderUnitStartY, layout.unitTargetY, progress)

    local unitScale = Utils.lerp(0.75, 1.0, progress)

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    local shader = getWhiteMixShader()
    love.graphics.setShader(shader)
    shader:send("mixAmount", progress)

    drawPlatformAt(state, attackerPlatformX, attackerPlatformY, attackerOnRight and 1 or -1, currentScale, 0.7)
    drawPlatformAt(state, defenderPlatformX, defenderPlatformY, attackerOnRight and -1 or 1, currentScale, 0.7)

    love.graphics.setColor(1, 1, 1, 0.8)
    if state.defender then
        local defenderFacingX = attackerOnRight and 1 or -1
        drawUnit(state, state.defender, defenderUnitX, defenderUnitY, defenderFacingX, false, nil, true, unitScale)
    end

    if state.attacker then
        local attackerFacingX = attackerOnRight and -1 or 1
        local attackerAnim = Helpers.isMonkCaster(state.attacker) and "idle" or "walk"
        drawUnit(state, state.attacker, attackerUnitX, attackerUnitY, attackerFacingX, false, attackerAnim, nil, unitScale)
    end

    drawFrameAt(state, screenW, screenH, progress)

    UiDraw.drawBigBar(state, screenW, screenH, progress)

    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1, 1)
    return true
end

return TransitionDraw
