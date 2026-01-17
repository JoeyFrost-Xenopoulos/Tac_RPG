-- Enemy.lua
local Enemy_Soldier = {}
local Pathfinding = require("modules.engine.pathfinding")
local Movement = require("modules.engine.movement")
local Map = require("modules.world.map")

Enemy_Soldier.unit = {}
Enemy_Soldier.animations = {}

-- Tile/grid settings
Enemy_Soldier.tileSize = 64
Enemy_Soldier.scaleX = 0.85
Enemy_Soldier.scaleY = 0.85
Enemy_Soldier.unit.facingX = 1

Enemy_Soldier.unit.selected = false
Enemy_Soldier.unit.moveDuration = 0.25 -- seconds per tile

function Enemy_Soldier.load()
    -- IDLE animation
    Enemy_Soldier.animations.idle = {
        img = love.graphics.newImage("assets/units/Enemy/Soldier/Warrior_Idle.png"),
        frames = {
            {x=0,   y=0, width=192, height=192},
            {x=192, y=0, width=192, height=192},
            {x=384, y=0, width=192, height=192},
            {x=576, y=0, width=192, height=192},
            {x=768, y=0, width=192, height=192},
            {x=960, y=0, width=192, height=192},
            {x=1152, y=0, width=192, height=192},
            {x=1344, y=0, width=192, height=192}
        },
        speed = 0.10
    }

    -- WALK animation
    Enemy_Soldier.animations.walk = {
        img = love.graphics.newImage("assets/units/Enemy/Soldier/Warrior_Run.png"),
        frames = {
            {x=0,   y=0, width=192, height=192},
            {x=192, y=0, width=192, height=192},
            {x=384, y=0, width=192, height=192},
            {x=576, y=0, width=192, height=192},
            {x=768, y=0, width=192, height=192},
            {x=960, y=0, width=192, height=192}
        },
        speed = 0.08
    }

    -- ATTACK animation
    Enemy_Soldier.animations.attack = {
        img = love.graphics.newImage("assets/units/Enemy/Soldier/Warrior_Attack1.png"),
        frames = {
            {x=0,   y=0, width=68, height=126},
            {x=188, y=0, width=70, height=126},
        },
        speed = 0.15
    }

    -- Generate quads
    for name, anim in pairs(Enemy_Soldier.animations) do
        local quads = {}
        local imgW, imgH = anim.img:getDimensions()
        for _, f in ipairs(anim.frames) do
            table.insert(quads, love.graphics.newQuad(f.x, f.y, f.width, f.height, imgW, imgH))
        end
        anim.quads = quads
        anim.frameCount = #quads
    end

    Enemy_Soldier.unit.animations = Enemy_Soldier.animations
    Enemy_Soldier.unit.currentAnimation = "idle"
    Enemy_Soldier.unit.currentFrame = 1
    Enemy_Soldier.unit.frameTimer = 0
    Enemy_Soldier.unit.tileX = 3
    Enemy_Soldier.unit.tileY = 3
end

function Enemy_Soldier.setPosition(tileX, tileY) 
    Enemy_Soldier.unit.tileX = tileX 
    Enemy_Soldier.unit.tileY = tileY 
end

function Enemy_Soldier.tryMove(tileX, tileY)
    local unit = Enemy_Soldier.unit
    if unit.isMoving then return end

    local path = Pathfinding.findPath(
        unit.tileX,
        unit.tileY,
        tileX,
        tileY,
        Map.canMove
    )

    Movement.start(unit, path)
end

function Enemy_Soldier.update(dt)
    local unit = Enemy_Soldier.unit
    Movement.update(unit, dt)   

    local anim = unit.animations[unit.currentAnimation]
    if not anim or anim.frameCount <= 1 then return end

    unit.frameTimer = unit.frameTimer + dt
    if unit.frameTimer >= anim.speed then
        unit.currentFrame = unit.currentFrame + 1
        if unit.currentFrame > anim.frameCount then
            unit.currentFrame = 1
        end
        unit.frameTimer = 0
    end
end

function Enemy_Soldier.draw()
    local unit = Enemy_Soldier.unit
    local anim = unit.animations[unit.currentAnimation]
    if not anim then return end

    local quad = anim.quads[unit.currentFrame]
    if not quad then return end

    local _, _, qw, qh = quad:getViewport()
    local offsetX = qw / 2
    local offsetY = qh - 50

    local drawX = unit.tileX
    local drawY = unit.tileY
    if unit.isMoving then
        local t = unit.moveTime / unit.moveDuration
        drawX = unit.startX + (unit.targetX - unit.startX) * t
        drawY = unit.startY + (unit.targetY - unit.startY) * t
    end

    local px = (drawX - 1) * Enemy_Soldier.tileSize + Enemy_Soldier.tileSize / 2
    local py = (drawY - 1) * Enemy_Soldier.tileSize + Enemy_Soldier.tileSize

    local scaleX = Enemy_Soldier.scaleX
    if unit.facingX < 0 then scaleX = -scaleX end

    love.graphics.draw(anim.img, quad, px, py, 0, scaleX, Enemy_Soldier.scaleY, offsetX, offsetY)

    -- Selection highlight
    if unit.selected then
        love.graphics.setColor(1, 0, 0, 0.3)
        love.graphics.rectangle(
            "fill",
            (unit.tileX - 1) * Enemy_Soldier.tileSize,
            (unit.tileY - 1) * Enemy_Soldier.tileSize,
            Enemy_Soldier.tileSize,
            Enemy_Soldier.tileSize
        )
        love.graphics.setColor(1,1,1,1)
    end
end
function Enemy_Soldier.isClicked(mx, my)
    local unit = Enemy_Soldier.unit

    local px = (unit.tileX - 1) * Enemy_Soldier.tileSize
    local py = (unit.tileY - 1) * Enemy_Soldier.tileSize

    return mx >= px and mx < px + Enemy_Soldier.tileSize
       and my >= py and my < py + Enemy_Soldier.tileSize
end

function Enemy_Soldier.isHovered(mx, my)
    return Enemy_Soldier.isClicked(mx, my)
end

function Enemy_Soldier.setSelected(value)
    Enemy_Soldier.unit.selected = value
end

return Enemy_Soldier