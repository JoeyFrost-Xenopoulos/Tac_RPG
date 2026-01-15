-- modules/world/foam.lua
local WaterFoam = {}

local image
local quads = {}
local frameWidth, frameHeight = 192, 192
local frameCount = 16
local currentFrame = 1
local timer = 0

function WaterFoam.load()
    image = love.graphics.newImage("map/Water Foam.png")
    
    for i = 0, frameCount - 1 do
        quads[i+1] = love.graphics.newQuad(
            i * frameWidth, 0,
            frameWidth, frameHeight,
            image:getDimensions()
        )
    end
    
end

function WaterFoam.update(dt)
    timer = timer + dt
    if timer >= frameDuration then
        timer = timer - frameDuration
        currentFrame = currentFrame + 1
        if currentFrame > frameCount then
            currentFrame = 1
        end
    end
end

function WaterFoam.draw(x, y, w, h, frame)
    frame = frame or currentFrame
    local tileCenterX = x + w / 2
    local tileCenterY = y + h / 2
    local originX = frameWidth / 2
    local originY = frameHeight / 2

    love.graphics.draw(image, quads[frame], tileCenterX, tileCenterY, 0,1,1,originX,originY )
end

return WaterFoam
