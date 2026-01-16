-- modules/world/map.lua
local Map = {}
local sti = require("libs.sti")
local map = nil
local WaterFoam = require("modules.world.foam")

local foamTiles = {}

function Map.load(mapPath)
    map = sti(mapPath)
    WaterFoam.load()
    foamTiles = Map.getFoamTiles()
end

function Map.getFoamTiles()
    if not map then return {} end

    local grassLayer = map.layers["Grass"]
    local foamTiles = {}

    for y = 1, map.height do
        for x = 1, map.width do
            local grassTile = grassLayer.data[y] and grassLayer.data[y][x] or 0
            if grassTile ~= 0 then
                table.insert(foamTiles, {
                    x = x,
                    y = y,
                    currentFrame = love.math.random(1, 16), 
                    timer = love.math.random() * 0.1
                })
            end
        end
    end

    return foamTiles
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

function Map.update(dt)
    if map then
        map:update(dt)
    end

    local frameCount = 16
    local frameDuration = 0.10

    for _, tile in ipairs(foamTiles) do
        tile.timer = tile.timer + dt
        if tile.timer >= frameDuration then
            tile.timer = tile.timer - frameDuration
            tile.currentFrame = tile.currentFrame + 1
            if tile.currentFrame > frameCount then
                tile.currentFrame = 1
            end
        end
    end
end

function Map.draw()
    if map then
        love.graphics.push()
        love.graphics.scale(1, 1)

        map.layers["Water"]:draw()

        local tileW, tileH = map.tilewidth, map.tileheight
        for _, tile in ipairs(foamTiles) do
            local worldX = (tile.x - 1) * tileW
            local worldY = (tile.y - 1) * tileH
            WaterFoam.draw(worldX, worldY, tileW, tileH, tile.currentFrame)
        end

        map.layers["Grass"]:draw()
        map.layers["Shadow"]:draw()
        map.layers["Hill"]:draw()
        map.layers["Ramp"]:draw()

        love.graphics.pop()
    end
end

return Map