Effects = {}

local activeEffects = {}
Effects.cursorEffects = {}
Effects.cursorEffect = nil  -- only 1 active cursor

function Effects.damage(x, y, amount)
    table.insert(activeEffects, {
        x = x,
        y = y,
        text = tostring(amount),
        alpha = 1,
        timer = 0,
        duration = 1.0
    })
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
    -- Update the cursor effect
    if Effects.cursorEffect then
        local effect = Effects.cursorEffect
        effect.timer = effect.timer + dt
        if effect.timer >= effect.duration then
            effect.timer = effect.timer - effect.duration
        end
    end

    -- Existing damage effects
    for i = #activeEffects, 1, -1 do
        local effect = activeEffects[i]
        effect.timer = effect.timer + dt
        effect.y = effect.y - 20 * dt
        effect.alpha = 1 - (effect.timer / effect.duration)
        if effect.timer >= effect.duration then
            table.remove(activeEffects, i)
        end
    end
end

function Effects.draw()
    if Effects.cursorEffect then
        local effect = Effects.cursorEffect
        local alpha = 0.4 + 0.6 * math.sin(effect.timer * math.pi * 2 / effect.duration)
        love.graphics.setColor(1, 1, 0, alpha) -- yellow shimmer
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", effect.x, effect.y, TILE_SIZE, TILE_SIZE)
    end

    -- Draw damage effects
    for _, effect in ipairs(activeEffects) do
        love.graphics.setColor(1, 0, 0, effect.alpha)
        love.graphics.print(effect.text, effect.x, effect.y)
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end
