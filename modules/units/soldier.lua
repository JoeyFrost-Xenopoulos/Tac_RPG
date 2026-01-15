local Soldier = {}

Soldier.unit = {}
Soldier.animations = {}

-- Tile/grid settings
Soldier.tileSize = 64
Soldier.scaleX = 0.85
Soldier.scaleY = 0.85
Soldier.unit.facingX = 1

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

function Soldier.update(dt)
    local unit = Soldier.unit
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
    local offsetX = qw/2
    local offsetY = qh/2 - 15

    local px = (unit.tileX-1) * Soldier.tileSize + Soldier.tileSize/2
    local py = (unit.tileY-1) * Soldier.tileSize + Soldier.tileSize/2

    local finalScaleX = Soldier.scaleX
    if unit.facingX < 0 then finalScaleX = -Soldier.scaleX end

    love.graphics.push()
    love.graphics.scale(finalScaleX, Soldier.scaleY)
    love.graphics.draw(anim.img, quad, px/finalScaleX, py, 0, 1, 1, offsetX, offsetY)
    love.graphics.pop()
end

return Soldier