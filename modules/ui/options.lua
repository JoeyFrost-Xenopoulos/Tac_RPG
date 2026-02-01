local Options = {}

Options.visible = false
Options.video = nil
Options.menuImage = nil
Options.scaleX = 0.85
Options.scaleY = 0.85

local quadW = {left = 308, mid = 154, right = 204}
local quadH = {top = 310, mid = 310, bot = 310}

function Options.load()
    Options.menuImage = love.graphics.newImage("assets/ui/menu/options_menu.png")
    local imgW, imgH = Options.menuImage:getDimensions()

    Options.variants = {
        {
            topLeft   = love.graphics.newQuad(0,   0,   quadW.left,  quadH.top, imgW, imgH),
            topMid    = love.graphics.newQuad(462, 0,   quadW.mid,   quadH.top, imgW, imgH),
            topRight  = love.graphics.newQuad(768, 0,   quadW.right, quadH.top, imgW, imgH),
            midLeft   = love.graphics.newQuad(0,   462, quadW.left,  quadH.mid, imgW, imgH),
            midMid    = love.graphics.newQuad(462, 462, quadW.mid,   quadH.mid, imgW, imgH),
            midRight  = love.graphics.newQuad(768, 462, quadW.right, quadH.mid, imgW, imgH),
            botLeft   = love.graphics.newQuad(0,   768, quadW.left,  quadH.bot, imgW, imgH),
            botMid    = love.graphics.newQuad(462, 768, quadW.mid,   quadH.bot, imgW, imgH),
            botRight  = love.graphics.newQuad(768, 768, quadW.right, quadH.bot, imgW, imgH)
        }
    }

    Options.icons = {
        back  = love.graphics.newImage("assets/ui/icons/back.png"),
        music = love.graphics.newImage("assets/ui/icons/music.png"),
        sfx = love.graphics.newImage("assets/ui/icons/sfx.png")
    }

    Options.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 48)
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
    if vidW > 0 and vidH > 0 then
        local sx = screenW / vidW
        local sy = screenH / vidH
        love.graphics.draw(Options.video, 0, 0, 0, sx, sy)
    end

    if Options.menuImage and Options.variants then
        local v = Options.variants[1]

        local totalW = (quadW.left + quadW.mid + quadW.right) * Options.scaleX
        local totalH = (quadH.top + quadH.mid + quadH.bot) * Options.scaleY        
        local offsetX = 45
        local x = (screenW - totalW) / 2 - offsetX
        local y = (screenH - totalH) / 2

        local col2X = x + (quadW.left * Options.scaleX) - 2
        local col3X = col2X + (quadW.mid * Options.scaleX) - 5
        
        local row2Y = y + (quadH.top * Options.scaleY) - 5
        local row3Y = row2Y + (quadH.mid * Options.scaleY) - 135

        love.graphics.setColor(1, 1, 1, 1)
        
        -- Top row
        love.graphics.draw(Options.menuImage, v.topLeft,  x,     y, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.topMid,   col2X, y, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.topRight, col3X, y, 0, Options.scaleX, Options.scaleY)

        -- Middle row
        love.graphics.draw(Options.menuImage, v.midLeft,  x,     row2Y, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.midMid,   col2X, row2Y, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.midRight, col3X, row2Y, 0, Options.scaleX, Options.scaleY)

        -- Bottom row
        love.graphics.draw(Options.menuImage, v.botLeft,  x,     row3Y, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.botMid,   col2X, row3Y, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.botRight, col3X, row3Y, 0, Options.scaleX, Options.scaleY)
    end

    if Options.icons then
        local totalW = (quadW.left + quadW.mid + quadW.right) * Options.scaleX
        local totalH = (quadH.top + quadH.mid + quadH.bot) * Options.scaleY

        local offsetX = 45
        local x = (love.graphics.getWidth() - totalW) / 2 - offsetX
        local y = (love.graphics.getHeight() - totalH) / 2

        love.graphics.draw(Options.icons.back, x + 160, y + 160, 0, 1, 1)
        love.graphics.draw(Options.icons.music, x + 160, y + 290, 0, 1, 1)
        love.graphics.draw(Options.icons.sfx, x + 120, y + 380, 0, 0.16, 0.16)

        if Options.font then
            love.graphics.setFont(Options.font)
            love.graphics.setColor(1, 1, 1, 1)

            local textOffsetX = 140
            local backTextY  = y + 175
            local musicTextY = y + 305
            local sfxTextY   = y + 430

            love.graphics.print("Back", x + 140 + textOffsetX, backTextY)
            love.graphics.print("Music", x + 135 + textOffsetX, musicTextY)
            love.graphics.print("SFX", x + 150 + textOffsetX, sfxTextY)
        end
    end
end

return Options