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
            }
        }
    }

    for _, char in pairs(Character.data) do
        for animName, anim in pairs(char.animations) do
            local quads = {}
            local imgWidth, imgHeight = anim.img:getDimensions() -- use animation's own image
            for _, f in ipairs(anim.frames) do
                table.insert(quads, love.graphics.newQuad(f.x, f.y, f.width, f.height, imgWidth, imgHeight))
            end
            anim.quads = quads
            anim.frameCount = #quads
        end
    end
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

    -- Switch animation based on movement
    if unit.isMoving then
        if unit.currentAnimation ~= "walk" then
            unit.currentAnimation = "walk"
            unit.currentFrame = 1
            unit.frameTimer = 0
        end
    else
        if unit.currentAnimation ~= "idle" then
            unit.currentAnimation = "idle"
            unit.currentFrame = 1
            unit.frameTimer = 0
        end
    end

    local anim = unit.animations[unit.currentAnimation]
    if not anim or anim.frameCount <= 1 then return end

    -- Advance frame
    unit.frameTimer = unit.frameTimer + dt
    if unit.frameTimer >= anim.speed then
        unit.currentFrame = unit.currentFrame + 1
        if unit.currentFrame > anim.frameCount then
            unit.currentFrame = 1
        end
        unit.frameTimer = 0
    end
end

-- Draw unit
function Character.draw(unit, scaleX, scaleY)
    scaleX = scaleX or 1
    scaleY = scaleY or 1

    if not unit.animations or not unit.currentAnimation then
        return
    end

    local anim = unit.animations[unit.currentAnimation]
    if not anim or not anim.quads or not anim.quads[unit.currentFrame] or not anim.img then
        return
    end

    local px = unit.pixelX + TILE_SIZE / 2
    local py = unit.pixelY + TILE_SIZE / 2

    local quad = anim.quads[unit.currentFrame]
    local _, _, qw, qh = quad:getViewport()
    local offsetX = qw / 2
    local offsetY = qh / 2

    love.graphics.draw(anim.img, quad, px, py, 0, scaleX, scaleY, offsetX, offsetY)
end
