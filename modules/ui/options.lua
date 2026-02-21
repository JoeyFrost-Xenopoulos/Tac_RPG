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

-- Back button bounds
Options.backButtonArea = {x = 0, y = 0, w = 0, h = 0}

-- Scrollbar state
Options.scrollPosition = 0.5  -- 0 to 1, where 0 is top and 1 is bottom
Options.scrollBarImage = nil
Options.scrollIconImage = nil

local quadW = {left = 448, mid = 448, right = 448}
local quadH = {top = 448, mid = 448, bot = 448}

Options.volumeLevels = {
    { label = "Off", value = 0.0 },
    { label = "L",   value = 0.3 },
    { label = "M",   value = 0.6 },
    { label = "H",   value = 1.0 }
}

Options.musicLevel = 3
Options.sfxLevel   = 2

function Options.load()
    Options.menuImage = love.graphics.newImage("assets/ui/menu/options_menu.png")
    Options.menuImage:setFilter("nearest", "nearest")

    local imgW, imgH = Options.menuImage:getDimensions()

    Options.variants = {
        {
            topLeft   = love.graphics.newQuad(0,   0,   448, 448, imgW, imgH),
            topMid    = love.graphics.newQuad(448, 0,   448, 448, imgW, imgH),
            topRight  = love.graphics.newQuad(896, 0,   448, 448, imgW, imgH),
            midLeft   = love.graphics.newQuad(0,   448, 448, 448, imgW, imgH),
            midMid    = love.graphics.newQuad(448, 448, 448, 448, imgW, imgH),
            midRight  = love.graphics.newQuad(896, 448, 448, 448, imgW, imgH),
            botLeft   = love.graphics.newQuad(0,   896, 448, 448, imgW, imgH),
            botMid    = love.graphics.newQuad(448, 896, 448, 448, imgW, imgH),
            botRight  = love.graphics.newQuad(896, 896, 448, 448, imgW, imgH)
        }
    }

    Options.icons = {
        back  = love.graphics.newImage("assets/ui/icons/menu/back.png"),
        music = love.graphics.newImage("assets/ui/icons/menu/music.png"),
        sfx = love.graphics.newImage("assets/ui/icons/menu/sfx.png")
    }

    Options.scrollBarImage = love.graphics.newImage("assets/ui/icons/menu/scroll_bar.png")
    Options.scrollBarImage:setFilter("nearest", "nearest")
    Options.scrollIconImage = love.graphics.newImage("assets/ui/icons/menu/scroll_bar_2.png")
    Options.scrollIconImage:setFilter("nearest", "nearest")

    Options.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 48)
    Options.cursorImage = love.graphics.newImage("assets/ui/cursors/Cursor_02.png")

    Effects.setMusicVolume(Options.volumeLevels[Options.musicLevel].value)
    Effects.setSFXVolume(Options.volumeLevels[Options.sfxLevel].value)
end

function Options.clicked(mx, my)
    if not Options.visible then return false end
    
    -- Check if back button was clicked
    if mx >= Options.backButtonArea.x and mx < Options.backButtonArea.x + Options.backButtonArea.w and
       my >= Options.backButtonArea.y and my < Options.backButtonArea.y + Options.backButtonArea.h then
        Options.hide()
        return true
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

    -- Draw the background video
    local vidW, vidH = Options.video:getDimensions()
    if vidW > 0 and vidH > 0 then
        local sx = screenW / vidW
        local sy = screenH / vidH
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Options.video, 0, 0, 0, sx, sy)
    end

    -- Draw the 3x3 menu table with individual quads
    if Options.menuImage and Options.variants then
        love.graphics.setColor(1, 1, 1, 1)
        
        local cellSize = 448 * Options.scaleX
        local v = Options.variants[1]        
        local offsetX = -170
        local offsetY = -170
        
        -- Calculate actual displayed dimensions accounting for offsets
        local actualW = cellSize * 3 + offsetX * 2
        local actualH = cellSize * 3 + offsetY * 2
        local startX = (screenW - actualW) / 2
        local startY = (screenH - actualH) / 2
        
        -- Top row
        love.graphics.draw(Options.menuImage, v.topLeft,   startX,                    startY,                    0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.topMid,    startX + cellSize + offsetX, startY,                    0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.topRight,  startX + cellSize*2 + offsetX*2, startY,              0, Options.scaleX, Options.scaleY)

        -- Middle row
        love.graphics.draw(Options.menuImage, v.midLeft,   startX,                    startY + cellSize + offsetY, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.midMid,    startX + cellSize + offsetX, startY + cellSize + offsetY, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.midRight,  startX + cellSize*2 + offsetX*2, startY + cellSize + offsetY, 0, Options.scaleX, Options.scaleY)

        -- Bottom row
        love.graphics.draw(Options.menuImage, v.botLeft,   startX,                    startY + cellSize*2 + offsetY*2, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.botMid,    startX + cellSize + offsetX, startY + cellSize*2 + offsetY*2, 0, Options.scaleX, Options.scaleY)
        love.graphics.draw(Options.menuImage, v.botRight,  startX + cellSize*2 + offsetX*2, startY + cellSize*2 + offsetY*2, 0, Options.scaleX, Options.scaleY)
        
        -- Draw back icon and text in top-left cell
        local iconSize = 64
        local backIconX = startX + 170
        local backIconY = startY + 170
        local backTextX = backIconX + iconSize + 16
        local backTextY = backIconY + (iconSize - 48) / 2
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(Options.icons.back, backIconX, backIconY, 0, 1, 1)
        love.graphics.setFont(Options.font)
        love.graphics.print("Back", backTextX, backTextY)
        
        -- Store back button area for click detection
        Options.backButtonArea.x = startX
        Options.backButtonArea.y = startY
        Options.backButtonArea.w = cellSize
        Options.backButtonArea.h = cellSize
        
        -- Draw scrollbar on the right side
        if Options.scrollBarImage and Options.scrollIconImage then
            local scrollbarX = startX + 510
            local scrollbarY = startY + 250
            local scrollbarHeight = cellSize * 3 + offsetY * 2
            
            -- Draw scrollbar background
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(Options.scrollBarImage, scrollbarX, scrollbarY, 0, 2, 3)
            
            -- Draw scrollbar icon at the appropriate position
            local scrollIconHeight = Options.scrollIconImage:getHeight()
            local availableHeight = scrollbarHeight - scrollIconHeight
            local scrollIconY = scrollbarY + (availableHeight * Options.scrollPosition)
            
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(Options.scrollIconImage, scrollbarX, scrollIconY - 525, 0, 2, 4)
        end
    end
end

return Options