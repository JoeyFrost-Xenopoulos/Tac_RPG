local Soldier = {}
local Pathfinding = require("modules.engine.pathfinding")
local Movement = require("modules.engine.movement")
local Map = require("modules.world.map")

Soldier.unit = {}
Soldier.animations = {}

-- Tile/grid settings
Soldier.tileSize = 64
Soldier.scaleX = 0.85
Soldier.scaleY = 0.85
Soldier.unit.facingX = 1

Soldier.unit.selected = false
Soldier.unit.moveDuration = 0.05 -- seconds per tile

function Soldier.load()
    -- IDLE animation
    Soldier.animations.idle = {
        img = love.graphics.newImage("assets/units/Player/Soldier/Warrior_Idle.png"),
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
    Soldier.animations.walk = {
        img = love.graphics.newImage("assets/units/Player/Soldier/Warrior_Run.png"),
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
    Soldier.animations.attack = {
        img = love.graphics.newImage("assets/units/Player/Soldier/Warrior_Attack1.png"),
        frames = {
            {x=0,   y=0, width=68, height=126},
            {x=188, y=0, width=70, height=126},
        },
        speed = 0.15
    }

    for name, anim in pairs(Soldier.animations) do
        local quads = {}
        local imgW, imgH = anim.img:getDimensions()
        for _, f in ipairs(anim.frames) do
            table.insert(quads, love.graphics.newQuad(f.x, f.y, f.width, f.height, imgW, imgH))
        end
        anim.quads = quads
        anim.frameCount = #quads
    end

    Soldier.unit.animations = Soldier.animations
    Soldier.unit.currentAnimation = "idle"
    Soldier.unit.currentFrame = 1
    Soldier.unit.frameTimer = 0
    Soldier.unit.tileX = 1
    Soldier.unit.tileY = 1
end

function Soldier.setPosition(tileX, tileY) 
    Soldier.unit.tileX = tileX 
    Soldier.unit.tileY = tileY 
end
function Soldier.tryMove(tileX, tileY) -- Removed 'isWalkable' arg, use global Map or pass Map.canMove
    local unit = Soldier.unit
    if unit.isMoving then return end

    -- Use the new Map.canMove function
    local path = Pathfinding.findPath(
        unit.tileX,
        unit.tileY,
        tileX,
        tileY,
        Map.canMove -- Pass the detailed transition checker
    )

    Movement.start(unit, path)
end

function Soldier.isClicked(mx, my)
    local unit = Soldier.unit

    local px = (unit.tileX - 1) * Soldier.tileSize
    local py = (unit.tileY - 1) * Soldier.tileSize

    return mx >= px and mx < px + Soldier.tileSize
       and my >= py and my < py + Soldier.tileSize
end

function Soldier.setSelected(value)
    Soldier.unit.selected = value
end

function Soldier.update(dt)
    local unit = Soldier.unit

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


function Soldier.draw()
    local unit = Soldier.unit
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

    local px = (drawX - 1) * Soldier.tileSize + Soldier.tileSize / 2
    local py = (drawY - 1) * Soldier.tileSize + Soldier.tileSize


    local scaleX = Soldier.scaleX
    if unit.facingX < 0 then scaleX = -scaleX end

    love.graphics.draw(anim.img, quad, px, py, 0, scaleX, Soldier.scaleY, offsetX, offsetY)

    -- Selection highlight
    if unit.selected then
        love.graphics.setColor(0, 1, 0, 0.3)
        love.graphics.rectangle(
            "fill",
            (unit.tileX - 1) * Soldier.tileSize,
            (unit.tileY - 1) * Soldier.tileSize,
            Soldier.tileSize,
            Soldier.tileSize
        )
        love.graphics.setColor(1,1,1,1)
    end
end


return Soldier