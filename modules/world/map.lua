-- modules/world/map.lua
local Map = {}
local sti = require("libs.sti")
local map = nil

function Map.load(mapPath)
    map = sti(mapPath)
end

function Map.update(dt)
    if map then
        map:update(dt)
    end
end

function Map.draw()
    if map then
        local windowWidth, windowHeight = love.graphics.getDimensions()
        local scaleX = 1
        local scaleY = 1

        love.graphics.push()
        love.graphics.scale(scaleX, scaleY)

        map.layers["Water"]:draw()
        map.layers["Grass"]:draw()

        love.graphics.pop()
    end
end

function Map.isWalkable(tx, ty)
    if not map then return false end

    if tx < 1 or ty < 1 or tx > map.width or ty > map.height then
        return false
    end

    local layer = map.layers["Grass"]

    if layer and layer.data[ty] and layer.data[ty][tx] then
        return true
    end

    return false
end

return Map
