-- modules/engine/mouse.lua
local Mouse = {}
local Cursor = require("modules.ui.cursor")
local UnitManager = require("modules.units.manager")
local MovementRange = require("modules.engine.movement_range")
local Menu = require("modules.ui.menu")

function Mouse.pressed(x, y, button)
    -- 1. Priority: Handle Menu Interaction
    if UnitManager.state == "menu" then
        if button == 1 then
            local hit = Menu.clicked(x, y)
            -- If clicked outside menu, maybe treat as cancel?
            -- For now, force them to click an option or Right Click to cancel
        end
        
        -- Right click acts as Cancel button
        if button == 2 then
            UnitManager.cancelMove()
        end
        return
    end

    -- 2. Priority: Handle Unit Selection/Movement (IDLE state)
    local tx = Cursor.tileX
    local ty = Cursor.tileY
    
    if button == 1 then
        local clickedUnit = UnitManager.getUnitAt(tx, ty)
        local currentSelected = UnitManager.selectedUnit

        if clickedUnit then
            -- Can't select enemies or switch units while moving (though state check covers this)
            if UnitManager.state == "idle" then
                UnitManager.select(clickedUnit)
            end
        
        elseif currentSelected and UnitManager.state == "idle" then
            if MovementRange.canReach(tx, ty) then
                local success = currentSelected:tryMove(tx, ty)
                if success then
                    UnitManager.state = "moving"
                end
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