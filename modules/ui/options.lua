local Options = {}

Options.visible = false
Options.video = nil
Options.menuImage = nil
Options.scaleX = 0.85
Options.scaleY = 0.85

function Options.load()
    Options.menuImage = love.graphics.newImage("assets/ui/menu/options_menu.png")
    local imgW, imgH = Options.menuImage:getDimensions()

    Options.variants = {
        {
            topLeft   = love.graphics.newQuad(0,   0,   308, 310, imgW, imgH),
            topMid    = love.graphics.newQuad(462, 0,   154, 310, imgW, imgH),
            topRight  = love.graphics.newQuad(768, 0,   204, 310, imgW, imgH),
            
            midLeft   = love.graphics.newQuad(0,   462, 308, 310, imgW, imgH),
            midMid    = love.graphics.newQuad(462, 462, 154, 310, imgW, imgH),
            midRight  = love.graphics.newQuad(768, 462, 204, 310, imgW, imgH),

            botLeft   = love.graphics.newQuad(0,   768, 308, 310, imgW, imgH),
            botMid    = love.graphics.newQuad(462, 768, 154, 310, imgW, imgH),
            botRight  = love.graphics.newQuad(768, 768, 204, 310, imgW, imgH)
        }
    }
end

function Options.show()
    if not Options.video then
        Options.video = love.graphics.newVideo("assets/backgrounds/options_background.ogv")
    end
    if Options.video then
        Options.video:play()
    end
    Options.visible = true
end

function Options.hide()
    if Options.video then
        Options.video:pause()
    end
    Options.visible = false
end

function Options.update(dt)
    if not Options.visible or not Options.video then return end
    if not Options.video:isPlaying() then
        Options.video:rewind()
        Options.video:play()
    end
end

function Options.draw()
    if not Options.visible then return end
    if not Options.video then return end

    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()

    local vidW, vidH = Options.video:getDimensions()
    if vidW == 0 or vidH == 0 then
        love.graphics.draw(Options.video, 0, 0)
        return
    end

    local sx = screenW / vidW
    local sy = screenH / vidH
    love.graphics.draw(Options.video, 0, 0, 0, sx, sy)

    if Options.menuImage and Options.variants then
        
        local v = Options.variants[1]
        local imgW, imgH = Options.menuImage:getDimensions()        
        local scaledW = imgW * Options.scaleX
        local scaledH = imgH * Options.scaleY       
        local x = (screenW - scaledW) / 2
        local y = (screenH - scaledH) / 2

        love.graphics.setColor(1, 1, 1, 1)
        
        -- Top row)
        love.graphics.draw(Options.menuImage, v.topLeft,  x, y, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.topMid,   x + 306 * Options.scaleX, y, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.topRight, x + 456 * Options.scaleX, y, 0, Options.scaleX, Options.scaleY)

        -- Middle row
        love.graphics.draw(Options.menuImage, v.midLeft,  x, y + 306 * Options.scaleY, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.midMid,   x + 306 * Options.scaleX, y + 306 * Options.scaleY, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.midRight, x + 456 * Options.scaleX, y + 306 * Options.scaleY, 0, Options.scaleX, Options.scaleY)

        -- Bottom row
        love.graphics.draw(Options.menuImage, v.botLeft,  x, y + 456 * Options.scaleY, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.botMid,   x + 306 * Options.scaleX, y + 456 * Options.scaleY, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.botRight, x + 456 * Options.scaleX, y + 456 * Options.scaleY, 0, Options.scaleX, Options.scaleY)
    end
end

return Options
