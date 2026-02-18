local ItemSelector = {}

local State = require("modules.ui.item_selector.state")
local Input = require("modules.ui.item_selector.input")
local Draw = require("modules.ui.item_selector.draw")

function ItemSelector.load()
    State.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 38)
    State.smallFont = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 30)
    
    -- Load different icons for different item types
    State.icons = {}
    State.icons.health_potion = love.graphics.newImage("assets/ui/icons/health_pot.png")
    State.icons.health_potion:setFilter("nearest", "nearest")
    State.icons.sword = love.graphics.newImage("assets/ui/icons/sword.png")
    State.icons.sword:setFilter("nearest", "nearest")
    State.icons.harpoon = love.graphics.newImage("assets/ui/icons/harpoon.png")
    State.icons.harpoon:setFilter("nearest", "nearest")
    
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
ItemSelector.show = State.show
ItemSelector.hide = State.hide
ItemSelector.cancel = State.cancel
ItemSelector.update = State.update

-- Forward Input functions
ItemSelector.isHovered = Input.isHovered
ItemSelector.clicked = Input.clicked

-- Forward Draw functions
ItemSelector.draw = Draw.draw

-- Expose visible state for external checks
function ItemSelector.isVisible()
    return State.visible
end

-- Expose for backward compatibility with existing code that checks ItemSelector.visible
setmetatable(ItemSelector, {
    __index = function(t, k)
        if k == "visible" then
            return State.visible
        end
        return rawget(t, k)
    end
})

return ItemSelector
