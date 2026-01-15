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


return Map
