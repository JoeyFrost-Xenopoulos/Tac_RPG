local Helpers = require("modules.combat.battle_helpers")
local Utils = require("modules.combat.draw.progression.utils")

local LevelUpMenu = {}

local LEVEL_UP_STATS_PANEL_W = 480
local LEVEL_UP_STATS_PANEL_H = 360
local LEVEL_UP_HEADER_PANEL_W = 360
local LEVEL_UP_HEADER_PANEL_H = 140
local LEVEL_UP_PANEL_BASE_SIZE = 192

local STAR_EFFECT_FRAME_W = 32
local STAR_EFFECT_FRAME_H = 32
local STAR_EFFECT_FRAMES = 4
local STAR_EFFECT_FRAME_DURATION = 0.12

local ARROW_EFFECT_FRAME_W = 409
local ARROW_EFFECT_FRAME_H = 176
local ARROW_EFFECT_FRAMES = 5
local ARROW_EFFECT_FRAME_DURATION = 0.15

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
    local panelX = math.floor((screenW - panelW) / 2)
    local topPanelY = math.floor((screenH - stackHeight) / 2)
    local headerPanelX = math.floor((screenW - headerPanelW) / 2)
    local statsPanelY = topPanelY + headerPanelH + panelGap

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
    local unitLevel = state.expLevelAfter or (playerUnit and playerUnit.level) or 1

    local headerLabelX = headerPanelX + headerPanelW * 0.13
    local headerValueX = headerPanelX + headerPanelW * 0.70
    local headerTextY = topPanelY + headerPanelH * 0.34
    Utils.drawOutlinedText(tostring(unitName), headerLabelX, headerTextY)
    Utils.drawOutlinedText("LV " .. tostring(unitLevel), headerValueX, headerTextY)

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

    Utils.drawOutlinedText("STR", leftLabelX, row1Y)
    Utils.drawOutlinedText(Utils.formatStatValue(playerUnit and playerUnit.strength), leftValueX, row1Y)
    Utils.drawOutlinedText("MAG", rightLabelX, row1Y)
    Utils.drawOutlinedText(Utils.formatStatValue(playerUnit and playerUnit.magic), rightValueX, row1Y)

    Utils.drawOutlinedText("DEF", leftLabelX, row2Y)
    Utils.drawOutlinedText(Utils.formatStatValue(playerUnit and playerUnit.defense), leftValueX, row2Y)
    Utils.drawOutlinedText("RES", rightLabelX, row2Y)
    Utils.drawOutlinedText(Utils.formatStatValue(playerUnit and playerUnit.resistance), rightValueX, row2Y)

    Utils.drawOutlinedText("LUK", leftLabelX, row3Y)
    Utils.drawOutlinedText(Utils.formatStatValue(playerUnit and playerUnit.luck), leftValueX, row3Y)
    Utils.drawOutlinedText("SKL", rightLabelX, row3Y)
    Utils.drawOutlinedText(Utils.formatStatValue(playerUnit and playerUnit.skill), rightValueX, row3Y)

    Utils.drawOutlinedText("SPD", leftLabelX, row4Y)
    Utils.drawOutlinedText(Utils.formatStatValue(playerUnit and playerUnit.speed), leftValueX, row4Y)
    Utils.drawOutlinedText("CON", rightLabelX, row4Y)
    Utils.drawOutlinedText(Utils.formatStatValue(playerUnit and playerUnit.constitution), rightValueX, row4Y)

    local starScale = 1
    local starOffset = -55
    local arrowScale = 0.5
    local arrowGapX = -120

    for rowIndex = 1, 4 do
        local rowY
        if rowIndex == 1 then
            rowY = row1Y
        elseif rowIndex == 2 then
            rowY = row2Y
        elseif rowIndex == 3 then
            rowY = row3Y
        else
            rowY = row4Y
        end

        local leftArrowX = leftValueX + 70 + arrowGapX
        local rightArrowX = rightValueX + 70 + arrowGapX
        local arrowY = rowY - 28

        if state.levelUpArrow then
            Utils.drawStatAnimation(state, state.levelUpArrow, ARROW_EFFECT_FRAME_W, ARROW_EFFECT_FRAME_H, ARROW_EFFECT_FRAMES, ARROW_EFFECT_FRAME_DURATION, leftArrowX, arrowY, arrowScale)
            Utils.drawStatAnimation(state, state.levelUpArrow, ARROW_EFFECT_FRAME_W, ARROW_EFFECT_FRAME_H, ARROW_EFFECT_FRAMES, ARROW_EFFECT_FRAME_DURATION, rightArrowX, arrowY, arrowScale)
        end

        if state.levelUpStarEffect then
            Utils.drawStatAnimation(state, state.levelUpStarEffect, STAR_EFFECT_FRAME_W, STAR_EFFECT_FRAME_H, STAR_EFFECT_FRAMES, STAR_EFFECT_FRAME_DURATION, leftArrowX - starOffset, arrowY, starScale)
            Utils.drawStatAnimation(state, state.levelUpStarEffect, STAR_EFFECT_FRAME_W, STAR_EFFECT_FRAME_H, STAR_EFFECT_FRAMES, STAR_EFFECT_FRAME_DURATION, rightArrowX - starOffset, arrowY, starScale)
        end
    end

    if previousFont then
        love.graphics.setFont(previousFont)
    end
end

return LevelUpMenu
