local TurnOverlay = {}

TurnOverlay.isVisible = false
TurnOverlay.text = ""
TurnOverlay.timer = 0
TurnOverlay.totalDuration = 2.0
TurnOverlay.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 128)

function TurnOverlay.show(text)
    TurnOverlay.text = text
    TurnOverlay.timer = 0
    TurnOverlay.isVisible = true
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
    
    local halfDuration = TurnOverlay.totalDuration / 2
    local alpha = 1.0
    
    if TurnOverlay.timer < halfDuration then
        alpha = TurnOverlay.timer / halfDuration
    else
        alpha = 1.0 - (TurnOverlay.timer - halfDuration) / halfDuration
    end
    
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)
    
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.setFont(TurnOverlay.font)
    
    local textW = TurnOverlay.font:getWidth(TurnOverlay.text)
    local x = (screenW - textW) / 2
    local y = (screenH - 48) / 2
    
    love.graphics.print(TurnOverlay.text, x, y)
    love.graphics.setColor(1, 1, 1, 1)
end

function TurnOverlay.isActive()
    return TurnOverlay.isVisible
end

return TurnOverlay
