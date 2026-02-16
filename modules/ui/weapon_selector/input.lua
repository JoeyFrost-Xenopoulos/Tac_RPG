local Input = {}
local State = require("modules.ui.weapon_selector.state")
local Config = require("modules.ui.weapon_selector.config")

local function getHoveredIndex(mx, my)
    if not State.visible then return nil end

    local listX = State.x + Config.PANEL_PADDING
    local listY = State.y + Config.TITLE_HEIGHT
    local listW = State.width - Config.PANEL_PADDING * 2

    if mx < listX or mx > listX + listW then
        return nil
    end

    for i = 1, #State.options do
        local itemY = listY + (i - 1) * Config.ITEM_HEIGHT
        local highlightY = itemY + Config.ITEM_VISUAL_OFFSET - 5
        local clickMinY = highlightY
        if i == 1 then
            clickMinY = highlightY - 10
        end
        if my >= clickMinY and my <= highlightY + Config.ITEM_HOVER_HEIGHT then
            return i
        end
    end

    return nil
end

function Input.isHovered(mx, my)
    if not State.visible then return false end
    return mx >= State.x and mx <= State.x + State.width
        and my >= State.y and my <= State.y + State.height
end

function Input.clicked(mx, my)
    if not State.visible then return false end

    local hoveredIndex = getHoveredIndex(mx, my)
    if hoveredIndex then
        local option = State.options[hoveredIndex]
        local onSelect = State.onSelect
        local Effects = require("modules.audio.sound_effects")
        Effects.playConfirm()
        State.hide()
        if onSelect then
            onSelect(option)
        end
        return true
    end

    return Input.isHovered(mx, my)
end

function Input.getHoveredIndex()
    local mx, my = love.mouse.getPosition()
    return getHoveredIndex(mx, my)
end

return Input
