local WeaponSelector = {}

local State = require("modules.ui.weapon_selector.state")
local Input = require("modules.ui.weapon_selector.input")
local Draw = require("modules.ui.weapon_selector.draw")

function WeaponSelector.load()
    State.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 38)
    State.smallFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 30)
    
    -- Load weapon icons
    State.weaponIcons.sword = love.graphics.newImage("assets/ui/icons/sword.png")
    State.weaponIcons.sword:setFilter("nearest", "nearest")
    State.weaponIcons.harpoon = love.graphics.newImage("assets/ui/icons/harpoon.png")
    State.weaponIcons.harpoon:setFilter("nearest", "nearest")
    State.weaponIcons.bow = love.graphics.newImage("assets/ui/icons/bow.png")
    State.weaponIcons.bow:setFilter("nearest", "nearest")
    
    State.cursorImage = love.graphics.newImage("assets/ui/cursors/Cursor_02.png")

    State.menuImage = love.graphics.newImage("assets/ui/menu/menu.png")
    State.menuImage:setFilter("nearest", "nearest")
    local imgW, imgH = State.menuImage:getDimensions()
    State.variants = {
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
