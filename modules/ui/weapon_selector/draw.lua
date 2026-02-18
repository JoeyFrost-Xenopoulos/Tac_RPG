local Draw = {}
local State = require("modules.ui.weapon_selector.state")
local Config = require("modules.ui.weapon_selector.config")
local Input = require("modules.ui.weapon_selector.input")

local function drawMenuFrameAt(x, y, width, height)
    if not State.menuImage or not State.variants then return end

    local v = State.variants
    x = math.floor(x)
    y = math.floor(y)
    local midScaleX = math.max(0, (width - Config.SLICE_SIZE * 2) / Config.SLICE_SIZE)
    local midScaleY = math.max(0, (height - Config.SLICE_SIZE * 2) / Config.SLICE_SIZE)
    local rightX = x + width - Config.SLICE_SIZE
    local bottomY = y + height - Config.SLICE_SIZE

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

local function drawMenuFrame()
    drawMenuFrameAt(State.x, State.y, State.width, State.height)
end

local function drawUnitPanel()
    if not State.unit then return end
    if not State.unit.avatar then return end

    local screenW = love.graphics.getWidth()
    local panelW = Config.RIGHT_PANEL_WIDTH
    local panelX = screenW - panelW - Config.RIGHT_MARGIN
    local panelY = State.y
    local avatarPanelH = Config.AVATAR_PANEL_HEIGHT
    local menuPanelH = Config.RIGHT_MENU_HEIGHT
    local gap = Config.RIGHT_PANEL_GAP

    drawMenuFrameAt(panelX, panelY, panelW, avatarPanelH)
    drawMenuFrameAt(panelX, panelY + avatarPanelH + gap, panelW, menuPanelH)

    local avatar = State.unit.avatar
    local padding = Config.RIGHT_PANEL_PADDING
    local availW = panelW - padding * 2
    local availH = avatarPanelH - padding * 2
    local scale = math.min(availW / avatar:getWidth(), availH / avatar:getHeight())
    local avatarX = panelX + (panelW - avatar:getWidth() * scale) / 2
    local avatarY = panelY + (avatarPanelH - avatar:getHeight() * scale) / 2
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(avatar, avatarX, avatarY, 0, scale, scale)

    if State.smallFont or State.font then
        local stats = {
            { label = "Atk", value = "--" },
            { label = "Crit", value = "--" },
            { label = "Hit", value = "--" },
            { label = "Avoid", value = "--" }
        }
        local statFont = State.smallFont or State.font
        love.graphics.setFont(statFont)
        local padding = Config.RIGHT_PANEL_PADDING
        local startX = panelX + padding
        local startY = panelY + avatarPanelH + gap + padding
        local innerW = panelW - padding * 2 - 50
        local innerH = menuPanelH - padding * 2
        local colGap = 6
        local colW = (innerW - colGap) / 2
        local rowH = innerH / 2

        for i, stat in ipairs(stats) do
            local col = (i - 1) % 2
            local row = math.floor((i - 1) / 2)
            local labelText = stat.label .. ":"
            local valueText = stat.value
            local cellX = startX + col * (colW + colGap)
            local textY = startY + row * rowH + (rowH - statFont:getHeight()) / 2
            local valueW = statFont:getWidth(valueText)
            local valueX = cellX + colW - valueW
            love.graphics.print(labelText, cellX + 20, textY)
            love.graphics.print(valueText, valueX + 20, textY)
        end
    end
end

local function drawWeaponItems(hoveredIndex)
    local listX = State.x + Config.PANEL_PADDING
    local listY = State.y + Config.TITLE_HEIGHT
    local listW = State.width - Config.PANEL_PADDING * 2

    for i, option in ipairs(State.options) do
        local itemY = listY + (i - 1) * Config.ITEM_HEIGHT
        local isHovered = hoveredIndex == i
        local isDisabled = option.inRange == false

        if isHovered and not isDisabled then
            love.graphics.setColor(1, 1, 1, 0.12)
            love.graphics.rectangle("fill", listX, itemY + Config.ITEM_VISUAL_OFFSET - 5, listW, Config.ITEM_HOVER_HEIGHT, 6, 6)
        end

        -- Use grey color if weapon is out of range
        if isDisabled then
            love.graphics.setColor(0.5, 0.5, 0.5, 0.7)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        
        -- Select the appropriate icon based on weapon type
        local icon = State.weaponIcons[option.id] or State.weaponIcons.sword
        if icon then
            local iconScale = 0.65
            local iconY = itemY + (Config.ITEM_HEIGHT - icon:getHeight() * iconScale) / 2 + Config.ICON_Y_OFFSET
            love.graphics.draw(icon, listX + 10, iconY, 0, iconScale, iconScale)
        end

        if isHovered and not isDisabled and State.cursorImage then
            local bob = math.sin(State.cursorTime * Config.CURSOR_BOB_SPEED) * Config.CURSOR_BOB_AMOUNT
            local cursorY = itemY + (Config.ITEM_HEIGHT - State.cursorImage:getHeight()) / 2
            love.graphics.draw(State.cursorImage, listX + bob + 22, cursorY + Config.CURSOR_Y_OFFSET, 90)
        end

        if State.font then
            love.graphics.setFont(State.font)
        end
        
        local weaponText = option.name or "Unknown"
        if isDisabled then
            weaponText = weaponText .. " (out of range)"
            love.graphics.setColor(0.5, 0.5, 0.5, 0.7)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        
        love.graphics.print(weaponText, listX + 70, itemY + Config.TEXT_Y_OFFSET)
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
    drawUnitPanel()

    love.graphics.setColor(1, 1, 1, 1)
end

return Draw
