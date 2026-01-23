local Menu = {}

Menu.visible = false
Menu.x = 0
Menu.y = 0
Menu.width = 320
Menu.height = 320

function Menu.load()
    Menu.image = love.graphics.newImage("assets/ui/menu/menu.png")
    local imgW, imgH = Menu.image:getDimensions()

    Menu.variants = {
        {
            topLeft  = love.graphics.newQuad(0,   0,   105, 105, imgW, imgH),
            topMid   = love.graphics.newQuad(128, 0,   64, 64, imgW, imgH),
            topRight = love.graphics.newQuad(256, 0,   64, 64, imgW, imgH),
            midLeft  = love.graphics.newQuad(0,   128, 105, 105, imgW, imgH),
            midMid   = love.graphics.newQuad(128, 128, 64, 64, imgW, imgH),
            midRight = love.graphics.newQuad(256, 128, 64, 64, imgW, imgH),
            botLeft  = love.graphics.newQuad(0,   256, 105, 105, imgW, imgH),
            botMid   = love.graphics.newQuad(128, 256, 64, 64, imgW, imgH),
            botRight = love.graphics.newQuad(256, 256, 64, 64, imgW, imgH)
        }
    }
end

function Menu.show(x, y)
    Menu.x = x
    Menu.y = y
    Menu.visible = true
end

function Menu.hide()
    Menu.visible = false
end

function Menu.draw()
    if not Menu.visible then return end

    local v = Menu.variants[1]

    love.graphics.draw(Menu.image, v.topLeft,  Menu.x, Menu.y)
    love.graphics.draw(Menu.image, v.topMid,   Menu.x + 64, Menu.y)
    love.graphics.draw(Menu.image, v.topRight, Menu.x + 128, Menu.y)

    love.graphics.draw(Menu.image, v.midLeft,  Menu.x, Menu.y + 64)
    love.graphics.draw(Menu.image, v.midMid,   Menu.x + 64, Menu.y + 64)
    love.graphics.draw(Menu.image, v.midRight, Menu.x + 128, Menu.y + 64)

    love.graphics.draw(Menu.image, v.botLeft,  Menu.x, Menu.y + 128)
    love.graphics.draw(Menu.image, v.botMid,   Menu.x + 64, Menu.y + 128)
    love.graphics.draw(Menu.image, v.botRight, Menu.x + 128, Menu.y + 128)
end

return Menu
