Character = {}
Character.data = {}

function Character.init()
    Character.data["hero"] = {
        animations = {
            idle = {
                img = love.graphics.newImage("units/Warrior/Warrior_idle.png"),
                frames = {
                    {x=0,   y=0, width=80, height=124},
                    {x=192, y=0, width=80, height=124},
                    {x=384, y=0, width=82, height=124},
                    {x=576, y=0, width=82, height=124},
                    {x=768, y=0, width=82, height=124},
                    {x=960, y=0, width=82, height=124},
                    {x=1152, y=0, width=82, height=124},
                    {x=1344, y=0, width=82, height=124},
                },
                speed = 0.10
            },
            walk = {
                img = love.graphics.newImage("units/Warrior/Warrior_Run.png"),
                frames = {
                    {x=0,   y=0, width=80, height=124},
                    {x=192, y=0, width=80, height=124},
                    {x=384, y=0, width=82, height=124},
                    {x=576, y=0, width=82, height=124},
                    {x=768, y=0, width=90, height=124},
                    {x=960, y=0, width=90, height=124},
                },
                speed = 0.08
            },
            attack = {
                img = love.graphics.newImage("units/Warrior/Warrior_Attack1.png"),
                frames = {
                    {x=0,   y=0, width=68, height=126},
                    {x=188, y=0, width=70, height=126},
                    {x=370, y=0, width=126, height=126},
                    {x=560, y=0, width=126, height=126},
                },
                speed = 0.15
            }
        }
    }

    for _, char in pairs(Character.data) do
        for animName, anim in pairs(char.animations) do
            local quads = {}
            local imgWidth, imgHeight = anim.img:getDimensions()
            for _, f in ipairs(anim.frames) do
                table.insert(quads, love.graphics.newQuad(f.x, f.y, f.width, f.height, imgWidth, imgHeight))
            end
            anim.quads = quads
            anim.frameCount = #quads
        end
    end

    Character.data["hero"].animations.hurt = {
        img = love.graphics.newImage("units/Warrior/Warrior_Guard.png"),
        frames = {
            {x=0,   y=0, width=80, height=110},
            {x=192, y=0, width=80, height=110},
            {x=384, y=0, width=80, height=110},
            {x=576, y=0, width=80, height=110},
            {x=768, y=0, width=80, height=110},
            {x=960, y=0, width=80, height=110},
        },
        speed = 0.1
    }

    for _, f in ipairs(Character.data["hero"].animations.hurt.frames) do
        local anim = Character.data["hero"].animations.hurt
        local imgWidth, imgHeight = anim.img:getDimensions()
        anim.quads = anim.quads or {}
        table.insert(anim.quads, love.graphics.newQuad(f.x, f.y, f.width, f.height, imgWidth, imgHeight))
    end
    Character.data["hero"].animations.hurt.frameCount = #Character.data["hero"].animations.hurt.quads

end

function Character.assignToUnit(unit, name)
    local char = Character.data[name]
    if not char then
        print("Character not found: " .. tostring(name))
        return
    end
    unit.animations = char.animations
    unit.currentAnimation = "idle"
    unit.currentFrame = 1
    unit.frameTimer = 0
end

function Character.update(dt, unit)
    if not unit.animations then return end

    if unit.isHurt then
        if unit.currentAnimation ~= "hurt" then
            unit.currentAnimation = "hurt"
            unit.currentFrame = 1
            unit.frameTimer = 0
        end
    elseif unit.isAttacking then
        if unit.currentAnimation ~= "attack" then
            unit.currentAnimation = "attack"
            unit.currentFrame = 1
            unit.frameTimer = 0
        end
    elseif unit.isMoving then
        unit.idleDelayTimer = 0
        if unit.currentAnimation ~= "walk" then
            unit.currentAnimation = "walk"
            unit.currentFrame = 1
            unit.frameTimer = 0
        end
    else
        unit.idleDelayTimer = (unit.idleDelayTimer or 0) + dt
        if unit.idleDelayTimer >= 0.5 then
            if unit.currentAnimation ~= "idle" then
                unit.currentAnimation = "idle"
                unit.currentFrame = 1
                unit.frameTimer = 0
            end
        end
    end

    local anim = unit.animations[unit.currentAnimation]
    if not anim or anim.frameCount <= 1 then return end

    unit.frameTimer = unit.frameTimer + dt
    if unit.frameTimer >= anim.speed then
        unit.currentFrame = unit.currentFrame + 1

        if unit.currentFrame > anim.frameCount then
            if unit.currentAnimation == "attack" then
                unit.isAttacking = false
                unit.currentAnimation = "idle"
                unit.currentFrame = 1
            elseif unit.currentAnimation == "hurt" then
                -- Hurt animation finished
                unit.isHurt = false
                unit.currentAnimation = "idle"
                unit.currentFrame = 1
            else
                unit.currentFrame = 1
            end
        end

        unit.frameTimer = 0
    end
end

function Character.draw(unit, scaleX, scaleY)
    scaleX = scaleX or 1
    scaleY = scaleY or 1

    if not unit.animations or not unit.currentAnimation then return end

    local anim = unit.animations[unit.currentAnimation]
    if not anim or not anim.quads or not anim.quads[unit.currentFrame] or not anim.img then
        return
    end

    local quad = anim.quads[unit.currentFrame]
    local _, _, qw, qh = quad:getViewport()

    local offsetX = qw / 2
    local offsetY = qh / 2

    local px = unit.pixelX + TILE_SIZE / 2
    local py = unit.pixelY + TILE_SIZE / 2
    local finalScaleX = scaleX
    if unit.isMoving and unit.moveDirX and unit.moveDirX < 0 then
        finalScaleX = -scaleX
    end

    -- Grey out if unit has acted
    local colorMod = (unit.hasActed and 0.3) or 1
    love.graphics.setColor(colorMod, colorMod, colorMod, 1)
    love.graphics.draw(anim.img, quad, px, py, 0, finalScaleX, scaleY, offsetX, offsetY)

    love.graphics.setColor(1, 1, 1, 1)
end
