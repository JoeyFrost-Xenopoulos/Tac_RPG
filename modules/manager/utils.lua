-- modules/manager/utils.lua
local Utils = {}

function Utils.isUnitDead(unit)
    return unit and ((unit.health or 0) <= 0 or unit.isDead)
end

local function applySwapsToImageData(imageData, swaps)
    local width, height = imageData:getDimensions()
    local newImageData = love.image.newImageData(width, height)

    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local r, g, b, a = imageData:getPixel(x, y)

            for _, swap in ipairs(swaps) do
                local fromR = swap.from[1] / 255
                local fromG = swap.from[2] / 255
                local fromB = swap.from[3] / 255
                local toR = swap.to[1] / 255
                local toG = swap.to[2] / 255
                local toB = swap.to[3] / 255

                -- Check if pixel matches (with small tolerance for floating point)
                if math.abs(r - fromR) < 0.01 and math.abs(g - fromG) < 0.01 and math.abs(b - fromB) < 0.01 then
                    r, g, b = toR, toG, toB
                    break
                end
            end

            newImageData:setPixel(x, y, r, g, b, a)
        end
    end

    return newImageData
end

function Utils.applyColourSwaps(imagePath, swapsPath)
    local imageData = love.image.newImageData(imagePath)
    local swapPaths = swapsPath

    if type(swapsPath) == "string" then
        swapPaths = { swapsPath }
    end

    if type(swapPaths) ~= "table" then
        return love.graphics.newImage(imageData)
    end

    for _, path in ipairs(swapPaths) do
        local swaps = require(path)
        imageData = applySwapsToImageData(imageData, swaps)
    end

    return love.graphics.newImage(imageData)
end

return Utils
