local WeaponSelect = {}

WeaponSelect.visible = false
WeaponSelect.x = 0
WeaponSelect.y = 0
WeaponSelect.width = 350
WeaponSelect.height = 240
WeaponSelect.options = {}
WeaponSelect.cursorTime = 0
WeaponSelect.onSelect = nil
WeaponSelect.onCancel = nil
WeaponSelect.lastHoveredIndex = nil

local ITEM_HEIGHT = 48
local PANEL_PADDING = 26
local TITLE_HEIGHT = 60
local FOOTER_HEIGHT = 34
local CURSOR_OFFSET_X = 34
local CURSOR_BOB_SPEED = 8
local CURSOR_BOB_AMOUNT = 4
local LEFT_MARGIN = 60
local SLICE_SIZE = 64
local MENU_Y_OFFSET = -200
local ITEM_VISUAL_OFFSET = -25
local ITEM_HOVER_HEIGHT = ITEM_HEIGHT
local ICON_Y_OFFSET = -30
local TEXT_Y_OFFSET = -22
local CURSOR_Y_OFFSET = -10

local WEAPON_NAMES = {
    sword = "Heavy Sword",
    sword_test = "Practice Blade",
}

local function prettifyWeaponName(weaponId)
    if not weaponId or weaponId == "" then
        return "Unknown"
    end
    local mapped = WEAPON_NAMES[weaponId]
    if mapped then
        return mapped
    end
    local text = tostring(weaponId):gsub("_", " ")
    return text:sub(1, 1):upper() .. text:sub(2)
end

local function buildOptions(unit)
    local options = {}
    local seen = {}

    if unit and type(unit.weapons) == "table" then
        for _, weapon in ipairs(unit.weapons) do
            local id
            local name
            if type(weapon) == "table" then
                id = weapon.id or weapon.weapon or weapon.name
                name = weapon.name or weapon.label
            else
                id = weapon
            end
            if id and not seen[id] then
                table.insert(options, { id = id, name = name or prettifyWeaponName(id) })
                seen[id] = true
            end
        end
    end

    if #options == 0 and unit and unit.weapon then
        table.insert(options, { id = unit.weapon, name = prettifyWeaponName(unit.weapon) })
    end

    if #options == 0 then
        table.insert(options, { id = "unarmed", name = "Unarmed" })
    end

    if #options == 1 then
        table.insert(options, { id = "sword_test", name = prettifyWeaponName("sword_test") })
    end

    return options
end

function WeaponSelect.load()
    WeaponSelect.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 38)
    WeaponSelect.smallFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 22)
    WeaponSelect.swordIcon = love.graphics.newImage("assets/ui/icons/sword.png")
    WeaponSelect.swordIcon:setFilter("nearest", "nearest")
    WeaponSelect.cursorImage = love.graphics.newImage("assets/ui/cursors/Cursor_02.png")

    WeaponSelect.menuImage = love.graphics.newImage("assets/ui/menu/menu.png")
    WeaponSelect.menuImage:setFilter("nearest", "nearest")
    local imgW, imgH = WeaponSelect.menuImage:getDimensions()
    WeaponSelect.variants = {
        topLeft   = love.graphics.newQuad(0,   0,   105, 105, imgW, imgH),
        topMid    = love.graphics.newQuad(128, 0,   64,  64,  imgW, imgH),
        topRight  = love.graphics.newQuad(256, 0,   64,  64,  imgW, imgH),
        midLeft   = love.graphics.newQuad(0,   128, 105, 105, imgW, imgH),
        midMid    = love.graphics.newQuad(128, 128, 64,  64,  imgW, imgH),
        midRight  = love.graphics.newQuad(256, 128, 64,  64,  imgW, imgH),
        botLeft   = love.graphics.newQuad(0,   256, 105, 105, imgW, imgH),
        botMid    = love.graphics.newQuad(128, 256, 64,  64,  imgW, imgH),
        botRight  = love.graphics.newQuad(256, 256, 64,  64,  imgW, imgH)
    }
end

function WeaponSelect.show(unit, onSelect, onCancel)
    WeaponSelect.options = buildOptions(unit)
    WeaponSelect.onSelect = onSelect
    WeaponSelect.onCancel = onCancel
    WeaponSelect.visible = true
    WeaponSelect.cursorTime = 0
    WeaponSelect.lastHoveredIndex = nil

    local totalHeight = TITLE_HEIGHT + (#WeaponSelect.options * ITEM_HEIGHT) + FOOTER_HEIGHT + PANEL_PADDING
    WeaponSelect.height = math.max(220, totalHeight)

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    WeaponSelect.x = LEFT_MARGIN
    WeaponSelect.y = (screenH - WeaponSelect.height) / 2 + MENU_Y_OFFSET
end

function WeaponSelect.hide()
    WeaponSelect.visible = false
    WeaponSelect.options = {}
    WeaponSelect.onSelect = nil
    WeaponSelect.onCancel = nil
    WeaponSelect.lastHoveredIndex = nil
end

function WeaponSelect.cancel()
    if not WeaponSelect.visible then return end
    local onCancel = WeaponSelect.onCancel
    WeaponSelect.hide()
    if onCancel then
        onCancel()
    end
end

function WeaponSelect.update(dt)
    if not WeaponSelect.visible then return end
    WeaponSelect.cursorTime = WeaponSelect.cursorTime + dt
end

local function getHoveredIndex(mx, my)
    if not WeaponSelect.visible then return nil end

    local listX = WeaponSelect.x + PANEL_PADDING
    local listY = WeaponSelect.y + TITLE_HEIGHT
    local listW = WeaponSelect.width - PANEL_PADDING * 2

    if mx < listX or mx > listX + listW then
        return nil
    end

    for i = 1, #WeaponSelect.options do
        local itemY = listY + (i - 1) * ITEM_HEIGHT + ITEM_VISUAL_OFFSET
        if my >= itemY and my <= itemY + ITEM_HOVER_HEIGHT then
            return i
        end
    end

    return nil
end

function WeaponSelect.isHovered(mx, my)
    if not WeaponSelect.visible then return false end
    return mx >= WeaponSelect.x and mx <= WeaponSelect.x + WeaponSelect.width
        and my >= WeaponSelect.y and my <= WeaponSelect.y + WeaponSelect.height
end

function WeaponSelect.clicked(mx, my)
    if not WeaponSelect.visible then return false end

    local hoveredIndex = getHoveredIndex(mx, my)
    if hoveredIndex then
        local option = WeaponSelect.options[hoveredIndex]
        local onSelect = WeaponSelect.onSelect
        WeaponSelect.hide()
        if onSelect then
            onSelect(option)
        end
        return true
    end

    return WeaponSelect.isHovered(mx, my)
end

function WeaponSelect.draw()
    if not WeaponSelect.visible then return end

    local mx, my = love.mouse.getPosition()
    local hoveredIndex = getHoveredIndex(mx, my)
    if hoveredIndex then
        WeaponSelect.lastHoveredIndex = hoveredIndex
    elseif WeaponSelect.lastHoveredIndex then
        hoveredIndex = WeaponSelect.lastHoveredIndex
    else
        hoveredIndex = #WeaponSelect.options > 0 and 1 or nil
        WeaponSelect.lastHoveredIndex = hoveredIndex
    end

    if WeaponSelect.menuImage and WeaponSelect.variants then
        local v = WeaponSelect.variants
        local x = math.floor(WeaponSelect.x)
        local y = math.floor(WeaponSelect.y)
        local midScaleX = math.max(0, (WeaponSelect.width - SLICE_SIZE * 2) / SLICE_SIZE)
        local midScaleY = math.max(0, (WeaponSelect.height - SLICE_SIZE * 2) / SLICE_SIZE)
        local rightX = x + WeaponSelect.width - SLICE_SIZE
        local bottomY = y + WeaponSelect.height - SLICE_SIZE

        love.graphics.setColor(1, 1, 1, 1)
        -- Top row
        love.graphics.draw(WeaponSelect.menuImage, v.topLeft, x, y)
        love.graphics.draw(WeaponSelect.menuImage, v.topMid, x + SLICE_SIZE, y, 0, midScaleX, 1)
        love.graphics.draw(WeaponSelect.menuImage, v.topRight, rightX, y)

        -- Middle row
        love.graphics.draw(WeaponSelect.menuImage, v.midLeft, x, y + SLICE_SIZE, 0, 1, midScaleY)
        love.graphics.draw(WeaponSelect.menuImage, v.midMid, x + SLICE_SIZE, y + SLICE_SIZE, 0, midScaleX, midScaleY)
        love.graphics.draw(WeaponSelect.menuImage, v.midRight, rightX, y + SLICE_SIZE, 0, 1, midScaleY)

        -- Bottom row
        love.graphics.draw(WeaponSelect.menuImage, v.botLeft, x, bottomY)
        love.graphics.draw(WeaponSelect.menuImage, v.botMid, x + SLICE_SIZE, bottomY, 0, midScaleX, 1)
        love.graphics.draw(WeaponSelect.menuImage, v.botRight, rightX, bottomY)
    else
        love.graphics.setColor(0.08, 0.09, 0.12, 0.95)
        love.graphics.rectangle("fill", WeaponSelect.x, WeaponSelect.y, WeaponSelect.width, WeaponSelect.height, 10, 10)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", WeaponSelect.x, WeaponSelect.y, WeaponSelect.width, WeaponSelect.height, 10, 10)
    end

    local listX = WeaponSelect.x + PANEL_PADDING
    local listY = WeaponSelect.y + TITLE_HEIGHT
    local listW = WeaponSelect.width - PANEL_PADDING * 2

    for i, option in ipairs(WeaponSelect.options) do
        local itemY = listY + (i - 1) * ITEM_HEIGHT
        local isHovered = hoveredIndex == i

        if isHovered then
            love.graphics.setColor(1, 1, 1, 0.12)
            love.graphics.rectangle("fill", listX, itemY + ITEM_VISUAL_OFFSET, listW, ITEM_HOVER_HEIGHT, 6, 6)
        end

        love.graphics.setColor(1, 1, 1, 1)
        if WeaponSelect.swordIcon then
            local iconScale = 0.65
            local iconY = itemY + (ITEM_HEIGHT - WeaponSelect.swordIcon:getHeight() * iconScale) / 2 + ICON_Y_OFFSET
            love.graphics.draw(WeaponSelect.swordIcon, listX + 10, iconY, 0, iconScale, iconScale)
        end

        if isHovered and WeaponSelect.cursorImage then
            local bob = math.sin(WeaponSelect.cursorTime * CURSOR_BOB_SPEED) * CURSOR_BOB_AMOUNT
            local cursorY = itemY + (ITEM_HEIGHT - WeaponSelect.cursorImage:getHeight()) / 2
            love.graphics.draw(WeaponSelect.cursorImage, listX + bob + 22, cursorY + CURSOR_Y_OFFSET, 90)
        end

        if WeaponSelect.font then
            love.graphics.setFont(WeaponSelect.font)
        end
        love.graphics.print(option.name or "Unknown", listX + 70, itemY + TEXT_Y_OFFSET)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return WeaponSelect
