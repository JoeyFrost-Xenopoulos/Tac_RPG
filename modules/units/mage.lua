Mage = {}

function Mage.init()
    Mage.data = {}

    Mage.data["mage"] = {
        animations = {
            idle = {
                img = love.graphics.newImage("units/Player/Monk/Monk_Idle.png"),
                frames = {
                    {x=0,   y=0, width=80, height=110},
                    {x=192, y=0, width=80, height=110},
                    {x=384, y=0, width=80, height=110},
                    {x=576, y=0, width=80, height=110},
                    {x=768, y=0, width=80, height=110},
                    {x=960, y=0, width=80, height=110}
                },
                speed = 0.26
            },

            walk = {
                img = love.graphics.newImage("units/Player/Monk/Monk_Run.png"),
                frames = {
                    {x=0,   y=0, width=90, height=110},
                    {x=192, y=0, width=90, height=110},
                    {x=384, y=0, width=90, height=110},
                    {x=576, y=0, width=90, height=110}
                },
                speed = 0.16
            },

            attack = {
                img = love.graphics.newImage("units/Player/Monk/Monk_Cast.png"),
                frames = {
                    {x=0,   y=0, width=70, height=192},
                    {x=184, y=0, width=85, height=192},
                    {x=360, y=0, width=110, height=192},
                    {x=550, y=0, width=130, height=192},
                    {x=738, y=0, width=130, height=192},
                    {x=926, y=0, width=130, height=192},
                    {x=1124, y=0, width=130, height=192},
                    {x=1320, y=0, width=130, height=192},
                    {x=1508, y=0, width=130, height=192},
                    {x=1704, y=0, width=130, height=192},
                    {x=1916, y=0, width=70, height=192}
                },
                speed = 0.36,
                fireFrame = 4
            }
        }
    }

    for _, mage in pairs(Mage.data) do
        for _, anim in pairs(mage.animations) do
            anim.quads = {}
            local w, h = anim.img:getDimensions()
            for _, f in ipairs(anim.frames) do
                table.insert(anim.quads,
                    love.graphics.newQuad(f.x, f.y, f.width, f.height, w, h)
                )
            end
            anim.frameCount = #anim.quads
        end
    end

    Mage.spellImg = love.graphics.newImage("units/Player/Monk/Heal_Effect.png")
    Mage.spellFrames = {
        {x=0,   y=0, width=192, height=192},
        {x=192, y=0, width=192, height=192},
        {x=384, y=0, width=192, height=192},
        {x=576, y=0, width=192, height=192},
        {x=768, y=0, width=192, height=192},
        {x=960, y=0, width=192, height=192},
        {x=1152, y=0, width=192, height=192},
        {x=1344, y=0, width=192, height=192},
        {x=1536, y=0, width=192, height=192},
        {x=1728, y=0, width=192, height=192},
        {x=1920, y=0, width=192, height=192}
    }

    Mage.spellQuads = {}
    local w, h = Mage.spellImg:getDimensions()
    for _, f in ipairs(Mage.spellFrames) do
        table.insert(Mage.spellQuads,
            love.graphics.newQuad(f.x, f.y, f.width, f.height, w, h)
        )
    end

    Mage.activeSpells = {}
end

function Mage.assignToUnit(unit, name)
    local mage = Mage.data[name]
    if not mage then
        print("Mage type not found: " .. tostring(name))
        return
    end

    unit.animations = mage.animations
    unit.currentAnimation = "idle"
    unit.currentFrame = 1
    unit.frameTimer = 0
    unit.facingX = 1
    unit.spellFired = false
    unit.actionType = nil
end

function Mage.update(dt, unit)
    if not unit.animations then return end

    if unit.isMoving and unit.moveDirX then
        unit.facingX = unit.moveDirX
    elseif unit.isAttacking and unit.attackDirX then
        unit.facingX = unit.attackDirX
    end

    local anim = unit.animations[unit.currentAnimation]
    if not anim or anim.frameCount <= 1 then return end

    if unit.currentAnimation == "attack"
        and anim.fireFrame
        and unit.currentFrame == anim.fireFrame
        and not unit.spellFired then

        unit.spellFired = true

        if unit.attackTarget then
            local color

            if unit.actionType == "attack" and unit.attackTarget.team ~= unit.team then
                color = {1, 0.6, 0}
            elseif unit.actionType == "heal" then
                color = {1, 1, 1}
            else
                color = {1, 1, 1}
            end

            Mage.spawnSpellEffect(unit.attackTarget, color)
        end
    end

    unit.frameTimer = unit.frameTimer + dt
    if unit.frameTimer >= anim.speed then
        unit.currentFrame = unit.currentFrame + 1
        unit.frameTimer = 0

        if unit.currentFrame > anim.frameCount then
            unit.currentFrame = 1

            if unit.currentAnimation == "attack" then
                unit.isAttacking = false
                unit.spellFired = false
                unit.attackTarget = nil
                unit.actionType = nil
                unit.currentAnimation = "idle"
            end
        end
    end
end

function Mage.spawnSpellEffect(target, color)
    table.insert(Mage.activeSpells, {
        x = target.pixelX + TILE_SIZE / 2,
        y = target.pixelY + TILE_SIZE / 2,
        t = 0,
        duration = 0.8,
        frame = 1,
        frameTimer = 0,
        frameSpeed = 0.08,
        color = color or {1, 1, 1}
    })
end

function Mage.updateSpells(dt)
    for i = #Mage.activeSpells, 1, -1 do
        local s = Mage.activeSpells[i]
        s.t = s.t + dt / s.duration

        if s.t >= 1 then
            table.remove(Mage.activeSpells, i)
        else
            s.frameTimer = s.frameTimer + dt
            if s.frameTimer >= s.frameSpeed then
                s.frame = s.frame + 1
                if s.frame > #Mage.spellQuads then
                    s.frame = 1
                end
                s.frameTimer = 0
            end
        end
    end
end

function Mage.drawSpells(scale)
    scale = scale or (TILE_SIZE / 100)

    for _, s in ipairs(Mage.activeSpells) do
        love.graphics.setColor(s.color[1], s.color[2], s.color[3], 1)
        love.graphics.draw(
            Mage.spellImg,
            Mage.spellQuads[s.frame],
            s.x,
            s.y,
            0,
            scale, scale,
            192 / 2, 192 / 2
        )
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return Mage
