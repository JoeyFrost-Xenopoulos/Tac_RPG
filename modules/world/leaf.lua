-- modules/world/leaf.lua

local Leaf = {}

local image
local quads = {}

local frameCount = 5
local frameWidth = 16
local frameHeight = 16

local leaves = {}
local maxLeaves = 25
local frameDuration = 0.12

-- Map bounds (in world pixels)
local MAP_WIDTH = 18 * 64  -- 1152
local MAP_HEIGHT = 15 * 64  -- 960

local BEHAVIOR = {
    FALL = 1,
    DIAGONAL = 2,
    WINDY = 3
}

function Leaf.load()
    image = love.graphics.newImage("map/leaf/SpringLeaf.png")

    quads = {}
    for i = 0, frameCount - 1 do
        quads[i + 1] = love.graphics.newQuad(
            i * frameWidth,
            0,
            frameWidth,
            frameHeight,
            image:getDimensions()
        )
    end

    leaves = {}
    for i = 1, maxLeaves do
        Leaf.spawnLeaf(true)
    end
end

function Leaf.spawnLeaf(randomY)
    local behavior = love.math.random(1, 3)

    local leaf = {
        behavior = behavior,

        x = (behavior == BEHAVIOR.DIAGONAL) and -16
            or love.math.random(0, MAP_WIDTH),

        y = randomY and love.math.random(0, MAP_HEIGHT) or -16,

        vx = 0,
        vy = love.math.random(15, 30),

        swayTimer = love.math.random() * math.pi * 2,
        swayStrength = love.math.random(6, 14),

        frame = love.math.random(1, frameCount),
        frameTimer = love.math.random() * frameDuration,

        life = 0,
        maxLife = love.math.random(6, 14),
        landedLife = love.math.random(2, 6),
        alpha = 1,

        canLand = love.math.random() < 0.6,
        landed = false,
        landY = love.math.random(MAP_HEIGHT * 0.4, MAP_HEIGHT * 0.85)
    }

    if behavior == BEHAVIOR.DIAGONAL then
        leaf.vx = love.math.random(20, 35)
    elseif behavior == BEHAVIOR.WINDY then
        leaf.vx = love.math.random(-20, 20)
        leaf.vy = love.math.random(10, 20)
        leaf.swayStrength = love.math.random(15, 25)
    else
        leaf.vx = love.math.random(-5, 5)
    end

    table.insert(leaves, leaf)
end

function Leaf.update(dt)
    for i = #leaves, 1, -1 do
        local leaf = leaves[i]
        leaf.life = leaf.life + dt

        leaf.frameTimer = leaf.frameTimer + dt
        if leaf.frameTimer >= frameDuration then
            leaf.frameTimer = leaf.frameTimer - frameDuration
            leaf.frame = leaf.frame + 1
            if leaf.frame > frameCount then
                leaf.frame = 1
            end
        end

        if not leaf.landed then
            leaf.swayTimer = leaf.swayTimer + dt
            local sway = math.sin(leaf.swayTimer) * leaf.swayStrength

            leaf.x = leaf.x + (leaf.vx + sway) * dt
            leaf.y = leaf.y + leaf.vy * dt

            -- landing check
            if leaf.canLand and leaf.y >= leaf.landY then
                leaf.landed = true
                leaf.vx = 0
                leaf.vy = 0
                leaf.life = 0 -- reset life after landing
            end
        else
            -- fade out after landing
            leaf.alpha = math.max(0, 1 - (leaf.life / leaf.landedLife))

            if leaf.life >= leaf.landedLife then
                table.remove(leaves, i)
                Leaf.spawnLeaf(false)
                goto continue
            end
        end

        if leaf.y > MAP_HEIGHT + 20
        or leaf.x > MAP_WIDTH + 20
        or leaf.x < -40 then
            table.remove(leaves, i)
            Leaf.spawnLeaf(false)
        end
        ::continue::
    end
end

function Leaf.draw()
    for _, leaf in ipairs(leaves) do
        love.graphics.setColor(1, 1, 1, leaf.alpha or 1)
        love.graphics.draw(image, quads[leaf.frame], leaf.x, leaf.y)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return Leaf
