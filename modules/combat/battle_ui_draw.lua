-- modules/combat/battle_ui_draw.lua
local Helpers = require("modules.combat.battle_helpers")

local UiDraw = {}

local BAR_W = 320
local BAR_H = 64
local LEFT_W = 64
local MID_W = 64
local RIGHT_W = 64
local LEFT_X = 0
local MID_X = 128
local RIGHT_X = 256
local MID_TARGET_W = BAR_W - LEFT_W - RIGHT_W
local MID_DRAW_X = LEFT_W
local RIGHT_DRAW_X = LEFT_W + MID_TARGET_W
local BAR_MARGIN = 40
local BAR_BOTTOM_MARGIN = 30
local BAR_CENTER_OFFSET = 30
local FILL_INSET = 50
local FILL_START_OFFSET = 0
local HEALTH_TEXT_OFFSET_X = -20
local HEALTH_TEXT_OFFSET_Y = 15

local function lerp(startValue, endValue, t)
    return startValue + (endValue - startValue) * t
end

local function getFillPercent(unit)
    if unit and unit.maxHealth and unit.maxHealth > 0 then
        return Helpers.clamp(unit.health / unit.maxHealth, 0, 1)
    end
    return 1
end

local function drawBarBase(image, x, y, scale, alpha, mirror)
    local imgW, imgH = image:getDimensions()
    love.graphics.push()
    if mirror then
        love.graphics.translate(x + BAR_W * scale, y)
        love.graphics.scale(-scale, scale)
    else
        love.graphics.translate(x, y)
        love.graphics.scale(scale, scale)
    end

    love.graphics.setColor(1, 1, 1, alpha)
    local leftQuad = love.graphics.newQuad(LEFT_X, 0, LEFT_W, BAR_H, imgW, imgH)
    local midQuad = love.graphics.newQuad(MID_X, 0, MID_W, BAR_H, imgW, imgH)
    local rightQuad = love.graphics.newQuad(RIGHT_X, 0, RIGHT_W, BAR_H, imgW, imgH)
    love.graphics.draw(image, leftQuad, 0, 0)
    love.graphics.draw(image, midQuad, MID_DRAW_X, 0, 0, MID_TARGET_W / MID_W, 1)
    love.graphics.draw(image, rightQuad, RIGHT_DRAW_X, 0)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end

local function drawBarFill(image, x, y, scale, alpha, mirror, fillPercent)
    if fillPercent <= 0 then return end

    local imgW, imgH = image:getDimensions()
    local totalW = (BAR_W - FILL_INSET * 2) * fillPercent
    local leftW = math.min(LEFT_W, totalW)
    local remainingW = math.max(0, totalW - leftW)
    local midW = math.min(MID_TARGET_W, remainingW)
    local rightW = math.max(0, totalW - LEFT_W - MID_TARGET_W)

    love.graphics.push()
    if mirror then
        love.graphics.translate(x + BAR_W * scale, y)
        love.graphics.scale(-scale, scale)
    else
        love.graphics.translate(x, y)
        love.graphics.scale(scale, scale)
    end

    love.graphics.setColor(1, 1, 1, alpha)
    local fillStartX = FILL_INSET + FILL_START_OFFSET
    if leftW > 0 then
        local leftQuad = love.graphics.newQuad(LEFT_X, 0, leftW, BAR_H, imgW, imgH)
        love.graphics.draw(image, leftQuad, fillStartX, 0)
    end
    if midW > 0 then
        local midQuad = love.graphics.newQuad(MID_X, 0, MID_W, BAR_H, imgW, imgH)
        love.graphics.draw(image, midQuad, fillStartX + MID_DRAW_X, 0, 0, midW / MID_W, 1)
    end
    if rightW > 0 then
        local rightQuad = love.graphics.newQuad(RIGHT_X, 0, rightW, BAR_H, imgW, imgH)
        love.graphics.draw(image, rightQuad, fillStartX + RIGHT_DRAW_X, 0)
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end

function UiDraw.drawBigBar(state, screenW, screenH, progress, shakeX, shakeY)
    if not state.bigBarBaseImage or not state.bigBarFillImage then return end

    local playerUnit = Helpers.getPlayerUnit(state.attacker, state.defender)
    local enemyUnit = Helpers.getEnemyUnit(state.attacker, state.defender)

    shakeX = shakeX or 0
    shakeY = shakeY or 0

    local scale = 1
    local alpha = 1
    local offsetX = 0
    local offsetY = 0
    if progress ~= nil then
        progress = Helpers.clamp(progress, 0, 1)
        scale = 0.9 + 0.1 * progress
        alpha = progress
        offsetX = (1 - progress) * -20
        offsetY = (1 - progress) * 30
    end

    local baseY = screenH - BAR_H * scale - BAR_BOTTOM_MARGIN + BAR_CENTER_OFFSET + offsetY + shakeY

    if enemyUnit then
        local leftX = BAR_MARGIN + offsetX - 10 + shakeX
        local enemyDisplayHealth = state.defenderHealthDisplay or enemyUnit.health
        local fillPercent = enemyUnit.maxHealth and enemyUnit.maxHealth > 0
            and Helpers.clamp(enemyDisplayHealth / enemyUnit.maxHealth, 0, 1) or 1
            drawBarBase(state.bigBarBaseImage, leftX, baseY, scale, alpha, false)
            drawBarFill(state.bigBarFillImage, leftX, baseY, scale, alpha, false, fillPercent)
        
        -- Draw enemy health number
        if state.pixelFont and enemyUnit.health then
                local displayHealth = enemyDisplayHealth or enemyUnit.health
            love.graphics.setFont(state.pixelFont)
            love.graphics.setColor(1, 1, 1, alpha)
            love.graphics.print(tostring(math.max(0, math.floor(displayHealth + 0.5))), leftX + HEALTH_TEXT_OFFSET_X, baseY + HEALTH_TEXT_OFFSET_Y)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    if playerUnit then
        local rightX = screenW - BAR_W * scale - (BAR_MARGIN + 10) - offsetX - 60 + shakeX
        local playerDisplayHealth = state.playerHealthDisplay or playerUnit.health
        local fillPercent = playerUnit.maxHealth and playerUnit.maxHealth > 0
            and Helpers.clamp(playerDisplayHealth / playerUnit.maxHealth, 0, 1) or 1
            drawBarBase(state.bigBarBaseImage, rightX, baseY, scale, alpha, true)
            drawBarFill(state.bigBarFillImage, rightX, baseY, scale, alpha, false, fillPercent)
        
        -- Draw player health number
        if state.pixelFont and playerUnit.health then
                local displayHealth = playerDisplayHealth or playerUnit.health
            love.graphics.setFont(state.pixelFont)
            love.graphics.setColor(1, 1, 1, alpha)
            love.graphics.print(tostring(math.max(0, math.floor(displayHealth + 0.5))), rightX + HEALTH_TEXT_OFFSET_X, baseY + HEALTH_TEXT_OFFSET_Y)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

return UiDraw
