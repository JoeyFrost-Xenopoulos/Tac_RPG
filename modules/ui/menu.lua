-- modules/ui/menu.lua
local Menu = {}

Menu.visible = false
Menu.x = 0
Menu.y = 0
Menu.width = 160 -- Made smaller for options
Menu.height = 120
Menu.options = {} -- List of {text, callback}

function Menu.load()
    Menu.image = love.graphics.newImage("assets/ui/menu/menu.png")
    local imgW, imgH = Menu.image:getDimensions()

    Menu.variants = {
        {
            topLeft   = love.graphics.newQuad(0,   0,   105, 105, imgW, imgH),
            topMid    = love.graphics.newQuad(128, 0,   64, 64, imgW, imgH),
            topRight  = love.graphics.newQuad(256, 0,   64, 64, imgW, imgH),
            midLeft   = love.graphics.newQuad(0,   128, 105, 105, imgW, imgH),
            midMid    = love.graphics.newQuad(128, 128, 64, 64, imgW, imgH),
            midRight  = love.graphics.newQuad(256, 128, 64, 64, imgW, imgH),
            botLeft   = love.graphics.newQuad(0,   256, 105, 105, imgW, imgH),
            botMid    = love.graphics.newQuad(128, 256, 64, 64, imgW, imgH),
            botRight  = love.graphics.newQuad(256, 256, 64, 64, imgW, imgH)
        }
    }
    
    -- Font for options
    Menu.font = love.graphics.newFont(16)
end

function Menu.show(x, y, options)
    Menu.x = x
    Menu.y = y
    Menu.options = options or {}
    
    -- Auto calculate height based on options
    Menu.height = 30 + (#Menu.options * 30)
    Menu.visible = true
end

function Menu.hide()
    Menu.visible = false
    Menu.options = {}
end

function Menu.clicked(mx, my)
    if not Menu.visible then return false end
    
    -- Simple AABB check for the menu box
    if mx >= Menu.x and mx <= Menu.x + Menu.width and
       my >= Menu.y and my <= Menu.y + Menu.height then
       
       -- Check which option
       local startY = Menu.y + 15
       for i, opt in ipairs(Menu.options) do
            local optY = startY + (i-1)*30
            if my >= optY and my < optY + 30 then
                if opt.callback then opt.callback() end
                return true
            end
       end
       return true -- Clicked menu but missed text, still consume click
    end
    return false
end

function Menu.draw()
    if not Menu.visible then return end

    local v = Menu.variants[1]
    
    -- Simplified 9-slice drawing for custom size (approximate)
    -- Ideally you would scale the center pieces, but here we just draw background
    -- For simplicity in this snippet, let's draw a solid background with the frame on top
    -- or just the 9-slice pieces at fixed corners. 
    -- (Keeping your original 9-slice draw code but treating it as a background)
    
    -- Draw Background
    love.graphics.setColor(1,1,1,1)
    
    -- Using the user's original draw code, but we might want to scale it to Menu.width/height
    -- For now, let's just draw the original 9-slice at x,y
    love.graphics.draw(Menu.image, v.topLeft,  Menu.x, Menu.y)
    love.graphics.draw(Menu.image, v.topMid,   Menu.x + 64, Menu.y)
    love.graphics.draw(Menu.image, v.topRight, Menu.x + 128, Menu.y)

    love.graphics.draw(Menu.image, v.midLeft,  Menu.x, Menu.y + 64)
    love.graphics.draw(Menu.image, v.midMid,   Menu.x + 64, Menu.y + 64)
    love.graphics.draw(Menu.image, v.midRight, Menu.x + 128, Menu.y + 64)

    love.graphics.draw(Menu.image, v.botLeft,  Menu.x, Menu.y + 128)
    love.graphics.draw(Menu.image, v.botMid,   Menu.x + 64, Menu.y + 128)
    love.graphics.draw(Menu.image, v.botRight, Menu.x + 128, Menu.y + 128)

    -- DRAW OPTIONS
    love.graphics.setFont(Menu.font)
    local startY = Menu.y + 15
    for i, opt in ipairs(Menu.options) do
        local optY = startY + (i-1)*30
        
        -- Highlight on hover?
        local mx, my = love.mouse.getPosition()
        if mx > Menu.x and mx < Menu.x + Menu.width and my > optY and my < optY + 30 then
             love.graphics.setColor(1, 1, 0, 1) -- Yellow hover
        else
             love.graphics.setColor(0, 0, 0, 1) -- Black text
        end
        
        love.graphics.print(opt.text, Menu.x + 20, optY + 5)
    end
    love.graphics.setColor(1,1,1,1)
end

return Menu