local TurnOverlay = {}

TurnOverlay.isVisible = false
TurnOverlay.text = ""
TurnOverlay.timer = 0
TurnOverlay.totalDuration = 1.5
TurnOverlay.slideDuration = 0.5

TurnOverlay.font = love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 128)
TurnOverlay.swordImage = love.graphics.newImage("assets/ui/swords/Swords.png")
TurnOverlay.swordImage:setFilter("nearest", "nearest")

TurnOverlay.swordHeight = 128
TurnOverlay.overlap = 1

-- Define sword segments
local segments = {
    {x = 0,   w = 128, targetW = 128, xOffset = -10},
    {x = 190, w = 66,  targetW = 200, xOffset = -10},
    {x = 320, w = 128, targetW = 200, xOffset = -2}
}

TurnOverlay.combinedWidth = 0
for _, s in ipairs(segments) do
    TurnOverlay.combinedWidth = TurnOverlay.combinedWidth + s.targetW + s.xOffset - TurnOverlay.overlap
end

TurnOverlay.swordQuads = {}
for i = 0, 4 do
    TurnOverlay.swordQuads[i + 1] = {}
    for j, seg in ipairs(segments) do
        TurnOverlay.swordQuads[i + 1][j] = love.graphics.newQuad(
            seg.x,
            i * TurnOverlay.swordHeight,
            seg.w,
            TurnOverlay.swordHeight,
            TurnOverlay.swordImage:getDimensions()
        )
    end
end

TurnOverlay.combinedCanvases = {}

local function createCombinedCanvas(swordIndex)
    if TurnOverlay.combinedCanvases[swordIndex] then
        return TurnOverlay.combinedCanvases[swordIndex]
    end

    local canvas = love.graphics.newCanvas(TurnOverlay.combinedWidth, TurnOverlay.swordHeight)
    love.graphics.push()
    love.graphics.origin()
    love.graphics.setCanvas(canvas)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)

    local drawX = 0
    for i, quad in ipairs(TurnOverlay.swordQuads[swordIndex]) do
        local cfg = segments[i]
        local sx = cfg.targetW / cfg.w
        love.graphics.draw(TurnOverlay.swordImage, quad, drawX, 0, 0, sx, 1)
        drawX = drawX + cfg.targetW + cfg.xOffset - TurnOverlay.overlap
    end

    love.graphics.setCanvas()
    love.graphics.pop()
    TurnOverlay.combinedCanvases[swordIndex] = canvas
    return canvas
end

TurnOverlay.swordIndex = 1

function TurnOverlay.show(text, isPlayerTurn)
    TurnOverlay.text = text
    TurnOverlay.timer = 0
    TurnOverlay.isVisible = true
    TurnOverlay.swordIndex = isPlayerTurn and 1 or 2

    createCombinedCanvas(TurnOverlay.swordIndex)
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
        local p = t / sDur
        p = 1 - math.pow(1 - p, 3)
        animX = -screenW * (1 - p)
    elseif t > (dur - sDur) then
        local p = (t - (dur - sDur)) / sDur
        p = math.pow(p, 3)
        animX = screenW * p
    end
    animX = math.floor(animX + 0.5)

    local alpha = 1
    if t < sDur then
        alpha = t / sDur
    elseif t > (dur - sDur) then
        alpha = 1 - ((t - (dur - sDur)) / sDur)
    end

    -- Draw semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.5 * alpha)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    -- Draw pre-combined sword canvas
    local canvas = createCombinedCanvas(TurnOverlay.swordIndex)
    local swordY = math.floor((screenH - TurnOverlay.swordHeight) / 2 - 50 + 0.5)
    local swordX = math.floor((screenW - TurnOverlay.combinedWidth) / 2 + animX + 0.5)
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.draw(canvas, swordX, swordY)

    love.graphics.setFont(TurnOverlay.font)
    local textW = TurnOverlay.font:getWidth(TurnOverlay.text)
    love.graphics.print(
        TurnOverlay.text,
        math.floor((screenW - textW) / 2 + animX + 0.5),
        math.floor((screenH - 48) / 2 + 0.5)
    )

    love.graphics.setColor(1, 1, 1, 1)
end

function TurnOverlay.isActive()
    return TurnOverlay.isVisible
end

return TurnOverlay
