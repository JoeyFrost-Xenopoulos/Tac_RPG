local Utils = require("modules.combat.draw.progression.utils")

local LevelUpStatsDraw = {}

local function getStatAnimationElapsed(state)
    local totalStatsAnimDelay = 0.2
    local statStartTime = (state.expBarAnimDelay or 0)
        + math.max(state.expBarAnimDuration or 1.0, 0.001)
        + (state.expBarPostHoldDuration or 0.8)
        + totalStatsAnimDelay
    return math.max(0, (state.expBarTimer or 0) - statStartTime)
end

function LevelUpStatsDraw.draw(state, screenW, screenH)
    if not state.expLeveledUp then return end
    if not state.levelUpTableImage then return end
    if not state.levelUpStatsBefore or not state.levelUpStatsAfter then return end

    if Utils.getExpAnimProgress(state) < 1 then return end

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
    local elapsedSinceStatStart = getStatAnimationElapsed(state)

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

    local bannerText = "LEVEL UP! " .. tostring(state.expLevelBefore or 1) .. " -> " .. tostring(state.expLevelAfter or 1)
    if state.weaponFont then
        love.graphics.setFont(state.weaponFont)
    elseif state.previewFont then
        love.graphics.setFont(state.previewFont)
    end
    Utils.drawOutlinedText(bannerText, bannerX, bannerY + 8, bannerW, "center")

    if previousFont then
        love.graphics.setFont(previousFont)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return LevelUpStatsDraw
