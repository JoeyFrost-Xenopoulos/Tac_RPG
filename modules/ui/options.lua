local Effects = require("modules.audio.sound_effects")

local Options = {}

Options.visible = false
Options.video = nil
Options.menuImage = nil
Options.scaleX = 0.85
Options.scaleY = 0.85

Options.cursorTime = 0
Options.hoveredIndex = nil
Options.cursorImage = nil

local quadW = {left = 308, mid = 154, right = 204}
local quadH = {top = 310, mid = 310, bot = 310}

Options.volumeLevels = {
    { label = "Off", value = 0.0 },
    { label = "L",   value = 0.3 },
    { label = "M",   value = 0.6 },
    { label = "H",   value = 1.0 }
}

Options.musicLevel = 3
Options.sfxLevel   = 3

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
    Options.cursorImage = love.graphics.newImage("assets/ui/cursors/Cursor_02.png")

    Effects.setMusicVolume(Options.volumeLevels[Options.musicLevel].value)
    Effects.setSFXVolume(Options.volumeLevels[Options.sfxLevel].value)
end

function Options.clicked(mx, my)
    if not Options.visible then return false end
    local x = (love.graphics.getWidth() - (quadW.left + quadW.mid + quadW.right) * Options.scaleX) / 2 - 45
    local y = (love.graphics.getHeight() - (quadH.top + quadH.mid + quadH.bot) * Options.scaleY) / 2
    local items = {
        { name = "Back",  y = y + 175, iconY = y + 160 },
        { name = "Music", y = y + 305, iconY = y + 290 },
        { name = "SFX",   y = y + 430, iconY = y + 380 }
    }

    for i, item in ipairs(items) do
        if mx > x + 100 and mx < x + 500 and my > item.y and my < item.y + 50 then
            if item.name == "Back" then
                Options.hide()
                Effects.playClick()
                return true
            end

            if item.name == "Music" then
                Options.musicLevel = Options.musicLevel % #Options.volumeLevels + 1
                Effects.setMusicVolume(Options.volumeLevels[Options.musicLevel].value)
                Effects.playSelect()
                return true
            end

            if item.name == "SFX" then
                Options.sfxLevel = Options.sfxLevel % #Options.volumeLevels + 1
                Effects.setSFXVolume(Options.volumeLevels[Options.sfxLevel].value)
                Effects.playSelect()
                return true
            end
        end
    end

    return false
end

function Options.show()
    if not Options.video then
        Options.video = love.graphics.newVideo("assets/backgrounds/options_background.ogv")
    end
    if Options.video then
        Options.video:play()
    end
    Options.visible = true
    Options.hoveredIndex = nil
end

function Options.hide()
    if Options.video then
        Options.video:pause()
    end
    Options.visible = false
    Options.hoveredIndex = nil
end

function Options.update(dt)
    if not Options.visible then return end    
    Options.cursorTime = Options.cursorTime + dt

    if Options.video then
        if not Options.video:isPlaying() then
            Options.video:rewind()
            Options.video:play()
        end
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

    local totalW = (quadW.left + quadW.mid + quadW.right) * Options.scaleX
    local totalH = (quadH.top + quadH.mid + quadH.bot) * Options.scaleY         
    local offsetX = 45
    local x = (screenW - totalW) / 2 - offsetX
    local y = (screenH - totalH) / 2

    if Options.menuImage and Options.variants then
        local v = Options.variants[1]
        local col2X = x + (quadW.left * Options.scaleX) - 2
        local col3X = col2X + (quadW.mid * Options.scaleX) - 5
        local row2Y = y + (quadH.top * Options.scaleY) - 5
        local row3Y = row2Y + (quadH.mid * Options.scaleY) - 135
        love.graphics.setColor(1, 1, 1, 1)
        
        -- Top row
        love.graphics.draw(Options.menuImage, v.topLeft,   x,     y, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.topMid,    col2X, y, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.topRight, col3X, y, 0, Options.scaleX, Options.scaleY)

        -- Middle row
        love.graphics.draw(Options.menuImage, v.midLeft,   x,     row2Y, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.midMid,    col2X, row2Y, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.midRight, col3X, row2Y, 0, Options.scaleX, Options.scaleY)

        -- Bottom row
        love.graphics.draw(Options.menuImage, v.botLeft,   x,     row3Y, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.botMid,    col2X, row3Y, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.botRight, col3X, row3Y, 0, Options.scaleX, Options.scaleY)
    end

    if Options.icons then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Options.icons.back, x + 160, y + 160, 0, 1, 1)
        love.graphics.draw(Options.icons.music, x + 160, y + 290, 0, 1, 1)
        love.graphics.draw(Options.icons.sfx, x + 120, y + 380, 0, 0.16, 0.16)

        if Options.font then
            love.graphics.setFont(Options.font)
            
            local textOffsetX = 140
            local items = {
                { name = "Back",  y = y + 175, iconY = y + 160 },
                { name = "Music", y = y + 305, iconY = y + 290 },
                { name = "SFX",   y = y + 430, iconY = y + 380 }
            }

            local mx, my = love.mouse.getPosition()
            local currentHover = nil
            local rightX = x + totalW - 125

            for i, item in ipairs(items) do
                local isHovered = mx > x + 100 and mx < x + totalW
                    and my > item.y and my < item.y + 50
                    -- HIGHLIGHT
                    if isHovered then
                        love.graphics.setColor(1, 1, 1, 0.12)
                        love.graphics.rectangle("fill",x + 100,item.y - (80 - 40) / 2,totalW - 140,80,8, 8)
                    end

                    love.graphics.setColor(1, 1, 1, 1)

                    -- Cursor
                    if isHovered then
                        local bob = math.sin(Options.cursorTime * 8) * 4
                        love.graphics.draw(Options.cursorImage, x + 220 + bob, item.y - 5, 90, 2, 2)
                    end

                    -- Text
                    love.graphics.print(item.name, x + 140 + textOffsetX, item.y)
                if item.name == "Music" then
                    love.graphics.print(Options.volumeLevels[Options.musicLevel].label, rightX, item.y)
                elseif item.name == "SFX" then
                    love.graphics.print(Options.volumeLevels[Options.sfxLevel].label, rightX, item.y)
                end
            end

        end
    end
end

return Options