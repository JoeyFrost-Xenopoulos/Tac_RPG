-- modules/ui/unit_stats/draw.lua
-- Drawing logic for unit stats screen

local Config = require("modules.ui.unit_stats.config")
local Resources = require("modules.ui.unit_stats.resources")
local State = require("modules.ui.unit_stats.state")
local AvatarDraw = require("modules.ui.unit_stats.avatar_draw")
local NameTypeDraw = require("modules.ui.unit_stats.name_type_draw")
local HPLevelDraw = require("modules.ui.unit_stats.hp_level_draw")
local AnimationDraw = require("modules.ui.unit_stats.animation_draw")
local StatsDraw = require("modules.ui.unit_stats.stats_draw")
local HeaderArrowsDraw = require("modules.ui.unit_stats.header_arrows_draw")

local Draw = {}

local function computeTransitionValues(transitionType)
    if not State.isTransitioning then
        return 0, 1, 0  -- offset, opacity, overlay_opacity
    end

    if transitionType and State.transitionType ~= transitionType then
        return 0, 1, 0  -- offset, opacity, overlay_opacity
    end

    local progress = State.transitionProgress
    local direction = State.transitionDirection

    -- Easing function for smoother transition
    local easeProgress = progress < 0.5 and 2 * progress * progress or 1 - (-2 * progress + 2) ^ 2 / 2

    -- Calculate offset and opacity for the slide/fade effect
    local offset = easeProgress * Config.TRANSITION_SLIDE_DISTANCE * direction
    local opacity = 1 - math.abs(easeProgress * 2 - 1) * 0.6

    -- Black overlay fades in and out (peaks at midpoint)
    local overlayOpacity = math.abs(easeProgress * 2 - 1) * 0.5  -- Peaks at 0.5 opacity

    return offset, opacity, overlayOpacity
end

local function getPanelLayout(screenW, offsetX, offsetY)
    local panelW = math.min(420, math.floor(screenW * 0.35))
    local panelX = screenW - panelW - Config.PANEL_OFFSET_RIGHT + (offsetX or 0)
    local panelY = Config.PANEL_HEIGHT_OFFSET + (offsetY or 0)
    local padding = Config.PANEL_PADDING

    return panelX, panelY, padding
end

local function drawUnitPanel(unit, panelX, panelY, padding, opacity)
    AvatarDraw.draw(unit, panelX, panelY, padding, opacity)

    local nameY = panelY + padding + Config.NAME_Y_OFFSET
    NameTypeDraw.draw(unit, panelX, panelY, padding, nameY, opacity)
    HPLevelDraw.draw(unit, panelX, padding, nameY, opacity)
    AnimationDraw.draw(unit, panelX, padding, nameY, opacity)

    local statsY = nameY + Config.STATS_Y_BASE_OFFSET
    StatsDraw.draw(unit, panelX, padding, nameY, statsY, opacity)
end

function Draw.getTransitionValues()
    return computeTransitionValues()
end

function Draw.getHorizontalTransitionValues()
    return computeTransitionValues("horizontal")
end

function Draw.drawBackground(screenW, screenH)
    local background = State.currentView == "player" and Resources.backgroundPlayer or Resources.backgroundEnemy
    if background then
        local imgW, imgH = background:getDimensions()
        local scaleX = screenW / imgW
        local scaleY = screenH / imgH
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(background, 0, 0, 0, scaleX, scaleY)
    else
        love.graphics.setColor(0.1, 0.2, 0.8, 1)
        love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    end
end

function Draw.drawBackButton(screenW, screenH)
    if Resources.font then
        love.graphics.setFont(Resources.font)
        love.graphics.setColor(1, 1, 1, 1)
        local text = "Backspace to go back"
        local textW = Resources.font:getWidth(text)
        local textH = Resources.font:getHeight()
        love.graphics.print(text, (screenW - textW) / 2, screenH - textH - Config.BACK_TEXT_Y_OFFSET)
    end
end

function Draw.drawHeader(screenW, offset, opacity, isHorizontal)
    offset = offset or 0
    opacity = opacity or 1
    isHorizontal = isHorizontal or false
    if Resources.headerFont then
        love.graphics.setFont(Resources.headerFont)
        love.graphics.setColor(1, 1, 1, opacity)
        local headerText = "Personal Data"
        local headerW = Resources.headerFont:getWidth(headerText)
        if isHorizontal then
            -- For horizontal transitions, offset affects X position
            love.graphics.print(headerText, (screenW - headerW) / 2 + Config.HEADER_X_OFFSET + offset, Config.HEADER_Y)
        else
            -- For vertical transitions, offset affects Y position
            love.graphics.print(headerText, (screenW - headerW) / 2 + Config.HEADER_X_OFFSET, Config.HEADER_Y + offset)
        end
    end
end

function Draw.drawAvatar(unit, panelX, panelY, padding, opacity)
    AvatarDraw.draw(unit, panelX, panelY, padding, opacity)
end

function Draw.drawNameAndType(unit, panelX, panelY, padding, nameY, opacity)
    NameTypeDraw.draw(unit, panelX, panelY, padding, nameY, opacity)
end

function Draw.drawHPAndLevel(unit, panelX, padding, nameY, opacity)
    HPLevelDraw.draw(unit, panelX, padding, nameY, opacity)
end

function Draw.drawAnimation(unit, panelX, padding, nameY, opacity)
    AnimationDraw.draw(unit, panelX, padding, nameY, opacity)
end

function Draw.drawStats(unit, panelX, padding, nameY, statsY, opacity)
    StatsDraw.draw(unit, panelX, padding, nameY, statsY, opacity)
end

function Draw.drawUnitWithOffset(unit, screenW, offset, opacity)
    local panelX, panelY, padding = getPanelLayout(screenW, 0, offset)
    drawUnitPanel(unit, panelX, panelY, padding, opacity)
end

function Draw.drawUnitWithHorizontalOffset(unit, screenW, offset, opacity)
    local panelX, panelY, padding = getPanelLayout(screenW, offset, 0)
    drawUnitPanel(unit, panelX, panelY, padding, opacity)
end

function Draw.drawUnit(unit, screenW)
    if State.transitionType == "horizontal" then
        local offset, opacity, overlayOpacity = Draw.getHorizontalTransitionValues()
        Draw.drawUnitWithHorizontalOffset(unit, screenW, offset, opacity)
    else
        local offset, opacity, overlayOpacity = Draw.getTransitionValues()
        Draw.drawUnitWithOffset(unit, screenW, offset, opacity)
    end
end

local function drawHorizontalTransition(screenW)
    local offset, opacity, overlayOpacity = Draw.getHorizontalTransitionValues()
    Draw.drawHeader(screenW, -offset, opacity, true)
    HeaderArrowsDraw.draw(screenW, -offset, opacity, true)

    if State.isTransitioning then
        -- Get units based on current and previous view
        local prevUnits = State.currentView == "enemy" and State.playerUnits or State.enemyUnits
        local currentUnits = State.getCurrentUnits()
        local prevUnit = prevUnits[State.previousIndex]
        local currentUnit = currentUnits[State.index]

        -- Draw outgoing unit (moves away)
        if prevUnit then
            local outgoingOffset = -State.transitionProgress * Config.TRANSITION_SLIDE_DISTANCE * State.transitionDirection
            local outgoingOpacity = math.abs(State.transitionProgress * 2 - 1) * 0.6 + 0.4
            Draw.drawUnitWithHorizontalOffset(prevUnit, screenW, outgoingOffset, outgoingOpacity)
        end

        -- Draw incoming unit (moves in from opposite direction)
        if currentUnit then
            local incomingOffset = (1 - State.transitionProgress) * Config.TRANSITION_SLIDE_DISTANCE * State.transitionDirection
            local incomingOpacity = math.abs(State.transitionProgress * 2 - 1) * 0.6 + 0.4

            Draw.drawUnitWithHorizontalOffset(currentUnit, screenW, incomingOffset, incomingOpacity)
        end
    else
        -- Normal draw when not transitioning
        local unit = State.getCurrentUnits()[State.index]
        if unit then
            Draw.drawUnitWithHorizontalOffset(unit, screenW, 0, 1)
        end
    end
end

local function drawVerticalTransition(screenW)
    -- Vertical transition (cycling through units)
    local offset, opacity, overlayOpacity = Draw.getTransitionValues()
    Draw.drawHeader(screenW, offset, opacity)
    HeaderArrowsDraw.draw(screenW, offset, opacity, false)

    if State.isTransitioning then
        -- Draw both the outgoing and incoming units during transition
        local units = State.getCurrentUnits()
        local prevUnit = units[State.previousIndex]
        local currentUnit = units[State.index]

        -- Draw incoming unit coming from the opposite direction
        if currentUnit then
            local incomingOffset = -(Config.TRANSITION_SLIDE_DISTANCE * State.transitionDirection) +
                                   (State.transitionProgress * Config.TRANSITION_SLIDE_DISTANCE * State.transitionDirection)
            local incomingOpacity = math.abs(State.transitionProgress * 2 - 1) * 0.6 + 0.4  -- Fades from 0.4 to 1

            Draw.drawUnitWithOffset(currentUnit, screenW, incomingOffset, incomingOpacity)
        end

        -- Draw outgoing unit
        if prevUnit then
            Draw.drawUnit(prevUnit, screenW)
        end
    else
        -- Normal draw when not transitioning
        local unit = State.getCurrentUnits()[State.index]
        if unit then
            Draw.drawUnit(unit, screenW)
        end
    end
end

function Draw.draw()
    if not State.visible then return end

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    Draw.drawBackground(screenW, screenH)
    Draw.drawBackButton(screenW, screenH)
    
    local transitionType = State.transitionType or "vertical"

    if transitionType == "horizontal" then
        drawHorizontalTransition(screenW)
    else
        drawVerticalTransition(screenW)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return Draw
