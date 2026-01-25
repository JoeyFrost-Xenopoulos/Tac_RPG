-- modules/ui/menu.lua
local Menu = {}

Menu.visible = false
Menu.x = 0
Menu.y = 0
Menu.width = 160
Menu.height = 120
Menu.options = {}

Menu.visible = false
Menu.animating = false
Menu.animationTime = 0 
Menu.animationDuration = 0.3 
Menu.currentHeight = 0

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

    Menu.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 32)
end

function Menu.show(x, y, options)
    Menu.x = x
    Menu.y = y
    Menu.options = options or {}
    Menu.height = 30 + (#Menu.options * 30)
    Menu.currentHeight = 0
    Menu.animationTime = 0
    Menu.animating = true
    Menu.visible = true
end

function Menu.update(dt)
    if Menu.animating then
        Menu.animationTime = Menu.animationTime + dt
        local t = Menu.animationTime / Menu.animationDuration
        if t >= 1 then
            t = 1
            Menu.animating = false
        end
        Menu.currentHeight = Menu.height * (1 - (1 - t)^3)
    else
        Menu.currentHeight = Menu.height
    end
end


function Menu.hide()
    Menu.visible = false
    Menu.options = {}
end

function Menu.clicked(mx, my)
    if not Menu.visible then return false end
    
    if mx >= Menu.x and mx <= Menu.x + Menu.width and
       my >= Menu.y and my <= Menu.y + Menu.height then
       local startY = Menu.y + 15
       for i, opt in ipairs(Menu.options) do
            local optY = startY + (i-1)*30
            if my >= optY and my < optY + 30 then
                if opt.callback then opt.callback() end
                return true
            end
       end
       return true
    end
    return false
end

function Menu.draw()
    if not Menu.visible then return end
    local v = Menu.variants[1]
    love.graphics.setColor(1,1,1,1)    
    local scaleY = Menu.currentHeight / Menu.height

    love.graphics.draw(Menu.image, v.topLeft,  Menu.x, Menu.y)
    love.graphics.draw(Menu.image, v.topMid,   Menu.x + 64, Menu.y)
    love.graphics.draw(Menu.image, v.topRight, Menu.x + 128, Menu.y)

    love.graphics.draw(Menu.image, v.midLeft,  Menu.x, Menu.y + 64 * scaleY, 0, 1, scaleY)
    love.graphics.draw(Menu.image, v.midMid,   Menu.x + 64, Menu.y + 64 * scaleY, 0, 1, scaleY)
    love.graphics.draw(Menu.image, v.midRight, Menu.x + 128, Menu.y + 64 * scaleY, 0, 1, scaleY)

    love.graphics.draw(Menu.image, v.botLeft,  Menu.x, Menu.y + 128 * scaleY, 0, 1, scaleY)
    love.graphics.draw(Menu.image, v.botMid,   Menu.x + 64, Menu.y + 128 * scaleY, 0, 1, scaleY)
    love.graphics.draw(Menu.image, v.botRight, Menu.x + 128, Menu.y + 128 * scaleY, 0, 1, scaleY)

    love.graphics.setFont(Menu.font)
    local startY = Menu.y + 15
    for i, opt in ipairs(Menu.options) do
        local optY = startY + (i-1)*30
        if optY > Menu.y + Menu.currentHeight then break end

        local mx, my = love.mouse.getPosition()
        if mx > Menu.x and mx < Menu.x + Menu.width and my > optY and my < optY + 30 then
             love.graphics.setColor(0, 0, 1, 1)
        else
             love.graphics.setColor(1, 1, 1, 1)
        end
        
        love.graphics.print(opt.text, Menu.x + 40, optY + 15)
    end

    love.graphics.setColor(1,1,1,1)
end

return Menu