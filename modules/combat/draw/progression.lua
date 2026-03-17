local ProgressionDraw = {}

local function drawOutlinedText(text, x, y, width, align)
    align = align or "left"
    love.graphics.setColor(0, 0, 0, 1)
    if width then
        love.graphics.printf(text, x - 1, y, width, align)
        love.graphics.printf(text, x + 1, y, width, align)
        love.graphics.printf(text, x, y - 1, width, align)
        love.graphics.printf(text, x, y + 1, width, align)
        love.graphics.setColor(1, 0.8706, 0.2588, 1)
        love.graphics.printf(text, x, y, width, align)
    else
        love.graphics.print(text, x - 1, y)
        love.graphics.print(text, x + 1, y)
        love.graphics.print(text, x, y - 1)
        love.graphics.print(text, x, y + 1)
        love.graphics.setColor(1, 0.8706, 0.2588, 1)
        love.graphics.print(text, x, y)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function ProgressionDraw.drawExpBar(state, screenW, screenH)
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
    local animDelay = state.expBarAnimDelay or 0
    local animDuration = math.max(state.expBarAnimDuration or 1.0, 0.001)
    local animElapsed = math.max(0, (state.expBarTimer or 0) - animDelay)
    local animProgress = math.max(0, math.min(1, animElapsed / animDuration))

    if state.expLeveledUp and state.levelUpTableImage and animProgress >= 1 then return end
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

    if state.expBarBackgroundImage then
        local bgScaleX = panelW / 1000
        local bgScaleY = panelH / 400
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(state.expBarBackgroundImage, panelX - 30, panelY - 140, 0, bgScaleX, bgScaleY)
    end

    if state.expLeveledUp then
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

        drawOutlinedText(bannerText, bannerX, bannerY + textYOffset, bannerW, "center")
    end

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
        drawOutlinedText(gainLabelText, textX, textY)
        drawOutlinedText(gainNumberText, numberX, barY + 2, numberAreaW, "right")
    elseif state.previewFont then
        love.graphics.setFont(state.previewFont)
        drawOutlinedText(gainLabelText, textX, textY)
        drawOutlinedText(gainNumberText, numberX, barY + 8, numberAreaW, "right")
    elseif state.weaponFont then
        love.graphics.setFont(state.weaponFont)
        drawOutlinedText(gainLabelText, textX, textY)
        drawOutlinedText(gainNumberText, numberX, barY + 10, numberAreaW, "right")
    else
        drawOutlinedText(gainLabelText, textX, textY)
        drawOutlinedText(gainNumberText, numberX, barY + 10, numberAreaW, "right")
    end

    if previousFont then
        love.graphics.setFont(previousFont)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function ProgressionDraw.drawLevelUpStats(state, screenW, screenH)
    if not state.expLeveledUp then return end
    if not state.levelUpTableImage then return end
    if not state.levelUpStatsBefore or not state.levelUpStatsAfter then return end

    local animDelay = state.expBarAnimDelay or 0
    local animDuration = math.max(state.expBarAnimDuration or 1.0, 0.001)
    local animElapsed = math.max(0, (state.expBarTimer or 0) - animDelay)
    local animProgress = math.max(0, math.min(1, animElapsed / animDuration))
    if animProgress < 1 then return end

    local tableW, tableH = state.levelUpTableImage:getDimensions()
    local maxTableW = 700
    local maxTableH = 700
    local scale = math.min(maxTableW / tableW, maxTableH / tableH)
    local scaledW = tableW * scale
    local scaledH = tableH * scale

    local tableX = (screenW - scaledW) / 2
    local tableY = (screenH - scaledH) / 2 - 30

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(state.levelUpTableImage, tableX, tableY, 0, scale - 0.1, scale - 0.05)

    local statsList = {
        {name = "HP", key = "maxHealth"},
        {name = "STR", key = "strength"},
        {name = "MAG", key = "magic"},
        {name = "SKL", key = "skill"},
        {name = "SPD", key = "speed"},
        {name = "LCK", key = "luck"},
        {name = "DEF", key = "defense"},
        {name = "RES", key = "resistance"},
        {name = "CON", key = "constitution"},
        {name = "AID", key = "aid"},
    }

    local previousFont = love.graphics.getFont()
    local statFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 28)
    love.graphics.setFont(statFont)

    local startX = tableX + scaledW * 0.12
    local startY = tableY + scaledH * 0.18
    local colWidth = scaledW * 0.20
    local rowHeight = scaledH * 0.065
    local col1X = startX
    local col2X = startX + colWidth

    local statAnimDelay = 0.1
    local statAnimDuration = 0.15
    local totalStatsAnimDelay = 0.2

    local statStartTime = (state.expBarAnimDelay or 0)
        + math.max(state.expBarAnimDuration or 1.0, 0.001)
        + (state.expBarPostHoldDuration or 0.8)
        + totalStatsAnimDelay
    local elapsedSinceStatStart = math.max(0, (state.expBarTimer or 0) - statStartTime)

    for i, stat in ipairs(statsList) do
        local row = i % 5
        if row == 0 then row = 5 end
        local colX = (i > 5) and col2X or col1X
        local yPos = startY + (row - 1) * rowHeight

        local statBefore = state.levelUpStatsBefore[stat.key] or 0
        local statAfter = state.levelUpStatsAfter[stat.key] or 0
        local statGain = statAfter - statBefore

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(stat.name, colX, yPos)

        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.print(tostring(statBefore), colX + scaledW * 0.05, yPos)

        local statStartDelay = (i - 1) * statAnimDelay
        local statAnimStart = statStartDelay
        local statAnimEnd = statStartDelay + statAnimDuration

        local animatedGain = 0

        if elapsedSinceStatStart >= statAnimStart then
            if elapsedSinceStatStart < statAnimEnd then
                local statProgress = (elapsedSinceStatStart - statAnimStart) / statAnimDuration
                animatedGain = statGain * statProgress
            else
                animatedGain = statGain
            end
        end

        if statGain > 0 then
            love.graphics.setColor(0.3, 1, 0.3, 1)
            love.graphics.print("→", colX + scaledW * 0.095, yPos)
            love.graphics.print("+" .. tostring(math.floor(animatedGain + 0.5)), colX + scaledW * 0.115, yPos)
        elseif statGain < 0 then
            love.graphics.setColor(1, 0.3, 0.3, 1)
            love.graphics.print("→", colX + scaledW * 0.095, yPos)
            love.graphics.print(tostring(math.floor(animatedGain + 0.5)), colX + scaledW * 0.115, yPos)
        else
            love.graphics.setColor(0.6, 0.6, 0.6, 1)
            love.graphics.print("=", colX + scaledW * 0.095, yPos)
            love.graphics.print("0", colX + scaledW * 0.115, yPos)
        end
    end

    local bannerW = 400
    local bannerH = 50
    local bannerX = (screenW - bannerW) / 2
    local bannerY = tableY - 70

    love.graphics.setColor(0.05, 0.1, 0.35, 0.95)
    love.graphics.rectangle("fill", bannerX, bannerY, bannerW, bannerH, 12, 12)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", bannerX, bannerY, bannerW, bannerH, 12, 12)
    love.graphics.setLineWidth(1)

    local bannerText = "LEVEL UP! " .. tostring(state.expLevelBefore or 1) .. " → " .. tostring(state.expLevelAfter or 1)
    if state.weaponFont then
        love.graphics.setFont(state.weaponFont)
    elseif state.previewFont then
        love.graphics.setFont(state.previewFont)
    end
    drawOutlinedText(bannerText, bannerX, bannerY + 8, bannerW, "center")

    if previousFont then
        love.graphics.setFont(previousFont)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return ProgressionDraw