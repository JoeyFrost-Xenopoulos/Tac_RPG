local Options = {}

Options.visible = false
Options.video = nil
Options.menuImage = nil
Options.scaleX = 1.0
Options.scaleY = 1.0

function Options.load()
    Options.menuImage = love.graphics.newImage("assets/ui/menu/options_menu.png")
    local imgW, imgH = Options.menuImage:getDimensions()

    Options.variants = {
        {
            topLeft   = love.graphics.newQuad(0,   0,   128, 128, imgW, imgH),
            topMid    = love.graphics.newQuad(192, 0,   64, 128, imgW, imgH),
            topRight  = love.graphics.newQuad(320, 0,   84, 128, imgW, imgH),
            midLeft   = love.graphics.newQuad(0,   192, 128, 128, imgW, imgH),
            midMid    = love.graphics.newQuad(192, 192, 64, 64, imgW, imgH),
            midRight  = love.graphics.newQuad(320, 192, 84, 64, imgW, imgH),
            botLeft   = love.graphics.newQuad(0,   320, 128, 128, imgW, imgH),
            botMid    = love.graphics.newQuad(192, 320, 64, 104, imgW, imgH),
            botRight  = love.graphics.newQuad(320, 320, 84, 102, imgW, imgH)
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
    if not Options.visible then return end
    if Options.video then

        local ok, duration = pcall(function() return Options.video:getDuration() end)
        if ok and duration and duration > 0 then
            local ok2, pos = pcall(function() return Options.video:tell() end)
            if ok2 and pos then
                if pos >= duration - 0.05 then
                    pcall(function() Options.video:seek(0) end)
                    pcall(function() Options.video:play() end)
                end
            end
        end
        if not Options.video:isPlaying() then
            pcall(function() Options.video:play() end)
        end
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
        love.graphics.draw(Options.menuImage, v.topMid,   x + 128 * Options.scaleX, y, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.topRight, x + 192 * Options.scaleX, y, 0, Options.scaleX, Options.scaleY)

        -- Middle row
        love.graphics.draw(Options.menuImage, v.midLeft,  x, y + 128 * Options.scaleY, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.midMid,   x + 128 * Options.scaleX, y + 128 * Options.scaleY, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.midRight, x + 192 * Options.scaleX, y + 128 * Options.scaleY, 0, Options.scaleX, Options.scaleY)

        -- Bottom row
        love.graphics.draw(Options.menuImage, v.botLeft,  x, y + 192 * Options.scaleY, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.botMid,   x + 128 * Options.scaleX, y + 192 * Options.scaleY, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.botRight, x + 192 * Options.scaleX, y + 192 * Options.scaleY, 0, Options.scaleX, Options.scaleY)
    end
end

return Options
