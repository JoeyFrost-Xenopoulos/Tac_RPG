local Mouse = {}

local Soldier = require("modules.units.soldier")
local Enemy_Soldier = require("modules.units.enemy_soldier")

function Mouse.pressed(x, y, button)
    if button ~= 1 then return end

    local tx, ty = mouseToTile(x, y)

    -- Soldier click
    if Soldier.isClicked(x, y) then
        Soldier.setSelected(true)
        Enemy_Soldier.setSelected(false)
        return
    end

    -- Enemy click
    if Enemy_Soldier.isClicked(x, y) then
        Enemy_Soldier.setSelected(true)
        Soldier.setSelected(false)
        return
    end

    -- Move selected unit
    if Soldier.unit.selected then
        Soldier.tryMove(tx, ty)
        Soldier.setSelected(false)
        return
    end

    if Enemy_Soldier.unit.selected then
        Enemy_Soldier.tryMove(tx, ty)
        Enemy_Soldier.setSelected(false)
        return
    end
end

return Mouse
