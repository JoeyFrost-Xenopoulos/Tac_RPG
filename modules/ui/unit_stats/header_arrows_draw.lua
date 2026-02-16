-- modules/ui/unit_stats/header_arrows_draw.lua
-- Header arrows drawing for unit stats screen

local Config = require("modules.ui.unit_stats.config")
local Resources = require("modules.ui.unit_stats.resources")
local State = require("modules.ui.unit_stats.state")

local HeaderArrowsDraw = {}

function HeaderArrowsDraw.draw(screenW, offset, opacity, isHorizontal)
    if not Resources.arrowImage or not Resources.headerFont then return end
    
    local imgW, imgH = Resources.arrowImage:getDimensions()
    local arrowH = imgH / 2  -- Half height for each arrow
    local scale = Config.ARROW_SIZE / arrowH
    
    -- Calculate header position
    local headerText = "Personal Data"
    love.graphics.setFont(Resources.headerFont)
    local headerW = Resources.headerFont:getWidth(headerText)
    local headerX = (screenW - headerW) / 2 + Config.HEADER_X_OFFSET
    
    local arrowY = Config.HEADER_Y
    if isHorizontal then
        arrowY = Config.HEADER_Y - offset
    else
        arrowY = Config.HEADER_Y + offset
    end
    
    love.graphics.setColor(1, 1, 1, opacity)
    
    -- Apply pendulum animation offset (arrows move in opposite directions)
    local animOffset = State.arrowAnimOffset or 0
    
    -- Left arrow (upper half of image) - moves up when right moves down
    local leftArrowX = headerX + Config.ARROW_LEFT_X_OFFSET
    local leftArrowY = arrowY + Config.ARROW_LEFT_Y_OFFSET + animOffset
    local upQuad = love.graphics.newQuad(0, 0, imgW, arrowH, imgW, imgH)
    love.graphics.draw(Resources.arrowImage, upQuad, leftArrowX, leftArrowY, 0, scale, scale)
    
    -- Right arrow (lower half of image) - moves down when left moves up
    local rightArrowX = headerX + headerW + Config.ARROW_RIGHT_X_OFFSET
    local rightArrowY = arrowY + Config.ARROW_RIGHT_Y_OFFSET - animOffset
    local downQuad = love.graphics.newQuad(0, arrowH, imgW, arrowH, imgW, imgH)
    love.graphics.draw(Resources.arrowImage, downQuad, rightArrowX, rightArrowY, 0, scale, scale)
end

return HeaderArrowsDraw
