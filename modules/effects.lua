Effects = {}

local activeEffects = {}
local activeParticles = {}
Effects.cursorEffects = {}
Effects.cursorEffect = nil

function Effects.damage(x, y, amount, type)
    table.insert(activeEffects, {
        x = x,
        y = y,
        text = tostring(amount),
        alpha = 1,
        timer = 0,
        duration = 1.0,
        type = type or "damage"
    })
end

function Effects.spawnParticles(x, y, attackType)
    local num = 8

    for i = 1, num do
        local angle = math.random() * 2 * math.pi
        local speed = math.random(50, 80)
        local lifetime = 0.3 + math.random() * 0.3
        local size = 4 + math.random() * 2

        local color
        local shape = "circle"

        if attackType == "melee" then
            color = {1, 0.8, 0.5}
            shape = "slash"
            angle = math.random() * math.pi / 2 - math.pi/2
            speed = math.random(100, 150)
            size = 8 + math.random() * 4
        elseif attackType == "archer" then
            color = {1, 1, 0}
            shape = "circle"
            speed = math.random(40, 70)
            size = 2 + math.random() * 2
        elseif attackType == "mage" then
            color = {0.6, 0.2, 0.8}
            shape = "circle"
            speed = math.random(50, 80)
            size = 3 + math.random() * 3
        else
            color = {1, 1, 1}
            shape = "circle"
        end

        table.insert(activeParticles, {
            x = x,
            y = y,
            dx = math.cos(angle) * speed,
            dy = math.sin(angle) * speed,
            alpha = 1,
            size = size,
            timer = 0,
            duration = lifetime,
            color = color,
            shape = shape
        })
    end
end

function Effects.cursor(x, y)
    Effects.cursorEffect = {
        x = x,
        y = y,
        timer = 0,
        duration = 2 -- shimmer cycle
    }
end

function Effects.update(dt)
    -- Damage numbers
    for i = #activeEffects, 1, -1 do
        local effect = activeEffects[i]
        effect.timer = effect.timer + dt
        effect.y = effect.y - 20 * dt
        effect.alpha = 1 - (effect.timer / effect.duration)
        if effect.timer >= effect.duration then
            table.remove(activeEffects, i)
        end
    end

    -- Particles
    for i = #activeParticles, 1, -1 do
        local p = activeParticles[i]
        p.timer = p.timer + dt
        p.x = p.x + p.dx * dt
        p.y = p.y + p.dy * dt
        p.alpha = 1 - (p.timer / p.duration)
        if p.timer >= p.duration then
            table.remove(activeParticles, i)
        end
    end
end

function Effects.draw()
    for _, effect in ipairs(activeEffects) do
        love.graphics.setColor(1, 0, 0, effect.alpha)
        love.graphics.print(effect.text, effect.x, effect.y)
    end

    -- Spark particles
    for _, p in ipairs(activeParticles) do
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.alpha)

        if p.shape == "circle" then
            love.graphics.circle("fill", p.x, p.y, p.size)
        elseif p.shape == "slash" then
            local length = p.size * 2
            love.graphics.setLineWidth(2)
            love.graphics.line(p.x, p.y, p.x + math.cos(math.atan2(p.dy, p.dx)) * length, p.y + math.sin(math.atan2(p.dy, p.dx)) * length)
        end
    end
end