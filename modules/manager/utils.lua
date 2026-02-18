-- modules/manager/utils.lua
local Utils = {}

function Utils.isUnitDead(unit)
    return unit and ((unit.health or 0) <= 0 or unit.isDead)
end

function Utils.applyColourSwaps(imagePath, swapsPath)
    -- Load the original image data
    local imageData = love.image.newImageData(imagePath)
    
    -- Load colour swaps from Lua file
    local swaps = require(swapsPath)
    
    -- Get dimensions from image data
    local width, height = imageData:getDimensions()
    
    -- Create a new image data to modify
    local newImageData = love.image.newImageData(width, height)
    
    -- Copy and modify pixels
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local r, g, b, a = imageData:getPixel(x, y)
            
            -- Apply colour swaps
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
    
    -- Create and return a new image from the modified image data
    return love.graphics.newImage(newImageData)
end

return Utils
