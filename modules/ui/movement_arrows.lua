-- modules/ui/movement_arrows
local Arrows = {}
local Grid = require("modules.ui.grid")

Arrows.image = nil
Arrows.variants = {}
Arrows.path = nil

function Arrows.load()
    Arrows.image = love.graphics.newImage("assets/ui/movement_arrows/Arrows.png")
    local imgW, imgH = Arrows.image:getDimensions()

    Arrows.variants = {
        ends = {
            right = love.graphics.newQuad(0, 0, 64, 64, imgW, imgH),
            down  = love.graphics.newQuad(64, 0, 64, 64, imgW, imgH),
            up    = love.graphics.newQuad(0, 64, 64, 64, imgW, imgH),
            left  = love.graphics.newQuad(64, 64, 64, 64, imgW, imgH),
        },
        straight = {
            vertical   = love.graphics.newQuad(160, 0, 64, 64, imgW, imgH),
            horizontal = love.graphics.newQuad(160, 64, 64, 64, imgW, imgH),
        },
        bends = {
            right = love.graphics.newQuad(352, 0, 64, 64, imgW, imgH),
            left  = love.graphics.newQuad(448, 0, 64, 64, imgW, imgH),
            up    = love.graphics.newQuad(352, 64, 64, 64, imgW, imgH),
            down  = love.graphics.newQuad(448, 64, 64, 64, imgW, imgH),
        }
    }
end

function Arrows.setPath(path)
    Arrows.path = path
end

function Arrows.clear()
    Arrows.path = nil
end

local function direction(a, b)
    return b.x - a.x, b.y - a.y
end

function Arrows.draw()
    if not Arrows.path or #Arrows.path < 2 then return end

    for i = 1, #Arrows.path do
        local prev = Arrows.path[i - 1]
        local curr = Arrows.path[i]
        local next = Arrows.path[i + 1]

        local quad = nil

        if not prev and next then
            -- start arrow
            local dx, dy = direction(curr, next)
            if dx == 1 then quad = Arrows.variants.ends.horizontal
            elseif dx == -1 then quad = Arrows.variants.ends.horizontal
            elseif dy == 1 then quad = Arrows.variants.ends.vertical
            elseif dy == -1 then quad = Arrows.variants.ends.horizontal end

        elseif prev and next then
            local dx1, dy1 = direction(prev, curr)
            local dx2, dy2 = direction(curr, next)

            -- straight lines
            if dx1 ~= 0 and dx2 ~= 0 then
                quad = Arrows.variants.straight.horizontal
            elseif dy1 ~= 0 and dy2 ~= 0 then
                quad = Arrows.variants.straight.vertical
            else
                -- bends
                if dx1 == 1 and dy2 == 1 or dy1 == -1 and dx2 == -1 then
                    quad = Arrows.variants.bends.left
                elseif dx1 == -1 and dy2 == 1 or dy1 == -1 and dx2 == 1 then
                    quad = Arrows.variants.bends.right
                elseif dy1 == 1 and dx2 == 1 or dx1 == -1 and dy2 == -1 then
                    quad = Arrows.variants.bends.up
                else
                    quad = Arrows.variants.bends.down
                end
            end

        elseif prev and not next then
            -- end arrow
            local dx, dy = direction(prev, curr)
            if dx == 1 then quad = Arrows.variants.ends.right
            elseif dx == -1 then quad = Arrows.variants.ends.left
            elseif dy == 1 then quad = Arrows.variants.ends.down
            elseif dy == -1 then quad = Arrows.variants.ends.up end
        end

        if quad then
            local px = (curr.x - 1) * Grid.tileSize
            local py = (curr.y - 1) * Grid.tileSize
            love.graphics.draw(Arrows.image, quad, px, py)
        end
    end
end

return Arrows