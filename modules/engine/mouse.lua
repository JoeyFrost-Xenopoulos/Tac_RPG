-- modules/engine/mouse.lua
local Mouse = {}
local Cursor = require("modules.ui.cursor")
local UnitManager = require("modules.units.manager")
local MovementRange = require("modules.engine.movement_range") -- Added this

function Mouse.pressed(x, y, button)
    local tx = Cursor.tileX
    local ty = Cursor.tileY
    
    if button == 1 then
        local clickedUnit = UnitManager.getUnitAt(tx, ty)
        local currentSelected = UnitManager.selectedUnit

        if clickedUnit then
            UnitManager.select(clickedUnit)
        
        elseif currentSelected then
            if MovementRange.canReach(tx, ty) then
                currentSelected:tryMove(tx, ty)
            else
                UnitManager.deselectAll()
            end
            
        else
            UnitManager.deselectAll()
        end
    end

    if button == 2 then
        UnitManager.deselectAll()
    end
end

return Mouse