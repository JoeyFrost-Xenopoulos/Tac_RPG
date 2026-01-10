Effects = {}

local activeEffects = {}

-- Create a damage effect
function Effects.damage(x, y, amount)
    table.insert(activeEffects, {
        x = x,
        y = y,
        text = tostring(amount),
        alpha = 1,        -- opacity
        timer = 0,        -- lifetime tracker
        duration = 1.0    -- 1 second
    })
end

-- Update all active effects
function Effects.update(dt)
    for i = #activeEffects, 1, -1 do
        local effect = activeEffects[i]
        effect.timer = effect.timer + dt
        effect.y = effect.y - 20 * dt    -- float upward
        effect.alpha = 1 - (effect.timer / effect.duration)

        if effect.timer >= effect.duration then
            table.remove(activeEffects, i)
        end
    end
end

-- Draw all active effects
function Effects.draw()
    for _, effect in ipairs(activeEffects) do
        love.graphics.setColor(1, 0, 0, effect.alpha) -- red for damage
        love.graphics.print(effect.text, effect.x, effect.y)
    end
    love.graphics.setColor(1, 1, 1, 1) -- reset color
end
