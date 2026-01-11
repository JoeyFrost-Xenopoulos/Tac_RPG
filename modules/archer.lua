-- modules/archer.lua
Archer = {}

function Archer.init()
    Archer.data = {}

    -- Define archer animations
    Archer.data["archer"] = {
        animations = {
            idle = {
                img = love.graphics.newImage("units/Player/Archer/Archer_idle.png"),
                frames = {
                    {x=0,   y=0, width=80, height=110},
                    {x=192, y=0, width=80, height=110},
                    {x=384, y=0, width=80, height=110},
                    {x=576, y=0, width=80, height=110},
                    {x=768, y=0, width=80, height=110},
                    {x=960, y=0, width=80, height=110},
                },
                speed = 0.20
            },

            walk = {
                img = love.graphics.newImage("units/Player/Archer/Archer_Run.png"),
                frames = {
                    {x=0,   y=0, width=80, height=110},
                    {x=192, y=0, width=80, height=110},
                    {x=384, y=0, width=80, height=110},
                    {x=576, y=0, width=80, height=110}
                },
                speed = 0.09
            },

            attack = {
                img = love.graphics.newImage("units/Player/Archer/Archer_Shoot.png"),
                frames = {
                    {x=0,   y=0, width=96, height=128},
                    {x=192, y=0, width=96, height=128},
                    {x=384, y=0, width=96, height=128},
                    {x=576, y=0, width=96, height=128},
                    {x=768, y=0, width=96, height=128},
                    {x=960, y=0, width=96, height=128},
                    {x=1052, y=0, width=96, height=128},
                    {x=1144, y=0, width=96, height=128}
                },
                speed = 0.10,
                fireFrame = 4
            }
        }
    }

    for _, archer in pairs(Archer.data) do
        for _, anim in pairs(archer.animations) do
            anim.quads = {}
            local imgW, imgH = anim.img:getDimensions()

            for _, f in ipairs(anim.frames) do
                table.insert(
                    anim.quads,
                    love.graphics.newQuad(
                        f.x, f.y,
                        f.width, f.height,
                        imgW, imgH
                    )
                )
            end

            anim.frameCount = #anim.quads
        end
    end

    -- Load arrow image once
    Archer.arrowImg = love.graphics.newImage("units/Player/Archer/Arrow.png")
    Archer.arrows = {}
end

function Units.findTarget(unit)
    for _, u in ipairs(Units.list) do
        if u.team ~= unit.team then
            return u
        end
    end
    return nil
end

function Archer.assignToUnit(unit, name)
    local archer = Archer.data[name]
    if not archer then
        print("Archer type not found: " .. tostring(name))
        return
    end

    unit.animations = archer.animations
    unit.currentAnimation = "idle"
    unit.currentFrame = 1
    unit.frameTimer = 0
    unit.facingX = 1
    unit.arrowFired = false
end

function Archer.update(dt, unit)
    if not unit.animations then return end

    if unit.isMoving and unit.moveDirX then
        unit.facingX = unit.moveDirX
    elseif unit.isAttacking and unit.attackDirX then
        unit.facingX = unit.attackDirX
    end

    local anim = unit.animations[unit.currentAnimation]
    if not anim or anim.frameCount <= 1 then return end

    if unit.currentAnimation == "attack" and anim.fireFrame and
    unit.currentFrame == anim.fireFrame and not unit.arrowFired then

        unit.arrowFired = true

        local target = Units.findTarget(unit)
        if target then
            Archer.spawnArrow(unit, target)
        end
    end

    unit.frameTimer = unit.frameTimer + dt
    if unit.frameTimer >= anim.speed then
        unit.currentFrame = unit.currentFrame + 1
        if unit.currentFrame > anim.frameCount then
            unit.currentFrame = 1
            if unit.currentAnimation == "attack" then
                unit.isAttacking = false
                unit.arrowFired = false
                unit.currentAnimation = "idle"
            end
        end
        unit.frameTimer = 0
    end
end

function Archer.spawnArrow(shooter, target)
    table.insert(Archer.arrows, {
        startX = shooter.pixelX + 32,
        startY = shooter.pixelY + 16,
        endX = target.pixelX + TILE_SIZE / 2,
        endY = target.pixelY + TILE_SIZE / 2,
        x = shooter.pixelX + 32,
        y = shooter.pixelY + 16,
        t = 0,
        duration = 0.5,
        lifeAfterHit = 0,
        opacity = 0.8
    })
end

function Archer.updateProjectiles(dt)
    for i = #Archer.arrows, 1, -1 do
        local a = Archer.arrows[i]

        if a.t < 1 then
            a.t = a.t + dt / a.duration

            if a.t >= 1 then
                a.t = 1
            end

            local tNext = math.min(a.t + 0.01, 1)
            local lx = a.startX + (a.endX - a.startX) * a.t
            local ly = a.startY + (a.endY - a.startY) * a.t
            local peak = 50
            local arc = 4 * peak * a.t * (1 - a.t)
            a.x = lx
            a.y = ly - arc

            local lxNext = a.startX + (a.endX - a.startX) * tNext
            local lyNext = a.startY + (a.endY - a.startY) * tNext
            local arcNext = 4 * peak * tNext * (1 - tNext)
            local xNext = lxNext
            local yNext = lyNext - arcNext

            a.angle = math.atan2(yNext - a.y, xNext - a.x)
        else
            a.lifeAfterHit = a.lifeAfterHit - dt
            a.opacity = math.max(0, a.lifeAfterHit / 0.5) -- fade from 1 -> 0

            if a.lifeAfterHit <= 0 then
                table.remove(Archer.arrows, i)
            end
        end
    end
end

function Archer.drawProjectiles()
    for _, a in ipairs(Archer.arrows) do
        love.graphics.setColor(1, 1, 1, a.opacity or 1)
        love.graphics.draw(
            Archer.arrowImg,
            a.x,
            a.y,
            a.angle,
            1, 1,
            Archer.arrowImg:getWidth()/2,
            Archer.arrowImg:getHeight()/2
        )
        love.graphics.setColor(1, 1, 1, 1) -- reset color
    end
end

return Archer
