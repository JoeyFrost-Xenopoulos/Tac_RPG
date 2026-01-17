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

function Map.getElevation(tx, ty)
    if not map then return nil end    
    if tx < 1 or ty < 1 or tx > map.width or ty > map.height then
        return nil
    end

    local wallLayer = map.layers["Wall"] and map.layers["Wall"].data[ty] and map.layers["Wall"].data[ty][tx]
    if wallLayer and wallLayer ~= 0 then
        return nil
    end

    local hillLayer = map.layers["Hill"] and map.layers["Hill"].data[ty] and map.layers["Hill"].data[ty][tx]
    if hillLayer and hillLayer ~= 0 then
        return 1
    end

    local topSlopeLayer = map.layers["Top_Slope"] and map.layers["Top_Slope"].data[ty] and map.layers["Top_Slope"].data[ty][tx]
    if topSlopeLayer and topSlopeLayer ~= 0 then
        return 1
    end

    local botSlopeLayer = map.layers["Bot_Slope"] and map.layers["Bot_Slope"].data[ty] and map.layers["Bot_Slope"].data[ty][tx]
    if botSlopeLayer and botSlopeLayer ~= 0 then
        return 0.5
    end

    local grassLayer = map.layers["Grass"] and map.layers["Grass"].data[ty] and map.layers["Grass"].data[ty][tx]
    if grassLayer and grassLayer ~= 0 then
        return 0
    end

    return nil
end

function Map.canMove(fromX, fromY, toX, toY)
    local fromHeight = Map.getElevation(fromX, fromY)
    local toHeight   = Map.getElevation(toX, toY)

    if not fromHeight or not toHeight then return false end
    
    local diff = toHeight - fromHeight
    local fromBot = map.layers["Bot_Slope"].data[fromY] and map.layers["Bot_Slope"].data[fromY][fromX] or 0
    local toBot   = map.layers["Bot_Slope"].data[toY]   and map.layers["Bot_Slope"].data[toY][toX] or 0

    if diff == 0 then
        return true
    end
    if fromHeight == 0.5 or toHeight == 0.5 then
        return true
    end

    if (fromHeight == 0 and toHeight == 1) or (fromHeight == 1 and toHeight == 0) then
        return false
    end
    return false
end


function Map.isWalkable(tx, ty)
    return Map.getElevation(tx, ty) ~= nil
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
        map.layers["Wall"]:draw()
        map.layers["Hill"]:draw()
        map.layers["Bot_Slope"]:draw()
        map.layers["Top_Slope"]:draw()

        love.graphics.pop()
    end
end

return Map