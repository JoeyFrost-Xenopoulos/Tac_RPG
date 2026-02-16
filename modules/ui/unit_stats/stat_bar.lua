-- modules/ui/unit_stats/stat_bar.lua
-- Stat bar rendering module

local Config = require("modules.ui.unit_stats.config")
local Resources = require("modules.ui.unit_stats.resources")

local StatBar = {}

-- Global stat maximums for bar scaling
local STAT_MAX_VALUES = {
    strength = 20,
    magic = 15,
    skill = 20,
    speed = 20,
    luck = 10,
    defense = 15,
    resistance = 10,
    constitution = 20,
    maxMoveRange = 5
}

-- Bar dimensions matching BigBar assets (320x64 total)
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

local function drawBarBase(image, x, y, scale, alpha)
    local imgW, imgH = image:getDimensions()
    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(scale, scale)

    love.graphics.setColor(1, 1, 1, alpha)
    local leftQuad = love.graphics.newQuad(LEFT_X, 0, LEFT_W, BAR_H, imgW, imgH)
    local midQuad = love.graphics.newQuad(MID_X, 0, MID_W, BAR_H, imgW, imgH)
    local rightQuad = love.graphics.newQuad(RIGHT_X, 0, RIGHT_W, BAR_H, imgW, imgH)
    love.graphics.draw(image, leftQuad, 0, 0)
    love.graphics.draw(image, midQuad, MID_DRAW_X, 0, 0, MID_TARGET_W / MID_W, 1)
    love.graphics.draw(image, rightQuad, RIGHT_DRAW_X, 0)
    love.graphics.pop()
end

local function drawBarFill(image, x, y, scale, alpha, fillPercent)
    if fillPercent <= 0 then return end

    local imgW, imgH = image:getDimensions()
    local fillInset = 50  -- Space reserved for base bar frame
    local totalW = (BAR_W - fillInset * 2) * fillPercent
    local leftW = math.min(LEFT_W, totalW)
    local remainingW = math.max(0, totalW - leftW)
    local midW = math.min(MID_TARGET_W, remainingW)
    local rightW = math.max(0, totalW - LEFT_W - MID_TARGET_W)

    love.graphics.push()
    love.graphics.translate(x, y)
    love.graphics.scale(scale, scale)

    love.graphics.setColor(1, 1, 1, alpha)
    local fillStartX = fillInset
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
    love.graphics.pop()
end

function StatBar.draw(x, y, unit, statKey, opacity)
    if not Resources.barBase or not Resources.barFill then return end
    
    -- Get stat value
    local statValue = unit[statKey] or 0
    local maxValue = STAT_MAX_VALUES[statKey] or 10
    local fillPercent = math.min(statValue / maxValue, 1)
    
    -- Calculate scale to fit desired bar width/height
    local scaleX = Config.STATS_BAR_WIDTH / BAR_W
    local scaleY = Config.STATS_BAR_HEIGHT / BAR_H
    local scale = math.min(scaleX, scaleY)  -- Use minimum to maintain aspect ratio
    
    -- Draw base bar
    drawBarBase(Resources.barBase, x, y, scale, opacity)
    
    -- Draw fill bar
    drawBarFill(Resources.barFill, x, y, scale, opacity, fillPercent)
end

return StatBar
