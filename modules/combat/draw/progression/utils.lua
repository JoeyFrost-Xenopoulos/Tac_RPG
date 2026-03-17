local Utils = {}

function Utils.getAnimationFrame(timer, frameDuration, totalFrames)
    return math.floor((timer / frameDuration) % totalFrames)
end

function Utils.getExpAnimProgress(state)
    local animDelay = state.expBarAnimDelay or 0
    local animDuration = math.max(state.expBarAnimDuration or 1.0, 0.001)
    local animElapsed = math.max(0, (state.expBarTimer or 0) - animDelay)
    return math.max(0, math.min(1, animElapsed / animDuration))
end

function Utils.drawStatAnimation(state, animImage, frameW, frameH, frameCount, frameDuration, x, y, scale)
    if not animImage or not state.expBarTimer then return end

    local animTime
    if state.expLeveledUp then
        animTime = state.levelUpMenuTimer or 0
    else
        animTime = state.expBarTimer
            - (state.expBarAnimDelay or 0)
            - (state.expBarAnimDuration or 1.0)
            - (state.expBarPostHoldDuration or 0.8)
    end

    if animTime < 0 then return end

    local frameIndex = Utils.getAnimationFrame(animTime, frameDuration, frameCount)
    local imageW, imageH = animImage:getDimensions()
    local quad = love.graphics.newQuad(frameIndex * frameW, 0, frameW, frameH, imageW, imageH)

    scale = scale or 1
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(animImage, quad, x, y, 0, scale, scale)
    love.graphics.setColor(1, 1, 1, 1)
end

function Utils.formatStatValue(value)
    if value == nil then
        return "--"
    end
    return tostring(math.floor(value + 0.5))
end

function Utils.drawOutlinedText(text, x, y, width, align)
    align = align or "left"
    love.graphics.setColor(0, 0, 0, 1)

    if width then
        love.graphics.printf(text, x - 1, y, width, align)
        love.graphics.printf(text, x + 1, y, width, align)
        love.graphics.printf(text, x, y - 1, width, align)
        love.graphics.printf(text, x, y + 1, width, align)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(text, x, y, width, align)
    else
        love.graphics.print(text, x - 1, y)
        love.graphics.print(text, x + 1, y)
        love.graphics.print(text, x, y - 1)
        love.graphics.print(text, x, y + 1)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(text, x, y)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return Utils
