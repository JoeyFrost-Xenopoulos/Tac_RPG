local WeaponSelector = {}

local State = require("modules.ui.weapon_selector.state")
local Input = require("modules.ui.weapon_selector.input")
local Draw = require("modules.ui.weapon_selector.draw")

function WeaponSelector.load()
    State.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 38)
    State.smallFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 30)
    
    State.weaponIcons = require("modules.ui.icons").getWeaponIcons()
    
    State.cursorImage = love.graphics.newImage("assets/ui/cursors/Cursor_02.png")

    State.menuImage = love.graphics.newImage("assets/ui/menu/menu.png")
    State.menuImage:setFilter("nearest", "nearest")
    State.variants = require("modules.ui.menu_quads").get(State.menuImage)
end

-- Forward State functions
WeaponSelector.show = State.show
WeaponSelector.hide = State.hide
WeaponSelector.cancel = State.cancel
WeaponSelector.update = State.update

-- Forward Input functions
WeaponSelector.isHovered = Input.isHovered
WeaponSelector.clicked = Input.clicked

-- Forward Draw functions
WeaponSelector.draw = Draw.draw

-- Expose visible state for external checks
function WeaponSelector.isVisible()
    return State.visible
end

-- Expose for backward compatibility with existing code that checks WeaponSelect.visible
setmetatable(WeaponSelector, {
    __index = function(t, k)
        if k == "visible" then
            return State.visible
        end
        return rawget(t, k)
    end
})

return WeaponSelector
