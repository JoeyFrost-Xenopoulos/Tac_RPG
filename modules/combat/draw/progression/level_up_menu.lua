local Helpers = require("modules.combat.battle_helpers")
local Utils = require("modules.combat.draw.progression.utils")

local LevelUpMenu = {}

local LEVEL_UP_STATS_PANEL_W = 480
local LEVEL_UP_STATS_PANEL_H = 360
local LEVEL_UP_HEADER_PANEL_W = 360
local LEVEL_UP_HEADER_PANEL_H = 140
local LEVEL_UP_PANEL_BASE_SIZE = 192
local LEVEL_VALUE_UPDATE_DELAY = 0.7
local LEVEL_MENU_SLIDE_IN_DURATION = 0.35
local LEVEL_LIGHT_RECT_DURATION = 0.42
local LEVEL_LIGHT_RECT_PAD = 10
local LEVEL_LIGHT_RECT_EXTRA_REACH = 48
local STAR_ANIM_FRAME_W = 100
local STAR_ANIM_FRAME_H = 100
local STAR_ANIM_FRAME_COUNT = 11
local STAR_ANIM_FRAME_DURATION = 0.06
local LEVEL_TO_STATS_DELAY = 0.10
local STAT_ANIM_GAP = 0.08
local STAT_ANIM_OVERLAP = 0.45
local STAT_GAIN_ARROW_SCALE = 0.6
local STAT_GAIN_BOUNCE_DURATION = 0.42
local STAT_GAIN_BOUNCE_SCALE = 0.30
local STAT_GAIN_BOUNCE_Y_OFFSET = 10

local function easeOutCubic(t)
    return 1 - ((1 - t) ^ 3)
end

local function drawLevelLightBridge(menuAnimTime, triggerTime, nameX, nameY, nameText, levelX, levelY, levelText, headerFont)
    local lightStartTime = triggerTime - LEVEL_LIGHT_RECT_DURATION
    if menuAnimTime < lightStartTime or menuAnimTime > triggerTime then
        return
    end

    local progress = (menuAnimTime - lightStartTime) / LEVEL_LIGHT_RECT_DURATION
    progress = math.max(0, math.min(1, progress))
    local pulse = math.sin(progress * math.pi)
    local edgeSoftness = 18 * pulse

    local nameWidth = headerFont:getWidth(nameText)
    local levelWidth = headerFont:getWidth(levelText)
    local textHeight = headerFont:getHeight()

    local beamStartX = nameX
    local targetBeamEndX = levelX - LEVEL_LIGHT_RECT_PAD + levelWidth + edgeSoftness + LEVEL_LIGHT_RECT_EXTRA_REACH
    local beamEndX = beamStartX + (targetBeamEndX - beamStartX) * progress
    local beamWidth = math.max(0, beamEndX - beamStartX)
    if beamWidth <= 0 then
        return
    end

    local beamY = math.min(nameY, levelY) - 3
    local beamH = textHeight + 6

    love.graphics.setColor(0.96, 0.96, 1.00, 0.24 * pulse)
    love.graphics.rectangle("fill", beamStartX, beamY, beamWidth, beamH, 6, 6)

    local coreInset = 6
    local coreWidth = math.max(0, beamWidth - (coreInset * 2))
    local coreHeight = math.max(0, beamH - 6)
    if coreWidth > 0 and coreHeight > 0 then
        love.graphics.setColor(1.00, 1.00, 1.00, 0.40 * pulse)
        love.graphics.rectangle("fill", beamStartX + coreInset, beamY + 3, coreWidth, coreHeight, 5, 5)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

local function getLevelUpPanelQuads(state)
    if state.levelUpPanelQuads then
        return state.levelUpPanelQuads
    end
    if not state.levelUpTableImage then
        return nil
    end

    local imageW, imageH = state.levelUpTableImage:getDimensions()
    state.levelUpPanelQuads = {
        topLeft = love.graphics.newQuad(0, 0, 105, 105, imageW, imageH),
        topMid = love.graphics.newQuad(128, 0, 64, 64, imageW, imageH),
        topRight = love.graphics.newQuad(256, 0, 64, 64, imageW, imageH),
        midLeft = love.graphics.newQuad(0, 128, 105, 105, imageW, imageH),
        midMid = love.graphics.newQuad(128, 128, 64, 64, imageW, imageH),
        midRight = love.graphics.newQuad(256, 128, 64, 64, imageW, imageH),
        botLeft = love.graphics.newQuad(0, 256, 105, 105, imageW, imageH),
        botMid = love.graphics.newQuad(128, 256, 64, 64, imageW, imageH),
        botRight = love.graphics.newQuad(256, 256, 64, 64, imageW, imageH),
    }

    return state.levelUpPanelQuads
end

local function getLevelUpStarQuad(state, frameIndex)
    if not state.levelUpStarAnimImage then
        return nil
    end

    state.levelUpStarAnimQuads = state.levelUpStarAnimQuads or {}
    if state.levelUpStarAnimQuads[frameIndex] then
        return state.levelUpStarAnimQuads[frameIndex]
    end

    local imageW, imageH = state.levelUpStarAnimImage:getDimensions()
    local quadX = frameIndex * STAR_ANIM_FRAME_W
    local quad = love.graphics.newQuad(quadX, 0, STAR_ANIM_FRAME_W, STAR_ANIM_FRAME_H, imageW, imageH)
    state.levelUpStarAnimQuads[frameIndex] = quad
    return quad
end

local function drawStarBurstAtText(state, starAnimElapsed, textX, textY, textValue, font, starScale)
    if not state.levelUpStarAnimImage then
        return
    end

    local starAnimDuration = STAR_ANIM_FRAME_COUNT * STAR_ANIM_FRAME_DURATION
    if starAnimElapsed < 0 or starAnimElapsed > starAnimDuration then
        return
    end

    local frameIndex = math.min(STAR_ANIM_FRAME_COUNT - 1, math.floor(starAnimElapsed / STAR_ANIM_FRAME_DURATION))
    local starQuad = getLevelUpStarQuad(state, frameIndex)
    if not starQuad then
        return
    end

    local textWidth = font:getWidth(textValue)
    local textHeight = font:getHeight()
    local starX = textX + (textWidth * 0.5) - ((STAR_ANIM_FRAME_W * starScale) * 0.5)
    local starY = textY + (textHeight * 0.5) - ((STAR_ANIM_FRAME_H * starScale) * 0.5)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(state.levelUpStarAnimImage, starQuad, starX, starY, 0, starScale, starScale)
end

local function drawStatGainArrow(state, valueX, valueY, valueText, valueFont, triggerElapsed)
    if not state.levelUpArrowImage then
        return
    end

    local bounceT = math.max(0, math.min(1, (triggerElapsed or 0) / STAT_GAIN_BOUNCE_DURATION))
    local bouncePulse = math.sin(bounceT * math.pi)
    local bounceScale = 1 + (STAT_GAIN_BOUNCE_SCALE * bouncePulse)
    local bounceYOffset = -STAT_GAIN_BOUNCE_Y_OFFSET * bouncePulse

    local valueWidth = valueFont:getWidth(tostring(valueText))
    local valueHeight = valueFont:getHeight()
    local arrowW, arrowH = state.levelUpArrowImage:getDimensions()
    local scaledArrowW = arrowW * STAT_GAIN_ARROW_SCALE * bounceScale
    local scaledArrowH = arrowH * STAT_GAIN_ARROW_SCALE * bounceScale
    local arrowX = valueX + valueWidth + 10
    local arrowY = valueY + (valueHeight * 0.5) - (scaledArrowH * 0.5) - 10 + bounceYOffset
    local plusText = "+1"
    local plusY = arrowY + scaledArrowH * 0.1 + bounceYOffset * 0.2

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(state.levelUpArrowImage, arrowX, arrowY, 0, STAT_GAIN_ARROW_SCALE * bounceScale, STAT_GAIN_ARROW_SCALE * bounceScale)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.printf(plusText, arrowX - 1, plusY, scaledArrowW, "center")
    love.graphics.printf(plusText, arrowX + 1, plusY, scaledArrowW, "center")
    love.graphics.printf(plusText, arrowX, plusY - 1, scaledArrowW, "center")
    love.graphics.printf(plusText, arrowX, plusY + 1, scaledArrowW, "center")
    love.graphics.setColor(1.0, 0.831, 0.0, 1.0)
    love.graphics.printf(plusText, arrowX, plusY, scaledArrowW, "center")
    love.graphics.setColor(1, 1, 1, 1)
end

local function drawMenuPanelAt(state, panelX, panelY, panelW, panelH)
    local quads = getLevelUpPanelQuads(state)
    if not quads then return end

    local image = state.levelUpTableImage
    local scaleX = panelW / LEVEL_UP_PANEL_BASE_SIZE
    local scaleY = panelH / LEVEL_UP_PANEL_BASE_SIZE

    love.graphics.setColor(1, 1, 1, 1)

    local x1 = panelX
    local x2 = panelX + (64 * scaleX)
    local x3 = panelX + (128 * scaleX)
    local y1 = panelY
    local y2 = panelY + (64 * scaleY)
    local y3 = panelY + (128 * scaleY)

    love.graphics.draw(image, quads.topLeft, x1, y1, 0, scaleX, scaleY)
    love.graphics.draw(image, quads.topMid, x2, y1, 0, scaleX, scaleY)
    love.graphics.draw(image, quads.topRight, x3, y1, 0, scaleX, scaleY)
    love.graphics.draw(image, quads.midLeft, x1, y2, 0, scaleX, scaleY)
    love.graphics.draw(image, quads.midMid, x2, y2, 0, scaleX, scaleY)
    love.graphics.draw(image, quads.midRight, x3, y2, 0, scaleX, scaleY)
    love.graphics.draw(image, quads.botLeft, x1, y3, 0, scaleX, scaleY)
    love.graphics.draw(image, quads.botMid, x2, y3, 0, scaleX, scaleY)
    love.graphics.draw(image, quads.botRight, x3, y3, 0, scaleX, scaleY)
end

function LevelUpMenu.draw(state, screenW, screenH)
    if not state.levelUpTableImage then return end

    local panelW = LEVEL_UP_STATS_PANEL_W
    local panelH = LEVEL_UP_STATS_PANEL_H
    local headerPanelW = LEVEL_UP_HEADER_PANEL_W
    local headerPanelH = LEVEL_UP_HEADER_PANEL_H
    local panelGap = 10
    local stackHeight = headerPanelH + panelH + panelGap
    local targetPanelX = math.floor((screenW - panelW) / 2)
    local topPanelY = math.floor((screenH - stackHeight) / 2)
    local targetHeaderPanelX = math.floor((screenW - headerPanelW) / 2)
    local statsPanelY = topPanelY + headerPanelH + panelGap

    local menuAnimTime = math.max(0, (state.levelUpMenuTimer or 0) - (state.expBarAnimDelay or 0) - (state.expBarAnimDuration or 0))
    local slideProgress = math.max(0, math.min(1, menuAnimTime / LEVEL_MENU_SLIDE_IN_DURATION))
    local easedSlideProgress = easeOutCubic(slideProgress)
    local startPanelX = -panelW - 40
    local startHeaderPanelX = -headerPanelW - 40
    local panelX = math.floor(startPanelX + (targetPanelX - startPanelX) * easedSlideProgress)
    local headerPanelX = math.floor(startHeaderPanelX + (targetHeaderPanelX - startHeaderPanelX) * easedSlideProgress)

    drawMenuPanelAt(state, headerPanelX, topPanelY, headerPanelW, headerPanelH)
    drawMenuPanelAt(state, panelX, statsPanelY, panelW, panelH)

    local previousFont = love.graphics.getFont()
    if state.levelUpHeaderFont then
        love.graphics.setFont(state.levelUpHeaderFont)
    elseif state.pixelFont then
        love.graphics.setFont(state.pixelFont)
    end

    local playerUnit = Helpers.getPlayerUnit(state.attacker, state.defender)
    local unitName = (playerUnit and playerUnit.name) or "UNIT"
    local previousLevel = state.expLevelBefore or (playerUnit and playerUnit.level) or 1
    local updatedLevel = state.expLevelAfter or previousLevel
    local showUpdatedLevel = menuAnimTime >= LEVEL_VALUE_UPDATE_DELAY
    local displayedLevel = showUpdatedLevel and updatedLevel or previousLevel

    local headerLabelX = headerPanelX + headerPanelW * 0.13
    local headerValueX = headerPanelX + headerPanelW * 0.70
    local headerTextY = topPanelY + headerPanelH * 0.34
    local unitNameText = tostring(unitName)
    Utils.drawOutlinedText(unitNameText, headerLabelX, headerTextY)
    local levelText = "LV " .. tostring(displayedLevel)

    local headerFont = love.graphics.getFont()
    if headerFont then
        drawLevelLightBridge(
            menuAnimTime,
            LEVEL_VALUE_UPDATE_DELAY,
            headerLabelX,
            headerTextY,
            unitNameText,
            headerValueX,
            headerTextY,
            levelText,
            headerFont
        )
    end

    if showUpdatedLevel and state.levelUpStarAnimImage and headerFont then
        local starAnimElapsed = menuAnimTime - LEVEL_VALUE_UPDATE_DELAY
        drawStarBurstAtText(state, starAnimElapsed, headerValueX, headerTextY, levelText, headerFont, 1.2)
    end

    Utils.drawOutlinedText(levelText, headerValueX, headerTextY)

    if showUpdatedLevel and state.levelUpArrowImage then
        local textWidth = love.graphics.getFont():getWidth(levelText)
        local arrowX = headerValueX + textWidth + 10
        local arrowY = headerTextY + 4
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(state.levelUpArrowImage, arrowX, arrowY - 15, 0, 0.8, 0.8)
    end

    if state.levelUpStatsFont then
        love.graphics.setFont(state.levelUpStatsFont)
    elseif state.previewFont then
        love.graphics.setFont(state.previewFont)
    elseif state.weaponFont then
        love.graphics.setFont(state.weaponFont)
    end

    local leftColumnOffset = 18
    local leftLabelX = panelX + panelW * 0.12 + leftColumnOffset
    local leftValueX = panelX + panelW * 0.34 + leftColumnOffset
    local rightLabelX = panelX + panelW * 0.56
    local rightValueX = panelX + panelW * 0.79

    local row1Y = statsPanelY + panelH * 0.18
    local row2Y = statsPanelY + panelH * 0.35
    local row3Y = statsPanelY + panelH * 0.52
    local row4Y = statsPanelY + panelH * 0.69

    local statsBefore = state.levelUpStatsBefore or {}
    local statsAfter = state.levelUpStatsAfter or {}
    local statsFont = love.graphics.getFont()
    local starDuration = STAR_ANIM_FRAME_COUNT * STAR_ANIM_FRAME_DURATION
    local statSequenceStart = LEVEL_VALUE_UPDATE_DELAY + starDuration + LEVEL_TO_STATS_DELAY
    local statStepDuration = math.max(0.05, LEVEL_LIGHT_RECT_DURATION + starDuration + STAT_ANIM_GAP - STAT_ANIM_OVERLAP)

    local statDrawOrder = {
        { label = "STR", key = "strength", labelX = leftLabelX, valueX = leftValueX, y = row1Y },
        { label = "DEF", key = "defense", labelX = leftLabelX, valueX = leftValueX, y = row2Y },
        { label = "LUK", key = "luck", labelX = leftLabelX, valueX = leftValueX, y = row3Y },
        { label = "SPD", key = "speed", labelX = leftLabelX, valueX = leftValueX, y = row4Y },
        { label = "MAG", key = "magic", labelX = rightLabelX, valueX = rightValueX, y = row1Y },
        { label = "RES", key = "resistance", labelX = rightLabelX, valueX = rightValueX, y = row2Y },
        { label = "SKL", key = "skill", labelX = rightLabelX, valueX = rightValueX, y = row3Y },
        { label = "CON", key = "constitution", labelX = rightLabelX, valueX = rightValueX, y = row4Y },
    }

    local animatedStatIndexByKey = {}
    local animatedStatCount = 0
    for _, stat in ipairs(statDrawOrder) do
        local beforeValue = statsBefore[stat.key]
        if beforeValue == nil then
            beforeValue = playerUnit and playerUnit[stat.key] or 0
        end
        local afterValue = statsAfter[stat.key]
        if afterValue == nil then
            afterValue = playerUnit and playerUnit[stat.key] or 0
        end

        if afterValue == beforeValue + 1 then
            animatedStatCount = animatedStatCount + 1
            animatedStatIndexByKey[stat.key] = animatedStatCount
        end
    end

    for _, stat in ipairs(statDrawOrder) do
        local beforeValue = statsBefore[stat.key]
        if beforeValue == nil then
            beforeValue = playerUnit and playerUnit[stat.key] or 0
        end
        local afterValue = statsAfter[stat.key]
        if afterValue == nil then
            afterValue = playerUnit and playerUnit[stat.key] or 0
        end

        local displayedValue = afterValue
        local animIndex = animatedStatIndexByKey[stat.key]
        local statTriggered = false
        local statTriggerElapsed = 0
        if animIndex then
            local statSlotStart = statSequenceStart + ((animIndex - 1) * statStepDuration)
            local statTriggerTime = statSlotStart + LEVEL_LIGHT_RECT_DURATION
            statTriggerElapsed = math.max(0, menuAnimTime - statTriggerTime)
            if menuAnimTime < statTriggerTime then
                displayedValue = beforeValue
            else
                statTriggered = true
            end

            drawLevelLightBridge(
                menuAnimTime,
                statTriggerTime,
                stat.labelX,
                stat.y,
                stat.label,
                stat.valueX,
                stat.y,
                tostring(afterValue),
                statsFont
            )

            if menuAnimTime >= statTriggerTime then
                local statStarElapsed = menuAnimTime - statTriggerTime
                drawStarBurstAtText(
                    state,
                    statStarElapsed,
                    stat.valueX,
                    stat.y,
                    tostring(afterValue),
                    statsFont,
                    0.95
                )
            end
        end

        Utils.drawOutlinedText(stat.label, stat.labelX, stat.y)
        Utils.drawOutlinedText(Utils.formatStatValue(displayedValue), stat.valueX, stat.y)
        if statTriggered then
            drawStatGainArrow(state, stat.valueX, stat.y, displayedValue, statsFont, statTriggerElapsed)
        end
    end

    if previousFont then
        love.graphics.setFont(previousFont)
    end
end

return LevelUpMenu
