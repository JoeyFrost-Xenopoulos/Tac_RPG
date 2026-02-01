local TurnOverlay = {}

TurnOverlay.isVisible = false
TurnOverlay.text = ""
TurnOverlay.timer = 0
TurnOverlay.totalDuration = 2.5 
TurnOverlay.slideDuration = 0.5 
TurnOverlay.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 128)
TurnOverlay.swordImage = love.graphics.newImage("assets/ui/swords/Swords.png")

TurnOverlay.swordHeight = 128

local segments = {
    {x = 0,   w = 128, targetW = 128, xOffset = 0},
    {x = 190, w = 66,  targetW = 300, xOffset = -10},
    {x = 320, w = 128, targetW = 200, xOffset = -2}
}

TurnOverlay.combinedWidth = 0
for _, s in ipairs(segments) do
    TurnOverlay.combinedWidth = TurnOverlay.combinedWidth + s.targetW + s.xOffset
end

TurnOverlay.swordQuads = {}
for i = 0, 4 do
    TurnOverlay.swordQuads[i + 1] = {}
    for j, seg in ipairs(segments) do
        TurnOverlay.swordQuads[i + 1][j] = love.graphics.newQuad(
            seg.x, i * TurnOverlay.swordHeight, 
            seg.w, TurnOverlay.swordHeight, 
            TurnOverlay.swordImage:getDimensions()
        )
    end
end

TurnOverlay.swordIndex = 1

function TurnOverlay.show(text, isPlayerTurn)
    TurnOverlay.text = text
    TurnOverlay.timer = 0
    TurnOverlay.isVisible = true
    TurnOverlay.swordIndex = isPlayerTurn and 1 or 2
end

function TurnOverlay.update(dt)
    if not TurnOverlay.isVisible then return end
    TurnOverlay.timer = TurnOverlay.timer + dt
    if TurnOverlay.timer >= TurnOverlay.totalDuration then
        TurnOverlay.isVisible = false
    end
end

function TurnOverlay.draw()
    if not TurnOverlay.isVisible then return end
    
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local t = TurnOverlay.timer
    local dur = TurnOverlay.totalDuration
    local sDur = TurnOverlay.slideDuration
    local animX = 0

    if t < sDur then
        -- Slide In from Left (-screenW to 0)
        local p = t / sDur
        p = 1 - math.pow(1 - p, 3) -- Ease Out
        animX = -screenW * (1 - p)
    elseif t > (dur - sDur) then
        -- Slide Out to Right (0 to screenW)
        local p = (t - (dur - sDur)) / sDur
        p = math.pow(p, 3) -- Ease In
        animX = screenW * p
    else
        -- Stay at center
        animX = 0
    end

    local alpha = 1
    if t < sDur then alpha = t / sDur
    elseif t > (dur - sDur) then alpha = 1 - ((t - (dur - sDur)) / sDur)
    end
    
    -- Background Dim
    love.graphics.setColor(0, 0, 0, 0.5 * alpha)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    
    -- Draw Stitched Sword
    if TurnOverlay.swordImage and TurnOverlay.swordQuads[TurnOverlay.swordIndex] then
        local currentQuads = TurnOverlay.swordQuads[TurnOverlay.swordIndex]        
        local startX = (screenW - TurnOverlay.combinedWidth) / 2 + animX
        local swordY = (screenH - TurnOverlay.swordHeight) / 2 - 50
        
        love.graphics.setColor(1, 1, 1, alpha)
        
        local drawX = startX
        for i = 1, #currentQuads do
            local quad = currentQuads[i]
            local config = segments[i]
            local sx = config.targetW / config.w
            
            love.graphics.draw(TurnOverlay.swordImage, quad, drawX + config.xOffset, swordY, 0, sx, 1)            
            drawX = drawX + config.targetW + config.xOffset
        end
    end
    
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.setFont(TurnOverlay.font)
    local textW = TurnOverlay.font:getWidth(TurnOverlay.text)
    love.graphics.print(TurnOverlay.text, (screenW - textW) / 2 + animX, (screenH - 48) / 2)
    
    love.graphics.setColor(1, 1, 1, 1)
end

function TurnOverlay.isActive()
    return TurnOverlay.isVisible
end

return TurnOverlay