-- modules/manager/damage.lua
local function attach(UnitManager)
    local Grid = require("modules.ui.grid")

    function UnitManager.showDamage(target, damage)
        table.insert(UnitManager.damageDisplays, {
            x = target.tileX * Grid.tileSize + 32,
            y = target.tileY * Grid.tileSize,
            damage = damage,
            time = 0,
            duration = 1.0
        })
    end

    function UnitManager.updateDamageDisplays(dt)
        for i = #UnitManager.damageDisplays, 1, -1 do
            local display = UnitManager.damageDisplays[i]
            display.time = display.time + dt

            if display.time >= display.duration then
                table.remove(UnitManager.damageDisplays, i)
            end
        end
    end

    function UnitManager.drawDamageDisplays()
        if #UnitManager.damageDisplays == 0 then return end

        love.graphics.setFont(love.graphics.newFont("assets/ui/font/Pixel_Font.otf", 48))
        love.graphics.setColor(1, 0, 0, 1)

        for _, display in ipairs(UnitManager.damageDisplays) do
            local alpha = 1 - (display.time / display.duration)
            local offsetY = display.time * 30

            love.graphics.setColor(1, 0, 0, alpha)
            love.graphics.printf(tostring(display.damage), display.x - 20, display.y - offsetY, 40, "center")
        end

        love.graphics.setColor(1, 1, 1, 1)
    end
end

return attach
