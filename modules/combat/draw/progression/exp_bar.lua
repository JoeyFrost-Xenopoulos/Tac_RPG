local Utils = require("modules.combat.draw.progression.utils")
local LevelUpMenu = require("modules.combat.draw.progression.level_up_menu")

local ExpBarDraw = {}

local function getLevelUpMenuDelay(state)
    return math.max(state.expBarPostHoldDuration or 0.8, 0)
end

local function getFillAndDisplayedExp(state, animProgress, barScaleX)
    local startFill = state.expBarStartFillPercent or 0
    local targetFillUnits = state.expBarTargetFillUnits
    if targetFillUnits == nil then
        targetFillUnits = state.expBarFillPercent or 0
    end

    local traveledFillUnits = startFill + (targetFillUnits - startFill) * animProgress
    local fillPercent
    if animProgress >= 1 then
        fillPercent = state.expBarFillPercent or 0
    elseif traveledFillUnits >= 1 then
        fillPercent = traveledFillUnits % 1
        if fillPercent == 0 then
            fillPercent = 1
        end
    else
        fillPercent = traveledFillUnits
    end

    fillPercent = math.max(0, math.min(1, fillPercent))
    local fillVisibleWidth = math.floor(192 * barScaleX * fillPercent)

    local maxExperience = math.max(state.expBarMaxValue or 100, 1)
    local displayedExpValue
    if animProgress >= 1 then
        displayedExpValue = state.expBarEndValue or 0
    else
        local startExpValue = state.expBarStartValue or 0
        local animatedGain = math.floor((state.expBarGainAmount or 0) * animProgress + 0.5)
        displayedExpValue = (startExpValue + animatedGain) % maxExperience
    end

    return fillVisibleWidth, displayedExpValue
end

local function drawLevelUpBanner(state, panelX, panelY, panelW)
    if not state.expLeveledUp then return end

    local bannerW = 320
    local bannerH = 42
    local bannerX = panelX + (panelW - bannerW) / 2
    local bannerY = panelY - 24
    local bannerText = "LEVEL UP! " .. tostring(state.expLevelBefore or 1) .. " -> " .. tostring(state.expLevelAfter or 1)
    local textYOffset = 8

    if state.weaponFont then
        love.graphics.setFont(state.weaponFont)
        textYOffset = 6
    elseif state.previewFont then
        love.graphics.setFont(state.previewFont)
        textYOffset = 4
    end

    love.graphics.setColor(0.05, 0.1, 0.35, 0.95)
    love.graphics.rectangle("fill", bannerX, bannerY, bannerW, bannerH, 12, 12)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", bannerX, bannerY, bannerW, bannerH, 12, 12)
    love.graphics.setLineWidth(1)

    Utils.drawOutlinedText(bannerText, bannerX, bannerY + textYOffset, bannerW, "center")
end

function ExpBarDraw.draw(state, screenW, screenH)
    if not state.expBarActive then return end
    if not state.expBarImage or not state.expBarBaseQuad or not state.expBarFullFillQuad then return end

    local barScaleX, barScaleY = 2, 1
    local barW, barH = 192 * barScaleX, 64 * barScaleY
    local numberGap = -4
    local numberAreaW = 86
    local numberRightPadding = 16
    local barY = screenH * 0.89 - (barH / 2)
    local panelPaddingX = 20
    local panelPaddingTop = 60
    local panelPaddingBottom = 16
    local barX = (screenW - barW) / 2
    local panelW = barW + panelPaddingX + numberGap + numberAreaW + numberRightPadding
    local panelX = barX - panelPaddingX
    local panelY = barY - panelPaddingTop
    local panelH = barH + panelPaddingTop + panelPaddingBottom
    local numberX = barX + barW + numberGap

    local animProgress = Utils.getExpAnimProgress(state)
    local expAnimEndTime = (state.expBarAnimDelay or 0) + (state.expBarAnimDuration or 1.0)
    local elapsedSinceExpAnimEnd = (state.expBarTimer or 0) - expAnimEndTime
    local canShowLevelUpMenu = state.expLeveledUp
        and state.levelUpTableImage
        and animProgress >= 1
        and elapsedSinceExpAnimEnd >= getLevelUpMenuDelay(state)

    if canShowLevelUpMenu then
        LevelUpMenu.draw(state, screenW, screenH)
        return
    end

    local fillVisibleWidth, displayedExpValue = getFillAndDisplayedExp(state, animProgress, barScaleX)

    if state.expBarBackgroundImage then
        local bgScaleX = panelW / 1000
        local bgScaleY = panelH / 400
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(state.expBarBackgroundImage, panelX - 30, panelY - 140, 0, bgScaleX, bgScaleY)
    end

    drawLevelUpBanner(state, panelX, panelY, panelW)

    love.graphics.setColor(1, 1, 1, 1)
    if fillVisibleWidth > 0 then
        local scissorX, scissorY, scissorW, scissorH = love.graphics.getScissor()
        love.graphics.setScissor(barX, barY, fillVisibleWidth, barH)
        love.graphics.draw(state.expBarImage, state.expBarFullFillQuad, barX, barY, 0, barScaleX, barScaleY)
        if scissorX then
            love.graphics.setScissor(scissorX, scissorY, scissorW, scissorH)
        else
            love.graphics.setScissor()
        end
    end
    love.graphics.draw(state.expBarImage, state.expBarBaseQuad, barX, barY, 0, barScaleX, barScaleY)

    local previousFont = love.graphics.getFont()
    local gainLabelText = "EXP"
    local gainNumberText = tostring(displayedExpValue)
    local textX = panelX + 46
    local textY = panelY + 16

    if state.pixelFont then
        love.graphics.setFont(state.pixelFont)
        Utils.drawOutlinedText(gainLabelText, textX, textY)
        Utils.drawOutlinedText(gainNumberText, numberX, barY + 2, numberAreaW, "right")
    elseif state.previewFont then
        love.graphics.setFont(state.previewFont)
        Utils.drawOutlinedText(gainLabelText, textX, textY)
        Utils.drawOutlinedText(gainNumberText, numberX, barY + 8, numberAreaW, "right")
    elseif state.weaponFont then
        love.graphics.setFont(state.weaponFont)
        Utils.drawOutlinedText(gainLabelText, textX, textY)
        Utils.drawOutlinedText(gainNumberText, numberX, barY + 10, numberAreaW, "right")
    else
        Utils.drawOutlinedText(gainLabelText, textX, textY)
        Utils.drawOutlinedText(gainNumberText, numberX, barY + 10, numberAreaW, "right")
    end

    if previousFont then
        love.graphics.setFont(previousFont)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return ExpBarDraw
