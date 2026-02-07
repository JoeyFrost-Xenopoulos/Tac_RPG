local State = {}

State.visible = false
State.x = 0
State.y = 0
State.width = 350
State.height = 240
State.options = {}
State.cursorTime = 0
State.onSelect = nil
State.onCancel = nil
State.lastHoveredIndex = nil

State.font = nil
State.smallFont = nil
State.swordIcon = nil
State.cursorImage = nil
State.menuImage = nil
State.variants = {}

function State.show(unit, onSelect, onCancel)
    local Options = require("modules.ui.weapon_selector.options")
    local Config = require("modules.ui.weapon_selector.config")
    
    State.options = Options.buildOptions(unit)
    State.onSelect = onSelect
    State.onCancel = onCancel
    State.visible = true
    State.cursorTime = 0
    State.lastHoveredIndex = nil

    local totalHeight = Config.TITLE_HEIGHT + (#State.options * Config.ITEM_HEIGHT) + Config.FOOTER_HEIGHT + Config.PANEL_PADDING
    State.height = math.max(220, totalHeight)

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    State.x = Config.LEFT_MARGIN
    State.y = (screenH - State.height) / 2 + Config.MENU_Y_OFFSET
end

function State.hide()
    State.visible = false
    State.options = {}
    State.onSelect = nil
    State.onCancel = nil
    State.lastHoveredIndex = nil
end

function State.cancel()
    if not State.visible then return end
    local onCancel = State.onCancel
    State.hide()
    if onCancel then
        onCancel()
    end
end

function State.update(dt)
    if not State.visible then return end
    State.cursorTime = State.cursorTime + dt
end

return State
