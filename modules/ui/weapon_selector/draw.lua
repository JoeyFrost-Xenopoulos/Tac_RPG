local Draw = {}
local State = require("modules.ui.weapon_selector.state")
local Config = require("modules.ui.weapon_selector.config")
local Input = require("modules.ui.weapon_selector.input")

local function drawMenuFrame()
    if not State.menuImage or not State.variants then return end
    
    local v = State.variants
    local x = math.floor(State.x)
    local y = math.floor(State.y)
    local midScaleX = math.max(0, (State.width - Config.SLICE_SIZE * 2) / Config.SLICE_SIZE)
    local midScaleY = math.max(0, (State.height - Config.SLICE_SIZE * 2) / Config.SLICE_SIZE)
    local rightX = x + State.width - Config.SLICE_SIZE
    local bottomY = y + State.height - Config.SLICE_SIZE

    love.graphics.setColor(1, 1, 1, 1)
    -- Top row
    love.graphics.draw(State.menuImage, v.topLeft, x, y)
    love.graphics.draw(State.menuImage, v.topMid, x + Config.SLICE_SIZE, y, 0, midScaleX, 1)
    love.graphics.draw(State.menuImage, v.topRight, rightX, y)

    -- Middle row
    love.graphics.draw(State.menuImage, v.midLeft, x, y + Config.SLICE_SIZE, 0, 1, midScaleY)
    love.graphics.draw(State.menuImage, v.midMid, x + Config.SLICE_SIZE, y + Config.SLICE_SIZE, 0, midScaleX, midScaleY)
    love.graphics.draw(State.menuImage, v.midRight, rightX, y + Config.SLICE_SIZE, 0, 1, midScaleY)

    -- Bottom row
    love.graphics.draw(State.menuImage, v.botLeft, x, bottomY)
    love.graphics.draw(State.menuImage, v.botMid, x + Config.SLICE_SIZE, bottomY, 0, midScaleX, 1)
    love.graphics.draw(State.menuImage, v.botRight, rightX, bottomY)
end

local function drawWeaponItems(hoveredIndex)
    local listX = State.x + Config.PANEL_PADDING
    local listY = State.y + Config.TITLE_HEIGHT
    local listW = State.width - Config.PANEL_PADDING * 2

    for i, option in ipairs(State.options) do
        local itemY = listY + (i - 1) * Config.ITEM_HEIGHT
        local isHovered = hoveredIndex == i

        if isHovered then
            love.graphics.setColor(1, 1, 1, 0.12)
            love.graphics.rectangle("fill", listX, itemY + Config.ITEM_VISUAL_OFFSET, listW, Config.ITEM_HOVER_HEIGHT, 6, 6)
        end

        love.graphics.setColor(1, 1, 1, 1)
        if State.swordIcon then
            local iconScale = 0.65
            local iconY = itemY + (Config.ITEM_HEIGHT - State.swordIcon:getHeight() * iconScale) / 2 + Config.ICON_Y_OFFSET
            love.graphics.draw(State.swordIcon, listX + 10, iconY, 0, iconScale, iconScale)
        end

        if isHovered and State.cursorImage then
            local bob = math.sin(State.cursorTime * Config.CURSOR_BOB_SPEED) * Config.CURSOR_BOB_AMOUNT
            local cursorY = itemY + (Config.ITEM_HEIGHT - State.cursorImage:getHeight()) / 2
            love.graphics.draw(State.cursorImage, listX + bob + 22, cursorY + Config.CURSOR_Y_OFFSET, 90)
        end

        if State.font then
            love.graphics.setFont(State.font)
        end
        love.graphics.print(option.name or "Unknown", listX + 70, itemY + Config.TEXT_Y_OFFSET)
    end
end

function Draw.draw()
    if not State.visible then return end

    local hoveredIndex = Input.getHoveredIndex()
    if hoveredIndex then
        State.lastHoveredIndex = hoveredIndex
    elseif State.lastHoveredIndex then
        hoveredIndex = State.lastHoveredIndex
    else
        hoveredIndex = #State.options > 0 and 1 or nil
        State.lastHoveredIndex = hoveredIndex
    end

    drawMenuFrame()
    drawWeaponItems(hoveredIndex)

    love.graphics.setColor(1, 1, 1, 1)
end

return Draw
