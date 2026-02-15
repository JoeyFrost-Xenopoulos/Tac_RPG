-- modules/ui/unit_stats/draw.lua
-- Drawing logic for unit stats screen

local Config = require("modules.ui.unit_stats.config")
local Resources = require("modules.ui.unit_stats.resources")
local State = require("modules.ui.unit_stats.state")

local Draw = {}

function Draw.getTransitionValues()
    if not State.isTransitioning then
        return 0, 1, 0  -- offset, opacity, overlay_opacity
    end
    
    local progress = State.transitionProgress
    local direction = State.transitionDirection
    
    -- Easing function for smoother transition
    local easeProgress = progress < 0.5 and 2 * progress * progress or 1 - (-2 * progress + 2) ^ 2 / 2
    
    -- Calculate offset and opacity for the slide/fade effect
    local offset = easeProgress * Config.TRANSITION_SLIDE_DISTANCE * direction
    local opacity = 1 - math.abs(easeProgress * 2 - 1) * 0.6  -- Fades to 0.4 at midpoint
    
    -- Black overlay fades in and out (peaks at midpoint)
    local overlayOpacity = math.abs(easeProgress * 2 - 1) * 0.5  -- Peaks at 0.5 opacity
    
    return offset, opacity, overlayOpacity
end

function Draw.drawBackground(screenW, screenH)
    if Resources.background then
        local imgW, imgH = Resources.background:getDimensions()
        local scaleX = screenW / imgW
        local scaleY = screenH / imgH
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Resources.background, 0, 0, 0, scaleX, scaleY)
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

function Draw.drawHeader(screenW)
    if Resources.headerFont then
        love.graphics.setFont(Resources.headerFont)
        love.graphics.setColor(1, 1, 1, 1)
        local headerText = "Personal Data"
        local headerW = Resources.headerFont:getWidth(headerText)
        love.graphics.print(headerText, (screenW - headerW) / 2 + Config.HEADER_X_OFFSET, Config.HEADER_Y)
    end
end

function Draw.drawAvatar(unit, panelX, panelY, padding, opacity)
    if unit.avatar then
        local maxPortrait = Config.AVATAR_SIZE
        local scale = math.min(maxPortrait / unit.avatar:getWidth(), maxPortrait / unit.avatar:getHeight())
        love.graphics.setColor(1, 1, 1, opacity)
        love.graphics.draw(unit.avatar, panelX + padding + Config.AVATAR_X_OFFSET, panelY + padding + Config.AVATAR_Y_OFFSET, 0, scale * Config.AVATAR_SCALE, scale * Config.AVATAR_SCALE)
    end
end

function Draw.drawNameAndType(unit, panelX, panelY, padding, nameY, opacity)
    if Resources.font then
        love.graphics.setFont(Resources.font)
        love.graphics.setColor(1, 1, 1, opacity)
        love.graphics.print(unit.type or "Unknown", panelX + padding + Config.TYPE_X_OFFSET, nameY + Config.TYPE_Y_OFFSET, 0)
        love.graphics.print(unit.name or "Unknown", panelX + padding + Config.TYPE_X_OFFSET, nameY + Config.TYPE_Y_OFFSET + Config.NAME_Y_OFFSET_FROM_TYPE, 0)
    end
end

function Draw.drawHPAndLevel(unit, panelX, padding, nameY, opacity)
    if Resources.smallFont then
        love.graphics.setFont(Resources.smallFont)
        love.graphics.setColor(1, 1, 1, opacity)
        local hpText = string.format("HP: %d/%d", unit.health or 0, unit.maxHealth or 0)
        love.graphics.print(hpText, panelX + padding + Config.HP_X_OFFSET, nameY + Config.HP_Y_OFFSET, 0)
        love.graphics.print("Lvl: --", panelX + padding + Config.HP_X_OFFSET, nameY + Config.LEVEL_Y_OFFSET, 0)
    end
end

function Draw.drawAnimation(unit, panelX, padding, nameY, opacity)
    if unit.animations and unit.animations.idle then
        local anim = unit.animations.idle
        if anim.quads and anim.quads[State.animFrame] and anim.img then
            local quad = anim.quads[State.animFrame]
            local animScale = 1
            local animX = panelX + padding + Config.ANIM_X_OFFSET
            local animY = nameY + Config.ANIM_Y_OFFSET
            love.graphics.setColor(1, 1, 1, opacity)
            love.graphics.draw(anim.img, quad, animX + Config.ANIM_DRAW_X_OFFSET, animY + Config.ANIM_DRAW_Y_OFFSET, 0, animScale, animScale)
        end
    end
end

function Draw.drawStats(unit, panelX, padding, nameY, statsY, opacity)
    if Resources.statsFont then
        love.graphics.setFont(Resources.statsFont)
        love.graphics.setColor(1, 1, 1, opacity)
        local leftColumn = {
            { label = "Str", value = unit.strength and tostring(unit.strength) or "--" },
            { label = "Mag", value = unit.magic and tostring(unit.magic) or "--" },
            { label = "Skill", value = unit.skill and tostring(unit.skill) or "--" },
            { label = "Spd", value = unit.speed and tostring(unit.speed) or "--" },
            { label = "Con", value = unit.constitution and tostring(unit.constitution) or "--" }
        }
        local rightColumn = {
            { label = "Move", value = tostring(unit.maxMoveRange or 0) },
            { label = "Luck", value = unit.luck and tostring(unit.luck) or "--" },
            { label = "Def", value = unit.defense and tostring(unit.defense) or "--" },
            { label = "Res", value = unit.resistance and tostring(unit.resistance) or "--" },
            { label = "Aid", value = "--" }
        }
        
        local statsX = panelX + padding
        
        -- Draw left column
        for i, stat in ipairs(leftColumn) do
            local lineY = statsY + (i - 1) * Config.STATS_LINE_HEIGHT
            love.graphics.print(stat.label .. ":", statsX + Config.STATS_LABEL_X_OFFSET, lineY + Config.STATS_Y_DRAW_OFFSET)
            love.graphics.print(stat.value, statsX + Config.STATS_VALUE_X_OFFSET, lineY + Config.STATS_Y_DRAW_OFFSET)
        end
        
        -- Draw right column
        local rightX = statsX + Config.STATS_COLUMN_GAP
        for i, stat in ipairs(rightColumn) do
            local lineY = statsY + (i - 1) * Config.STATS_LINE_HEIGHT
            love.graphics.print(stat.label .. ":", rightX + Config.STATS_LABEL_X_OFFSET, lineY + Config.STATS_Y_DRAW_OFFSET)
            love.graphics.print(stat.value, rightX + Config.STATS_VALUE_X_OFFSET, lineY + Config.STATS_Y_DRAW_OFFSET)
        end
    end
end

function Draw.drawUnitWithOffset(unit, screenW, offset, opacity)
    local panelW = math.min(420, math.floor(screenW * 0.35))
    local panelX = screenW - panelW - Config.PANEL_OFFSET_RIGHT
    local panelY = Config.PANEL_HEIGHT_OFFSET + offset
    local padding = Config.PANEL_PADDING

    Draw.drawAvatar(unit, panelX, panelY, padding, opacity)

    local nameY = panelY + padding + Config.NAME_Y_OFFSET
    Draw.drawNameAndType(unit, panelX, panelY, padding, nameY, opacity)
    Draw.drawHPAndLevel(unit, panelX, padding, nameY, opacity)
    Draw.drawAnimation(unit, panelX, padding, nameY, opacity)

    local statsY = nameY + Config.STATS_Y_BASE_OFFSET
    Draw.drawStats(unit, panelX, padding, nameY, statsY, opacity)
end

function Draw.drawUnit(unit, screenW)
    local offset, opacity, overlayOpacity = Draw.getTransitionValues()
    
    local panelW = math.min(420, math.floor(screenW * 0.35))
    local panelX = screenW - panelW - Config.PANEL_OFFSET_RIGHT
    local panelY = Config.PANEL_HEIGHT_OFFSET + offset  -- Apply vertical offset from transition
    local padding = Config.PANEL_PADDING

    Draw.drawAvatar(unit, panelX, panelY, padding, opacity)

    local nameY = panelY + padding + Config.NAME_Y_OFFSET
    Draw.drawNameAndType(unit, panelX, panelY, padding, nameY, opacity)
    Draw.drawHPAndLevel(unit, panelX, padding, nameY, opacity)
    Draw.drawAnimation(unit, panelX, padding, nameY, opacity)

    local statsY = nameY + Config.STATS_Y_BASE_OFFSET
    Draw.drawStats(unit, panelX, padding, nameY, statsY, opacity)
end

function Draw.draw()
    if not State.visible then return end

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    Draw.drawBackground(screenW, screenH)
    Draw.drawBackButton(screenW, screenH)
    Draw.drawHeader(screenW)

    if State.isTransitioning then
        -- Draw both the outgoing and incoming units during transition
        local prevUnit = State.units[State.previousIndex]
        local currentUnit = State.units[State.index]
        
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
        local unit = State.units[State.index]
        if unit then
            Draw.drawUnit(unit, screenW)
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return Draw
